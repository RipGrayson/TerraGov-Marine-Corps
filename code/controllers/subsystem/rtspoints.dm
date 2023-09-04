#define TESTING

// points per minute
#define AI_SUPPLY_POINT_RATE 20 * (GLOB.current_orbit/3)

SUBSYSTEM_DEF(rtspoints)
	name = "Rtspoints"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING

	wait = 10 SECONDS
	///list of rts points the AI has
	var/ai_points = list()
	///list of the last point gain we got
	var/ailastrecordedpointgain = 0

/datum/controller/subsystem/rtspoints/Recover()
	ai_points = SSrtspoints.ai_points

/datum/controller/subsystem/rtspoints/Initialize()
	ai_points = rand(2000, 3000)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rtspoints/proc/calculatepoints()
	var/sumofpoints = null
	for(var/obj/structure/rts_building/structure in GLOB.constructed_rts_builds)
		sumofpoints += structure.pointvalue
	return sumofpoints

/datum/controller/subsystem/rtspoints/fire(resumed = FALSE)
	var/aipointstoadd
	aipointstoadd = calculatepoints()
	if(!length(GLOB.constructed_rts_builds))
		ai_points -= 10 / (10 SECONDS / wait)
		return
	ai_points += aipointstoadd / (10 SECONDS / wait)
	ailastrecordedpointgain = aipointstoadd
