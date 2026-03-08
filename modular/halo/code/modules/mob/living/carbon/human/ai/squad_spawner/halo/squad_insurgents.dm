/datum/human_ai_squad_preset/insurgent
	faction = FACTION_INSURGENT

/datum/human_ai_squad_preset/insurgent/partisan_patrol
	name = "Partisan Patrol Team (Armored, SMG + Pistol)"
	desc = "A pair of untrained and underequipped partisans."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/smg = 1,
		/datum/equipment_preset/insurgent/partisan = 1,
	)

/datum/human_ai_squad_preset/insurgent/partisan_patrol/plainclothes
	name = "Partisan Patrol Team (Plainclothes, SMG + Pistol)"
	desc = "A pair of untrained and underequipped partisans."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/plainclothes/smg = 1,
		/datum/equipment_preset/insurgent/partisan/plainclothes = 1,
	)

/datum/human_ai_squad_preset/insurgent/partisan_squad
	name = "Partisan Assault Squad"
	desc = "A squad of untrained and underequipped partisans, lead by a Partisan Breacher."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/partisan/breach = 1,
		/datum/equipment_preset/insurgent/partisan/smg = 2,
		/datum/equipment_preset/insurgent/partisan = 1,
	)

/datum/human_ai_squad_preset/insurgent/patrol
	name = "Insurgent Patrol Team"
	desc = "A pair of Insurgent soldiers formed into a patrol team."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/rifleman = 2,
	)

/datum/human_ai_squad_preset/insurgent/at_team
	name = "Insurgent AT Team"
	desc = "A pair of Insurgent soldiers, one with a SPNKr launcher to act as an AT team."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/specialist = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)

/datum/human_ai_squad_preset/insurgent/sapper_team
	name = "Insurgent Sapper Team"
	desc = "A pair of Insurgent soldiers, one being a technician to act as a sapper team."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/technician = 1,
		/datum/equipment_preset/insurgent/rifleman = 1,
	)

/datum/human_ai_squad_preset/insurgent/squad
	name = "Insurgent Squad"
	desc = "A squad of Insurgent soldiers, led by a Squad Leader."
	ai_to_spawn = list(
		/datum/equipment_preset/insurgent/rifleman/sl = 1,
		/datum/equipment_preset/insurgent/rifleman = 2,
		/datum/equipment_preset/insurgent/technician = 1,
	)
