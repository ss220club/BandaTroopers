/datum/human_ai_squad_preset/oni
	faction = FACTION_ONI

/datum/human_ai_squad_preset/oni/team
	name = "ONI Security Team"
	desc = "A compact ONI security team equipped for internal defense and checkpoint work."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/security = 2,
	)

/datum/human_ai_squad_preset/oni/squad
	name = "ONI Security Squad"
	desc = "An ONI security squad with a lead, corpsman, and armed riflemen."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/security/lead = 1,
		/datum/equipment_preset/oni/security = 2,
		/datum/equipment_preset/oni/security/corpsman = 1,
	)

/datum/human_ai_squad_preset/oni/field_cell
	name = "ONI Field Cell"
	desc = "A covert ONI field cell with a senior agent, agent partner, and field operative support."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/field/agent/senior = 1,
		/datum/equipment_preset/oni/field/agent = 1,
		/datum/equipment_preset/oni/field = 1,
	)

/datum/human_ai_squad_preset/oni/mixed_response_team
	name = "ONI Mixed Response Team"
	desc = "An ONI response package mixing security command with a field operative element."
	ai_to_spawn = list(
		/datum/equipment_preset/oni/security/lead = 1,
		/datum/equipment_preset/oni/security = 1,
		/datum/equipment_preset/oni/security/corpsman = 1,
		/datum/equipment_preset/oni/field/agent = 1,
	)
