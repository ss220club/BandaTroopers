// Swamp_1
// Areas
//Base
/area/swamp
	name = "Base Antverted"
	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY

//==============================================================================Other
/area/swamp/caverns
	name = "Caves"
	ceiling = CEILING_UNDERGROUND_BLOCK_CAS
	icon_state = "cave"

/area/swamp/beach
	name = "Beach"
	icon_state = "blueold"
	ceiling = CEILING_NONE

/area/swamp/beach_house
	name = "Beach Housing"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/canal
	name = "Canalisation"
	icon_state = "cave"
	ceiling = CEILING_UNDERGROUND_BLOCK_CAS

//============================================================================Base Hub
/area/swamp/colony/hangar
	name = "Logistic Base Hub - Hangars"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/swamp/colony/flightdeck
	name = "Otogi Flight Control"
	icon_state = "bluenew"
	ceiling = CEILING_METAL

/area/swamp/colony/colony_exterior
	name = "Logistic Base Hub -  Inner Area"
	icon_state = "green"

/area/swamp/colony/logistics_hub
	name = "Logistic Base Hub - Warehouse"
	icon_state = "storage"
	ceiling = CEILING_METAL

/area/swamp/colony/logistics
	name = "Logistic Base Hub - Services"
	icon_state = "storage"
	ceiling = CEILING_METAL

/area/swamp/colony/complex
	name = "Logistic Base Hub - Multi-Complex Base"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/colony/engineering
	name = "Logistic Base Hub - Engineering"
	icon_state = "yellow"
	ceiling = CEILING_METAL

/area/swamp/colony/filtration
	name = "Logistic Base Hub - Filtration Tunnel"
	icon_state = "yellow"
	ceiling = CEILING_METAL

/area/swamp/colony/comms
	name = "Logistic Base Hub - T-Comms"
	icon_state = "yellow"
	soundscape_playlist = SCAPE_PL_LV522_OUTDOORS
	powernet_name = "outpost"
	ceiling = CEILING_METAL


//===============================================================================Shuttles
/area/swamp/shuttles/drop1
	name = "Logistics Base Hub"
	icon_state = "shuttle"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ

/area/swamp/shuttles/drop2
	name = "Antverd Military Base "
	icon_state = "shuttle2"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ

/area/swamp/shuttles/drop3
	name = "Keppitz Bunker- Private Hangar"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ

/area/swamp/shuttles/drop4
	name = "Site Landing"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ


//============================================================================Antverted Base
/area/swamp/base/road
	name = "Antverd Military Base Roadside"
	icon_state = "yellow"
	ceiling = CEILING_NONE

/area/swamp/base/farmland
	name = "Farmland"
	icon_state = "yellow"
	ceiling = CEILING_NONE

/area/swamp/base/church/ext
	name = "Antverd military Base - Church"
	icon_state = "central"

/area/swamp/base/church/int
	name = "Antverd military Base - Church"
	icon_state = "away1"
	ceiling = CEILING_METAL

/area/swamp/base/checkpoint
	name = "Antverd Military Base - Checkpoint"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/base/telecomms_station
	name = "Antverd military Base - Relay Substation"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/base/outskirts
	name = "Antverd military Base - Outskirts"
	icon_state = "green"


//================================================================Antverted base - Inside
/area/swamp/base/inside/lzone
	name = "Antverd Military Base - Platform"
	ceiling = CEILING_NONE
	icon_state = "south"

/area/swamp/base/inside/flag
	name = "Antverd Military Base - The Flag"
	icon_state = "head_quarters"
	minimap_color = MINIMAP_AREA_COMMAND

/area/swamp/base/inside/messhall
	name = "Antverd Military Base - Messhall"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_COLONY

/area/swamp/base/inside/requisitions
	name = "Antverd Military Base - Requisitions"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_SEC

/area/swamp/base/inside/medical
	name = "Antverd Military Base - Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/swamp/base/inside/garage
	name = "Antverd Military Base - Garage"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/swamp/base/inside/engineering
	name = "Antverd Military Base - Maintenance Room"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/swamp/base/inside/dorms
	name = "Antverd Military Base - Barracks"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_SEC

/area/swamp/base/inside/command
	name = "Antverd Military Base - Command Center"
	icon_state = "blueold"
	minimap_color = MINIMAP_AREA_COMMAND

/area/swamp/base/inside
	name = "Antverd Military Base"
	icon_state = "purple"
	ceiling = CEILING_METAL
	ambience_exterior = AMBIENCE_ALMAYER
	//ambience = list('sound/ambience/shipambience.ogg)


//================================================================Antverted Base - Bunker
/area/swamp/base/bunker
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/swamp/base/bunker/cargo
	name = "Antverd Military Base - Relay Cargo Area"
	icon_state = "storage"

/area/swamp/base/bunker/synthetic
	name = "Antverd Military Base - Relay Synthetic Storage Bay"
	icon_state = "storage"

/area/swamp/base/bunker/telecommunication
	name = "Antverd Military Base - Relay Telecommunication Center"
	icon_state = "storage"

/area/swamp/base/bunker/engineering
	name = "Antverd Military Base - Relay Generator Room"
	icon_state = "storage"


//========================================================================Keppitz Bunker
/area/swamp/base/keppitz
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/swamp/base/keppitz/command
	name = "Keppitz Bunker - Public Services Center"
	icon_state = "blue"

/area/swamp/base/keppitz/archives
	name = "Keppitz Bunker - Public Archives"
	icon_state = "bluenew"

/area/swamp/base/keppitz/entry_pub
	name = "Keppitz Bunker - Public Entry Section"
	icon_state = "blueold"

/area/swamp/base/keppitz/interlude
	name = "Keppitz Bunker - Interlude Section"
	icon_state = "fitness"

/area/swamp/base/keppitz/hangar
	name = "Keppitz Bunker -  Private Hangar"
	icon_state = "blue"

/area/swamp/base/keppitz/Engineeringlower
	name = "Keppitz Bunker  - Engineering Lower Access"
	icon_state = "engine_storage"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/swamp/base/keppitz/watertreat
	name = "Keppitz Bunker - Water Treatment Control"
	icon_state = "yellow"

/area/swamp/base/keppitz/research
	name = "Keppitz Bunker  - Research"
	icon_state = "research"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/swamp/base/keppitz/powerstation
	name = "Keppitz Bunker - Power Station"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI
	soundscape_playlist = SCAPE_PL_ENG

/area/swamp/base/keppitz/armory
	name = "Keppitz Bunker - Safe"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC


//==================================================================Murasverd Village-swamp
/area/swamp/murasverd
	name = "Murasverd Villiage"
	icon_state = "green"

/area/swamp/murasverd/house
	name = "Murasverd Village - House"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/murasverd/trench
	name = "Murasverd Village - Trench"
	icon_state = "north"
	ceiling = CEILING_NONE

/area/swamp/murasverd/village
	name = "Murasverd Village "
	icon_state = "south"
	ceiling = CEILING_NONE

/area/swamp/murasverd/river
	name = "River"
	icon_state = "west"
	ceiling = CEILING_NONE

/area/swamp/murasverd/swamp
	name = "Swamp"
	minimap_color = MINIMAP_AREA_JUNGLE
	ceiling = CEILING_NONE
	icon_state = "central"
	//ambience = list('sound/ambience/jungle_amb1.ogg')

/area/swamp/murasverd/oldman
	name = "Oldman House"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/murasverd/oldman_basement
	name = "Oldman Basement"
	icon_state = "storage"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL


//==========================================================================Villa General
/area/swamp/villa
	name = "Villa General"
	icon_state = "south"

/area/swamp/villa/house
	name = "Villa General - House"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_COMMAND
	ceiling = CEILING_METAL

/area/swamp/villa/checkpoint
	name = "Villa General - Checkpoint"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/swamp/villa/garage
	name = "Villa General - Garage"
	icon_state = "storage"
	ceiling = CEILING_METAL


//===================================================================Villa General-bunker
/area/swamp/villa/bunker
	name = "Villa General - Bunker - Main Hall"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	icon_state = "central"

/area/swamp/villa/bunker/armory
	name = "Villa General - Bunker - Armory"
	icon_state = "red"

/area/swamp/villa/bunker/command
	name = "Villa General - Bunker - Operations Center"
	icon_state = "bluenew"

/area/swamp/villa/bunker/engineer
	name = "Villa General - Bunker - Engineering"
	icon_state = "engine_smes"

/area/swamp/villa/bunker/holding
	name = "Villa General - Bunker - Holding Cell"
	icon_state = "security"

/area/swamp/villa/bunker/closet
	name = "Villa General - Bunker - Supply Closet"
	icon_state = "storage"

/area/swamp/villa/bunker/hospital
	name = "Villa General - Bunker - Hospital"
	icon_state = "medbay"

/area/swamp/villa/bunker/cafe
	name = "Villa General - Bunker - Cafe"
	icon_state = "cafeteria"

/area/swamp/villa/bunker/research
	name = "Villa General - Bunker - Research Labs"
	icon_state = "research"

/area/swamp/villa/bunker/barracks
	name = "Barracks"
	icon_state = "Sleep"
