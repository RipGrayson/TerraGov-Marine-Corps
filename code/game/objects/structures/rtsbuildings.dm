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
	var/list/has_building_flags = list()
	//holder for unit datums
	var/datum/rts_units/unit_type
	///icon for activation, so we can show off fancy working graphics
	var/activation_icon = "holder2"
	///list of all units that can a building can produce
	var/list/buildable_units = list()
	///list of all structures that our building can produce
	var/list/buildable_structures = list()
	///view range of AI from buildings
	var/camera_range = 7
	///holds the icon_state for the hud
	var/buildable_icon_state = "hq"
	///what flags we require to exist before we allow this building to be constructed
	var/list/required_buildings_flags_for_construction = list()
	///what AI created this building
	var/mob/living/silicon/ai/malf/constructingai
	///units to be built, yes I'm actually working on a sensible implementation
	var/list/queuedunits = list()
	///holds our position in a theoretical list of buildings
	var/buildingorder = 0
	///holds our position in a theoretical list of buildings
	var/is_selected = FALSE
	///is this a building an upgrade to an existing building, if so replace existing building with upgrade
	var/is_upgrade = FALSE
	hud_possible = list(HEALTH_HUD, STATUS_HUD_SIMPLE, STATUS_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, WANTED_HUD, SQUAD_HUD_TERRAGOV, SQUAD_HUD_SOM, ORDER_HUD, PAIN_HUD, XENO_DEBUFF_HUD, HEART_STATUS_HUD)

/obj/structure/rts_building/construct/Initialize(mapload)
	. = ..()
	var/obj/machinery/camera/building_camera = new /obj/machinery/camera(src)
	building_camera.network = list("marinemainship")
	building_camera.view_range = camera_range
	building_camera.internal_light = FALSE

/obj/structure/rts_building/construct/headquarters
	name = "AI headquarters"
	desc = "AI headquarters, the brain of any operation"
	has_building_flags = list(
		AI_HEADQUARTERS,
		)
	camera_range = 14
	pointvalue = 300
	buildable_icon_state = "hud_hq"
	buildable_structures = list(
		/obj/structure/rts_building/precursor/engineering,
		/obj/structure/rts_building/precursor/headquarters,
		/obj/structure/rts_building/precursor/factory,
		/obj/structure/rts_building/precursor/techcenter,
		/obj/structure/rts_building/precursor/mechfound,
	)
	buildable_units = list(
		/datum/rts_units/mantis,
		/datum/rts_units/beetle,
	)
	icon_state = "built_hq"

/obj/structure/rts_building/construct/engineering
	name = "AI engineering"
	buildable_icon_state = "hud_engi"
	has_building_flags = list(
		AI_ENGINEERING,
	)
	buildable_structures = list(
		/obj/structure/rts_building/precursor/powergenerator,
	)
	buildable_units = list(
		/datum/rts_units/beetle,
	)
	icon_state = "built_engi"

/obj/structure/rts_building/construct/powergenerator
	name = "AI power generation"
	buildable_icon_state = "hud_gen"
	icon_state = "built_gen"

/obj/structure/rts_building/construct/techcenter
	name = "AI tech center"
	buildable_icon_state = "hud_tech"
	icon_state = "built_tech"

/obj/structure/rts_building/construct/teleporter
	name = "AI teleporter"
	buildable_icon_state = "hud_tele"
	icon_state = "built_tele"

/obj/structure/rts_building/construct/satcommand
	name = "AI satellite command"
	buildable_icon_state = "hud_satcomm"
	icon_state = "built_satcomm"

/obj/structure/rts_building/construct/factory
	name = "AI factory"
	buildable_icon_state = "hud_fact"
	icon_state = "built_fact"
	buildable_structures = list(
		/obj/structure/rts_building/precursor/factory_two,
	)

/obj/structure/rts_building/construct/factory_two
	name = "AI upgraded factory"
	buildable_icon_state = "hud_fact_two"
	icon_state = "built_fact_two"

/obj/structure/rts_building/construct/mechfound
	name = "AI mech foundry"
	buildable_icon_state = "hud_bar"
	icon_state = "built_bar"

/obj/structure/rts_building/construct/engi
	name = "AI mech foundry"
	buildable_icon_state = "hud_engi"
	icon_state = "built_engi"

/obj/structure/rts_building/construct/commandpost
	name = "AI command post"
	buildable_icon_state = "hud_commpo"
	icon_state = "built_commpo"

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
	buildtype = /obj/structure/rts_building/construct/headquarters
	buildable_icon_state = "hud_hq"
	icon_state = "built_hq"

/obj/structure/rts_building/precursor/engineering
	name = "AI engineering"
	buildtype = /obj/structure/rts_building/construct/engineering
	buildtime = 20 SECONDS
	pointcost = 500
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/headquarters,
	)
	buildable_icon_state = "hud_engi"
	icon_state = "built_engi"

/obj/structure/rts_building/precursor/powergenerator
	name = "AI power generation"
	buildtype = /obj/structure/rts_building/construct/powergenerator
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/engineering,
	)
	buildable_icon_state = "hud_gen"
	icon_state = "built_gen"

/obj/structure/rts_building/precursor/techcenter
	name = "AI tech center"
	buildtype = /obj/structure/rts_building/construct/techcenter
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/headquarters,
	)
	buildable_icon_state = "hud_tech"
	icon_state = "built_tech"

/obj/structure/rts_building/precursor/teleporter
	name = "AI teleporter"
	buildtype = /obj/structure/rts_building/construct/teleporter
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/techcenter,
	)
	buildable_icon_state = "hud_tele"
	icon_state = "built_tele"

/obj/structure/rts_building/precursor/satcommand
	name = "AI satellite command"
	buildtype = /obj/structure/rts_building/construct/satcommand
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/techcenter,
	)
	buildable_icon_state = "hud_satcomm"
	icon_state = "built_satcomm"

/obj/structure/rts_building/precursor/factory
	name = "AI factory"
	buildtype = /obj/structure/rts_building/construct/factory
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/headquarters,
	)
	buildable_icon_state = "hud_fact"
	icon_state = "built_fact"

/obj/structure/rts_building/precursor/factory_two
	name = "AI factory"
	buildtype = /obj/structure/rts_building/construct/factory_two
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/factory,
	)
	buildable_icon_state = "hud_fact_two"
	icon_state = "built_fact_two"
	is_upgrade = TRUE

/obj/structure/rts_building/precursor/mechfound
	name = "AI mech foundry"
	buildtype = /obj/structure/rts_building/construct/mechfound
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/headquarters,
	)
	buildable_icon_state = "hud_bar"
	icon_state = "built_bar"

/obj/structure/rts_building/precursor/engi
	name = "AI engineering"
	buildtype = /obj/structure/rts_building/construct/engineering
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/headquarters,
	)
	buildable_icon_state = "hud_engi"
	icon_state = "built_engi"

/obj/structure/rts_building/precursor/commandpost
	name = "AI command post"
	buildtype = /obj/structure/rts_building/construct/commandpost
	buildtime = 5 SECONDS
	pointcost = 200
	required_buildings_flags_for_construction = list(
		/obj/structure/rts_building/construct/engineering,
		/obj/structure/rts_building/construct/techcenter,
	)
	buildable_icon_state = "hud_commpo"
	icon_state = "built_commpo"

///on init check for resources and if we meet the reqs add a construction timer
/obj/structure/rts_building/precursor/Initialize()
	. = ..()
	if(!check_for_resource_cost(pointcost))
		qdel(src)
		return
	SSrtspoints.ai_points -= pointcost
	addtimer(CALLBACK(src, PROC_REF(createbuilding), buildtype), buildtime)

///generates the building
/obj/structure/rts_building/precursor/proc/createbuilding(obj/structure/rts_building/constructedbuilding = /obj/structure/rts_building)
	if(locate(/obj/structure/rts_building/construct/engineering) in GLOB.constructed_rts_builds)
		to_chat(constructingai, "test")
	var/obj/structure/rts_building/construct/newbuilding = new constructedbuilding(get_turf(src))
	constructingai.last_touched_building = newbuilding
	newbuilding.constructingai = src.constructingai
	constructingai.update_build_icons() //todo in the distant future, this could be a signal
	qdel(src)

///handles cost, prereq checking and build queuing before creating a unit
//this is being deprecated after UI rework
/obj/structure/rts_building/construct/proc/queueunit(mob/living/silicon/ai/malf/user)
	if(HAS_TRAIT(src, BUILDING_BUSY))
		to_chat(user, "This building is already producing [unit_type.name]")
		return
	icon_state = activation_icon
	to_chat(user, "You start production on a [unit_type.name]")
	if(!check_for_resource_cost(unit_type.cost))
		to_chat(user, "We lack the resources to build[unit_type.name]!")
		return
	///AT THIS POINT DOES NOT ACTUALLY DO QUEUEING AAAAAH
	SSrtspoints.ai_points -= unit_type.cost
	ADD_TRAIT(src, BUILDING_BUSY, BUILDING_BUSY) //passed all checks, assign busy status
	addtimer(CALLBACK(src, PROC_REF(createunit), unit_type.spawntype), unit_type.buildtime)
	///TODO at some point this needs a refactor to handle multiple units in a queue, current implementation can't do it

///actually generates the unit
/obj/structure/rts_building/construct/proc/createunit(mob/living/generatedunit = /mob/living/carbon/xenomorph/mantis/ai, mob/living/silicon/ai/malf/user)
	new generatedunit(get_step(src, SOUTH))
	icon_state = base_icon_state
	if(HAS_TRAIT(src, BUILDING_BUSY))
		REMOVE_TRAIT(src, BUILDING_BUSY, BUILDING_BUSY)

/obj/structure/rts_building/construct/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125))//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75))

/obj/structure/rts_building/construct/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	rts_set_building_health()

/obj/structure/rts_building/construct/Initialize(mapload, start_dir)
	. = ..()
	//rts_set_building_health()
	unit_type = new
	GLOB.constructed_rts_builds += src

/obj/structure/rts_building/construct/Destroy()
	density = FALSE
	GLOB.constructed_rts_builds -= src
	QDEL_NULL(unit_type)
	if(constructingai)
		constructingai.update_build_icons() //force owning AI to reload their hud
	return ..()

/obj/structure/rts_building/construct/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, "fire")
	return ..()

///set a building to active, linking it to AI in process. Important for managing huds
/obj/structure/rts_building/construct/proc/set_active(mob/living/silicon/ai/malf/linkedai)
	if(!length(GLOB.constructed_rts_builds))
		return FALSE
	for(var/obj/structure/rts_building/buildingsdone in GLOB.constructed_rts_builds) //make sure nothing else is selected
		if(buildingsdone.is_selected)
			buildingsdone.is_selected = FALSE
	is_selected = !is_selected
	linkedai.last_touched_building = src
	return TRUE

/obj/structure/rts_building/proc/access_owning_ai(mob/living/silicon/ai/malf/AI, linktogether = FALSE)
	if(!AI)
		return
	constructingai = AI
	if(linktogether)
		AI.last_touched_building = src
	AI.update_build_icons()
