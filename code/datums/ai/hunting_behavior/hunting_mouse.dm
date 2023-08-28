// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/mouse
	hunt_targets = list(/obj/item/reagent_containers/food/snacks/cheesewedge)
	hunt_range = 1

// Our hunts have a decent cooldown.
/datum/ai_behavior/hunt_target/unarmed_attack_target/mouse
	hunt_cooldown = 20 SECONDS
