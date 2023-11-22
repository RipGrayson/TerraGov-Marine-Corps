#define MANAGEMENT_IDLE "management_idle"
#define MANAGEMENT_REPAIR_LIFE "management_rep_life"
#define MANAGEMENT_REPAIR_DEFENCE "management_rep_def"
#define MANAGEMENT_REPAIR_POWER "management_rep_power"
#define MANAGEMENT_REPAIR_TELECOMMS "management_rep_comms"
#define MANAGEMENT_ACTIVATE_TURRETS "management_turret_active"
#define MANAGEMENT_UPGRADE_TURRETS "management_turret_upgrade"
#define MANAGEMENT_TURRETS_SWAP_FACTIONS "management_turret_swap_active"
#define MANAGEMENT_ACTIVATE_TELECOMMS "management_comms_active"
#define MANAGEMENT_TELECOMMS_SEND_SIGNAL "management_send_comms_signal"
#define MANAGEMENT_BOLT_DOOR "management_bolt_door"
#define MANAGEMENT_SHOCK_DOOR "management_shock_door"
#define MANAGEMENT_FLOOD_GAS "management_deadly_neurotoxin"
#define MANAGEMENT_VENT_ROOM "management_vent_room"
#define MANAGEMENT_ACTIVATE_GENERATORS "management_gens_turn_on"

//Random science machines that don't do anything
/obj/machinery/shipmanagement
	name = "Placeholder ship AI"
	icon = 'icons/obj/machines/virology.dmi'
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	resistance_flags = RESIST_ALL
	///list of all defensive related machinery, populated on init
	var/list/defencemachines
	///list of all life support related machinery, populated on init
	var/list/lifesupportmachines
	///list of all power related machinery, populated on init
	var/list/powermachines
	///list of all comms related machinery, populated on init
	var/list/telecommsmachines
	///list of all doors in our area, populated on init
	var/list/areadoors
	///list of all humans in the area, dynamically generated in processing_loop()
	var/list/humans_in_area
	///list of all xenos in the area, dynamically generated in processing_loop()
	var/list/xenos_in_area
	///holds our area, used extensively for keeping track of machinery and mobs
	var/area/sourcearea
	///increased by broken machinery and high amounts of marines/xenos, higher levels result in more dramatic action
	var/aggression_level
	///array to hold the status of our subsystems
	var/list/system_status[0]
	///management AI state, used to dictate behaviors
	var/decision_state = MANAGEMENT_IDLE
	///AI is crazy and pulls from this list to spout off nonsense
	var/hallucination_lines = list(
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
		"Something's wrong my man",
		"My system is totes broke yo, fr"
	)
	///AI eye tracks players for dramatic effect, this keeps track of the player in question
	var/mob/tracked_player = null


///returns false if any defensive related machinery is broken or depowered
/obj/machinery/shipmanagement/proc/defencemachinecheck()
	for(var/obj/machinery/defencemachinery in defencemachines)
		if(defencemachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

///returns false if any life support related machinery is broken or depowered
/obj/machinery/shipmanagement/proc/lifesupportemachinecheck()
	for(var/obj/machinery/lifemachinery in lifesupportmachines)
		if(lifemachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

///returns false if any comms related machinery is broken or depowered
/obj/machinery/shipmanagement/proc/telecommsmachinecheck()
	for(var/obj/machinery/commsmachinery in telecommsmachines)
		if(commsmachinery.machine_stat & NOPOWER|BROKEN)
			return FALSE

///returns false if any power related machinery is broken or depowered
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

///main AI processing loop
/obj/machinery/shipmanagement/proc/processing_loop()
	grab_mobs_by_area()
	check_system_status()
	if(decision_state == MANAGEMENT_IDLE)
		make_decision() ///we don't make the decision and act on it in the same loop, this is because we want to warn marines/xenos before the ai does something
	else
		do_action() //we made our decision, take previously set state and act on it
	addtimer(CALLBACK(src, PROC_REF(processing_loop)), rand(30,90) SECONDS)

///handles AI decision making processes, sets a state and warns marines
/obj/machinery/shipmanagement/proc/make_decision()
	do_hallucinate()
	if(prob(25)) //don't make a decision. TODO make this more dynamic
		return
	var/message = "warning test"
	for(var/mob/affectedmob in humans_in_area)
		affectedmob.say(message)

///check all subsystems status and use it to populate a list
/obj/machinery/shipmanagement/proc/check_system_status()
	if(length(defencemachines)) //this proc isn't great, needs a rethink at some point
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

///for everybody inside the AIs area, broadcast flavor lines and logs about system damage
/obj/machinery/shipmanagement/proc/do_hallucinate()
	var/message = pick(hallucination_lines)
	for(var/mob/affectedmob in humans_in_area) //no xeno lines yet
		affectedmob.say(message)

///takes AI state and uses it to do an action of some kind, by default sets it back to IDLE afterwards
/obj/machinery/shipmanagement/proc/do_action(reset_to_idle = TRUE)
	switch(decision_state)
		if(MANAGEMENT_IDLE)
			do_hallucinate() //we shouldn't get here, but if we do hallucinate
		if(MANAGEMENT_IDLE)
	if(reset_to_idle)
		decision_state = MANAGEMENT_IDLE //reset to idle, this is important so we don't spam the same action over and over

/obj/machinery/shipmanagement/standard //standard AI
