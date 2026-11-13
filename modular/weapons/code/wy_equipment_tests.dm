#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/wy_equipment/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/structure/gun_rack/flammenwerfer3/deathsquad/rack = new(test_turf)
	if(length(rack.contents) != 2 || rack.max_stored != 2 || rack.icon_state != "fl3rack_2")
		Fail("Flammenwerfer rack must spawn with exactly two guns", __FILE__, __LINE__)
	for(var/obj/item/gun as anything in rack.contents)
		if(!istype(gun, /obj/item/weapon/gun/flamer/flammenwerfer3/deathsquad))
			Fail("Flammenwerfer rack contains the wrong gun", __FILE__, __LINE__)
	for(var/count in 0 to 2)
		if(!("fl3rack_[count]" in icon_states(rack.icon)))
			Fail("Flammenwerfer rack is missing a stock sprite", __FILE__, __LINE__)
	qdel(rack)

	var/obj/item/storage/box/guncase/heavy/es7/es7_case = new(test_turf)
	var/shotguns = 0
	var/slug_boxes = 0
	for(var/obj/item/item as anything in es7_case.contents)
		if(istype(item, /obj/item/weapon/gun/shotgun/es7))
			shotguns++
		else if(istype(item, /obj/item/ammo_magazine/shotgun/beanbag/es7/slug))
			slug_boxes++
	if(shotguns != 1 || slug_boxes != 5 || es7_case.storage_slots != 6)
		Fail("ES-7 case must contain one shotgun and five slug boxes", __FILE__, __LINE__)
	for(var/state in list("es7case", "es7case_lid", "es7case_lid_open", "+es7gun", "+es7slug_5"))
		if(!(state in icon_states(es7_case.icon)))
			Fail("ES-7 case is missing sprite [state]", __FILE__, __LINE__)
	qdel(es7_case)

	var/obj/item/storage/box/guncase/heavy/fuel/pmc/flammenwerfer3/fuel_case = new(test_turf)
	var/fuel_tanks = 0
	for(var/obj/item/item as anything in fuel_case.contents)
		if(istype(item, /obj/item/ammo_magazine/flamer_tank/flammenwerfer/whiteout))
			fuel_tanks++
	if(fuel_tanks != 6 || length(fuel_case.contents) != 6)
		Fail("Flammenwerfer fuel case must contain six EX tanks", __FILE__, __LINE__)
	qdel(fuel_case)

	var/obj/item/weapon/gun/rifle/m46c/xm46a = new(test_turf)
	if(!(xm46a.flags_gun_features & GUN_WY_RESTRICTED))
		Fail("XM46A is missing PMC firing restriction", __FILE__, __LINE__)
	if(!(/obj/item/ammo_magazine/rifle/ap in xm46a.accepted_ammo) || !(/obj/item/ammo_magazine/rifle/m41aMK1/ap in xm46a.accepted_ammo))
		Fail("XM46A must accept MK2 and MK1 magazines", __FILE__, __LINE__)
	if(!("xm46a" in icon_states(xm46a.icon)) || !("xm46a_e" in icon_states(xm46a.icon)))
		Fail("XM46A lacks its loaded or empty world sprite", __FILE__, __LINE__)
	for(var/slot in list(WEAR_L_HAND, WEAR_R_HAND, WEAR_BACK, WEAR_J_STORE))
		if(!(xm46a.get_icon_state(null, slot) in icon_states(xm46a.item_icons[slot])))
			Fail("XM46A lacks a sprite for slot [slot]", __FILE__, __LINE__)
	if(!("m46c_w" in icon_states(xm46a.item_icons[WEAR_L_HAND])) || !("m46c_w" in icon_states(xm46a.item_icons[WEAR_R_HAND])))
		Fail("XM46A lacks wielded hand sprites", __FILE__, __LINE__)
	qdel(xm46a)
#endif
