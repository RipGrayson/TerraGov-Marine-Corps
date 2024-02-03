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

/mob/living/silicon/rtsmob
