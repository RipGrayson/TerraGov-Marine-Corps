/mob/living/basic/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/basic/pet/dog
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak_emote = list("barks", "woofs")
	faction = list(FACTION_NEUTRAL)
	see_in_dark = 5
	ai_controller = /datum/ai_controller/basic_controller/dog
	// The dog attack pet command can raise melee attack above 0
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

/mob/living/basic/pet/dog/proc/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("YAP", "Woof!", "Bark!", "AUUUUUU"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/proc/tamed(mob/living/tamer)
	visible_message(span_notice("[src] licks at [tamer] in a friendly manner!"))

//Corgis and pugs are now under one dog subtype

/mob/living/basic/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "They're a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	ai_controller = /datum/ai_controller/basic_controller/dog/corgi
	var/shaved = FALSE
	var/nofur = FALSE //Corgis that have risen past the material plane of existence.
	/// Is this corgi physically slow due to age, etc?
	var/is_slow = FALSE

/mob/living/basic/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "They're a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"

/mob/living/basic/pet/dog/pug/mcgriff
	name = "McGriff"
	desc = "This dog can tell something smells around here, and that something is CRIME!"

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "They're a bull terrier."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"

/mob/living/basic/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as they are colorful!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	nofur = TRUE

/mob/living/basic/pet/dog/corgi/exoticcorgi/Initialize(mapload)
		. = ..()
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/basic/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

//IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/ian
	name = "Ian"
	real_name = "Ian" //Intended to hold the name without altering it.
	gender = MALE
	desc = "He's the Captain's beloved corgi."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

/mob/living/basic/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list(FACTION_NEUTRAL, "cult")

/mob/living/basic/pet/dog/corgi/narsie/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR"))
	speech.emote_hear = string_list(list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable."))
	speech.emote_see = string_list(list("communes with the unnameable.", "ponders devouring some souls.", "shakes."))

/mob/living/basic/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "They're a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	mob_size = MOB_SIZE_SMALL

//PUPPY IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/puppy/ian
	name = "Ian"
	real_name = "Ian"
	gender = MALE
	desc = "He's the Captain's beloved corgi puppy."

/mob/living/basic/pet/dog/corgi/puppy/void //Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	gender = NEUTER
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE

//LISA! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	var/puppies = 0

/mob/living/basic/pet/dog/breaddog
	name = "Kobun"
	desc = "It is a dog made out of bread. 'The universe is definitely half full'."
	icon_state = "breaddog"
	icon_living = "breaddog"
	icon_dead = "breaddog_dead"
	health = 50
	maxHealth = 50
	gender = NEUTER
	damage_coeff = list(BRUTE = 3, BURN = 3, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'

