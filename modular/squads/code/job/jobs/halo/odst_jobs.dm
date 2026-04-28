/datum/job/marine/standard/ai/halo/odst
	title = JOB_SQUAD_MARINE_ODST
	gear_preset = /datum/equipment_preset/unsc/pfc/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/pfc/odst/lesser_rank
	job_options = list(HALO_PFC_VARIANT = "LCPL", HALO_PVT_VARIANT = "PFC")

/datum/job/marine/standard/ai/rto/halo/odst
	title = JOB_SQUAD_RTO_ODST
	gear_preset = /datum/equipment_preset/unsc/rto/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/rto/odst/lesser_rank
	job_options = list(HALO_PFC_VARIANT = "PFC", HALO_LCPL_VARIANT = "LCPL")

/datum/job/marine/leader/ai/halo/odst
	title = JOB_SQUAD_LEADER_ODST
	gear_preset = /datum/equipment_preset/unsc/leader/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/leader/odst/lesser_rank

/datum/job/marine/medic/ai/halo/odst
	title = JOB_SQUAD_MEDIC_ODST
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/medic/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/medic/odst/lesser_rank
	gear_preset_tertiary = /datum/equipment_preset/unsc/medic/odst/pfc
	gear_preset_quaternary = /datum/equipment_preset/unsc/medic/odst/private
	job_options = list(HALO_CPL_VARIANT = "CPL", HALO_LCPL_VARIANT = "LCPL", HALO_PFC_VARIANT = "PFC", HALO_PVT_VARIANT = "PVT")

/datum/job/marine/tl/ai/halo/odst
	title = JOB_SQUAD_TEAM_LEADER_ODST
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/tl/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/tl/odst/lesser_rank

/datum/job/marine/specialist/ai/halo/odst
	title = JOB_SQUAD_SPECIALIST_ODST
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/spec/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/spec/odst/lesser_rank

/datum/job/command/bridge/ai/halo/odst
	title = JOB_SO_ODST
	gear_preset = /datum/equipment_preset/unsc/platco/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/platco/odst/lesser_rank

/obj/effect/landmark/late_join/odst
	name = "odst late join"
	squad = SQUAD_ODST

/obj/effect/landmark/start/marine/odst
	name = JOB_SQUAD_MARINE_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/standard/ai/halo/odst

/obj/effect/landmark/start/marine/rto/odst
	name = JOB_SQUAD_RTO_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/standard/ai/rto/halo/odst

/obj/effect/landmark/start/marine/medic/odst
	name = JOB_SQUAD_MEDIC_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/medic/ai/halo/odst

/obj/effect/landmark/start/marine/tl/odst
	name = JOB_SQUAD_TEAM_LEADER_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/tl/ai/halo/odst

/obj/effect/landmark/start/marine/leader/odst
	name = JOB_SQUAD_LEADER_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/leader/ai/halo/odst

/obj/effect/landmark/start/marine/spec/odst
	name = JOB_SQUAD_SPECIALIST_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/specialist/ai/halo/odst
