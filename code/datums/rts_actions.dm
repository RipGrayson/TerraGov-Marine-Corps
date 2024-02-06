/datum/ai_action
	///name of the unit in question
	var/name = "Placeholder Action"
	///how long it takes to build
	var/activation_delay = null
	///how many resource points it costs
	var/cost = 15
	///required building flags before a unit can be spawned
	var/list/required_action_building_flags = list()
	///icon we use to display when constructing
	var/action_buildable_icon_state = null

/datum/ai_action/proc/preactivation(obj/structure/A, turf/selectedturf)

/datum/ai_action/proc/activation(obj/structure/A, turf/selectedturf)

/datum/ai_action/structurebased/repair
	name = "Repair"
	activation_delay = 1 SECONDS
	cost = 15
	var/how_many_reps_to_fix
	required_action_building_flags = list(
		/obj/structure/rts_building/construct/engineering,
	)

/datum/ai_action/structurebased/repair/preactivation(obj/structure/A, turf/selectedturf)
	if(A.obj_integrity >= A.max_integrity)
		return
	if(HAS_TRAIT(A, BUILDING_BEING_REPAIRED)) //no stacking multiple repairs
		return
	if(!istype(A, /obj/structure/rts_building))
		return
	else
		var/obj/structure/rts_building/repairedbuilding = A
		var/integrity_difference = (repairedbuilding.max_integrity -= repairedbuilding.obj_integrity)
		var/newcost = integrity_difference / 2
		how_many_reps_to_fix = newcost / 15
		if(!check_for_resource_cost(newcost))
			return
		SSrtspoints.ai_points -= newcost
		activation(A)

/datum/ai_action/structurebased/repair/activation(obj/structure/A, turf/selectedturf)
	if(how_many_reps_to_fix == 0)
		if(HAS_TRAIT(A, BUILDING_BEING_REPAIRED))
			REMOVE_TRAIT(A, BUILDING_BEING_REPAIRED, BUILDING_BEING_REPAIRED)
		return
	A.obj_integrity += 15
	--how_many_reps_to_fix
	if(!HAS_TRAIT(A, BUILDING_BEING_REPAIRED))
		ADD_TRAIT(A, BUILDING_BEING_REPAIRED, BUILDING_BEING_REPAIRED)
	addtimer(CALLBACK(src, PROC_REF(activation)), 5 SECONDS)
