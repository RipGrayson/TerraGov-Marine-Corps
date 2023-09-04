/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/
/mob/living/silicon/ai/malf/CtrlShiftClickOn(atom/A)
	A.MalfCtrlShiftClick(src)

/mob/living/silicon/ai/malf/ShiftClickOn(atom/A)
	A.MalfShiftClick(src)
	return TRUE

/mob/living/silicon/ai/malf/CtrlClickOn(atom/A)
	A.MalfCtrlClick(src)

/mob/living/silicon/ai/malf/MiddleClickOn(atom/A)
	A.MalfMiddleClick(src)

/mob/living/silicon/ai/malf/AIRightClick(atom/A)
	A.MalfRightClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/


/* Atom Procs */
/atom/proc/MalfCtrlClick()
	return

/atom/proc/MalfShiftClick()
	return

/atom/proc/MalfCtrlShiftClick()
	return

/atom/proc/MalfMiddleClick()
	return

/atom/proc/MalfRightClick()
	return

/* Airlocks */
/obj/machinery/door/airlock/MalfCtrlClick(mob/living/silicon/ai/user) // Bolts doors
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	if(emergency)
		to_chat(user, span_notice("You can't lock a door that's on emergency access."))
		return
	if(locked)
		bolt_raise(user)
	else if(hasPower())
		bolt_drop(user)

/obj/machinery/door/airlock/MalfShiftClick(mob/living/silicon/ai/user)  // Opens and closes doors!
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	user_toggle_open(user)

/obj/machinery/door/airlock/MalfCtrlShiftClick(mob/living/silicon/ai/user)
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	if(locked || !hasPower())
		to_chat(user, span_notice("Emergency access mechanism inaccessible."))
		return
	if(emergency)
		to_chat(user, span_notice("[src] emergency access has been disabled."))
		emergency_off(user)
	else
		to_chat(user, span_notice("[src] emergency access has been enabled."))
		emergency_on(user)

/obj/machinery/door/airlock/dropship_hatch/MalfCtrlClick(mob/living/silicon/ai/user)
	return

/obj/machinery/door/airlock/hatch/cockpit/MalfCtrlClick(mob/living/silicon/ai/user)
	return

/* APC */
/obj/machinery/power/apc/MalfCtrlClick(mob/living/silicon/ai/user) // turns off/on APCs.
	return

/* Firealarm */
/obj/machinery/firealarm/MalfCtrlClick(mob/living/silicon/ai/user) // toggle the fire alarm
	var/area/A = get_area(src)
	if(A.flags_alarm_state & ALARM_WARNING_FIRE)
		reset()
	else
		alarm()

//
// Override TurfAdjacent for AltClicking
//
/mob/living/silicon/ai/malf/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))

/turf/MalfShiftClick(mob/living/silicon/ai/user)
	return

/turf/MalfCtrlClick(mob/living/silicon/ai/malf/user)
	var/turf/checkedturf
	//if(is_mainship_level(user.eyeobj.z)) //no building bases shipside
		//return
	for(var/dirn in GLOB.alldirs)
		checkedturf = get_step(src, dirn)
		if(checkedturf.density)
			to_chat(user, "You can't, the building would clip into dense turf")
			return
		if(isspaceturf(checkedturf) || islava(checkedturf) || iswater(checkedturf))
			to_chat(user, span_warning("Unsuitable terrain for building"))
			return
		for(var/atom/A in checkedturf)
			if(isliving(A))
				continue
			if(A.density || istype(A, /obj/structure/rts_building/precursor))
				to_chat(user, "Another object here is dense")
				return
	to_chat(user, "You begin the construction of [initial(user.held_building.name)].")
	var/obj/structure/rts_building/precursor/newbuilding = new user.held_building(src)
	newbuilding.constructingai = user
	user.last_touched_building = newbuilding.buildtype

/obj/structure/rts_building/precursor/MalfCtrlClick(mob/living/silicon/ai/malf/user)
	user.last_touched_building = src
	to_chat(user, "You cancel the construction of this [name] for [pointcost] resources.")
	SSrtspoints.ai_points += pointcost
	qdel(src)

/obj/structure/rts_building/MalfCtrlClick(mob/living/silicon/ai/malf/user)
	user.last_touched_building = src
	queueunit(user)
	//do hud action

/obj/structure/rts_building/MalfMiddleClick(mob/living/silicon/ai/malf/user)
	user.last_touched_building = src
	user.show_unit_build_options(src)

