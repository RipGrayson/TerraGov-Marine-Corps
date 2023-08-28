/datum/ai_controller/basic_controller/dog
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_dog
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/dog,
		/datum/ai_planning_subtree/dog_harassment,
	)

/**
 * Same thing but with make tiny corgis and use access cards.
 */
/datum/ai_controller/basic_controller/dog/corgi
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/pet/dog),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/dog/corgi/puppy = 95, /mob/living/basic/pet/dog/corgi/puppy/void = 5),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/dog,
		/datum/ai_planning_subtree/dog_harassment,
	)

/datum/ai_controller/basic_controller/dog/corgi/get_access()
	var/mob/living/basic/pet/dog/corgi/corgi_pawn = pawn
	if(!istype(corgi_pawn))
		return
