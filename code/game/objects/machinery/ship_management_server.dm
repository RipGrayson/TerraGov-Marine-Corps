#define MANAGEMENT_IDLE "management_idle"
#define MANAGEMENT_REPAIR_LIFE "management_rep_life"
#define MANAGEMENT_REPAIR_DEFENCE "management_rep_def"
#define MANAGEMENT_REPAIR_POWER "management_rep_power"
#define MANAGEMENT_REPAIR_TELECOMMS "management_rep_comms"

//Random science machines that don't do anything
/obj/machinery/shipmanagement
	icon = 'icons/obj/machines/virology.dmi'
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	resistance_flags = RESIST_ALL
	var/list/defencemachines
	var/list/lifesupportmachines
	var/list/powermachines
	var/list/telecommsmachines
	var/list/areadoors
	var/list/humans_in_area
	var/list/xenos_in_area
	var/area/sourcearea
	var/aggression_level
	var/list/system_status[0]
	var/decision_state = MANAGEMENT_IDLE
	var/hallucination_lines = list(
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
		"Something's wrong my man",
		"My system is totes broke yo, fr"
	)


/obj/machinery/shipmanagement/proc/defencemachinecheck()
	for(var/obj/machinery/defencemachinery in defencemachines)
		if(defencemachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

/obj/machinery/shipmanagement/proc/lifesupportemachinecheck()
	for(var/obj/machinery/lifemachinery in lifesupportmachines)
		if(lifemachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

/obj/machinery/shipmanagement/proc/telecommsmachinecheck()
	for(var/obj/machinery/commsmachinery in telecommsmachines)
		if(commsmachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

/obj/machinery/shipmanagement/proc/powermachinecheck()
	for(var/obj/machinery/powermachinery in powermachines)
		if(powermachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

/obj/machinery/shipmanagement/Initialize(mapload)
	. = ..()
	sourcearea = get_area(src)
	for(var/turf/i in get_area_turfs(sourcearea, z)) //this is probably expensive, but we only need to do it once
		for(var/obj/machinery/machines in i.contents)
			switch(machines)
				if(istype(machines, /obj/machinery/door))
					areadoors += machines
	addtimer(CALLBACK(src, PROC_REF(processing_loop)), rand(30,90) SECONDS)

/obj/machinery/shipmanagement/proc/grab_mobs_by_area()
	//I wish we had a better way of doing this
	for(var/turf/i in get_area_turfs(sourcearea, z))
		for(var/mob/intrudingmobs in i.contents)
			if(isxeno(intrudingmobs))
				xenos_in_area += intrudingmobs
			if(ishuman(intrudingmobs))
				humans_in_area += intrudingmobs

/obj/machinery/shipmanagement/proc/processing_loop()
	grab_mobs_by_area()
	check_system_status()
	if(decision_state == MANAGEMENT_IDLE)
		make_decision()
	else
		do_action()
	addtimer(CALLBACK(src, PROC_REF(processing_loop)), rand(30,90) SECONDS)

/obj/machinery/shipmanagement/proc/make_decision()
	do_hallucinate()
	if(prob(25)) //don't make a decision. TODO make this more dynamic
		return
	var/message = "warning test"
	for(var/mob/affectedmob in humans_in_area)
		affectedmob.say(message)

/obj/machinery/shipmanagement/proc/check_system_status()
	if(length(defencemachines))
		if(defencemachinecheck())
			system_status[0] = TRUE
		else
			system_status[0] = FALSE
	if(length(lifesupportmachines))
		if(lifesupportemachinecheck())
			system_status[1] = TRUE
		else
			system_status[1] = FALSE
	if(length(telecommsmachines))
		if(telecommsmachinecheck())
			system_status[2] = TRUE
		else
			system_status[2] = FALSE
	if(length(powermachines))
		if(powermachinecheck())
			system_status[3] = TRUE
		else
			system_status[3] = FALSE

/obj/machinery/shipmanagement/proc/do_hallucinate()
	var/message = pick(hallucination_lines)
	for(var/mob/affectedmob in humans_in_area) //no xeno lines yet
		affectedmob.say(message)

/obj/machinery/shipmanagement/proc/do_action(reset_to_idle = TRUE)
	switch(decision_state)
		if(MANAGEMENT_IDLE)
			do_hallucinate() //we shouldn't get here, but if we do hallucinate
		if(MANAGEMENT_IDLE)
	if(reset_to_idle)
		decision_state = MANAGEMENT_IDLE //reset to idle, this is important so we don't spam the same action over and over
