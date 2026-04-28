/datum/human_ai_squad_preset/unsc
	faction = FACTION_UNSC

/datum/human_ai_squad_preset/unsc/rifleteam
	name = "UNSC, Rifle Team"
	desc = "A two-man UNSC rifle patrol with basic rifles and IFAKs."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/pfc/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/rifleteam/tl
	name = "UNSC, Rifle Team (TL)"
	desc = "A UNSC rifle patrol led by a DMR-equipped fireteam leader."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/tl/equipped = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/medical
	name = "UNSC, Medical Team"
	desc = "A UNSC corpsman pair with rifleman escort."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/medic/equipped = 2,
		/datum/equipment_preset/unsc/pfc/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/sniper
	name = "UNSC, Sniper Team"
	desc = "A UNSC sniper specialist with rifleman security."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/atteam
	name = "UNSC, Anti-Armor Team"
	desc = "A UNSC SPNKR specialist with rifleman security."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/squad
	name = "UNSC, Fireteam"
	desc = "A UNSC fireteam with a DMR-equipped leader and three riflemen."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/tl/equipped = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 3,
	)

/datum/human_ai_squad_preset/unsc/command
	name = "UNSC, Command Element"
	desc = "A protected UNSC command element with leader, RTO, medic, and escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/leader/equipped = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 2,
		/datum/equipment_preset/unsc/rto/equipped = 1,
		/datum/equipment_preset/unsc/medic/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/support_section
	name = "UNSC, Support Section"
	desc = "A lore-friendly UNSC support section with section leader, RTO, corpsman, and line escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/leader/equipped = 1,
		/datum/equipment_preset/unsc/rto/equipped = 1,
		/datum/equipment_preset/unsc/medic/equipped = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/marksman_section
	name = "UNSC, Marksman Section"
	desc = "A UNSC line section with a DMR-equipped fireteam leader, sniper specialist, and rifle escort."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/tl/equipped = 1,
		/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper = 1,
		/datum/equipment_preset/unsc/pfc/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/odst
	faction = FACTION_UNSC

/datum/human_ai_squad_preset/unsc/odst/rifleteam
	name = "ODST, Rifle Team"
	desc = "A two-man ODST rifle patrol."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/pfc/odst/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/odst/fireteam
	name = "ODST, Fireteam"
	desc = "An ODST fireteam with a DMR-equipped leader and riflemen."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/tl/odst/equipped = 1,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 3,
	)

/datum/human_ai_squad_preset/unsc/odst/medical
	name = "ODST, Medical Team"
	desc = "An ODST corpsman pair with rifleman escort."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/medic/odst/equipped = 2,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/odst/sniper
	name = "ODST, Sniper Team"
	desc = "An ODST sniper specialist with rifleman security."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spec/odst/equipped_sniper/ai_sniper = 1,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/odst/atteam
	name = "ODST, Anti-Armor Team"
	desc = "An ODST SPNKR specialist with rifleman security."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/ai_man = 1,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 1,
	)

/datum/human_ai_squad_preset/unsc/odst/command
	name = "ODST, Command Element"
	desc = "An ODST command element with squad leader, RTO, medic, and riflemen."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/leader/odst/equipped = 1,
		/datum/equipment_preset/unsc/rto/odst/equipped = 1,
		/datum/equipment_preset/unsc/medic/odst/equipped = 1,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 2,
	)

/datum/human_ai_squad_preset/unsc/odst/strike_team
	name = "ODST, Strike Team"
	desc = "A harder ODST strike team built around a DMR team leader, sniper, SPNKR specialist, and assault escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/unsc/tl/odst/equipped = 1,
		/datum/equipment_preset/unsc/spec/odst/equipped_sniper/ai_sniper = 1,
		/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/ai_man = 1,
		/datum/equipment_preset/unsc/pfc/odst/equipped = 2,
	)
