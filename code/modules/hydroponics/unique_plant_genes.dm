
// --- Below here are special, unique plant traits that only belong to certain plants. ---
// They are un-removable and cannot be mutated randomly, and should never be graftable.

/// Sunflower's attack effect (shows cute text)
/datum/plant_gene/trait/attack/sunflower_attack
	name = "Bright Petals"

/datum/plant_gene/trait/attack/sunflower_attack/after_plant_attack(obj/item/our_plant, atom/target, mob/living/user)
	. = ..()

	if(!ismob(target))
		return
	var/mob/target_mob = target
	user.visible_message("<font color='green'>[user] smacks [target_mob] with [user.p_their()] [our_plant.name]! <font color='orange'><b>FLOWER POWER!</b></font></font>", ignored_mobs = list(target_mob, user))
	if(target_mob != user)
		to_chat(target_mob, "<font color='green'>[user] smacks you with [our_plant]!<font color='orange'><b>FLOWER POWER!</b></font></font>")
	to_chat(user, "<font color='green'>Your [our_plant.name]'s <font color='orange'><b>FLOWER POWER</b></font> strikes [target_mob]!</font>")

/// Normal nettle's force + degradation on attack
/datum/plant_gene/trait/attack/nettle_attack
	name = "Sharpened Leaves"

/datum/plant_gene/trait/attack/nettle_attack/after_plant_attack(obj/item/our_plant, atom/target, mob/user)
	. = ..()

	if(!ismovable(target))
		return
	if(our_plant.force > 0)
		our_plant.force -= rand(1, (our_plant.force / 3) + 1)
	else
		to_chat(user, "<span class='warning'>All the leaves have fallen off [our_plant] from violent whacking!</span>")
		qdel(our_plant)

/// Traiit for plants eaten in 1 bite.
/datum/plant_gene/trait/one_bite
	name = "Large Bites"

/datum/plant_gene/trait/one_bite/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/food/grown/grown_plant = our_plant
	if(istype(grown_plant))
		grown_plant.bite_consumption_mod = 100

/// Traits for plants with a different base max_volume.
/datum/plant_gene/trait/modified_volume
	name = "Deep Vesicles"
	/// The new number we set the plant's max_volume to.
	var/new_capcity = 100

/datum/plant_gene/trait/modified_volume/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/food/grown/grown_plant = our_plant
	if(istype(grown_plant))
		grown_plant.max_volume = new_capcity

/// Omegaweed's funny 420 max volume gene
/datum/plant_gene/trait/modified_volume/omega_weed
	name = "Dank Vesicles"
	new_capcity = 420

/// Starthistle's essential invasive spreading
/datum/plant_gene/trait/invasive/galaxythistle
	mutability_flags = PLANT_GENE_GRAFTABLE

/// Jupitercup's essential carnivory
/datum/plant_gene/trait/carnivory/jupitercup
	mutability_flags = PLANT_GENE_GRAFTABLE

/// Preset plant reagent genes that are unremovable from a plant.
/datum/plant_gene/reagent/preset
	mutability_flags = PLANT_GENE_GRAFTABLE

/datum/plant_gene/reagent/preset/New(new_reagent_id, new_reagent_rate = 0.04)
	. = ..()
	set_reagent(reagent_id)

/// Spaceman's Trumpet fragile Polypyrylium Oligomers
/datum/plant_gene/reagent/preset/polypyr
	reagent_id = /datum/reagent/medicine/polypyr
	rate = 0.15

/// Jupitercup's fragile Liquid Electricity
/datum/plant_gene/reagent/preset/liquidelectricity
	reagent_id = /datum/reagent/consumable/liquidelectricity/enriched
	rate = 0.1

/// Carbon Roses's fragile Carbon
/datum/plant_gene/reagent/preset/carbon
	reagent_id = /datum/reagent/carbon
	rate = 0.1
