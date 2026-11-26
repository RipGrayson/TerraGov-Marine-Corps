/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"

/obj/vehicle/ridden/bicycle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/bicycle)

/obj/vehicle/ridden/dumpster
	name = "wheeled rubbish bin"
	desc = "It's a rubbish bin with wheels. You can see a hole beneath the center, somebody could move it while inside, if they didn't mind being immersed in garbage."
	icon_state = "mobile_dumpster"
	soft_armor = list(MELEE = 30, BULLET = 75, LASER = 30, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 120)
	key_type = /obj/item/key/grinch
	var/static/mutable_appearance/dumpstercover

/obj/vehicle/ridden/dumpster/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/dumpster)
	if(!dumpstercover)
		dumpstercover = mutable_appearance(icon, "dumpstercover", MOB_LAYER + 0.1)

/obj/vehicle/ridden/dumpster/post_buckle_mob(mob/living/M)
	add_overlay(dumpstercover)
	return ..()

/obj/vehicle/ridden/dumpster/post_buckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(dumpstercover)
	return ..()

/obj/vehicle/ridden/dumpster/welder_act(mob/user, obj/item/tool)
	return welder_repair_act(user, tool, 10, 2 SECONDS, fuel_req = 1)
