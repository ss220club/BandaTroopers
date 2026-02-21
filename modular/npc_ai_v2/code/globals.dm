/// Р В¤Р С‘РЎвЂЎР В°-РЎвЂћР В»Р В°Р С–Р С‘ Р Т‘Р В»РЎРЏ Р С—Р С•РЎРЊРЎвЂљР В°Р С—Р Р…Р С•Р С–Р С• rollout NPC AI v2.
GLOBAL_VAR_INIT(npc_ai_v2_human_enabled, TRUE)
GLOBAL_VAR_INIT(npc_ai_v2_xeno_enabled, TRUE)
GLOBAL_VAR_INIT(npc_ai_v2_squad_enabled, FALSE)
GLOBAL_VAR_INIT(npc_ai_v2_director_enabled, FALSE)
GLOBAL_VAR_INIT(npc_ai_v2_director_mood, NPC_AI_V2_DIRECTOR_MOOD_BALANCED)
GLOBAL_VAR_INIT(npc_ai_v2_director_pressure_bias, 0)
GLOBAL_VAR_INIT(npc_ai_v2_xeno_goal_provider_enabled, TRUE)
GLOBAL_VAR_INIT(npc_ai_v2_xeno_movement_plugins_enabled, TRUE)
/// Cached relation matrix for fast human faction checks.
GLOBAL_VAR_INIT(npc_ai_v2_human_faction_relation_matrix, list())
GLOBAL_VAR_INIT(npc_ai_v2_human_faction_relation_matrix_next_rebuild, 0)
