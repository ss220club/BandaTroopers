#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/f90_equipment/Run()
	var/turf/test_turf = locate(1, 1, 1)
	var/list/rack_types = list(
		/obj/structure/gun_rack/f90,
		/obj/structure/gun_rack/f90/a_grip,
		/obj/structure/gun_rack/f90/marksman,
		/obj/structure/gun_rack/f90/breacher
	)
	for(var/rack_type as anything in rack_types)
		var/obj/structure/gun_rack/rack = new rack_type(test_turf)
		if(length(rack.contents) != 6 || !(rack.icon_state in icon_states(rack.icon)))
			return Fail("[rack_type] is missing its loaded sprite or contents", __FILE__, __LINE__)
		for(var/count in 0 to 6)
			if(!("[initial(rack.icon_state)]_[count]" in icon_states(rack.icon)))
				return Fail("[rack_type] is missing its [count] rifle sprite", __FILE__, __LINE__)
		for(var/obj/item/weapon/gun/gun as anything in rack.contents)
			if(!istype(gun, rack.populate_type))
				return Fail("[rack_type] contains the wrong rifle", __FILE__, __LINE__)
		for(var/count in 5 to 0 step -1)
			var/obj/item/weapon/gun/removed = rack.contents[length(rack.contents)]
			removed.forceMove(test_turf)
			rack.update_icon()
			if(rack.icon_state != "[initial(rack.icon_state)]_[count]")
				return Fail("[rack_type] does not lose one sprite per rifle", __FILE__, __LINE__)
			qdel(removed)
		qdel(rack)
	var/list/box_types = list(
		/obj/item/ammo_box/magazine/f90,
		/obj/item/ammo_box/magazine/f90/ap,
		/obj/item/ammo_box/magazine/f90/heap,
		/obj/item/ammo_box/magazine/f90/marksman,
		/obj/item/ammo_box/magazine/f90/marksman/heap,
		/obj/item/ammo_box/magazine/f90/large,
		/obj/item/ammo_box/magazine/f90/large/ap,
		/obj/item/ammo_box/magazine/f90/large/heap,
		/obj/item/ammo_box/magazine/f90/large/marksman,
		/obj/item/ammo_box/magazine/f90/large/marksman/heap
	)
	for(var/box_type as anything in box_types)
		var/obj/item/ammo_box/magazine/box = new box_type(test_turf)
		if(length(box.contents) != box.num_of_magazines)
			return Fail("[box_type] contains the wrong magazine count", __FILE__, __LINE__)
		if(!("text[box.overlay_gun_type]" in icon_states(box.text_markings_icon)))
			return Fail("[box_type] is missing its F90 label", __FILE__, __LINE__)
		if(!("base_type[box.overlay_ammo_type]" in icon_states(box.text_markings_icon)))
			return Fail("[box_type] is missing its ammo marking", __FILE__, __LINE__)
		var/obj/item/ammo_magazine/magazine = box.contents[1]
		if(!istype(magazine, box.magazine_type))
			return Fail("[box_type] contains the wrong magazine", __FILE__, __LINE__)
		var/obj/structure/magazine_box/f90/deployed = new(test_turf)
		deployed.item_box = box
		deployed.update_icon()
		if(deployed.text_markings_icon != box.text_markings_icon)
			return Fail("[box_type] loses its label when deployed", __FILE__, __LINE__)
		deployed.item_box = null
		qdel(deployed)
		qdel(box)
#endif
