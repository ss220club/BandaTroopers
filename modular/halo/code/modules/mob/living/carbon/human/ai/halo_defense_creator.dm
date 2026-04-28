/datum/human_ai_defense/barricade/covenant
	name = "Covenant Barrier"
	desc = /obj/structure/covenant_barricade::desc
	category = "Covenant Barricades"
	path_to_spawn = /obj/structure/covenant_barricade

/datum/human_ai_defense/barricade/covenant/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/covenant_barricade/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)

/datum/human_ai_defense/barricade/covenant/wide
	name = "Covenant Triptych Barrier"
	desc = /obj/structure/covenant_barricade/wide::desc
	path_to_spawn = /obj/structure/covenant_barricade/wide

/datum/human_ai_defense/mine/covenant
	uses_turned_on = FALSE
	category = "Covenant Landmines"

/datum/human_ai_defense/mine/covenant/plasma
	name = "Covenant Plasma Mine"
	desc = /obj/item/explosive/mine/covenant/plasma/active::desc
	icon_state = "plasmamine"
	path_to_spawn = /obj/item/explosive/mine/covenant/plasma/active

/datum/human_ai_defense/mine/covenant/needle
	name = "Covenant Needle Mine"
	desc = /obj/item/explosive/mine/covenant/needle_mine/active::desc
	icon_state = "needlemine"
	path_to_spawn = /obj/item/explosive/mine/covenant/needle_mine/active
