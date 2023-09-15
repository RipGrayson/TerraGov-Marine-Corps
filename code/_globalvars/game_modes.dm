GLOBAL_VAR_INIT(master_mode, "Nuclear War")

/proc/init_rts_types() //initializes, creates and populates a global list of rts buildings
	var/list/buildings = list()
	for (var/_building_path in typesof(/obj/structure/rts_building/precursor))
		var/obj/structure/rts_building/structure/building_path = _building_path
		buildings[initial(building_path.name)] = building_path
	return buildings

///all possible constructable buildings
GLOBAL_LIST_INIT_TYPED(rts_buildings, /obj/structure/rts_building, init_rts_types())
