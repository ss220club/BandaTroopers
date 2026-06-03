/datum/ammo/xeno/acid/pony_magic
	name = "arcane spit"
	icon_state = "neuro_glob"
	damage = 18
	accuracy = HIT_ACCURACY_TIER_7
	max_range = 8
	spit_cost = 25

/datum/ammo/xeno/acid/pony_magic/spatter
	name = "arcane splash"
	icon_state = "neuro_glob"
	damage = 28
	max_range = 6

/datum/caste_datum/pony_unicorn_caster
	parent_type = /datum/caste_datum/pony_xeno
	caste_type = PONY_XENO_CASTE_UNICORN_CASTER
	display_name = "Unicorn Caster"
	caste_desc = "A unicorn with a spell-lance horn and plasma-fed ranged pressure."
	tier = 2
	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_7
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_6
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_ARMOR_MOD_MED
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_5
	spit_types = list(/datum/ammo/xeno/acid/pony_magic, /datum/ammo/xeno/acid/pony_magic/spatter)
	spit_delay = 2.5 SECONDS
	tackle_min = 2
	tackle_max = 5
	tackle_chance = 40
	tacklestrength_min = 3
	tacklestrength_max = 4
	minimap_icon = "spitter"
	pony_minimap_body_color = "#D9B8FF"
	pony_minimap_eye_color = "#5B2A86"
	pony_minimap_show_horn = TRUE

/mob/living/carbon/xenomorph/pony/unicorn_caster
	caste_type = PONY_XENO_CASTE_UNICORN_CASTER
	name = PONY_XENO_CASTE_UNICORN_CASTER
	desc = "A horned artillery pony whose spit looks more like hostile sorcery than acid."
	tier = 2
	pony_render_offset_y = -1
	pony_voice_name = "caster"
	pony_title = "Caster"
	pony_default_armor_variant = "fleshsuit"
	pony_body_variant_pool = list("swift", "battle")
	pony_mane_front_variant_pool = list("bookworm", "timid", "fatale", "wintershield")
	pony_mane_back_variant_pool = list("bookworm", "timid", "fatale", "wintershield")
	pony_tail_variant_pool = list("standard", "banner", "royal")
	pony_eye_variant_pool = list("arcane", "stern")
	pony_horn_variant_pool = list("unicorn", "regal")
	pony_wing_variant_pool = list(PONY_XENO_NONE)
	pony_cutie_mark_variant_pool = list("sigil", "telekinesis", "meteor")
	pony_armor_variant_pool = list("fleshsuit", "spacesuit")
	pony_body_palette_keys = list(PONY_XENO_PALETTE_BODY_MAGIC)
	pony_mane_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_tail_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_eye_palette_keys = list(PONY_XENO_PALETTE_EYES_MAGIC)
	pony_armor_palette_keys = list(PONY_XENO_PALETTE_ARMOR_CHITIN)
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/spitter,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit/ai,
		/datum/action/xeno_action/onclick/charge_spit,
		/datum/action/xeno_action/activable/spray_acid/spitter/ai,
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	sound_meta_magic = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_magic_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_magic_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
	)

/mob/living/carbon/xenomorph/pony/unicorn_caster/init_movement_handler()
	var/datum/xeno_ai_movement/linger/linger_movement = new(src)
	linger_movement.linger_range = 5
	linger_movement.linger_deviation = 1
	return linger_movement
