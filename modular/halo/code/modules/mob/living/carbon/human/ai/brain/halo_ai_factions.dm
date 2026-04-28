/datum/human_ai_faction/unsc
	faction = FACTION_UNSC
	friendly_factions = list(
		FACTION_UNSCN,
		FACTION_ONI,
		FACTION_UEG_POLICE,
		FACTION_MARINE,
	)

/datum/human_ai_faction/unscn
	faction = FACTION_UNSCN
	friendly_factions = list(
		FACTION_UNSC,
		FACTION_ONI,
		FACTION_UEG_POLICE,
		FACTION_MARINE,
	)

/datum/human_ai_faction/oni
	faction = FACTION_ONI
	friendly_factions = list(
		FACTION_UNSC,
		FACTION_UNSCN,
		FACTION_UEG_POLICE,
		FACTION_MARINE,
	)

/datum/human_ai_faction/ueg_police
	faction = FACTION_UEG_POLICE
	friendly_factions = list(
		FACTION_UNSC,
		FACTION_UNSCN,
		FACTION_ONI,
		FACTION_MARINE,
	)

/datum/human_ai_faction/insurgent
	faction = FACTION_INSURGENT

/datum/human_ai_faction/covenant
	faction = FACTION_COVENANT
	friendly_factions = list(
		FACTION_UNGGOY,
		FACTION_KIGYAR,
		FACTION_SANGHEILI,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

/datum/human_ai_faction/unggoy
	faction = FACTION_UNGGOY
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_KIGYAR,
		FACTION_SANGHEILI,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

/datum/human_ai_faction/kigyar
	faction = FACTION_KIGYAR
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_UNGGOY,
		FACTION_SANGHEILI,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

/datum/human_ai_faction/sangheili
	faction = FACTION_SANGHEILI
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_UNGGOY,
		FACTION_KIGYAR,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

/datum/human_ai_faction/specops_sangheili
	faction = FACTION_SPECOPS_SANGHEILI
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

/datum/human_ai_faction/specops_unggoy
	faction = FACTION_SPECOPS_UNGGOY
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
	)

/datum/human_ai_faction/specops_kigyar
	faction = FACTION_SPECOPS_KIGYAR
	friendly_factions = list(
		FACTION_COVENANT,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_UNGGOY,
	)
