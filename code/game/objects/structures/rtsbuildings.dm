/obj/structure/rts_building
	name = "AI headquarters"
	desc = "A featureless block meant for testing core mechanics, how did you even see this?"
	icon = 'icons/obj/structures/rtsstructures.dmi'
	base_icon_state = "holder1"
	icon_state = "holder1"
	density = TRUE
	anchored = TRUE //We can not be moved.
	coverage = 5
	layer = WINDOW_LAYER
	max_integrity = 1000
	resistance_flags = XENO_DAMAGEABLE
	minimap_color = MINIMAP_FENCE
	///how much value this structure generates just by existing
	var/pointvalue = 10
	///how much this structure costs to create
	var/pointcost = 1000
	var/sci_on_completion = 1000
	coverage = 95
	bound_height = 64
	bound_width = 64
	var/has_building_flags = AI_HEADQUARTERS
	//We dont have armor do to being a bit more healthy!
	var/datum/rts_units/unit_type
	var/activation_icon = "holder2"
	var/list/buildable_units = list(
		/datum/rts_units/beetle,
		/datum/rts_units/mantis,
	)
	var/required_buildings_flags_for_construction = AI_NONE

/obj/structure/rts_building/engineering
	name = "AI engineering"
	has_building_flags = AI_ENGINEERING
	required_buildings_flags_for_construction = AI_HEADQUARTERS

/obj/structure/rts_building/precursor
	name = "AI headquarters"
	max_integrity = 100
	alpha = 100
	pointvalue = 0
	density = FALSE
	var/buildtype = /obj/structure/rts_building
	var/buildtime = 10 SECONDS
	unit_type = null

/obj/structure/rts_building/precursor/engineering
	name = "AI engineering"
	buildtype = /obj/structure/rts_building/engineering
	buildtime = 20 SECONDS
	pointcost = 500
	required_buildings_flags_for_construction = AI_HEADQUARTERS

///on init check for resources and if we meet the reqs add a construction timer
/obj/structure/rts_building/precursor/Initialize()
	. = ..()
	var/pointswehave = SSrtspoints.ai_points
	if((pointswehave -= pointcost) <= 0)
		qdel(src)
		return
	SSrtspoints.ai_points -= pointcost
	addtimer(CALLBACK(src, PROC_REF(createbuilding), buildtype), buildtime)

///generates the building
/obj/structure/rts_building/precursor/proc/createbuilding(obj/structure/rts_building/constructedbuilding = /obj/structure/rts_building)
	new constructedbuilding(get_turf(src))
	qdel(src)

///handles cost, prereq checking and build queuing before creating a unit
/obj/structure/rts_building/proc/queueunit(mob/living/silicon/ai/malf/user)
	if(HAS_TRAIT(src, BUILDING_BUSY))
		to_chat(user, "This building is already producing something")
		return
	icon_state = activation_icon
	to_chat(user, "You start production on a [unit_type.name]")
	var/pointswehave = SSrtspoints.ai_points
	if((pointswehave -= unit_type.cost) <= 0)
		return
	///AT THIS POINT DOES NOT ACTUALLY DO QUEUEING AAAAAH
	SSrtspoints.ai_points -= unit_type.cost
	ADD_TRAIT(src, BUILDING_BUSY, BUILDING_BUSY) //passed all checks, assign busy status
	addtimer(CALLBACK(src, PROC_REF(createunit), unit_type.spawntype), unit_type.buildtime)
	///TODO at some point this needs a refactor to handle multiple units in a queue, current implementation can't do it

///actually generates the unit
/obj/structure/rts_building/proc/createunit(mob/living/generatedunit = /mob/living/carbon/xenomorph/mantis/ai, mob/living/silicon/ai/malf/user)
	new generatedunit(get_step(src, SOUTH))
	icon_state = base_icon_state
	if(HAS_TRAIT(src, BUILDING_BUSY))
		REMOVE_TRAIT(src, BUILDING_BUSY, BUILDING_BUSY)

/obj/structure/rts_building/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125))//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75))

/obj/structure/rts_building/attackby(obj/item/I, mob/user, params)
	. = ..()

/obj/structure/rts_building/Initialize(mapload, start_dir)
	. = ..()
	unit_type = new
	GLOB.ai_rts_buildings += src

/obj/structure/rts_building/Destroy()
	density = FALSE
	GLOB.ai_rts_buildings -= src
	QDEL_NULL(unit_type)
	return ..()

/obj/structure/rts_building/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, "fire")
	return ..()

/obj/structure/rts_building/proc/validate_build_reqs(incomingbitflag)
	if(CHECK_BITFIELD(src, incomingbitflag))
		return TRUE
	return FALSE
