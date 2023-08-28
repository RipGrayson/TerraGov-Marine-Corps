/mob/living/basic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	// so that martial arts don't double dip
	if (..())
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/shove_dir = get_dir(user, src)
		if(!Move(get_step(src, shove_dir), shove_dir))
			log_combat(user, src, "shoved", "failing to move it")
			user.visible_message(span_danger("[user.name] shoves [src]!"),
				span_danger("You shove [src]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, list(src))
			to_chat(src, span_userdanger("You're shoved by [user.name]!"))
			return TRUE
		log_combat(user, src, "shoved", "pushing it")
		user.visible_message(span_danger("[user.name] shoves [src], pushing [p_them()]!"),
			span_danger("You shove [src], pushing [p_them()]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, list(src))
		to_chat(src, span_userdanger("You're pushed by [user.name]!"))
		return TRUE

	if(!user.a_intent == INTENT_HARM)
		if (stat == DEAD)
			return
		visible_message(span_notice("[user] [response_help_continuous] [src]."), \
						span_notice("[user] [response_help_continuous] you."), null, null, user)
		to_chat(user, span_notice("You [response_help_simple] [src]."))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	else
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message(span_danger("[user] [response_harm_continuous] [src]!"),\
						span_userdanger("[user] [response_harm_continuous] you!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [response_harm_simple] [src]!"))
		playsound(loc, attacked_sound, 25, TRUE, -1)

		var/damage = rand(3, 10)

		attack_threshold_check(damage)
		log_combat(user, src, "attacked")
		updatehealth()
		return TRUE

/mob/living/basic/attack_basic_mob(mob/living/basic/user, list/modifiers)
	. = ..()
	if(.)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		return attack_threshold_check(damage, user.melee_damage_type)

/mob/living/basic/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = MELEE, actuallydamage = TRUE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(actuallydamage)
		apply_damage(damage, damagetype, null)
	return TRUE

/mob/living/basic/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage_upper)
		if(attack_vis_effect && !iswallturf(A)) // override the standard visual effect.
			visual_effect_icon = attack_vis_effect
		else if(melee_damage_upper < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()


/mob/living/basic/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()
