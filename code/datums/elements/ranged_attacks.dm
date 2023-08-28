///This proc is used by basic mobs to give them a simple ranged attack! In theory this could be extended to
/datum/element/ranged_attacks
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	var/projectilesound = 'sound/weapons/guns/fire/gunshot.ogg'
	var/projectiletype

/datum/element/ranged_attacks/Attach(atom/movable/target, casingtype, projectilesound, projectiletype)
	. = ..()
	if(!isbasicmob(target))
		return COMPONENT_INCOMPATIBLE

	src.projectilesound = projectilesound
	src.projectiletype = projectiletype

	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, .proc/fire_ranged_attack)

	if(casingtype && projectiletype)
		CRASH("Set both casing type and projectile type in [target]'s ranged attacks element! uhoh! stinky!")

/datum/element/ranged_attacks/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOB_ATTACK_RANGED)
	return ..()

/datum/element/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/async_fire_ranged_attack, firer, target, modifiers)


/datum/element/ranged_attacks/proc/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers, spawn_casing, ammotype)
	var/turf/startloc = get_turf(firer)
	ammotype = /datum/ammo/bullet/pistol

	if(ammotype)
		new /obj/item/ammo_casing(startloc)
		var/obj/projectile/P = new(startloc)
		playsound(firer, projectilesound, 100, TRUE)
		P.generate_bullet(GLOB.ammo_list[ammotype])
		P.forceMove(get_turf(P))
		P.fire_at(target, firer)
