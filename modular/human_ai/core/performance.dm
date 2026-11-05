/// Low-frequency measurements for real combat runs, appended to the existing
/// ten-second perf CSV. No per-NPC logging or gameplay throttling.
/datum/controller/subsystem/human_ai/proc/performance_headers()
	return list("ai_world_cpu", "ai_world_tick_usage", "ai_living_npcs", "ai_engaged_npcs", "ai_think_cost_ms", "ai_think_tick_usage", "ai_path_cost_ms", "ai_path_pending", "ai_path_active", "ai_human_life_cost_ms", "ai_projectile_cost_ms", "ai_timer_cost_ms")

/datum/controller/subsystem/human_ai/proc/performance_values()
	var/living = 0
	var/engaged = 0
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		if(!brain.has_valid_tied_human() || brain.tied_human.client || brain.tied_human.stat == DEAD)
			continue
		living++
		if(brain.current_target)
			engaged++
	flush_performance_profile(living, engaged)
	return list(world.cpu, world.tick_usage, living, engaged, cost, tick_usage, SSpathfinding.cost, length(SSpathfinding.paths_to_calculate), length(SSpathfinding.current_processing), SShuman.cost, SSprojectiles.cost, SStimer.cost)
