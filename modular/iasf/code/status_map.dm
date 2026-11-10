GLOBAL_DATUM_INIT(twe_tacmap_status, /datum/tacmap/drawing/status_tab_view/twe, new)

/datum/tacmap/drawing/status_tab_view/twe/New()
	. = ..()
	allowed_flags = MINIMAP_FLAG_TWE

/mob/living/carbon/human/get_status_tab_items()
	. = ..()
	if(faction != FACTION_TWE && faction != FACTION_IASF)
		return
	var/map_link = "<a href='byond://?MapView=1'>View Tactical Map</a>"
	if(!(map_link in .))
		. += ""
		. += map_link

/proc/open_faction_status_tacmap(mob/viewer)
	if(!viewer)
		return
	if(viewer.faction == FACTION_TWE || viewer.faction == FACTION_IASF)
		GLOB.twe_tacmap_status.tgui_interact(viewer)
		return
	GLOB.uscm_tacmap_status.tgui_interact(viewer)
