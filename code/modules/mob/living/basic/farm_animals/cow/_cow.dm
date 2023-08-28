//cow
/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon = 'icons/mob/animal.dmi'
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	speak_emote = list("moos","moos hauntingly")
	speed = 1.1
	see_in_dark = 6
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/cow

/mob/living/basic/cow/Initialize(mapload)
	udder_component()
	. = ..()

///wrapper for the udder component addition so you can have uniquely uddered cow subtypes
/mob/living/basic/cow/proc/udder_component()
	AddComponent(/datum/component/udder)

