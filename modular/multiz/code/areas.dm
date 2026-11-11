/area/navalis
	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY

/area/navalis/oob
	name = "Navalis - Out Of Bounds"
	icon_state = "unknown"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	minimap_color = MINIMAP_AREA_OOB
	flags_area = AREA_NOTUNNEL|AREA_UNWEEDABLE|AREA_NO_PARA

/area/navalis/indoors
	name = "Navalis - Indoors"
	icon_state = "cliff_blocked"
	ceiling = CEILING_METAL
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/navalis/outdoors
	name = "Navalis - Outdoors"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	soundscape_playlist = SCAPE_PL_LV759_OUTDOORS
	ambience_exterior = AMBIENCE_CITY
	soundscape_interval = 25

/area/navalis/oob/water
	name = "Water - Near"
	icon_state = "blue2"
	ceiling = CEILING_NONE
	requires_power = FALSE
	base_lighting_alpha = 25
	minimap_color = MINIMAP_WATER

/area/navalis/oob/water/mid
	name = "Water - Middle"
	base_lighting_alpha = 30

/area/navalis/oob/water/far
	name = "Water - Far"
	base_lighting_alpha = 35

/area/navalis/oob/powered
	requires_power = FALSE

/area/navalis/oob/empty_space
	requires_power = FALSE
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_WATER
	flags_area = AREA_NOTUNNEL|AREA_UNWEEDABLE|AREA_NO_PARA

/area/navalis/outdoors/charon
	name = "PSV Charon"
	icon_state = "unknown"
	ceiling = CEILING_NONE

/area/navalis/outdoors/charon/surface_deck
	name = "PSV Charon - Forecastle Deck"
	icon_state = "syndie-ship"

/area/navalis/outdoors/charon/surface_deck/forecastle_deck
	name = "PSV Charon - Forecastle Deck"

/area/navalis/outdoors/charon/surface_deck/main_deck
	name = "PSV Charon - Main Deck"

/area/navalis/outdoors/charon/surface_deck/rear_deck
	name = "PSV Charon - Poop Deck"

/area/navalis/indoors/charon
	name = "PSV Charon - Below Deck"
	icon_state = "unknown"
	ceiling = CEILING_METAL

/area/navalis/indoors/charon/surface_deck
	icon_state = "syndie-ship"

/area/navalis/indoors/charon/surface_deck/main_deck
	name = "PSV Charon - Main Deck"

/area/navalis/indoors/charon/surface_deck/rear_deck
	name = "PSV Charon - Poop Deck"

/area/navalis/indoors/charon/below_deck
	icon_state = "syndie-ship"

/area/navalis/indoors/charon/below_deck/front
	name = "PSV Charon - Below-Deck Fore"

/area/navalis/indoors/charon/below_deck/middle
	name = "PSV Charon - Below-Deck: Cargo Hold"

/area/navalis/indoors/charon/below_deck/rear
	name = "PSV Charon - Below-Deck Aft"

/area/navalis/indoors/charon/upper_deck
	icon_state = "syndie-ship"

/area/navalis/indoors/charon/upper_deck/front
	name = "PSV Charon - Upper-Deck: Bridge"

/area/navalis/indoors/charon/upper_deck/rear
	name = "PSV Charon - Upper-Deck: Engineering"

/area/navalis/indoors/med_sci
	name = "Medi-Sci Rig - Indoors"
	icon_state = "medbay"
	ceiling = CEILING_METAL

/area/navalis/indoors/med_sci/foyer
	name = "Medi-Sci Rig - Level-1: Foyer"

/area/navalis/indoors/med_sci/main_floor
	name = "Medi-Sci Rig - Level-1: Treatment Floor"

/area/navalis/indoors/med_sci/surg_one
	name = "Medi-Sci Rig - Level-1: Surgery One"

/area/navalis/indoors/med_sci/surg_two
	name = "Medi-Sci Rig - Level-1: Surgery Two"

/area/navalis/indoors/med_sci/elevator
	name = "Medi-Sci Rig - Level-1: Elevator"

/area/navalis/indoors/med_sci/break_room
	name = "Medi-Sci Rig - Level-1: Employee Break Room"

/area/navalis/indoors/med_sci/pharmacy
	name = "Medi-Sci Rig - Level-1: Pharmacy"

/area/navalis/indoors/med_sci/storage
	name = "Medi-Sci Rig - Level-1: Medical Storage"

/area/navalis/indoors/med_sci/records_room
	name = "Medi-Sci Rig - Level-1: Records Room"

/area/navalis/indoors/med_sci/science_lower_entrance
	name = "Medi-Sci Rig - Level-1: Sci-Wing Lower-Entrance"

/area/navalis/indoors/med_sci/corridor
	name = "Medi-Sci Rig - Level-1: Lower Corridor"

/area/navalis/indoors/med_sci/chemical_store
	name = "Medi-Sci Rig - Level-1: Chemical Storage"

/area/navalis/indoors/med_sci/maintenance_port
	name = "Medi-Sci Rig - Level-1: Port Maintenance"

/area/navalis/indoors/med_sci/maintenance_starboard
	name = "Medi-Sci Rig - Level-1: Starboard Maintenance"

/area/navalis/indoors/med_sci/lower_level
	name = "Medi-Sci Rig - Level-0"

/area/navalis/indoors/med_sci/lower_level/port
	name = "Medi-Sci Rig - Level-0: Port-Corridor"

/area/navalis/indoors/med_sci/lower_level/starboard
	name = "Medi-Sci Rig - Level-0: Starboard-Corridor"

/area/navalis/indoors/med_sci/lower_level/records
	name = "Medi-Sci Rig - Level-0: Storage Records"

/area/navalis/indoors/med_sci/lower_level/delivery
	name = "Medi-Sci Rig - Level-0: Delivery Bay"

/area/navalis/indoors/med_sci/upper_level
	name = "Medi-Sci Rig - Level-2"

/area/navalis/indoors/med_sci/upper_level/entrance
	name = "Medi-Sci Rig - Level-2: Entrance"

/area/navalis/indoors/med_sci/upper_level/morgue
	name = "Medi-Sci Rig - Level-2: Morgue"

/area/navalis/indoors/med_sci/upper_level/sec
	name = "Medi-Sci Rig - Level-2: Security Office"

/area/navalis/indoors/med_sci/upper_level/corridor
	name = "Medi-Sci Rig - Level-2: Corridor"

/area/navalis/indoors/med_sci/upper_level/flight
	name = "Medi-Sci Rig - Level-2: Medical Flight Control"

/area/navalis/indoors/med_sci/upper_level/store
	name = "Medi-Sci Rig - Level-2: Storage"

/area/navalis/indoors/med_sci/upper_level/on_duty
	name = "Medi-Sci Rig - Level-2: On-Call Standby Quarters"

/area/navalis/indoors/med_sci/upper_level/sci_ent
	name = "Medi-Sci Rig - Level-2: Sci-Wing Entrance"

/area/navalis/indoors/med_sci/upper_level/sci_lab
	name = "Medi-Sci Rig - Level-2: Sci-Wing Lab"

/area/navalis/indoors/med_sci/upper_level/sci_scan
	name = "Medi-Sci Rig - Level-2: Sci-Wing Scanning Room"

/area/navalis/indoors/command
	name = "Command Rig - Indoors"
	icon_state = "bridge"

/area/navalis/indoors/command/aft_hallway
	name = "Command Rig - Level-1: Aft-Hallway"

/area/navalis/indoors/command/port_hallway
	name = "Command Rig - Level-1: Port-Hallway"

/area/navalis/indoors/command/starboard_hallway
	name = "Command Rig - Level-1: Starboard-Hallway"

/area/navalis/indoors/command/office
	name = "Command Rig - Level-1: Main Office"

/area/navalis/indoors/command/conferance
	name = "Command Rig - Level-1: Conferance Room"

/area/navalis/indoors/command/director_office
	name = "Command Rig - Level-1: Site Director's Office"

/area/navalis/indoors/command/cent_com
	name = "Command Rig - Level-1: Central Command Room"

/area/navalis/indoors/command/oft_duty_room
	name = "Command Rig - Level-1: Off-Duty Break Room"

/area/navalis/indoors/command/command_kitchen
	name = "Command Rig - Level-1: Command Kitchen"

/area/navalis/indoors/command/server_room
	name = "Command Rig - Level-1: Ancillery Backup Server Room"

/area/navalis/indoors/command/security
	name = "Command Rig - Level-1: Security Office"

/area/navalis/indoors/command/meeting_hall
	name = "Command Rig - Level-1: Meeting Hall"

/area/navalis/indoors/command/bathroom
	name = "Command Rig - Level-1: Bathroom"

/area/navalis/indoors/command/tertiary_comms
	name = "Command Rig - Level-1: Tertiary Communications"

/area/navalis/indoors/command/maintenance_port
	name = "Command Rig - Level-1: Port Maintenance"

/area/navalis/indoors/command/maintenance_starboard
	name = "Command Rig - Level-1: Starboard Maintenance"

/area/navalis/indoors/command/lower_deck
	name = "Command Rig - Level-0"

/area/navalis/indoors/command/lower_deck/starboard
	name = "Command Rig - Level-0: Starboard Access"

/area/navalis/indoors/command/lower_deck/port
	name = "Command Rig - Level-0: Port Access"

/area/navalis/indoors/command/lower_deck/sub_pen
	name = "Command Rig - Level-0: Sub-Pen"

/area/navalis/indoors/command/upper_deck
	name = "Command Rig - Level-2"

/area/navalis/indoors/command/upper_deck/server
	name = "Command Rig - Level-2: Primary Server Room"

/area/navalis/indoors/command/upper_deck/starboard
	name = "Command Rig - Level-2: Starboard Corridor"

/area/navalis/indoors/command/upper_deck/port
	name = "Command Rig - Level-2: Port Corridor"

/area/navalis/indoors/command/upper_deck/air_traffic_control
	name = "Command Rig - Level-2: Air Traffic Control"

/area/navalis/indoors/command/upper_deck/naval_traffic_control
	name = "Command Rig - Level-2: Naval Traffic Control"

/area/navalis/indoors/command/upper_deck/jani
	name = "Command Rig - Level-2: Janitorial Closet"

/area/navalis/indoors/logistic
	name = "Logistic Rig - Level-1:Indoors"
	icon_state = "quartstorage"

/area/navalis/indoors/logistic/Port_hallway
	name = "Logistic Rig - Level-1:Port-Hallway"

/area/navalis/indoors/logistic/workshop
	name = "Logistic Rig - Level-1:Workshop"

/area/navalis/indoors/logistic/mech_bay
	name = "Logistic Rig - Level-1:Mech-Bay"

/area/navalis/indoors/logistic/primary_storage
	name = "Logistic Rig - Level-1:Primary Storage"

/area/navalis/indoors/logistic/elevator
	name = "Logistic Rig - Level-1:Elevator"

/area/navalis/indoors/logistic/maintenance_port
	name = "Logistic Rig - Level-1:Port Maintenance"

/area/navalis/indoors/logistic/maintenance_starboard
	name = "Logistic Rig - Level-1:Starboard Maintenance"

/area/navalis/indoors/logistic/lower_deck
	name = "Logistic Rig - Level-0"

/area/navalis/indoors/logistic/lower_deck/fore
	name = "Logistic Rig - Level-0: Fore Section"

/area/navalis/indoors/logistic/lower_deck/port
	name = "Logistic Rig - Level-0: Port Corridor"

/area/navalis/indoors/logistic/lower_deck/maint
	name = "Logistic Rig - Level-0: Maintenance Control"

/area/navalis/indoors/logistic/lower_deck/fuel
	name = "Logistic Rig - Level-0: Fuel Pump Control"

/area/navalis/indoors/logistic/lower_deck/maint_store
	name = "Logistic Rig - Level-0: Maintenance Storage"

/area/navalis/indoors/logistic/upper_deck
	name = "Logistic Rig - Level-2"

/area/navalis/indoors/logistic/upper_deck/entrance
	name = "Logistic Rig - Level-2: Entrance"

/area/navalis/indoors/logistic/upper_deck/walkway
	name = "Logistic Rig - Level-2: Walkway"

/area/navalis/indoors/logistic/upper_deck/maint
	name = "Logistic Rig - Level-2: Maintenance"

/area/navalis/indoors/logistic/upper_deck/office
	name = "Logistic Rig - Level-2: Office"

/area/navalis/indoors/logistic/upper_deck/workshop
	name = "Logistic Rig - Level-2: Workshop"

/area/navalis/indoors/logistic/upper_deck/conduit
	name = "Logistic Rig - Level-2: Electrical Conduit"

/area/navalis/indoors/industrial
	name = "Industrial Rig - Indoors"
	icon_state = "mining_production"

/area/navalis/indoors/industrial/accessway
	name = "Industrial Rig - Sector-A: Accessway"

/area/navalis/indoors/industrial/power
	name = "Industrial Rig - Sector-B: Geothermal Reactor"

/area/navalis/indoors/industrial/refinery
	name = "Industrial Rig - Sector-C: Refinery"

/area/navalis/indoors/industrial/mining
	name = "Industrial Rig - Sector-D: Primary-Mining Rig"

/area/navalis/indoors/residential
	name = "Residential Rig - Indoors"
	icon_state = "fitness"
	ceiling = CEILING_REINFORCED_METAL

/area/navalis/indoors/residential/accessway
	name = "Residential Rig - Aft-Accessway"

/area/navalis/indoors/residential/port
	name = "Residential Rig - Port-Section"

/area/navalis/indoors/residential/starboard
	name = "Residential Rig - Starboard-Section"

/area/navalis/indoors/residential/kitchen
	name = "Residential Rig - Kitchen"

/area/navalis/indoors/residential/landing_pad
	name = "Residential Rig - Landing-Pad"

/area/navalis/indoors/residential/cafeteria
	name = "Residential Rig - Level 2: Cafeteria"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS

/area/navalis/indoors/residential/access
	name = "Residential Rig - Level 2: Starboard Access"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS

/area/navalis/indoors/residential/maint_stern
	name = "Residential Rig - Level 2: Stern Maintenance"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS

/area/navalis/indoors/residential/maint_starboard
	name = "Residential Rig - Level 2: Starboard Maintenance"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS

/area/navalis/outdoors/landing_zone_1
	name = "Navalis Platform 13 - Medical Emergency Response - Landing Zone One"
	icon_state = "medbay3"
	is_resin_allowed =  FALSE

/area/navalis/outdoors/landing_zone_1/under
	name = "LZ1 - Lower-Level Walkway"

/area/navalis/outdoors/landing_zone_2
	name = "Navalis Platform 13 - Logistics Delivery Area - Landing Zone Two"
	icon_state = "bunker01_engineering"
	is_resin_allowed =  FALSE

/area/navalis/outdoors/landing_zone_2/under
	name = "LZ2 - Lower-Level Walkway"

/area/navalis/indoors/landing_zone_2
	name = "LZ2 - Lower-Level Access"
	icon_state = "bunker01_engineering"
	is_resin_allowed =  FALSE

/area/navalis/outdoors/exterior
	name = "Exterior Walkway"
	icon_state = "eva"
	requires_power = FALSE

/area/navalis/outdoors/exterior/med_ext
	name = "Med-Sci Rig - Level-1: Exterior Walkway"

/area/navalis/outdoors/exterior/med_ext/lower
	name = "Med-Sci Rig - Level-0: Exterior Walkway"

/area/navalis/outdoors/exterior/med_ext/upper
	name = "Med-Sci Rig - Level-2: Exterior Walkway"

/area/navalis/outdoors/exterior/med_ext/roof
	name = "Medi-Sci Rig - Roof"

/area/navalis/outdoors/exterior/com_ext
	name = "Command Rig - Level-1: Exterior Walkway"

/area/navalis/outdoors/exterior/com_ext/lower
	name = "Command Rig - Level-0: Exterior Walkway"

/area/navalis/outdoors/exterior/com_ext/upper
	name = "Command Rig - Level-2: Exterior Walkway"

/area/navalis/outdoors/exterior/com_ext/roof
	name = "Command Rig - Roof"

/area/navalis/outdoors/exterior/log_ext
	name = "Logistical Rig - Level-1: Exterior Walkway"

/area/navalis/outdoors/exterior/log_ext/lower
	name = "Logistical Rig - Level-0: Exterior Walkway"

/area/navalis/outdoors/exterior/log_ext/upper
	name = "Logistical Rig - Level-2: Exterior Walkway"

/area/navalis/outdoors/exterior/log_ext/roof
	name = "Logistical Rig - Roof"

/area/navalis/outdoors/exterior/ind_ext
	name = "Industrial Rig - Level-1: Exterior Walkway"

/area/navalis/outdoors/comm_one
	name = "Navalis Platform 13 - Exterior Communications Relay"

/area/navalis/outdoors/exterior_xeno_only
	name = "Industrial Rig - Exterior Lattice Walkway"
	icon_state = "red2"
	flags_area = AREA_NOTUNNEL|AREA_CONTAINMENT|NOT_WEEDABLE|AREA_NO_PARA
	base_lighting_alpha = 35
	requires_power = FALSE

/area/navalis/outdoors/exterior_xeno_only/lz1
	name = "Medical / LZ1 - Exterior Lattice Walkway"

/area/navalis/outdoors/exterior_xeno_only/lz2
	name = "Medical / LZ2 - Exterior Lattice Walkway"

/area/navalis/outdoors/exterior_xeno_only/mining
	name = "Mining Rig - Exterior Lattice Walkway"

/area/navalis/indoors/xeno_growth
	name = "Unidentified Xeno-biological Growth: Industrial Area"
	icon_state = "eta_xeno"
	ceiling = CEILING_UNDERGROUND_ALLOW_CAS
	requires_power = FALSE

/area/navalis/indoors/xeno_growth/residential
	name = "Unidentified Xeno-biological Growth: Residential Entrance Area"

/area/navalis/indoors/ice_cavern
	name = "Iceberg Interior"
	icon_state = "medbay3"
	ceiling = CEILING_UNDERGROUND_ALLOW_CAS
	requires_power = FALSE

/area/white_antre
	name = "White Antre Research Facility"
	icon = 'icons/turf/hybrisareas.dmi'
	icon_state = "wydropship"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM

/area/white_antre/indoors
	name = "White Antre Research Facility - Indoors"
	icon_state = "cliff_blocked"
	ceiling = CEILING_METAL
	ambience_exterior = AMBIENCE_ANTRE
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/white_antre/outdoors
	name = "White Antre Research Facility - Outdoors"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	soundscape_playlist = SCAPE_PL_LV759_OUTDOORS
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_interval = 25
	always_unpowered = TRUE

/area/white_antre/oob
	name = "Out Of Bounds"
	icon_state = "oob"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL
	minimap_color = MINIMAP_AREA_OOB
	requires_power = FALSE

/area/white_antre/oob/outdoors
	ceiling = CEILING_NO_PROTECTION

/area/white_antre/landing_zone
	name = "White Antre Research Facility - Supply Pad - Landing Zone"
	icon_state = "lz"
	soundscape_playlist = SCAPE_PL_LV759_OUTDOORS
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
	requires_power = FALSE
	minimap_color = MINIMAP_AREA_COLONY_SPACE_PORT

/area/white_antre/landing_zone/roof
	name = "White Antre Research Facility - Supply Pad - Landing Zone"
	icon_state = "lz"
	ceiling = CEILING_METAL
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/white_antre/indoors/pmc_dropship
	name = "PMC-DS-1 'Cash Flow'"
	icon_state = "WYSpaceport"
	ambience_exterior = AMBIENCE_SHIP_ALT
	minimap_color = MINIMAP_AREA_COLONY_SPACE_PORT

/area/white_antre/outdoors/north_field
	name = "Snow Fields - North"
	icon_state = "caves_north"
	minimap_color = MINIMAP_SNOW

/area/white_antre/outdoors/south_field
	name = "Snow Fields - South"
	icon_state = "caves_south"
	minimap_color = MINIMAP_SNOW

/area/white_antre/outdoors/south_field/under_cover
	ceiling = CEILING_UNDERGROUND_ALLOW_CAS

/area/white_antre/outdoors/road_west
	name = "Snow Fields - Road West"
	icon_state = "meridian_factory"
	minimap_color = MINIMAP_DIRT

/area/white_antre/outdoors/road_east
	name = "Snow Fields - Road East"
	icon_state = "meridian"
	minimap_color = MINIMAP_DIRT

/area/white_antre/outdoors/path_north
	name = "Snow Fields - Offroad North"
	icon_state = "mining"
	minimap_color = MINIMAP_MARS_DIRT

/area/white_antre/outdoors/facility_exterior
	name = "White Antre - Western Facility Exterior"
	icon_state = "police_line"
	minimap_color = MINIMAP_AREA_CELL_VIP

/area/white_antre/indoors/exterior
	name = "White Antre Research Facility - Exterior"
	ceiling = CEILING_METAL
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR
	minimap_color = MINIMAP_SNOW

/area/white_antre/indoors/exterior/checkpoint
	name = "White Antre Research Facility - Exterior Checkpoint"
	icon_state = "security_checkpoint_west"

/area/white_antre/indoors/exterior/ext_relay_north
	name = "White Antre Research Facility - Exterior Relay North"
	icon_state = "power0"

/area/white_antre/indoors/exterior/ext_relay_south
	name = "White Antre Research Facility - Exterior Relay South"
	icon_state = "power0"

/area/white_antre/indoors/exterior/prefab_1
	name = "Exterior Storage Pod - West"
	icon_state = "mining"
	minimap_color = MINIMAP_DIRT

/area/white_antre/indoors/exterior/prefab_2
	name = "Exterior Storage Pod - North"
	icon_state = "mining"
	minimap_color = MINIMAP_DIRT

/area/white_antre/indoors/exterior/prefab_3
	name = "Exterior Storage Pod - South"
	icon_state = "mining"
	minimap_color = MINIMAP_DIRT

/area/white_antre/indoors/exterior/prefab_4
	name = "Exterior Storage Pod - North-West"
	icon_state = "mining"
	minimap_color = MINIMAP_DIRT

/area/white_antre/indoors/main_level
	name = "White Antre Research Facility - Ground Level"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM

/area/white_antre/indoors/main_level/west_corridor
	name = "White Antre Research Facility - West Corridor - Ground"
	icon_state = "colonystreets_west"

/area/white_antre/indoors/main_level/east_corridor
	name = "White Antre Research Facility - East Corridor - Ground"
	icon_state = "colonystreets_east"

/area/white_antre/indoors/main_level/engineering
	name = "White Antre Research Facility - Engineering - Ground"
	icon_state = "power0"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING

/area/white_antre/indoors/main_level/security
	name = "White Antre Research Facility - Security - Ground"
	icon_state = "security_checkpoint"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY_MARSHALLS

/area/white_antre/indoors/main_level/dorms
	name = "White Antre Research Facility - Dormitory - Ground"
	icon_state = "apartments"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY

/area/white_antre/indoors/main_level/research
	name = "White Antre - Xenobiological Research - Ground"
	icon_state = "apartments"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_RESEARCH

/area/white_antre/indoors/main_level/weapons
	name = "White Antre - Weapons Research - Ground"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_SEC

/area/white_antre/indoors/main_level/north_containment
	name = "White Antre - K-Series Containment Holding Bay - Ground"
	icon_state = "tumor1"
	minimap_color = MINIMAP_AREA_DERELICT

/area/white_antre/indoors/main_level/north_containment_hive
	name = "White Antre - K-Series Containment Zone - Ground"
	icon_state = "tumor2"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	minimap_color = MINIMAP_AREA_DERELICT
	base_muffle = MUFFLE_MEDIUM
	ceiling_muffle = FALSE

/area/white_antre/indoors/main_level/south_containment
	name = "White Antre - Unused Containment Holding Bay - Ground"
	icon_state = "tumor1"
	minimap_color = MINIMAP_AREA_DERELICT

/area/white_antre/indoors/main_level/south_containment_hive
	name = "White Antre - Unused Containment Zone - Ground"
	icon_state = "tumor2"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	minimap_color = MINIMAP_AREA_RESEARCH
	base_muffle = MUFFLE_MEDIUM
	ceiling_muffle = FALSE

/area/white_antre/indoors/main_level/east_containment
	name = "White Antre - Prime Hive Containment Holding Bay - Ground"
	icon_state = "tumor1"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	base_muffle = MUFFLE_MEDIUM
	ceiling_muffle = FALSE

/area/white_antre/indoors/main_level/east_containment_hive
	name = "White Antre - Prime Hive Containment Zone - Ground"
	icon_state = "tumor2"
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	base_muffle = MUFFLE_MEDIUM
	ceiling_muffle = FALSE

/area/white_antre/indoors/underground_level
	name = "White Antre Research Facility - Underground"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_ENGI

/area/white_antre/indoors/underground_level/west_maint
	name = "White Antre Research Facility - West Maintenance - Underground"
	icon_state = "maints"

/area/white_antre/indoors/underground_level/east_maint
	name = "White Antre Research Facility - East Maintenance - Underground"
	icon_state = "maints"

/area/white_antre/indoors/underground_level/gonzo
	name = "Gonzo's hide-out"
	icon_state = "cliff_blocked"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL
	minimap_color = MINIMAP_AREA_OOB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	requires_power = FALSE
	ceiling_muffle = FALSE

/area/white_antre/indoors/upper_level
	name = "White Antre - Upper Level"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM

/area/white_antre/indoors/upper_level/west_corridor
	name = "White Antre - West Corridor - Upper"
	icon_state = "colonystreets_west"

/area/white_antre/indoors/upper_level/east_corridor
	name = "White Antre - East Corridor - Upper"
	icon_state = "colonystreets_east"

/area/white_antre/indoors/upper_level/central_corridor
	name = "White Antre - Central Corridor - Upper"
	icon_state = "colonystreets_north"

/area/white_antre/indoors/upper_level/medical
	name = "White Antre - Medbay - Upper"
	icon_state = "medical_lz1"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY_HOSPITAL

/area/white_antre/indoors/upper_level/canteen
	name = "White Antre - Canteen - Upper"
	icon_state = "pizza"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY

/area/white_antre/indoors/upper_level/records
	name = "White Antre - Records - Upper"
	icon_state = "wyoffice"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COLONY

/area/white_antre/indoors/upper_level/simian_storage
	name = "White Antre - Simian Storage - Upper"
	icon_state = "WYSpaceportcargo"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_RESEARCH

/area/white_antre/indoors/upper_level/central_command
	name = "White Antre - Central Command - Upper"
	icon_state = "wardens"
	minimap_color = MINIMAP_AREA_COMMAND

/area/white_antre/indoors/upper_level/director_office
	name = "White Antre - Director Kandinsky's Quarters - Upper"
	icon_state = "tumor0-deep"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_COMMAND_CAVE

/area/white_antre/indoors/upper_level/ancillery_storage
	name = "White Antre - Ancillery Storage - Upper"
	icon_state = "WYSpaceportcargo"
	minimap_color = MINIMAP_AREA_GLASS

/area/white_antre/indoors/upper_level/payroll
	name = "White Antre - Payroll - Upper"
	icon_state = "disco"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_MINING

/area/white_antre/indoors/upper_level/xenobio
	name = "White Antre - Xenobiological Research - Upper"
	icon_state = "medical"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_RESEARCH

/area/white_antre/indoors/upper_level/east_overwatch
	name = "White Antre - East Containment Overwatch - Upper"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR
	minimap_color = MINIMAP_AREA_HYBRISARESEARCH

/area/white_antre/indoors/upper_level/north_overwatch
	name = "White Antre - North Containment Overwatch - Upper"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_HYBRISARESEARCH

/area/white_antre/indoors/upper_level/south_overwatch
	name = "White Antre - South Containment Overwatch - Upper"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_ANTRE_ADJACENT
	minimap_color = MINIMAP_AREA_HYBRISARESEARCH

/area/pudong
	name = "MI264 - Pudong Bunker"
	icon_state = "lv-626"
	can_build_special = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	powernet_name = "pudong"

/area/pudong/base
	name = "Pudong Bunker Base"
	ceiling = CEILING_REINFORCED_METAL
	sound_environment = SOUND_ENVIRONMENT_ROOM
	soundscape_playlist = AMBIENCE_SHIP
	powernet_name = "base"
/area/pudong/caves
	name = "Pudong Caves"
	ceiling = CEILING_UNDERGROUND_BLOCK_CAS
	ambience_exterior = AMBIENCE_CAVE
	soundscape_playlist = SCAPE_PL_CAVE
	base_muffle = MUFFLE_HIGH
	temperature = T0C
/area/pudong/exterior
	name = "Pudong Exterior"
	soundscape_playlist = SCAPE_PL_WIND
	temperature = ICE_COLONY_TEMPERATURE
/area/pudong/oob
	name = "OOB"
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS
	requires_power = FALSE

/area/pudong/base/maintenance
	name = "Pudong - Maintenance"
	icon_state = "yellow"
/area/pudong/base/power
	name = "Pudong - Power Station"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	soundscape_playlist = SCAPE_PL_ENG
/area/pudong/base/engi
	name = "Pudong - Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI
	soundscape_playlist = SCAPE_PL_ENG
/area/pudong/base/server
	name = "Pudong - Server Room"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND
	soundscape_playlist = SCAPE_PL_CIC
/area/pudong/base/quarters
	name = "Pudong - Quarters"
	icon_state = "green"
/area/pudong/base/cryo
	name = "Pudong - Cryogenic Storage"
	icon_state = "cryo"
/area/pudong/base/galley
	name = "Pudong - Galley"
	icon_state = "green"
/area/pudong/base/platoon
	name = "Pudong - Platoon Commander's Office"
	icon_state = "green"
/area/pudong/base/briefing
	name = "Pudong - Briefing Hall"
	icon_state = "green"
/area/pudong/base/armory
	name = "Pudong - Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC
/area/pudong/base/nco
	name = "Pudong - Sergeants' Office"
	icon_state = "security"
/area/pudong/base/treatment
	name = "Pudong - Treatment Space"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
/area/pudong/base/hangar
	name = "Pudong - Hangar Space"
	icon_state = "purple"
/area/pudong/base/bunker
	name = "Pudong - Bunker System"
	icon_state = "red"

/area/pudong/caves/main
	name = "Pudong Caves"
	icon_state = "cave"
/area/pudong/caves/depths
	name = "Pudong Depths"
	icon_state = "cave"

/area/pudong/exterior/cliff
	name = "Pudong Clifface"
	icon_state = "north"
/area/pudong/exterior/cavern
	name = "Pudong Caverns"
	icon_state = "east"

/area/pudong/oob/buttons
	name = "Out of Bounds"
	icon_state = "mech"
	requires_power = FALSE

/area/tyrargo

	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM

/area/tyrargo/indoors
	name = "Tyrargo - Indoors"
	icon_state = "unknown"
	ceiling = CEILING_METAL
	ambience_exterior = AMBIENCE_TYRARGO_CITY

/area/tyrargo/outdoors
	name = "Tyrargo - Outdoors"
	icon_state = "unknown"
	ceiling = CEILING_NONE
	ambience_exterior = AMBIENCE_TYRARGO_CITY

/area/tyrargo/underground
	name = "Tyrargo - Underground"
	icon_state = "unknown"
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS
	ambience_exterior = AMBIENCE_TYRARGO_SEWER_CITY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ceiling_muffle = FALSE

/area/tyrargo/oob
	name = "Out Of Bounds"
	icon_state = "unknown"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL
	minimap_color = MINIMAP_AREA_OOB
	requires_power = FALSE
	ambience_exterior = AMBIENCE_TYRARGO_CITY

/area/tyrargo/oob/outdoors
	ceiling = CEILING_NO_PROTECTION

/area/tyrargo/landing_zone_1
	name = "Firebase Charlie - Landing Zone One"
	icon_state = "yellow"
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	requires_power = FALSE
	ambience_exterior = AMBIENCE_TYRARGO_CITY

/area/tyrargo/landing_zone_1/no_tunnel
	icon_state = "dk_yellow"
	flags_area = AREA_NOTUNNEL

/area/tyrargo/landing_zone_1/ceiling
	ceiling = CEILING_METAL

/area/tyrargo/landing_zone_1/underground
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS

/area/tyrargo/landing_zone_1/west_trench
	name = "Firebase Charlie - Western Trench"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_CONTESTED_ZONE

/area/tyrargo/landing_zone_1/north_trench
	name = "Firebase Charlie - Northern Trench"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_CONTESTED_ZONE

/area/tyrargo/landing_zone_1/no_mans_land
	name = "Firebase Charlie - No Man's Land"
	icon_state = "security_sub"
	minimap_color = MINIMAP_LAVA

/area/tyrargo/landing_zone_1/comms
	name = "Firebase Charlie - Communications Control Bunker"
	requires_power = TRUE

/area/tyrargo/landing_zone_2
	name = "USASF Airbase Anderson - Landing Zone Two"
	icon_state = "yellow"
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	requires_power = FALSE
	ambience_exterior = AMBIENCE_TYRARGO_CITY

/area/tyrargo/landing_zone_2/road
	name = "USASF Airbase Anderson - Road"
	icon_state = "shuttle3"
	minimap_color = MINIMAP_AREA_SHIP

/area/tyrargo/landing_zone_2/strip
	name = "USASF Airbase Anderson - Airstrip"
	icon_state = "shuttle3"
	minimap_color = MINIMAP_AREA_COMMS
	flags_area = AREA_NOTUNNEL

/area/tyrargo/landing_zone_2/no_tunnel
	icon_state = "dk_yellow"
	flags_area = AREA_NOTUNNEL

/area/tyrargo/landing_zone_2/ceiling
	ceiling = CEILING_METAL

/area/tyrargo/landing_zone_2/east_trench
	name = "USASF Airbase Anderson - North-East Trench"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/tyrargo/outdoors/outskirts_road
	name = "Outskirts Road"
	icon_state = "shuttle2"
	minimap_color = MINIMAP_AREA_SHIP
	requires_power = FALSE

/area/tyrargo/outdoors/outskirts_road/west
	name = "Outskirts Road - West"

/area/tyrargo/outdoors/outskirts_road/central
	name = "Outskirts Road - Central"

/area/tyrargo/outdoors/outskirts_road/east
	name = "Outskirts Road - East"

/area/tyrargo/outdoors/colony_streets
	name = "Colony Streets"
	icon_state = "shuttle3"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY_STREETS
	requires_power = FALSE

/area/tyrargo/outdoors/colony_streets/north_west
	name = "Colony Streets - North-West"

/area/tyrargo/outdoors/colony_streets/west
	name = "Colony Streets - West"

/area/tyrargo/outdoors/colony_streets/south_west
	name = "Colony Streets - South-West"

/area/tyrargo/outdoors/colony_streets/north
	name = "Colony Streets - North"

/area/tyrargo/outdoors/colony_streets/north_east
	name = "Colony Streets - North-East"

/area/tyrargo/outdoors/colony_streets/east
	name = "Colony Streets - East"

/area/tyrargo/outdoors/colony_streets/south_east
	name = "Colony Streets - South-East"

/area/tyrargo/outdoors/colony_exterior
	name = "Colony Exterior"
	icon_state = "mining"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_JUNGLE
	requires_power = FALSE

/area/tyrargo/outdoors/colony_exterior/north_west
	name = "Colony Exterior - North-West"

/area/tyrargo/outdoors/colony_exterior/west
	name = "Colony Exterior - West"

/area/tyrargo/outdoors/colony_exterior/south_west
	name = "Colony Exterior - South-West"

/area/tyrargo/outdoors/colony_exterior/north
	name = "Colony Exterior - North"

/area/tyrargo/outdoors/colony_exterior/north_east
	name = "Colony Exterior - North-East"

/area/tyrargo/outdoors/colony_exterior/east
	name = "Colony Exterior - East"

/area/tyrargo/outdoors/colony_exterior/south_east
	name = "Colony Exterior - South-East"

/area/tyrargo/outdoors/walkway_access
	name = "External Access Walkway"
	icon_state = "showroom"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_CELL_HIGH
	requires_power = FALSE

/area/tyrargo/outdoors/walkway_access/power_sewer
	name = "External Walkway - Power/Sewer"

/area/tyrargo/outdoors/walkway_access/sewer_apart
	name = "External Walkway - Sewer/Apartments"

/area/tyrargo/outdoors/walkway_access/power_apart
	name = "External Walkway - Power/Apartments"

/area/tyrargo/outdoors/walkway_access/apart_gararge
	name = "External Walkway - Apartments/Gararge"

/area/tyrargo/outdoors/walkway_access/gararge_admin
	name = "External Walkway - Gararge/Admin"

/area/tyrargo/outdoors/walkway_access/museum_central
	name = "External Walkway - Museum"

/area/tyrargo/indoors/apartment
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM
	icon_state = "quart"

/area/tyrargo/indoors/apartment/north_ground
	name = "Standfeld Apartment Complex - North-Ground"

/area/tyrargo/indoors/apartment/north_upper
	name = "Standfeld Apartment Complex - North-Upper"

/area/tyrargo/indoors/apartment/south_ground
	name = "Standfeld Apartment Complex - South-Ground"

/area/tyrargo/indoors/apartment/south_upper
	name = "Standfeld Apartment Complex - South-Upper"

/area/tyrargo/indoors/bar
	minimap_color = MINIMAP_AREA_CELL_VIP
	icon_state = "bar"

/area/tyrargo/indoors/bar/ground
	name = "Last Throw Bar - Ground"

/area/tyrargo/indoors/bar/upper
	name = "Last Throw Bar - Upper"

/area/tyrargo/indoors/bar/upper/external
	name = "Last Throw Bar - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/engineering
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING
	icon_state = "maint_engine"

/area/tyrargo/indoors/engineering/ground
	name = "Sector F: Power Plant - Ground"

/area/tyrargo/indoors/engineering/upper
	name = "Sector F: Power Plant - Upper"

/area/tyrargo/indoors/engineering/upper/external
	name = "Sector F: Power Plant - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/sewer_treatment
	minimap_color = MINIMAP_AREA_HYBRISARESEARCH
	icon_state = "explored"

/area/tyrargo/indoors/sewer_treatment/ground
	name = "Sewer Treatment Plant - Ground"

/area/tyrargo/indoors/sewer_treatment/upper
	name = "Sewer Treatment Plant - Upper"

/area/tyrargo/indoors/sewer_treatment/lower
	name = "Sewer Treatment Plant - Underground Access"

/area/tyrargo/indoors/sewer_treatment/upper/external
	name = "Sewer Treatment Plant - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/comms
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING
	icon_state = "ai_upload"

/area/tyrargo/indoors/comms/ground
	name = "Ancillery Communications System - Ground"

/area/tyrargo/indoors/comms/upper
	name = "Ancillery Communications System - Upper"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/gararge
	minimap_color = MINIMAP_AREA_CELL_MED
	icon_state = "HH_Mines"

/area/tyrargo/indoors/gararge/ground
	name = "Busters Car Repair - Ground"

/area/tyrargo/indoors/gararge/upper
	name = "Busters Car Repair - Ground"
	ceiling = CEILING_NONE

/area/tyrargo/indoors/gararge/upper/external
	name = "Busters Car Repair - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/mall
	name = "Tyrargo Wesfeld Mall - Ground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM
	icon_state = "HH_Mines"

/area/tyrargo/indoors/mall/upper
	name = "Tyrargo Wesfeld Mall - Upper"

/area/tyrargo/indoors/mall/upper/external
	name = "Tyrargo Wesfeld Mall - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/admin
	minimap_color = MINIMAP_AREA_COLONY_SPACE_PORT
	icon_state = "storage"

/area/tyrargo/indoors/admin/ground
	name = "Sector F: Government Administration - Ground"

/area/tyrargo/indoors/admin/upper
	name = "Sector F: Government Administration - Upper"

/area/tyrargo/indoors/admin/upper/external
	name = "Sector F: Government Administration - Upper-External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/market
	minimap_color = MINIMAP_AREA_COLONY_HOSPITAL
	icon_state = "HH_Panic"
/area/tyrargo/indoors/market/ground
	name = "Farmers Market - Ground"

/area/tyrargo/indoors/market/upper
	name = "Farmers Market - Upper"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/security
	minimap_color = MINIMAP_AREA_COLONY_MARSHALLS
	icon_state = "HH_Basement"

/area/tyrargo/indoors/security/ground
	name = "Sector F: Marshals Outpost - Ground"

/area/tyrargo/indoors/security/upper
	name = "Sector F: Marshals Outpost - Upper"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/museum_storage
	minimap_color = MINIMAP_AREA_HYBRISARESEARCH
	icon_state = "auxstorage"

/area/tyrargo/indoors/museum_storage/ground
	name = "Museum Carpark - Ground"

/area/tyrargo/indoors/museum_storage/upper
	name = "Museum Carpark - Upper"

/area/tyrargo/indoors/museum_storage/upper/external
	name = "Museum Carpark - Upper/External"
	ceiling = CEILING_NONE
	requires_power = FALSE

/area/tyrargo/indoors/power_substation_outskirt
	name = "Power Substation: West Outskirts"
	icon_state = "maint_engine"
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING

/area/tyrargo/outdoors/outskirts
	name = "Outskirts"
	icon_state = "green"
	minimap_color = MINIMAP_AREA_JUNGLE
	requires_power = FALSE

/area/tyrargo/outdoors/outskirts/north_west_usasf
	name = "Outskirts  - Worth-West Anderson Airbase"

/area/tyrargo/outdoors/outskirts/north_east_usasf
	name = "Outskirts  - North-East Anderson Airbase"

/area/tyrargo/outdoors/outskirts/north_east_usasf/weedkiller

/area/tyrargo/outdoors/outskirts/central
	name = "Outskirts  - Central"

/area/tyrargo/outdoors/outskirts/central/landing_zone

/area/tyrargo/outdoors/outskirts/east
	name = "Outskirts  - East"

/area/tyrargo/outdoors/outskirts/river
	name = "Outskirts  - River"

/area/tyrargo/outdoors/outskirts/fsb_north
	name = "Fire Support Base - North"
	icon_state = "security_sub"
	minimap_color = MINIMAP_AREA_DERELICT
	requires_power = TRUE

/area/tyrargo/outdoors/outskirts/fsb_south
	name = "Fire Support Base - South"
	icon_state = "security_sub"
	minimap_color = MINIMAP_AREA_DERELICT
	requires_power = TRUE

/area/tyrargo/outdoors/outskirts/east_trench
	name = "Fire Support Base - Eastern Trench"
	icon_state = "ass_line"

/area/tyrargo/outdoors/outskirts/no_mans_land
	name = "Fire Support Base - No Man's Land"
	icon_state = "security_sub"
	minimap_color = MINIMAP_LAVA

/area/tyrargo/indoors/bunker
	name = "Surface Bunker"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	base_muffle = MUFFLE_LOW

/area/tyrargo/indoors/bunker/north
	name = "Surface Bunker - Alpha"

/area/tyrargo/indoors/bunker/north_south
	name = "Surface Bunker - Bravo"

/area/tyrargo/indoors/bunker/central
	name = "Surface Bunker - Charlie"

/area/tyrargo/indoors/bunker/central_south
	name = "Surface Bunker - Delta"

/area/tyrargo/underground/bunker
	name = "Underground Bunker"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/tyrargo/underground/bunker/north
	name = "Bunker Network - Sector Tango-12"

/area/tyrargo/underground/bunker/south
	name = "Bunker Network - Sector Epsilon-29"

/area/tyrargo/underground/bunker/ammo_dump_entrance
	name = "USASF Airbase Anderson - Underground Ammo Dump"

/area/tyrargo/underground/bunker/ammo_dump_connection
	name = "USASF Airbase Anderson - Underground Cave Network"
	requires_power = FALSE

/area/tyrargo/underground/sewer
	name = "City Sewer"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_COLONY_STREETS

/area/tyrargo/underground/sewer/south
	name = "City Sewers - South"

/area/tyrargo/underground/sewer/north
	name = "City Sewers - North"

/area/tyrargo/underground/oob_area
	name = "Disconnected Underground Bunker Network"
	minimap_color = MINIMAP_AREA_OOB
	icon_state = "Holodeck"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL
	requires_power = FALSE

/area/tyrargo/underground/engineering
	name = "Sector F: Power Plant - Underground"
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING
	icon_state = "maint_engine"
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/tyrargo/underground/apartment
	name = "Standfeld Apartment Complex - Underground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM
	icon_state = "quart"
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/tyrargo/underground/mall
	name = "Tyrargo Wesfeld Mall - Underground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM
	icon_state = "HH_Mines"
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/tyrargo/underground/museum_carpark
	name = "Museum Carpark - Underground"
	minimap_color = MINIMAP_AREA_COLONY_RESANDCOM
	icon_state = "auxstorage"
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/tyrargo/underground/power_substation
	name = "Sewer - Power-Routing Substation"
	minimap_color = MINIMAP_AREA_COLONY_ENGINEERING
	icon_state = "maint_engine"
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR

/area/tyrargo/indoors/saipan
	name = "Dropship Saipan"
	minimap_color = MINIMAP_SQUAD_ECHO
	icon_state = "Holodeck"
	ceiling = CEILING_UNDERGROUND_METAL_ALLOW_CAS
	requires_power = FALSE

/area/tyrargo/outdoors/army_staging
	name = "32nd Armor Division: Staging Area - Southern Outskirts"
	icon_state = "Holodeck"
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL
	minimap_color = MINIMAP_AREA_SEC_CAVE
	ceiling = CEILING_MAX
	ceiling_muffle = FALSE
	requires_power = FALSE

/area/bigredv2/secondfloor
	name = "\improper Solaris Ridge Z2 Parent"
	icon_state = "garden"
	ceiling = CEILING_NONE

/area/bigredv2/secondfloor/indoors
	name = "\improper Solaris Ridge Z2 Indoors Parent"
	icon_state = "garden"
	ceiling = CEILING_METAL

/area/bigredv2/secondfloor/rooftops
	name = "\improper Solaris Ridge Second Story Rooftops"
	icon_state = "garden"
	ceiling = CEILING_NONE

/area/bigredv2/secondfloor/indoors/lz1
	name = "\improper Solaris Ridge Second Story - Spaceport"
	icon_state = "green"

/area/bigredv2/secondfloor/indoors/medical
	name = "\improper Solaris Ridge Second Story - Hospital"
	icon_state = "CMO"

/area/bigredv2/secondfloor/indoors/operations
	name = "\improper Solaris Ridge Second Story - Admin"
	icon_state = "bridge"

/area/bigredv2/secondfloor/indoors/cargo
	name = "\improper Solaris Ridge Second Story - Cargo"
	icon_state = "storage"

/area/bigredv2/secondfloor/indoors/filtration
	name = "\improper Solaris Ridge Second Story - Filtration Building"
	icon_state = "atmos"

/area/bigredv2/secondfloor/indoors/dorms
	name = "\improper Solaris Ridge Second Story - Dorms"
	icon_state = "fitness"

/area/bigredv2/secondfloor/indoors/office
	name = "\improper Solaris Ridge Second Story - Offices"
	icon_state = "explored"

/area/bigredv2/secondfloor/indoors/sec
	name = "\improper Solaris Ridge Second Story - Marshal Office"
	icon_state = "explored"
