/datum/human_ai_squad_preset/canc_dogwar
	faction = FACTION_CANC_DOGWAR

/datum/human_ai_squad_preset/canc_dogwar/patrol

	name = "CANC Armed Forces, Patrol"
	desc = "CANCAF patrol. 2 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/rifle_team

	name = "CANC Armed Forces, Rifle Team"
	desc = "CANCAF rifle team. 3 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/mg_team

	name = "CANC Armed Forces, MG Team"
	desc = "CANCAF MG team. 1 rifleman and 1 machinegunner."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/machinegunner = 1,
		/datum/equipment_preset/canc_dogwar/soldier = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/at_team

	name = "CANC Armed Forces, AT Team"
	desc = "CANCAF AT team. 1 loader and 1 anti-tank specialist."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/antitank = 1,
		/datum/equipment_preset/canc_dogwar/soldier/antitank_loader = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/aa_team

	name = "CANC Armed Forces, AA Team"
	desc = "CANCAF AA team. 1 rifleman and 1 anti-air rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/antiair = 1,
		/datum/equipment_preset/canc_dogwar/soldier = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/half_squad

	name = "CANC Armed Forces, Half Squad"
	desc = "CANCAF Half Squad. 3 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/leader = 1,
		/datum/equipment_preset/canc_dogwar/soldier/medic = 1,
		/datum/equipment_preset/canc_dogwar/soldier = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/full_squad

	name = "CANC Armed Forces, Full Squad"
	desc = "CANCAF Full Squad. 6 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/leader = 1,
		/datum/equipment_preset/canc_dogwar/soldier/medic = 1,
		/datum/equipment_preset/canc_dogwar/soldier = 6,
	)

/datum/human_ai_squad_preset/canc_dogwar/full_platoon

	name = "CANC Armed Forces, Full Platoon"
	desc = "CANCAF Full Platoon. 12 rifleman, 2 medic, 2 squad leaders and 1 platoon leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/pl_leader = 1,
		/datum/equipment_preset/canc_dogwar/soldier/leader = 2,
		/datum/equipment_preset/canc_dogwar/soldier/medic = 2,
		/datum/equipment_preset/canc_dogwar/soldier = 12,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/patrol

	name = "CANC Colonial Militia, Patrol"
	desc = "CANC Colonial Militia Patrol. 2 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/rifle_team

	name = "CANC Colonial Militia, Rifle Team"
	desc = "CANC Colonial Militia Rifle Team. 3 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/lmg_team

	name = "CANC Colonial Militia, LMG Team"
	desc = "CANC Colonial Militia LMG Team. 1 rifleman and 1 LMG gunner."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia/lmg = 1,
		/datum/equipment_preset/canc_dogwar/militia = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/at_team

	name = "CANC Colonial Militia, AT Team"
	desc = "CANC Colonial Militia AT Team. 1 rifleman and 1 AT rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia/antitank = 1,
		/datum/equipment_preset/canc_dogwar/militia = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/breach_team

	name = "CANC Colonial Militia, Breach Team"
	desc = "CANC Colonial Militia Breach Team. 2 rifleman and 1 shotgunner."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia/shotgun = 1,
		/datum/equipment_preset/canc_dogwar/militia = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/half_squad

	name = "CANC Colonial Militia, Half Squad"
	desc = "CANC Colonial Militia Half Squad. 3 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia/leader = 1,
		/datum/equipment_preset/canc_dogwar/militia/medic = 1,
		/datum/equipment_preset/canc_dogwar/militia = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/militia/full_squad

	name = "CANC Colonial Militia, Full Squad"
	desc = "CANC Colonial Militia Full Squad. 6 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/militia/leader = 1,
		/datum/equipment_preset/canc_dogwar/militia/medic = 1,
		/datum/equipment_preset/canc_dogwar/militia = 6,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/patrol

	name = "CANC Armed Forces, Patrol (UPP)"
	desc = "CANCAF Patrol. 2 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/rifle_team

	name = "CANC Armed Forces, Rifle Team (UPP)"
	desc = "CANCAF Rifle Team. 3 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/mg_team

	name = "CANC Armed Forces, MG Team (UPP)"
	desc = "CANCAF MG Team. 1 rifleman and 1 MG gunner."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/machinegunner = 1,
		/datum/equipment_preset/canc_dogwar/upp = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/at_team

	name = "CANC Armed Forces, AT Team (UPP)"
	desc = "CANCAF AT Team. 1 loader and 1 AT rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/soldier/antitank = 1,
		/datum/equipment_preset/canc_dogwar/upp/antitank_loader = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/aa_team

	name = "CANC Armed Forces, AA Team (UPP)"
	desc = "CANCAF AA Team. 1 rifleman and 1 AA specialist."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp/antiair = 1,
		/datum/equipment_preset/canc_dogwar/upp = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/breach_team

	name = "CANC Armed Forces, Breach Team (UPP)"
	desc = "CANCAF Breach Team. 2 rifleman and 1 shotgunner."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp/shotgun = 1,
		/datum/equipment_preset/canc_dogwar/upp = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/half_squad

	name = "CANC Armed Forces, Half Squad (UPP)"
	desc = "CANCAF Half Squad. 3 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp/leader = 1,
		/datum/equipment_preset/canc_dogwar/upp = 3,
		/datum/equipment_preset/canc_dogwar/upp/medic = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/full_squad

	name = "CANC Armed Forces, Full Squad (UPP)"
	desc = "CANCAF Full Squad. 6 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp/leader = 1,
		/datum/equipment_preset/canc_dogwar/upp = 6,
		/datum/equipment_preset/canc_dogwar/upp/medic = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/upp/full_platoon

	name = "CANC Armed Forces, Full Platoon (UPP)"
	desc = "CANCAF Full Platoon. 12 rifleman, 2 medic, 2 squad leader and 1 platoon leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/upp/pl_leader = 1, // SS220 EDIT: match the real UPP platoon leader preset path
		/datum/equipment_preset/canc_dogwar/upp/leader = 2,
		/datum/equipment_preset/canc_dogwar/upp = 12,
		/datum/equipment_preset/canc_dogwar/upp/medic = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/patrol

	name = "CANC SOF, Patrol"
	desc = "CANC SOF Patrol. 2 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops = 2,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/rifle_team

	name = "CANC SOF, Rifle Team"
	desc = "CANC SOF Rifle Team. 3 rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops = 3,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/at_team

	name = "CANC SOF, AT Team"
	desc = "CANC SOF AT Team. 1 rifleman and 1 AT rifleman."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops/antitank = 1,
		/datum/equipment_preset/canc_dogwar/specops = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/small_squad

	name = "CANC SOF, Small Squad"
	desc = "CANC SOF Small Squad. 2 rifleman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops/leader = 1,
		/datum/equipment_preset/canc_dogwar/specops = 2,
		/datum/equipment_preset/canc_dogwar/specops/medic = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/half_squad

	name = "CANC SOF, Half Squad"
	desc = "CANC SOF Half Squad. 3 rifleman, 1 marksman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops/leader = 1,
		/datum/equipment_preset/canc_dogwar/specops = 3,
		/datum/equipment_preset/canc_dogwar/specops/marksman = 1,
		/datum/equipment_preset/canc_dogwar/specops/medic = 1,
	)

/datum/human_ai_squad_preset/canc_dogwar/specops/full_squad

	name = "CANC SOF, Full Squad"
	desc = "CANC SOF Full Squad. 5 rifleman, 2 AT rifleman, 1 marksman, 1 medic and 1 squad leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc_dogwar/specops/leader = 1,
		/datum/equipment_preset/canc_dogwar/specops = 5,
		/datum/equipment_preset/canc_dogwar/specops/antitank = 2,
		/datum/equipment_preset/canc_dogwar/specops/marksman = 1,
		/datum/equipment_preset/canc_dogwar/specops/medic = 1,
	)
