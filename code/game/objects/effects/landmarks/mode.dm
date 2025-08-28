/obj/effect/landmark/lv624


/obj/effect/landmark/lv624/fog_blocker
	name = "fog blocker"
	icon_state = "fog_spawn"


/obj/effect/landmark/lv624/fog_blocker/Initialize(mapload)
	. = ..()
	store_location()
	atom_flags |= INITIALIZED
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/lv624/fog_blocker/proc/store_location()
	GLOB.fog_blocker_locations += loc

/obj/effect/landmark/lv624/fog_blocker/xeno_spawn
	name = "xeno spawn protection"

/obj/effect/landmark/lv624/fog_blocker/xeno_spawn/store_location()
	GLOB.xeno_spawn_protection_locations += loc

/obj/effect/landmark/exodus/xenospawner
	name = "exodus xeno spawner"
	icon_state = "fog_spawn"

/obj/effect/landmark/exodus/xenospawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_xeno_spawns += src

/obj/effect/landmark/exodus/toolspawner ///tools
	name = "exodus utility spawner"
	icon_state = "surv_tool"

/obj/effect/landmark/exodus/toolspawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_tool_spawns += src

/obj/effect/landmark/exodus/blueprintspawner ///blueprints
	name = "exodus blueprint spawner"
	icon_state = "surv_blueprint"

/obj/effect/landmark/exodus/blueprintspawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_blueprint_spawns += src

/obj/effect/landmark/exodus/medicalspawner ///medical supplies
	name = "exodus medical spawner"
	icon_state = "surv_med"

/obj/effect/landmark/exodus/medicalspawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_medical_spawns += src

/obj/effect/landmark/exodus/resourcespawner ///metal plasteel etc
	name = "exodus resource spawner"
	icon_state = "surv_metal"

/obj/effect/landmark/exodus/resourcespawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_resource_spawns += src

/obj/effect/landmark/exodus/aux_component_spawner ///other components
	name = "exodus special component spawner"
	icon_state = "fog_spawn"

/obj/effect/landmark/exodus/aux_component_spawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_aux_spawns += src

/obj/effect/landmark/exodus/weapon_spawner ///weapons
	name = "exodus weapon spawner"
	icon_state = "surv_gun"

/obj/effect/landmark/exodus/weapon_spawner/Initialize(mapload)
	. = ..()
	GLOB.exodus_weapon_spawns += src


