/// RU: Возвращает агрегированный runtime-статус xeno behavior stack для snapshot/артефактов. EN: Returns aggregated runtime status of xeno behavior stack for snapshots/artifacts.
/proc/get_npc_ai_v2_xeno_behavior_stack_active()
	// PR4 finalized runtime core as a permanent xeno v2 path.
	return !!GLOB.npc_ai_v2_xeno_enabled

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 human) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 human) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_human()
	set name = "Toggle NPC AI v2 (Human)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_human_enabled = !GLOB.npc_ai_v2_human_enabled
	var/refreshed_count = refresh_all_human_ai_runtime_ownership()
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_human_enabled ? "enabled" : "disabled"] NPC AI v2 human controller. Refreshed [refreshed_count] human runtime states.")

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 xeno) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 xeno) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_xeno()
	set name = "Toggle NPC AI v2 (Xeno)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_xeno_enabled = !GLOB.npc_ai_v2_xeno_enabled
	var/refreshed_count = refresh_all_xeno_ai_runtime_state()
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_xeno_enabled ? "enabled" : "disabled"] NPC AI v2 xeno controller. Refreshed [refreshed_count] xeno runtime states.")

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 xeno goal provider) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 xeno goal provider) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_xeno_goal_provider()
	set name = "Toggle NPC AI v2 (Xeno Goal Provider)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_xeno_goal_provider_enabled = !GLOB.npc_ai_v2_xeno_goal_provider_enabled
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_xeno_goal_provider_enabled ? "enabled" : "disabled"] NPC AI v2 xeno goal-provider plugins.")

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 xeno movement plugins) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 xeno movement plugins) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_xeno_movement_plugins()
	set name = "Toggle NPC AI v2 (Xeno Movement Plugins)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_xeno_movement_plugins_enabled = !GLOB.npc_ai_v2_xeno_movement_plugins_enabled
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_xeno_movement_plugins_enabled ? "enabled" : "disabled"] NPC AI v2 xeno movement plugins.")

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 squad) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 squad) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_squad()
	set name = "Toggle NPC AI v2 (Squad)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_squad_enabled = !GLOB.npc_ai_v2_squad_enabled
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_squad_enabled ? "enabled" : "disabled"] NPC AI v2 squad controller.")

/// RU: Выполняет служебный этап в AI v2 (этап: toggle npc ai v2 director) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 (step: toggle npc ai v2 director) to coordinate state between AI v2 subsystems.
/datum/admins/proc/toggle_npc_ai_v2_director()
	set name = "Toggle NPC AI v2 (Director)"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	GLOB.npc_ai_v2_director_enabled = !GLOB.npc_ai_v2_director_enabled
	message_admins("[key_name_admin(usr)] [GLOB.npc_ai_v2_director_enabled ? "enabled" : "disabled"] NPC AI v2 director controller.")

/// RU: Показывает текущую сводку runtime-флагов NPC AI v2 для staged rollout/rollback диагностики. EN: Shows current NPC AI v2 runtime flag snapshot for staged rollout/rollback diagnostics.
/datum/admins/proc/show_npc_ai_v2_runtime_flags()
	set name = "Show NPC AI v2 Runtime Flags"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	var/list/lines = list(
		"NPC AI v2 runtime flags:",
		"human_enabled=[GLOB.npc_ai_v2_human_enabled]",
		"xeno_enabled=[GLOB.npc_ai_v2_xeno_enabled]",
		"xeno_goal_provider_enabled=[GLOB.npc_ai_v2_xeno_goal_provider_enabled]",
		"xeno_movement_plugins_enabled=[GLOB.npc_ai_v2_xeno_movement_plugins_enabled]",
		"xeno_behavior_stack_active=[get_npc_ai_v2_xeno_behavior_stack_active()]",
		"squad_enabled=[GLOB.npc_ai_v2_squad_enabled]",
		"director_enabled=[GLOB.npc_ai_v2_director_enabled]",
		"director_mood=[GLOB.npc_ai_v2_director_mood]",
		"director_pressure_bias=[GLOB.npc_ai_v2_director_pressure_bias]"
	)

	if(SSnpc_ai)
		lines += "benchmark_enabled=[SSnpc_ai.benchmark_enabled] benchmark_running=[SSnpc_ai.benchmark_running] benchmark_completed=[SSnpc_ai.benchmark_completed]"
		lines += "benchmark_scenario=[SSnpc_ai.benchmark_scenario] benchmark_duration_seconds=[SSnpc_ai.benchmark_duration_seconds]"

	to_chat(usr, jointext(lines, "\n"))

/// RU: Обновляет runtime состояние в AI v2 (этап: set npc ai v2 director mood) и синхронизирует данные для последующих тиков. EN: Updates runtime state in AI v2 (step: set npc ai v2 director mood) and synchronizes data for subsequent ticks.
/datum/admins/proc/set_npc_ai_v2_director_mood()
	set name = "Set NPC AI v2 Director Mood"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	var/list/moods = list(
		NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE,
		NPC_AI_V2_DIRECTOR_MOOD_BALANCED,
		NPC_AI_V2_DIRECTOR_MOOD_RETREAT,
	)
	var/new_mood = tgui_input_list(usr, "Select scene mood for Squad AI guidance.", "NPC AI v2 Director Mood", moods)
	if(!new_mood)
		return

	GLOB.npc_ai_v2_director_mood = new_mood
	var/datum/npc_ai_controller/director/director_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/director)
	director_controller?.set_current_mood(new_mood)
	message_admins("[key_name_admin(usr)] set NPC AI v2 director mood to '[new_mood]'.")

/// RU: Обновляет runtime состояние в AI v2 (этап: set npc ai v2 director pressure bias) и синхронизирует данные для последующих тиков. EN: Updates runtime state in AI v2 (step: set npc ai v2 director pressure bias) and synchronizes data for subsequent ticks.
/datum/admins/proc/set_npc_ai_v2_director_pressure_bias()
	set name = "Set NPC AI v2 Director Pressure"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	var/new_pressure_bias = tgui_input_real_number(usr, "Set tactical pressure bias (-100..100).", "NPC AI v2 Director Pressure", GLOB.npc_ai_v2_director_pressure_bias)
	if(isnull(new_pressure_bias))
		return
	new_pressure_bias = clamp(round(new_pressure_bias), -100, 100)

	GLOB.npc_ai_v2_director_pressure_bias = new_pressure_bias
	var/datum/npc_ai_controller/director/director_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/director)
	director_controller?.set_pressure_bias(new_pressure_bias)
	message_admins("[key_name_admin(usr)] set NPC AI v2 director pressure bias to [new_pressure_bias].")

