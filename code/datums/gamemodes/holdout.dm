#define HOLDOUT_PROCESS_INTERVAL 5 // 0.5 seconds

// --- DATA STRUCTURE FOR A SINGLE SPAWN TASK ---
/datum/holdout_spawn_task
	var/type_path
	var/turf/spawn_location

// --- LANDMARK DEFINITION ---
/obj/effect/wavelandmark
	name = "wave spawn"
	/// The ID for this landmark, set in the map editor. Used by the map's JSON config.
	var/landmark_id = "" // Use a string to be safe with map editor input

/obj/effect/wavelandmark/Initialize(mapload)
	. = ..()
	GLOB.wavelandmarks += src // Assumes GLOB.wavelandmarks is a lazylist or initialized
	return INITIALIZE_HINT_NORMAL

// --- HOLDOUT GAME MODE ---
/datum/game_mode/holdout
	name = "Holdout"
	config_tag = "Holdout"
	required_players = 1 // Keep low for testing

	/// The wave configuration loaded from the map JSON.
	var/list/wave_config

	/// The current wave number we are on (0 = pre-round, 1-indexed for active waves).
	var/current_wave = 0
	/// The total number of waves for this map.
	var/total_waves = 0
	/// The world.time when the next wave or state transition is scheduled.
	var/next_event_time = 0
	/// The number of objectives at the start of the round.
	var/initial_objectives_count = 0
	/// Internal timer for the process() loop.
	var/next_process_time = 0

    /// The minimum number of players before spawn rate starts to increase.
    var/spawn_rate_min_pop = 5
    /// The number of players at which the spawn rate reaches its maximum.
    var/spawn_rate_max_pop = 30
    /// The number of enemies to spawn per process tick at minimum population.
    var/spawn_rate_min = 5
    /// The maximum number of enemies to spawn per process tick at maximum population.
    var/spawn_rate_max = 30

	/// A FIFO queue of /datum/holdout_spawn_task.
	var/list/spawn_queue = list()
	/// The index of the next task in spawn_queue to process.
	var/spawn_queue_cursor = 1

	// --- Game State Flags ---
	#define HOLDOUT_STATE_PREP 0
	#define HOLDOUT_STATE_WAVE_IN_PROGRESS 1
	#define HOLDOUT_STATE_INTERMISSION 2
	#define HOLDOUT_STATE_CLEANUP 3
	/// The current state of the game mode.
	var/holdout_state = HOLDOUT_STATE_PREP


/datum/game_mode/holdout/pre_setup()
	. = ..()
	wave_config = SSmapping.configs[GROUND_MAP].holdout_config
	if(!islist(wave_config) || !islist(wave_config["waves"]))
		CRASH("Holdout mode started on a map with no valid 'holdout_config' in its JSON.")

	total_waves = length(wave_config["waves"])
	return TRUE

/datum/game_mode/holdout/post_setup()
	. = ..()

	var/initial_delay = text2num(wave_config["initial_delay_minutes"]) * 1 MINUTES
	if(initial_delay <= 0) initial_delay = 20 MINUTES
	next_event_time = world.time + initial_delay

	priority_announce("You are defenders. Fortify your position and prepare to hold out. The first wave is expected in [DisplayTimeText(initial_delay)].", "Holdout Mission Briefing")

	initial_objectives_count = length(GLOB.wave_mission_objects)
	var/objective_health = text2num(wave_config["objective_health"])
	if(objective_health > 0)
		for(var/obj/structure/objective_atom in GLOB.wave_mission_objects) // Use a more specific type if possible
			objective_atom.max_integrity = objective_health
			objective_atom.obj_integrity = objective_atom.max_integrity

	START_PROCESSING(SSprocessing, src)
	next_process_time = world.time
	return TRUE

/datum/game_mode/holdout/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	// No global signals registered, but if we did, unregister here.
	// We unregister from individual mobs when they are qdel'd (handled by signal system).
	QDEL_LIST(spawn_queue) // Clean up any remaining spawn task datums
	return ..()


/datum/game_mode/holdout/process()
	if(world.time < next_process_time) return
	next_process_time = world.time + HOLDOUT_PROCESS_INTERVAL

	if(round_finished) return PROCESS_KILL

	if(!check_objectives_are_valid())
		round_finished = "Mission Objectives Lost"
		declare_completion()
		return PROCESS_KILL
	
	// Calculate a scaling factor (alpha) from 0.0 to 1.0 based on player count.
	var/player_count = length(GLOB.player_list)
	var/scaling_alpha = (player_count - spawn_rate_min_pop) / max(1, spawn_rate_max_pop - spawn_rate_min_pop)
	scaling_alpha = clamp(scaling_alpha, 0, 1) // Ensure it's between 0.0 and 1.0

	// Linearly interpolate between the min and max spawn rates using the scaling factor.
	var/max_spawns_per_tick = round(lerp(spawn_rate_min, spawn_rate_max, scaling_alpha))

	var/spawns_this_tick = 0

	if(spawn_queue.len > 0 && spawn_queue_cursor <= spawn_queue.len)
		while(spawn_queue_cursor <= spawn_queue.len && spawns_this_tick < max_spawns_per_tick) 
			var/datum/holdout_spawn_task/spawn_task = spawn_queue[spawn_queue_cursor]
			if(spawn_task) 
				spawn_single_enemy(spawn_task.type_path, spawn_task.spawn_location)
			
			spawn_queue_cursor++
			spawns_this_tick++

		if(spawn_queue_cursor > spawn_queue.len)  // We finished the queue
			QDEL_LIST(spawn_queue)
			spawn_queue = list()
			spawn_queue_cursor = 1

	// After processing the queue, check the main game state
	check_game_state()

/// Checks if all objectives are still intact.
/datum/game_mode/holdout/proc/check_objectives_are_valid()
	if(initial_objectives_count <= 0) return TRUE
	list_clear_nulls(GLOB.wave_mission_objects)
	if(GLOB.wave_mission_objects.len < initial_objectives_count)
		return FALSE
	return TRUE

/// Signal handler. Called when a spawned enemy is being deleted.
/datum/game_mode/holdout/proc/handle_enemy_qdel(datum/source_enemy)
	SIGNAL_HANDLER
	GLOB.wave_spawned_enemies -= source_enemy // 'source' is the enemy that sent the signal

/// Checks for wave transitions and victory conditions
/datum/game_mode/holdout/proc/check_game_state()
	// This switch is structured to prevent fall-through and multiple state changes in one tick.
	switch(holdout_state)
		if(HOLDOUT_STATE_PREP)
			if(world.time >= next_event_time)
				holdout_state = HOLDOUT_STATE_WAVE_IN_PROGRESS
				queue_up_next_wave()

		if(HOLDOUT_STATE_WAVE_IN_PROGRESS)
			if(spawn_queue.len == 0)  // Finished spawning this wave
				if(current_wave >= total_waves)
					holdout_state = HOLDOUT_STATE_CLEANUP
					priority_announce("All enemy waves have been deployed! Eliminate the remaining hostiles to secure victory!", "Final Wave")
				else
					holdout_state = HOLDOUT_STATE_INTERMISSION
					var/time_between_waves = text2num(wave_config["time_between_waves_minutes"]) * 1 MINUTES
					if(time_between_waves <= 0) time_between_waves = 5 MINUTES
					next_event_time = world.time + time_between_waves



		if(HOLDOUT_STATE_INTERMISSION)
			if(world.time >= next_event_time)
				holdout_state = HOLDOUT_STATE_WAVE_IN_PROGRESS
				queue_up_next_wave()

		if(HOLDOUT_STATE_CLEANUP)
			if(GLOB.wave_spawned_enemies.len == 0)
				round_finished = "All Waves Cleared"
				declare_completion()


/datum/game_mode/holdout/proc/queue_up_next_wave()
	current_wave++
	priority_announce("Warning! Wave [current_wave] is inbound!", "Incoming Wave", sound = 'sound/effects/snap.ogg')

	// --- 1. Get Wave Data ---
	// The wave list is 1-indexed in DM, but JSON might be 0-indexed if parsed naively.
	// Assuming the parser handles it correctly and wave_config["waves"] is a 1-indexed list in DM.
	if(current_wave > length(wave_config["waves"]))
		CRASH("Holdout: Tried to queue up wave #[current_wave], but only [length(wave_config["waves"])] waves are defined.")

	var/list/wave_data = wave_config["waves"][current_wave]
	if(!islist(wave_data))
		CRASH("Holdout: Wave data for wave #[current_wave] is not a valid list.")


	// --- 2. Prepare for Spawning ---
	var/player_count = length(GLOB.player_list)
	var/list/spawn_definitions = wave_data["spawns"]


	var/list/new_spawn_tasks = list()

	//do this once per wave
	var/list/available_landmarks = list() // Assoc list: "landmark_id" -> list of turfs
	for(var/obj/effect/wavelandmark/L in GLOB.wavelandmarks)
		if(L.landmark_id != "")  // Ensure landmark has an ID
			LAZYINITLIST(available_landmarks[L.landmark_id])
			available_landmarks[L.landmark_id] += L.loc



	// --- 3. Process Each Spawn Definition in the Wave ---
	for(var/list/spawn_info in spawn_definitions)

		// A. Determine Spawn Locations for this group
		var/list/landmark_ids = spawn_info["landmark_ids"]
		var/list/spawn_turfs = list()

		if(islist(landmark_ids))
			for(var/id in landmark_ids)
				if(available_landmarks[id])  // Check our lookup table
					spawn_turfs |= available_landmarks[id] // |= to add unique turfs




		// Fallback: If no valid landmark_ids were found or none were specified, use all available landmarks.
		if(!spawn_turfs.len)
			for(var/id in available_landmarks)
				spawn_turfs |= available_landmarks[id]

			if(!spawn_turfs.len) CRASH("Holdout: No wavelandmarks found on map at all for wave #[current_wave].")


		// B. Determine Number of Mobs to Spawn
		// Your JSON values are strings, so text2num is essential.
		var/pop_scaler = text2num(spawn_info["pop_scaler"])
		if(isnull(pop_scaler) || pop_scaler < 0) pop_scaler = 1.0 // Default to 1.0 if not defined or invalid

		var/number_to_spawn = ceil(player_count * pop_scaler)

		// Add a "min_spawn" field to the JSON for a minimum number per group
		var/min_spawn_count = text2num(spawn_info["min_spawn"]) // Will be null if not present
		if(isnull(min_spawn_count)) min_spawn_count = 1 // Default to at least 1
		number_to_spawn = max(number_to_spawn, min_spawn_count)

		// C. Pick Mobs from the Pool and Create Tasks
		var/list/mob_pool = spawn_info["mobs"]
		if(!islist(mob_pool)) continue // Skip if no mobs are defined for this spawn group

		for(var/i in 1 to number_to_spawn)
			var/mob_type_string = pickweight(mob_pool)
			if(!mob_type_string)
				log_game("Holdout: pickweight failed for mob_pool in wave #[current_wave]. Check weights.")
				continue

			var/type_path = text2path(mob_type_string)
			if(!ispath(type_path))
				log_game("Holdout: Invalid mob type path '[mob_type_string]' in wave #[current_wave].")
				continue


			// Use our datum for a clean, robust spawn task
			var/datum/holdout_spawn_task/task = new
			task.type_path = type_path
			task.spawn_location = pick(spawn_turfs)
			new_spawn_tasks += task



	// --- 4. Finalize the Queue ---
	shuffle_inplace(new_spawn_tasks) // Shuffle the final list to make spawn order less predictable
	spawn_queue = new_spawn_tasks
	spawn_queue_cursor = 1
	log_game("Holdout: Queued [spawn_queue.len] enemies for wave [current_wave].")

/// Spawns a single enemy and sets it up.
/datum/game_mode/holdout/proc/spawn_single_enemy(type_path, turf/spawn_location)
	var/mob/new_enemy = new type_path(spawn_location)
	if(new_enemy)
		LAZYADD(GLOB.wave_spawned_enemies, new_enemy)
		//handle enemies dying
		RegisterSignal(new_enemy, COMSIG_MOB_DEATH, PROC_REF(handle_enemy_qdel))
		//dunno if dying covers qdeleting, might as well listen for it too
		RegisterSignal(new_enemy, COMSIG_QDELETING, PROC_REF(handle_enemy_qdel))


/// Add gamemode related items to statpanel
/datum/game_mode/holdout/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	switch(holdout_state)
		if(HOLDOUT_STATE_PREP, HOLDOUT_STATE_INTERMISSION)
			if(next_event_time > world.time)
				items += "Time Until Next Wave: [DisplayTimeText(next_event_time - world.time)]"

		if(HOLDOUT_STATE_WAVE_IN_PROGRESS, HOLDOUT_STATE_CLEANUP)
			items += "Enemies Remaining: [length(GLOB.wave_spawned_enemies)]"

	items += "Current Wave: [current_wave]/[total_waves]"

// Cleanup defines
#undef HOLDOUT_PROCESS_INTERVAL
#undef HOLDOUT_STATE_PREP
#undef HOLDOUT_STATE_WAVE_IN_PROGRESS
#undef HOLDOUT_STATE_INTERMISSION
#undef HOLDOUT_STATE_CLEANUP
