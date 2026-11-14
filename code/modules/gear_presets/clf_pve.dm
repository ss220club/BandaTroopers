/datum/equipment_preset/uscm/clf
	name = "Colonial Liberation Front, Insurgent"
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	languages = list(LANGUAGE_JAPANESE, LANGUAGE_RUSSIAN)
	role_comm_title = "Insurgent
	access = list(ACCESS_CLF_GENERAL)
	faction_group = FACTION_LIST_CLF
	faction = FACTION_CLF
	idtype = /obj/item/card/id/dogtag
	assignment = JOB_SQUAD_MARINE_CLF
	rank = JOB_SQUAD_MARINE
	flags = EQUIPMENT_PRESET_START_OF_ROUND|EQUIPMENT_PRESET_MARINE
	skills = /datum/skills/clf_special_forces/regular

/datum/equipment_preset/uscm/clf/eng
	name = "Colonial Liberation Front, Network Operator"
	paygrades = list(PAY_SHORT_OPR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Operator"
	access = list(ACCESS_CLF_GENERAL, ACCESS_CLF_ENGINEERING, ACCESS_CLF_FLIGHT)
	assignment = JOB_SQUAD_ENGI_CLF
	rank = JOB_SQUAD_ENGI
	skills = /datum/skills/clf_special_forces/regular/combat_engineer

/datum/equipment_preset/uscm/clf/med
	name = "Colonial Liberation Front, Sawbones"
	paygrades = list(PAY_SHORT_CDOC = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Sawbones"
	access = list(ACCESS_CLF_GENERAL, ACCESS_CLF_MEDICAL)
	assignment = JOB_SQUAD_MEDIC_CLF
	rank = JOB_SQUAD_MEDIC
	skills = /datum/skills/clf_special_forces/regular/combat_medic

/datum/equipment_preset/uscm/clf/sl
	name = "Colonial Liberation Front, Cell Leader"
	paygrades = list(PAY_SHORT_REBC = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Cell Leader"
	access = list(ACCESS_CLF_GENERAL, ACCESS_CLF_MEDICAL, ACCESS_CLF_ENGINEERING, ACCESS_CLF_SECURITY, ACCESS_CLF_ARMORY, ACCESS_CLF_FLIGHT, ACCESS_CLF_LEADERSHIP)
	assignment = JOB_SQUAD_LEADER_CLF
	rank = JOB_SQUAD_LEADER
	skills = /datum/skills/clf_special_forces/regular/team_leader
