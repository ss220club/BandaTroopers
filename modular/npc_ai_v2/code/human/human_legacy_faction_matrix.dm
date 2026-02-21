#define NPC_AI_V2_HUMAN_FACTION_MATRIX_REBUILD_COOLDOWN (5 SECONDS)
#define NPC_AI_V2_HUMAN_FACTION_RELATION_NEUTRAL 1
#define NPC_AI_V2_HUMAN_FACTION_RELATION_FRIENDLY 2

/// RU: Выполняет служебный этап в human AI v2 (этап: npc ai v2 refresh human faction relation matrix) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: npc ai v2 refresh human faction relation matrix) to coordinate state between AI v2 subsystems.
/proc/npc_ai_v2_refresh_human_faction_relation_matrix(force = FALSE)
	if(!force && world.time < GLOB.npc_ai_v2_human_faction_relation_matrix_next_rebuild)
		return

	var/list/new_matrix = list()
	var/list/runtime_factions = get_human_ai_runtime_factions()
	if(islist(runtime_factions))
		for(var/faction_name in runtime_factions)
			var/datum/human_ai_faction/faction_data = runtime_factions[faction_name]
			if(!faction_data || !faction_data.faction)
				continue

			var/list/relation_row = list()
			relation_row[faction_data.faction] = NPC_AI_V2_HUMAN_FACTION_RELATION_FRIENDLY

			var/list/friendly_factions = faction_data.get_friendly_factions()
			if(islist(friendly_factions))
				for(var/friendly_faction in friendly_factions)
					relation_row[friendly_faction] = NPC_AI_V2_HUMAN_FACTION_RELATION_FRIENDLY

			var/list/neutral_factions = faction_data.get_neutral_factions()
			if(islist(neutral_factions))
				for(var/neutral_faction in neutral_factions)
					relation_row[neutral_faction] = NPC_AI_V2_HUMAN_FACTION_RELATION_NEUTRAL

			new_matrix[faction_data.faction] = relation_row

	GLOB.npc_ai_v2_human_faction_relation_matrix = new_matrix
	GLOB.npc_ai_v2_human_faction_relation_matrix_next_rebuild = world.time + NPC_AI_V2_HUMAN_FACTION_MATRIX_REBUILD_COOLDOWN

/// RU: Выполняет служебный этап в human AI v2 (этап: npc ai v2 get human faction relation) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: npc ai v2 get human faction relation) to coordinate state between AI v2 subsystems.
/proc/npc_ai_v2_get_human_faction_relation(my_faction, target_faction)
	if(!my_faction || !target_faction)
		return null

	npc_ai_v2_refresh_human_faction_relation_matrix()
	var/list/relation_row = GLOB.npc_ai_v2_human_faction_relation_matrix[my_faction]
	if(!islist(relation_row))
		return null

	return relation_row[target_faction]

/// RU: Выполняет служебный этап в human AI v2 (этап: npc ai v2 apply faction matrix to brain) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: npc ai v2 apply faction matrix to brain) to coordinate state between AI v2 subsystems.
/proc/npc_ai_v2_apply_faction_matrix_to_brain(datum/human_ai_brain/brain)
	if(!brain || !brain.tied_human?.faction)
		return

	npc_ai_v2_refresh_human_faction_relation_matrix()
	var/list/relation_row = GLOB.npc_ai_v2_human_faction_relation_matrix[brain.tied_human.faction]
	if(!islist(relation_row))
		return

	var/list/friendly_set = list()
	var/list/neutral_set = list()
	for(var/target_faction in relation_row)
		var/relation = relation_row[target_faction]
		if(relation == NPC_AI_V2_HUMAN_FACTION_RELATION_FRIENDLY)
			friendly_set[target_faction] = TRUE
		else if(relation == NPC_AI_V2_HUMAN_FACTION_RELATION_NEUTRAL)
			neutral_set[target_faction] = TRUE

	brain.friendly_factions = friendly_set
	brain.neutral_factions = neutral_set

#undef NPC_AI_V2_HUMAN_FACTION_MATRIX_REBUILD_COOLDOWN
#undef NPC_AI_V2_HUMAN_FACTION_RELATION_NEUTRAL
#undef NPC_AI_V2_HUMAN_FACTION_RELATION_FRIENDLY
