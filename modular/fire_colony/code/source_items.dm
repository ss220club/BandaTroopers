/datum/skills/civilian/survivor/pmc/lead
	name = "Survivor PMC Team Leader"
	additional_skills = list(
		SKILL_CQC = SKILL_CQC_TRAINED,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_FIREMAN = SKILL_FIREMAN_SKILLED,
		SKILL_MEDICAL = SKILL_MEDICAL_TRAINED,
		SKILL_ENDURANCE = SKILL_ENDURANCE_SURVIVOR,
		SKILL_FIREARMS = SKILL_FIREARMS_EXPERT,
		SKILL_VEHICLE = SKILL_VEHICLE_SMALL,
		SKILL_ENGINEER = SKILL_ENGINEER_TRAINED,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_LEADERSHIP = SKILL_LEAD_TRAINED,
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_JTAC = SKILL_JTAC_TRAINED,
	)


/datum/skills/civilian/survivor/pmc/co_survivor // PMC Nightmare Variant of CMB CO Survivor for Solaris Ridge
	name = "Survivor PMC Field Operations Leader"
	additional_skills = list(
		SKILL_CQC = SKILL_CQC_EXPERT,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_MELEE_WEAPONS = SKILL_MELEE_TRAINED,
		SKILL_FIREMAN = SKILL_FIREMAN_MASTER,
		SKILL_MEDICAL = SKILL_MEDICAL_MEDIC,
		SKILL_ENDURANCE = SKILL_ENDURANCE_SURVIVOR,
		SKILL_FIREARMS = SKILL_FIREARMS_EXPERT,
		SKILL_VEHICLE = SKILL_VEHICLE_SMALL,
		SKILL_ENGINEER = SKILL_ENGINEER_TRAINED,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_LEADERSHIP = SKILL_LEAD_MASTER,
		SKILL_OVERWATCH = SKILL_OVERWATCH_TRAINED,
		SKILL_JTAC = SKILL_JTAC_TRAINED,
		SKILL_INTEL = SKILL_INTEL_EXPERT,
	)

/obj/item/card/id/silver/cl/lasalle_bionational
	name = "corporate holo-badge"
	desc = "A corporate holo-badge. It's a unique Corporate blue and black."
	icon_state = "lasalle_bionational"

/obj/item/device/radio/headset/distress/lasalle_bionational
	name = "LB corporate headset"
	desc = "A headset commonly worn by Lasalle Bionational corporate personnel."
	icon_state = "generic_headset"
	frequency = LB_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/colony, /obj/item/device/encryptionkey/lasalle_bionational)
	has_hud = TRUE
	hud_type = MOB_HUD_FACTION_LB


/obj/item/device/radio/headset/distress/lasalle_bionational/lb_merc
	name = "HIG tactical headset"
	desc = "A secure tactical headset issued to Lasalle Bionational - Hazard Intervention Group operatives."
	icon_state = "mcom_headset"


/obj/item/storage/backpack/lightpack/black
	name = "\improper lightweight combat pack"
	desc = "A small, lightweight pack for expeditions and short-range operations."
	icon_state = "ERT_satchel_black"


/obj/item/storage/backpack/lightpack/black/five_slot
	max_storage_space = 15


/obj/item/storage/backpack/lightpack/black/medic
	name = "\improper lightweight medic combat pack"
	desc = "A small, lightweight medic pack for expeditions and short-range operations."
	icon_state = "ERT_satchel_medic_black"


/obj/item/storage/backpack/lightpack/black/medic/five_slot
	max_storage_space = 15


/obj/item/storage/backpack/marine/engineerpack/ert/black
	icon_state = "ERT_satchel_welder_black"
	max_storage_space = 20


/obj/item/storage/backpack/marine/engineerpack/ert/black/four_slot
	max_fuel = 100
	max_storage_space = 12


/obj/item/storage/backpack/satchel/white
	icon_state = "satchel_white"
	item_state = "satchel_white"


/obj/item/storage/backpack/satchel/black/lockable
	name = "secure leather satchel"
	is_id_lockable = TRUE


/obj/item/storage/backpack/satchel/white/lockable
	name = "secure leather satchel"
	is_id_lockable = TRUE

/obj/item/storage/belt/marine/wy/generic
	name = "\improper TM401 pattern ammo load rig"
	desc = "A slightly outdated rig, by modern standards - The TM401 is the standard load-bearing equipment of various corporate & military forces. It consists of a modular belt with various clips. This is the standard variant, designed for bulk ammunition-carrying operations."


/obj/item/storage/belt/medical/lifesaver/wy/lb_merc
	name = "\improper LB-TM624 pattern medical bag"
	desc = "The LB-TM624 is the standard load-bearing equipment of the L-B security forces. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies, and is common among medics. \nRight click its sprite and click \"toggle belt mode\" to take pills out of bottles by simply clicking them."


/obj/item/storage/belt/gun/m4a3/wy/lb_merc/b92fs_suppressed/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/b92fs/suppressed())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/b92fs(src)


/obj/item/storage/belt/marine/wy/generic/w_ek_17/fill_preset_inventory() // W/EK 17 Carbine
	for(var/i = 1 to storage_slots)
		new /obj/item/ammo_magazine/rifle/w_ek_17 (src)

/obj/item/storage/pouch/survival/synth/black/full/fill_preset_inventory()
	new /obj/item/tool/crowbar/red(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/device/radio(src)
	new /obj/item/attachable/bayonet(src)


/obj/item/storage/pouch/survival/full/lasalle
	icon_state = "soctools"


/obj/item/storage/pouch/survival/full/lasalle/fill_preset_inventory()
	new /obj/item/device/flashlight/lantern/alt(src)
	new /obj/item/tool/crowbar/tactical(src)
	new /obj/item/storage/pill_bottle/packet/kelo_oxy_mix(src) // fire colony has lot's of map hazards, effective kelo/oxy mix is necessary here, probably not on other maps.
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/radio(src)
	new /obj/item/attachable/bayonet/lb(src)
	new /obj/item/stack/medical/splint(src)


/obj/item/storage/backpack/marine/smartpack/a1/lb_black
	name = "\improper LB-S-V42A1 backpack"
	desc = "A Lasalle Bionational redesign of the S-V42 backpack, bearing a remarkable resemblance to a joint USCM and Weyland-Yutani project. Lasalle insists the similarities are purely coincidental. It features an integrated shoulder lamp."
	item_state = "b_smartpack_a1"
	icon_state = "b_smartpack_a1"

#undef BACKPACK_LIGHT_LEVEL
#undef PROTECTIVE_COST
#undef REPAIR_COST
#undef IMMOBILE_COST

#undef EXOSKELETON_ON_FILTER_SIZE
#undef EXOSKELETON_OFF_FILTER_SIZE

#undef PROTECTIVE_FORM_COLOR
#undef IMMOBILE_FORM_COLOR

/obj/item/clothing/glasses/science/blue
	icon_state = "blue"
	item_state = "glasses"


/obj/item/clothing/glasses/sunglasses/big/chrome
	name = "\improper BiMex Chromeline Shades"
	desc = "Large stylish chrome-framed shades favored by corporate personnel for their sharp appearance and practical eye protection."
	desc_lore = "Part of BiMex's executive-oriented 'ChromeLine' series, these oversized shades combine stylish chromatic flavor with durable industrial-grade lenses. Capable of shrugging off small shrapnel impacts"
	icon_state = "chrome_shades"
	item_state = "chrome_shades"
	eye_protection = EYE_PROTECTION_FLASH
	clothing_traits = list(TRAIT_BIMEX)
	flags_equip_slot = SLOT_EYES|SLOT_FACE
	flags_obj = OBJ_IS_HELMET_GARB

/obj/item/clothing/gloves/marine/lasalle_security
	name = "brown combat gloves"
	desc = "Standard issue tactical gloves used by corporate security."
	icon_state = "lasalle_brown_gloves"
	item_state = "lasalle_brown_gloves"


/obj/item/clothing/gloves/marine/fireproof_gloves
	name = "HZP-12 entry-type proximity gloves"
	desc = "Thermal-insulated boots designed for use with the HZP-12 proximity suit system."
	icon_state = "fireproof_gloves"
	item_state = "fireproof_gloves"
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_LOW
	siemens_coefficient = 0


/obj/item/clothing/gloves/marine/fireproof_gloves/Initialize(mapload)
	. = ..()


/obj/item/clothing/gloves/marine/insulated
	name = "marine insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	icon_state = "insulated"
	item_state = "insulated"
	siemens_coefficient = 0


/obj/item/clothing/gloves/marine/veteran/lb_merc
	name = "HIG combat gloves"
	desc = "A pair of reinforced black combat gloves with distinctive blue accents, standard issued to Lasalle Bionational - Hazard Intervention Group operators."
	icon_state = "lb_merc"
	item_state = "lb_merc"


/obj/item/clothing/gloves/marine/veteran/lb_merc/Initialize()
	. = ..()


/obj/item/clothing/gloves/marine/science_gloves
	name = "chemical handling gloves"
	desc = "A pair of thick protective gloves intended for handling hazardous materials, volatile compounds, and biological contaminants."
	icon_state = "long_gloves"
	item_state = "long_gloves"
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH


/obj/item/clothing/gloves/marine/science_gloves/yellow
	icon_state = "long_yellow_gloves"
	item_state = "long_yellow_gloves"

/obj/item/clothing/gloves/black_leather
	name = "stylish leather gloves"
	desc = "Supple, black leather gloves crafted from the finest leather. Stylish, durable, and ready for work or play."
	icon_state = "black_leather"
	item_state = "black"

/obj/item/clothing/head/science_coif
	name = "sterile coif"
	desc = "A close-fitting sterile head covering, protecting the wearer from hazardous materials, intended for laboratory and cleanroom environments."
	icon = 'icons/obj/items/clothing/hats/hats.dmi'
	icon_state = "scientist_coif"
	blood_overlay_type = "surgcap"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/LASALLE.dmi'
	)

	flags_inv_hide = HIDEALLHAIR


/obj/item/clothing/head/science_coif/blue
	icon_state = "scientist_coif_blue"


/obj/item/clothing/head/science_coif/purple
	icon_state = "scientist_coif_purple"


/obj/item/clothing/head/science_coif/green
	icon_state = "scientist_coif_green"

/obj/item/clothing/head/helmet/marine/veteran/lb_merc
	name = "\improper HIG combat helmet"
	desc = "A fully enclosed combat helmet issued to Lasalle Bionational - Hazard Intervention Group operators. It is reinforced and has an integrated visor. Designed for high-risk operations in hostile environments."
	icon_state = "lb_merc"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/LASALLE.dmi',
	)
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = BODY_FLAG_HEAD|BODY_FLAG_FACE|BODY_FLAG_EYES
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	flags_marine_helmet = NO_FLAGS

	built_in_visors = list(new /obj/item/device/helmet_visor)



/obj/item/clothing/head/helmet/marine/veteran/lb_merc/Initialize()
	. = ..()


/obj/item/clothing/head/helmet/marine/veteran/lb_merc/leader
	name = "\improper HIG team leader combat helmet"
	desc = "A fully enclosed combat helmet issued to Lasalle Bionational - Hazard Intervention Group team leaders. It's single blue command markings and intergrated telemetry beacon clearly distinguish the wearer from the other members of an intervention team."
	icon_state = "lb_merc_lead"


/obj/item/clothing/head/helmet/marine/veteran/lb_merc/engi
	name = "\improper HIG technical specialist combat helmet"
	desc = "A fully enclosed combat helmet issued to Lasalle Bionational - Hazard Intervention Group technical specialists. It's enlarged visor provides improved visibility, it also has an integrated deployable welding visor."
	icon_state = "lb_merc_engi"
	built_in_visors = list(new /obj/item/device/helmet_visor, new /obj/item/device/helmet_visor/welding_visor)


/obj/item/clothing/head/helmet/marine/veteran/lb_merc/commander
	name = "\improper HIG operations commander combat helmet"
	desc = "A fully enclosed combat helmet issued to Lasalle Bionational - Hazard Intervention Group operations commanders. It's double blue command markings and intergrated telemetry beacon clearly distinguish the wearer from the other members of an intervention team."
	icon_state = "lb_merc_co"
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_MEDIUM


/obj/item/clothing/head/helmet/marine/veteran/pmc/corporate/lasalle_security
	name = "\improper Lasalle Bionational security helmet"
	desc = "A full face helmet worn by Lasalle Bionatonal corporate security assets."
	contained_sprite = FALSE
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/LASALLE.dmi'
	)
	icon_state = "lasalle_security_helmet"
	item_state = "lasalle_security_helmet"

	flags_inv_hide = HIDEEARS|HIDEEYES|HIDETOPHAIR


/obj/item/clothing/head/helmet/marine/veteran/pmc/corporate/lasalle_security/Initialize()
	. = ..()

/obj/item/clothing/mask/gas/pmc/lasalle
	name = "LBN-4 gasmask"
	desc = "A lightly reinforced gasmask developed by Lasalle Bionational for hazardous security and industrial operations."
	icon_state = "lasalle_gas"
	item_state = "lasalle_gas"
	icon = 'icons/obj/items/clothing/masks/gasmasks.dmi'
	item_icons = list(
		WEAR_FACE = 'icons/mob/humans/onmob/clothing/masks/gasmasks.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/clothing/masks_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/clothing/masks_righthand.dmi',
	)
	item_state_slots = list(WEAR_L_HAND = "gas_alt", WEAR_R_HAND = "gas_alt")


/obj/item/clothing/shoes/leather/fancy
	name = "fancy leather shoes"
	desc = "A fancy pair of leather shoes."
	icon_state = "fancy"

/obj/item/clothing/shoes/marine/corporate/lasalle_security
	name = "brown combat boots"
	icon_state = "lasalle_brown_boots"
	item_state = "lasalle_brown_boots"
	desc = "These synth-leather boots seem high quality when first worn, but quickly detoriate, especially in the environments the corporate security members these are issued to operate in. Still, better than nothing."


/obj/item/clothing/shoes/silver_white
	name = "sterile work shoes"
	desc = "A pair of silver-white industrial work shoes designed for laboratory and cleanroom use."
	icon_state = "silver_shoes"
	item_state = "silver_shoes"


/obj/item/clothing/shoes/marine/fireproof_boots
	name = "HZP-12 entry-type proximity boots"
	desc = "Thermal-insulated boots designed for use with the HZP-12 proximity suit system."
	icon_state = "fireproof_boots"
	item_state = "fireproof_boots"
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_LOW


/obj/item/clothing/shoes/marine/fireproof_boots/Initialize(mapload)
	. = ..()


/obj/item/clothing/shoes/veteran/pmc/lb_merc/knife
	spawn_item_type = /obj/item/attachable/bayonet/lb


/obj/item/clothing/suit/armor/vest/seegson_security
	name = "\improper Seegson security armor"
	desc = "An old Seegson security armored vest that protects against some damage."
	icon_state = "seegson_security_armor"
	item_state = "seegson_security_armor"
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/SEEGSON.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/SEEGSON.dmi'
	)
	uniform_restricted = null


/obj/item/clothing/head/bio_hood/lasalle
	name = "LBN-4 containment helmet"
	desc = "A sealed hazard-response helmet manufactured for Lasalle Bionational personnel operating in hazardous environments. It has lightweight armor plating."
	icon_state = "bio_lasalle"
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_LOW


/obj/item/clothing/suit/bio_suit/lasalle
	name = "LBN-4 containment suit"
	desc = "A sealed hazard-response suit manufactured for Lasalle Bionational personnel operating in hazardous environments. It has lightweight armor plating."
	icon_state = "bio_lasalle"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_LOW


/obj/item/clothing/suit/storage/CMB/trenchcoat/white
	name = "\improper white trench-coat"
	desc = "A worn, white, old style trench-coat. When a bum sees a dick coming, he don't stick around."
	icon_state = "trench_white"
	item_state = "trench_white"


/obj/item/clothing/suit/storage/CMB/trenchcoat/blue
	name = "\improper blue trench-coat"
	desc = "A worn, blue, old style trench-coat. When a bum sees a dick coming, he don't stick around."
	icon_state = "trench_blue"
	item_state = "trench_blue"

/obj/item/clothing/suit/storage/labcoat/lasalle
	name = "sealed research coat"
	desc = "A high-quality lab coat worn by Lasalle Bionational science personnel. Constructed from durable synthetic materials for work in hazardous research environments."
	icon_state = "labcoat"
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/LASALLE.dmi'
	)
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW


/obj/item/clothing/suit/storage/labcoat/lasalle/green
	icon_state = "labcoat_green"


/obj/item/clothing/suit/storage/labcoat/lasalle/blue
	icon_state = "labcoat_blue"


/obj/item/clothing/suit/storage/labcoat/lasalle/purple
	icon_state = "labcoat_purple"

/obj/item/clothing/suit/storage/marine/veteran/lb_merc
	name = "\improper M3-LB combat armor"
	desc = "A heavily modified, proprietary Lasalle Bionational variant of the Armat Systems M3 armor platform. Issued exclusively to Lasalle Bionational - Hazard Intervention Group operatives. Designed for hazardous intervention and high-threat operations."
	icon_state = "lb_merc"
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/LASALLE.dmi'
	)
	flags_bodypart_hidden = BODY_FLAG_CHEST|BODY_FLAG_LEGS
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/lb_merc)
	item_state_slots = list(WEAR_JACKET = "lb_merc")
	lamp_icon = "lamp_neon"
	lamp_light_color = LIGHT_COLOR_XENON
	light_color = LIGHT_COLOR_XENON


/obj/item/clothing/suit/storage/marine/veteran/lb_merc/Initialize()
	. = ..()


/obj/item/clothing/suit/storage/marine/veteran/lb_merc/synth
	name = "\improper M3-LB Synthetic combat armor"
	desc = "A heavily modified Lasalle Bionational variant of the Armat Systems M3 armor platform. Designed exclusively for Lasalle Bionational - Hazard Intervention Group synthetic support units, its armor inserts have been removed in favor of reduced weight and unrestricted mobility."
	icon_state = "lb_merc"
	item_state_slots = list(WEAR_JACKET = "lb_merc")
	time_to_unequip = 0.5 SECONDS
	time_to_equip = 1 SECONDS
	armor_melee = CLOTHING_ARMOR_NONE
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_NONE
	armor_rad = CLOTHING_ARMOR_NONE
	armor_internaldamage = CLOTHING_ARMOR_NONE
	storage_slots = 3
	slowdown = SLOWDOWN_ARMOR_SUPER_LIGHT


/obj/item/clothing/suit/storage/marine/veteran/lb_merc/synth/Initialize()
	flags_atom |= NO_NAME_OVERRIDE
	flags_marine_armor |= SYNTH_ALLOWED
	return ..()


/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/lasalle_security
	name = "\improper M1 pattern corporate security armor"
	desc = "A basic vest with a Lasalle Bionational logo on the right breast. This is commonly worn by low-level guards protecting Lasalle Bionational facilities."
	contained_sprite = FALSE
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/LASALLE.dmi'
	)

	lamp_light_color = LIGHT_COLOR_XENON
	light_color = LIGHT_COLOR_XENON
	lamp_icon = "lamp_neon"


/obj/item/clothing/suit/storage/marine/veteran/pmc/light/corporate/lasalle_security/Initialize()
	. = ..()

/obj/item/clothing/suit/storage/marine/cbrn/lava //child of cbrn suit for fireproofing and hood toggling
	name = "HZP-12 entry-type proximity suit"
	desc = "The 'HZP-12' is a bulky extreme environment suit manufactured by Lorenz SysTech Development under Seegson industrial contract for personnel operating in severe thermal hazard zones."
	icon = 'icons/obj/items/clothing/suits/hazard.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/hazard.dmi',
	)
	icon_state = "fireproof_suit"
	item_state = "fireproof_suit"
	uniform_restricted = null
	storage_slots = 1
	flags_inv_hide = HIDEJUMPSUIT|HIDETAIL
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	allowed = list(
		/obj/item/tool/extinguisher,

		/obj/item/device/flashlight,
		/obj/item/device/healthanalyzer,
		/obj/item/device/radio,
		/obj/item/tank/emergency_oxygen,
		/obj/item/tool/crowbar,
		/obj/item/tool/pen,
	)

	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_inventory = NOPRESSUREDMAGE
	fire_intensity_resistance = BURN_LEVEL_TIER_1
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROT
	unacidable = TRUE
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	armor_melee = CLOTHING_ARMOR_NONE
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_NONE
	armor_rad = CLOTHING_ARMOR_NONE
	armor_internaldamage = CLOTHING_ARMOR_NONE


/obj/item/clothing/suit/storage/marine/cbrn/lava/Initialize(mapload)
	. = ..()

/obj/item/clothing/under/lasalle
	name = "lasalle bionational uniform"
	desc = "A heavy-duty uniform commonly worn by Lasalle Bionational workers & civilians."
	icon_state = "civilian_base"
	item_state = "civilian_base"
	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/LASALLE.dmi',
	)


/obj/item/clothing/under/lasalle/grey
	icon_state = "civilian_base_grey"
	item_state = "civilian_base_grey"


/obj/item/clothing/under/lasalle/yellow
	icon_state = "civilian_base_yellow"
	item_state = "civilian_base_yellow"


/obj/item/clothing/under/rank/synthetic/joe/fire/overalls
	name = "\improper Working Joe Hazardous Uniform"
	desc = "A reinforced uniform used for Synthetic labor in hazardous areas. Comes with an additional layer for liquid hazards. Tomorrow, Together."
	icon_state = "working_joe_fire_overalls"
	worn_state = "working_joe_fire_overalls"
	unacidable = TRUE


/obj/item/clothing/under/marine/veteran/pmc/corporate/lasalle_security
	name = "\improper Lasalle Bionational corporate security uniform"
	desc = "An armored uniform worn by Lasalle Bionational corporate security members."
	contained_sprite = FALSE
	icon_state = "lasalle_security_uniform"
	worn_state = "lasalle_security_uniform"
	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/LASALLE.dmi'

	item_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/LASALLE.dmi'
	)

	suit_restricted = null


/obj/item/clothing/under/marine/veteran/pmc/corporate/lasalle_security/Initialize()
	. = ..()


/obj/item/clothing/under/rank/scientist/lasalle
	name = "research duty uniform"
	desc = "A sterile sleeveless research uniform, commonly issued to research and scientific personnel operating in corporate laboratory facilities."
	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/LASALLE.dmi',
	)
	icon_state = "science_outfit"
	worn_state = "science_outfit"
	armor_melee = CLOTHING_ARMOR_NONE
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_LOW
	armor_internaldamage = CLOTHING_ARMOR_LOW
	flags_jumpsuit = FALSE


/obj/item/clothing/under/rank/scientist/lasalle/blue
	icon_state = "science_outfit_blue"
	worn_state = "science_outfit_blue"


/obj/item/clothing/under/rank/scientist/lasalle/purple
	icon_state = "science_outfit_purple"
	worn_state = "science_outfit_purple"


/obj/item/clothing/under/rank/scientist/lasalle/green
	icon_state = "science_outfit_green"
	worn_state = "science_outfit_green"


/obj/item/clothing/under/lasalle/drysuit
	icon_state = "civilian_base_alt"
	item_state = "civilian_base_alt"


/obj/item/clothing/under/lasalle/grey/drysuit
	icon_state = "civilian_base_grey_alt"
	item_state = "civilian_base_grey_alt"


/obj/item/clothing/under/lasalle/yellow/drysuit
	icon_state = "civilian_base_yellow_alt"
	item_state = "civilian_base_yellow_alt"


/obj/item/clothing/under/marine/veteran/lb_merc
	name = "\improper HIG combat jumpsuit"
	desc = "A fitted black combat jumpsuit designed for Lasalle Bionational - Hazard Intervention Group operators. It bears the insignia of Lasalle Bionational."

	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/LASALLE.dmi'
	item_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/LASALLE.dmi',
	)
	icon_state = "lb_merc"
	worn_state = "lb_merc"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT


/obj/item/clothing/under/marine/veteran/lb_merc/Initialize()
	. = ..()

/obj/item/clothing/accessory/patch/lasalle
	name = "Lasalle Bionational Corporation patch"
	desc = "A patch bearing the insignia of Lasalle Bionational Corporation. Known for cutting-edge biological research and controversial experiments, it's emblem represents progress pursued at any cost."
	icon_state = "lasalle"
	item_state_slots = list(WEAR_AS_GARB = "lasalle")


/obj/item/clothing/accessory/storage/droppouch/black
	name = "black drop pouch"
	icon_state = "drop_pouch_black"


/obj/item/weapon/gun/pistol/mod88
	name = "\improper 88 Mod 4 combat pistol"
	desc = "Standard issue USCM firearm. Also found in the hands of Weyland-Yutani PMC teams. Fires 9mm armor shredding rounds and is capable of 3-round burst."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/WY/pistols.dmi'
	icon_state = "_88m4" // to comply with css standards
	item_state = "_88m4"
	lineart_gun_icon = "type88"
	fire_sound = "88m4"
	firesound_volume = 20
	reload_sound = 'sound/weapons/gun_88m4_reload.ogg'
	unload_sound = 'sound/weapons/gun_88m4_unload.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/mod88
	force = 8
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AMMO_COUNTER
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor/sleek,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under_barrel,
		/obj/item/attachable/reflex,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot/small,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/mod88,
	)


/obj/item/weapon/gun/pistol/mod88/Initialize()
	. = ..()


/obj/item/weapon/gun/pistol/mod88/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 8, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 18, "stock_y" = 15)


/obj/item/weapon/gun/pistol/mod88/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4


/obj/item/weapon/gun/rifle/w_ek_17
	name = "\improper W/EK 17 Carbine"
	desc = "A 7.6mm pulse-action carbine, developed for close quarters combat aboard starships, space stations and in dense urban environments. Designed and produced by the previously German (now independent and member to the ICSC) Ecke-and-Associates Arms Combine."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony/assault_rifles.dmi'
	icon_state = "w_ek_17"
	lineart_gun_icon = "m16a1"
	item_state = "w_ek_17"

	fire_sound = 'sound/weapons/gun_w_ek.ogg'

	current_mag = /obj/item/ammo_magazine/rifle/w_ek_17
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/bayonet/antique,
		/obj/item/attachable/bayonet/custom,
		/obj/item/attachable/bayonet/wy,
		/obj/item/attachable/bayonet/custom/red,
		/obj/item/attachable/bayonet/custom/blue,
		/obj/item/attachable/bayonet/custom/black,
		/obj/item/attachable/bayonet/tanto,
		/obj/item/attachable/bayonet/tanto/blue,
		/obj/item/attachable/bayonet/rmc_replica,
		/obj/item/attachable/bayonet/rmc,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under_barrel,
		/obj/item/attachable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/extended_barrel/vented,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/flamer/advanced,
		/obj/item/attachable/attached_gun/shotgun,
		/obj/item/attachable/attached_gun/extinguisher,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/rifle/w_ek_17, // Stock
		)

	starting_attachment_types = list(/obj/item/attachable/stock/rifle/w_ek_17)
	map_specific_decoration = FALSE
	start_automatic = TRUE
	wield_delay = WIELD_DELAY_FAST


/obj/item/weapon/gun/rifle/w_ek_17/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 20, "under_x" = 22, "under_y" = 13, "stock_x" = 24, "stock_y" = 5)


/obj/item/weapon/gun/rifle/w_ek_17/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_LMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_LMG)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/smg/a_m36
	name = "\improper A-M36 Experimental"
	desc = "An experimental directed-energy SMG developed for Lasalle Bionational's corporate security forces. Issued to high-threat response teams and select elite personnel, its high-energy laser bursts are capable of occasionally igniting organic targets."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony/smgs.dmi'
	icon_state = "a_m36"
	item_state = "a_m36"
	lineart_gun_icon = "m39"
	fire_sound = 'sound/weapons/a_m36.ogg'
	current_mag = /obj/item/ammo_magazine/smg/a_m36
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	wield_delay = WIELD_DELAY_MIN
	aim_slowdown = SLOWDOWN_ADS_QUICK_MINUS
	flags_equip_slot = SLOT_BACK
	muzzle_flash = "muzzle_laser"
	muzzle_flash_color = COLOR_LASER_RED

	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot/small,
		/obj/item/attachable/reflex,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lasersight/micro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/bayonet/antique,
		/obj/item/attachable/bayonet/custom,
		/obj/item/attachable/bayonet/wy,
		/obj/item/attachable/bayonet/custom/red,
		/obj/item/attachable/bayonet/custom/blue,
		/obj/item/attachable/bayonet/custom/black,
		/obj/item/attachable/bayonet/tanto,
		/obj/item/attachable/bayonet/tanto/blue,
		/obj/item/attachable/bayonet/rmc_replica,
		/obj/item/attachable/bayonet/rmc,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

	start_automatic = TRUE

	random_spawn_chance = 100
	random_spawn_rail = list(
		/obj/item/attachable/reddot/small,
	)
	random_spawn_under = list(
		/obj/item/attachable/lasersight/micro,
	)


/obj/item/weapon/gun/smg/a_m36/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 13, "rail_y" = 21, "under_x" = 21, "under_y" = 15, "stock_x" = 24, "stock_y" = 15)


/obj/item/weapon/gun/smg/a_m36/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	fa_max_scatter = SCATTER_AMOUNT_TIER_10 + 0.5


/obj/item/weapon/gun/smg/a_m36/load_into_chamber(mob/user)
	if(in_chamber && !active_attachable)
		var/obj/projectile/projectile = create_bullet(ammo, initial(name))
		projectile.set_light(1, 1, LIGHT_COLOR_RED)
		in_chamber = projectile
		return in_chamber

	if(active_attachable)
		if(shots_fired >= 1) // This is what you'll want to remove if you want automatic underbarrel guns in the future
			SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE)
			return

		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			var/obj/projectile/bullet = create_bullet(active_attachable.ammo, initial(name))
			for(var/entry in active_attachable.traits_to_give_attached)
				var/list/L
				if(istext(entry))
					L = active_attachable.traits_to_give_attached[entry].Copy()
				else
					L = list(entry) + active_attachable.traits_to_give_attached[entry]
				bullet.apply_bullet_trait(L)
			return bullet
		else
			to_chat(user, SPAN_WARNING("[active_attachable] is empty!"))
			to_chat(user, SPAN_NOTICE("You disable [active_attachable]."))
			playsound(user, active_attachable.activation_sound, 15, 1)
			active_attachable.activate_attachment(src, null, TRUE)
	else
		return ready_in_chamber()//We're not using the active attachable, we must use the active mag if there is one.


/obj/item/weapon/gun/smg/a_m36/Initialize()
	. = ..()

/obj/item/ammo_magazine/pistol/mod88/penetrating
	name = "\improper 88M4 wall-penetrating magazine (9mm)"
	desc = "A wall-penetrating 9mm pistol magazine for the Mod88."
	default_ammo = /datum/ammo/bullet/pistol/ap/penetrating
	ammo_band_color = AMMO_BAND_COLOR_PENETRATING

/obj/item/ammo_magazine/rifle/w_ek_17
	name = "\improper W/EK 17 magazine (7.6mm)"
	desc = "A 7.6mm carbine magazine."
	caliber = "7.6mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/colony/assault_rifles.dmi'
	icon_state = "w_ek_17"
	item_state = "generic_mag"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/weapons/ammo_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/weapons/ammo_righthand.dmi'
		)
	w_class = SIZE_MEDIUM
	default_ammo = /datum/ammo/bullet/rifle/w_ek_17
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/rifle/w_ek_17
	ammo_band_icon = "+w_ek_17_band"
	ammo_band_icon_empty = "+w_ek_17_band_e"

/obj/item/ammo_magazine/smg/a_m36
	name = "\improper A-M36 Charge Pack"
	desc = "A one-time use, disposable high-capacity energy cell designed for the A-M36 Experimental."
	default_ammo = /datum/ammo/bullet/smg/a_m36
	flags_magazine = NO_FLAGS
	caliber = "9x19mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/colony/smgs.dmi'
	icon_state = "a_m36"
	w_class = SIZE_MEDIUM
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/smg/a_m36
