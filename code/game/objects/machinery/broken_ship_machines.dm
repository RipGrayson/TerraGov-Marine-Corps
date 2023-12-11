/obj/machinery/broken_ship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "hangarbox"
	max_integrity = 100

/obj/machinery/broken_ship/power_gen
	name = "Shipside Power Generator"
	desc = "Commonly seen on colonization starships that need power for a long duration."
	var/is_active = TRUE
	icon_state = "generator_on"
	max_integrity = 300

/obj/machinery/broken_ship/power_gen/off
	is_active = FALSE
	icon_state = "generator"
