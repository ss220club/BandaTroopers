
// Слоты выставлены в соответствии с одним отрядом Альфа

// Морпех
/datum/job/marine/standard/ai
	total_positions = 8
	spawn_positions = 8

// Инженер - у альфы нет, добавляется от тех. отряда
/datum/job/marine/engineer/ai
	total_positions = 0
	spawn_positions = 0

// Медик
/datum/job/marine/medic/ai
	total_positions = 2
	spawn_positions = 2

// Смартганнер
/datum/job/marine/smartgunner/ai
	total_positions = 2
	spawn_positions = 2

// Оператор
/datum/job/marine/standard/ai/rto
	total_positions = 1
	spawn_positions = 1

// Лидер группы
/datum/job/marine/tl
	total_positions = 2
	spawn_positions = 2

// Сквадной
/datum/job/marine/leader/ai
	total_positions = 1
	spawn_positions = 1

// СО
/datum/job/command/bridge/ai
	total_positions = 1
	spawn_positions = 1


// ODST
/datum/job/marine/standard/ai/odst
	title = JOB_SQUAD_MARINE_ODST
	gear_preset = /datum/equipment_preset/unsc/pfc/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/pfc/odst/lesser_rank
	job_options = list(PFC_VARIANT = "LCPL", PVT_VARIANT = "PFC")

/datum/job/marine/standard/ai/rto/odst
	title = JOB_SQUAD_RTO_ODST
	gear_preset = /datum/equipment_preset/unsc/rto/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/rto/odst/lesser_rank
	job_options = list(PFC_VARIANT = "PFC", LCPL_VARIANT = "LCPL")

/obj/effect/landmark/start/marine/odst
	name = JOB_SQUAD_MARINE_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/standard/ai/odst
	
/obj/effect/landmark/start/marine/rto/odst
	name = JOB_SQUAD_RTO_ODST
	squad = SQUAD_ODST
	job = /datum/job/marine/standard/ai/rto/odst
