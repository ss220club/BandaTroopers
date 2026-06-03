/datum/caste_datum/pony_pegasus_skirmisher
	parent_type = /datum/caste_datum/pony_xeno
	caste_type = PONY_XENO_CASTE_PEGASUS_SKIRMISHER
	display_name = "Pegasus Skirmisher"
	caste_desc = "A darting war-pegasus that harasses prey with terrifying speed."
	tier = 1
	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_1
	plasma_gain = XENO_PLASMA_GAIN_TIER_2
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	max_health = XENO_HEALTH_RUNNER
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_RUNNER
	attack_delay = -3
	behavior_delegate_type = /datum/behavior_delegate/runner_base
	tackle_min = 3
	tackle_max = 5
	tackle_chance = 45
	tacklestrength_min = 3
	tacklestrength_max = 4
	minimap_icon = "runner"
	pony_minimap_body_color = "#CDEBFA"
	pony_minimap_eye_color = "#355C7D"
	pony_minimap_show_wings = TRUE

/mob/living/carbon/xenomorph/pony/pegasus_skirmisher
	caste_type = PONY_XENO_CASTE_PEGASUS_SKIRMISHER
	name = PONY_XENO_CASTE_PEGASUS_SKIRMISHER
	desc = "A feathered shock-trooper pieced together from equine fury and xeno aggression."
	tier = 1
	pull_speed = -0.25
	viewsize = 9
	mob_size = MOB_SIZE_XENO_SMALL
	base_pixel_y = -20
	pony_render_offset_y = -1
	pony_voice_name = "skirmisher"
	pony_title = "Skirmisher"
	pony_default_armor_variant = "chitinsuit"
	pony_body_variant_pool = list("swift", "battle")
	pony_mane_front_variant_pool = list("wintershield", "punkrocker", "timid", "fatale")
	pony_mane_back_variant_pool = list("wintershield", "punkrocker", "timid", "fatale")
	pony_tail_variant_pool = list("standard", "banner", "braided")
	pony_eye_variant_pool = list("standard", "stern")
	pony_horn_variant_pool = list(PONY_XENO_NONE)
	pony_wing_variant_pool = list("pegasus", "battle")
	pony_cutie_mark_variant_pool = list("meteor", "hover", "telekinesis")
	pony_armor_variant_pool = list("chitinsuit")
	pony_body_palette_keys = list(PONY_XENO_PALETTE_BODY_PASTEL)
	pony_mane_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_tail_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT, PONY_XENO_PALETTE_MANE_DUAL)
	pony_eye_palette_keys = list(PONY_XENO_PALETTE_EYES_STANDARD)
	pony_armor_palette_keys = list(PONY_XENO_PALETTE_ARMOR_CHITIN)
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/onclick/xenohide,
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
		/datum/action/xeno_action/onclick/toggle_long_range/runner,
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/pony/pegasus_skirmisher/init_movement_handler()
	var/datum/xeno_ai_movement/linger/linger_movement = new(src)
	linger_movement.linger_range = 5
	linger_movement.linger_deviation = 1
	return linger_movement
