GLOBAL_LIST_EMPTY(human_ai_squad_presets)

/datum/human_squad_spawner_menu
	var/static/list/lazy_ui_data = list()

/datum/human_squad_spawner_menu/New()
	if(!length(GLOB.human_ai_squad_presets))
		for(var/datum/human_ai_squad_preset/squad_type as anything in subtypesof(/datum/human_ai_squad_preset))
			if(!squad_type::name)
				continue

			if(!lazy_ui_data[squad_type::faction])
				lazy_ui_data[squad_type::faction] = list()

			var/datum/human_ai_squad_preset/squad_obj = new squad_type()
			GLOB.human_ai_squad_presets["[squad_type]"] = squad_obj

			var/list/contains = list()
			for(var/datum/equipment_preset/equip_path as anything in squad_obj.ai_to_spawn)
				contains += "[squad_obj.ai_to_spawn[equip_path]]x [equip_path::name]"

			lazy_ui_data[squad_type::faction] += list(list(
				"name" = squad_obj.name,
				"description" = squad_obj.desc,
				"path" = squad_type,
				"contents" = contains,
			))


/datum/human_squad_spawner_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanSquadSpawner")
		ui.open()

/datum/human_squad_spawner_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_squad_spawner_menu/ui_data(mob/user)
	var/list/data = list()

	return data

/datum/human_squad_spawner_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["squads"] = lazy_ui_data

	return data

/datum/human_squad_spawner_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_squad")
			if(!params["path"])
				return FALSE

			var/gotten_path = params["path"]
			if(!gotten_path)
				return FALSE

			var/datum/human_ai_squad_preset/preset_squad = GLOB.human_ai_squad_presets[gotten_path]
			if(!preset_squad)
				return FALSE

			var/turf/spawn_turf = get_turf(ui.user)
			if(!spawn_turf)
				return FALSE

			// SS220 EDIT - START: pass spawn radius and filter toggles from the panel to squad spawning
			var/spawn_radius = preset_squad.normalize_spawn_radius(params["radius"])
			var/only_accessible_raw = params["only_accessible"]
			var/only_accessible_tiles = isnull(only_accessible_raw) ? TRUE : !!text2num("[only_accessible_raw]")
			var/only_reachable_raw = params["only_reachable"]
			var/only_reachable_tiles = isnull(only_reachable_raw) ? FALSE : !!text2num("[only_reachable_raw]")
			var/windows_blockers_raw = params["windows_blockers"]
			var/treat_windows_as_blockers = isnull(windows_blockers_raw) ? TRUE : !!text2num("[windows_blockers_raw]")
			var/preset_name = preset_squad.name
			if(!preset_name)
				preset_name = "[gotten_path]"

			var/list/spawn_candidates = preset_squad.get_spawn_candidate_turfs(spawn_turf, spawn_radius, only_accessible_tiles, only_reachable_tiles, treat_windows_as_blockers)
			if(!length(spawn_candidates))
				to_chat(ui.user, SPAN_WARNING("Failed to spawn [preset_name]: no valid spawn turfs were found."))
				log_admin("[key_name(ui.user)] failed to spawn Human AI squad [preset_name] at ([spawn_turf.x],[spawn_turf.y],[spawn_turf.z]): no valid spawn turfs were found.")
				return FALSE

			// preset_squad.spawn_ai(get_turf(ui.user))
			var/datum/human_ai_squad/new_squad = preset_squad.spawn_ai(spawn_turf, spawn_radius, only_accessible_tiles, only_reachable_tiles, spawn_candidates, treat_windows_as_blockers)
			if(!new_squad || !length(new_squad.ai_in_squad))
				if(new_squad)
					qdel(new_squad)
				to_chat(ui.user, SPAN_WARNING("Failed to spawn [preset_name]: squad creation did not produce any AI members."))
				log_admin("[key_name(ui.user)] failed to spawn Human AI squad [preset_name] at ([spawn_turf.x],[spawn_turf.y],[spawn_turf.z]): squad creation produced no AI members.")
				return FALSE
			// SS220 EDIT - END
			return TRUE

/client/proc/open_human_squad_spawner_panel()
	set name = "Human AI Squad Spawner Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	if(human_squad_menu)
		human_squad_menu.tgui_interact(mob)
		return

	human_squad_menu = new /datum/human_squad_spawner_menu(src)
	human_squad_menu.tgui_interact(mob)

/datum/human_ai_squad_preset
	var/name = ""
	var/desc = ""
	var/faction = FACTION_NEUTRAL
	/// First entry is marked as squad leader
	var/list/ai_to_spawn = list()

// SS220 EDIT - START: attach spawn helper logic to the preset instead of introducing global proc pollution
/datum/human_ai_squad_preset/proc/normalize_spawn_radius(spawn_radius)
	if(!isnum(spawn_radius))
		spawn_radius = text2num("[spawn_radius]")

	if(isnull(spawn_radius))
		spawn_radius = 1

	return clamp(round(spawn_radius), 1, 10)

/datum/human_ai_squad_preset/proc/get_viable_spawn_turfs(turf/spawn_loc, radius = 1, only_accessible = TRUE, only_reachable = FALSE, treat_windows_as_blockers = TRUE)
	return get_spawn_candidate_turfs(spawn_loc, radius, only_accessible, only_reachable, treat_windows_as_blockers)

/datum/human_ai_squad_preset/proc/is_spawn_turf_center_blocked(turf/checking_turf, treat_windows_as_blockers = TRUE)
	if(!checking_turf || checking_turf.density)
		return TRUE

	for(var/atom/blocker as anything in checking_turf)
		if(ismob(blocker))
			continue
		if(istype(blocker, /obj/structure/window))
			if(treat_windows_as_blockers)
				return TRUE
			continue
		if(!blocker.density)
			continue
		// Border blockers do not occupy the tile center; path accessibility is validated separately.
		if(blocker.flags_atom & ON_BORDER)
			continue

		return TRUE

	return FALSE

/datum/human_ai_squad_preset/proc/is_spawn_turf_occupied(turf/checking_turf)
	if(!checking_turf)
		return FALSE

	for(var/mob/occupant as anything in checking_turf)
		if(!QDELETED(occupant))
			return TRUE

	return FALSE

/datum/human_ai_squad_preset/proc/get_adjacent_spawn_turfs(turf/current_turf, treat_windows_as_blockers = TRUE)
	var/list/adjacent_turfs = list()
	if(!current_turf)
		return adjacent_turfs

	if(!treat_windows_as_blockers)
		return current_turf.AdjacentTurfs()

	for(var/turf/adjacent_turf as anything in current_turf.AdjacentTurfs())
		if(is_spawn_turf_center_blocked(adjacent_turf, TRUE))
			continue
		adjacent_turfs += adjacent_turf

	return adjacent_turfs

/datum/human_ai_squad_preset/proc/get_reachable_spawn_candidate_refs(turf/start_turf, list/candidate_turfs, spawn_radius, treat_windows_as_blockers = TRUE)
	var/list/reachable_candidate_refs = list()
	if(!start_turf || !length(candidate_turfs))
		return reachable_candidate_refs

	var/list/pending_candidate_refs = list()
	var/list/occupied_candidate_refs = list()
	var/list/occupied_candidate_adjacency = list()
	for(var/turf/candidate_turf as anything in candidate_turfs)
		var/candidate_ref = REF(candidate_turf)
		pending_candidate_refs[candidate_ref] = TRUE

		if(!is_spawn_turf_occupied(candidate_turf))
			continue

		occupied_candidate_refs[candidate_ref] = TRUE
		for(var/direction in GLOB.cardinals)
			var/turf/adjacent_turf = get_step(candidate_turf, direction)
			if(!isturf(adjacent_turf) || is_spawn_turf_center_blocked(adjacent_turf, treat_windows_as_blockers))
				continue

			var/adjacent_ref = REF(adjacent_turf)
			if(!occupied_candidate_adjacency[adjacent_ref])
				occupied_candidate_adjacency[adjacent_ref] = list()
			occupied_candidate_adjacency[adjacent_ref][candidate_ref] = TRUE

	var/list/visited_turf_refs = list(
		REF(start_turf) = TRUE,
	)
	var/list/open_turfs = list(start_turf)
	var/search_index = 1
	while(search_index <= length(open_turfs) && (length(pending_candidate_refs) || length(occupied_candidate_refs)))
		var/turf/current_turf = open_turfs[search_index++]
		var/current_ref = REF(current_turf)

		if(pending_candidate_refs[current_ref])
			reachable_candidate_refs[current_ref] = TRUE
			pending_candidate_refs -= current_ref
			if(occupied_candidate_refs[current_ref])
				occupied_candidate_refs -= current_ref

		var/list/unlocked_occupied_candidates = occupied_candidate_adjacency[current_ref]
		if(unlocked_occupied_candidates)
			for(var/candidate_ref in unlocked_occupied_candidates)
				reachable_candidate_refs[candidate_ref] = TRUE
				if(pending_candidate_refs[candidate_ref])
					pending_candidate_refs -= candidate_ref
				if(occupied_candidate_refs[candidate_ref])
					occupied_candidate_refs -= candidate_ref

		for(var/turf/adjacent_turf as anything in get_adjacent_spawn_turfs(current_turf, treat_windows_as_blockers))
			if(get_dist(start_turf, adjacent_turf) > spawn_radius)
				continue

			var/adjacent_ref = REF(adjacent_turf)
			if(visited_turf_refs[adjacent_ref])
				continue

			visited_turf_refs[adjacent_ref] = TRUE
			open_turfs += adjacent_turf

	return reachable_candidate_refs

// SS220 EDIT - END

// SS220 EDIT - START: split candidate filtering from actual spawning so accessibility rules stay testable
/datum/human_ai_squad_preset/proc/get_spawn_candidate_turfs(turf/spawn_loc, spawn_radius = 1, only_accessible_tiles = TRUE, only_reachable_tiles = FALSE, treat_windows_as_blockers = TRUE)
	var/list/viable_turfs = list()
	var/list/base_candidate_turfs = list()
	spawn_radius = normalize_spawn_radius(spawn_radius)

	if(!spawn_loc)
		return viable_turfs

	if(is_spawn_turf_center_blocked(spawn_loc, treat_windows_as_blockers))
		return viable_turfs

	for(var/turf/open/floor_tile in range(spawn_radius, spawn_loc))
		if((only_accessible_tiles || only_reachable_tiles) && is_spawn_turf_center_blocked(floor_tile, treat_windows_as_blockers))
			continue

		base_candidate_turfs += floor_tile

	if(!only_reachable_tiles || !length(base_candidate_turfs))
		return base_candidate_turfs

	var/list/reachable_candidate_refs = get_reachable_spawn_candidate_refs(spawn_loc, base_candidate_turfs, spawn_radius, treat_windows_as_blockers)
	for(var/turf/candidate_turf as anything in base_candidate_turfs)
		if(reachable_candidate_refs[REF(candidate_turf)])
			viable_turfs += candidate_turf

	return viable_turfs

/datum/human_ai_squad_preset/proc/categorize_spawn_candidate_turfs(list/candidate_turfs, treat_windows_as_blockers = TRUE)
	var/list/categorized_turfs = list(
		"free" = list(),
		"occupied" = list(),
	)

	for(var/turf/candidate_turf as anything in candidate_turfs)
		if(is_spawn_turf_center_blocked(candidate_turf, treat_windows_as_blockers))
			continue

		var/list/target_bucket = is_spawn_turf_occupied(candidate_turf) ? categorized_turfs["occupied"] : categorized_turfs["free"]
		target_bucket += candidate_turf

	return categorized_turfs

/datum/human_ai_squad_preset/proc/spawn_ai(turf/spawn_loc, spawn_radius = 1, only_accessible_tiles = TRUE, only_reachable_tiles = FALSE, list/precomputed_candidate_turfs = null, treat_windows_as_blockers = TRUE)
	var/list/viable_turfs = precomputed_candidate_turfs
	if(!islist(viable_turfs))
		viable_turfs = get_spawn_candidate_turfs(spawn_loc, spawn_radius, only_accessible_tiles, only_reachable_tiles, treat_windows_as_blockers)
	if(!length(viable_turfs))
		return null

	var/datum/human_ai_squad/new_squad = SShuman_ai.create_new_squad()
	var/list/categorized_turfs = categorize_spawn_candidate_turfs(viable_turfs, treat_windows_as_blockers)
	var/list/free_turfs = categorized_turfs["free"]
	var/list/occupied_turfs = categorized_turfs["occupied"]

	var/squad_leader_selected = FALSE
	for(var/datum/equipment_preset/ai_equipment as anything in ai_to_spawn)
		for(var/i in 1 to ai_to_spawn[ai_equipment])
			var/turf/chosen_turf
			if(length(free_turfs))
				chosen_turf = pick(free_turfs)
				free_turfs -= chosen_turf
				occupied_turfs += chosen_turf
			else if(length(occupied_turfs))
				chosen_turf = pick(occupied_turfs)

			if(!chosen_turf)
				continue

			var/mob/living/carbon/human/ai_human = modular_spawn_human_ai_from_equipment_preset(ai_equipment, chosen_turf, TRUE) // SS220 EDIT: modular HALO spawn flow validates preset species before the AI brain is attached
			if(!ai_human)
				continue

			var/datum/component/human_ai/ai_comp = ai_human.GetComponent(/datum/component/human_ai) // SS220 EDIT: shared modular spawn helper already attached the component; squad glue only consumes it
			if(!ai_comp?.ai_brain)
				continue

			new_squad.add_to_squad(ai_comp.ai_brain)
			if(!squad_leader_selected)
				new_squad.set_squad_leader(ai_comp.ai_brain)
				squad_leader_selected = TRUE

	if(!length(new_squad.ai_in_squad))
		qdel(new_squad)
		return null

	return new_squad
// SS220 EDIT - END
