/datum/human_ai_squad_preset/insurgent
	faction = FACTION_INSURGENT

/datum/human_ai_squad_preset/insurgent/partisan_patrol
	name = "Insurgent Partisan Patrol"
	desc = "A badly equipped partisan patrol with improvised small arms."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/smg = 1,
		/datum/equipment_preset/insurgent/partisan = 1,
	)

/datum/human_ai_squad_preset/insurgent/partisan_patrol/plainclothes
	name = "Insurgent Plainclothes Patrol"
	desc = "A plainclothes partisan pair carrying concealable but still dangerous weapons."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/plainclothes/smg = 1,
		/datum/equipment_preset/insurgent/partisan/plainclothes = 1,
	)

/datum/human_ai_squad_preset/insurgent/partisan_squad
	name = "Insurgent Partisan Assault Group"
	desc = "A partisan assault group built around a breach-oriented irregular."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/breach = 1,
		/datum/equipment_preset/insurgent/partisan/smg = 2,
		/datum/equipment_preset/insurgent/partisan = 1,
	)

/datum/human_ai_squad_preset/insurgent/patrol
	name = "Insurgent Patrol"
	desc = "A simple insurgent patrol made from standard riflemen."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/rifleman = 2,
	)

/datum/human_ai_squad_preset/insurgent/at_team
	name = "Insurgent Anti-Armor Team"
	desc = "An insurgent SPNKR team with a rifle escort."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/specialist = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)

/datum/human_ai_squad_preset/insurgent/sapper_team
	name = "Insurgent Sapper Team"
	desc = "A field technician and rifleman pair for sabotage and breaching support."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/technician = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)

/datum/human_ai_squad_preset/insurgent/squad
	name = "Insurgent Squad"
	desc = "A basic insurgent squad under a cell leader with engineering support."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/rifleman/sl = 1,
		/datum/equipment_preset/insurgent/rifleman = 2,
		/datum/equipment_preset/insurgent/technician = 1,
	)

/datum/human_ai_squad_preset/insurgent/breach_cell
	name = "Insurgent Breach Cell"
	desc = "A breaching insurgent cell with a shock rifleman, technician, and line escort."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/rifleman/breacher = 1,
		/datum/equipment_preset/insurgent/technician = 1,
		/datum/equipment_preset/insurgent/rifleman = 2,
	)

/datum/human_ai_squad_preset/insurgent/sniper_cell
	name = "Insurgent Sniper Cell"
	desc = "A hidden insurgent sniper team with a spotter-leader and rifle security."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/specialist/sniper = 1,
		/datum/equipment_preset/insurgent/rifleman/sl = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)

/datum/human_ai_squad_preset/insurgent/command_cell
	name = "Insurgent Command Cell"
	desc = "A heavier insurgent command cell with officer leadership, a cell leader, and specialist support."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/officer = 1,
		/datum/equipment_preset/insurgent/cell_leader = 1,
		/datum/equipment_preset/insurgent/specialist/ai_man = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)
