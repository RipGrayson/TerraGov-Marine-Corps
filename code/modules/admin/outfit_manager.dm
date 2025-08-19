/client/proc/outfit_manager()
	set category = "Debug"
	set name = "Outfit Manager"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)


/datum/outfit_manager
	var/client/owner

/datum/outfit_manager/New(user)
	owner = CLIENT_FROM_VAR(user)

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_close(mob/user)
	qdel(src)

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitManager")
		ui.open()

/datum/outfit_manager/proc/entry(datum/outfit/outfit)
	var/vv = FALSE
	var/datum/outfit/varedit/varoutfit = outfit
	if(istype(varoutfit))
		vv = length(varoutfit.vv_values)
	return list(
		"name" = "[outfit.name] [vv ? "(VV)" : ""]",
		"ref" = REF(outfit),
	)

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/outfits = list()
	for(var/datum/outfit/custom_outfit in GLOB.custom_outfits)
		outfits += list(entry(custom_outfit))
	data["outfits"] = outfits

	return data

/datum/outfit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("new")
			owner.open_outfit_editor(new /datum/outfit)
		if("load")
			owner.holder.load_outfit(owner.mob)
		if("copy")
			var/datum/outfit/outfit = tgui_input_list(owner, "Pick an outfit to copy from", "Outfit Manager", subtypesof(/datum/outfit))
			if(isnull(outfit))
				return
			if(!ispath(outfit))
				return
			owner.open_outfit_editor(new outfit)

	var/datum/outfit/target_outfit = locate(params["outfit"])
	if(!istype(target_outfit))
		return
	switch(action) //wow we're switching through action again this is horrible optimization smh
		if("edit")
			owner.open_outfit_editor(target_outfit)
		if("save")
			owner.holder.save_outfit(owner.mob, target_outfit)
		if("delete")
			owner.holder.delete_outfit(owner.mob, target_outfit)


ADMIN_VERB(dummy_survivors, R_DEBUG, "Spawn Dummy Survivors", "Toggles local debug of the stat panel", ADMIN_CATEGORY_DEBUG)

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
		dummy_mind.transfer_to(new_dummy)

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

ADMIN_VERB(recalculate_threat, R_DEBUG, "Recalculate Threat", "Toggles local debug of the stat panel", ADMIN_CATEGORY_DEBUG)

	if(!check_rights(R_SERVER)) return

	if(!istype(SSticker.mode, /datum/game_mode/exodus)) {
		to_chat(src, "<span class='warning'>This is not an Exodus round.</span>")
		return
	}

	var/datum/game_mode/exodus/exodus_mode = SSticker.mode
	exodus_mode.recalculate_threat_values()


ADMIN_VERB(change_threat, R_DEBUG, "Change threat stage", "Changes threat stage", ADMIN_CATEGORY_DEBUG)

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

	exodus_mode.escalate_to_stage(choice)

