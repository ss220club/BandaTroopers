#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/uscm_map_camouflage/Run()
	var/datum/map_config/ground_config = SSmapping.configs[GROUND_MAP]
	if(!ground_config)
		return Fail("Ground map configuration is unavailable", __FILE__, __LINE__)
	var/original_camouflage = ground_config.camouflage_type
	var/list/gear = list(
		/obj/item/clothing/suit/storage/marine = WEAR_JACKET,
		/obj/item/clothing/suit/storage/marine/tanker = WEAR_JACKET,
		/obj/item/clothing/suit/storage/marine/medium/rto = WEAR_JACKET,
		/obj/item/clothing/suit/storage/marine/M3S = WEAR_JACKET,
		/obj/item/clothing/suit/storage/marine/MP = WEAR_JACKET,
		/obj/item/clothing/suit/storage/marine/MP/general = WEAR_JACKET,
		/obj/item/clothing/head/helmet/marine = WEAR_HEAD,
		/obj/item/clothing/head/helmet/marine/tech/tanker = WEAR_HEAD,
		/obj/item/clothing/head/helmet/marine/rto/intel = WEAR_HEAD,
		/obj/item/clothing/head/helmet/marine/scout = WEAR_HEAD,
		/obj/item/clothing/head/helmet/marine/specialist = WEAR_HEAD,
	)
	var/list/styled_gear = list(
		/obj/item/clothing/suit/storage/marine/tanker,
		/obj/item/clothing/suit/storage/marine/medium/rto,
		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/suit/storage/marine/MP,
		/obj/item/clothing/head/helmet/marine/tech/tanker,
		/obj/item/clothing/head/helmet/marine/rto/intel,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/clothing/head/helmet/marine/specialist,
	)
	var/failure
	for(var/camouflage in list("snow", "desert", "urban", "classic", "jungle"))
		ground_config.camouflage_type = camouflage
		for(var/gear_type as anything in gear)
			var/obj/item/gear_item = new gear_type()
			var/slot = gear[gear_type]
			var/worn_state = gear_item.get_icon_state(null, slot)
			var/worn_icon = gear_item.item_icons[slot]
			if(!(gear_item.icon_state in icon_states(gear_item.icon)) || !(worn_state in icon_states(worn_icon)))
				failure = "[gear_type] has an invalid [camouflage] object or worn state"
			else if(gear_type in styled_gear && camouflage != "jungle")
				var/style_prefix = copytext(gear_item.icon_state, 1, 3)
				if(style_prefix != copytext(camouflage, 1, 2) + "_")
					failure = "[gear_type] did not select [camouflage] camouflage"
			qdel(gear_item)
			if(failure)
				break
		if(failure)
			break
	ground_config.camouflage_type = original_camouflage
	if(failure)
		return Fail(failure, __FILE__, __LINE__)
#endif
