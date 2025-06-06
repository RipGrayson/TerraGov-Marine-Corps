/*CONTENTS
Buildable pipes
Buildable meters
*/

//construction defines are in __defines/pipe_construction.dm
//update those defines ANY TIME an atmos path is changed...
//...otherwise construction will stop working

/obj/item/pipe
	name = "pipe"
	desc = "A pipe."
	var/pipe_type
	var/pipename
	force = 7
	throwforce = 7
	icon = 'icons/obj/items/pipe_item.dmi'
	icon_state = "simple"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	worn_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	level = 2
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/RPD_type

/obj/item/pipe/directional
	RPD_type = PIPE_UNARY
/obj/item/pipe/binary
	RPD_type = PIPE_STRAIGHT
/obj/item/pipe/binary/bendable
	RPD_type = PIPE_BENDABLE
/obj/item/pipe/trinary
	RPD_type = PIPE_TRINARY
/obj/item/pipe/trinary/flippable
	RPD_type = PIPE_TRIN_M
	var/flipped = FALSE
/obj/item/pipe/quaternary
	RPD_type = PIPE_ONEDIR

///obj/item/pipe/ComponentInitialize()
	//Flipping handled manually due to custom handling for trinary pipes
	//AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/item/pipe/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from)
	if(make_from)
		make_from_existing(make_from)
	else
		pipe_type = _pipe_type
		setDir(_dir)

	update()
	pixel_x += rand(-5, 5)
	pixel_y += rand(-5, 5)
	return ..()

/obj/item/pipe/proc/make_from_existing(obj/machinery/atmospherics/make_from)
	setDir(make_from.dir)
	pipename = make_from.name
	add_atom_colour(make_from.color, FIXED_COLOR_PRIORITY)
	pipe_type = make_from.type

/obj/item/pipe/trinary/flippable/make_from_existing(obj/machinery/atmospherics/components/trinary/make_from)
	..()
	if(make_from.flipped)
		do_a_flip()

/obj/item/pipe/dropped()
	if(loc)
		setPipingLayer(piping_layer)
	return ..()

/obj/item/pipe/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	var/obj/machinery/atmospherics/fakeA = pipe_type

	if(initial(fakeA.pipe_flags) & PIPING_ALL_LAYER)
		new_layer = PIPING_LAYER_DEFAULT
	piping_layer = new_layer

	PIPING_LAYER_SHIFT(src, piping_layer)
	layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

/obj/item/pipe/proc/update()
	var/obj/machinery/atmospherics/fakeA = pipe_type
	name = "[initial(fakeA.name)] fitting"
	icon_state = initial(fakeA.pipe_state)

/obj/item/pipe/verb/flip()
	set category = "IC.Object"
	set name = "Flip Pipe"
	set src in view(1)

	if(!isliving(usr))
		return

	var/mob/living/L = usr

	if ( L.incapacitated() )
		return

	do_a_flip()

/obj/item/pipe/proc/do_a_flip()
	setDir(turn(dir, -180))

/obj/item/pipe/trinary/flippable/do_a_flip()
	setDir(turn(dir, flipped ? 45 : -45))
	flipped = !flipped

// Convert dir of fitting into dir of built component
/obj/item/pipe/proc/fixed_dir()
	return dir

/obj/item/pipe/binary/fixed_dir()
	. = dir
	if(dir == SOUTH)
		. = NORTH
	else if(dir == WEST)
		. = EAST

/obj/item/pipe/trinary/flippable/fixed_dir()
	. = dir
	if(dir in GLOB.diagonals)
		. = turn(dir, 45)

/obj/item/pipe/attack_self(mob/user)
	setDir(turn(dir,-90))

/obj/item/pipe/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(user.incapacitated())
		return FALSE
	if(iswrench(I))
		return wrench_act(user, I)

/obj/item/pipe/wrench_act(mob/living/user, obj/item/tool/wrench/W)
	if(!isturf(loc))
		return TRUE

	var/obj/machinery/atmospherics/fakeA = pipe_type
	var/flags = initial(fakeA.pipe_flags)
	for(var/obj/machinery/atmospherics/M in loc)
		if((M.pipe_flags & flags & PIPING_ONE_PER_TURF))	//Only one dense/requires density object per tile, eg connectors/cryo/heater/coolers.
			to_chat(user, span_warning("Something is hogging the tile!"))
			return TRUE
		if((M.piping_layer != piping_layer) && !((M.pipe_flags | flags) & PIPING_ALL_LAYER)) //don't continue if either pipe goes across all layers
			continue
		if(M.GetInitDirections() & SSair.get_init_dirs(pipe_type, fixed_dir()))	// matches at least one direction on either type of pipe
			to_chat(user, span_warning("There is already a pipe at that location!"))
			return TRUE
	// no conflicts found

	var/obj/machinery/atmospherics/A = new pipe_type(loc)
	build_pipe(A)
	A.on_construction(color, piping_layer)

	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		span_notice("You fasten \the [src]."), \
		span_italics("You hear ratcheting."))

	qdel(src)

/obj/item/pipe/proc/build_pipe(obj/machinery/atmospherics/A)
	A.setDir(fixed_dir())
	A.SetInitDirections()

	if(pipename)
		A.name = pipename
	if(A.on)
		// Certain pre-mapped subtypes are on by default, we want to preserve
		// every other aspect of these subtypes (name, pre-set filters, etc.)
		// but they shouldn't turn on automatically when wrenched.
		A.on = FALSE

/obj/item/pipe/trinary/flippable/build_pipe(obj/machinery/atmospherics/components/trinary/T)
	..()
	T.flipped = flipped

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/items/pipe_item.dmi'
	icon_state = "meter"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	worn_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/attackby(obj/item/W, mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!.)
		return ..()

/obj/item/pipe_meter/wrench_act(mob/living/user, obj/item/tool/wrench/W)

	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in loc)
		if(P.piping_layer == piping_layer)
			pipe = P
			break
	if(!pipe)
		to_chat(user, span_warning("You need to fasten it to a pipe!"))
		return TRUE
	new /obj/machinery/meter(loc, piping_layer)
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	to_chat(user, span_notice("You fasten the meter to the pipe."))
	qdel(src)

/obj/item/pipe_meter/screwdriver_act(mob/living/user, obj/item/S)
	. = ..()
	if(.)
		return TRUE

	if(!isturf(loc))
		to_chat(user, span_warning("You need to fasten it to the floor!"))
		return TRUE

	new /obj/machinery/meter/turf(loc, piping_layer)
	playsound(src.loc, 'sound/items/screwdriver.ogg', 25, 1)
	to_chat(user, span_notice("You fasten the meter to the [loc.name]."))
	qdel(src)

/obj/item/pipe_meter/dropped()
	. = ..()
	if(loc)
		setAttachLayer(piping_layer)

/obj/item/pipe_meter/proc/setAttachLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, piping_layer)
