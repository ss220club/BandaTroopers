/datum/caste_datum/arachnid
	caste_type = ARACHNID_CASTE_WARRIOR
	caste_desc = "Четырехногий арахнид воин. Основная действующая многочисленная боевая единица улья."
	tier = 2
	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_4
	melee_vehicle_damage = 0
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1 // 10
	armor_deflection = XENO_ARMOR_TIER_2 // 25
	max_health = XENO_HEALTH_TIER_3 // 350
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_5
	attack_delay = -4

	available_strains = list()
	evolves_to = list()
	deevolves_to = list()

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 45
	tacklestrength_min = 4
	tacklestrength_max = 5

	heal_resting = 1.5
	innate_healing = TRUE

	minimum_evolve_time = 5 MINUTES

	minimap_icon = "runner"

/mob/living/carbon/xenomorph/arachnid
	caste_type = ARACHNID_CASTE_WARRIOR
	name = ARACHNID_CASTE_WARRIOR
	desc = "Небольшой красный арахнид. Быстрый штурмовик, который сближается и утаскивает жертву."
	icon = 'modular/arachnid/icons/mobs/warrior/arachnid.dmi'
	icon_state = "Arachnid Walking"
	icon_size = 64
	plasma_types = list(PLASMA_CHITIN)
	tier = 2
	pixel_x = -16 // Смещение для 2x2 спрайта.
	old_x = -16
	base_pixel_x = 0
	base_pixel_y = -20
	pull_speed = -0.5
	organ_value = 500

	mob_size = MOB_SIZE_XENO

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/onclick/tacmap,
	)

	icon_xeno = 'modular/arachnid/icons/mobs/warrior/arachnid.dmi'
	icon_xenonid = 'modular/arachnid/icons/mobs/warrior/Arachnid_Green2.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_64x64.dmi'
	weed_food_states = list("Warrior_old_1", "Warrior_old_2", "Warrior_old_3")
	weed_food_states_flipped = list("Warrior_old_1", "Warrior_old_2", "Warrior_old_3")

/// Инициализирует обработчик движения арахнида (с лазанием по структурам).
/mob/living/carbon/xenomorph/arachnid/init_movement_handler()
	return new /datum/xeno_ai_movement/arachnid(src)

/// Движение в idle: при перетаскивании в приоритете маршрут к улью.
/mob/living/carbon/xenomorph/arachnid/ai_move_idle(delta_time)
	if(!ai_movement_handler)
		CRASH("Для [src] не найден валидный обработчик движения!")

	var/mob/living/pulling_target = pulling
	return (istype(pulling_target) && length(GLOB.ai_hives)) ? ai_movement_handler.ai_move_hive(delta_time) : ai_movement_handler.ai_move_idle(delta_time)

/// Движение к цели: при перетаскивании в приоритете маршрут к улью.
/mob/living/carbon/xenomorph/arachnid/ai_move_target(delta_time)
	if(!ai_movement_handler)
		CRASH("Для [src] не найден валидный обработчик движения!")

	var/mob/living/pulling_target = pulling
	return (istype(pulling_target) && length(GLOB.ai_hives)) ? ai_movement_handler.ai_move_hive(delta_time) : ai_movement_handler.ai_move_target(delta_time)

/// Захват арахнида: наносит боль и может перевести цель в захват ксеноморфа.
/mob/living/carbon/xenomorph/arachnid/start_pulling(atom/movable/AM, lunge)
	if(!check_state() || agility || !isliving(AM))
		return FALSE

	if(!prob(ARACHNID_GRAB_CHANCE))
		return FALSE

	var/mob/living/L = AM
	var/should_neckgrab = !can_not_harm(L) && (lunge || prob(ARACHNID_NECKGRAB_CHANCE))

	if(!QDELETED(L) && !QDELETED(L.pulledby) && L != src) // Перехват перетаскивания у другого моба.
		visible_message(SPAN_WARNING("[src] вырвал [L.pulledby] из хватки [L]!"), null, null, ARACHNID_VISIBLE_MESSAGE_RANGE_CLOSE)
		L.pulledby.stop_pulling()

	. = ..(L, lunge, should_neckgrab)

	if(.)
		var/pain_to_cause = PAIN_XENO_DRAG
		if(should_neckgrab && L.mob_size < MOB_SIZE_BIG)
			pain_to_cause += PAIN_XENO_GRAB
			L.pulledby = src
			visible_message(SPAN_XENOWARNING("\The [src] крепко зажал [L]!"), SPAN_XENOWARNING("Вы зажали [L]!"))

		L.pain.apply_pain(pain_to_cause)
		grab_level = GRAB_XENO
		if(prob(ARACHNID_HISS_EMOTE_CHANCE))
			emote("hiss")

/// Логика завершения перетаскивания с коррекцией при bump.
/mob/living/carbon/xenomorph/arachnid/stop_pulling(bumped_movement = FALSE)
	// Если цель сорвалась из хвата из-за bump, подтягиваем ее обратно.
	if(bumped_movement && grab_level == GRAB_XENO && get_dir(src, pulling) == dir)
		pulling.loc = get_step_towards(src, pulling)
	else
		return ..()

/// Основная AI-логика intent'ов и триггеров боевого звука.
/mob/living/carbon/xenomorph/arachnid/process_ai(delta_time)
	var/mob/living/pulling_target = pulling
	var/mob/living/potential_target = current_target

	if(istype(pulling_target))
		if(get_active_hand())
			swap_hand()
		ai_active_intent = INTENT_DISARM

	else if(istype(potential_target))
		var/mob/living/carbon/xenomorph/other_xenomorph = potential_target.pulledby
		ai_active_intent = (istype(other_xenomorph) && IS_SAME_HIVENUMBER(src, other_xenomorph)) ? INTENT_DISARM : INTENT_GRAB
		if(prob(ARACHNID_COMBAT_SOUND_TRIGGER_CHANCE))
			play_combat_sound()

	ai_active_intent = (prob(ARACHNID_HARM_PULL_CHANCE)) ? INTENT_HARM : ai_active_intent

	return ..()
