/// Slippery component, for making anything slippery. Of course.
/datum/component/repair_building
	var/how_many_reps_to_fix

/datum/component/repair_building/Initialize(obj/structure/A, turf/selectedturf)
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
		repair_building(A)

/datum/component/repair_building/proc/repair_building(obj/structure/A, turf/selectedturf)
	if(how_many_reps_to_fix == 0)
		if(HAS_TRAIT(A, BUILDING_BEING_REPAIRED))
			REMOVE_TRAIT(A, BUILDING_BEING_REPAIRED, BUILDING_BEING_REPAIRED)
		return
	A.obj_integrity += 15
	--how_many_reps_to_fix
	if(!HAS_TRAIT(A, BUILDING_BEING_REPAIRED))
		ADD_TRAIT(A, BUILDING_BEING_REPAIRED, BUILDING_BEING_REPAIRED)
	addtimer(CALLBACK(src, PROC_REF(repair_building)), 5 SECONDS)
