#define POD_FRAME_STAGE_FOUNDATION 0      // Just laid down
#define POD_FRAME_STAGE_STRUTS_SECURED 1  // After initial wrenching
#define POD_FRAME_STAGE_BEAMS_WELDED 2    // After main welding
#define POD_FRAME_STAGE_FRAME_REINFORCED 3// After final wrenching
#define POD_FRAME_STAGE_HULL_ATTACHED 4   // After crowbarring plates
#define POD_FRAME_STAGE_HULL_SEALED 5     // After hull welding
#define POD_FRAME_STAGE_AIRLOCK_INSTALLED 6// After final hull wrenching
#define POD_FRAME_STAGE_ENGINE_INSTALLED 7 // Engine placed and secured
#define POD_FRAME_STAGE_FUEL_SYSTEM_INSTALLED 8 // Fuel tank and lines
#define POD_FRAME_STAGE_POWER_WIRED 9     // Main power cables
#define POD_FRAME_STAGE_CONSOLE_INSTALLED 10 // Navigation console
#define POD_FRAME_STAGE_CELL_INSERTED 11   // Power cell is in
#define POD_FRAME_STAGE_CALIBRATED 12      // Final screwdriver step done

/obj/structure/escape_pod
	name = "Escape Pod Frame"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "An incomplete escape pod."
	density = TRUE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	max_integrity = 600
	var/occupied = FALSE
	///how much fuel we have
	var/fuelcount = 0
	///what stage of construction we're at
	var/construction_stage = POD_FRAME_STAGE_FOUNDATION
	///used for holding when we need to do multiple steps like screwing a bolt multiple times
	var/substep = 0
	///used for keeping track of whether we added metal in a specific step
	var/metal_invested = 0
	///used for keeping track of how much cable we have inserted in a specific step
	var/cable_invested = 0

/obj/structure/escape_pod_frame/examine(mob/user)
	. = ..()
	. += "<span class='notice'>"
	switch(construction_stage)
		if(POD_FRAME_STAGE_FOUNDATION)
			. += "The basic foundation is laid, but the main structural struts are loose. They need to be secured with a <b>wrench</b>."
		if(POD_FRAME_STAGE_STRUTS_SECURED)
			. += "The primary struts are bolted in place, but the frame lacks rigidity. It needs major support beams to be attached with a <b>welder</b>."
		if(POD_FRAME_STAGE_BEAMS_WELDED)
			. += "The main support beams have been welded, creating a solid chassis. The entire structure should be given a final tightening with a <b>wrench</b> to ensure its integrity."
		if(POD_FRAME_STAGE_FRAME_REINFORCED)
			. += "The frame is now solid and rigid. It's ready for the outer hull plates to be pried into place with a <b>crowbar</b>."
		if(POD_FRAME_STAGE_HULL_ATTACHED)
			. += "The hull plates are fitted, but the seams are exposed. They need to be sealed with a <b>welder</b> to make the pod airtight."
		if(POD_FRAME_STAGE_HULL_SEALED)
			. += "The hull is sealed and airtight. All that's left is to install the airlock mechanism with a <b>wrench</b>."
		if(POD_FRAME_STAGE_AIRLOCK_INSTALLED)
			. += "The pod is now fully enclosed. It's time to install the core systems. The first step is to mount the <b>engine</b>."
		if(POD_FRAME_STAGE_ENGINE_INSTALLED)
			. += "The engine is mounted. Next, the <b>fuel tank</b> and its associated lines need to be connected."
		if(POD_FRAME_STAGE_FUEL_SYSTEM_INSTALLED)
			. += "The propulsion system is installed. The pod now needs its main <b>power systems wired up</b> with cable coils."
		if(POD_FRAME_STAGE_POWER_WIRED)
			. += "The main power conduits are in place. The <b>navigation console</b> can now be installed."
		if(POD_FRAME_STAGE_CONSOLE_INSTALLED)
			. += "The navigation console is installed, but it needs a power source. It's ready for the main <b>power cell</b> to be inserted."
		if(POD_FRAME_STAGE_CELL_INSERTED)
			. += "The pod is powered, but the avionics and thrusters are out of sync. It needs a final, delicate <b>systems calibration</b> with a <b>screwdriver</b>."
		if(POD_FRAME_STAGE_CALIBRATED)
			. += "All systems are calibrated and online. A final <b>systems diagnostic</b> is required before it's ready for launch."

	. += "</span>"

/obj/structure/escape_pod/destroyed
	icon_state = "labcageb0"
	density = FALSE
	occupied = FALSE

/obj/structure/escape_pod/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			if(prob(50))
				take_damage(50, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			if(prob(50))
				take_damage(5, BRUTE, BOMB)


/obj/structure/escape_pod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.visible_message(span_warning("[user] kicks the escape pod."), span_notice("You kick the escape pod, it hurts your foot."))
	take_damage(2, BRUTE, MELEE)

/obj/structure/escape_pod_frame/attackby(obj/item/I, mob/user, params)
	// --- Material Handling (No change, this part is good) ---
	if(istype(I, /obj/item/stack/metal)) {
		if(metal_needed > 0 && metal_invested < metal_needed) {
			var/obj/item/stack/metal/M = I
			var/amount_to_add = min(M.amount, metal_needed - metal_invested)
			if(user.transfer_item_to_atom(M, src, amount_to_add)) {
				user.visible_message(span_notice("[user] adds [amount_to_add] metal sheets to the frame."), span_notice("You add [amount_to_add] metal sheets to the frame."))
				metal_invested += amount_to_add
			}
		} else {
			to_chat(user, "<span class='warning'>The frame doesn't require any more metal for this construction phase.</span>")
		}
		return
	}
	if(istype(I, /obj/item/stack/cable_coil)) {
		if(cable_needed > 0 && cable_invested < cable_needed) {
			var/obj/item/stack/cable_coil/C = I
			var/amount_to_add = min(C.amount, cable_needed - cable_invested)
			if(user.transfer_item_to_atom(C, src, amount_to_add)) {
				user.visible_message(span_notice("[user] adds [amount_to_add] lengths of cable to the frame."), span_notice("You add [amount_to_add] lengths of cable to the frame."))
				cable_invested += amount_to_add
			}
		} else {
			to_chat(user, "<span class='warning'>The frame doesn't require any more cable for this construction phase.</span>")
		}
		return
	}

	// --- Tool Handling ---
	var/build_skill_mod = user.skills?.getRating(SKILL_CONSTRUCTION) || SKILL_CONSTRUCTION_DEFAULT
	var/skill_multiplier = 1 + (SKILL_CONSTRUCTION_DEFAULT - build_skill_mod) * 0.10

	switch(construction_stage)
		if(POD_FRAME_STAGE_FOUNDATION)
			if(iswrench(I)) {
				metal_needed = 25
				if(metal_invested < metal_needed) {
					return to_chat(user, span_warning("The frame needs at least [metal_needed] metal sheets to secure the struts."))
				}

				var/bolts_to_tighten = 4
				var/action_time = 10 SECONDS * skill_multiplier

				if(substep < (bolts_to_tighten - 1)) {
					if(do_after(user, action_time, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_FOUNDATION))) {
						substep++
						user.visible_message(span_notice("[user] tightens a structural bolt on the frame."), span_notice("You tighten another bolt. [bolts_to_tighten - 1 - substep] more to go."))
					}
				} else {
					if(do_after(user, action_time, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_FOUNDATION))) {
						user.visible_message(span_notice("[user] secures the final strut on the escape pod frame!"), span_notice("You secure the final strut."))
						advance_stage_to(POD_FRAME_STAGE_STRUTS_SECURED)
					}
				}
			}

		if(POD_FRAME_STAGE_STRUTS_SECURED)
			if(iswelder(I)) {
				metal_needed = 50
				if(metal_invested < metal_needed) return to_chat(user, span_warning("The frame needs [metal_needed] metal sheets for the support beams."))
				var/obj/item/tool/weldingtool/welder = I
				if(!welder.is_hot()) return to_chat(user, span_warning("The welder must be on!"))

				if(do_after(user, 60 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_STRUTS_SECURED))) {
					user.visible_message(span_notice("[user] welds the main support beams onto the frame."), span_notice("You finish welding the support beams."))
					advance_stage_to(POD_FRAME_STAGE_BEAMS_WELDED)
				}
			}

		if(POD_FRAME_STAGE_BEAMS_WELDED)
			if(iswrench(I)) {
				metal_needed = 25
				if(metal_invested < metal_needed) return to_chat(user, span_warning("The frame needs [metal_needed] metal sheets for reinforcement plates."))

				if(do_after(user, 20 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_BEAMS_WELDED))) {
					user.visible_message(span_notice("[user] reinforces the pod's chassis."), span_notice("You finish reinforcing the frame."))
					advance_stage_to(POD_FRAME_STAGE_FRAME_REINFORCED)
				}
			}

		if(POD_FRAME_STAGE_FRAME_REINFORCED)
			if(iscrowbar(I)) {
				metal_needed = 50
				if(metal_invested < metal_needed) return to_chat(user, span_warning("You need [metal_needed] metal sheets for the hull plating."))

				if(do_after(user, 30 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_FRAME_REINFORCED))) {
					user.visible_message(span_notice("[user] pries the heavy hull plates into position."), span_notice("You fit the hull plates onto the frame."))
					advance_stage_to(POD_FRAME_STAGE_HULL_ATTACHED)
				}
			}

		if(POD_FRAME_STAGE_HULL_ATTACHED)
			if(iswelder(I)) {
				var/obj/item/tool/weldingtool/welder = I
				if(!welder.is_hot()) return to_chat(user, span_warning("The welder must be on!"))

				if(do_after(user, 60 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_HULL_ATTACHED))) {
					user.visible_message(span_notice("[user] seals the hull seams, making the pod airtight."), span_notice("You finish welding the hull."))
					advance_stage_to(POD_FRAME_STAGE_HULL_SEALED)
				}
			}

		if(POD_FRAME_STAGE_HULL_SEALED)
			if(iswrench(I)) {
				metal_needed = 25
				if(metal_invested < metal_needed) return to_chat(user, span_warning("You need [metal_needed] metal sheets to assemble the airlock mechanism."))

				if(do_after(user, 30 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_HULL_SEALED))) {
					user.visible_message(span_notice("[user] installs the airlock mechanism."), span_notice("You finish installing the airlock."))
					advance_stage_to(POD_FRAME_STAGE_AIRLOCK_INSTALLED)
				}
			}

		if(POD_FRAME_STAGE_AIRLOCK_INSTALLED)
			if(!has_engine) return to_chat(user, span_warning("You need to install an engine first (use an empty hand while holding it)."))

			if(iswrench(I) && substep == 0) {
				if(do_after(user, 20 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_AIRLOCK_INSTALLED))) {
					user.visible_message(span_notice("[user] secures the engine mounts."), span_notice("You secure the engine mounts."))
					substep = 1 // Mark wrenching as done
				}
			} else if(iswelder(I)) {
				if(substep < 1) return to_chat(user, span_warning("You need to secure the engine mounts with a wrench first."))
				var/obj/item/tool/weldingtool/welder = I
				if(!welder.is_hot()) return to_chat(user, span_warning("The welder must be on!"))

				if(do_after(user, 20 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_AIRLOCK_INSTALLED))) {
					user.visible_message(span_notice("[user] welds the engine into the frame."), span_notice("You weld the engine into place."))
					advance_stage_to(POD_FRAME_STAGE_ENGINE_INSTALLED)
				}
			}

		if(POD_FRAME_STAGE_ENGINE_INSTALLED)
			if(!has_fuel_tank) return to_chat(user, span_warning("You need to install a fuel tank first."))
			if(iswrench(I)) {
				cable_needed = 20
				if(cable_invested < cable_needed) return to_chat(user, span_warning("You need [cable_needed] lengths of cable to connect the fuel lines."))

				if(do_after(user, 45 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_ENGINE_INSTALLED))) {
					user.visible_message(span_notice("[user] connects the fuel tank and lines."), span_notice("You finish connecting the fuel system."))
					advance_stage_to(POD_FRAME_STAGE_FUEL_SYSTEM_INSTALLED)
				}
			}

		if(POD_FRAME_STAGE_FUEL_SYSTEM_INSTALLED)
			if(iswirecutter(I)) {
				cable_needed = 20
				if(cable_invested < cable_needed) return to_chat(user, span_warning("You need [cable_needed] lengths of cable to wire the main power systems."))

				if(do_after(user, 60 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_FUEL_SYSTEM_INSTALLED))) {
					user.visible_message(span_notice("[user] wires the main power systems."), span_notice("You finish wiring the main power systems."))
					advance_stage_to(POD_FRAME_STAGE_POWER_WIRED)
				}
			}

		if(POD_FRAME_STAGE_POWER_WIRED)
			if(!has_console_screen) return to_chat(user, span_warning("You need to install a console screen first."))
			if(iswirecutter(I)) {
				cable_needed = 10
				if(cable_invested < cable_needed) return to_chat(user, span_warning("You need [cable_needed] lengths of cable to connect the avionics."))

				if(do_after(user, 30 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_POWER_WIRED))) {
					user.visible_message(span_notice("[user] connects the avionics to the main console."), span_notice("You connect the avionics."))
					advance_stage_to(POD_FRAME_STAGE_CONSOLE_INSTALLED)
				}
			}

		if(POD_FRAME_STAGE_CONSOLE_INSTALLED)
			if(!has_power_cell) return to_chat(user, span_warning("You need to insert a power cell first."))
			if(iswrench(I)) {
				if(do_after(user, 10 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_CONSOLE_INSTALLED))) {
					user.visible_message(span_notice("[user] secures the power cell."), span_notice("You lock the power cell in place."))
					advance_stage_to(POD_FRAME_STAGE_CELL_INSERTED)
				}
			}

		if(POD_FRAME_STAGE_CELL_INSERTED)
			if(isscrewdriver(I)) {
				if(do_after(user, 45 SECONDS * skill_multiplier, target = src, extra_checks = CALLBACK(src, PROC_REF(check_construction_state), POD_FRAME_STAGE_CELL_INSERTED))) {
					user.visible_message(span_notice("[user] performs the final systems calibration."), span_notice("You finish calibrating the systems."))
					advance_stage_to(POD_FRAME_STAGE_CALIBRATED)
				}
			}

	return ..()
