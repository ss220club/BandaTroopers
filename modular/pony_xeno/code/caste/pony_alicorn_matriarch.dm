/datum/ammo/xeno/toxin/queen/pony_royal
	name = "royal starfire"
	icon_state = "neuro_glob"
	spit_cost = 45
	effect_power = 2
	accuracy = HIT_ACCURACY_TIER_6 * 2
	max_range = 7

/datum/caste_datum/pony_alicorn_matriarch
	parent_type = /datum/caste_datum/pony_xeno
	caste_type = PONY_XENO_CASTE_ALICORN_MATRIARCH
	display_name = "Alicorn Matriarch"
	caste_desc = "A regal hive-sovereign with both wings and horn, commanding the battlefield like a living omen."
	tier = 0
	melee_damage_lower = XENO_DAMAGE_TIER_5
	melee_damage_upper = XENO_DAMAGE_TIER_7
	melee_vehicle_damage = XENO_DAMAGE_TIER_9
	max_health = XENO_HEALTH_QUEEN * 4
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_10 * 2
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_10
	armor_deflection = XENO_ARMOR_TIER_4
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_QUEEN
	spit_types = list(/datum/ammo/xeno/toxin/queen/pony_royal, /datum/ammo/xeno/acid/pony_magic/spatter)
	evolution_allowed = FALSE
	fire_immunity = FIRE_IMMUNITY_NO_DAMAGE|FIRE_IMMUNITY_NO_IGNITE
	can_be_revived = FALSE
	royal_caste = TRUE
	spit_delay = 20
	tackle_min = 3
	tackle_max = 6
	tackle_chance = 55
	tacklestrength_min = 5
	tacklestrength_max = 6
	aura_strength = 4
	minimap_icon = "xenoqueen"
	pony_minimap_body_color = "#D4C3FF"
	pony_minimap_eye_color = "#5B2A86"
	pony_minimap_show_horn = TRUE
	pony_minimap_show_wings = TRUE
	pony_minimap_crown = TRUE

/mob/living/carbon/xenomorph/pony/alicorn_matriarch
	caste_type = PONY_XENO_CASTE_ALICORN_MATRIARCH
	name = PONY_XENO_CASTE_ALICORN_MATRIARCH
	desc = "A towering alicorn brood-mother plated in royal barding and hive malice."
	tier = 0
	base_pixel_y = -14
	pull_speed = 2
	viewsize = 12
	mob_size = MOB_SIZE_BIG
	pony_render_offset_x = 1
	pony_render_offset_y = 3
	pony_directional_north_x = 0
	pony_directional_north_y = -2
	pony_directional_south_x = 0
	pony_directional_south_y = 1
	pony_directional_east_x = 1
	pony_directional_east_y = 0
	pony_directional_west_x = -1
	pony_directional_west_y = 0
	pony_voice_name = "matriarch"
	pony_title = "Matriarch"
	pony_default_armor_variant = "spacesuit"
	pony_body_variant_pool = list("royal")
	pony_mane_front_variant_pool = list("fatale", "wintershield", "bookworm")
	pony_mane_back_variant_pool = list("fatale", "wintershield", "bookworm")
	pony_tail_variant_pool = list("royal", "banner")
	pony_eye_variant_pool = list("arcane")
	pony_horn_variant_pool = list("regal")
	pony_wing_variant_pool = list("royal")
	pony_cutie_mark_variant_pool = list("sigil", "telekinesis")
	pony_armor_variant_pool = list("spacesuit", "bombsuit")
	pony_body_palette_keys = list(PONY_XENO_PALETTE_BODY_ROYAL)
	pony_mane_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_tail_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_eye_palette_keys = list(PONY_XENO_PALETTE_EYES_MAGIC)
	pony_armor_palette_keys = list(PONY_XENO_PALETTE_ARMOR_CHITIN)
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/onclick/queen_word,
		/datum/action/xeno_action/onclick/psychic_whisper,
		/datum/action/xeno_action/onclick/psychic_radiance,
		/datum/action/xeno_action/activable/gut,
		/datum/action/xeno_action/activable/xeno_spit/queen_macro/ai,
		/datum/action/xeno_action/onclick/screech/ai,
		/datum/action/xeno_action/onclick/shift_spits,
		/datum/action/xeno_action/onclick/tacmap,
	)
	sound_meta_magic = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_magic_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_magic_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_royal_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_MEDIUM),
	)
