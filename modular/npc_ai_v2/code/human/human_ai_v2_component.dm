/datum/component/human_ai_v2
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Reuses the current human AI brain implementation while execution is delegated to SSnpc_ai.
	var/datum/human_ai_brain/ai_brain
	/// Ref to the owning human.
	var/mob/living/carbon/human/ai_human
	var/static/human_ai_has_spawned = FALSE

/// RU: Инициализирует объект и его зависимости в компоненте human_ai_v2. EN: Initializes object and dependencies in the human_ai_v2 component.
/datum/component/human_ai_v2/Initialize()
	. = ..()
	ai_human = parent
	if(!istype(ai_human))
		return COMPONENT_INCOMPATIBLE

	if(!human_ai_has_spawned && !(SSticker.mode.toggleable_flags & MODE_HUMAN_AI_TWEAKS))
		human_ai_has_spawned = TRUE
		SSticker.mode.toggleable_flags ^= MODE_HUMAN_AI_TWEAKS
		message_admins("Human AI tweaks have been enabled by spawning an AI. This can be disabled with the \"Toggle Human AI Tweaks\" verb.")

	ai_brain = new(ai_human)
	GLOB.ai_humans += ai_human
	ai_human.mob_flags |= AI_CONTROLLED
	register_with_npc_ai()

/// RU: Очищает runtime-состояние перед удалением объекта в компоненте human_ai_v2. Побочные эффекты: чистит runtime-объекты. EN: Cleans runtime state before deleting object in the human_ai_v2 component. Side effects: cleans runtime objects.
/datum/component/human_ai_v2/Destroy(force, silent)
	handle_qdel()
	return ..()

/// RU: Выполняет служебный этап в human AI v2 (этап: RegisterWithParent) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: RegisterWithParent) to coordinate state between AI v2 subsystems.
/datum/component/human_ai_v2/RegisterWithParent()
	..()
	RegisterSignal(ai_human, COMSIG_PARENT_QDELETING, PROC_REF(handle_qdel))
	RegisterSignal(ai_human, COMSIG_HUMAN_SET_SPECIES, PROC_REF(on_species_set))
	RegisterSignal(ai_human, COMSIG_MOVABLE_MOVED, PROC_REF(on_ai_moved))
	register_with_npc_ai()
	request_item_search_reconcile()

/// RU: Выполняет служебный этап в human AI v2 (этап: UnregisterFromParent) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: UnregisterFromParent) to coordinate state between AI v2 subsystems.
/datum/component/human_ai_v2/UnregisterFromParent()
	..()
	var/mob/living/carbon/human/current_human = ai_human
	if(!current_human && istype(parent, /mob/living/carbon/human))
		current_human = parent
	if(current_human)
		UnregisterSignal(current_human, COMSIG_PARENT_QDELETING)
		UnregisterSignal(current_human, COMSIG_HUMAN_SET_SPECIES)
		UnregisterSignal(current_human, COMSIG_MOVABLE_MOVED)
	ai_human = null

/// RU: Выполняет служебный этап в human AI v2 (этап: handle qdel) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: handle qdel) to coordinate state between AI v2 subsystems.
/datum/component/human_ai_v2/proc/handle_qdel()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/current_human = ai_human
	if(!current_human && istype(parent, /mob/living/carbon/human))
		current_human = parent
	unregister_from_npc_ai()
	if(current_human)
		GLOB.ai_humans -= current_human
	ai_brain?.tied_human = null
	QDEL_NULL(ai_brain)

/// RU: Выполняет служебный этап в human AI v2 (этап: on species set) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: on species set) to coordinate state between AI v2 subsystems.
/datum/component/human_ai_v2/proc/on_species_set(datum/source, new_species)
	SIGNAL_HANDLER

	ai_human.mob_flags |= AI_CONTROLLED

/// RU: Выполняет служебный этап в human AI v2 (этап: on ai moved) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: on ai moved) to coordinate state between AI v2 subsystems.
/datum/component/human_ai_v2/proc/on_ai_moved(datum/source, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	request_item_search_reconcile()

/// RU: Регистрирует сущность в human AI v2 (этап: register with npc ai) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in human AI v2 (step: register with npc ai) and links it to AI v2 runtime state.
/datum/component/human_ai_v2/proc/register_with_npc_ai()
	if(!ai_human || !SSnpc_ai)
		return
	ai_human.mob_flags |= AI_CONTROLLED
	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/human)
	if(!human_controller)
		return
	human_controller.register_agent(ai_human, ai_brain)
	request_item_search_reconcile()

/// RU: Удаляет или освобождает runtime сущности в human AI v2 (этап: unregister from npc ai) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in human AI v2 (step: unregister from npc ai) to avoid dangling references and stale state.
/datum/component/human_ai_v2/proc/unregister_from_npc_ai()
	if(!ai_human || !SSnpc_ai)
		if(ai_human)
			ai_human.mob_flags &= ~AI_CONTROLLED
		return
	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/human)
	if(human_controller)
		human_controller.unregister_agent(ai_human)
	ai_human.mob_flags &= ~AI_CONTROLLED
	if(!human_controller)
		return

/// RU: Ставит в blackboard флаги пересчета item_search, fire line и cover scan после движения/регистрации AI. EN: Sets blackboard reconcile flags for item_search, fire line, and cover scan after AI movement/registration.
/datum/component/human_ai_v2/proc/request_item_search_reconcile()
	if(!ai_human || !SSnpc_ai)
		return

	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/human)
	if(!human_controller)
		return

	var/datum/npc_ai_blackboard/blackboard = human_controller.get_blackboard(ai_human)
	if(!blackboard)
		return

	blackboard.set_value("legacy_item_search_requested", TRUE)
	blackboard.set_value("legacy_fire_line_recalc_requested", TRUE)
	blackboard.set_value("legacy_cover_scan_requested", TRUE)
