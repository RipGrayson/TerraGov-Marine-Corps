/mob/living/basic/mouse
	name = "mouse"
	desc = "This cute little guy just loves the taste of uninsulated electrical cables. Isn't he adorable?"
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"

	maxHealth = 5
	health = 5
	see_in_dark = 6
	density = FALSE

	speak_emote = list("squeaks")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"

	ai_controller = /datum/ai_controller/basic_controller/mouse

	/// Whether this rat is friendly to players
	var/tame = FALSE
	/// What color our mouse is. Brown, gray and white - leave blank for random.
	var/body_color
	/// Does this mouse contribute to the ratcap?
	var/contributes_to_ratcap = TRUE
	/// Probability that, if we successfully bite a shocked cable, that we will die to it.
	var/cable_zap_prob = 85

/mob/living/basic/mouse/Initialize(mapload, tame = FALSE)
	. = ..()

	src.tame = tame
	if(isnull(body_color))
		icon_state = pick("mouse_brown", "mouse_gray", "mouse_white")
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/// Kills the rat and changes its icon state to be splatted (bloody).
/mob/living/basic/mouse/proc/splat()
	icon_dead = "mouse_[body_color]_splat"
	adjust_health(maxHealth)

/mob/living/basic/mouse/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/reagent_containers/food/snacks/cheesewedge))
		try_consume_cheese(attack_target)
		return TRUE

/// Attempts to consume a piece of cheese, causing a few effects.
/mob/living/basic/mouse/proc/try_consume_cheese(obj/item/reagent_containers/food/snacks/cheesewedge/cheese)

	if(prob(90) || health < maxHealth)
		visible_message(
			span_notice("[src] nibbles [cheese]."),
			span_notice("You nibble [cheese][health < maxHealth ? ", restoring your health" : ""].")
		)
		adjust_health(-maxHealth)

	qdel(cheese)

/// Signal proc for [COMSIG_ATOM_ENTERED]. Sends a lil' squeak to chat when someone walks over us.
/mob/living/basic/mouse/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(ishuman(entered) && stat == CONSCIOUS)
		to_chat(entered, span_notice("[icon2html(src, entered)] Squeak!"))

/mob/living/basic/mouse/white
	body_color = "white"
	icon_state = "mouse_white"

/mob/living/basic/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/basic/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/basic/mouse/brown/tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"

/// The mouse AI controller
/datum/ai_controller/basic_controller/mouse
	blackboard = list(
		BB_BASIC_MOB_FLEEING = TRUE, // Always cowardly
		BB_CURRENT_HUNTING_TARGET = null, // cheese
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(), // Use this to find people to run away from
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Top priority is to look for and execute hunts for cheese even if someone is looking at us
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Next priority is see if anyone is looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Try to speak, because it's cute
		/datum/ai_planning_subtree/random_speech/mouse,
	)

/// Don't look for anything to run away from if you are distracted by being adjacent to cheese
/datum/ai_planning_subtree/flee_target/mouse
	flee_behaviour = /datum/ai_behavior/run_away_from_target/mouse

/datum/ai_planning_subtree/flee_target/mouse

/datum/ai_planning_subtree/flee_target/mouse/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/hunting_weakref = controller.blackboard[BB_CURRENT_HUNTING_TARGET]
	var/atom/hunted_cheese = hunting_weakref?.resolve()
	if (!isnull(hunted_cheese))
		return // We see some cheese, which is more important than our life
	return ..()

/datum/ai_planning_subtree/flee_target/mouse/select

/datum/ai_behavior/run_away_from_target/mouse
	run_distance = 3 // Mostly exists in small tunnels, don't get ahead of yourself

