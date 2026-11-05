#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/breacher_equipment/Run()
	var/list/items = list(
		/obj/item/clothing/suit/storage/marine/m40,
		/obj/item/clothing/suit/storage/marine/m40/twe,
		/obj/item/clothing/head/helmet/marine/m40,
		/obj/item/clothing/head/helmet/marine/m40/twe,
		/obj/item/clothing/gloves/marine/m40,
		/obj/item/weapon/twohanded/breacher_hammer,
		/obj/item/weapon/shield/riot/montage,
		/obj/item/weapon/shield/riot/montage/twe,
		/obj/item/weapon/shield/riot/ballistic/iasf,
		/obj/item/weapon/gun/rifle/xm52,
		/obj/item/weapon/gun/launcher/rocket/brute/breacher,
		/obj/item/storage/belt/gun/xm52,
		/obj/item/storage/belt/gun/brutepack,
		/obj/item/storage/box/spec/breacher,
	)
	for(var/item_type as anything in items)
		var/obj/item/item = new item_type()
		if(!(item.icon_state in icon_states(item.icon)))
			return Fail("[item_type] has no object sprite [item.icon_state]", __FILE__, __LINE__)
		qdel(item)
	var/obj/item/clothing/suit/storage/marine/m40/twe/twe_armor = new()
	if(!(/datum/action/item_action/specialist/enrage in twe_armor.actions_types))
		return Fail("TWE breacher armor has no stimulant action", __FILE__, __LINE__)
	qdel(twe_armor)
	var/obj/item/weapon/shield/riot/montage/uscm_shield = new()
	var/obj/item/weapon/shield/riot/montage/twe/twe_shield = new()
	var/obj/item/weapon/shield/riot/ballistic/iasf/iasf_shield = new()
	if(twe_shield.passive_block != uscm_shield.passive_block || twe_shield.readied_block != uscm_shield.readied_block)
		return Fail("TWE breacher shield protection differs from USCM", __FILE__, __LINE__)
	if(iasf_shield.passive_block != uscm_shield.passive_block || iasf_shield.readied_block != uscm_shield.readied_block)
		return Fail("IASF breacher shield protection differs from USCM", __FILE__, __LINE__)
	qdel(uscm_shield)
	qdel(twe_shield)
	qdel(iasf_shield)
#endif
