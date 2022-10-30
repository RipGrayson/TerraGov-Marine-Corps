/obj/item/tool/pickaxe/alien_baton
	name = "plasma cutter"
	icon_state = "plasma_cutter_off"
	item_state = "alien_baton"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 70.0
	damtype = BURN
	digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction
	desc = "A tool that cuts with deadly hot plasma. You could use it to cut limbs off of xenos! Or, you know, cut apart walls or mine through stone. Eye protection strongly recommended."
	drill_verb = "cutting"
	attack_verb = list("dissolves", "disintegrates", "liquefies", "subliminates", "vaporizes")
	heat = 3800
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_PURPLE
	var/cutting_sound = 'sound/items/welder2.ogg'
	var/powered = FALSE
	var/dirt_amt_per_dig = 5
	tool_behaviour = TOOL_WELD_CUTTER

/obj/item/tool/pickaxe/alien_baton/attack_self(mob/user)
	toggle(user)
	user.changeNext_move(CLICK_CD_LONG)


//Toggles the cutter off and on
/obj/item/tool/pickaxe/alien_baton/proc/toggle(mob/user, silent)
	if(powered)
		playsound(loc, 'sound/weapons/saberoff.ogg', 15)
		powered = FALSE
		return

	playsound(loc, 'sound/weapons/saberon.ogg', 15)
	powered = TRUE

/obj/item/tool/pickaxe/alien_baton/attack(mob/living/M, mob/living/user)
	playsound(M, cutting_sound, 25, 1)
	eyecheck(user)
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, M)
	spark_system.attach(M)
	spark_system.start(M)
	if(isxeno(M) && M.stat != DEAD)
		var/mob/living/carbon/xenomorph/xeno = M
		if(!CHECK_BITFIELD(xeno.xeno_caste.caste_flags, CASTE_PLASMADRAIN_IMMUNE))
			xeno.use_plasma(round(xeno.xeno_caste.plasma_regen_limit * xeno.xeno_caste.plasma_max * 0.2)) //One fifth of the xeno's regeneratable plasma per hit.
	return ..()


/obj/item/tool/pickaxe/alien_baton/afterattack(atom/target, mob/user, proximity)
	if(!proximity || user.do_actions)
		return

	if(isturf(target))//Melting snow with the plasma cutter.
		var/turf/T = target
		var/turfdirt = T.get_dirt_type()
		if(!turfdirt == DIRT_TYPE_SNOW)
			return
		if(!istype(T, /turf/open/floor/plating/ground/snow))
			return
		var/turf/open/floor/plating/ground/snow/ST = T
		if(!ST.slayer)
			return
		playsound(user.loc, 'sound/items/welder.ogg', 25, 1)
		if(!turfdirt == DIRT_TYPE_SNOW)
			return
		if(!ST.slayer)
			return
		ST.slayer = max(0 , ST.slayer - dirt_amt_per_dig)
		ST.update_icon(1,0)



/obj/item/tool/pickaxe/alien_baton/attack_obj(obj/O, mob/living/user)
	if(!powered || user.do_actions || CHECK_BITFIELD(O.resistance_flags, INDESTRUCTIBLE) || CHECK_BITFIELD(O.resistance_flags, ALIENBATON_IMMUNE))
		..()
		return TRUE

	qdel(O)
	return TRUE

/obj/item/tool/pickaxe/alien_baton/attack_turf(turf/T, mob/living/user)
	. = ..()
	if(!T.density) //no floor modifications for now
		return
	if(!istype(T, /turf/closed/mineral/smooth/alien))
		return
	get_step(T, NORTH).ChangeTurf(/turf/open/floor/plating/ground/alienone) //this is horrible, yell at me if I forget to change it to something more reasonable in final PR
	get_step(T, SOUTH).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, WEST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, EAST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, SOUTHEAST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, SOUTHWEST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, NORTHWEST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	get_step(T, NORTHEAST).ChangeTurf(/turf/open/floor/plating/ground/alienone)
	T.ChangeTurf(/turf/open/floor/plating/ground/alienone)
