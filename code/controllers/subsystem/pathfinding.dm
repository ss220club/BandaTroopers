// SS220 EDIT: share the existing MC budget fairly between pending human and xeno routes.
#define PATHFINDING_EXPANSIONS_PER_TURN 8

SUBSYSTEM_DEF(pathfinding)
	name = "Pathfinding"
	priority = SS_PRIORITY_PATHFINDING
	flags = SS_NO_INIT|SS_TICKER|SS_BACKGROUND
	wait = 1
	/// A list of mobs scheduled to process
	var/list/datum/xeno_pathinfo/current_processing = list()
	/// A list of paths to calculate
	var/list/datum/xeno_pathinfo/paths_to_calculate = list()

	var/list/hash_path = list()
	// var/current_position = 1 // SS220 EDIT: consumptive round snapshots need no mutable cursor.

/datum/controller/subsystem/pathfinding/stat_entry(msg)
	msg = "P:[length(paths_to_calculate)]"
	// SS220 EDIT: let modular packs append subsystem-specific diagnostics without baking them into hardcode
	if(hascall(src, "modular_stat_entry_suffix"))
		var/suffix = call(src, "modular_stat_entry_suffix")()
		if(suffix)
			msg += " | [suffix]"
	return ..()

/datum/controller/subsystem/pathfinding/fire(resumed = FALSE)
	if(!resumed)
		current_processing = paths_to_calculate.Copy()

	// SS220 EDIT - START: consume one bounded slice per request before beginning another round.
	while(length(paths_to_calculate))
		if(MC_TICK_CHECK)
			return
		if(!length(current_processing))
			current_processing = paths_to_calculate.Copy()

		var/datum/xeno_pathinfo/current_run = current_processing[length(current_processing)]
		current_processing.len--
		if(QDELETED(current_run))
			paths_to_calculate -= current_run
			continue

		var/is_xeno = isxeno(current_run.agent)
		var/datum/human_ai_brain/brain
		if(!is_xeno && !QDELETED(current_run.agent))
			var/datum/component/human_ai/ai_component = current_run.agent.GetComponent(/datum/component/human_ai)
			brain = ai_component?.ai_brain
		if(QDELETED(current_run.agent) || (!is_xeno && QDELETED(brain)))
			var/datum/callback/failed_callback = current_run.to_return
			QDEL_NULL(current_run)
			failed_callback?.Invoke()
			continue
		// SS220 EDIT - END

		var/turf/target = current_run.finish

		var/list/visited_nodes = current_run.visited_nodes
		var/list/distances = current_run.distances
		var/list/f_distances = current_run.f_distances
		var/list/prev = current_run.prev

		// SS220 EDIT - START: only a popped goal or an exhausted frontier completes a search.
		var/reached_target = FALSE
		var/expanded_nodes = 0
		while(length(visited_nodes) && expanded_nodes < PATHFINDING_EXPANSIONS_PER_TURN)
			expanded_nodes++
			// SS220 EDIT - END
			current_run.current_node = visited_nodes[length(visited_nodes)]
			visited_nodes.len--
			if(current_run.current_node == target)
				reached_target = TRUE // SS220 EDIT: discovering a goal is not the same as selecting it.
				break

			for(var/direction in GLOB.cardinals)
				var/turf/neighbor = get_step(current_run.current_node, direction)
				if(!neighbor) // SS220 EDIT: map-edge steps have no turf to inspect.
					continue
				var/distance_between = distances[current_run.current_node] * DISTANCE_PENALTY
				if(isnull(distances[neighbor]))
					if(get_dist(neighbor, current_run.agent) > current_run.path_range)
						continue
					distances[neighbor] = INFINITY
					f_distances[neighbor] = INFINITY

				if(direction != get_dir(prev[neighbor], neighbor))
					distance_between += DIRECTION_CHANGE_PENALTY

				if(is_xeno && !neighbor.weeds) // SS220 EDIT: agent type is constant during this slice.
					distance_between += NO_WEED_PENALTY

				for(var/i in neighbor)
					var/atom/A = i
					distance_between += A.object_weight

				var/list/L = LinkBlocked(current_run.agent, current_run.current_node, neighbor, current_run.ignore, TRUE)
				L += check_special_blockers(current_run.agent, neighbor)
				if(length(L))
					if(is_xeno) // SS220 EDIT: reuse the validated slice-local agent type.
						for(var/atom/A as anything in L)
							distance_between += A.xeno_ai_obstacle(current_run.agent, direction, target)
					else
						// SS220 EDIT: the human brain is validated once before this slice.
						for(var/atom/A as anything in L)
							distance_between += A.human_ai_obstacle(current_run.agent, brain, direction, target)

				if(distance_between < distances[neighbor])
					distances[neighbor] = distance_between
					var/f_distance = distance_between + ASTAR_COST_FUNCTION(neighbor, target)
					f_distances[neighbor] = f_distance
					prev[neighbor] = current_run.current_node
					if(neighbor in visited_nodes)
						visited_nodes -= neighbor

					for(var/i in 0 to length(visited_nodes))
						var/index_to_check = length(visited_nodes) - i
						if(index_to_check == 0)
							visited_nodes.Insert(1, neighbor)
							break

						if(f_distance < f_distances[visited_nodes[index_to_check]])
							// visited_nodes.Insert(index_to_check, neighbor)
							visited_nodes.Insert(index_to_check + 1, neighbor) // SS220 EDIT: minimum cost is popped from the tail.
							break

			if(MC_TICK_CHECK)
				return

		// SS220 EDIT: unfinished work rejoins only after the other requests receive their slice.
		if(!reached_target && length(visited_nodes))
			continue

		#ifdef TESTING
		for(var/i in distances)
			var/turf/T = i
			var/distance = distances[i]
			if(distance == INFINITY)
				T.color = "#000000"
				for(var/l in T)
					var/atom/A = l
					A.color = "#000000"
				continue

			var/red = num2hex(min(distance*10, 255), 2)
			var/green = num2hex(max(255-distance*10, 0), 2)

			for(var/l in T)
				var/atom/A = l
				A.color = "#[red][green]00"
			T.color = "#[red][green]00"
		#endif

		// SS220 EDIT - START: finish failures without abandoning the queue; release ownership before callbacks.
		var/list/path
		if(reached_target)
			path = list()
			var/turf/current_node = target
			var/remaining_steps = length(prev) + 1
			while(current_node && current_node != current_run.start && remaining_steps > 0)
				remaining_steps--
				path += current_node
				current_node = prev[current_node]
			// Do not return a partial or cyclic predecessor chain as a usable route.
			if(current_node != current_run.start)
				path = null

		var/datum/callback/completed_callback = current_run.to_return
		QDEL_NULL(current_run)
		completed_callback?.Invoke(path)
		// SS220 EDIT - END

/datum/controller/subsystem/pathfinding/proc/check_special_blockers(mob/agent, turf/checking_turf)
	var/list/pass_back = list()

	for(var/spec_blocker in AI_SPECIAL_BLOCKERS)
		// SS220 EDIT - START: preserve blocker order/multiplicity without allocating lists for nonmatches.
		if(istype(checking_turf, spec_blocker))
			pass_back += checking_turf

		for(var/atom/checked_atom as anything in checking_turf)
			if(istype(checked_atom, spec_blocker))
				pass_back += checked_atom
		// SS220 EDIT - END

	return pass_back

/datum/controller/subsystem/pathfinding/proc/stop_calculating_path(mob/agent)
	var/datum/xeno_pathinfo/data = hash_path[agent]
	qdel(data)

/datum/controller/subsystem/pathfinding/proc/get_or_create_pathinfo(mob/agent)
	var/datum/xeno_pathinfo/data = hash_path[agent]
	SSpathfinding.current_processing -= data

	if(data)
		return data

	data = new()
	data.RegisterSignal(agent, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/xeno_pathinfo, qdel_wrapper))
	hash_path[agent] = data
	paths_to_calculate += data
	return data

/datum/controller/subsystem/pathfinding/proc/calculate_path(atom/start, atom/finish, path_range, mob/agent, datum/callback/CB, list/ignore)
	if(!get_turf(start) || !get_turf(finish))
		return

	var/datum/xeno_pathinfo/data = get_or_create_pathinfo(agent)
	data.configure_search(get_turf(start), get_turf(finish), path_range, agent, CB, ignore)

/datum/xeno_pathinfo
	var/turf/start
	var/turf/finish
	var/mob/agent
	var/datum/callback/to_return
	var/path_range

	var/turf/current_node
	var/list/ignore
	var/list/visited_nodes
	var/list/distances
	var/list/f_distances
	var/list/prev

/datum/xeno_pathinfo/proc/qdel_wrapper()
	SIGNAL_HANDLER
	qdel(src)

/datum/xeno_pathinfo/New()
	. = ..()
	visited_nodes = list()
	distances = list()
	f_distances = list()
	prev = list()

/datum/xeno_pathinfo/proc/reset_search_state()
	current_node = null
	ignore = null
	visited_nodes.Cut()
	distances.Cut()
	f_distances.Cut()
	prev.Cut()

/datum/xeno_pathinfo/proc/configure_search(turf/new_start, turf/new_finish, new_path_range, mob/new_agent, datum/callback/new_callback, list/new_ignore)
	// Re-pathing can happen while an older search is still queued or mid-flight.
	// Reset the search frontier so stale nodes do not keep inflating the next run.
	reset_search_state()
	current_node = new_start
	start = new_start
	finish = new_finish
	agent = new_agent
	to_return = new_callback
	path_range = new_path_range
	ignore = new_ignore
	distances[current_node] = 0
	var/turf/target = finish
	f_distances[current_node] = ASTAR_COST_FUNCTION(current_node, target)
	visited_nodes += current_node

/datum/xeno_pathinfo/Destroy(force)
	// SS220 EDIT - START: deleting an obsolete request must not remove a replacement's ownership.
	// SSpathfinding.hash_path -= agent
	if(SSpathfinding.hash_path[agent] == src)
		SSpathfinding.hash_path -= agent
	// SS220 EDIT - END
	SSpathfinding.paths_to_calculate -= src
	SSpathfinding.current_processing -= src

	#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_colors), distances), 5 SECONDS)
	#endif

	start = null
	finish = null
	agent = null
	to_return = null
	visited_nodes = null
	distances = null
	f_distances = null
	prev = null
	return ..()

#ifdef TESTING
/datum/xeno_pathinfo/proc/clear_colors(list/L)
	for(var/i in L)
		var/turf/T = i
		for(var/l in T)
			var/atom/A = l
			A.color = null
		T.color = null
#endif

#undef PATHFINDING_EXPANSIONS_PER_TURN // SS220 EDIT: keep the scheduling quantum local to this subsystem.
