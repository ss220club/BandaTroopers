/datum/human_ai_squad_preset/police
	faction = FACTION_UEG_POLICE

/datum/human_ai_squad_preset/police/patrol
	name = "UEG Police Patrol (Gearless)"
	desc = "A pair of UEG police officers, without armor."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer = 2,
	)

/datum/human_ai_squad_preset/police/patrol/armored
	name = "UEG Police Patrol (Geared, Pistol + SMG)"
	desc = "A pair of UEG police officers, with armor and one of them equipped with an SMG."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/geared/smg = 1,
		/datum/equipment_preset/police/officer/geared = 1,
	)

/datum/human_ai_squad_preset/police/squad
	name = "UEG Police Squad"
	desc = "A squad of UEG police officers, all equipped for hostile activity.."
	ai_to_spawn = list(
		/datum/equipment_preset/police/officer/sergeant/geared = 1,
		/datum/equipment_preset/police/officer/geared/smg = 2,
		/datum/equipment_preset/police/officer/geared = 1,
	)
