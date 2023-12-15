/obj/machinery/ship_defense_turret
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "maxim_turret"
	name = "defence turret"
	desc = "A shipside defence turret."
	bound_width = 32
	bound_height = 32
	obj_integrity = 600
	max_integrity = 1500
	layer = MOB_LAYER
	density = TRUE
	resistance_flags = RESIST_ALL
	allow_pass_flags = PASS_AIR|PASS_THROW
	///What kind of ammo it uses
	var/datum/ammo/ammo = /datum/ammo/energy/lasgun/M43/disabler
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/atom/hostile
	var/has_cover = TRUE
	///Last target of the turret
	var/atom/last_hostile
	///Potential list of targets found by scan
	var/list/atom/potential_hostiles
	///Fire rate of the target in ticks
	var/firerate = 7
	///The last time the sentry did a scan
	var/last_scan_time
	var/firing
	var/shoots_humans = TRUE
	var/shoots_xenos = TRUE
	var/is_active = FALSE
	var/is_damaged = FALSE

/obj/machinery/ship_defense_turret/Initialize(mapload, _hivenumber)
	. = ..()
	if(is_damaged)
		icon_state = "maxim_base"
	else
		icon_state = "maxim_turret"
	ammo = GLOB.ammo_list[ammo]
	potential_hostiles = list()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, PROC_REF(shoot))
	update_icon()

/obj/machinery/ship_defense_turret/proc/activate()
	if(is_active)
		return
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PORTAL_IMMUNE | XENO_DAMAGEABLE
	is_active = TRUE

/obj/machinery/ship_defense_turret/proc/deactivate()
	resistance_flags = RESIST_ALL
	is_active = FALSE
	explosion(loc, 2, 2)
	icon_state = "maxim_base"

/obj/machinery/ship_defense_turret/attack_ai(mob/living/silicon/ai/user)
	. = ..()
	activate()

/obj/machinery/ship_defense_turret/Destroy()
	var/obj/machinery/ship_defense_turret/damaged/brokenturret = new /obj/machinery/ship_defense_turret/damaged(get_turf(src))
	brokenturret.dir = dir //make sure the turret retains the direction of where we last were aimed
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/xeno_turret_death.ogg', 70)
	return ..()

/obj/machinery/ship_defense_turret/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	if(obj_integrity <= 30)
		deactivate()


/obj/machinery/ship_defense_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(750, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(150, BRUTE, BOMB)

/obj/machinery/ship_defense_turret/process()
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		if(is_active)
			scan()
		last_scan_time = world.time
	if(!length(potential_hostiles))
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/machinery/ship_defense_turret/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	damage *= max(0, multiplier)
	take_damage(damage, BRUTE, MELEE)
	playsound(src, "alien_resin_break", 25)

///Signal handler for hard del of hostile
/obj/machinery/ship_defense_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/machinery/ship_defense_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/machinery/ship_defense_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_QDELETING, PROC_REF(unset_hostile))

///Setter for last_hostile with hard del in mind
/obj/machinery/ship_defense_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/machinery/ship_defense_turret/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/list/turf/path = list()
	for (var/atom/nearby_hostile AS in potential_hostiles)
		if(isliving(nearby_hostile))
			var/mob/living/nearby_living_hostile = nearby_hostile
			if(nearby_living_hostile.stat == DEAD)
				continue
			if(nearby_living_hostile.stat == UNCONSCIOUS)
				continue
		if(HAS_TRAIT(nearby_hostile, TRAIT_TURRET_HIDDEN))
			continue
		buffer_distance = get_dist(nearby_hostile, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_hostile)
		path -= get_turf(src)
		if(!length(path)) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && !(T.allow_pass_flags & PASS_PROJECTILE))
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && !(MA.allow_pass_flags & PASS_PROJECTILE))
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && !(S.allow_pass_flags & PASS_PROJECTILE))
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_hostile

///Return TRUE if a possible target is near
/obj/machinery/ship_defense_turret/proc/scan()
	potential_hostiles.Cut()
	for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(!shoots_humans)
			break
		if(nearby_human.stat == DEAD)
			continue
		potential_hostiles += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(!shoots_xenos)
			break
		if(nearby_xeno.stat == DEAD)
			continue
		potential_hostiles += nearby_xeno
	for(var/obj/vehicle/unmanned/vehicle AS in GLOB.unmanned_vehicles)
		if(vehicle.z == z && get_dist(vehicle, src) <= range)
			potential_hostiles += vehicle
	for(var/obj/vehicle/sealed/mecha/mech AS in GLOB.mechas_list)
		if(mech.z == z && get_dist(mech, src) <= range)
			potential_hostiles += mech

///Signal handler to make the turret shoot at its target
/obj/machinery/ship_defense_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		firing = FALSE
		return
	face_atom(hostile)
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, src, null, ammo.max_range, ammo.shell_speed)
	firing = TRUE

/obj/machinery/ship_defense_turret/proc/set_shoot_only_humans()
	shoots_xenos = FALSE
	shoots_humans = TRUE

/obj/machinery/ship_defense_turret/proc/set_shoot_only_xenos()
	shoots_xenos = TRUE
	shoots_humans = FALSE

/obj/machinery/ship_defense_turret/damaged
	is_damaged = TRUE
