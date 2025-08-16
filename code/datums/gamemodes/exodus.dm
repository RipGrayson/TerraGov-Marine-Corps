#define STAGE_THRESHOLD_LOW 1
#define STAGE_THRESHOLD_MEDIUM 2
#define STAGE_THRESHOLD_HIGH 3

/datum/game_mode/exodus
	name = "Exodus"
	config_tag = "exodus"
	required_players = 1
	round_type_flags = MODE_NO_PERMANENT_WOUND|MODE_DEAD_GRAB_FORBIDDEN
	wait = 2 SECONDS

	var/stage = 1
	var/initial_survivor_count = 0
	var/survivors_escaped = 0
	var/survivors_killed = 0
	var/threat_counter = 0

	var/stage_2_threshold = 0
	var/stage_3_threshold = 0

	var/threat_per_death = 0
	var/threat_per_escape = 0
	var/threat_per_pvp_kill = 0
	var/threat_per_tick = 0

	var/threat_budget_per_survivor = 100      // MASTER PACING KNOB
	var/stage_2_threshold_percent = 0.33      // When Stage 2 triggers
	var/death_threat_factor = 0.75            // Multiplier for death threat
	var/escape_threat_factor = 1.25           // Multiplier for escape threat
	var/pvp_kill_threat_factor = 2.5          // Multiplier for PvP kill threat
	var/desired_peaceful_duration = 30 MINUTES // Target time for a peaceful round
	var/pvp_threat_ramp_up_duration = 10 MINUTES // Time for PvP penalty to scale to max
	var/schematic_ratio = 0.60                // % of players that schematics spawn for

	// --- Temp Vars ---
	var/round_end_timer = 15 MINUTES // Temporary win/loss for testing

/datum/game_mode/exodus/can_start(bypass_checks = FALSE)
	. = ..()
	if(!.) return FALSE

	if(!set_valid_job_types()) {
		return FALSE
	}
	return TRUE

/datum/game_mode/exodus/announce()
	to_chat(world, span_round_header("The Exodus has begun. You are a survivor. The creatures are stirring. Find a way to escape."))

/datum/game_mode/exodus/pre_setup()
	. = ..()

    var/player_count = length(GLOB.ready_players)
    if(player_count > 0) {
        var/schematic_count = ceil(player_count * schematic_ratio)
        schematic_count = max(schematic_count, 1)

        var/list/potential_spawn_locations = GLOB.exodus_utility_spawns.Copy()
        shuffle_inplace(potential_spawn_locations)

        for(var/i in 1 to min(schematic_count, potential_spawn_locations.len)) {
            var/obj/effect/landmark/spawn_landmark = pick_n_take(potential_spawn_locations)
            if(spawn_landmark) {
                new /obj/item/escape_pod_schematic(spawn_landmark.loc)
                log_game("Exodus: Spawned escape pod schematic at [spawn_landmark.loc].")
            }
        }
    }

	// TODO: Add logic to spawn other scavengeable loot here

	return TRUE


/datum/game_mode/exodus/setup()
    GLOB.spawns_by_job[/datum/job/survivor] = GLOB.exodus_survivor_spawns
    . = ..()
	return .

/datum/game_mode/exodus/post_setup()
    . = ..()

	initial_survivor_count = length(GLOB.alive_human_list_faction[FACTION_SURVIVOR])
    if(initial_survivor_count > 0) {
        var/total_threat_budget = initial_survivor_count * threat_budget_per_survivor

        stage_2_threshold = total_threat_budget * stage_2_threshold_percent
        stage_3_threshold = total_threat_budget

        threat_per_death = threat_budget_per_survivor * death_threat_factor
        threat_per_escape = threat_budget_per_survivor * escape_threat_factor
        threat_per_pvp_kill = threat_budget_per_survivor * pvp_kill_threat_factor

        var/total_ticks_in_duration = desired_peaceful_duration / wait
        if(total_ticks_in_duration > 0) {
            threat_per_tick = total_threat_budget / total_ticks_in_duration
        }
    } else {
        threat_per_tick = 1
        stage_2_threshold = 1000
        stage_3_threshold = 3000
    }

    log_game("Exodus mode starting with [initial_survivor_count] survivors.")
    log_game("Threat thresholds: Stage 2 at [stage_2_threshold], Stage 3 at [stage_3_threshold].")
    log_game("Threat values: Death=[threat_per_death], Escape=[threat_per_escape], PvP Kill=[threat_per_pvp_kill], Tick=[round(threat_per_tick, 0.01)].")

	RegisterSignal(SSdcs, COMSIG_MOB_DEATH, PROC_REF(handle_survivor_death))

    if(GLOB.exodus_xeno_spawns.len > 0) {
        var/turf/spawn_loc = pick(GLOB.exodus_xeno_spawns).loc
        var/mob/living/carbon/xenomorph/runner/ai/first_xeno = new(spawn_loc)
        if(first_xeno) {
            log_game("Exodus: Spawned initial Stage 1 AI Xeno: [first_xeno].")
        }
    } else {
        log_warning("Exodus: Could not find any 'exodus_xeno_spawn' landmarks to spawn threat.")
    }

    return TRUE

/datum/game_mode/exodus/process()
    if(round_finished)
        return PROCESS_KILL

    threat_counter += threat_per_tick

    // Check for stage escalation
    if(stage == 1 && threat_counter >= stage_2_threshold) {
        escalate_to_stage(STAGE_THRESHOLD_MEDIUM)
    } else if(stage == STAGE_THRESHOLD_MEDIUM && threat_counter >= stage_3_threshold) {
        escalate_to_stage(STAGE_THRESHOLD_HIGH)
    }

// This proc is now a placeholder for all the cool stage-up logic
/datum/game_mode/exodus/proc/escalate_to_stage(new_stage)
    if(stage >= new_stage) return // Already at or past this stage

    stage = new_stage
    priority_announce("Hostile biomass readings are surging. Threat level has escalated to Stage [stage]!", "Threat Escalation")
    log_game("Exodus: Threat escalated to Stage [stage]. Current threat: [threat_counter]/[stage_3_threshold]")

    // TODO:
    // - Change lighting using area.set_base_lighting()
    // - Send global signal for survivor HUD update
    // - Spawn new AI/Player xenos up to the new cap
    // - Unlock higher-tier xeno castes

// The temporary win condition for testing
/datum/game_mode/exodus/check_finished()
    if(world.time > SSticker.round_start_time + round_end_timer) {
        round_finished = "Time Limit Reached"
        return TRUE
    }
    // TODO: Add real win/loss conditions here
    return ..()

/datum/game_mode/exodus/set_valid_job_types()
    valid_job_types = list(/datum/job/survivor = -1)
    return TRUE

/datum/game_mode/exodus/proc/handle_survivor_death(datum/source, mob/living/victim, mob/attacker)
    SIGNAL_HANDLER
    if(!ishuman(victim) || victim.job.faction != FACTION_SURVIVOR) return

    survivors_killed++

    if(ishuman(attacker) && attacker.job.faction == FACTION_SURVIVOR) {
        var/round_duration_so_far = world.time - SSticker.round_start_time
        var/scaling_factor = min(round_duration_so_far / pvp_threat_ramp_up_duration, 1.0)
        var/scaled_pvp_threat = lerp(threat_per_death, threat_per_pvp_kill, scaling_factor)
        threat_counter += scaled_pvp_threat
        message_admins("Exodus PvP Kill: [key_name(attacker)] killed [key_name(victim)]. Threat Added: [round(scaled_pvp_threat)].")
        if(scaling_factor > 0.5) {
            priority_announce("The sounds of infighting echo across the sector, drawing the hive's attention...", "Sudden Aggression Detected")
        }
    } else {
        threat_counter += threat_per_death
    }

/datum/game_mode/exodus/proc/handle_survivor_escape(mob/living/carbon/human/survivor)
    if(!ishuman(survivor) || survivor.job.faction != FACTION_SURVIVOR) return

    survivors_escaped++
    threat_counter += threat_per_escape

#undef STAGE_THRESHOLD_LOW
#undef STAGE_THRESHOLD_MEDIUM
#undef STAGE_THRESHOLD_HIGH
