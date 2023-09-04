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

/atom/movable/screen/ai_rts/announcement
	name = "Make Vox Announcement"
	icon_state = "announcement"

/atom/movable/screen/ai_rts/announcement/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.announcement()

/atom/movable/screen/ai_rts/announcement_help
	name = "Vox Announcement Help"
	icon_state = "alerts"

/atom/movable/screen/ai_rts/announcement_help/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.announcement_help()

/atom/movable/screen/ai_rts/bioscan
	name = "Issue Manual Bioscan"
	icon_state = "bioscan"

/atom/movable/screen/ai_rts/bioscan/Click()
	. = ..()
	if(.)
		return
	SSticker.mode.announce_bioscans(FALSE, GLOB.current_orbit, TRUE, FALSE, FALSE)

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


/atom/movable/screen/ai_rts/camera_track/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	var/target_name = tgui_input_list(AI, "Choose who you want to track", "Tracking", AI.trackable_mobs())
	AI.ai_camera_track(target_name)


/atom/movable/screen/ai_rts/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"


/atom/movable/screen/ai_rts/camera_light/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.toggle_camera_light()


/atom/movable/screen/ai_rts/multicam
	name = "Multicamera Mode"
	icon_state = "multicam"


/atom/movable/screen/ai_rts/multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.toggle_multicam()


/atom/movable/screen/ai_rts/add_multicam
	name = "New Camera"
	icon_state = "new_cam"


/atom/movable/screen/ai_rts/add_multicam/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/malf/AI = usr
	AI.drop_new_multicam()


/datum/hud/ai_rts/New(mob/owner, ui_style, ui_color, ui_alpha = 230)
	. = ..()
	var/atom/movable/screen/using

//AI core
	using = new /atom/movable/screen/ai_rts/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai_rts/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai_rts/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//VOX
	using = new /atom/movable/screen/ai_rts/announcement()
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//VOX Help
	using = new /atom/movable/screen/ai_rts/announcement_help()
	using.screen_loc = ui_ai_announcement_help
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai_rts/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Multicamera mode
	using = new /atom/movable/screen/ai_rts/multicam()
	using.screen_loc = ui_ai_multicam
	static_inventory += using

//Add multicamera camera
	using = new /atom/movable/screen/ai_rts/add_multicam()
	using.screen_loc = ui_ai_add_multicam
	static_inventory += using

//bioscan
	using = new /atom/movable/screen/ai_rts/bioscan()
	using.screen_loc = ui_ai_bioscan
	static_inventory += using

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
