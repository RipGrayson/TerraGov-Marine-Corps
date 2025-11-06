// In /datums/gamemodes/holdout.dm

#define HOLDOUT_PROCESS_INTERVAL 5 // How often the mode's main logic ticks (0.5 seconds)

// --- GLOBAL LISTS (in a global file like _globalvars/lists/game_modes.dm) ---
GLOBAL_LIST_EMPTY(wave_mission_objects)
GLOBAL_LIST_EMPTY(wave_spawned_enemies)
GLOBAL_LIST_EMPTY(wavelandmarks) // Populated by /obj/effect/wavelandmark/Initialize()

// --- LANDMARK DEFINITION ---
/obj/effect/wavelandmark
	name = "wave spawn"
	/// The ID for this landmark, set in the map editor. Used by the map's JSON config.
	var/landmark_id = 0

/obj/effect/wavelandmark/Initialize(mapload)
	. = ..()
	LAZYADD(GLOB.wavelandmarks, src)
	return INITIALIZE_HINT_NORMAL

// --- HOLDOUT GAME MODE ---
/datum/game_mode/holdout
	name = "Holdout"
	config_tag = "Holdout"
	required_players = 1 // Keep low for testing
	
	valid_job_types = list(
		/datum/job/defender/rifleman = -1,
		/datum/job/defender/engineer = 4,
		/datum/job/defender/medic = 4
	) // Assuming these job types exist
	
	/// The wave configuration loaded from the map JSON.
	var/list/wave_config

	/// The current wave number we are on (1-indexed).
	var/current_wave = 0
	/// The total number of waves for this map.
	var/total_waves = 0
	/// The world.time when the next wave is scheduled to begin.
	var/next_wave_time = 0
	/// The number of objectives at the start of the round.
	var/initial_objectives_count = 0

	/// A FIFO queue of spawn tasks. Each task is an assoc list: list("type" = /path, "turf" = /turf)
	var/list/spawn_queue = list()
	
	// --- Game State Flags ---
	#define HOLDOUT_STATE_PREP 0	  // The initial 20-minute wait
	#define HOLDOUT_STATE_WAVE_IN_PROGRESS 1 // A wave is actively spawning/fighting
	#define HOLDOUT_STATE_INTERMISSION 2   // In between waves
	#define HOLDOUT_STATE_CLEANUP 3		// Final wave is over, cleaning up stragglers
	/// The current state of the game mode.
	var/holdout_state = HOLDOUT_STATE_PREP


/datum/game_mode/holdout/pre_setup()
	. = ..()
	wave_config = SSmapping.configs[GROUND_MAP].holdout_config
	if(!wave_config || !islist(wave_config["waves"])) {
		CRASH("Holdout mode started on a map with no 'holdout_config' or 'waves' list in its JSON.")
	}
	total_waves = length(wave_config["waves"])
	return TRUE

/datum/game_mode/holdout/post_setup()
	. = ..()

	var/initial_delay = text2num(wave_config["initial_delay_minutes"]) * 1 MINUTES
	if(initial_delay <= 0) initial_delay = 20 MINUTES // Default if not specified or zero
	next_wave_time = world.time + initial_delay
	
	priority_announce("You are defenders. Fortify your position and prepare to hold out. The first wave is expected in [DisplayTimeText(initial_delay)].", "Holdout Mission Briefing")

	initial_objectives_count = length(GLOB.wave_mission_objects)
	var/objective_health = text2num(wave_config["objective_health"])
	if(objective_health > 0) {
		for(var/atom/movable/objective_atom in GLOB.wave_mission_objects) {
			if(HAS_TRAIT(objective_atom, TRAIT_HAS_INTEGRITY)) {
				objective_atom.set_max_integrity(objective_health)
				objective_atom.set_integrity(objective_atom.max_integrity)
			}
		}
	}
	
	// We don't need a COMSIG_GLOB_MOB_DEATH handler. We will have the enemies
	// signal us directly when they are deleted.
	START_PROCESSING(SSprocessing, src)
	next_process_time = world.time
	return TRUE

/datum/game_mode/holdout/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	// No signals to unregister if we do it on a per-mob basis
	return ..()


/// The main game loop for the mode, driven by SSprocessing.
/datum/game_mode/holdout/process()
	if(world.time < next_process_time) return
	next_process_time = world.time + HOLDOUT_PROCESS_INTERVAL

	if(round_finished) return PROCESS_KILL

	if(!check_objectives_are_valid()) {
		round_finished = "Mission Objectives Lost"
		declare_completion()
		return PROCESS_KILL
	}

	// --- Process the incremental spawn queue ---
	// Spawn a burst of enemies each process tick until the queue is empty.
	var/spawns_this_tick = 0
	var/max_spawns_per_tick = 5 // TUNABLE: How many enemies to spawn per 0.5s tick.
	while(spawn_queue.len > 0 && spawns_this_tick < max_spawns_per_tick) {
		var/list/spawn_task = popleft(spawn_queue)
		if(spawn_task) {
			var/type_path = spawn_task["type"]
			var/turf/spawn_location = spawn_task["turf"]
			if(type_path && spawn_location && !QDELETED(spawn_location)) {
				spawn_single_enemy(type_path, spawn_location)
			}
		}
		spawns_this_tick++
		
		// This is a micro-optimization. Since spawning a mob is fast, we don't need a full CHECK_TICK,
		// but we can stoplag briefly if we spawn a lot, to keep things smooth.
		if(spawns_this_tick % 5 == 0) stoplag()
	}
	
	// After processing the queue, check the main game state
	check_game_state()

/// Checks if all objectives are still intact.
/datum/game_mode/holdout/proc/check_objectives_are_valid()
	if(initial_objectives_count <= 0) return TRUE // No objectives to check

	list_clear_nulls(GLOB.wave_mission_objects)
	if(GLOB.wave_mission_objects.len < initial_objectives_count) {
		// An objective has been destroyed
		return FALSE
	}
	return TRUE

/// Signal handler in case an enemy is deleted. This is the primary way we track enemy deaths.
/datum/game_mode/holdout/proc/handle_enemy_qdel(datum/source)
	SIGNAL_HANDLER
	GLOB.wave_spawned_enemies -= source

/// Checks for wave transitions and victory conditions
/datum/game_mode/holdout/proc/check_game_state()
	switch(holdout_state)
		if(HOLDOUT_STATE_PREP)
			if(world.time >= next_wave_time) {
				holdout_state = HOLDOUT_STATE_WAVE_IN_PROGRESS
				queue_up_next_wave()
			}
		if(HOLDOUT_STATE_WAVE_IN_PROGRESS)
			if(spawn_queue.len == 0) { // Finished spawning the current wave
				if(current_wave >= total_waves) {
					holdout_state = HOLDOUT_STATE_CLEANUP
					priority_announce("All enemy waves have been deployed! Eliminate the remaining hostiles to secure victory!", "Final Wave")
				} else {
					holdout_state = HOLDOUT_STATE_INTERMISSION
					var/time_between_waves = text2num(wave_config["time_between_waves_minutes"]) * 1 MINUTES
					if(time_between_waves <= 0) time_between_waves = 5 MINUTES // Default
					next_wave_time = world.time + time_between_waves
					priority_announce("Wave [current_wave] cleared! Prepare for the next wave, expected in [DisplayTimeText(time_between_waves)].", "Wave Cleared")
				}
			}
		if(HOLDOUT_STATE_INTERMISSION)
			if(world.time >= next_wave_time) {
				holdout_state = HOLDOUT_STATE_WAVE_IN_PROGRESS
				queue_up_next_wave()
			}
		if(HOLDOUT_STATE_CLEANUP)
			// Victory condition: In cleanup phase and all enemies are gone.
			if(GLOB.wave_spawned_enemies.len == 0) {
				round_finished = "All Waves Cleared"
				declare_completion()
			}

/// Reads the wave config and populates the spawn_queue.
/datum/game_mode/holdout/proc/queue_up_next_wave()
	current_wave++
	priority_announce("Warning! Wave [current_wave] is inbound!", "Incoming Wave", 'sound/AI/hostile_detected.ogg')
	
	var/list/wave_data = wave_config["waves"][current_wave]
	if(!wave_data || !islist(wave_data["spawns"])) {
		log_warning("Holdout: Wave [current_wave] has no 'spawns' data in JSON.")
		return
	}

	var/player_count = length(GLOB.player_list)
	var/list/spawn_definitions = wave_data["spawns"]
	var/list/new_spawn_tasks = list()

	for(var/list/spawn_info in spawn_definitions) {
		var/list/landmark_ids = spawn_info["landmark_ids"]
		var/list/spawn_turfs = list()
		if(islist(landmark_ids)) {
			for(var/id in landmark_ids) {
				for(var/obj/effect/wavelandmark/L in GLOB.wavelandmarks) {
					if(L.landmark_id == text2num(id)) {
						spawn_turfs += L.loc
					}
				}
			}
		}
		if(!spawn_turfs.len) {
			log_warning("Holdout: Could not find wavelandmarks for wave [current_wave]. Using all landmarks as fallback.")
			for(var/obj/effect/wavelandmark/L in GLOB.wavelandmarks) spawn_turfs += L.loc
			if(!spawn_turfs.len) CRASH("Holdout: No wavelandmarks found on map at all.")
		}

		var/pop_scaler = text2num(spawn_info["pop_scaler"])
		if(isnull(pop_scaler)) pop_scaler = 1.0 // Default if missing
		var/number_to_spawn = ceil(player_count * pop_scaler)
		number_to_spawn = max(number_to_spawn, 1)

		var/list/mob_pool = spawn_info["mobs"]
		if(!islist(mob_pool) || !mob_pool.len) {
			log_warning("Holdout: Wave [current_wave] spawn entry has no 'mobs' defined.")
			continue
		}

		for(var/i in 1 to number_to_spawn) {
			var/mob_type_string = pickweight(mob_pool)
			if(!mob_type_string) continue
			var/type_path = text2path(mob_type_string)
			if(!ispath(type_path)) {
				log_warning("Holdout: Invalid mob type path '[mob_type_string]' in wave [current_wave].")
				continue
			}
			
			LAZYADD(new_spawn_tasks, list("type" = type_path, "turf" = pick(spawn_turfs)))
		}
	}

	shuffle_inplace(new_spawn_tasks)
	spawn_queue = new_spawn_tasks // Use assignment, not +=, to replace old queue
	log_game("Holdout: Queued [spawn_queue.len] enemies for wave [current_wave].")

/// Spawns a single enemy and sets it up.
/datum/game_mode/holdout/proc/spawn_single_enemy(type_path, turf/spawn_location)
	var/mob/new_enemy = new type_path(spawn_location)
	
	if(new_enemy) {
		// Only add a generic AI if the mob doesn't already have an AI preset.
		if(isliving(new_enemy) && !new_enemy.GetComponent(/datum/component/ai_controller)) {
			new_enemy.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/hostile_simple)
		}
		GLOB.wave_spawned_enemies += new_enemy
		// We listen for the QDELETING signal on each enemy. This is more robust than listening to GLOB_MOB_DEATH.
		RegisterSignal(new_enemy, COMSIG_QDELETING, src, PROC_REF(handle_enemy_qdel))
	} else {
		log_error("Holdout: Failed to create new enemy of type '[type_path]'.")
	}

#undef HOLDOUT_PROCESS_INTERVAL
