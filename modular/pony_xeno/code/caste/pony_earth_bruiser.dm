/datum/caste_datum/pony_earth_bruiser
	parent_type = /datum/caste_datum/pony_xeno
	caste_type = PONY_XENO_CASTE_EARTH_BRUISER
	display_name = "Earth Bruiser"
	caste_desc = "A broad earth pony built to break lines and keep them broken."
	tier = 2
	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_5
	melee_vehicle_damage = XENO_DAMAGE_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_4
	armor_deflection = XENO_ARMOR_TIER_1
	max_health = XENO_HEALTH_TIER_6
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7
	behavior_delegate_type = /datum/behavior_delegate/warrior_base
	tackle_min = 3
	tackle_max = 5
	tackle_chance = 45
	tacklestrength_min = 4
	tacklestrength_max = 5
	agility_speed_increase = -0.6
	minimap_icon = "warrior"
	pony_minimap_body_color = "#8A5A44"
	pony_minimap_eye_color = "#7F5539"

/mob/living/carbon/xenomorph/pony/earth_bruiser
	caste_type = PONY_XENO_CASTE_EARTH_BRUISER
	name = PONY_XENO_CASTE_EARTH_BRUISER
	desc = "A plated earth pony whose hooves hit like a breaching ram."
	tier = 2
	pull_speed = 2
	viewsize = 10
	mob_size = MOB_SIZE_XENO
	pony_render_offset_y = 1
	pony_voice_name = "bruiser"
	pony_title = "Bruiser"
	pony_default_armor_variant = "bonearmor"
	pony_body_variant_pool = list("battle", "stout")
	pony_mane_front_variant_pool = list("wintershield", "bookworm", "dork")
	pony_mane_back_variant_pool = list("wintershield", "bookworm", "dork")
	pony_tail_variant_pool = list("standard", "braided", "royal")
	pony_eye_variant_pool = list("standard", "stern")
	pony_horn_variant_pool = list(PONY_XENO_NONE)
	pony_wing_variant_pool = list(PONY_XENO_NONE)
	pony_cutie_mark_variant_pool = list("hover", "meteor")
	pony_armor_variant_pool = list("bonearmor", "bombsuit")
	pony_body_palette_keys = list(PONY_XENO_PALETTE_BODY_EARTH)
	pony_mane_palette_keys = list(PONY_XENO_PALETTE_MANE_DUAL, PONY_XENO_PALETTE_MANE_BRIGHT)
	pony_tail_palette_keys = list(PONY_XENO_PALETTE_MANE_DUAL, PONY_XENO_PALETTE_MANE_BRIGHT)
	pony_eye_palette_keys = list(PONY_XENO_PALETTE_EYES_STANDARD)
	pony_armor_palette_keys = list(PONY_XENO_PALETTE_ARMOR_CHITIN)
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/warrior_punch,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/onclick/tacmap,
	)
