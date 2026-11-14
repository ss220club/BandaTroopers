/area/turing
	name = "Turing Base"
	icon_state = "base"
	can_build_special = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	powernet_name = "turing"

/area/turing/base
	name = "Turing Base"
	ceiling = CEILING_REINFORCED_METAL
	sound_environment = SOUND_ENVIRONMENT_ROOM
	soundscape_playlist = SCAPE_PL_CIC

/area/turing/streets
	name = "Turing Streets"
	icon_state = "outside"
	requires_power = FALSE
	soundscape_playlist = SCAPE_PL_WIND

/area/turing/streets/west
	name = "\improper West Street"
	icon_state = "north"

/area/turing/streets/east
	name = "\improper East Street"
	icon_state = "east"

/area/turing/base/barracks
	name = "Marine Barracks"
	icon_state = "barracks"

/area/turing/base/lake_house
	name = "Lake House"
	icon_state = "civ_service"

/area/turing/base/medical
	name = "Medical Bay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/turing/base/engineering
	name = "Engineering Bay"
	icon_state = "engie"
	minimap_color = MINIMAP_AREA_ENGI
	soundscape_playlist = SCAPE_PL_ENG


/area/turing/base/command
	name = "\improper Command Center"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/turing/base/hangar
	name = "Vehicle Hangar"
	icon_state = "hangar"

/area/turing/base/garage
	name = "Garage Workshop"
	icon_state = "storage"

/area/turing/base/command/checkpoint
	name = "\improper Checkpoint Building"
	icon_state = "security"
