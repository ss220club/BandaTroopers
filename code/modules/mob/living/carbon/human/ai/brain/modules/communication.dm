/datum/human_ai_module/communication
	module_id = "communication"
	required_module_types = list(/datum/human_ai_module/inventory)
	/// Lines potentially said when an AI enters combat
	var/list/enter_combat_lines = list(
		"CONTACT!",
		"Contact!",
		"SHIT- CONTACT!",
		"CONTACT, FRONT!",
		"WE GOT CONTACT!",
		"Look alive!",
		"GUNS UP!",
		"There!",
		"Over there!",
		"OPEN FIRE!",
		"Open fire!",
		"ENGAGE!",
		"Engage!",
		"Weapons free!",
		"Wipe 'em out!",
		"Light 'em up!",
		"Cut 'em down!",
		"Fuck 'em up!",
		"WASTE THE MOTHERFUCKERS!",
		"Kill that fucker!",
		"Ice that fucker!",
		"Let's rock!",
		"Eat shit!",
		"Die, you son of a bitch!",
		"Get some!",
		"GET SOME!",
		"GET SOME, MOTHERFUCKER!",
		"*warcry",
	)

	/// Lines potentially said when an AI exits combat
	var/list/exit_combat_lines = list(
		"CEASE FIRE!",
		"Cease fire!",
		"Cease your fire!",
		"Hold your fire!",
		"HOLD FIRE!",
		"We're clear!",
		"We clear?",
		"Looks clear!",
		"CLEAR!",
		"Keep your eyes peeled!",
		"Might be more- Keep your eyes peeled.",
	)

	/// Lines potentially said when an AI's squadmate dies
	var/list/squad_member_death_lines = list(
		"FUCK!",
		"SHIT!",
		"CRAP!",
		"MOTHERFUCKER!",
		"GOD DAMN IT!",
		"WE'RE TAKING HITS HERE!",
		"THEY GOT THEM-- RETURN THE FUCKING FAVOUR!",
		"YOU'LL FUCKING PAY, MOTHERFUCKER!",
		"YOU'LL FUCKING PAY, ASSHOLE!",
		"THEY'RE DOWN!",
		"THEY'RE DEAD!",
		"THEY GOT THEM!",
	)

	/// Lines potentially said when an AI throws a grenade
	var/list/grenade_thrown_lines = list(
		"GRENADE!",
		"THROWING GRENADE!",
		"GRENADE, GET CLEAR!",
		"EAT IT, FUCKER!",
		"RETURN TO SENDER!",
		"DELIVERY, MOTHERFUCKER!",
	)

	/// Lines potentially said when an AI reloads a magazine-fed gun
	var/list/reload_lines = list(
		"RELOADING!",
		"Reloading!",
		"Swapping magazines!",
		"Swapping mags!",
		"Changing magazines!",
		"Changing mags!",
		"Cover me, reloading!",
		"NEED COVERING FIRE!",
		"COVER ME!",
		"RED! RED!-- GREEN!",
		"I'M RED!",
		"RED!",
	)

	/// Lines potentially said when an AI reloads a tube-fed gun
	var/list/reload_internal_mag_lines = list(
		"RELOADING!",
		"Reloading!",
		"Cover me, reloading!",
		"NEED COVERING FIRE!",
		"COVER ME!",
		"RED! RED!-- GREEN!",
		"I'M RED!",
		"I NEED A FUCKING SPEEDLOADER- CHRIST!",
		"RED!",
	)

	/// Currently unused
	var/list/need_healing_lines = list(
		"FUCK ME!",
		"FUCK!",
		"SHIT!",
		"CRAP!",
		"MOTHERFUCKER!",
		"GOD DAMN IT!",
		"JESUS CHRIST!",
		"BLEEDING!",
		"MOTHER OF GOD-- NO!",
		"I'M TAKING HITS HERE!",
		"I'M HIT!",
		"I'M HURT!",
		"INJECTOR GOING IN!",
		"INJECTOR IN!",
		"I NEED GAUZE!",
		"SOMEONE PATCH THIS FUCKING HOLE!",
		"NEED MORPHINE!",
	)

	/// Chance that an AI says a voiceline when entering combat
	var/in_combat_line_chance = 100
	/// Chance that an AI says a voiceline when exiting combat
	var/exit_combat_line_chance = 100
	/// Chance that an AI says a voiceline when a squadmember dies
	var/squad_member_death_line_chance = 100
	/// Chance that an AI says a voiceline when they throw a grenade
	var/grenade_thrown_line_chance = 100
	/// Chance that an AI says a voiceline when they reload a gun
	var/reload_line_chance = 100
	/// Currently unused
	var/need_healing_line_chance = 100
	/// Minimum spacing between AI combat voicelines to avoid runaway chatter loops in prolonged fights.
	var/combat_voiceline_cooldown_time = 4 SECONDS
	COOLDOWN_DECLARE(combat_voiceline_cooldown)

/datum/human_ai_module/communication/proc/get_reload_line_chance()
	return reload_line_chance

/datum/human_ai_module/communication/proc/set_reload_line_chance(new_chance)
	reload_line_chance = new_chance

/datum/human_ai_module/communication/proc/get_owner_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	return brain.get_primary_weapon()

/datum/human_ai_module/communication/proc/apply_faction_lines(
	list/new_enter_combat_lines,
	list/new_exit_combat_lines,
	list/new_squad_member_death_lines,
	list/new_grenade_thrown_lines,
	list/new_reload_lines,
	list/new_reload_internal_mag_lines,
	list/new_need_healing_lines
)
	if(length(new_enter_combat_lines))
		enter_combat_lines = new_enter_combat_lines
	if(length(new_exit_combat_lines))
		exit_combat_lines = new_exit_combat_lines
	if(length(new_squad_member_death_lines))
		squad_member_death_lines = new_squad_member_death_lines
	if(length(new_grenade_thrown_lines))
		grenade_thrown_lines = new_grenade_thrown_lines
	if(length(new_reload_lines))
		reload_lines = new_reload_lines
	if(length(new_reload_internal_mag_lines))
		reload_internal_mag_lines = new_reload_internal_mag_lines
	if(length(new_need_healing_lines))
		need_healing_lines = new_need_healing_lines

/datum/human_ai_module/communication/proc/emit_ai_voiceline(line)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller?.can_read_puppet() || !line)
		return FALSE

	if(!COOLDOWN_FINISHED(src, combat_voiceline_cooldown))
		return FALSE

	COOLDOWN_START(src, combat_voiceline_cooldown, combat_voiceline_cooldown_time)
	return controller.say(line)

/datum/human_ai_module/communication/proc/say_in_combat_line(chance = in_combat_line_chance)
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(enter_combat_lines) || !prob(chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT))
		return
	emit_ai_voiceline(pick(enter_combat_lines))

/datum/human_ai_module/communication/on_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_COMBAT_ENTERED)
			on_combat_entered(event.was_in_combat())
		if(HUMAN_AI_EVENT_COMBAT_EXIT_STARTED)
			on_combat_exit_started(event.should_holster_primary())

/datum/human_ai_module/communication/on_combat_entered(was_in_combat)
	if(was_in_combat)
		return

	say_in_combat_line()

/datum/human_ai_module/communication/proc/say_exit_combat_line(chance = exit_combat_line_chance)
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(exit_combat_lines) || !prob(chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT))
		return
	emit_ai_voiceline(pick(exit_combat_lines))

/datum/human_ai_module/communication/on_combat_exit_started(should_holster_primary = TRUE)
	say_exit_combat_line()

/datum/human_ai_module/communication/proc/on_squad_member_death(mob/living/carbon/human/dead_member)
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(squad_member_death_lines) || !prob(squad_member_death_line_chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT))
		return
	emit_ai_voiceline(pick(squad_member_death_lines))

/datum/human_ai_module/communication/proc/say_grenade_thrown_line(chance = grenade_thrown_line_chance)
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(grenade_thrown_lines) || !prob(chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT))
		return
	emit_ai_voiceline(pick(grenade_thrown_lines))

/datum/human_ai_module/communication/proc/say_reload_line(chance = reload_line_chance)
	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(reload_lines) || !prob(chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT) || !primary_weapon)
		return
	if(istype(primary_weapon.current_mag, /obj/item/ammo_magazine/internal))
		emit_ai_voiceline(pick(reload_internal_mag_lines))
	else
		emit_ai_voiceline(pick(reload_lines))

/datum/human_ai_module/communication/proc/say_need_healing_line(chance = need_healing_line_chance)
	var/datum/human_tied_controller/controller = context?.controller
	if(!length(need_healing_lines) || !prob(chance) || controller?.is_health_below(HEALTH_THRESHOLD_CRIT))
		return
	emit_ai_voiceline(pick(need_healing_lines))
