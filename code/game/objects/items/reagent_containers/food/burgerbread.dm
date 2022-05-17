//Food items that are eaten normally and don't leave anything behind.
/obj/item/reagent_containers/food/snacks/soup
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/items/soupsalad.dmi'
	icon_state = null

/obj/item/reagent_containers/food/snacks/soup/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D1F4FF"
	list_reagents = list(/datum/reagent/water = 10)
	bitesize = 5
	tastes = list("wishes" = 1)

/obj/item/reagent_containers/food/snacks/soup/wish/Initialize(mapload)
	. = ..()
	var/wish_true = prob(25)
	if(wish_true)
		desc = "A wish come true!"
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)

/obj/item/reagent_containers/food/snacks/soup/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/drink/tomatojuice = 3)
	bitesize = 5
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/soup/slime
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 9, /datum/reagent/water = 5)
	tastes = list("slime" = 1)

/obj/item/reagent_containers/food/snacks/soup/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper"
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/blood = 10, /datum/reagent/water= 5)
	bitesize = 5
	tastes = list("iron" = 1)

/obj/item/reagent_containers/food/snacks/soup/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43DE18"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("soy" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/soup/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/banana = 5, /datum/reagent/water = 10)
	bitesize = 5
	tastes = list("a bad joke" = 1)

/obj/item/reagent_containers/food/snacks/soup/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal" //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5)
	bitesize = 5
	tastes = list("vegetables" = 1)

/obj/item/reagent_containers/food/snacks/soup/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5, /datum/reagent/medicine/tricordrazine = 5)
	bitesize = 5
	tastes = list("nettles" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F082FF"
	bitesize = 5
	tastes = list("chaos" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup/Initialize()
	. = ..()
	var/mysteryselect = pick(1,2,3,4,5,6,7,8,9)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)
			reagents.add_reagent(/datum/reagent/consumable/capsaicin, 3)
			reagents.add_reagent(/datum/reagent/consumable/drink/tomatojuice, 2)
		if(2)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)
			reagents.add_reagent(/datum/reagent/consumable/frostoil, 3)
			reagents.add_reagent(/datum/reagent/consumable/drink/tomatojuice, 2)
		if(3)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)
			reagents.add_reagent(/datum/reagent/water, 5)
			reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 5)
		if(4)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)
			reagents.add_reagent(/datum/reagent/water, 10)
		if(5)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 2)
			reagents.add_reagent(/datum/reagent/consumable/drink/banana,, 10)
		if(6)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)
			reagents.add_reagent(/datum/reagent/blood, 10)
		if(7)
			reagents.add_reagent(/datum/reagent/carbon, 10)
			reagents.add_reagent(/datum/reagent/toxin, 10)
		if(8)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)
			reagents.add_reagent(/datum/reagent/consumable/drink/tomatojuice, 10)
		if(9)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)
			reagents.add_reagent(/datum/reagent/consumable/drink/tomatojuice, 5)
			reagents.add_reagent(/datum/reagent/medicine/imidazoline, 5)
/obj/item/reagent_containers/food/snacks/soup/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FF3C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/capsaicin = 3)
	bitesize = 5
	tastes = list("hot peppers" = 1)

/obj/item/reagent_containers/food/snacks/soup/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/frostoil = 3)
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	tastes = list("tomato" = 1, "mint" = 1)

/obj/item/reagent_containers/food/snacks/soup/larvasoup
	name = "Larva Soup"
	desc = "Liquified larva."
	icon_state = "larvasoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#66801e"
	list_reagents = list(/datum/reagent/consumable/larvajellyprepared = 1, /datum/reagent/consumable/nutriment = 4)
	bitesize = 5
	tastes = list("burning" = 1)

/obj/item/reagent_containers/food/snacks/soup/clownchili
	name = "chili con carnival"
	desc = "A delicious stew of meat, chiles, and salty, salty clown tears."
	icon_state = "clownchili"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/tomatojuice = 4, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/banana = 1, /datum/reagent/consumable/laughter = 1)
	tastes = list("tomato" = 1, "hot peppers" = 2, "clown feet" = 2, "kind of funny" = 2, "someone's parents" = 2)

/obj/item/reagent_containers/food/snacks/soup/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3,  /datum/reagent/consumable/nutriment/protein = 9, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("the jungle" = 1, "banana" = 1)

/obj/item/reagent_containers/food/snacks/soup/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D92929"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/drink/tomatojuice = 10)
	bitesize = 3
	tastes = list("tomato" = 1)

/obj/item/reagent_containers/food/snacks/soup/eyeball
	name = "eyeball soup"
	desc = "It looks back at you..."
	icon_state = "eyeballsoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/liquidgibs = 3)
	tastes = list("tomato" = 1, "squirming" = 1)

/obj/item/reagent_containers/food/snacks/soup/miso
	name = "misosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "misosoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("miso" = 1)

/obj/item/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#E386BF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	bitesize = 3
	tastes = list("mushroom" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FAC9FF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("tasteless soup" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup/Initialize()
	. = ..()
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	tastes = list(name = 1)

/obj/item/reagent_containers/food/snacks/soup/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/psilocybin = 6)
	bitesize = 3
	tastes = list("jelly" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/soup/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic"
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/amatoxin = 6, /datum/reagent/consumable/psilocybin = 3)
	bitesize = 3
	tastes = list("jelly" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/soup/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/drink/tomatojuice = 5, /datum/reagent/consumable/drink/carrotjuice = 5, /datum/reagent/water = 5)
	bitesize = 7
	volume = 100
	tastes = list("tomato" = 1, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/soup/sweetpotato
	name = "sweet potato soup"
	desc = "Delicious sweet potato in soup form."
	icon_state = "sweetpotatosoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("sweet potato" = 1)

/obj/item/reagent_containers/food/snacks/soup/beet/red
	name = "red beet soup"
	desc = "Quite a delicacy."
	icon_state = "redbeetsoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("beet" = 1)

/obj/item/reagent_containers/food/snacks/soup/onion
	name = "french onion soup"
	desc = "Good enough to make a grown mime cry."
	icon_state = "onionsoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 8, /datum/reagent/consumable/nutriment/vitamin = 5)

/obj/item/reagent_containers/food/snacks/soup/bisque
	name = "bisque"
	desc = "A classic entree from Space-France."
	icon_state = "bisque"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("creamy texture" = 1, "crab" = 4)

/obj/item/reagent_containers/food/snacks/soup/electron
	name = "electron soup"
	desc = "A gastronomic curiosity of ethereal origin. It is famed for the minature weather system formed over a properly prepared soup."
	icon_state = "electronsoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/liquidelectricity/enriched = 12)
	tastes = list("mushroom" = 1, "electrons" = 4)

/obj/item/reagent_containers/food/snacks/soup/bungocurry
	name = "bungo curry"
	desc = "A spicy vegetable curry made with the humble bungo fruit, Exotic!"
	icon_state = "bungocurry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/bungojuice = 9, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bungo" = 2, "hot curry" = 4, "tropical sweetness" = 1)

/obj/item/reagent_containers/food/snacks/soup/mammi
	name = "Mammi"
	desc = "A bowl of mushy bread and milk. It reminds you, not too fondly, of a bowel movement."
	icon_state = "mammi"
	list_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/reagent_containers/food/snacks/soup/peasoup
	name = "pea soup"
	desc = "A humble split pea soup."
	icon_state = "peasoup"
	list_reagents = list (/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("creamy peas"= 2, "parsnip" = 1)

/obj/item/reagent_containers/food/snacks/soup/indian_curry
	name = "indian chicken curry"
	desc = "A mild, creamy curry from the old subcontinent. Liked by the Space-British, because it reminds them of the Raj."
	icon_state = "indian_curry"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("chicken" = 2, "creamy curry" = 4, "earthy heat" = 1)

/obj/item/reagent_containers/food/snacks/soup/oatmeal
	name = "oatmeal"
	desc = "A nice bowl of oatmeal."
	icon_state = "oatmeal"
	list_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/milk = 10, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("oats" = 1, "milk" = 1)

/obj/item/reagent_containers/food/snacks/soup/zurek
	name = "zurek"
	desc = "A traditional Polish soup composed of vegetables, meat, and an egg. Goes great with bread."
	icon_state = "zurek"
	list_reagents = list (/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("creamy vegetables"= 2, "sausage" = 1)

/obj/item/reagent_containers/food/snacks/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5)
	bitesize = 4
	tastes = list("miso" = 1)
