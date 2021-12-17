////////////////////HOLOSIGN///////////////////////////////////////
/obj/machinery/laser_emitter
	name = "laser emitter"
	desc = "Small wall-mounted laser projector"
	icon = 'icons/obj/machines/laseremitterwall.dmi'
	icon_state = "laser1"
	layer = TURF_LAYER
	anchored = TRUE
	var/fireinterval = 0

/obj/machinery/laser_emitter/proc/firelaser()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	var/turflist = getline(get_turf(src.loc), get_turf(get_step(src, WEST)))
	to_chat(world, span_boldnotice("Laser attempting to fire"))
	laser_turfs(turflist)
	update_icon()

/obj/machinery/laser_emitter/proc/laser_beam_turf(turf/T)
	. = locate(/obj/effect/laserbeam/flash) in T
	if(!.)

		. = new /obj/effect/laserbeam/flash
		to_chat(world, span_boldnotice("Procing laser beam turf"))

		for(var/i in T)
			var/atom/A = i
			if(!A)
				continue

/obj/machinery/laser_emitter/proc/laser_turfs(list/turflist)
	set waitfor = FALSE

	if(isnull(turflist))
		return
	
	var/maxdistance = 0
	
	for(var/X in turflist)
		var/turf/T = X
		if(T.density || isspaceturf(T))
			to_chat(world, span_boldnotice("Density detected 1"))
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				to_chat(world, span_boldnotice("Density detected 2"))
				blocked = TRUE
				break

		laser_beam_turf(T)

		maxdistance++
		if(blocked)
			to_chat(world, span_boldnotice("Blocked"))
			break

/obj/effect/laserbeam/flash
	icon_state = "laserfire"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/laserbeam/flash/Initialize(mapload, duration = 1000 SECONDS, damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE) //Self-deletes
	. = ..()
	var/targetturf = get_turf(src.loc)
	var/area/A = get_area(src)
	to_chat(world, span_boldnotice("Firing"))
	to_chat(world, span_boldnotice(A))
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, duration + rand(0, 1 SECONDS))

/obj/effect/laserbeam/flash/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()