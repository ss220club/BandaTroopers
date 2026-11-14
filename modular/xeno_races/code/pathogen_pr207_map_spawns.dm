/// Pathogen round versions of the Distress structure setup landmarks.
/obj/effect/landmark/structure_spawner/setup/distress
	var/pathogen_path

/obj/effect/landmark/structure_spawner/setup/distress/set_pathogen_spawns()
	if(!pathogen_path)
		qdel(src)
		return
	path_to_spawn = pathogen_path

/obj/effect/landmark/structure_spawner/setup/distress/xeno_wall
	pathogen_path = /turf/closed/wall/resin/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_membrane
	pathogen_path = /turf/closed/wall/resin/membrane/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_door
	pathogen_path = /obj/structure/mineral_door/resin/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_nest
	pathogen_path = /obj/structure/bed/nest/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_weed_node
	pathogen_path = /obj/effect/alien/weeds/node/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_wall_reinforced
	pathogen_path = /turf/closed/wall/resin/thick/pathogen

/obj/effect/landmark/structure_spawner/setup/distress/xeno_door_reinforced
	pathogen_path = /obj/structure/mineral_door/resin/pathogen/thick
