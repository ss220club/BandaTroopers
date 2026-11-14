/datum/caste_datum/pathogen/sprinter
	caste_type = PATHOGEN_CREATURE_SPRINTER
	fire_immunity = FIRE_VULNERABILITY
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	tier = 1
	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = 0
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_PLASMA_TIER_2
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	max_health = XENO_HEALTH_TIER_2
	evasion = XENO_EVASION_HIGH
	speed = XENO_SPEED_RUNNER
	attack_delay = -3

	available_strains = list()
	behavior_delegate_type = /datum/behavior_delegate/pathogen_base/sprinter
	evolves_to = list(PATHOGEN_CREATURE_BLIGHT)
	deevolves_to = list(PATHOGEN_CREATURE_BURSTER)

	tackle_min = 4
	tackle_max = 5
	tackle_chance = 40
	tacklestrength_min = 4
	tacklestrength_max = 4

	heal_resting = 1.4
	minimum_evolve_time = 5 MINUTES

	minimap_icon = "sprinter"

/mob/living/carbon/xenomorph/sprinter
	caste_type = PATHOGEN_CREATURE_SPRINTER
	name = PATHOGEN_CREATURE_SPRINTER
	desc = "A small white alien that looks like it could run fairly quickly..."
	icon = 'icons/mob/pathogen/sprinter.dmi'
	icon_state = "Sprinter Walking"
	icon_size = 64
	layer = MOB_LAYER
	plasma_types = list()
	tier = 1
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	base_pixel_x = 0
	base_pixel_y = -20
	pull_speed = -0.5
	viewsize = 9
	organ_value = 3000

	mob_size = MOB_SIZE_XENO_SMALL

	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough/pathogen,
		/datum/action/xeno_action/onclick/xeno_resting/pathogen,
		/datum/action/xeno_action/watch_xeno/pathogen,
		/datum/action/xeno_action/activable/tail_stab/pathogen,
		/datum/action/xeno_action/onclick/xenohide/pathogen,
		/datum/action/xeno_action/activable/pounce/runner/pathogen, // Macro 1
		/datum/action/xeno_action/activable/runner_skillshot/sprinter, // Macro 2
		/datum/action/xeno_action/onclick/toggle_long_range/runner/sprinter, // Macro 3
		//, // Macro 4
		//, // Macro 5
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	icon_xeno = 'icons/mob/pathogen/sprinter.dmi'
	icon_xenonid = 'icons/mob/pathogen/sprinter.dmi'


	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	mycelium_food_icon = 'icons/mob/pathogen/pathogen_weeds_64x64.dmi'
	weed_food_states = list("Sprinter_1","Sprinter_2","Sprinter_3")
	weed_food_states_flipped = list("Sprinter_1","Sprinter_2","Sprinter_3")

	AUTOWIKI_SKIP(TRUE)
	hivenumber = XENO_HIVE_PATHOGEN
	speaking_noise = "pathogen_talk"
	acid_blood_damage = 0
	bubble_icon = "pathogen"

	var/linger_range = 5
	var/linger_deviation = 1
	var/pull_direction

/mob/living/carbon/xenomorph/sprinter/initialize_pass_flags(datum/pass_flags_container/pass_flags_container)
	..()
	if (pass_flags_container)
		pass_flags_container.flags_pass |= PASS_FLAGS_CRAWLER

/mob/living/carbon/xenomorph/sprinter/recalculate_actions()
	. = ..()
	pull_multiplier *= 0.85
	if(is_zoomed)
		zoom_out()

/mob/living/carbon/xenomorph/sprinter/launch_towards(datum/launch_metadata/LM)
	if(!current_target)
		return ..()

	pull_direction = turn(get_dir(src, current_target), 180)

	if(!(pull_direction in GLOB.cardinals))
		if(abs(x - current_target.x) < abs(y - current_target.y))
			pull_direction &= (NORTH|SOUTH)
		else
			pull_direction &= (EAST|WEST)
	return ..()

/mob/living/carbon/xenomorph/sprinter/start_pulling(atom/movable/AM, lunge, no_msg)
	. = ..()

	add_temp_negative_pass_flags(PASS_FLAGS_CRAWLER)

/mob/living/carbon/xenomorph/sprinter/stop_pulling(bumped_movement = FALSE)
	. = ..()

	remove_temp_negative_pass_flags(PASS_FLAGS_CRAWLER)

/mob/living/carbon/xenomorph/sprinter/init_movement_handler()
	var/datum/xeno_ai_movement/linger/linger_movement = new(src)
	linger_movement.linger_range = linger_range
	linger_movement.linger_deviation = linger_deviation
	return linger_movement

/mob/living/carbon/xenomorph/sprinter/ai_move_target(delta_time)
	if(throwing)
		return

	if(pulling)
		if(!current_target || get_dist(src, current_target) > 10)
			INVOKE_ASYNC(src, PROC_REF(stop_pulling))
			return ..()
		if(can_move_and_apply_move_delay())
			if(!Move(get_step(loc, pull_direction), pull_direction))
				pull_direction = turn(pull_direction, pick(45, -45))
		current_path = null
		return

	..()

	if(get_dist(current_target, src) > 1)
		return

	if(!istype(current_target, /mob))
		return

	var/mob/current_target_mob = current_target

	if(!current_target_mob.is_mob_incapacitated())
		return

	if(isxeno(current_target.pulledby))
		return

	if(!DT_PROB(RUNNER_GRAB, delta_time))
		return

	INVOKE_ASYNC(src, PROC_REF(start_pulling), current_target)
	swap_hand()

/mob/living/carbon/xenomorph/sprinter/process_ai(delta_time)
	if(get_active_hand())
		swap_hand()
	return ..()

/datum/behavior_delegate/pathogen_base/sprinter
	name = "Base Sprinter Behavior Delegate"

/datum/behavior_delegate/pathogen_base/sprinter/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/onclick/xenohide/hide = get_action(bound_xeno, /datum/action/xeno_action/onclick/xenohide)
	if(hide)
		hide.post_attack()
