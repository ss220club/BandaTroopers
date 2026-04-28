/datum/human_ai_squad_preset/police
	faction = FACTION_UEG_POLICE

/datum/human_ai_squad_preset/police/patrol
	name = "UEG Police Patrol"
	desc = "A pair of lightly equipped UEG police officers."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer = 2,
	)

/datum/human_ai_squad_preset/police/patrol/armored
	name = "UEG Police Armored Patrol"
	desc = "A geared police patrol with one SMG officer and one sidearm officer."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/geared/smg = 1,
		/datum/equipment_preset/police/officer/geared = 1,
	)

/datum/human_ai_squad_preset/police/squad
	name = "UEG Police Squad"
	desc = "A UEG police squad with a sergeant, SMG officers, and an armored patrolman."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/sergeant/geared = 1,
		/datum/equipment_preset/police/officer/geared/smg = 2,
		/datum/equipment_preset/police/officer/geared = 1,
	)

/datum/human_ai_squad_preset/police/sergeant_patrol
	name = "UEG Police Sergeant Patrol"
	desc = "A patrol led by a geared sergeant with a pair of armored officers."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/sergeant/geared = 1,
		/datum/equipment_preset/police/officer/geared = 2,
	)

/datum/human_ai_squad_preset/police/enforcer_response
	name = "UEG Police Enforcer Response"
	desc = "A tougher UEG police response team with a shotgun enforcer, sergeant, and SMG officers."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/sergeant/geared = 1,
		/datum/equipment_preset/police/officer/geared/enforcer = 1,
		/datum/equipment_preset/police/officer/geared/smg = 2,
	)
