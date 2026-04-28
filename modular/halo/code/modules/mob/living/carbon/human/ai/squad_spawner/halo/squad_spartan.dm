/datum/human_ai_squad_preset/unsc/spartan
	faction = FACTION_UNSC

/datum/human_ai_squad_preset/unsc/spartan/assault_pair
	name = "UNSC, Spartan Assault Pair"
	desc = "A two-Spartan direct-action pair for fast assault and recovery tasks."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spartan/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/spartan/sniper_cell
	name = "UNSC, Spartan Sniper Cell"
	desc = "A Spartan sniper with an assault Spartan spotter and security wing."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spartan/sniper = 1,
		/datum/equipment_preset/unsc/spartan/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/spartan/hunter_killer_team
	name = "UNSC, Spartan Hunter-Killer Team"
	desc = "A compact Spartan hunter-killer element with anti-armor and breaching support."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spartan/spnkr/ai_man = 1,
		/datum/equipment_preset/unsc/spartan/cqc = 1,
		/datum/equipment_preset/unsc/spartan/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/spartan/strike_team
	name = "UNSC, Spartan Strike Team"
	desc = "A full Spartan strike team with assault, breach, anti-armor, and overwatch roles."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spartan/equipped = 1,
		/datum/equipment_preset/unsc/spartan/cqc = 1,
		/datum/equipment_preset/unsc/spartan/spnkr/ai_man = 1,
		/datum/equipment_preset/unsc/spartan/sniper = 1,
	)
