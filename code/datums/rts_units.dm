/datum/rts_units
	///name of the unit in question
	var/name = "Mantis Unit"
	///how long it takes to build
	var/buildtime = 10 SECONDS
	///how many resource points it costs
	var/cost = 15
	///what mob is getting spawned from this
	var/spawntype = /mob/living/carbon/xenomorph/mantis/ai
	///required building flags before a unit can be spawned
	var/required_unit_building_flags = AI_NONE
	///icon we use to display when constructing
	var/display_icon = null

/datum/rts_units/mantis
	buildtime = 15 SECONDS
	cost = 15

/datum/rts_units/beetle
	name = "Beetle Unit"
	buildtime = 15 SECONDS
	cost = 30
	spawntype = /mob/living/carbon/xenomorph/beetle/ai
	required_unit_building_flags = AI_ENGINEERING
