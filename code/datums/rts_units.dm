/datum/rts_units
	///name of the unit in question
	var/name = "Placeholder Unit"
	///how long it takes to build
	var/buildtime = 10 SECONDS
	///how many resource points it costs
	var/cost = 15
	///what mob is getting spawned from this
	var/spawntype = /mob/living/carbon/xenomorph/mantis/ai
	///required building flags before a unit can be spawned
	var/list/required_unit_building_flags = list()
	///icon we use to display when constructing
	var/display_icon = null
	///holds the icon_state for the hud
	var/unit_buildable_icon_state = null

/datum/rts_units/mantis
	name = "Mantis Unit"
	buildtime = 15 SECONDS
	cost = 15
	unit_buildable_icon_state = "mantis"

/datum/rts_units/beetle
	name = "Beetle Unit"
	buildtime = 15 SECONDS
	cost = 30
	spawntype = /mob/living/carbon/xenomorph/beetle/ai
	required_unit_building_flags = list(
		/obj/structure/rts_building/construct/engineering,
	)
	unit_buildable_icon_state = "beetle"

#define MOVEMENT_STATE_IDLE "movement_idle"
#define MOVEMENT_STATE_MOVING "movement_moving"
#define MOVEMENT_STATE_CHASING "movement_chasing"

#define BEHAVIOR_STATE_GUARDING "behavior_guarding"
#define BEHAVIOR_STATE_ATTACKING "behavior_attacking"
#define BEHAVIOR_STATE_SCANNING "behavior_scanning"

/mob/living/silicon/rtsmob
	name = "placeholder rts mob"
	desc = "If you see this in game, ping a maint"
	icon = 'icons/Xeno/castes/beetle.dmi'
	icon_state = "Beetle Walking"
	///what movement state are we in, walking, sitting etc
	var/movement_state = MOVEMENT_STATE_IDLE
	///what behavior state are we in, guarding, chasing etc
	var/behavior_state = BEHAVIOR_STATE_SCANNING
	///are we currently being held by AI?
	var/selected_by_ai = FALSE

/mob/living/silicon/rtsmob/attack_ai(mob/user)
	. = ..()
	if(!isbadAI(user))
		return
	var/mob/living/silicon/ai/malf/evilai = user
	if(!selected_by_ai)
		evilai.selected_units += src
		selected_by_ai = TRUE
		to_chat(user, span_notice("[src] has been added to selected units."))
