

ADMIN_VERB(dummy_survivors, R_DEBUG, "Spawn Dummy Survivors", "Toggles local debug of the stat panel", ADMIN_CATEGORY_EXODUS)

	if(!check_rights(R_SPAWN)) // Or a higher admin right
		return

	var/amount = tgui_input_number(usr, "please enter the number of humans you want")

	if(amount <= 0 || amount > 50) // Sanity check the amount
		to_chat(src, "<span class='warning'>Please provide a number between 1 and 50.</span>")
		return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This verb is intended for the Exodus game mode.</span>")
	}

	var/datum/job/survivor/survivor_job = SSjob.GetJobType(/datum/job/survivor)
	if(!survivor_job) {
		to_chat(src, "<span class='warning'>Could not find the Survivor job datum.</span>")
		return
	}

	if(!GLOB.exodus_survivor_spawns || !GLOB.exodus_survivor_spawns.len) {
		to_chat(src, "<span class='warning'>Could not find any 'exodus_survivor_spawn' landmarks.</span>")
		return
	}

	message_admins("[key_name(src)] is spawning [amount] dummy survivors for testing.")
	log_admin("[key_name(src)] spawned [amount] dummy survivors.")

	for(var/i in 1 to amount) {
		var/turf/spawn_turf = pick(GLOB.exodus_survivor_spawns)
		if(!spawn_turf) continue

		// Create the dummy mob
		var/mob/living/carbon/human/new_dummy = new(get_turf(spawn_turf))

		// Give it a mind, which is essential for many game systems to recognize it as a "character"
		var/datum/mind/dummy_mind = new()
		dummy_mind.key = "dummy-[rand(1000,9999)]" // Give it a fake key

		// Assign the job and give it an outfit
		new_dummy.apply_assigned_role_to_spawn(survivor_job)

		// Set a random name
		new_dummy.fully_replace_character_name(new_dummy.real_name, GLOB.namepool[/datum/namepool].get_random_name(new_dummy.gender))

		// Ensure it's correctly accounted for
		// Most of the GLOB lists are handled by /mob/living/carbon/human/Initialize,
		// but we can manually ensure faction is set.
		// apply_assigned_role_to_spawn should handle this, but we can be explicit.
		new_dummy.faction = FACTION_SURVIVOR

		// Manually add to faction list if apply_assigned_role_to_spawn doesn't
		// (It usually does, but this is a failsafe)
		LAZYADD(GLOB.alive_human_list_faction[survivor_job.faction], new_dummy)

		CHECK_TICK // Yield processing if we are spawning a large number
	}

	to_chat(src, "<span class='notice'>Spawned [amount] dummy survivors.</span>")
	if(tgui_alert(user, "Recalculate threat values, including the new dummy survivors? (strongly recommended)", "Confirm", list("Yes", "No")) != "Yes")
		return
	message_admins("[key_name(src)] has recalculated threat values.")
	log_admin("[key_name(src)] has recalculated threat values.")
	var/datum/game_mode/exodus/exodus_mode = SSticker.mode
	exodus_mode.recalculate_threat_values()

ADMIN_VERB(recalculate_threat, R_DEBUG, "Recalculate Threat", "Recalculates threat value", ADMIN_CATEGORY_EXODUS)

	if(!check_rights(R_SERVER)) return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This is not an Exodus round.</span>")
		return
	}

	var/datum/game_mode/exodus/exodus_mode = SSticker.mode
	exodus_mode.recalculate_threat_values()


ADMIN_VERB(change_threat_level, R_DEBUG, "Change threat stage", "Changes threat stage", ADMIN_CATEGORY_EXODUS)

	if(!check_rights(R_SERVER)) return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This is not an Exodus round.</span>")
		return
	}
	var/choice = tgui_input_number(usr, "please enter the stage you want")

	if(choice < 1 || choice > 3) // Sanity check the amount
		to_chat(src, "<span class='warning'>Please provide a number between 1 and 3.</span>")
		return

	var/datum/game_mode/exodus/exodus_mode = SSticker.mode

	switch(choice)
		if(1)
			exodus_mode.threat_counter = 0
		if(2)
			exodus_mode.threat_counter = exodus_mode.stage_2_threshold
		if(3)
			exodus_mode.threat_counter = exodus_mode.stage_3_threshold

	exodus_mode.escalate_to_stage(choice, TRUE)


ADMIN_VERB(change_threat_directly, R_DEBUG, "Set threat value", "Sets threat value", ADMIN_CATEGORY_EXODUS)

	if(!check_rights(R_SERVER)) return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This is not an Exodus round.</span>")
		return
	}
	var/choice = tgui_input_number(usr, "please enter the threat value you want")
	var/datum/game_mode/exodus/exodus_mode = SSticker.mode
	exodus_mode.threat_counter = choice

ADMIN_VERB(manual_spawn_loot, R_DEBUG, "Spawn loot", "Manually triggers the spawning of loot", ADMIN_CATEGORY_EXODUS)

	if(!check_rights(R_SERVER)) return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This is not an Exodus round.</span>")
		return
	}
	var/choice = tgui_input_number(usr, "please enter the amount of theoretical players to spawn loot for")
	var/datum/game_mode/exodus/exodus_mode = SSticker.mode
	exodus_mode.distribute_loot(choice)
