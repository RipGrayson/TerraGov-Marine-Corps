/obj/structure/rts_building
	name = "buildingplaceholder"
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
	coverage = 95
	bound_height = 64
	bound_width = 64
	///what building flags this building has
	var/has_building_flags = null
	//holder for unit datums
	var/datum/rts_units/unit_type
	///icon for activation, so we can show off fancy working graphics
	var/activation_icon = "holder2"
	///list of all units that can be built, remember that selectable units require certain buildings before they show up, this is just all the units that can theoretically be built
	var/list/buildable_units = list(
		/datum/rts_units/beetle,
		/datum/rts_units/mantis,
	)
	var/list/buildable_structures = list(
		/obj/structure/rts_building/precursor,
		/obj/structure/rts_building/precursor/engineering,
	)
	///holds the icon_state for the hud
	var/buildable_icon_state = "hq"
	///what flags we require to exist before we allow this building to be constructed
	var/required_buildings_flags_for_construction = AI_NONE
	///what AI created this building
	var/mob/living/silicon/ai/malf/constructingai
	///units to be built, yes I'm actually working on a sensible implementation
	var/list/queuedunits = list()
	///holds our position in a theoretical list of buildings
	var/buildingorder = 0

/obj/structure/rts_building/structure/headquarters
	name = "AI headquarters"
	desc = "AI headquarters, the brain of any operation"
	has_building_flags = AI_HEADQUARTERS

/obj/structure/rts_building/structure/engineering
	name = "AI engineering"
	buildable_icon_state = "engi"
	has_building_flags = AI_ENGINEERING
	required_buildings_flags_for_construction = AI_HEADQUARTERS

///ghost of the building we're constructing
/obj/structure/rts_building/precursor
	name = "AI headquarters"
	desc = "A building under construction"
	max_integrity = 100
	alpha = 100
	pointvalue = 0
	density = FALSE
	///what building we'll deploy after buildtime is done
	var/buildtype = /obj/structure/rts_building
	///how long it takes until we deploy the real building
	var/buildtime = 10 SECONDS
	unit_type = null

/obj/structure/rts_building/precursor/headquarters
	name = "AI headquarters"
	buildtype = /obj/structure/rts_building/structure/headquarters

/obj/structure/rts_building/precursor/engineering
	name = "AI engineering"
	buildtype = /obj/structure/rts_building/structure/engineering
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
	if(locate(/obj/structure/rts_building/structure/engineering) in GLOB.constructed_rts_builds)
		to_chat(constructingai, "test")
	var/obj/structure/rts_building/structure/newbuilding = new constructedbuilding(get_turf(src))
	newbuilding.constructingai = src.constructingai
	qdel(src)

///handles cost, prereq checking and build queuing before creating a unit
//this is being deprecated after UI rework
/obj/structure/rts_building/structure/proc/queueunit(mob/living/silicon/ai/malf/user)
	if(HAS_TRAIT(src, BUILDING_BUSY))
		to_chat(user, "This building is already producing [unit_type.name]")
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
/obj/structure/rts_building/structure/proc/createunit(mob/living/generatedunit = /mob/living/carbon/xenomorph/mantis/ai, mob/living/silicon/ai/malf/user)
	new generatedunit(get_step(src, SOUTH))
	icon_state = base_icon_state
	if(HAS_TRAIT(src, BUILDING_BUSY))
		REMOVE_TRAIT(src, BUILDING_BUSY, BUILDING_BUSY)

/obj/structure/rts_building/structure/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125))//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75))

/obj/structure/rts_building/structure/attackby(obj/item/I, mob/user, params)
	. = ..()
	rts_set_building_health()

/obj/structure/rts_building/structure/Initialize(mapload, start_dir)
	. = ..()
	//rts_set_building_health()
	unit_type = new
	GLOB.constructed_rts_builds += src

/obj/structure/rts_building/structure/Destroy()
	density = FALSE
	GLOB.constructed_rts_builds -= src
	QDEL_NULL(unit_type)
	return ..()

/obj/structure/rts_building/structure/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, "fire")
	return ..()

