/datum/caste_datum/arachnid/bombardier
	caste_type = ARACHNID_CASTE_BOMBARDIER
	caste_desc = "Взрывоопасный арахнид, который самоуничтожается после прыжка в цель."
	tier = 1
	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	melee_vehicle_damage = 0
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_ARMOR_TIER_1
	max_health = XENO_HEALTH_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_5
	attack_delay = -4

	available_strains = list()
	evolves_to = list()
	deevolves_to = list()

	behavior_delegate_type = /datum/behavior_delegate/arachnid_bombardier

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 35
	tacklestrength_min = 4
	tacklestrength_max = 5

	heal_resting = 1.25
	innate_healing = TRUE

	minimum_evolve_time = 5 MINUTES

	minimap_icon = "runner"

/mob/living/carbon/xenomorph/arachnid/bombardier
	caste_type = ARACHNID_CASTE_BOMBARDIER
	name = ARACHNID_CASTE_BOMBARDIER
	desc = "Раздутый арахнид-камикадзе, взрывающийся после контакта с добычей."
	icon = 'modular/arachnid/icons/mobs/bombardier/Arachnid_Bombardir.dmi'
	icon_state = "Bombard Walking"
	icon_size = 64
	layer = MOB_LAYER
	plasma_types = list(PLASMA_CHITIN)
	tier = 1
	base_pixel_x = 0
	base_pixel_y = 0
	pull_speed = -0.5
	organ_value = 500

	mob_size = MOB_SIZE_XENO_VERY_SMALL

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/onclick/xenohide,
		/datum/action/xeno_action/activable/pounce/arachnid_bombardier,
		/datum/action/xeno_action/onclick/tacmap,
	)

	icon_xeno = 'modular/arachnid/icons/mobs/bombardier/Arachnid_Bombardir.dmi'
	icon_xenonid = 'modular/arachnid/icons/mobs/bombardier/Arachnid_Bombardir.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	weed_food_states = list("Facehugger_1", "Facehugger_2", "Facehugger_3")
	weed_food_states_flipped = list("Facehugger_1", "Facehugger_2", "Facehugger_3")

/mob/living/carbon/xenomorph/arachnid/bombardier/Initialize(mapload, ...)
	. = ..()
	// Случайное смещение спрайта для визуального разнообразия.
	pixel_x = rand(ARACHNID_BOMBARDIER_PIXEL_X_MIN, ARACHNID_BOMBARDIER_PIXEL_X_MAX)
	pixel_y = rand(ARACHNID_BOMBARDIER_PIXEL_Y_MIN, ARACHNID_BOMBARDIER_PIXEL_Y_MAX)
	old_x = pixel_x
	old_y = pixel_y

/mob/living/carbon/xenomorph/arachnid/bombardier/initialize_pass_flags(datum/pass_flags_container/pass_flags)
	..()
	if(pass_flags)
		pass_flags.flags_pass = PASS_MOB_THRU | PASS_FLAGS_CRAWLER

/// Запускает подготовку самоподрыва через поведенческий делегат.
/mob/living/carbon/xenomorph/arachnid/bombardier/proc/prime_self_destruct()
	var/datum/behavior_delegate/arachnid_bombardier/bombardier_delegate = behavior_delegate
	if(!istype(bombardier_delegate))
		return

	bombardier_delegate.prime_self_destruct()

/mob/living/carbon/xenomorph/arachnid/bombardier/pounced_mob(mob/living/L)
	. = ..()
	prime_self_destruct()

/mob/living/carbon/xenomorph/arachnid/bombardier/pounced_obj(obj/O)
	. = ..()
	prime_self_destruct()

/mob/living/carbon/xenomorph/arachnid/bombardier/pounced_turf(turf/T)
	. = ..()
	prime_self_destruct()

/datum/action/xeno_action/activable/pounce/arachnid_bombardier
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 10
	plasma_cost = 0
	distance = ARACHNID_BOMBARDIER_POUNCE_RANGE
	knockdown = TRUE
	knockdown_duration = ARACHNID_BOMBARDIER_POUNCE_KNOCKDOWN_DURATION
	freeze_self = FALSE
	can_be_shield_blocked = TRUE

/// Прыжок бомбардира с шансом промаха в радиус рядом с целью.
/datum/action/xeno_action/activable/pounce/arachnid_bombardier/use_ability(atom/A)
	var/mob/living/carbon/human/target_carbon = A
	if(istype(target_carbon) && prob(ARACHNID_BOMBARDIER_POUNCE_MISS_CHANCE))
		var/turf/target_turf = get_turf(target_carbon)
		if(target_turf)
			var/list/turf/miss_turfs = list()
			for(var/turf/open/open_turf in range(ARACHNID_BOMBARDIER_POUNCE_MISS_RADIUS, target_turf))
				if(get_dist(open_turf, target_turf) == 0)
					continue
				miss_turfs += open_turf

			if(length(miss_turfs))
				A = pick(miss_turfs)

	var/mob/living/carbon/xenomorph/arachnid/bombardier/bombardier = owner
	if(istype(bombardier))
		var/list/pounce_meta_bank = bombardier.get_sound_meta_bank(ARACHNID_SOUND_EVENT_POUNCE, null)
		var/pounce_sound = bombardier.pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_POUNCE, pounce_meta_bank, null)
		if(pounce_sound)
			playsound(bombardier, pounce_sound, bombardier.modular_get_sound_volume(ARACHNID_SOUND_VOLUME_BOMBARDIER_POUNCE), FALSE)

	return ..(A)

/// AI-использование прыжка: только по валидной цели в радиусе способности.
/datum/action/xeno_action/activable/pounce/arachnid_bombardier/process_ai(mob/living/carbon/xenomorph/pouncing_xeno, delta_time)
	var/mob/living/carbon/human/target_carbon = pouncing_xeno.current_target
	if(!istype(target_carbon))
		return FALSE

	if(pouncing_xeno.can_not_harm(target_carbon))
		return FALSE

	if(get_dist(pouncing_xeno, target_carbon) > distance)
		return FALSE

	if(!DT_PROB(ai_prob_chance, delta_time))
		return FALSE

	use_ability_async(target_carbon)
	return TRUE

/datum/behavior_delegate/arachnid_bombardier
	name = "Поведенческий делегат бомбардира"

	var/primed = FALSE
	var/detonation_timer_id = TIMER_ID_NULL
	var/detonation_delay = ARACHNID_BOMBARDIER_DETONATION_DELAY
	var/explosion_power = ARACHNID_BOMBARDIER_EXPLOSION_POWER
	var/explosion_falloff = ARACHNID_BOMBARDIER_EXPLOSION_FALLOFF

/// Подготовка к взрыву: звук, оглушение и запуск таймера детонации.
/datum/behavior_delegate/arachnid_bombardier/proc/prime_self_destruct()
	if(!bound_xeno || primed || bound_xeno.stat == DEAD)
		return

	primed = TRUE
	var/mob/living/carbon/xenomorph/arachnid/bombardier/bombardier = bound_xeno
	if(istype(bombardier))
		var/list/prime_meta_bank = bombardier.get_sound_meta_bank(ARACHNID_SOUND_EVENT_PRIME, null)
		var/prime_sound = bombardier.pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_PRIME, prime_meta_bank, null)
		if(prime_sound && bombardier.modular_should_play_sound(ARACHNID_SOUND_EVENT_PRIME, prime_sound))
			playsound(bound_xeno, prime_sound, bombardier.modular_get_sound_volume(ARACHNID_SOUND_VOLUME_BOMBARDIER_PRIME), FALSE)
	flick("Normal Arachnid Bombardier Attacking", bound_xeno)
	bound_xeno.Stun(detonation_delay)
	bound_xeno.KnockDown(detonation_delay)
	bound_xeno.update_icons()

	detonation_timer_id = addtimer(CALLBACK(src, PROC_REF(detonate_if_alive)), detonation_delay, TIMER_STOPPABLE)

/// Выполняет фактический подрыв, если бомбардир еще жив.
/datum/behavior_delegate/arachnid_bombardier/proc/detonate_if_alive()
	detonation_timer_id = TIMER_ID_NULL

	if(!bound_xeno || QDELETED(bound_xeno) || bound_xeno.stat == DEAD)
		primed = FALSE
		return

	var/turf/explosion_turf = get_turf(bound_xeno)
	if(!explosion_turf)
		primed = FALSE
		return

	var/datum/cause_data/cause_data = create_cause_data("arachnid bombardier kamikaze", bound_xeno)
	cell_explosion(explosion_turf, explosion_power, explosion_falloff, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, cause_data)

	if(bound_xeno && !QDELETED(bound_xeno) && bound_xeno.stat != DEAD)
		bound_xeno.gib(cause_data)

	primed = FALSE

/datum/behavior_delegate/arachnid_bombardier/handle_death(mob/M)
	if(detonation_timer_id != TIMER_ID_NULL)
		deltimer(detonation_timer_id)
		detonation_timer_id = TIMER_ID_NULL

	primed = FALSE

/datum/behavior_delegate/arachnid_bombardier/remove_from_xeno()
	if(detonation_timer_id != TIMER_ID_NULL)
		deltimer(detonation_timer_id)
		detonation_timer_id = TIMER_ID_NULL

	primed = FALSE

	..()
