/datum/job/command/bridge/ai/rmc/iasf
	title = JOB_IASF_OFFICER
	gear_preset = /datum/equipment_preset/iasf/lieutenant/ship
	supervisors = "IASF command"
	entry_message_body = "You are the detachment officer. Set the mission and give orders to the platoon sergeant, who coordinates the teams. Your personal equipment is stored in the command locker."

/obj/effect/landmark/start/bridge/rmc/iasf
	name = JOB_IASF_OFFICER
	squad = SQUAD_IASF_TURING
	job = /datum/job/command/bridge/ai/rmc/iasf

/datum/job/marine/leader/ai/rmc/iasf
	title = JOB_IASF_SERGEANT
	gear_preset = /datum/equipment_preset/iasf/troopsergeant/ship
	supervisors = "the IASF officer"
	entry_message_body = "You command the detachment in the field. Coordinate the team leaders and report to the officer. Your equipment is stored in your personal locker."

/obj/effect/landmark/start/marine/leader/rmc/iasf
	name = JOB_IASF_SERGEANT
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/leader/ai/rmc/iasf

/datum/job/marine/tl/ai/rmc2ic/iasf
	title = JOB_IASF_TEAM
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/iasf/leader/lesser/ship
	supervisors = "the IASF platoon sergeant"
	entry_message_body = "Lead your fire team under the platoon sergeant and take command of the team when needed."

/obj/effect/landmark/start/marine/tl/rmc2ic/iasf
	name = JOB_IASF_TEAM
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/tl/ai/rmc2ic/iasf

/obj/effect/landmark/start/marine/tl/rmc2ic/iasf/second

/datum/job/marine/standard/ai/rmc/iasf
	title = JOB_IASF_TROOPER
	gear_preset = /datum/equipment_preset/iasf/standard/ship
	supervisors = "the IASF team leader and platoon sergeant"
	entry_message_body = "You are an IASF trooper. Follow your team leader and platoon sergeant. Your uniform and personal equipment are in your locker."

/obj/effect/landmark/start/marine/rmc/iasf
	name = JOB_IASF_TROOPER
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/standard/ai/rmc/iasf

/datum/job/marine/medic/ai/rmc/iasf
	title = JOB_IASF_MEDIC
	gear_preset = /datum/equipment_preset/iasf/medic/ship
	supervisors = "the IASF team leader"
	entry_message_body = "Keep the detachment alive and follow your team leader's orders. Medical supplies are in the medical stores."

/obj/effect/landmark/start/marine/medic/rmc/iasf
	name = JOB_IASF_MEDIC
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/medic/ai/rmc/iasf

/datum/job/marine/smartgunner/ai/rmc/iasf
	title = JOB_IASF_GUNNER
	gear_preset = /datum/equipment_preset/iasf/machinegun/ship
	supervisors = "the IASF team leader"
	entry_message_body = "Provide heavy weapons support to your team and obey the team leader."

/obj/effect/landmark/start/marine/smartgunner/rmc/iasf
	name = JOB_IASF_GUNNER
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/smartgunner/ai/rmc/iasf

/datum/job/marine/specialist/ai/rmc/iasf
	title = JOB_IASF_SNIPER
	gear_preset = /datum/equipment_preset/iasf/sniper/light/ship
	supervisors = "the IASF team leader"
	entry_message_body = "Provide precision fire to your team with a scoped F903A1. Ammunition is available in the armory."

/obj/effect/landmark/start/marine/specialist/rmc/iasf
	name = JOB_IASF_SNIPER
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/specialist/ai/rmc/iasf

/datum/job/marine/engineer/ai/rmc/iasf
	title = JOB_IASF_BREACHER
	gear_preset = /datum/equipment_preset/iasf/breacher
	supervisors = "the IASF team leader"
	entry_message_body = "You are the team breacher. Carry your ballistic shield and shotgun and clear the entry on your team leader's order."

/obj/effect/landmark/start/marine/engineer/rmc/iasf
	name = JOB_IASF_BREACHER
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/engineer/ai/rmc/iasf

/datum/job/marine/engineer/ai/rmcmortar/iasf
	title = JOB_IASF_SUPPORT
	gear_preset = /datum/equipment_preset/iasf/engineer/ship
	supervisors = "the IASF platoon sergeant"
	entry_message_body = "Coordinate fire support with the platoon sergeant and support the teams."

/obj/effect/landmark/start/marine/engineer/rmcmortar/iasf
	name = JOB_IASF_SUPPORT
	squad = SQUAD_IASF_TURING
	job = /datum/job/marine/engineer/ai/rmcmortar/iasf
