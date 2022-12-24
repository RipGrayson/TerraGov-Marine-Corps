//Santa is back in town
/datum/emergency_call/santa
	name = "Santa's Workshop"
	base_probability = 40
	alignement_factor = 0


/datum/emergency_call/santa/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You [pick("fed the reindeer and worked hard for 11 months a year", "worked hard to deliver presents to good boys and girls of all species", "survived the ice, snow, and low gravity working tirelessly for Santa", "were a master craftsman who snuck onto Santa's galactic sleigh ride")].</b>")
	to_chat(H, "<B>As part of Santa's entourage, you travel with him to deliver presents to all who deserve to be rewarded.</b>")
	to_chat(H, "<B>Santa travels the galaxy once a year, visiting every single inhabited planet in a single period of 24 standard hours. Santa maintains an active defense force to punish especially naughty sapients with lethal force, this defense force currently numbers more than 30,000 elves and ships.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, while enroute to visit a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], the artificial intelligence in Santa's sleigh detected an abnormally high level of naughtiness in the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Santa has resolved to punish them in the spirit of Christmas!</b>")
	if(GLOB.round_statistics.number_of_grinches >= 3)
		to_chat(H, "<B>Punish the naughty </b>marines and aliens</b> onboard the ship, coal won't be enough this time. The only punishment Santa believes in now is hot lead!</B>")
	else
		to_chat(H, "<B>Punish the naughty </b>aliens</b> onboard the ship, coal won't be enough this time. The only punishment Santa believes in now is hot lead!</B>")

/datum/emergency_call/santa/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	//
	//Santa himself is a discount deathsquad leader, his elves are just fodder though and very poorly equipped
	//

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/leader)
		H.name = "Santa Claus"
		H.real_name = H.name
		H.apply_assigned_role_to_spawn(J)
		H.set_nutrition(NUTRITION_OVERFED * 2)
		H.grant_language(/datum/language/xenocommon)
		if(GLOB.round_statistics.number_of_grinches >= 3)
			to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are Santa Claus! Punish all naughty </b>marines and aliens</b> with overwhelming firepower, starting with their commanders hiding on the ship.")]</p>")
		else
			to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are Santa Claus! Punish all the naughty </b>aliens</b> with overwhelming firepower, starting with their cowardly queen hiding on the ship.")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/santa)
	H.apply_assigned_role_to_spawn(J)
	H.name = "Elf [rand(1,999)]"
	H.real_name = H.name
	print_backstory(H)
	to_chat(H, span_notice("You are a member of Santa's loyal workforce, assist Santa in whatever way you can!"))
