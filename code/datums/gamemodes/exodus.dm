#define STAGE_THRESHOLD_LOW 1
#define STAGE_THRESHOLD_MEDIUM 2
#define STAGE_THRESHOLD_HIGH 3
#define EXODUS_PROCESS_INTERVAL 20

#define STAGE_LOWPOP_ESCALATION_MULTIPLIER 0.20

#define XENO_POWER_LOW 0.5
#define XENO_POWER_MEDIUM 1.0
#define XENO_POWER_MAXIMUM 1.4

/datum/game_mode/exodus
	name = "Exodus"
	config_tag = "Exodus"
	required_players = 1
	round_type_flags = MODE_NO_PERMANENT_WOUNDS|MODE_DEAD_GRAB_FORBIDDEN

	///what threat stage we're in
	var/stage = 1
	///initial survivor count at the start
	var/initial_survivor_count = 0
	///how many survivors have escaped
	var/survivors_escaped = 0
	///how many survivors have been killed
	var/survivors_killed = 0
	///how much threat has accumulated during the round, used to advance stage
	var/threat_counter = 0

	///minimum threat needed to enter stage 2
	var/stage_2_threshold = 0
	///minimum threat needed to enter stage 3
	var/stage_3_threshold = 0

	///how much threat we add per death
	var/threat_per_death = 0
	///how much threat we add per escape
	var/threat_per_escape = 0
	///how much threat we add per pvp kill
	var/threat_per_pvp_kill = 0
	///passive threat gain
	var/threat_per_tick = 0

	// MASTER PACING KNOB
	var/threat_budget_per_survivor = 100
	var/stage_2_threshold_percent = 0.33
	///multiplier for death threat
	var/death_threat_factor = 0.75
	///multiplier for escape threat
	var/escape_threat_factor = 1.25
	///multiplier for PvP kill threat
	var/pvp_kill_threat_factor = 2.5
	///target time that a hypothetical peaceful round would run absent of other factors
	var/desired_peaceful_duration = 35 MINUTES
	///time until PVP penalties are enforced to the max, intended to allow survivors to get some scavenging done without PVP rushing things to stage 2
	var/pvp_threat_ramp_up_duration = 10 MINUTES
	///percentage of players that schematics spawn for
	///note: to create conflict we do not set this to 1.00, some players will not escape by design
	var/schematic_ratio = 0.70

	///The actual current alpha value of the area lighting overlay.
	var/current_light_alpha = 0
	///The alpha value the lighting system is currently animating towards.
	var/target_light_alpha = 0
	///The actual current color of the area lighting overlay.
	var/current_light_color = COLOR_EVENING_BLUE
	///The color the lighting system is currently targeting.
	var/target_light_color = COLOR_EVENING_BLUE
	///How many alpha points to change per process() tick. Higher = faster transition.
	var/light_transition_speed = 1

	valid_job_types = list(
		/datum/job/survivor = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START
	)

	var/list/xeno_caste_slots_by_stage_poplow = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 1
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 1,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/praetorian = 1
			)
		)
	var/list/xeno_caste_slots_by_stage_popmid = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 2
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 1,
				/mob/living/carbon/xenomorph/spitter = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/spitter = 1,
				/mob/living/carbon/xenomorph/praetorian = 1,
				/mob/living/carbon/xenomorph/crusher = 1
			)
		)
	var/list/xeno_caste_slots_by_stage_pophigh = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/drone = 1 // Add a drone for utility at high pop
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 3,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/spitter = 1,
				/mob/living/carbon/xenomorph/defender = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 3,
				/mob/living/carbon/xenomorph/spitter = 2,
				/mob/living/carbon/xenomorph/praetorian = 2,
				/mob/living/carbon/xenomorph/crusher = 1
			)
		)
	var/list/xeno_caste_slots_by_stage = list(
		///number stands for minimum pop, so "1" would be for pop between 1 and 15, "15" would be between 15 and 25 etc
		"1" = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 1
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 1,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/praetorian = 1
			)
		),
		"15" = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 2
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 1,
				/mob/living/carbon/xenomorph/spitter = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/spitter = 1,
				/mob/living/carbon/xenomorph/praetorian = 1,
				/mob/living/carbon/xenomorph/crusher = 1
			)
		),
		//anything over 25 uses this list
		"25" = list(
			STAGE_THRESHOLD_LOW = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/drone = 1 // Add a drone for utility at high pop
			),
			STAGE_THRESHOLD_MEDIUM = list(
				/mob/living/carbon/xenomorph/runner = 3,
				/mob/living/carbon/xenomorph/warrior = 2,
				/mob/living/carbon/xenomorph/spitter = 1,
				/mob/living/carbon/xenomorph/defender = 1
			),
			STAGE_THRESHOLD_HIGH = list(
				/mob/living/carbon/xenomorph/runner = 2,
				/mob/living/carbon/xenomorph/warrior = 3,
				/mob/living/carbon/xenomorph/spitter = 2,
				/mob/living/carbon/xenomorph/praetorian = 2,
				/mob/living/carbon/xenomorph/crusher = 1
			)
		)
	)

	// --- Temp Vars ---
	var/round_end_timer = 1 HOURS // Temporary win/loss for testing

	var/next_process_time

/datum/game_mode/exodus/can_start(bypass_checks = FALSE)
	. = ..()
	if(!.)
		return FALSE // Base checks failed.

	var/player_count = length(GLOB.ready_players)
	var/initial_xeno_count = (player_count >= 15) ? 2 : 1
	var/xenos_assigned = 0

	if(!set_valid_job_types() && !bypass_checks)
		return FALSE

	var/datum/job/xenomorph/runner_job = SSjob.GetJobType(/datum/job/xenomorph)
	if(!runner_job) CRASH("Exodus: Cannot find the /datum/job/xenomorph/runner job datum.")

	for(var/level = JOBS_PRIORITY_HIGH; level >= JOBS_PRIORITY_MEDIUM; level--)
		if(xenos_assigned >= initial_xeno_count) break

		for(var/mob/new_player/p in GLOB.ready_players)
			if(p.assigned_role) continue
			if(p.client.prefs.job_preferences[ROLE_XENOMORPH] == level)
				if(SSjob.AssignRole(p, runner_job))
					xenos_assigned++
					if(xenos_assigned >= initial_xeno_count) break

///	if(xenos_assigned < initial_xeno_count && !bypass_checks)
///		to_chat(world, "<b>Unable to start Exodus.</b> Could not find enough eligible players with a Xenomorph preference to fill the required [initial_xeno_count] slots.")
//		return FALSE


	return TRUE // We have successfully pre-assigned our xenos.

/// Announces the game mode to the players.
/datum/game_mode/exodus/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	priority_announce(
		message = "You are a survivor. Your colony has been overrun and the creatures are stirring. Find a way to escape.",
		title = "Exodus",
		type = ANNOUNCEMENT_PRIORITY,
		color_override = "red"
	)

/// Runs before character creation to set up the map with loot.
/datum/game_mode/exodus/pre_setup()
	. = ..()

	var/player_count = length(GLOB.ready_players)
	if(player_count > 0)
		var/schematic_count = ceil(player_count * schematic_ratio)
		schematic_count = max(schematic_count, 1)

		var/list/potential_spawn_locations = GLOB.exodus_blueprint_spawns.Copy()
		if(!potential_spawn_locations.len)
			CRASH("Exodus: No 'exodus_utility_spawn' landmarks found to spawn schematics.")

		shuffle_inplace(potential_spawn_locations)

		for(var/i in 1 to min(schematic_count, potential_spawn_locations.len))
			var/obj/effect/landmark/spawn_landmark = pick_n_take(potential_spawn_locations)
			if(spawn_landmark)
				new /obj/item/blueprints/escape_pod(spawn_landmark.loc)
				log_game("Exodus: Spawned escape pod schematic at [spawn_landmark.loc].")

	return TRUE

/datum/game_mode/exodus/setup()
	GLOB.spawns_by_job[/datum/job/survivor] = GLOB.exodus_survivor_spawns
	. = ..()
	return .
/datum/game_mode/exodus/post_setup()
	. = ..()

	initial_survivor_count = length(GLOB.alive_human_list_faction[FACTION_SURVIVOR])
	if(initial_survivor_count > 0)
		var/total_threat_budget = initial_survivor_count * threat_budget_per_survivor
		stage_2_threshold = total_threat_budget * stage_2_threshold_percent
		stage_3_threshold = total_threat_budget
		threat_per_death = threat_budget_per_survivor * death_threat_factor
		threat_per_escape = threat_budget_per_survivor * escape_threat_factor
		threat_per_pvp_kill = threat_budget_per_survivor * pvp_kill_threat_factor

		var/total_ticks_in_duration = desired_peaceful_duration / EXODUS_PROCESS_INTERVAL
		if(total_ticks_in_duration > 0)
			threat_per_tick = total_threat_budget / total_ticks_in_duration

	else
		threat_per_tick = 1
		stage_2_threshold = 1000
		stage_3_threshold = 3000

	log_game("Exodus mode starting with [initial_survivor_count] survivors.")
	log_game("Threat thresholds: Stage 2 at [stage_2_threshold], Stage 3 at [stage_3_threshold].")
	log_game("Threat values: Death=[threat_per_death], Escape=[threat_per_escape], PvP Kill=[threat_per_pvp_kill], Tick=[round(threat_per_tick, 0.01)].")

	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(handle_survivor_death))

	var/player_count = length(GLOB.joined_player_list)
	var/stage_1_xeno_cap = (player_count >= 15) ? 2 : 1
	var/player_xenos_spawned = length(GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
	var/ai_to_spawn = max(0, stage_1_xeno_cap - player_xenos_spawned)

	var/list/chosen_bracket = null
	switch(initial_survivor_count)
		if(1 to 14) // Low Pop
			chosen_bracket = xeno_caste_slots_by_stage_poplow
		if(15 to 24) // Mid Pop
			chosen_bracket = xeno_caste_slots_by_stage_popmid
		if(25 to INFINITY) // High Pop
			chosen_bracket = xeno_caste_slots_by_stage_pophigh

	xeno_caste_slots_by_stage = chosen_bracket.Copy()
	if(!xeno_caste_slots_by_stage) {
		xeno_caste_slots_by_stage = list() // Prevent runtimes
		CRASH("Exodus: Could not determine a valid xeno slot bracket for [initial_survivor_count] players.")
	}
	log_game("Exodus: Selected xeno population bracket for [initial_survivor_count] survivors.")
/*	// Iterate brackets from highest pop to lowest to find the first one we match.
	var/list/pop_brackets = sort_list(assoc_to_keys(xeno_caste_slots_by_stage), /proc/cmp_numeric_dsc)
	for(var/pop_key in pop_brackets)
		if(initial_survivor_count >= text2num(pop_key))
			chosen_bracket = xeno_caste_slots_by_stage[text2num(pop_key)]
			break

	xeno_caste_slots_by_stage = chosen_bracket
	if(!xeno_caste_slots_by_stage) ///somehow we've broken our selection criterion
		xeno_caste_slots_by_stage = list()
		CRASH("Exodus: Could not determine a valid xeno slot bracket for [initial_survivor_count] players. Xenos may not spawn.")
*/

	if(GLOB.exodus_xeno_spawns.len > 0)
		for(var/i in 1 to ai_to_spawn)
			var/obj/effect/landmark/spawn_landmark = pick(GLOB.exodus_xeno_spawns)
			new /mob/living/carbon/xenomorph/runner/ai(spawn_landmark.loc)
		if(ai_to_spawn > 0) log_game("Exodus: Spawned [ai_to_spawn] initial AI Xenos.")
	else if (ai_to_spawn > 0)
		CRASH("Exodus: Could not find any 'exodus_xeno_spawn' landmarks to spawn AI threat.")

	log_game("Exodus: Setting initial daylight lighting for ground map.")
	// Initialize our lighting state variables to match the desired start
	current_light_alpha = 225
	target_light_alpha = 225
	current_light_color = COLOR_EVENING_BLUE
	target_light_color = COLOR_EVENING_BLUE

	var/list/ground_z_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND)
	if(ground_z_levels?.len)
		for(var/area/A in GLOB.areas)
			if(A.z in ground_z_levels)
				A.set_base_lighting(COLOR_EVENING_BLUE, 225)
	else
		CRASH("Exodus: Could not find any Z-levels with ZTRAIT_GROUND to apply initial lighting.")

	SSmonitor.is_automatic_balance_on = FALSE //do we need to do this? doing it anyway for safety
	GLOB.xeno_stat_multiplicator_buff = XENO_POWER_LOW
	SSmonitor.apply_balance_changes()

	START_PROCESSING(SSprocessing, src)
	next_process_time = world.time + EXODUS_PROCESS_INTERVAL

	return TRUE

/datum/game_mode/exodus/process()
	if(world.time < next_process_time)
		return

	next_process_time = world.time + EXODUS_PROCESS_INTERVAL

	if(round_finished)
		return PROCESS_KILL

	threat_counter += threat_per_tick
	var/old_stage = stage

	if(stage == STAGE_THRESHOLD_LOW && threat_counter >= stage_2_threshold)
		escalate_to_stage(STAGE_THRESHOLD_MEDIUM)
	else if(stage == STAGE_THRESHOLD_MEDIUM && threat_counter >= stage_3_threshold)
		escalate_to_stage(STAGE_THRESHOLD_HIGH)

	var/lighting_changed = FALSE
	if(current_light_alpha < target_light_alpha)
		current_light_alpha = min(current_light_alpha + light_transition_speed, target_light_alpha)
		lighting_changed = TRUE
	else if(current_light_alpha > target_light_alpha)
		current_light_alpha = max(current_light_alpha - light_transition_speed, target_light_alpha)
		lighting_changed = TRUE

	if(stage != old_stage)
		current_light_color = target_light_color
		lighting_changed = TRUE

	if(lighting_changed)
		var/list/ground_z_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND)
		if(ground_z_levels?.len)
			for(var/area/A in GLOB.areas)
				if(A.z in ground_z_levels)
					A.set_base_lighting(current_light_color, round(current_light_alpha))

	if(initial_survivor_count <= initial_survivor_count * STAGE_LOWPOP_ESCALATION_MULTIPLIER && initial_survivor_count >= 2) ///escalate to stage 3 if we hit pop this low
		threat_counter = stage_3_threshold

/// Escalates the threat to the next stage, making the game more difficult.
/datum/game_mode/exodus/proc/escalate_to_stage(new_stage)
	if(stage >= new_stage) return

	var/old_stage = stage
	stage = new_stage

	switch(stage)
		if(STAGE_THRESHOLD_LOW) ///this should only naturally be reached during debugging since we start in stage 1
			target_light_alpha = 225
			target_light_color = COLOR_EVENING_BLUE
		if(STAGE_THRESHOLD_MEDIUM)
			GLOB.xeno_stat_multiplicator_buff = XENO_POWER_MEDIUM
			SSmonitor.apply_balance_changes()
			target_light_alpha = 90
			target_light_color = COLOR_EVENING_ORANGE
		if(STAGE_THRESHOLD_HIGH)
			GLOB.xeno_stat_multiplicator_buff = XENO_POWER_MAXIMUM
			SSmonitor.apply_balance_changes()
			target_light_alpha = 10
			target_light_color = COLOR_EVENING_BLACK

	if(stage > old_stage)
		switch(stage)
			if(2)
				priority_announce("Hostile biomass readings are surging. Threat level has escalated, analysis: escape advised.", "Threat Escalation")
			if(3)
				priority_announce("Hostile biomass readings have reached critical levels. Threat level has escalated, analysis: survival unlikely.", "Threat Escalation")
		log_game("Exodus: Threat escalated to Stage [stage]. Current threat: [threat_counter]/[stage_3_threshold]")
		///SEND_GLOBAL_SIGNAL(COMSIG_EXODUS_STAGE_CHANGED, stage)

	// TODO: Spawn new AI/Player xenos and unlock higher-tier castes.

/datum/game_mode/exodus/check_finished()
	if(round_finished) return TRUE

	if(world.time > SSticker.round_start_time + round_end_timer)
		round_finished = "Time Limit Reached" ///failsafe in case we end up getting stuck somehow
		return TRUE

	var/survivors_left = length(GLOB.alive_human_list_faction[FACTION_SURVIVOR])
	if(survivors_left <= 0 && initial_survivor_count > 0) {
		if(survivors_escaped >= initial_survivor_count * 0.5) {
			round_finished = "SURVIVOR VICTORY (Majority Evacuated)"
		} else {
			round_finished = "XENOMORPH VICTORY (Survivors Eliminated)"
		}
		return TRUE
	}

	var/kill_percentage_for_xeno_win = 0.80
	if(initial_survivor_count > 0 && survivors_killed >= initial_survivor_count * kill_percentage_for_xeno_win)
		round_finished = "XENOMORPH VICTORY (Attrition)"
		return TRUE

	return ..()

/// Signal handler for mob deaths. Updates threat counter.
/datum/game_mode/exodus/proc/handle_survivor_death(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!ishuman(victim) || !issurvivorjob(victim.job)) return

	var/mob/living/attacker = victim.ff_fingerprint

	survivors_killed++

	if(ishuman(attacker) && issurvivorjob(attacker.job) && !HAS_TRAIT(victim, TRAIT_DIED_ONCE))
		var/round_duration_so_far = world.time - SSticker.round_start_time
		var/scaling_factor = min(round_duration_so_far / pvp_threat_ramp_up_duration, 1.0)
		var/scaled_pvp_threat = LERP(threat_per_death, threat_per_pvp_kill, scaling_factor)
		threat_counter += scaled_pvp_threat
		message_admins("Exodus PvP Kill: [key_name(attacker)] killed [key_name(victim)]. Threat Added: [round(scaled_pvp_threat)].")
		if(scaling_factor > 0.5 && prob(30)) {
			priority_announce("The sounds of infighting echo across the sector, drawing the hive's attention...", "Sudden Aggression Detected")
		}
	else
		threat_counter += threat_per_death
	if(!HAS_TRAIT(victim, TRAIT_DIED_ONCE))
		ADD_TRAIT(victim, TRAIT_DIED_ONCE, attacker)

/// Called by escape pod logic to update counters and threat.
/datum/game_mode/exodus/proc/handle_survivor_escape(mob/living/carbon/human/survivor)
	if(!ishuman(survivor) || survivor.job.faction != FACTION_SURVIVOR) return

	survivors_escaped++
	threat_counter += threat_per_escape

/datum/game_mode/exodus/proc/recalculate_threat_values()
	// This is a debug proc to be called by an admin verb
	// It's a copy of the logic from post_setup()

	threat_counter = 0
	stage = 1
	initial_survivor_count = length(GLOB.alive_human_list)
	if(initial_survivor_count <= 0)
		initial_survivor_count = 1
		message_admins("Somehow we passed initial checks but didn't?")
	if(initial_survivor_count > 0) {
		var/total_threat_budget = initial_survivor_count * threat_budget_per_survivor
		stage_2_threshold = total_threat_budget * stage_2_threshold_percent
		stage_3_threshold = total_threat_budget
		threat_per_death = threat_budget_per_survivor * death_threat_factor
		threat_per_escape = threat_budget_per_survivor * escape_threat_factor
		threat_per_pvp_kill = threat_budget_per_survivor * pvp_kill_threat_factor
		var/total_ticks_in_duration = desired_peaceful_duration / EXODUS_PROCESS_INTERVAL
		if(total_ticks_in_duration > 0) {
			threat_per_tick = total_threat_budget / total_ticks_in_duration
		}
	} else {
		threat_per_tick = 1
		stage_2_threshold = 1000
		stage_3_threshold = 3000
	}

	log_game("Exodus threat values recalculated for [initial_survivor_count] survivors.")
	message_admins("Exodus threat values have been recalculated for the new total of [initial_survivor_count] survivors.")

/datum/game_mode/exodus/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	items += "Stage: [stage]"
	items += "Threat Value: [threat_counter]"
