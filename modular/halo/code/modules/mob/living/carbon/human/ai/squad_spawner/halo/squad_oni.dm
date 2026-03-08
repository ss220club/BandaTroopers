/datum/human_ai_squad_preset/oni
	faction = FACTION_ONI

/datum/human_ai_squad_preset/oni/team
	name = "ONI Security Forces Team"
	desc = "A team of ONI security forces riflemen, all equipped for hostile activity."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/security = 2,
	)

/datum/human_ai_squad_preset/oni/squad
	name = "ONI Security Forces Squad"
	desc = "A squad of ONI security forces, all equipped for hostile activity."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/security/lead = 1,
		/datum/equipment_preset/oni/security = 2,
		/datum/equipment_preset/oni/security/corpsman = 1,
	)
