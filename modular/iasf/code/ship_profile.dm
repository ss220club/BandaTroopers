/datum/modular_ship_platoon_profile/iasf
	platoon_type = /datum/squad/marine/iasf

/datum/modular_ship_platoon_profile/iasf/initialize_profile()
	role_mappings = list(
		/datum/job/command/bridge/ai/rmc/iasf = JOB_IASF_OFFICER,
		/datum/job/marine/leader/ai/rmc/iasf = JOB_IASF_SERGEANT,
		/datum/job/marine/tl/ai/rmc2ic/iasf = JOB_IASF_TEAM,
		/datum/job/marine/standard/ai/rmc/iasf = JOB_IASF_TROOPER,
		/datum/job/marine/medic/ai/rmc/iasf = JOB_IASF_MEDIC,
		/datum/job/marine/smartgunner/ai/rmc/iasf = JOB_IASF_GUNNER,
		/datum/job/marine/specialist/ai/rmc/iasf = JOB_IASF_SNIPER,
		/datum/job/marine/engineer/ai/rmc/iasf = JOB_IASF_BREACHER,
		/datum/job/marine/engineer/ai/rmcmortar/iasf = JOB_IASF_ENGINEER,
	)
	lowpop_roles = list(
		JOB_IASF_OFFICER,
		JOB_IASF_SERGEANT,
		JOB_IASF_TEAM,
		JOB_IASF_TROOPER,
		JOB_IASF_MEDIC,
		JOB_IASF_GUNNER,
		JOB_IASF_SNIPER,
		JOB_IASF_BREACHER,
		JOB_IASF_ENGINEER,
	)
	distress_roles = lowpop_roles + GLOB.ROLES_GROUND
	preview_presets = list(
		JOB_IASF_OFFICER = /datum/equipment_preset/iasf/lieutenant,
		JOB_IASF_SERGEANT = /datum/equipment_preset/iasf/troopsergeant,
		JOB_IASF_TEAM = /datum/equipment_preset/iasf/leader/lesser,
		JOB_IASF_TROOPER = /datum/equipment_preset/iasf/standard,
		JOB_IASF_MEDIC = /datum/equipment_preset/iasf/medic,
		JOB_IASF_GUNNER = /datum/equipment_preset/iasf/machinegun,
		JOB_IASF_SNIPER = /datum/equipment_preset/iasf/sniper/light,
		JOB_IASF_BREACHER = /datum/equipment_preset/iasf/breacher,
		JOB_IASF_ENGINEER = /datum/equipment_preset/iasf/engineer,
	)
	platoon_label = "Turing Watch"
	manifest_picture = /atom/movable/screen/text/screen_text/picture/starting/twe
