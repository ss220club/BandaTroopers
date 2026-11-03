GLOBAL_LIST_EMPTY(gear_datums_by_category)
GLOBAL_LIST_EMPTY_TYPED(gear_datums_by_name, /datum/gear)

/proc/populate_gear_list()
	var/datum/gear/G
	for(var/gear_type in subtypesof(/datum/gear))
		G = new gear_type()
		if(!G.display_name)
			continue //Skipping parent types that are not actual items.
		if(!G.category)
			log_debug("Improper gear datum: [gear_type].")
			continue
		if(G.display_name in GLOB.gear_datums_by_name)
			log_debug("Duplicate gear datum name: [G.display_name].")
			continue
		if(!G.special_conditions())
			continue
		LAZYSET(GLOB.gear_datums_by_category[G.category], "[G.display_name] [G.cost == 1 ? "(1 point)" : "([G.cost] points)"]", G)
		GLOB.gear_datums_by_name[G.display_name] = G

/datum/gear
	var/display_name  // Name/index.
	var/category //Used for sorting in the loadout selection.
	var/obj/item/path  // Path to item.
	var/cost = 2 // Number of points used.
	var/slot // Slot to equip to, if any.
	var/list/allowed_roles   // Roles that can spawn with this item.
	var/list/allowed_origins

/datum/gear/proc/special_conditions()
	return TRUE

/*
//================================================
				Eyewear
//================================================
*/

/datum/gear/eyewear
	category = "Eyewear"
	slot = WEAR_EYES

// civilian

/datum/gear/eyewear/aviators
	display_name = "Aviator shades"
	path = /obj/item/clothing/glasses/sunglasses/aviator
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/eyewear/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/eyewear/eyepatch/green
	display_name = "Green Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch/green

/datum/gear/eyewear/prescription_glasses
	display_name = "Prescription Glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/eyewear/prescription_glasses_alt
	display_name = "Rounded Prescription Glasses"
	path = /obj/item/clothing/glasses/regular/hippie

/datum/gear/eyewear/sunglasses
	display_name = "Sunglasses"
	path = /obj/item/clothing/glasses/sunglasses

/datum/gear/eyewear/prescription_sunglasses
	display_name = "Prescription sunglasses"
	path = /obj/item/clothing/glasses/sunglasses/prescription

/datum/gear/eyewear/kutjevo
	display_name = "N95Z goggles"
	path = /obj/item/clothing/glasses/kutjevo/alt
	allowed_origins = NON_UPP_ORIGINS

// military

/datum/gear/eyewear/rpg_glasses
	display_name = "Marine RPG Glasses"
	path = /obj/item/clothing/glasses/regular
	allowed_origins = USCM_ORIGINS

/datum/gear/eyewear/prescription_goggles
	display_name = "Prescription ballistic goggles"
	path = /obj/item/clothing/glasses/mgoggles/prescription

/datum/gear/eyewear/goggles_black/prescription
	display_name = "Prescription ballistic goggles, sun-shaded"
	path = /obj/item/clothing/glasses/mgoggles/black/prescription

/datum/gear/eyewear/goggles_orange/prescription
	display_name = "Prescription ballistic goggles, laser-shaded (brown)"
	path = /obj/item/clothing/glasses/mgoggles/orange/prescription

/datum/gear/eyewear/goggles_green/prescription
	display_name = "Prescription ballistic goggles, laser-shaded (green)"
	path = /obj/item/clothing/glasses/mgoggles/green/prescription

/datum/gear/eyewear/bimex_shades
	display_name = "BiMex Polarized Shades"
	path = /obj/item/clothing/glasses/sunglasses/big
	allowed_origins = USCM_ORIGINS

/datum/gear/eyewear/bimex_shades_orange
	display_name = "BiMex Tactical Shades"
	path = /obj/item/clothing/glasses/sunglasses/big/orange
	allowed_origins = USCM_ORIGINS

/datum/gear/eyewear/bimex_shades_classic
	display_name = "BiMex Classic Shades"
	path = /obj/item/clothing/glasses/sunglasses/big/classic
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/eyewear/pilot_visor_black
	display_name = "Pilot visor, black"
	path = /obj/item/device/helmet_visor/po_visor/marine
	allowed_origins = USCM_ORIGINS

/datum/gear/eyewear/pilot_visor_yellow
	display_name = "Pilot visor, yellow"
	path = /obj/item/device/helmet_visor/po_visor/marine/yellow
	allowed_origins = USCM_ORIGINS

// resctricted

/datum/gear/eyewear/med_visor_prescription
	display_name = "Prescription HealthMate HUD"
	path = /obj/item/clothing/glasses/hud/health/prescription
	cost = 4
	allowed_roles = list(JOB_SQUAD_MEDIC, JOB_SQUAD_MEDIC_UPP, JOB_SQUAD_MEDIC_FORECON, JOB_SQUAD_MEDIC_FORECON_UPP, JOB_PMCPLAT_MEDIC, JOB_PMCPLAT_SMALL_MEDIC, JOB_TWE_RMC_MEDIC, JOB_SQUAD_LEADER, JOB_SQUAD_LEADER_UPP, JOB_SQUAD_LEADER_FORECON_UPP, JOB_PMCPLAT_LEADER, JOB_PMCPLAT_SMALL_LEADER, JOB_SQUAD_LEADER_FORECON, JOB_TWE_RMC_TROOPLEADER, JOB_SO, JOB_SO_UPP, JOB_PMCPLAT_OW, JOB_TWE_RMC_LIEUTENANT)

/*
//================================================
				Masks & Scarves
//================================================
*/

/datum/gear/mask
	category = "Masks and scarves"
	slot = WEAR_FACE
	cost = 2

// balaclavas

/datum/gear/mask/coif
	display_name = "Coif"
	path = /obj/item/clothing/mask/rebreather/scarf

/datum/gear/mask/balaclava_black
	display_name = "Balaclava, black"
	path = /obj/item/clothing/mask/balaclava

/datum/gear/mask/balaclava_green
	display_name = "Balaclava, green"
	path = /obj/item/clothing/mask/balaclava/tactical

/datum/gear/mask/balaclava_threehole
	display_name = "Balaclava, three-hole"
	path = /obj/item/clothing/mask/balaclava/threehole
	allowed_origins = UPP_ORIGINS

/datum/gear/mask/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/mask/uscm/balaclava_green
	display_name = "USCM balaclava, green"
	path = /obj/item/clothing/mask/rebreather/scarf/green

/datum/gear/mask/uscm/balaclava_grey
	display_name = "USCM balaclava, grey"
	path = /obj/item/clothing/mask/rebreather/scarf/gray

/datum/gear/mask/uscm/balaclava_tan
	display_name = "USCM balaclava, tan"
	path = /obj/item/clothing/mask/rebreather/scarf/tan

/datum/gear/mask/uscm/skull_balaclava_blue
	display_name = "USCM balaclava, blue skull"
	path = /obj/item/clothing/mask/rebreather/skull
	cost = 4 //same as skull facepaint

/datum/gear/mask/uscm/skull_balaclava_black
	display_name = "USCM balaclava, black skull"
	path = /obj/item/clothing/mask/rebreather/skull/black
	cost = 4

// face wraps

/datum/gear/mask/face_wrap_black
	display_name = "Face wrap, black"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/black

/datum/gear/mask/face_wrap_green
	display_name = "Face wrap, green"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/green

/datum/gear/mask/face_wrap_grey
	display_name = "Face wrap, grey"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask

/datum/gear/mask/face_wrap_red
	display_name = "Face wrap, red"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/red

/datum/gear/mask/face_wrap_tan
	display_name = "Face wrap, tan"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/tan

/datum/gear/mask/face_wrap_bravo
	display_name = "Face wrap, yellow"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/bravo

/datum/gear/mask/face_wrap_charlie
	display_name = "Face wrap, purple"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/charlie

/datum/gear/mask/face_wrap_delta
	display_name = "Face wrap, blue"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/delta

/datum/gear/mask/face_wrap_echo
	display_name = "Face wrap, cyan green"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/echo

/datum/gear/mask/face_wrap_usa
	display_name = "Face wrap, USA"
	path = /obj/item/clothing/mask/rebreather/scarf/tacticalmask/usa
	allowed_origins = USCM_ORIGINS

// scarfs

/datum/gear/mask/scarf_black
	display_name = "Scarf, black"
	path = /obj/item/clothing/mask/tornscarf/black

/datum/gear/mask/scarf_desert
	display_name = "Scarf, desert"
	path = /obj/item/clothing/mask/tornscarf/desert

/datum/gear/mask/scarf_green
	display_name = "Scarf, green"
	path = /obj/item/clothing/mask/tornscarf/green

/datum/gear/mask/scarf_grey
	display_name = "Scarf, grey"
	path = /obj/item/clothing/mask/tornscarf

/datum/gear/mask/scarf_urban
	display_name = "Scarf, urban"
	path = /obj/item/clothing/mask/tornscarf/urban

/datum/gear/mask/scarf_white
	display_name = "Scarf, white"
	path = /obj/item/clothing/mask/tornscarf/snow

// neckerchiefs

/datum/gear/mask/neckerchief_black
	display_name = "Neckerchief, black"
	path = /obj/item/clothing/mask/neckerchief/black

/datum/gear/mask/neckerchief_tan
	display_name = "Neckerchief, tan"
	path = /obj/item/clothing/mask/neckerchief

/datum/gear/mask/neckerchief_green
	display_name = "Neckerchief, green"
	path = /obj/item/clothing/mask/neckerchief/green

/datum/gear/mask/neckerchief_gray
	display_name = "Neckerchief, gray"
	path = /obj/item/clothing/mask/neckerchief/gray

/datum/gear/mask/neckerchief_red
	display_name = "Neckerchief, red"
	path = /obj/item/clothing/mask/neckerchief/red

// gas masks

/datum/gear/mask/gas
	display_name = "Gas mask"
	path = /obj/item/clothing/mask/gas //Civ market gas-mask, no longer USCM locked
	cost = 1

/datum/gear/mask/gas_upp
	display_name = "ShMB/4 gasmask"
	path = /obj/item/clothing/mask/gas/military/upp
	cost = 3
	allowed_origins = UPP_ORIGINS

/datum/gear/mask/keffiyeh
	display_name = "Keffiyeh"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh

/datum/gear/mask/keffiyeh/white
	display_name = "Keffiyeh, white"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh/white

/datum/gear/mask/keffiyeh/red
	display_name = "Keffiyeh, red"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh/red

/datum/gear/mask/keffiyeh/green
	display_name = "Keffiyeh, green"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh/green

/datum/gear/mask/keffiyeh/black
	display_name = "Keffiyeh, black"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh/black

/datum/gear/mask/keffiyeh/blue
	display_name = "Keffiyeh, blue"
	path = /obj/item/clothing/mask/rebreather/scarf/keffiyeh/blue

/*
//================================================
				Headwear
//================================================
*/

/datum/gear/headwear
	category = "Headwear"
	cost = 2
	slot = WEAR_HEAD

/datum/gear/headwear/uscm/santa_hat
	display_name = "santa hat, red"
	path = /obj/item/clothing/head/santa
	cost = 1
	allowed_origins = USCM_ORIGINS

/datum/gear/headwear/uscm/santa_hat/special_conditions()
	return is_month(12) && (is_day(21) || is_day(22) || is_day(23) || is_day(24) || is_day(25) || is_day(26))

/datum/gear/headwear/uscm/santa_hat_green
	display_name = "santa hat, green"
	path = /obj/item/clothing/head/santa/green
	cost = 1
	allowed_origins = USCM_ORIGINS

/datum/gear/headwear/uscm/santa_hat_green/special_conditions()
	return is_month(12) && (is_day(21) || is_day(22) || is_day(23) || is_day(24) || is_day(25) || is_day(26))

/datum/gear/headwear/durag_black
	display_name = "Durag, black"
	path = /obj/item/clothing/head/durag/black

/datum/gear/headwear/durag
	display_name = "Durag, jungle"
	path = /obj/item/clothing/head/durag

/datum/gear/headwear/beret_red
	display_name = "Beret, green"
	path = /obj/item/clothing/head/beret/cm/green

/datum/gear/headwear/beret_tan
	display_name = "Beret, tan"
	path = /obj/item/clothing/head/beret/cm/tan

/datum/gear/headwear/fisherman_boonie
	display_name = "Fisherman's boonie hat"
	path = /obj/item/clothing/head/cmcap/boonie/fisherman

/datum/gear/headwear/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/headwear/uscm/boonie_jungle
	display_name = "USCM boonie hat, jungle"
	path = /obj/item/clothing/head/cmcap/boonie

/datum/gear/headwear/uscm/boonie_desert
	display_name = "USCM boonie hat, desert"
	path = /obj/item/clothing/head/cmcap/boonie/tan

/datum/gear/headwear/uscm/boonie_snow
	display_name = "USCM boonie hat, snow"
	path = /obj/item/clothing/head/cmcap/boonie/snow

/datum/gear/headwear/uscm/beanie

/datum/gear/headwear/uscm/beanie/grey
	display_name = "USCM beanie, grey"
	path = /obj/item/clothing/head/beanie/gray

/datum/gear/headwear/uscm/beanie/green
	display_name = "USCM beanie, green"
	path = /obj/item/clothing/head/beanie/green

/datum/gear/headwear/uscm/beanie/tan
	display_name = "USCM beanie, tan"
	path = /obj/item/clothing/head/beanie/tan

/datum/gear/headwear/uscm/cap
	display_name = "USCM cap, jungle"
	path = /obj/item/clothing/head/cmcap

/datum/gear/headwear/uscm/cap/desert
	display_name = "USCM cap, desert"
	path = /obj/item/clothing/head/cmcap/desert

/datum/gear/headwear/uscm/cap/snow
	display_name = "USCM cap, snow"
	path = /obj/item/clothing/head/cmcap/snow

/datum/gear/headwear/uscm/cap/operations
	display_name = "USCM Operations Cap, Green"
	path = /obj/item/clothing/head/cmcap/bridge

/datum/gear/headwear/uscm/cap/cap_operations_alt
	display_name = "USCM Operations Cap, Tan"
	path = /obj/item/clothing/head/cmcap/bridge/tan

/datum/gear/headwear/uscm/cap/sulaco
	display_name = "USS Golden Arrow cap"
	path = /obj/item/clothing/head/sulacocap

/datum/gear/headwear/uscm/cap/flap_jungle
	display_name = "USCM expedition flapcap, jungle"
	path = /obj/item/clothing/head/cmcap/flap

/datum/gear/headwear/uscm/cap/flap_desert
	display_name = "USCM expedition flapcap, desert"
	path = /obj/item/clothing/head/cmcap/flap/desert

/datum/gear/headwear/uscm/cap/flap_snow
	display_name = "USCM expedition flapcap, snow"
	path = /obj/item/clothing/head/cmcap/flap/snow

/datum/gear/headwear/uscm/headband
	cost = 1

/datum/gear/headwear/uscm/headband/brown
	display_name = "USCM headband, brown"
	path = /obj/item/clothing/head/headband/brown

/datum/gear/headwear/uscm/headband/green
	display_name = "USCM headband, green"
	path = /obj/item/clothing/head/headband

/datum/gear/headwear/uscm/headband/grey
	display_name = "USCM headband, grey"
	path = /obj/item/clothing/head/headband/gray

/datum/gear/headwear/uscm/headband/red
	display_name = "USCM headband, red"
	path = /obj/item/clothing/head/headband/red

/datum/gear/headwear/uscm/headband/tan
	display_name = "USCM headband, tan"
	path = /obj/item/clothing/head/headband/tan

/datum/gear/headwear/uscm/headband/intel
	display_name = "USCM headband, black"
	path = /obj/item/clothing/head/headband/intel

/datum/gear/headwear/uscm/headband/bravo
	display_name = "USCM headband, orange"
	path = /obj/item/clothing/head/headband/bravo

/datum/gear/headwear/uscm/headband/charlie
	display_name = "USCM headband, purple"
	path = /obj/item/clothing/head/headband/charlie

/datum/gear/headwear/uscm/headband/delta
	display_name = "USCM headband, blue"
	path = /obj/item/clothing/head/headband/delta

/datum/gear/headwear/uscm/headband/echo
	display_name = "USCM headband, cyan green"
	path = /obj/item/clothing/head/headband/echo

/datum/gear/headwear/uscm/beret

/datum/gear/headwear/uscm/beret/white
	display_name = "Beret, white"
	path = /obj/item/clothing/head/beret/cm/white

/datum/gear/headwear/uscm/beret/alpha
	display_name = "Beret, red flash"
	path = /obj/item/clothing/head/beret/cm/alpha

/datum/gear/headwear/uscm/beret/bravo
	display_name = "Beret, yellow flash"
	path = /obj/item/clothing/head/beret/cm/bravo

/datum/gear/headwear/uscm/beret/charlie
	display_name = "Beret, purple flash"
	path = /obj/item/clothing/head/beret/cm/charlie

/datum/gear/headwear/uscm/beret/delta
	display_name = "Beret, blue flash"
	path = /obj/item/clothing/head/beret/cm/delta

/datum/gear/headwear/uscm/beret/echo
	display_name = "Beret, green flash"
	path = /obj/item/clothing/head/beret/cm/echo

/datum/gear/headwear/uscm/beret/foxtrot
	display_name = "Beret, brown flash"
	path = /obj/item/clothing/head/beret/cm/foxtrot

/datum/gear/headwear/uscm/beret/intel
	display_name = "Beret, black flash"
	path = /obj/item/clothing/head/beret/cm/intel

/datum/gear/headwear/uscm/headset
	display_name = "USCM headset"
	path = /obj/item/clothing/head/headset

/datum/gear/headwear/uscm/ushanka
	display_name = "Ushanka"
	path = /obj/item/clothing/head/ushanka

/datum/gear/headwear/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/headwear/upp/cap
	display_name = "UL2 cap"
	path = /obj/item/clothing/head/uppcap

/datum/gear/headwear/upp/beret
	display_name = "UL3 beret"
	path = /obj/item/clothing/head/uppcap/beret

/datum/gear/headwear/upp/boonie
	display_name = "UL5 hat"
	path = /obj/item/clothing/head/uppcap/boonie

/datum/gear/headwear/upp/boonie_canc
	display_name = "CANC boonie hat"
	path = /obj/item/clothing/head/uppcap/boonie/canc
	allowed_origins = list(ORIGIN_CANC, ORIGIN_UPP_EXCANC)

/datum/gear/headwear/upp/flapcap_canc
	display_name = "CANC flapcap"
	path = /obj/item/clothing/head/cmcap/flap/canc
	allowed_origins = list(ORIGIN_CANC, ORIGIN_UPP_EXCANC)

/datum/gear/headwear/upp/ushanka
	display_name = "UL2 ushanka"
	path = /obj/item/clothing/head/uppcap/ushanka

/datum/gear/headwear/rmc
	allowed_origins = TWE_ORIGINS

/datum/gear/headwear/rmc/beanie
	display_name = "RMC beanie"
	path = /obj/item/clothing/head/beanie/royal_marine

/datum/gear/headwear/rmc/turban
	display_name = "RMC turban"
	path = /obj/item/clothing/head/beanie/royal_marine/turban

/datum/gear/clothing/rmc/rmc_beret
	display_name = "Royal marine beret"
	path = /obj/item/clothing/head/beret/royal_marine_pvp

/datum/gear/clothing/rmc/rmc_beret_tl
	display_name = "Royal marine officer beret"
	path = /obj/item/clothing/head/beret/royal_marine_pvp/team_leader
	allowed_roles = list(JOB_TWE_RMC_SECTIONLEADER, JOB_TWE_RMC_TEAMLEADER, JOB_TWE_RMC_TROOPLEADER)

/datum/gear/clothing/rmc/iasf_beret
	display_name = "IASF beret"
	path = /obj/item/clothing/head/helmet/marine/veteran/iasf_beret

/datum/gear/clothing/rmc/iasf_beret_tl
	display_name = "IASF officer beret"
	path = /obj/item/clothing/head/helmet/marine/veteran/iasf_beret/tl
	allowed_roles = list(JOB_TWE_RMC_SECTIONLEADER, JOB_TWE_RMC_TEAMLEADER, JOB_TWE_RMC_TROOPLEADER)

/datum/gear/headwear/pmc
	allowed_origins = WY_ORIGINS

/datum/gear/headwear/pmc/cap
	display_name = "Weyland-Yutani cap"
	path = /obj/item/clothing/head/cmcap/weyyu

/datum/gear/headwear/pmc/cap_alt
	display_name = "Weyland-Yutani cap, Black"
	path = /obj/item/clothing/head/cmcap/wy_cap

/datum/gear/headwear/pmc/beret
	display_name = "PMC beret"
	path = /obj/item/clothing/head/cmcap/pmc

/datum/gear/headwear/pmc/beret_officer
	display_name = "PMC field officer beret"
	path = /obj/item/clothing/head/cmcap/pmc/fieldleader
	allowed_roles = list(JOB_PMCPLAT_LEADER, JOB_PMCPLAT_OW)

/*
//================================================
				Helmet Accessories
//================================================
*/

/datum/gear/helmet_garb
	category = "Helmet accessories"
	cost = 1

/datum/gear/helmet_garb/flair_initech
	display_name = "Flair, Initech"
	path = /obj/item/prop/helmetgarb/flair_initech

/datum/gear/helmet_garb/flair_io
	display_name = "Flair, Io"
	path = /obj/item/prop/helmetgarb/flair_io

/datum/gear/helmet_garb/flair_peace
	display_name = "Flair, Peace and Love"
	path = /obj/item/prop/helmetgarb/flair_peace

/datum/gear/helmet_garb/flair_uscm
	display_name = "Flair, USCM"
	path = /obj/item/prop/helmetgarb/flair_uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/helmet_garb/gunoil
	display_name = "Gun oil"
	path = /obj/item/prop/helmetgarb/gunoil

/datum/gear/helmet_garb/netting
	display_name = "Helmet netting"
	path = /obj/item/prop/helmetgarb/netting

/datum/gear/helmet_garb/lucky_feather
	display_name = "Lucky feather, red"
	path = /obj/item/prop/helmetgarb/lucky_feather

/datum/gear/helmet_garb/lucky_feather/yellow
	display_name = "Lucky feather, yellow"
	path = /obj/item/prop/helmetgarb/lucky_feather/yellow

/datum/gear/helmet_garb/lucky_feather/purple
	display_name = "Lucky feather, purple"
	path = /obj/item/prop/helmetgarb/lucky_feather/purple

/datum/gear/helmet_garb/lucky_feather/blue
	display_name = "Lucky feather, blue"
	path = /obj/item/prop/helmetgarb/lucky_feather/blue

/datum/gear/helmet_garb/prescription_bottle
	display_name = "Prescription bottle"
	path = /obj/item/prop/helmetgarb/prescription_bottle

/datum/gear/helmet_garb/raincover
	display_name = "Rain cover"
	path = /obj/item/prop/helmetgarb/raincover

/datum/gear/helmet_garb/rabbits_foot
	display_name = "Rabbit's foot"
	path = /obj/item/prop/helmetgarb/rabbitsfoot

/datum/gear/helmet_garb/rosary
	display_name = "Rosary"
	path = /obj/item/prop/helmetgarb/rosary

/datum/gear/helmet_garb/spent_buck
	display_name = "Spent buckshot"
	path = /obj/item/prop/helmetgarb/spent_buckshot

/datum/gear/helmet_garb/spent_flechette
	display_name = "Spent flechette"
	path = /obj/item/prop/helmetgarb/spent_flech

/datum/gear/helmet_garb/spent_slugs
	display_name = "Spent slugs"
	path = /obj/item/prop/helmetgarb/spent_slug

/datum/gear/helmet_garb/cartridge
	display_name = "Cartridge"
	path = /obj/item/prop/helmetgarb/cartridge

/datum/gear/helmet_garb/spacejam_tickets
	display_name = "Tickets to Space Jam"
	path = /obj/item/prop/helmetgarb/spacejam_tickets

/datum/gear/helmet_garb/trimmed_wire
	display_name = "Trimmed barbed wire"
	path = /obj/item/prop/helmetgarb/trimmed_wire

/datum/gear/helmet_garb/bullet_pipe
	display_name = "10x99mm XM43E1 casing pipe"
	path = /obj/item/prop/helmetgarb/bullet_pipe
	allowed_origins = USCM_ORIGINS

/datum/gear/helmet_garb/chaplain_patch
	display_name = "USCM chaplain helmet patch"
	path = /obj/item/prop/helmetgarb/chaplain_patch
	allowed_origins = USCM_ORIGINS

/datum/gear/helmet_garb/ngv_cosmetic
	display_name = "old M2 night vision goggles"
	path = /obj/item/prop/helmetgarb/helmet_nvg/cosmetic
	allowed_origins = USCM_ORIGINS

/*
//================================================
				Clothing
//================================================
*/

/datum/gear/clothing
	category = "Non-standard clothing"
	cost = 3

// boots
/datum/gear/clothing/boots
	cost = 2
	slot = WEAR_FEET

/datum/gear/clothing/boots/jungle_boots
	display_name = "jungle combat boots"
	path = /obj/item/clothing/shoes/marine/civilian/jungle

/datum/gear/clothing/boots/grey_boots
	display_name = "grey combat boots"
	path = /obj/item/clothing/shoes/marine/civilian/grey

/datum/gear/clothing/boots/brown_boots
	display_name = "brown combat boots"
	path = /obj/item/clothing/shoes/marine/civilian/brown

/datum/gear/clothing/boots/urban_boots
	display_name = "urban combat boots"
	path = /obj/item/clothing/shoes/marine/civilian/urban

/datum/gear/clothing/boots/snow_boots
	display_name = "snow combat boots"
	path = /obj/item/clothing/shoes/marine/civilian/snow

// gloves
/datum/gear/clothing/gloves
	cost = 2
	slot = WEAR_HANDS

/datum/gear/clothing/gloves/brown_gloves
	display_name = "brown combat gloves"
	path = /obj/item/clothing/gloves/marine/brown

/datum/gear/clothing/gloves/black_fingerless_gloves
	display_name = "black fingerless combat gloves"
	path = /obj/item/clothing/gloves/marine/fingerless

/datum/gear/clothing/gloves/brown_fingerless_gloves
	display_name = "brown fingerless combat gloves"
	path = /obj/item/clothing/gloves/marine/brown/fingerless

/datum/gear/clothing/gloves/alpha_gloves
	display_name = "red combat gloves"
	path = /obj/item/clothing/gloves/alpha
	allowed_origins = USCM_ORIGINS

/datum/gear/clothing/gloves/delta_gloves
	display_name = "blue combat gloves"
	path = /obj/item/clothing/gloves/delta
	allowed_origins = USCM_ORIGINS

/datum/gear/clothing/gloves/bravo_gloves
	display_name = "yellow combat gloves"
	path = /obj/item/clothing/gloves/bravo
	allowed_origins = USCM_ORIGINS

/datum/gear/clothing/gloves/charlie_gloves
	display_name = "purple combat gloves"
	path = /obj/item/clothing/gloves/charlie
	allowed_origins = USCM_ORIGINS

// windbreakers

/datum/gear/clothing/windbreaker_green
	display_name = "Windbreaker, Green"
	path = /obj/item/clothing/suit/storage/windbreaker/windbreaker_green

/datum/gear/clothing/windbreaker_khaki
	display_name = "Windbreaker, Brown"
	path = /obj/item/clothing/suit/storage/windbreaker/windbreaker_brown

/datum/gear/clothing/windbreaker_blue
	display_name = "Windbreaker, Blue"
	path = /obj/item/clothing/suit/storage/windbreaker/windbreaker_blue

// webbings

/datum/gear/clothing/utility_vest
	display_name = "Utility vest"
	path = /obj/item/clothing/suit/storage/utility_vest

/datum/gear/clothing/external_webbing
	display_name = "External webbing"
	path = /obj/item/clothing/suit/storage/webbing

/datum/gear/clothing/external_webbing_alt
	display_name = "External webbing, Black"
	path = /obj/item/clothing/suit/storage/webbing/black

// factions

/datum/gear/clothing/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/clothing/shorts
	display_name = "USCM PT Shorts"
	path = /obj/item/clothing/under/shorts/red/uscm
	cost = 1

/datum/gear/clothing/uscm/service_jacket
	display_name = "USCM service jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/service
	allowed_roles = list(JOB_SQUAD_LEADER, JOB_SO)

/datum/gear/clothing/uscm/aso_jacket
	display_name = "USCM auxiliary support officer jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/service/aso
	allowed_roles = list(JOB_SQUAD_LEADER, JOB_SO)

/datum/gear/clothing/uscm/shotgun_holster_belt
	display_name = "shotgun holster belt"
	path = /obj/item/storage/belt/gun/shotgunholster

/datum/gear/clothing/uscm/flak
	display_name = "M67 flak jacket (Blue)"
	path = /obj/item/clothing/accessory/flak

/datum/gear/clothing/uscm/flak/od
	display_name = "M67 flak jacket (Green)"
	path = /obj/item/clothing/accessory/flak/od

/datum/gear/clothing/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/clothing/upp/upp_service_jacket
	display_name = "UPP service jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/upp

/datum/gear/clothing/upp/upp_coldweather_service_jacket
	display_name = "UPP coldweather service jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/upp/coldweather

/datum/gear/clothing/upp/upp_naval_service_jacket
	display_name = "UPP naval infantry service jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/upp/naval

/datum/gear/clothing/twe
	allowed_origins = TWE_ORIGINS

/datum/gear/clothing/twe/iasf_combat_jacket
	display_name = "IASF combat jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/service/iasf_combat_jacket

/datum/gear/clothing/twe/royal_marine_commando_service_jacket
	display_name = "Royal Marine Commando service jacket"
	path = /obj/item/clothing/suit/storage/jacket/marine/rmc/service

/datum/gear/clothing/twe/royal_marine_commando_service_jacket_black
	display_name = "Royal Marine Commando service jacket | Black"
	path = /obj/item/clothing/suit/storage/jacket/marine/rmc/service/black

/*
//================================================
				Patches
//================================================
*/

/datum/gear/patch
	category = "Patches"
	cost = 1

/datum/gear/patch/field_medic
	display_name = "Field Medic patch"
	path = /obj/item/clothing/accessory/patch/loadout/medic_patch

/datum/gear/patch/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/patch/uscm/msfpatch
	display_name = "MSF shoulder patch"
	path = /obj/item/clothing/accessory/patch/msf_patch

/datum/gear/patch/uscm/patch_uscm
	display_name = "USCM shoulder patch"
	path = /obj/item/clothing/accessory/patch

/datum/gear/patch/uscm/patch_uscm/sapper
	display_name = "USCM Combat Engineering patch"
	path = /obj/item/clothing/accessory/patch/sapper

/datum/gear/patch/uscm/patch_uscm/devils
	display_name = "Solar Devils shoulder patch"
	path = /obj/item/clothing/accessory/patch/devils

/datum/gear/patch/uscm/patch_uscm/falcons
	display_name = "USCM Falling Falcons patch"
	path = /obj/item/clothing/accessory/patch/falcon

/datum/gear/patch/uscm/patch_uscm/ua
	display_name = "United Americas flag shoulder patch"
	path = /obj/item/clothing/accessory/patch/ua

/datum/gear/patch/uscm/patch_uscm/usa
	display_name = "United States flag shoulder patch" //no limited allowed_origins, a non-USCM could have the patch to show their original country
	path = /obj/item/clothing/accessory/patch/usa
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/patch/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/patch/upp/patch_upp
	display_name = "UPPAC shoulder patch"
	path = /obj/item/clothing/accessory/patch/upp

/datum/gear/patch/upp/patch_upp/sof
	display_name = "Naval Infantry shoulder patch"
	path = /obj/item/clothing/accessory/patch/upp/naval

/datum/gear/patch/upp/patch_upp/cec
	display_name = "Cosmos Exploration Corps shoulder patch"
	path = /obj/item/clothing/accessory/patch/loadout/cec_patch

/datum/gear/patch/twe
	allowed_origins = TWE_ORIGINS

/datum/gear/patch/twe/patch_rmc
	display_name = "Royal Marines Commando shoulder patch"
	path = /obj/item/clothing/accessory/patch/royal_marines
	allowed_origins = TWE_ORIGINS

/datum/gear/patch/twe/patch_rmc/twe
	display_name = "Three World Empire shoulder patch"
	path = /obj/item/clothing/accessory/patch/twe

/datum/gear/patch/wy
	allowed_origins = WY_ORIGINS

/datum/gear/patch/wy/patch
	display_name = "Weyland-Yutani patch"
	path = /obj/item/clothing/accessory/patch/wy

/datum/gear/patch/wy/wysquare
	display_name = "Weyland-Yutani Square patch"
	path = /obj/item/clothing/accessory/patch/wysquare

/datum/gear/patch/wy/wy_faction
	display_name = "Weyland-Yutani Faction patch"
	path = /obj/item/clothing/accessory/patch/wy_faction

/datum/gear/patch/wy/wy_white
	display_name = "Weyland-Yutani White patch"
	path = /obj/item/clothing/accessory/patch/wy_white

/datum/gear/patch/wy/wyfury
	display_name = "Weyland-Yutani Fury '161' patch"
	path = /obj/item/clothing/accessory/patch/wyfury

/datum/gear/patch/miscellaneous
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/patch/miscellaneous/freelancer_patch
	display_name = "Freelancer's Guild patch"
	path = /obj/item/clothing/accessory/patch/freelancer_patch

/datum/gear/patch/miscellaneous/merc_patch
	display_name = "Old Freelancer's Guild patch"
	path = /obj/item/clothing/accessory/patch/merc_patch

/datum/gear/patch/miscellaneous/conam
	display_name = "Con-Amalagated Corporation patch"
	path = /obj/item/clothing/accessory/patch/loadout/conam_patch

/datum/gear/patch/miscellaneous/hyperdyne
	display_name = "Hyperdyne Corporation patch"
	path = /obj/item/clothing/accessory/patch/loadout/hyperdyne_patch

/datum/gear/patch/miscellaneous/hyperdyne
	display_name = "Brazilian flag patch"
	path = /obj/item/clothing/accessory/patch/brazil

/*
//================================================
				Armor & Body Paints
//================================================
*/

/datum/gear/paint
	category = "Armor & body paints"
	cost = 1

/datum/gear/paint/paint_sg
	display_name = "Black Smartgun Harness Paint"
	path = /obj/item/clothing/accessory/paint/sg

/datum/gear/paint/paint_skull
	display_name = "M3 Pattern Skull Paint"
	path = /obj/item/clothing/accessory/paint

/datum/gear/paint/paint_heart
	display_name = "M3 Pattern Heart Paint"
	path = /obj/item/clothing/accessory/paint/heart

/datum/gear/paint/uaflag
	display_name = "M3 Pattern UA Flag Paint"
	path = /obj/item/clothing/accessory/paint/uaflag

/datum/gear/paint/usflag
	display_name = "M3 Pattern US Flag Paint"
	path = /obj/item/clothing/accessory/paint/usflag

/datum/gear/paint/target
	display_name = "M3 Pattern Target Paint"
	path = /obj/item/clothing/accessory/paint/target

/datum/gear/paint/smiley
	display_name = "M3 Pattern Smiley-Face Paint"
	path = /obj/item/clothing/accessory/paint/alcoholism

/datum/gear/paint/neutral
	display_name = "M3 Pattern Neutral-Face Paint"
	path = /obj/item/clothing/accessory/paint/melancholy

/datum/gear/paint/cross
	display_name = "M3 Pattern Cross Paint"
	path = /obj/item/clothing/accessory/paint/cross

/datum/gear/paint/pandora
	display_name = "M3 Pattern Inscription Paint"
	path = /obj/item/clothing/accessory/paint/inscription

/datum/gear/paint/flames
	display_name = "M3 Pattern Fire Paint"
	path = /obj/item/clothing/accessory/paint/fire

/datum/gear/paint/facepaint_green
	display_name = "Facepaint, green"
	path = /obj/item/facepaint/green
	cost = 2

/datum/gear/paint/facepaint_brown
	display_name = "Facepaint, brown"
	path = /obj/item/facepaint/brown
	cost = 2

/datum/gear/paint/facepaint_black
	display_name = "Facepaint, black"
	path = /obj/item/facepaint/black
	cost = 2

/datum/gear/paint/facepaint_skull
	display_name = "Facepaint, skull"
	path = /obj/item/facepaint/skull
	cost = 3

/datum/gear/paint/facepaint_clown
	display_name = "Facepaint, clown"
	path = /obj/item/facepaint/clown
	cost = 5

/datum/gear/paint/facepaint_clown_alt
	display_name = "Facepaint, clown (alternate)"
	path = /obj/item/facepaint/clown/alt
	cost = 5

/datum/gear/paint/facepaint_body
	display_name = "Fullbody paint"
	path = /obj/item/facepaint/sniper
	cost = 4 //To match with the skull paint amount of point, gave this amount of point for the same reason of the skull facepaint (too cool for everyone to be able to constantly use)

/datum/gear/paint/facepaint_body_snow
	display_name = "Fullbody paint, snow"
	path = /obj/item/facepaint/sniper/snow
	cost = 4

/datum/gear/paint/facepaint_body_desert
	display_name = "Fullbody paint, desert"
	path = /obj/item/facepaint/sniper/desert
	cost = 4

/datum/gear/paint/facepaint_body_jungle
	display_name = "Fullbody paint, jungle"
	path = /obj/item/facepaint/sniper/jungle
	cost = 4

/datum/gear/paint/facepaint_body_urban
	display_name = "Fullbody paint, urban"
	path = /obj/item/facepaint/sniper/urban
	cost = 4

/*
//================================================
				Paperwork
//================================================
*/

/datum/gear/paperwork
	category = "Paperwork"

/datum/gear/paperwork/pen
	display_name = "Pen, black"
	path = /obj/item/tool/pen
	cost = 1

/datum/gear/paperwork/pen_blue
	display_name = "Pen, blue"
	path = /obj/item/tool/pen/blue

/datum/gear/paperwork/pen_green
	display_name = "Pen, green"
	path = /obj/item/tool/pen/green

/datum/gear/paperwork/pen_red
	display_name = "Pen, red"
	path = /obj/item/tool/pen/red

/datum/gear/paperwork/pen_fountain
	display_name = "Pen, fountain"
	path = /obj/item/tool/pen/fountain
	cost = 3

/datum/gear/paperwork/paper
	display_name = "Sheet of paper"
	path = /obj/item/paper
	cost = 1

/datum/gear/paperwork/clipboard
	display_name = "Clipboard"
	path = /obj/item/clipboard

/datum/gear/paperwork/folder_black
	display_name = "Folder, black"
	path = /obj/item/folder/black

/datum/gear/paperwork/folder_blue
	display_name = "Folder, blue"
	path = /obj/item/folder/blue

/datum/gear/paperwork/folder_red
	display_name = "Folder, red"
	path = /obj/item/folder/red

/datum/gear/paperwork/folder_white
	display_name = "Folder, white"
	path = /obj/item/folder/white

/datum/gear/paperwork/folder_yellow
	display_name = "Folder, yellow"
	path = /obj/item/folder/yellow

/datum/gear/paperwork/notepad_black
	display_name = "Notepad, black"
	path = /obj/item/notepad/black

/datum/gear/paperwork/notepad_blue
	display_name = "Notepad, blue"
	path = /obj/item/notepad/blue

/datum/gear/paperwork/notepad_green
	display_name = "Notepad, green"
	path = /obj/item/notepad/green

/datum/gear/paperwork/notepad_red
	display_name = "Notepad, red"
	path = /obj/item/notepad/red

/*
//================================================
				Recreational
//================================================
*/

/datum/gear/toy
	category = "Recreational"
	cost = 1

/datum/gear/toy/camera
	display_name = "Camera"
	path = /obj/item/device/camera

/datum/gear/toy/mags
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/toy/mags/magazine_dirty
	display_name = "Magazine"
	path = /obj/item/prop/magazine/dirty

/datum/gear/toy/mags/boots
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/toy/mags/boots/boots_magazine_one
	display_name = "Boots Issue No.117"
	path = /obj/item/prop/magazine/boots/n117

/datum/gear/toy/mags/boots/boots_magazine_two
	display_name = "Boots Issue No.150"
	path = /obj/item/prop/magazine/boots/n150

/datum/gear/toy/mags/boot_magazine_three
	display_name = "Boots Issue No.160"
	path = /obj/item/prop/magazine/boots/n160

/datum/gear/toy/mags/boots/boots_magazine_four
	display_name = "Boots Issue No.54"
	path = /obj/item/prop/magazine/boots/n054

/datum/gear/toy/mags/boots/boots_magazine_five
	display_name = "Boots Issue No.55"
	path = /obj/item/prop/magazine/boots/n055

/datum/gear/toy/film
	display_name = "Camera film"
	path = /obj/item/device/camera_film

/datum/gear/toy/card
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/toy/card/ace_of_spades
	display_name = "Card, ace of spades"
	path = /obj/item/toy/handcard/aceofspades

/datum/gear/toy/card/uno_reverse_red
	display_name = "Card, Uno Reverse - red"
	path = /obj/item/toy/handcard/uno_reverse_red

/datum/gear/toy/card/uno_reverse_blue
	display_name = "Card, Uno Reverse - blue"
	path = /obj/item/toy/handcard/uno_reverse_blue

/datum/gear/toy/card/uno_reverse_purple
	display_name = "Card, Uno Reverse - purple"
	path = /obj/item/toy/handcard/uno_reverse_purple

/datum/gear/toy/card/uno_reverse_yellow
	display_name = "Card, Uno Reverse - yellow"
	path = /obj/item/toy/handcard/uno_reverse_yellow

/datum/gear/toy/card/trading_card
	display_name = "Card, random WeyYu Trading"
	path = /obj/item/toy/trading_card

/datum/gear/toy/deck
	display_name = "Deck of cards, regular"
	path = /obj/item/toy/deck

/datum/gear/toy/deck/uno
	display_name = "Deck of cards, Uno"
	path = /obj/item/toy/deck/uno

/datum/gear/toy/trading_card
	display_name = "Trading Card Packet"
	path = /obj/item/storage/fancy/trading_card

/datum/gear/toy/d6
	display_name = "Die, 6 sides"
	path = /obj/item/toy/dice

/datum/gear/toy/d20
	display_name = "Die, 20 sides"
	path = /obj/item/toy/dice/d20

/datum/gear/toy/crayon
	display_name = "Crayon"
	path = /obj/item/toy/crayon/rainbow

/*
//================================================
				Cassettes
//================================================
*/

/datum/gear/cassettes
	category = "Cassettes"
	cost = 1

/datum/gear/cassettes/walkman
	display_name = "Walkman"
	path = /obj/item/device/walkman

/datum/gear/cassettes/pop1
	display_name = "Blue Cassette"
	path = /obj/item/device/cassette_tape/pop1

/datum/gear/cassettes/pop2
	display_name = "Rainbow Cassette"
	path = /obj/item/device/cassette_tape/pop2
/datum/gear/cassettes/pop3
	display_name = "Orange Cassette"
	path = /obj/item/device/cassette_tape/pop3

/datum/gear/cassettes/pop4
	display_name = "Pink Cassette"
	path = /obj/item/device/cassette_tape/pop4

/datum/gear/cassettes/heavymetal
	display_name = "Red-Black Cassette"
	path = /obj/item/device/cassette_tape/heavymetal

/datum/gear/cassettes/hairmetal
	display_name = "Red Striped Cassette"
	path = /obj/item/device/cassette_tape/hairmetal

/datum/gear/cassettes/indie
	display_name = "Rising Sun Cassette"
	path = /obj/item/device/cassette_tape/indie

/datum/gear/cassettes/hiphop
	display_name = "Blue Stripe Cassette"
	path = /obj/item/device/cassette_tape/hiphop

/datum/gear/cassettes/nam
	display_name = "Green Cassette"
	path = /obj/item/device/cassette_tape/nam

/datum/gear/cassettes/ocean
	display_name = "Ocean Cassette"
	path = /obj/item/device/cassette_tape/ocean

/datum/gear/cassettes/pouch
	display_name = "Cassette Pouch"
	path = 	/obj/item/storage/pouch/cassette

/*
//================================================
				Plushies
//================================================
*/

/datum/gear/plush
	category = "Plushies"
	cost = 4

/datum/gear/plush/random
	display_name = "Random plush"
	path = /obj/item/toy/plush/random_plushie
	cost = 2

/datum/gear/plush/farwa
	display_name = "Farwa plush"
	path = /obj/item/toy/plush/farwa

/datum/gear/plush/barricade
	display_name = "Barricade plush"
	path = /obj/item/toy/plush/barricade

/datum/gear/plush/bee
	display_name = "Bee plush"
	path = /obj/item/toy/plush/bee

/datum/gear/plush/shark
	display_name = "Shark plush"
	path = /obj/item/toy/plush/shark

/datum/gear/plush/moth
	display_name = "Moth plush"
	path = /obj/item/toy/plush/moth

/datum/gear/plush/rock
	display_name = "Rock plush"
	path = /obj/item/toy/plush/rock

/datum/gear/plush/otter
	display_name = "Otter plush"
	path = /obj/item/toy/plush/otter

/datum/gear/plush/fox
	display_name = "Fox plush"
	path = /obj/item/toy/plush/fox

/datum/gear/plush/kitten
	display_name = "Kitten plush"
	path = /obj/item/toy/plush/kitten

/datum/gear/plush/box
	display_name = "Box plush"
	path = /obj/item/toy/plush/box

/datum/gear/plush/carp
	display_name = "Carp plush"
	path = /obj/item/toy/plush/carp

/datum/gear/plush/therapy
	display_name = "Therapy plush"
	path = /obj/item/toy/plush/therapy

/datum/gear/plush/therapy/red
	display_name = "Therapy plush (Red)"
	path = /obj/item/toy/plush/therapy/red

/datum/gear/plush/therapy/blue
	display_name = "Therapy plush (Blue)"
	path = /obj/item/toy/plush/therapy/blue

/datum/gear/plush/therapy/green
	display_name = "Therapy plush (Green)"
	path = /obj/item/toy/plush/therapy/green

/datum/gear/plush/therapy/orange
	display_name = "Therapy plush (Orange)"
	path = /obj/item/toy/plush/therapy/orange

/datum/gear/plush/therapy/purple
	display_name = "Therapy plush (Purple)"
	path = /obj/item/toy/plush/therapy/purple

/datum/gear/plush/therapy/yellow
	display_name = "Therapy plush (Yellow)"
	path = /obj/item/toy/plush/therapy/yellow

/datum/gear/plush/therapy/random
	display_name = "Therapy plush (???)"
	path = /obj/item/toy/plush/therapy/random_color
	cost = 7

/*
//================================================
				Weapons
//================================================
*/

/datum/gear/weapon
	category = "Weapons"
	cost = 4

/datum/gear/weapon/civilian
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/weapon/civilian/butterfly_knife
	display_name = "Butterfly Knife"
	path = /obj/item/weapon/butterfly
	cost = 3

/datum/gear/weapon/civilian/hg45_civilian
	display_name = "HG 45 'Aguila' Pistol"
	path = /obj/item/storage/box/loadout/HG45_civilian_loadout

/datum/gear/weapon/civilian/hg45_marine
	display_name = "HG 45 'Marina' Pistol"
	path = /obj/item/storage/box/loadout/HG45_marine_loadout

/datum/gear/weapon/civilian/hg44
	display_name = "HG 44 'Automag' Pistol"
	path = /obj/item/storage/box/loadout/HG44_loadout

/datum/gear/weapon/civilian/spearhead
	display_name = "Spearhead Armoury Revolver"
	path = /obj/item/storage/box/loadout/Spearhead_loadout

/datum/gear/weapon/civilian/spearhead_custom
	display_name = "Custom Spearhead Armoury Revolver"
	path = /obj/item/storage/box/loadout/Spearhead_loadout/custom

/datum/gear/weapon/civilian/clfpistol
	display_name = "Hummingbird Pistol"
	path = /obj/item/storage/box/loadout/CLF_loadout

/datum/gear/weapon/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/weapon/uscm/bayonet
	display_name = "M5 bayonet"
	path = 	/obj/item/attachable/bayonet
	cost = 3

/datum/gear/weapon/uscm/kabar
	display_name = "KA-BAR utility knife"
	path = 	/obj/item/weapon/knife/marine/kabar
	cost = 3

/datum/gear/weapon/uscm/bowie
	display_name = "Bowie fighting knife"
	path = 	/obj/item/storage/box/loadout/bowie
	cost = 3

/datum/gear/weapon/uscm/baker
	display_name = "Baker-pattern fighting knife"
	path = 	/obj/item/weapon/knife/marine/baker
	cost = 3

/datum/gear/weapon/uscm/m8_cartridge_bayonet
	display_name = "M8 Cartridge Bayonet"
	path = /obj/item/storage/box/loadout/co2_knife
	cost = 3

/datum/gear/weapon/m2100_machete
	display_name = "M2100 Machete"
	path = /obj/item/storage/large_holster/machete/arnold/weak

/datum/gear/weapon/m4a3_custom
	display_name = "Custom M4A3 Pistol"
	path = /obj/item/storage/box/loadout/M4A3_custom_loadout

/datum/gear/weapon/m1911
	display_name = "M1911 Pistol"
	path = /obj/item/storage/box/loadout/M1911_loadout

/datum/gear/weapon/m44
	display_name = "M44 Revolver"
	path = /obj/item/storage/box/loadout/M44_loadout

/datum/gear/weapon/m44_custom_revolver
	display_name = "Custom M44 Revolver"
	path = /obj/item/storage/box/loadout/M44_custom_loadout

/datum/gear/weapon/vp78
	display_name = "VP78 Pistol"
	path = /obj/item/storage/box/loadout/VP78_loadout //RMC get the better kind of VP78 on their ship, so they won't need to buy subpar civ-market models

/datum/gear/weapon/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/weapon/upp/type_80_Bayonet
	display_name = "Type 80 bayonet"
	path = /obj/item/attachable/bayonet/upp/surplus
	cost = 3

/datum/gear/weapon/upp/chinese
	display_name = "Type 4 bayonet"
	path = 	/obj/item/attachable/bayonet/canc
	allowed_origins = list(ORIGIN_CANC, ORIGIN_UPP_EXCANC)
	cost = 3

/datum/gear/weapon/upp/t73
	display_name = "Type 73 Pistol"
	path = /obj/item/storage/box/loadout/T73_loadout

/datum/gear/weapon/upp/zhnk72
	display_name = "ZHNK-72 Revolver"
	path = /obj/item/storage/box/loadout/ZHNK72_loadout

/datum/gear/weapon/twe
	allowed_origins = TWE_ORIGINS

/datum/gear/weapon/twe/kukri
	display_name = "Kukri utility knife"
	path = 	/obj/item/storage/box/loadout/bowie/kukri
	cost = 3

/datum/gear/weapon/twe/l54
	display_name = "L54A2 Pistol"
	path = /obj/item/storage/box/loadout/L54_loadout

/datum/gear/weapon/twe/m9
	display_name = "Berreta 92FS Pistol"
	path = /obj/item/storage/box/loadout/M9_loadout

/*
//================================================
				Canned Drinks
//================================================
*/

/datum/gear/drink
	category = "Canned drinks"
	cost = 1

/datum/gear/drink/non_upp
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/drink/non_upp/water
	display_name = "Bottled water"
	path = /obj/item/reagent_container/food/drinks/cans/waterbottle

/datum/gear/drink/non_upp/grape_juice
	display_name = "Grape juice"
	path = /obj/item/reagent_container/food/drinks/cans/grape_juice

/datum/gear/drink/non_upp/lemon_lime
	display_name = "Lemon lime"
	path = /obj/item/reagent_container/food/drinks/cans/lemon_lime

/datum/gear/drink/non_upp/iced_tea
	display_name = "Iced tea"
	path = /obj/item/reagent_container/food/drinks/cans/iced_tea

/datum/gear/drink/non_upp/cola
	display_name = "Classic Cola"
	path = /obj/item/reagent_container/food/drinks/cans/classcola

/datum/gear/drink/non_upp/mountain_wind
	display_name = "Mountain Wind"
	path = /obj/item/reagent_container/food/drinks/cans/space_mountain_wind

/datum/gear/drink/non_upp/space_up
	display_name = "Space Up"
	path = /obj/item/reagent_container/food/drinks/cans/space_up

/datum/gear/drink/non_upp/souto_classic
	display_name = "Classic Souto"
	path = /obj/item/reagent_container/food/drinks/cans/souto/classic

/datum/gear/drink/non_upp/souto_diet
	display_name = "Diet Souto"
	path = /obj/item/reagent_container/food/drinks/cans/souto/diet/classic

/datum/gear/drink/boda
	display_name = "Boda Soda"
	path = /obj/item/reagent_container/food/drinks/cans/boda
	cost = 3 //Legally imported from UPP.
	allowed_origins = FACTION_ORIGINS

/datum/gear/drink/boda/plus
	display_name = "Boda Cola"
	path = /obj/item/reagent_container/food/drinks/cans/bodaplus

/datum/gear/drink/non_upp/alcohol
	cost = 3 //Illegal in military. // UPP stricter on enforcement, I figure

/datum/gear/drink/non_upp/alcohol/ale
	display_name = "Weyland-Yutani IPA Ale"
	path = /obj/item/reagent_container/food/drinks/cans/ale

/datum/gear/drink/non_upp/alcohol/aspen
	display_name = "Weyland-Yutani Aspen Beer"
	path = /obj/item/reagent_container/food/drinks/cans/aspen

/datum/gear/drink/non_upp/alcohol/beer
	display_name = "Weyland-Yutani Lite Beer"
	path = /obj/item/reagent_container/food/drinks/cans/beer

/datum/gear/drink/non_upp/alcohol/loko
	display_name = "Thirteen Loko"
	path = /obj/item/reagent_container/food/drinks/cans/thirteenloko

/*
//================================================
				Flasks
//================================================
*/

/datum/gear/flask
	category = "Flasks"
	cost = 1

/datum/gear/flask/uscm
	allowed_origins = USCM_ORIGINS

/datum/gear/flask/uscm/flask
	display_name = "USCM flask"
	path = /obj/item/reagent_container/food/drinks/flask/marine

/datum/gear/flask/canteen
	display_name = "Canteen"
	path = /obj/item/reagent_container/food/drinks/flask/canteen/empty

/datum/gear/flask/leather
	display_name = "Leather flask"
	path = /obj/item/reagent_container/food/drinks/flask/detflask

/datum/gear/flask/leather_black
	display_name = "Black leather flask"
	path = /obj/item/reagent_container/food/drinks/flask/barflask

/datum/gear/flask/metal
	display_name = "Metal flask"
	path = /obj/item/reagent_container/food/drinks/flask

/datum/gear/flask/vacuum
	display_name = "Vacuum flask"
	path = /obj/item/reagent_container/food/drinks/flask/vacuumflask

/datum/gear/flask/wy
	display_name = "WY flask"
	path = /obj/item/reagent_container/food/drinks/flask/weylandyutani
	allowed_origins = NON_UPP_ORIGINS

/*
//================================================
				Sweet Foods
//================================================
*/

/datum/gear/snack_sweet
	category = "Food (sweets)"

/datum/gear/snack_sweet/candy
	display_name = "Bar of candy"
	path = /obj/item/reagent_container/food/snacks/candy

/datum/gear/snack_sweet/chocolate
	display_name = "Bar of chocolate"
	path = /obj/item/reagent_container/food/snacks/chocolatebar

/datum/gear/snack_sweet/candy_apple
	display_name = "Candied apple"
	path = /obj/item/reagent_container/food/snacks/candiedapple

/datum/gear/snack_sweet/cookie
	display_name = "Cookie"
	path = /obj/item/reagent_container/food/snacks/cookie

/datum/gear/snack_sweet/fortune_cookie
	display_name = "Fortune cookie"
	path = /obj/item/reagent_container/food/snacks/fortunecookie/prefilled
	cost = 3

/datum/gear/snack_sweet/donut_normal
	display_name = "Donut"
	path = /obj/item/reagent_container/food/snacks/donut/normal

/datum/gear/snack_sweet/donut_jelly
	display_name = "Jelly donut"
	path = /obj/item/reagent_container/food/snacks/donut/jelly

/datum/gear/snack_sweet/donut_cherry
	display_name = "Cherry donut"
	path = /obj/item/reagent_container/food/snacks/donut/cherryjelly

/*
//================================================
				Packaged Foods
//================================================
*/

/datum/gear/snack_packaged
	category = "Food (packaged)"
	cost = 1

/datum/gear/snack_packaged/non_upp
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/snack_packaged/non_upp/beef_jerky
	display_name = "Beef jerky"
	path = /obj/item/reagent_container/food/snacks/sosjerky

/datum/gear/snack_packaged/non_upp/meat_bar
	display_name = "MEAT bar"
	path = /obj/item/reagent_container/food/snacks/eat_bar

/datum/gear/snack_packaged/non_upp/kepler_crisps
	display_name = "Kepler Crisps"
	path = /obj/item/reagent_container/food/snacks/kepler_crisps

/datum/gear/snack_packaged/non_upp/burrito
	display_name = "Packaged burrito"
	path = /obj/item/reagent_container/food/snacks/microwavable/packaged_burrito

/datum/gear/snack_packaged/non_upp/cheeseburger
	display_name = "Packaged cheeseburger"
	path = /obj/item/reagent_container/food/snacks/microwavable/packaged_burger

/datum/gear/snack_packaged/non_upp/hotdog
	display_name = "Packaged hotdog"
	path = /obj/item/reagent_container/food/snacks/microwavable/packaged_hdogs

/datum/gear/snack_packaged/non_upp/chips_pepper
	display_name = "W-Y Pepper Chips"
	path = /obj/item/reagent_container/food/snacks/wy_chips/pepper

/datum/gear/snack_packaged/non_upp/mre
	display_name = "UA MRE"
	path = /obj/item/storage/box/mre/hdr
	cost = 2

/datum/gear/snack_packaged/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/snack_packaged/upp
	allowed_origins = UPP_ORIGINS

/datum/gear/snack_packaged/upp/galets
	display_name = "Army galets"
	path = /obj/item/reagent_container/food/snacks/wrapped/upp_biscuits

/datum/gear/snack_packaged/upp/rice
	display_name = "Canned rice with beef"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/rice

/datum/gear/snack_packaged/upp/buckwheat
	display_name = "Canned buckwheat with pork"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/buckwheat

/datum/gear/snack_packaged/upp/pasta
	display_name = "Canned pasta"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/pasta

/datum/gear/snack_packaged/upp/vegetables
	display_name = "Canned vegetables"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/vegetables

/datum/gear/snack_packaged/upp/beef
	display_name = "Canned beef"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/meat

/datum/gear/snack_packaged/upp/stef
	display_name = "Canned stef"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/stew

/datum/gear/snack_packaged/upp/speck
	display_name = "Canned speck"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/speck

/datum/gear/snack_packaged/upp/soup
	display_name = "Canned soup"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/soup

/datum/gear/snack_packaged/upp/condensed_milk
	display_name = "Canned condensed milk"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/condensed_milk

/datum/gear/snack_packaged/upp/condensed_milk
	display_name = "Canned boiled condensed milk"
	path = /obj/item/reagent_container/food/drinks/cans/food/upp/condensed_boiled_milk

/datum/gear/snack_packaged/upp/mre
	display_name = "IRP ration pack"
	path = /obj/item/storage/box/mre/upp
	cost = 2

/datum/gear/snack_packaged/wy
	allowed_origins = WY_ORIGINS

/datum/gear/snack_packaged/wy/mre_alt
	display_name = "W-Y brand ration pack"
	path = /obj/item/storage/box/mre/wy
	cost = 2

/datum/gear/snack_packaged/wy/mre
	display_name = "CFR MRE"
	path = /obj/item/storage/box/mre/pmc
	cost = 2

/datum/gear/snack_packaged/twe
	allowed_origins = TWE_ORIGINS

/datum/gear/snack_packaged/twe/tea
	display_name = "Earl Grey tea box"
	path = /obj/item/storage/box/teabags

/datum/gear/snack_packaged/twe/candy
	display_name = "Lemon Drop candy"
	path = /obj/item/reagent_container/food/snacks/lemondrop

/datum/gear/snack_packaged/twe/mre
	display_name = "ORP MRE"
	path = /obj/item/storage/box/mre/twe
	cost = 2

/*
//================================================
				Healthy Foods
//================================================
*/

/datum/gear/snack_grown
	category = "Food (healthy)"

/datum/gear/snack_grown/apple
	display_name = "Apple"
	path = /obj/item/reagent_container/food/snacks/grown/apple

/datum/gear/snack_grown/carrot
	display_name = "Carrot"
	path = /obj/item/reagent_container/food/snacks/grown/carrot

/datum/gear/snack_grown/corn
	display_name = "Corn"
	path = /obj/item/reagent_container/food/snacks/grown/corn

/datum/gear/snack_grown/lemon
	display_name = "Lemon"
	path = /obj/item/reagent_container/food/snacks/grown/lemon

/datum/gear/snack_grown/lime
	display_name = "Lime"
	path = /obj/item/reagent_container/food/snacks/grown/lime

/datum/gear/snack_grown/orange
	display_name = "Orange"
	path = /obj/item/reagent_container/food/snacks/grown/orange

/datum/gear/snack_grown/potato
	display_name = "Potato"
	path = /obj/item/reagent_container/food/snacks/grown/potato

/*
//================================================
				Smoking
//================================================
*/

/datum/gear/smoking
	category = "Smoking"
	cost = 1

/datum/gear/smoking/cigarette
	display_name = "Cigarette"
	path = /obj/item/clothing/mask/cigarette
	slot = WEAR_FACE
	allowed_origins = FACTION_ORIGINS

/datum/gear/smoking/cigarette/cigar_classic
	display_name = "Classic cigar"
	path = /obj/item/clothing/mask/cigarette/cigar/classic
	cost = 2

/datum/gear/smoking/cigarette/cigar_premium
	display_name = "Premium cigar"
	path = /obj/item/clothing/mask/cigarette/cigar
	cost = 2

/datum/gear/smoking/cigarette/weed_joint
	display_name = "Joint of weed"
	path = /obj/item/clothing/mask/cigarette/weed
	cost = 4 //Illegal in military.

/datum/gear/smoking/cigarette/electronic_cigarette
	display_name = "Electronic cigarette"
	path = /obj/item/clothing/mask/electronic_cigarette

/datum/gear/smoking/cigarette/electronic_cigarette/cigar
	display_name = "Electronic cigar"
	path = /obj/item/clothing/mask/electronic_cigarette/cigar
	cost = 3

/datum/gear/smoking/uscm
	allowed_origins = USCM_ORIGINS
	cost = 2

/datum/gear/smoking/uscm/pack_lucky_strikes
	display_name = "Pack Of Lucky Strikes"
	path = /obj/item/storage/fancy/cigarettes/lucky_strikes

/datum/gear/smoking/uscm/pack_ladyfingers
	display_name = "Pack Of Lady Fingers"
	path = /obj/item/storage/fancy/cigarettes/lady_finger

/datum/gear/smoking/uscm/pack_arcturian
	display_name = "Pack Of Arcturian Aces"
	path = /obj/item/storage/fancy/cigarettes/arcturian_ace

/datum/gear/smoking/uscm/pack_koorlander
	display_name = "Pack Of Koorlander Golds"
	path = /obj/item/storage/fancy/cigarettes/kpack

/datum/gear/smoking/uscm/spirit
	display_name = "Pack Of American Spirit, Turquoise"
	path = /obj/item/storage/fancy/cigarettes/spirit

/datum/gear/smoking/uscm/spirit_yellow
	display_name = "Pack Of American Spirit, Yellow"
	path = /obj/item/storage/fancy/cigarettes/spirit/yellow

/datum/gear/smoking/upp
	allowed_origins = UPP_ORIGINS
	cost = 2

/datum/gear/smoking/upp/pack_laika
	display_name = "Pack Of Laika"
	path = /obj/item/storage/fancy/cigarettes/laika

/datum/gear/smoking/wy
	allowed_origins = WY_ORIGINS
	cost = 2

/datum/gear/smoking/wy/pack_emeraldgreen
	display_name = "Pack Of Emerald Greens"
	path = /obj/item/storage/fancy/cigarettes/emeraldgreen
	allowed_origins = NON_UPP_ORIGINS

/datum/gear/smoking/wy/pack_wygold
	display_name = "Pack Of Weyland Yutani Golds"
	path = /obj/item/storage/fancy/cigarettes/wypacket

/datum/gear/smoking/wy/pack_exec
	display_name = "Pack Of Executive Selects"
	path = /obj/item/storage/fancy/cigarettes/blackpack
	cost = 4

/datum/gear/smoking/twe
	allowed_origins = TWE_ORIGINS
	cost = 2

/datum/gear/smoking/twe/pack_balaji
	display_name = "Pack Of Balaji"
	path = /obj/item/storage/fancy/cigarettes/balaji

/datum/gear/smoking/lighters
	allowed_origins = FACTION_ORIGINS
	cost = 1

/datum/gear/smoking/lighters/cheap
	display_name = "Lighter, cheap"
	path = /obj/item/tool/lighter/random

/datum/gear/smoking/lighters/zippos
	cost = 2

/datum/gear/smoking/lighters/zippos/zippo
	display_name = "Lighter, zippo"
	path = /obj/item/tool/lighter/zippo

/datum/gear/smoking/lighters/zippos/black
	display_name = "Black lighter, zippo"
	path = /obj/item/tool/lighter/zippo/black

/datum/gear/smoking/lighters/zippos/blue
	display_name = "Blue lighter, zippo"
	path = /obj/item/tool/lighter/zippo/blue

/datum/gear/smoking/lighters/zippos/goldzippo
	display_name = "Lighter, golden zippo"
	path = /obj/item/tool/lighter/zippo/gold
	cost = 3

/*
//================================================
				Miscellaneous
//================================================
*/

/datum/gear/misc
	category = "Miscellaneous"
	cost = 1

/datum/gear/misc/pdt_kit
	display_name = "PDT/L kit"
	path = /obj/item/storage/box/pdt_kit/advanced

/datum/gear/misc/watch
	display_name = "Seiko Pulsemeter wristwatch"
	path = /obj/item/storage/box/watch_box
	allowed_origins = USCM_ORIGINS

/datum/gear/misc/watch/bishop
	display_name = "Seiko 7A28-6000 wristwatch"
	path = /obj/item/storage/box/watch_box/bishop
	cost = 2

/datum/gear/misc/watch/ripley
	display_name = "Seiko 7A28-7000 wristwatch"
	path = /obj/item/storage/box/watch_box/ripley
	cost = 2

/datum/gear/misc/watch/burke
	display_name = "Seiko H556-5050 wristwatch"
	path = /obj/item/storage/box/watch_box/burke
	cost = 2

/datum/gear/misc/watch/dallas
	display_name = "Samani E-125 wristwatch"
	path = /obj/item/storage/box/watch_box/dallas
	cost = 3

/datum/gear/misc/sunscreen_stick
	display_name = "USCM issue sunscreen"
	path = /obj/item/facepaint/sunscreen_stick
	allowed_origins = USCM_ORIGINS

/datum/gear/misc/dogtags
	display_name = "Attachable Dogtags"
	path = /obj/item/clothing/accessory/dogtags
	slot = WEAR_IN_ACCESSORY
	allowed_origins = USCM_ORIGINS

/datum/gear/misc/family_photo
	display_name = "Family photo"
	path = /obj/item/prop/helmetgarb/family_photo

/datum/gear/misc/bible
	display_name = "Bible"
	path = /obj/item/prop/magazine/book/bible
	cost = 1

/datum/gear/misc/bible/quran
	display_name = "Quran"
	path = /obj/item/prop/magazine/book/bible/quran

/datum/gear/misc/bible/torah
	display_name = "Torah"
	path = /obj/item/prop/magazine/book/bible/torah

/datum/gear/misc/compass
	display_name = "Compass"
	path = /obj/item/prop/helmetgarb/compass

/datum/gear/misc/bug_spray
	display_name = "Bug spray"
	path = /obj/item/prop/helmetgarb/bug_spray

/datum/gear/misc/straight_razor
	display_name = "Cut-throat razor"
	path = /obj/item/weapon/straight_razor
	cost = 3

/datum/gear/misc/survival_tool
	display_name = "Colonial Companion multi-tool"
	path = /obj/item/weapon/swiss_army_knife
	cost = 3 // Two tools & a knife in one package

/datum/gear/misc/can_opener
	display_name = "Can opener"
	path = /obj/item/tool/kitchen/can_opener

/datum/gear/misc/can_opener/compact
	display_name = "Compact can opener"
	path = /obj/item/tool/kitchen/can_opener/compact
	cost = 2

/datum/gear/misc/eye_drops
	display_name = "Eye drops"
	path = /obj/item/prop/helmetgarb/eye_drops

/datum/gear/misc/coin
	cost = 1

/datum/gear/misc/coin/iron
	display_name = "Iron Coin"
	path = /obj/item/coin/iron

/datum/gear/misc/coin/silver
	display_name = "Silver Coin"
	path = /obj/item/coin/silver
	cost = 2

/datum/gear/misc/coin/gold
	display_name = "Gold Coin"
	path = /obj/item/coin/gold
	cost = 3

/datum/gear/misc/coin/diamond
	display_name = "Diamond Coin"
	path = /obj/item/coin/diamond
	cost = 4
