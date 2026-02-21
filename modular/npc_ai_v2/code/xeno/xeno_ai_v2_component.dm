/datum/component/xeno_ai_v2
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/mob/living/carbon/xenomorph/ai_xeno

/// RU: Инициализирует объект и его зависимости в компоненте xeno_ai_v2. EN: Initializes object and dependencies in the xeno_ai_v2 component.
/datum/component/xeno_ai_v2/Initialize()
	. = ..()
	ai_xeno = parent
	if(!istype(ai_xeno))
		return COMPONENT_INCOMPATIBLE

	ai_xeno.mob_flags |= AI_CONTROLLED
	register_with_npc_ai()

/// RU: Очищает runtime-состояние перед удалением объекта в компоненте xeno_ai_v2. Побочные эффекты: чистит runtime-объекты. EN: Cleans runtime state before deleting object in the xeno_ai_v2 component. Side effects: cleans runtime objects.
/datum/component/xeno_ai_v2/Destroy(force, silent)
	handle_qdel()
	return ..()

/// RU: Выполняет служебный этап в xeno AI v2 (этап: RegisterWithParent) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in xeno AI v2 (step: RegisterWithParent) to coordinate state between AI v2 subsystems.
/datum/component/xeno_ai_v2/RegisterWithParent()
	..()
	RegisterSignal(ai_xeno, COMSIG_PARENT_QDELETING, PROC_REF(handle_qdel))
	register_with_npc_ai()

/// RU: Выполняет служебный этап в xeno AI v2 (этап: UnregisterFromParent) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in xeno AI v2 (step: UnregisterFromParent) to coordinate state between AI v2 subsystems.
/datum/component/xeno_ai_v2/UnregisterFromParent()
	..()
	var/mob/living/carbon/xenomorph/current_xeno = ai_xeno
	if(!current_xeno && istype(parent, /mob/living/carbon/xenomorph))
		current_xeno = parent
	if(current_xeno)
		UnregisterSignal(current_xeno, COMSIG_PARENT_QDELETING)
	ai_xeno = null

/// RU: Выполняет служебный этап в xeno AI v2 (этап: handle qdel) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in xeno AI v2 (step: handle qdel) to coordinate state between AI v2 subsystems.
/datum/component/xeno_ai_v2/proc/handle_qdel()
	SIGNAL_HANDLER

	unregister_from_npc_ai()

/// RU: Регистрирует сущность в xeno AI v2 (этап: register with npc ai) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in xeno AI v2 (step: register with npc ai) and links it to AI v2 runtime state.
/datum/component/xeno_ai_v2/proc/register_with_npc_ai()
	if(!ai_xeno)
		return

	ai_xeno.mob_flags |= AI_CONTROLLED

	if(!SSnpc_ai)
		return

	var/datum/npc_ai_controller/xeno/xeno_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/xeno)
	if(!xeno_controller)
		return
	xeno_controller.register_agent(ai_xeno)

/// RU: Отписывает xeno от SSnpc_ai и снимает AI_CONTROLLED флаг при teardown компонента. EN: Unregisters xeno from SSnpc_ai and clears AI_CONTROLLED flag during component teardown.
/datum/component/xeno_ai_v2/proc/unregister_from_npc_ai()
	if(!ai_xeno)
		return

	if(SSnpc_ai)
		var/datum/npc_ai_controller/xeno/xeno_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/xeno)
		if(xeno_controller)
			xeno_controller.unregister_agent(ai_xeno)

	ai_xeno.mob_flags &= ~AI_CONTROLLED
