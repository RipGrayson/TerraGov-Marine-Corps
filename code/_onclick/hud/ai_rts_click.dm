/atom/movable/screen/ai_rts
	icon = 'icons/mob/screen_ai.dmi'

/atom/movable/screen/ai_rts/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/atom/movable/screen/ai_rts/aicore
	name = "AI core"
	icon_state = "ai_core"

/atom/movable/screen/ai_rts/aicore/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.view_core()

/atom/movable/screen/ai_rts/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/atom/movable/screen/ai_rts/camera_list/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.show_camera_list()

/atom/movable/screen/ai_rts/rts_stuff
	name = "rts manager"
	icon_state = "alerts"

/atom/movable/screen/ai_rts/rts_stuff/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.show_rts_build_options()

/atom/movable/screen/ai_rts/camera_track
	name = "Track With Camera"
	icon_state = "track"

/atom/movable/screen/ai_rts/construction_slot
	name = "build options generic"
	icon_state = "template_small"
	var/obj/structure/rts_building/precursor/potential_building = null
	var/datum/rts_units/potential_unit_type = null

/atom/movable/screen/ai_rts/construction_slot/Click()
	. = ..()
	var/mob/living/silicon/ai/malf/AI = usr
	if(!potential_building && !potential_unit_type)
		return //nothing has been set for this slot, return
	if(potential_building && potential_unit_type)
		CRASH("A construction slot on [AI] has both building and unit types at once!")
	if(potential_building)
		to_chat(AI, "You will now build a [potential_building]")
		AI.held_building = potential_building
	if(potential_unit_type)
		to_chat(AI, "You have started a [potential_unit_type]")
		AI.last_touched_building.queueunit(potential_unit_type)

/atom/movable/screen/ai_rts/construction_slot/build_slotone
	name = "build options one"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slottwo
	name = "build options two"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotthree
	name = "build options three"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotfour
	name = "build options four"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotfive
	name = "build options five"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotsix
	name = "build options six"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotseven
	name = "build options seven"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_sloteight
	name = "build options eight"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/construction_slot/build_slotspecial
	name = "build options special"
	icon_state = "template_small"

/atom/movable/screen/ai_rts/uparrow
	name = "scroll up"
	icon_state = "uparrow"

/atom/movable/screen/ai_rts/downarrow
	name = "scroll down"
	icon_state = "downarrow"

/atom/movable/screen/ai_rts/camera_track/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	var/target_name = tgui_input_list(AI, "Choose who you want to track", "Tracking", AI.trackable_mobs())
	AI.ai_camera_track(target_name)

/datum/hud/ai_rts/New(mob/owner, ui_style, ui_color, ui_alpha = 230)
	. = ..()
	var/atom/movable/screen/using

///inventory slots
	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotone()
	using.screen_loc = ui_ai_slot_one
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slottwo()
	using.screen_loc = ui_ai_slot_two
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotthree()
	using.screen_loc = ui_ai_slot_three
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotfour()
	using.screen_loc = ui_ai_slot_four
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotfive()
	using.screen_loc = ui_ai_slot_five
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotsix()
	using.screen_loc = ui_ai_slot_six
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotseven()
	using.screen_loc = ui_ai_slot_seven
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_sloteight()
	using.screen_loc = ui_ai_slot_eight
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/construction_slot/build_slotspecial()
	using.screen_loc = ui_ai_slot_special
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/uparrow
	using.screen_loc = ui_ai_slot_up_arrow
	static_inventory += using

	using = new /atom/movable/screen/ai_rts/downarrow
	using.screen_loc = ui_ai_slot_down_arrow
	static_inventory += using

//AI core
	//using = new /atom/movable/screen/ai_rts/aicore()
	//using.screen_loc = ui_ai_core
	//static_inventory += using

//Camera list
	//using = new /atom/movable/screen/ai_rts/camera_list()
	//using.screen_loc = ui_ai_camera_list
	//static_inventory += using

//Track
	//using = new /atom/movable/screen/ai_rts/camera_track()
	//using.screen_loc = ui_ai_track_with_camera
	//static_inventory += using

//rts stuff
	using = new /atom/movable/screen/ai_rts/rts_stuff()
	using.screen_loc = ui_ai_rts
	static_inventory += using

/atom/movable/screen/alert/ai_notify/Click()
	var/mob/living/silicon/ai/malf/recipientai = usr
	if(!istype(recipientai) || usr != owner)
		return
	if(!recipientai.client)
		return
	if(!target)
		return
	switch(action)
		if(NOTIFY_AI_ALERT)
			var/turf/T = get_turf(target)
			if(T)
				recipientai.eyeobj.setLoc(T)
