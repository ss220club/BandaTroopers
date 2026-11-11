/obj/effect/landmark
	var/spawn_chance = 100

/obj/effect/landmark/ammo_spawn/m41a_random_spawn
	name = "m41a ammo spawn"
	icon_state = "ipool"

/obj/effect/landmark/ammo_spawn/m41a_random_spawn/Initialize(mapload, ...)
	. = ..()
	if(prob(spawn_chance))
		new /obj/item/ammo_magazine/rifle(loc)

/obj/effect/landmark/ammo_spawn/m41a_ext_random_spawn
	name = "m41a extended ammo spawn"
	icon_state = "ipool"

/obj/effect/landmark/ammo_spawn/m41a_ext_random_spawn/Initialize(mapload, ...)
	. = ..()
	if(prob(spawn_chance))
		new /obj/item/ammo_magazine/rifle/extended(loc)

/obj/effect/landmark/ammo_spawn/m4ra_random_spawn
	name = "m4ra ammo spawn"
	icon_state = "ipool"

/obj/effect/landmark/ammo_spawn/m4ra_random_spawn/Initialize(mapload, ...)
	. = ..()
	if(prob(spawn_chance))
		new /obj/item/ammo_magazine/rifle/m49a(loc)

/obj/effect/landmark/ammo_spawn/m4ra_ext_random_spawn
	name = "m4ra extended ammo spawn"
	icon_state = "ipool"

/obj/effect/landmark/ammo_spawn/m4ra_ext_random_spawn/Initialize(mapload, ...)
	. = ..()
	if(prob(spawn_chance))
		new /obj/item/ammo_magazine/rifle/m49a/ext(loc)

/obj/effect/landmark/survivor_spawner/us_army_engineer
	equipment = /datum/equipment_preset/survivor/army/engineer
	spawn_priority = SPAWN_PRIORITY_HIGH

/obj/effect/landmark/survivor_spawner/us_army_medic
	equipment = /datum/equipment_preset/survivor/army/medic
	spawn_priority = SPAWN_PRIORITY_MEDIUM

/obj/effect/landmark/survivor_spawner/us_army_marksman
	equipment = /datum/equipment_preset/survivor/army/marksman
	spawn_priority = SPAWN_PRIORITY_MEDIUM

/obj/effect/landmark/survivor_spawner/us_army_gunner
	equipment = /datum/equipment_preset/survivor/army/gunner
	spawn_priority = SPAWN_PRIORITY_MEDIUM

/obj/effect/landmark/survivor_spawner/us_army_sl
	equipment = /datum/equipment_preset/survivor/army/sl
	spawn_priority = SPAWN_PRIORITY_VERY_HIGH

/obj/effect/landmark/lv624/fog_blocker/long
	time_to_dispel = 24 HOURS

/obj/effect/landmark/ert_spawns/groundside_army
	name = "distress_groundside_army"
	icon_state = "spawn_distress_wo"

/obj/structure/flora/wood/trunk1
	name = "tree trunk"
	icon_state = "trunk1"

/obj/structure/flora/wood/trunk2
	name = "tree trunk"
	icon_state = "trunk2"
