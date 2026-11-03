//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/// Сколько бонуса к CQC уже выдано телосложением. 0 — ничего.
/mob/living/carbon/human/var/body_type_cqc_bonus_applied = 0

/// Телосложение == Ripped?
/// Работает независимо от того, хранится ли body_type как строка,
/// как путь /datum/body_type/ripped или как сам датум.
/mob/living/carbon/human/proc/is_body_type_ripped()
	if(istext(body_type))
		return (lowertext(body_type) == "ripped")
	if(istype(body_type, /datum/body_type/ripped))
		return TRUE
	if(ispath(body_type, /datum/body_type/ripped))
		return TRUE
	return FALSE

/// Телосложение == No Muscles?
/mob/living/carbon/human/proc/is_body_type_no_muscles()
	if(istext(body_type))
		return (lowertext(body_type) == "no muscles")
	if(istype(body_type, /datum/body_type/twig))
		return TRUE
	if(ispath(body_type, /datum/body_type/twig))
		return TRUE
	return FALSE

/// Множитель расхода калорий от телосложения.
/mob/living/carbon/human/proc/get_body_type_hunger_mult()
	if(is_body_type_ripped())
		return HUNGER_MULT_RIPPED
	if(is_body_type_no_muscles())
		return HUNGER_MULT_NO_MUSCLES
	return HUNGER_MULT_LEAN

/// Множитель скорости передвижения от телосложения.
/// >1 = медленнее, <1 = быстрее.
/mob/living/carbon/human/proc/get_body_type_speed_mult()
	if(is_body_type_ripped())
		return SPEED_MULT_RIPPED
	if(is_body_type_no_muscles())
		return SPEED_MULT_NO_MUSCLES
	return SPEED_MULT_LEAN

/// Применяет бонус к CQC от телосложения. Реактивно: если body_type
/// сменился, старый бонус снимается, новый выдаётся.
/// Вызывается из Life() — там skills уже точно есть.
/mob/living/carbon/human/proc/apply_body_type_skill_bonuses()
	if(!skills)
		return // скиллы ещё не выданы — попробуем на следующем тике

	var/want_bonus = is_body_type_ripped() ? BODY_TYPE_CQC_BONUS : 0
	if(want_bonus == body_type_cqc_bonus_applied)
		return // ничего не поменялось

	// Снимаем прошлый бонус
	if(body_type_cqc_bonus_applied > 0)
		skills.decrement_skill(SKILL_CQC, body_type_cqc_bonus_applied)

	// Выдаём новый
	if(want_bonus > 0)
		skills.increment_skill(SKILL_CQC, want_bonus)

	body_type_cqc_bonus_applied = want_bonus

/mob/living/carbon/human/Life(delta_time)
	if(monkeyizing)
		return
	if(!loc) //Fixing a null error that occurs when the mob isn't found in the world -- TLE
		return

	if(undefibbable && stat == DEAD || spawned_corpse)
		GLOB.data_core.manifest_modify(real_name, WEAKREF(src), null, null, "*Deceased*")
		if(on_fire && iszombie(src))
			var/datum/species/zombie/zombie_corpse = src.species
			zombie_corpse.clean_up_zombie(src)
		SShuman.processable_human_list -= src
		if(hardcore)
			qdel(src) //We just delete the corpse on WO to keep things simple and lag-free
		return

	..()

	apply_body_type_skill_bonuses()

	blinded = FALSE
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.

	//TODO: separate this out
	//update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	if(stat == DEAD && species.name == SPECIES_ZOMBIE)
		handle_chemicals_in_body(delta_time)
		return

	//No need to update all of these procs if the guy is dead.
	if(!in_stasis)
		if(stat != DEAD)
			if(life_tick % 3 == 0) //First, resolve location and get a breath
				breathe() //Only try to take a breath every 3 ticks, unless suffocating

			//Chemicals in the body
			handle_chemicals_in_body(delta_time)

			//Organs and blood
			handle_organs(delta_time)
			handle_blood()

			//Random events (vomiting etc)
			if(!stat && getToxLoss() >= 45 && nutrition > 20)
				vomit()

			if(on_fire)
				species.handle_on_fire(src)

			//effects of being grabbed aggressively by another mob
			if(pulledby && pulledby.grab_level)
				handle_grabbed()

			handle_pain()

			//In case we want them to do something unique every life cycle, like twitch or moan, or whatever.
			species.handle_unique_behavior(src)

		else //Dead
			if(!undefibbable)
				handle_necro_chemicals_in_body(delta_time) //Specifically for chemicals that still work while dead.
				if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > revive_grace_period) && !issynth(src)) //We are dead beyond revival, or we're junk mobs spawned like the clowns on the clown shuttle
					undefibbable = TRUE
					SEND_SIGNAL(src, COMSIG_HUMAN_SET_UNDEFIBBABLE)
					med_hud_set_status()

	else if(stat != DEAD)
		handle_stasis_bag()


	stabilize_body_temperature() //Body temperature adjusts itself (self-regulation) (even when dead)

	//Handle temperature/pressure differences between body and environment
	handle_environment() //Optimized a good bit.

	updatehealth()

	//Status updates, death etc.
	handle_regular_status_updates() //Optimized a bit

	handle_regular_hud_updates()

	pulse = handle_pulse()

	if(!client && !mind && species)
		species.handle_npc(src)

/mob/living/carbon/human/set_stat(new_stat)
	. = ..()
	// Temporarily force triggering HUD updates so they apply immediately rather than on Life tick.
	// Remove this once effects have been ported to trait signals (blinded, dazed, etc)
	if(stat != .)
		handle_regular_hud_updates()
