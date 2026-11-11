/datum/equipment_preset/proc/add_lb_merc_survivor_weapon(mob/living/carbon/human/new_human)
	var/random_weapon = rand(0,19)
	switch(random_weapon)
		if(0 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/a_m36(new_human), WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
		if(5 to 9)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/a_m36(new_human), WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
		if(10 to 13)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/a_m36(new_human), WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
		if(14 to 17)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/a_m36(new_human), WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/a_m36(new_human), WEAR_IN_BACK)
		if(18,19)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(new_human), WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot(new_human), WEAR_IN_BACK)


/datum/equipment_preset/proc/add_survivor_weapon_civilian(mob/living/carbon/human/new_human)
	if(prob(60))
		return
	var/random_weapon = rand(0,4)
	switch(random_weapon)
		if(0)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/boltaction(new_human), WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/boltaction(new_human), WEAR_WAIST)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(new_human), WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/uzi(new_human), WEAR_WAIST)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/dual_tube/cmb(new_human), WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/shotgun_ammo, WEAR_WAIST)
		if(3)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/ar10(new_human), WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/ar10(new_human), WEAR_WAIST)
		if(4)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/w_ek_17(new_human), WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/wy/generic/w_ek_17(new_human), WEAR_WAIST)


/datum/equipment_preset/proc/add_survivor_rare_item(mob/living/carbon/human/new_human)
	var/random_rare_item = rand(1,444)
	switch(random_rare_item)
		if(1 to 4) // 2%
			new_human.equip_to_slot_or_del(new /obj/item/device/motiondetector/m717(new_human), WEAR_IN_BACK)
		if(5 to 8) // 2%
			new_human.equip_to_slot_or_del(new /obj/item/device/defibrillator/compact(new_human), WEAR_IN_BACK)
		if(9 to 16) // 4%
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/survivor(new_human), WEAR_IN_BACK)
		if(17 to 26) // 5%
			new_human.equip_to_slot_or_del(new /obj/item/storage/box/packet/high_explosive(new_human), WEAR_IN_BACK)
		if(27 to 38) // 6%
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack/upgraded(new_human), WEAR_IN_BACK)
		if(39 to 54) // 8%
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment/upgraded(new_human), WEAR_IN_BACK)
		if(55 to 74) // 10%
			new_human.equip_to_slot_or_del(new /obj/item/storage/box/attachments(new_human), WEAR_IN_BACK)
		if(75 to 104) // 15%
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/ert(new_human), WEAR_R_STORE)
		if(105 to 144) // 20%
			new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/m15(new_human), WEAR_IN_BACK)
		if(145 to 194) // 25%
			new_human.equip_to_slot_or_del(new /obj/item/cell/hyper(new_human), WEAR_IN_BACK)
		if(195 to 254) // 30%
			new_human.equip_to_slot_or_del(new /obj/item/attachable/flashlight/grip(new_human), WEAR_IN_BACK)
		if(255 to 324) // 35%
			new_human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack (new_human), WEAR_IN_BACK)
		if(325 to 444) // 45%
			new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/civ(new_human), WEAR_IN_BACK)
