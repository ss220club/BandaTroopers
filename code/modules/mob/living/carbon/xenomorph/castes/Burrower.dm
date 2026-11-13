//burrower is COMBAT support
/datum/caste_datum/burrower
	caste_type = XENO_CASTE_BURROWER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_6
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_6
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_4
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_4

	deevolves_to = list(XENO_CASTE_DRONE)
	caste_desc = "A digger and trapper."
	acid_level = 2
	weed_level = WEED_LEVEL_STANDARD
	evolution_allowed = FALSE

	behavior_delegate_type = /datum/behavior_delegate/burrower_base

	tackle_min = 3
	tackle_max = 5
	tackle_chance = 40
	tacklestrength_min = 4
	tacklestrength_max = 5

	burrow_cooldown = 20
	tunnel_cooldown = 70
	widen_cooldown = 70
	tremor_cooldown = 450

	minimum_evolve_time = 7 MINUTES

	minimap_icon = "burrower"

/mob/living/carbon/xenomorph/burrower
	caste_type = XENO_CASTE_BURROWER
	name = XENO_CASTE_BURROWER
	desc = "A beefy alien with sharp claws."
	icon = 'icons/mob/xenos/burrower.dmi'
	icon_size = 64
	icon_state = "Burrower Walking"
	layer = MOB_LAYER
	plasma_stored = 100
	plasma_types = list(PLASMA_PURPLE)
	pixel_x = -12
	old_x = -12
	base_pixel_x = 0
	base_pixel_y = -20
	tier = 2
	organ_value = 1500

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/place_construction,
		/datum/action/xeno_action/onclick/build_tunnel,
		/datum/action/xeno_action/onclick/plant_weeds, //first macro
		/datum/action/xeno_action/onclick/place_trap, //second macro
		/datum/action/xeno_action/activable/burrow/ai, //third macro
		/datum/action/xeno_action/onclick/tremor/ai, //fourth macro
		/datum/action/xeno_action/active_toggle/toggle_meson_vision,
		/datum/action/xeno_action/onclick/tacmap,
		)

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/rename_tunnel,
		/mob/living/carbon/xenomorph/proc/set_hugger_reserve_for_morpher,
	)

	icon_xeno = 'icons/mob/xenos/burrower.dmi'
	icon_xenonid = 'icons/mob/xenonids/burrower.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Burrower_1","Burrower_2","Burrower_3")
	weed_food_states_flipped = list("Burrower_1","Burrower_2","Burrower_3")

	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/burrower/ex_act(severity)
	if(HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		return
	..()

/mob/living/carbon/xenomorph/burrower/attack_hand()
	if(HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		return
	..()

/mob/living/carbon/xenomorph/burrower/attackby()
	if(HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		return
	..()

/mob/living/carbon/xenomorph/burrower/get_projectile_hit_chance()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		return 0

/datum/behavior_delegate/burrower_base
	name = "Base Burrower Behavior Delegate"

/mob/living/carbon/xenomorph/burrower/init_movement_handler()
	return new /datum/xeno_ai_movement/burrower(src)

// Moving would cancel digging in, and there is nowhere to go while burrowed anyway.
/datum/xeno_ai_movement/burrower

/datum/xeno_ai_movement/burrower/ai_move_idle(delta_time)
	if(parent.action_busy || HAS_TRAIT(parent, TRAIT_ABILITY_BURROWED))
		return
	return ..()

/datum/xeno_ai_movement/burrower/ai_move_target(delta_time)
	if(parent.action_busy || HAS_TRAIT(parent, TRAIT_ABILITY_BURROWED))
		return
	return ..()

// Digs in, tunnels under the target and knocks it down when coming up.
/datum/action/xeno_action/activable/burrow/ai
	default_ai_action = TRUE
	ai_prob_chance = 40

	/// Closer than this we just walk up to the target
	var/ai_min_ambush_range = 4
	/// Tunneling takes a second per tile, so the target would be long gone from further away
	var/ai_max_ambush_range = 8
	var/ai_ambush_cooldown_time = 20 SECONDS
	COOLDOWN_DECLARE(ai_ambush_cooldown)

/datum/action/xeno_action/activable/burrow/ai/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(HAS_TRAIT(parent, TRAIT_ABILITY_BURROWED))
		// Using it again while tunneling would stop the tunnel.
		if(!parent.tunnel && !parent.used_tunnel)
			use_ability_async(get_turf(parent.current_target))
		return

	if(!ishuman(parent.current_target) || parent.used_burrow || parent.action_busy || !COOLDOWN_FINISHED(src, ai_ambush_cooldown))
		return

	var/distance = get_dist(parent, parent.current_target)
	if(distance < ai_min_ambush_range || distance > ai_max_ambush_range || !DT_PROB(ai_prob_chance, delta_time))
		return

	COOLDOWN_START(src, ai_ambush_cooldown, ai_ambush_cooldown_time)
	parent.start_ai_ability_delay()
	use_ability_async(parent.current_target)

/datum/action/xeno_action/onclick/tremor/ai
	default_ai_action = TRUE
	ai_prob_chance = 50
	plasma_cost = 100 // Spent by tremor() itself

	/// How far tremor() knocks marines down
	var/ai_tremor_range = 3

/datum/action/xeno_action/onclick/tremor/ai/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(parent.used_tremor || parent.plasma_stored < plasma_cost || HAS_TRAIT(parent, TRAIT_ABILITY_BURROWED) || !DT_PROB(ai_prob_chance, delta_time))
		return

	if(parent.count_ai_targets_in_range(ai_tremor_range) < 2)
		return

	parent.start_ai_ability_delay()
	use_ability_async()
