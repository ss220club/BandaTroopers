// Keep Pathogen mycelium separate from ordinary xeno weeds at every spread site.
/obj/effect/alien/weeds/proc/get_spread_weed_type(base_type)
	var/spread_hive = linked_hive ? linked_hive.hivenumber : hivenumber
	if(spread_hive != XENO_HIVE_PATHOGEN)
		return base_type

	var/static/list/pathogen_spread_types = list(
		/obj/effect/alien/weeds = /obj/effect/alien/weeds/pathogen,
		/obj/effect/alien/weeds/weedwall = /obj/effect/alien/weeds/weedwall/pathogen,
		/obj/effect/alien/weeds/weedwall/window = /obj/effect/alien/weeds/weedwall/window/pathogen,
		/obj/effect/alien/weeds/weedwall/frame = /obj/effect/alien/weeds/weedwall/frame/pathogen
	)
	return pathogen_spread_types[base_type] || base_type

/obj/effect/alien/weeds/node/pathogen
	weed_family = XENO_HIVE_PATHOGEN
	node_overlay_icon = 'icons/mob/pathogen/pathogen_weeds.dmi'

/obj/effect/alien/weeds/pathogen
	weed_family = XENO_HIVE_PATHOGEN

/obj/effect/alien/weeds/weedwall/pathogen
	weed_family = XENO_HIVE_PATHOGEN

/obj/effect/alien/weeds/weedwall/window/pathogen
	weed_family = XENO_HIVE_PATHOGEN

/obj/effect/alien/weeds/weedwall/frame/pathogen
	weed_family = XENO_HIVE_PATHOGEN

/obj/effect/alien/weeds/node/pylon/pathogen_core
	icon = 'icons/mob/pathogen/pathogen_weeds.dmi'
	weed_family = XENO_HIVE_PATHOGEN
	node_overlay_icon = 'icons/mob/pathogen/pathogen_weeds.dmi'

/obj/effect/alien/weeds/node/pylon/cluster/pathogen
	icon = 'icons/mob/pathogen/pathogen_weeds.dmi'
	weed_family = XENO_HIVE_PATHOGEN
	node_overlay_icon = 'icons/mob/pathogen/pathogen_weeds.dmi'

/obj/effect/alien/weeds/node/proc/get_pathogen_node_overlay_image()
	var/static/image/pathogen_node_image
	if(!pathogen_node_image)
		pathogen_node_image = image('icons/mob/pathogen/pathogen_weeds.dmi', "weednode", ABOVE_OBJ_LAYER)
	return pathogen_node_image

/obj/effect/alien/weeds/node/pathogen/get_node_overlay_image()
	return get_pathogen_node_overlay_image()

/obj/effect/alien/weeds/node/pylon/pathogen_core/get_node_overlay_image()
	return get_pathogen_node_overlay_image()

/obj/effect/alien/weeds/node/pylon/cluster/pathogen/get_node_overlay_image()
	return get_pathogen_node_overlay_image()
