/datum/human_ai_squad_preset/covenant
	faction = FACTION_COVENANT

/datum/human_ai_squad_preset/covenant/unggoy_levy
	name = "Unggoy Levy"
	desc = "A covenant levy is vaguely equivalent to a fireteam, this one is just two grunt minors and a major."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/major = 1,
		/datum/equipment_preset/covenant/unggoy/minor = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_lance
	name = "Unggoy Lance"
	desc = "Equivalent to a squad-like formation, a Covenant Lance is the bread and butter of covenant groundside combat operations."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/minor = 1,
		/datum/equipment_preset/covenant/unggoy/major = 2,
		/datum/equipment_preset/covenant/unggoy/minor = 4,
	)

//The next step up from a lance is a 'file' which is basically just two lances + maybe like a commanding elite of a higher rank
//Those would be pretty big so just like, dont put them here for now.
