/datum/equipment_preset/uscm/clf/preview
	name = "CLF Lobby Preview, Insurgent"
	var/uniform_path = /obj/item/clothing/under/colonist/clf
	var/armor_path = /obj/item/clothing/suit/storage/militia
	var/head_path = /obj/item/clothing/head/militia

/datum/equipment_preset/uscm/clf/preview/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new uniform_path(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new armor_path(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new head_path(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)

/datum/equipment_preset/uscm/clf/preview/engineer
	name = "CLF Lobby Preview, Network Operator"
	uniform_path = /obj/item/clothing/under/colonist/clf/operative

/datum/equipment_preset/uscm/clf/preview/medic
	name = "CLF Lobby Preview, Sawbones"
	uniform_path = /obj/item/clothing/under/colonist/clf/medic

/datum/equipment_preset/uscm/clf/preview/leader
	name = "CLF Lobby Preview, Cell Leader"
	uniform_path = /obj/item/clothing/under/colonist/clf/leader
