/datum/job/marine/standard/ai/halo/unsc
	title = JOB_SQUAD_MARINE_UNSC
	total_positions = 4
	spawn_positions = 4
	gear_preset = /datum/equipment_preset/unsc/pfc
	gear_preset_secondary = /datum/equipment_preset/unsc/pfc/lesser_rank
	job_options = list("Private First Class" = "PFC", "Private" = "PVT")

/datum/job/marine/standard/ai/rto/halo/unsc
	title = JOB_SQUAD_RTO_UNSC
	gear_preset = /datum/equipment_preset/unsc/rto
	gear_preset_secondary = /datum/equipment_preset/unsc/rto/lesser_rank
	job_options = list("Private First Class" = "PFC", "Lance Corporal" = "LCPL")

/datum/job/marine/medic/ai/halo/unsc
	title = JOB_SQUAD_MEDIC_UNSC
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/medic
	gear_preset_secondary = /datum/equipment_preset/unsc/medic/lesser_rank

/datum/job/marine/tl/ai/halo/unsc
	title = JOB_SQUAD_TEAM_LEADER_UNSC
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/tl
	gear_preset_secondary = /datum/equipment_preset/unsc/tl/lesser_rank

/datum/job/marine/leader/ai/halo/unsc
	title = JOB_SQUAD_LEADER_UNSC
	gear_preset = /datum/equipment_preset/unsc/leader
	gear_preset_secondary = /datum/equipment_preset/unsc/leader/lesser_rank

/datum/job/marine/specialist/ai/halo/unsc
	title = JOB_SQUAD_SPECIALIST_UNSC
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/unsc/spec
	gear_preset_secondary = /datum/equipment_preset/unsc/spec/lesser_rank

/datum/job/marine/standard/ai/halo/odst
	title = JOB_SQUAD_MARINE_ODST
	gear_preset = /datum/equipment_preset/unsc/pfc/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/pfc/odst/lesser_rank
	job_options = list(PFC_VARIANT = "LCPL", PVT_VARIANT = "PFC")

/datum/job/marine/standard/ai/rto/halo/odst
	title = JOB_SQUAD_RTO_ODST
	gear_preset = /datum/equipment_preset/unsc/rto/odst
	gear_preset_secondary = /datum/equipment_preset/unsc/rto/odst/lesser_rank
	job_options = list(PFC_VARIANT = "PFC", LCPL_VARIANT = "LCPL")

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

/datum/authority/branch/role/New()
	. = ..()
	prefer_role_title_path(JOB_SQUAD_MARINE_UNSC, /datum/job/marine/standard/ai/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_RTO_UNSC, /datum/job/marine/standard/ai/rto/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_MEDIC_UNSC, /datum/job/marine/medic/ai/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_TEAM_LEADER_UNSC, /datum/job/marine/tl/ai/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_LEADER_UNSC, /datum/job/marine/leader/ai/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_SPECIALIST_UNSC, /datum/job/marine/specialist/ai/halo/unsc)
	prefer_role_title_path(JOB_SQUAD_MARINE_ODST, /datum/job/marine/standard/ai/halo/odst)
	prefer_role_title_path(JOB_SQUAD_RTO_ODST, /datum/job/marine/standard/ai/rto/halo/odst)
	prefer_role_title_path(JOB_SQUAD_MEDIC_ODST, /datum/job/marine/medic/ai/halo/odst)
	prefer_role_title_path(JOB_SQUAD_TEAM_LEADER_ODST, /datum/job/marine/tl/ai/halo/odst)
	prefer_role_title_path(JOB_SQUAD_LEADER_ODST, /datum/job/marine/leader/ai/halo/odst)
	prefer_role_title_path(JOB_SQUAD_SPECIALIST_ODST, /datum/job/marine/specialist/ai/halo/odst)

/datum/authority/branch/role/proc/prefer_role_title_path(role_title, role_path)
	if(!role_title || !role_path || !islist(roles_by_path) || !islist(roles_by_name))
		return

	var/datum/job/preferred_role = roles_by_path[role_path]
	if(preferred_role)
		roles_by_name[role_title] = preferred_role

/datum/squad/marine/halo/unsc/alpha
	parent_type = /datum/squad/marine/alpha
	faction = FACTION_UNSC
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/unsc/bravo
	parent_type = /datum/squad/marine/bravo
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 12
	platoon_associated_type = /datum/squad/marine/halo/unsc/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/unsc/charlie
	parent_type = /datum/squad/marine/charlie
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 24
	platoon_associated_type = /datum/squad/marine/halo/unsc/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/unsc/delta
	parent_type = /datum/squad/marine/delta
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 36
	platoon_associated_type = /datum/squad/marine/halo/unsc/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/odst/alpha
	parent_type = /datum/squad/marine/alpha
	faction = FACTION_UNSC
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/odst/bravo
	parent_type = /datum/squad/marine/bravo
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 12
	platoon_associated_type = /datum/squad/marine/halo/odst/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/odst/charlie
	parent_type = /datum/squad/marine/charlie
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 24
	platoon_associated_type = /datum/squad/marine/halo/odst/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/halo/odst/delta
	parent_type = /datum/squad/marine/delta
	faction = FACTION_UNSC
	active = TRUE
	roundstart = TRUE
	usable = FALSE
	squad_type = "Section"
	ready_players_usable = 36
	platoon_associated_type = /datum/squad/marine/halo/odst/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 2
	max_specialists = 2
	max_tl = 2
	max_smartgun = 0
	max_leaders = 1
	max_rto = 1

/datum/authority/branch/role/proc/get_modular_job_pref_to_gear_preset(job_title)
	switch(job_title)
		if(JOB_SQUAD_MARINE_ODST, JOB_SQUAD_LEADER_ODST, JOB_SQUAD_MEDIC_ODST, JOB_SQUAD_SPECIALIST_ODST, JOB_SQUAD_TEAM_LEADER_ODST, JOB_SQUAD_RTO_ODST)
			return /datum/equipment_preset/unsc/pfc/odst/equipped
		if(JOB_SQUAD_MARINE_UNSC)
			return /datum/equipment_preset/unsc/pfc/equipped
		if(JOB_SQUAD_LEADER_UNSC)
			return /datum/equipment_preset/unsc/leader/equipped
		if(JOB_SQUAD_MEDIC_UNSC)
			return /datum/equipment_preset/unsc/medic/equipped
		if(JOB_SQUAD_SPECIALIST_UNSC)
			return /datum/equipment_preset/unsc/spec/equipped_spnkr
		if(JOB_SQUAD_TEAM_LEADER_UNSC)
			return /datum/equipment_preset/unsc/tl/equipped
		if(JOB_SQUAD_RTO_UNSC)
			return /datum/equipment_preset/unsc/rto/equipped
	return null

/datum/authority/branch/role/proc/get_halo_main_ship_profile(platoon_type = MAIN_SHIP_PLATOON)
	switch(platoon_type)
		if(/datum/squad/marine/halo/unsc/alpha)
			return list(
				"family_types" = list(
					/datum/squad/marine/halo/unsc/alpha,
					/datum/squad/marine/halo/unsc/bravo,
					/datum/squad/marine/halo/unsc/charlie,
					/datum/squad/marine/halo/unsc/delta,
				),
				"family_secondary_types" = list(
					/datum/squad/marine/halo/unsc/bravo,
					/datum/squad/marine/halo/unsc/charlie,
					/datum/squad/marine/halo/unsc/delta,
				),
				"role_mappings" = list(
					/datum/job/marine/standard/ai/halo/unsc = JOB_SQUAD_MARINE,
					/datum/job/marine/standard/ai/rto/halo/unsc = JOB_SQUAD_RTO,
					/datum/job/marine/medic/ai/halo/unsc = JOB_SQUAD_MEDIC,
					/datum/job/marine/tl/ai/halo/unsc = JOB_SQUAD_TEAM_LEADER,
					/datum/job/marine/leader/ai/halo/unsc = JOB_SQUAD_LEADER,
					/datum/job/marine/specialist/ai/halo/unsc = JOB_SQUAD_SPECIALIST,
				),
				"distress_roles" = GLOB.ROLES_CIC + GLOB.ROLES_POLICE + GLOB.ROLES_AUXIL_SUPPORT + GLOB.ROLES_MISC + GLOB.ROLES_ENGINEERING + GLOB.ROLES_REQUISITION + GLOB.ROLES_MEDICAL + JOB_HALO_UNSC_MARINES_LIST + GLOB.ROLES_GROUND,
				"lowpop_roles" = list(JOB_SO) + JOB_HALO_UNSC_MARINES_LIST,
				"platoon_label" = "UNSC - Marine Troopers \"War Hogs\"",
				"manifest_picture" = /atom/movable/screen/text/screen_text/picture/starting/unsc,
				"intro_picture" = /atom/movable/screen/text/screen_text/picture/dark_was_the_night,
			)
		if(/datum/squad/marine/halo/odst/alpha)
			return list(
				"family_types" = list(
					/datum/squad/marine/halo/odst/alpha,
					/datum/squad/marine/halo/odst/bravo,
					/datum/squad/marine/halo/odst/charlie,
					/datum/squad/marine/halo/odst/delta,
				),
				"family_secondary_types" = list(
					/datum/squad/marine/halo/odst/bravo,
					/datum/squad/marine/halo/odst/charlie,
					/datum/squad/marine/halo/odst/delta,
				),
				"role_mappings" = list(
					/datum/job/marine/standard/ai/halo/odst = JOB_SQUAD_MARINE,
					/datum/job/marine/standard/ai/rto/halo/odst = JOB_SQUAD_RTO,
					/datum/job/marine/medic/ai/halo/odst = JOB_SQUAD_MEDIC,
					/datum/job/marine/tl/ai/halo/odst = JOB_SQUAD_TEAM_LEADER,
					/datum/job/marine/leader/ai/halo/odst = JOB_SQUAD_LEADER,
					/datum/job/marine/specialist/ai/halo/odst = JOB_SQUAD_SPECIALIST,
				),
				"distress_roles" = GLOB.ROLES_CIC + GLOB.ROLES_POLICE + GLOB.ROLES_AUXIL_SUPPORT + GLOB.ROLES_MISC + GLOB.ROLES_ENGINEERING + GLOB.ROLES_REQUISITION + GLOB.ROLES_MEDICAL + JOB_HALO_ODST_MARINES_LIST + GLOB.ROLES_GROUND,
				"lowpop_roles" = list(JOB_SO) + JOB_HALO_ODST_MARINES_LIST,
				"platoon_label" = "ODST - 7th Shock Troops Battalion. \"War Cogs\"",
				"manifest_picture" = /atom/movable/screen/text/screen_text/picture/starting/odst,
				"intro_picture" = /atom/movable/screen/text/screen_text/picture/dark_was_the_night,
			)
	return null
