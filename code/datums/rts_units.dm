/datum/rts_units
	var/name = "Mantis Unit"
	var/buildtime = 10 SECONDS
	var/cost = 15
	var/spawntype = /mob/living/carbon/xenomorph/mantis/ai
	var/required_unit_building_flags = null

/datum/rts_units/mantis
	buildtime = 15 SECONDS
	cost = 15

/datum/rts_units/beetle
	name = "Beetle Unit"
	buildtime = 15 SECONDS
	cost = 30
	spawntype = /mob/living/carbon/xenomorph/beetle/ai
	required_unit_building_flags = AI_ENGINEERING
