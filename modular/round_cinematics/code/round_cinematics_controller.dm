/datum/round_cinematics_controller
	var/list/intro_sessions = list()
	var/list/outro_sessions = list()
	var/datum/round_cinematics_outro_context/outro_context = null
	var/datum/round_cinematics_outcome/admin_outcome_override = null
	var/outro_started = FALSE
	/// Список референсов мобов, прошедших крио-интро (стартовый состав)
	var/list/initial_crew_refs = list()

/// Сброс трекинга стартового состава (вызывается на roundstart)
/datum/round_cinematics_controller/proc/reset_round_tracking()
	initial_crew_refs.Cut()

/// Called when a human is assigned to a cryopod (roundstart or latejoin).
/// Validates the human, pod, and client before queuing a cryo intro.
/datum/round_cinematics_controller/proc/on_human_assigned_cryo(mob/living/carbon/human/human, obj/structure/machinery/cryopod/pod, reason = "spawn")
	if(!istype(human))
		return
	if(!istype(pod))
		return
	if(!human.client)
		return
	if(pod.occupant && pod.occupant != human)
		return
	log_debug("round_cinematics: on_human_assigned_cryo [human] pod=[pod] reason=[reason]")
	// Запоминаем стартовый состав — только roundstart
	if((reason == "roundstart" || reason == "roundstart_job") && !(human in initial_crew_refs))
		initial_crew_refs += human
	queue_cryo_intro(human, pod, 5)

/datum/round_cinematics_controller/proc/on_session_finished(datum/round_cinematics_session/session)
	if(!session)
		return
	if(session.owner && intro_sessions[session.owner] == session)
		intro_sessions -= session.owner
	if(session.client && outro_sessions[session.client] == session)
		outro_sessions -= session.client

/datum/round_cinematics_controller/proc/register_intro_session(datum/round_cinematics_session/session)
	if(!session || !session.owner)
		return
	intro_sessions[session.owner] = session

/datum/round_cinematics_controller/proc/register_outro_session(datum/round_cinematics_session/session)
	if(!session || !session.client)
		return
	outro_sessions[session.client] = session

/datum/round_cinematics_controller/proc/get_intro_session(mob/living/carbon/human/human)
	if(!istype(human))
		return null
	return intro_sessions[human]

/datum/round_cinematics_controller/proc/try_start_cryo_intro(mob/living/carbon/human/human, preview = FALSE, obj/structure/machinery/cryopod/pod = null)
	if(!istype(human) || !human.client)
		log_debug("round_cinematics: try_start_cryo_intro skipped for [human] — reason: no human or no client")
		return FALSE
	if(!preview && !pod)
		log_debug("round_cinematics: try_start_cryo_intro skipped for [human] — reason: no pod (not in cryopod and no pod passed)")
		return FALSE
	if(!preview && !SSticker?.intro_sequence)
		log_debug("round_cinematics: try_start_cryo_intro skipped for [human] — reason: intro_sequence disabled")
		return FALSE
	if(human.stat == DEAD)
		log_debug("round_cinematics: try_start_cryo_intro skipped for [human] — reason: dead")
		return FALSE
	if(get_intro_session(human))
		log_debug("round_cinematics: try_start_cryo_intro skipped for [human] — reason: already has intro session")
		return FALSE

	var/datum/round_cinematics_session/intro/session = new /datum/round_cinematics_session/intro(src, human, pod, preview)
	register_intro_session(session)
	session.begin()
	return TRUE

/// Queue a cryo intro attempt. Retries up to max_attempts times with 1-second intervals.
/datum/round_cinematics_controller/proc/queue_cryo_intro(mob/living/carbon/human/human, obj/structure/machinery/cryopod/pod, max_attempts = 5, reason = "unknown")
	if(!istype(human))
		log_debug("round_cinematics: queue_cryo_intro skipped — reason: not a human")
		return FALSE
	if(!human.client)
		log_debug("round_cinematics: queue_cryo_intro skipped for [human] — reason: no client")
		return FALSE
	if(get_intro_session(human))
		log_debug("round_cinematics: queue_cryo_intro skipped for [human] — reason: already has intro session")
		return FALSE
	if(try_start_cryo_intro(human, FALSE, pod))
		return TRUE
	if(max_attempts <= 1)
		log_debug("round_cinematics: queue_cryo_intro failed for [human] — reason: max attempts exhausted on first try, trigger=[reason]")
		return FALSE
	log_debug("round_cinematics: queue_cryo_intro queued retry for [human] attempts_left=[max_attempts - 1] trigger=[reason]")
	addtimer(CALLBACK(src, PROC_REF(_queue_cryo_intro_tick), human, max_attempts - 1), 1 SECONDS)
	return FALSE

/datum/round_cinematics_controller/proc/_queue_cryo_intro_tick(mob/living/carbon/human/human, attempts_left)
	if(!istype(human) || QDELETED(human) || !human.client)
		return
	var/obj/structure/machinery/cryopod/pod = human.spawn_cryopod
	if(!pod)
		pod = istype(human.loc, /obj/structure/machinery/cryopod) ? human.loc : null
	if(try_start_cryo_intro(human, FALSE, pod))
		return
	if(attempts_left > 0)
		addtimer(CALLBACK(src, PROC_REF(_queue_cryo_intro_tick), human, attempts_left - 1), 1 SECONDS)

/datum/round_cinematics_controller/proc/handle_cryo_exit_attempt(obj/structure/machinery/cryopod/pod, mob/user)
	if(!user)
		return FALSE
	var/mob/living/carbon/human/human = user
	var/datum/round_cinematics_session/intro/session = get_intro_session(human)
	if(!session)
		return FALSE

	if(session.is_skip_allowed())
		session.finish_session("cryo_skip")
		return FALSE

	if(human.client)
		to_chat(human, SPAN_NOTICE("Последовательность пробуждения ещё калибруется."))
	return TRUE

/datum/round_cinematics_controller/proc/is_cryo_locked(mob/user)
	var/mob/living/carbon/human/human = user
	if(!istype(human))
		return FALSE
	var/datum/round_cinematics_session/intro/session = get_intro_session(human)
	return !!(session && !session.cleaned_up && !session.is_skip_allowed())

/datum/round_cinematics_controller/proc/force_finish_for(mob/user, reason)
	var/mob/living/carbon/human/human = user
	if(!istype(human))
		return FALSE
	var/datum/round_cinematics_session/intro/session = get_intro_session(human)
	if(session)
		session.finish_session(reason)
		return TRUE
	return FALSE

/datum/round_cinematics_controller/proc/preview_cryo_intro(mob/living/carbon/human/human)
	return try_start_cryo_intro(human, TRUE, null)

/datum/round_cinematics_controller/proc/set_admin_outcome(outcome, mob/admin)
	if(outcome == ROUND_CINEMATICS_OUTCOME_AUTO)
		admin_outcome_override = null
	else
		admin_outcome_override = new /datum/round_cinematics_outcome(outcome, TRUE)

	var/readable = admin_outcome_override ? admin_outcome_override.title : "АВТО"
	var/admin_name = admin ? key_name_admin(admin) : "system"
	var/message = "[admin_name] установил результат финальных титров: [readable]."
	log_admin(message)
	message_admins(message)
	return TRUE

/datum/round_cinematics_controller/proc/get_effective_outcome()
	if(admin_outcome_override && admin_outcome_override.id != ROUND_CINEMATICS_OUTCOME_AUTO)
		return admin_outcome_override.copy()
	return resolve_round_outcome(SSticker?.mode)

/datum/round_cinematics_controller/proc/build_outro_context()
	var/datum/round_cinematics_outcome/outcome = get_effective_outcome()
	outro_context = new /datum/round_cinematics_outro_context(SSticker?.mode, outcome, FALSE, null)
	outro_context.build()
	return outro_context

/datum/round_cinematics_controller/proc/get_outro_targets()
	var/list/targets = list()
	for(var/client/C as anything in GLOB.clients)
		if(!C?.mob)
			continue
		if(isnewplayer(C.mob))
			continue
		targets += C
	return targets

/datum/round_cinematics_controller/proc/try_start_round_outro(datum/round_cinematics_outcome_input/input = null)
	if(outro_started)
		return FALSE

	// Build outcome from input if provided, otherwise resolve from mode
	var/datum/round_cinematics_outcome/outcome
	if(input?.admin_override)
		outcome = new /datum/round_cinematics_outcome(input.admin_override, TRUE)
	else if(input?.explicit_result)
		outcome = round_cinematics_outcome_from_mode_result(input.explicit_result)
	else if(input?.mode)
		outcome = resolve_round_outcome(input.mode)
	else
		outcome = get_effective_outcome()

	var/datum/round_cinematics_outro_context/context = new /datum/round_cinematics_outro_context(input?.mode || SSticker?.mode, outcome, FALSE, null)
	context.build()
	outro_context = context
	admin_outcome_override = null

	var/list/targets = get_outro_targets()
	if(!length(targets))
		outro_context = null
		return FALSE
	outro_started = TRUE

	for(var/client/C as anything in targets)
		var/datum/round_cinematics_session/outro/existing_session = outro_sessions[C]
		if(existing_session && !existing_session.cleaned_up)
			existing_session.finish_session("outro_replaced")

		var/datum/round_cinematics_session/outro/session = new /datum/round_cinematics_session/outro(src, C, context, FALSE)
		register_outro_session(session)
		session.begin()

	return TRUE

/datum/round_cinematics_controller/proc/preview_round_outro(client/requester)
	if(!istype(requester) || !requester.mob)
		return FALSE
	if(outro_started)
		return FALSE

	var/datum/round_cinematics_session/outro/existing_session = outro_sessions[requester]
	if(existing_session && !existing_session.cleaned_up)
		existing_session.finish_session("preview_replaced")

	var/datum/round_cinematics_outro_context/context = new /datum/round_cinematics_outro_context(SSticker?.mode, get_effective_outcome(), TRUE, requester)
	context.build()
	var/datum/round_cinematics_session/outro/session = new /datum/round_cinematics_session/outro(src, requester, context, TRUE)
	register_outro_session(session)
	session.begin()
	return TRUE

/datum/round_cinematics_controller/proc/get_visual_profile(id)
	if(!id)
		return null
	switch(id)
		if("intro_universal")
			return new /datum/round_cinematics_visual_profile/intro_universal
		if("outro_victory")
			return new /datum/round_cinematics_visual_profile/outro_victory
		if("outro_defeat")
			return new /datum/round_cinematics_visual_profile/outro_defeat
		if("outro_inconclusive")
			return new /datum/round_cinematics_visual_profile/outro_inconclusive
		else
			return new /datum/round_cinematics_visual_profile

/datum/round_cinematics_controller/proc/cleanup_all(reason)
	for(var/mob/living/carbon/human/human in intro_sessions.Copy())
		var/datum/round_cinematics_session/session = intro_sessions[human]
		session?.finish_session(reason)

	for(var/client/C in outro_sessions.Copy())
		var/datum/round_cinematics_session/session = outro_sessions[C]
		session?.finish_session(reason)

	intro_sessions.Cut()
	outro_sessions.Cut()
	outro_context = null
	admin_outcome_override = null
	outro_started = FALSE
	return TRUE
