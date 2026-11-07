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
		/obj/item/weapon/gun/rifle/xm52/iasf,
		/obj/item/ammo_magazine/rifle/xm52/iasf_ap,
		/obj/item/ammo_magazine/shotgun/light/breaching/sparkshots/iasf_ap,
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

/datum/unit_test/breacher_shield_stance/Run()
	var/list/shield_types = list(
		/obj/item/weapon/shield/riot/montage,
		/obj/item/weapon/shield/riot/montage/marine,
		/obj/item/weapon/shield/riot/montage/twe,
		/obj/item/weapon/shield/riot/ballistic/iasf,
	)
	for(var/shield_type as anything in shield_types)
		var/turf/test_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, test_turf)
		var/obj/item/weapon/shield/riot/shield = allocate(shield_type, human)
		if(!human.put_in_active_hand(shield))
			return Fail("[shield_type] cannot be held", __FILE__, __LINE__)
		human.setDir(NORTH)
		shield.attack_self(human)
		if(shield.stance_user != human)
			return Fail("[shield_type] did not enter stance", __FILE__, __LINE__)
		if(shield.icon_state != "[shield.base_icon_state]_ready" || !(shield.icon_state in icon_states(shield.icon)))
			return Fail("[shield_type] has no ready sprite", __FILE__, __LINE__)
		if(!HAS_TRAIT(human, TRAIT_IMMOBILIZED) || !HAS_TRAIT(human, TRAIT_INCAPACITATED))
			return Fail("[shield_type] did not immobilize its user", __FILE__, __LINE__)
		var/obj/projectile/shot = allocate(/obj/projectile, test_turf)
		shot.ammo = allocate(/datum/ammo/bullet)
		shot.starting = get_step(human, NORTH)
		if(!(SEND_SIGNAL(human, COMSIG_HUMAN_PRE_BULLET_ACT, shot) & COMPONENT_CANCEL_BULLET_ACT))
			return Fail("[shield_type] did not stop a frontal shot", __FILE__, __LINE__)
		shot.starting = get_step(human, SOUTH)
		if(SEND_SIGNAL(human, COMSIG_HUMAN_PRE_BULLET_ACT, shot) & COMPONENT_CANCEL_BULLET_ACT)
			return Fail("[shield_type] stopped a rear shot", __FILE__, __LINE__)
		if(!(SEND_SIGNAL(human, COMSIG_KB_MOB_ACTIVATEINHAND_DOWN) & COMPONENT_KB_ACTIVATED))
			return Fail("[shield_type] did not respond to Z", __FILE__, __LINE__)
		if(shield.stance_user)
			return Fail("[shield_type] stayed planted after Z", __FILE__, __LINE__)
		if(shield.icon_state != shield.base_icon_state || !(shield.icon_state in icon_states(shield.icon)))
			return Fail("[shield_type] did not restore its normal sprite", __FILE__, __LINE__)
		if(HAS_TRAIT(human, TRAIT_IMMOBILIZED) || HAS_TRAIT(human, TRAIT_INCAPACITATED))
			return Fail("[shield_type] kept its user incapacitated", __FILE__, __LINE__)
		shield.attack_self(human)
		if(shield.stance_user)
			return Fail("[shield_type] ignored its cooldown", __FILE__, __LINE__)
#endif
