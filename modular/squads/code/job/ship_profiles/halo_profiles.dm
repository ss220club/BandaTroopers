/datum/modular_ship_platoon_profile/halo

/datum/modular_ship_platoon_profile/halo/unsc
	platoon_type = /datum/squad/marine/halo/unsc/alpha

/datum/modular_ship_platoon_profile/halo/unsc/initialize_profile()
	family_types = list(
		/datum/squad/marine/halo/unsc/alpha,
		/datum/squad/marine/halo/unsc/bravo,
		/datum/squad/marine/halo/unsc/charlie,
		/datum/squad/marine/halo/unsc/delta,
	)
	family_secondary_types = list(
		/datum/squad/marine/halo/unsc/bravo,
		/datum/squad/marine/halo/unsc/charlie,
		/datum/squad/marine/halo/unsc/delta,
	)
	role_mappings = list(
		/datum/job/command/bridge/ai/halo/unsc = JOB_SO,
		/datum/job/marine/standard/ai/halo/unsc = JOB_SQUAD_MARINE,
		/datum/job/marine/standard/ai/rto/halo/unsc = JOB_SQUAD_RTO,
		/datum/job/marine/medic/ai/halo/unsc = JOB_SQUAD_MEDIC,
		/datum/job/marine/tl/ai/halo/unsc = JOB_SQUAD_TEAM_LEADER,
		/datum/job/marine/leader/ai/halo/unsc = JOB_SQUAD_LEADER,
		/datum/job/marine/specialist/ai/halo/unsc = JOB_SQUAD_SPECIALIST,
	)
	distress_roles = JOB_HALO_UNSC_SHIPSIDE_LIST + GLOB.ROLES_GROUND
	lowpop_roles = list(JOB_SO_UNSC) + JOB_HALO_UNSC_MARINES_LIST
	lowpop_personal_weapon_options = get_default_personal_weapon_options()
	lowpop_personal_weapon_spawn_types = list(
		"Shotgun" = /obj/effect/essentials_set/m90caws,
		"Compact shotgun" = /obj/effect/essentials_set/m90caws,
		"Double-barrel shotgun" = /obj/effect/essentials_set/m90caws,
		"Grenade launcher" = /obj/effect/essentials_set/ma5_launcher,
		"Compact grenade launcher" = /obj/effect/essentials_set/ma5_launcher,
		"Grenade pack" = /obj/effect/essentials_set/m9_frag_4_pack,
	)
	lowpop_personal_weapon_legacy_aliases = get_default_personal_weapon_legacy_aliases()
	lowpop_personal_weapon_default = "Shotgun"
	lowpop_personal_weapon_label = "Rifleman Support Weapon"
	lowpop_personal_weapon_prompt = "Choose your character's support weapon:"
	lowpop_personal_weapon_title = "Character Preference (HALO Only)"
	lowpop_personal_weapon_notice_text = "You remember that your requisition for a <b>%weapon%</b> was approved. It's in your personal locker."
	lowpop_personal_weapon_roles = list(JOB_SQUAD_MARINE)
	lowpop_personal_weapon_required_faction = FACTION_UNSC
	lowpop_personal_weapon_case_type = /obj/item/storage/box/personalcase/unsc
	preview_presets = list(
		JOB_SO = /datum/equipment_preset/unsc/platco/equipped,
		JOB_SQUAD_MARINE = /datum/equipment_preset/unsc/pfc/equipped,
		JOB_SQUAD_MEDIC = /datum/equipment_preset/unsc/medic/equipped,
		JOB_SQUAD_RTO = /datum/equipment_preset/unsc/rto/equipped,
		JOB_SQUAD_TEAM_LEADER = /datum/equipment_preset/unsc/tl/equipped,
		JOB_SQUAD_LEADER = /datum/equipment_preset/unsc/leader/equipped,
		JOB_SQUAD_SPECIALIST = /datum/equipment_preset/unsc/spec/equipped_spnkr,
	)
	spawn_preset_overrides = list(
		JOB_SQUAD_MARINE = list(
			/datum/equipment_preset/uscm/pfc = /datum/equipment_preset/unsc/pfc,
			/datum/equipment_preset/uscm/pfc/private = /datum/equipment_preset/unsc/pfc/lesser_rank,
			/datum/equipment_preset/uscm/pfc/lance_corporal = /datum/equipment_preset/unsc/pfc,
		),
		JOB_SQUAD_RTO = list(
			/datum/equipment_preset/uscm/rto = /datum/equipment_preset/unsc/rto,
			/datum/equipment_preset/uscm/rto/lance_corporal = /datum/equipment_preset/unsc/rto/lesser_rank,
			/datum/equipment_preset/uscm/rto/pfc = /datum/equipment_preset/unsc/rto/lesser_rank,
		),
		JOB_SQUAD_MEDIC = list(
			/datum/equipment_preset/uscm/medic = /datum/equipment_preset/unsc/medic,
			/datum/equipment_preset/uscm/medic/lance_corporal = /datum/equipment_preset/unsc/medic/lesser_rank,
			/datum/equipment_preset/uscm/medic/pfc = /datum/equipment_preset/unsc/medic/pfc,
			/datum/equipment_preset/uscm/medic/private = /datum/equipment_preset/unsc/medic/private,
		),
		JOB_SQUAD_TEAM_LEADER = list(
			/datum/equipment_preset/uscm/tl = /datum/equipment_preset/unsc/tl,
			/datum/equipment_preset/uscm/tl/corporal = /datum/equipment_preset/unsc/tl/lesser_rank,
		),
		JOB_SQUAD_LEADER = list(
			/datum/equipment_preset/uscm/leader = /datum/equipment_preset/unsc/leader,
			/datum/equipment_preset/uscm/leader/staff_sergeant = /datum/equipment_preset/unsc/leader/lesser_rank,
		),
		JOB_SQUAD_SPECIALIST = list(
			/datum/equipment_preset/uscm/specialist_equipped = /datum/equipment_preset/unsc/spec,
		),
		JOB_SO = list(
			/datum/equipment_preset/uscm_ship/so = /datum/equipment_preset/unsc/platco,
			/datum/equipment_preset/uscm_ship/so/lesser_rank = /datum/equipment_preset/unsc/platco/lesser_rank,
		),
	)
	cryo_reinforcement_titles = list(
		JOB_SO = JOB_SO_UNSC,
		JOB_SQUAD_MARINE = JOB_SQUAD_MARINE_UNSC,
		JOB_SQUAD_MEDIC = JOB_SQUAD_MEDIC_UNSC,
		JOB_SQUAD_RTO = JOB_SQUAD_RTO_UNSC,
		JOB_SQUAD_TEAM_LEADER = JOB_SQUAD_TEAM_LEADER_UNSC,
		JOB_SQUAD_LEADER = JOB_SQUAD_LEADER_UNSC,
		JOB_SQUAD_SPECIALIST = JOB_SQUAD_SPECIALIST_UNSC,
	)
	cryo_reinforcement_presets = list(
		JOB_SO = /datum/equipment_preset/unsc/platco,
		JOB_SQUAD_MARINE = /datum/equipment_preset/unsc/pfc,
		JOB_SQUAD_MEDIC = /datum/equipment_preset/unsc/medic,
		JOB_SQUAD_RTO = /datum/equipment_preset/unsc/rto,
		JOB_SQUAD_TEAM_LEADER = /datum/equipment_preset/unsc/tl,
		JOB_SQUAD_LEADER = /datum/equipment_preset/unsc/leader,
		JOB_SQUAD_SPECIALIST = /datum/equipment_preset/unsc/spec,
	)
	platoon_label = "UNSC - Marine Troopers \"War Hogs\""
	manifest_picture = /atom/movable/screen/text/screen_text/picture/starting/unsc
	intro_picture = /atom/movable/screen/text/screen_text/picture/dark_was_the_night

/datum/modular_ship_platoon_profile/halo/odst
	platoon_type = /datum/squad/marine/halo/odst/alpha

/datum/modular_ship_platoon_profile/halo/odst/initialize_profile()
	family_types = list(
		/datum/squad/marine/halo/odst/alpha,
		/datum/squad/marine/halo/odst/bravo,
		/datum/squad/marine/halo/odst/charlie,
		/datum/squad/marine/halo/odst/delta,
	)
	family_secondary_types = list(
		/datum/squad/marine/halo/odst/bravo,
		/datum/squad/marine/halo/odst/charlie,
		/datum/squad/marine/halo/odst/delta,
	)
	role_mappings = list(
		/datum/job/command/bridge/ai/halo/odst = JOB_SO,
		/datum/job/marine/standard/ai/halo/odst = JOB_SQUAD_MARINE,
		/datum/job/marine/standard/ai/rto/halo/odst = JOB_SQUAD_RTO,
		/datum/job/marine/medic/ai/halo/odst = JOB_SQUAD_MEDIC,
		/datum/job/marine/tl/ai/halo/odst = JOB_SQUAD_TEAM_LEADER,
		/datum/job/marine/leader/ai/halo/odst = JOB_SQUAD_LEADER,
		/datum/job/marine/specialist/ai/halo/odst = JOB_SQUAD_SPECIALIST,
	)
	distress_roles = JOB_HALO_ODST_SHIPSIDE_LIST + GLOB.ROLES_GROUND
	lowpop_roles = list(JOB_SO_ODST) + JOB_HALO_ODST_MARINES_LIST
	lowpop_personal_weapon_options = get_default_personal_weapon_options()
	lowpop_personal_weapon_spawn_types = list(
		"Shotgun" = /obj/effect/essentials_set/m90caws,
		"Compact shotgun" = /obj/effect/essentials_set/m90caws,
		"Double-barrel shotgun" = /obj/effect/essentials_set/m90caws,
		"Grenade launcher" = /obj/effect/essentials_set/ma5_launcher,
		"Compact grenade launcher" = /obj/effect/essentials_set/ma5_launcher,
		"Grenade pack" = /obj/effect/essentials_set/m9_frag_4_pack,
	)
	lowpop_personal_weapon_legacy_aliases = get_default_personal_weapon_legacy_aliases()
	lowpop_personal_weapon_default = "Shotgun"
	lowpop_personal_weapon_label = "Rifleman Support Weapon"
	lowpop_personal_weapon_prompt = "Choose your character's support weapon:"
	lowpop_personal_weapon_title = "Character Preference (HALO Only)"
	lowpop_personal_weapon_notice_text = "You remember that your requisition for a <b>%weapon%</b> was approved. It's in your personal locker."
	lowpop_personal_weapon_roles = list(JOB_SQUAD_MARINE)
	lowpop_personal_weapon_required_faction = FACTION_UNSC
	lowpop_personal_weapon_case_type = /obj/item/storage/box/personalcase/unsc
	preview_presets = list(
		JOB_SO = /datum/equipment_preset/unsc/platco/odst/equipped,
		JOB_SQUAD_MARINE = /datum/equipment_preset/unsc/pfc/odst/equipped,
		JOB_SQUAD_MEDIC = /datum/equipment_preset/unsc/medic/odst/equipped,
		JOB_SQUAD_RTO = /datum/equipment_preset/unsc/rto/odst/equipped,
		JOB_SQUAD_TEAM_LEADER = /datum/equipment_preset/unsc/tl/odst/equipped,
		JOB_SQUAD_LEADER = /datum/equipment_preset/unsc/leader/odst/equipped,
		JOB_SQUAD_SPECIALIST = /datum/equipment_preset/unsc/spec/odst/equipped_spnkr,
	)
	spawn_preset_overrides = list(
		JOB_SQUAD_MARINE = list(
			/datum/equipment_preset/uscm/pfc = /datum/equipment_preset/unsc/pfc/odst,
			/datum/equipment_preset/uscm/pfc/private = /datum/equipment_preset/unsc/pfc/odst/lesser_rank,
			/datum/equipment_preset/uscm/pfc/lance_corporal = /datum/equipment_preset/unsc/pfc/odst,
		),
		JOB_SQUAD_RTO = list(
			/datum/equipment_preset/uscm/rto = /datum/equipment_preset/unsc/rto/odst,
			/datum/equipment_preset/uscm/rto/lance_corporal = /datum/equipment_preset/unsc/rto/odst/lesser_rank,
			/datum/equipment_preset/uscm/rto/pfc = /datum/equipment_preset/unsc/rto/odst/lesser_rank,
		),
		JOB_SQUAD_MEDIC = list(
			/datum/equipment_preset/uscm/medic = /datum/equipment_preset/unsc/medic/odst,
			/datum/equipment_preset/uscm/medic/lance_corporal = /datum/equipment_preset/unsc/medic/odst/lesser_rank,
			/datum/equipment_preset/uscm/medic/pfc = /datum/equipment_preset/unsc/medic/odst/pfc,
			/datum/equipment_preset/uscm/medic/private = /datum/equipment_preset/unsc/medic/odst/private,
		),
		JOB_SQUAD_TEAM_LEADER = list(
			/datum/equipment_preset/uscm/tl = /datum/equipment_preset/unsc/tl/odst,
			/datum/equipment_preset/uscm/tl/corporal = /datum/equipment_preset/unsc/tl/odst/lesser_rank,
		),
		JOB_SQUAD_LEADER = list(
			/datum/equipment_preset/uscm/leader = /datum/equipment_preset/unsc/leader/odst,
			/datum/equipment_preset/uscm/leader/staff_sergeant = /datum/equipment_preset/unsc/leader/odst/lesser_rank,
		),
		JOB_SQUAD_SPECIALIST = list(
			/datum/equipment_preset/uscm/specialist_equipped = /datum/equipment_preset/unsc/spec/odst,
		),
		JOB_SO = list(
			/datum/equipment_preset/uscm_ship/so = /datum/equipment_preset/unsc/platco/odst,
			/datum/equipment_preset/uscm_ship/so/lesser_rank = /datum/equipment_preset/unsc/platco/odst/lesser_rank,
		),
	)
	cryo_reinforcement_titles = list(
		JOB_SO = JOB_SO_ODST,
		JOB_SQUAD_MARINE = JOB_SQUAD_MARINE_ODST,
		JOB_SQUAD_MEDIC = JOB_SQUAD_MEDIC_ODST,
		JOB_SQUAD_RTO = JOB_SQUAD_RTO_ODST,
		JOB_SQUAD_TEAM_LEADER = JOB_SQUAD_TEAM_LEADER_ODST,
		JOB_SQUAD_LEADER = JOB_SQUAD_LEADER_ODST,
		JOB_SQUAD_SPECIALIST = JOB_SQUAD_SPECIALIST_ODST,
	)
	cryo_reinforcement_presets = list(
		JOB_SO = /datum/equipment_preset/unsc/platco/odst,
		JOB_SQUAD_MARINE = /datum/equipment_preset/unsc/pfc/odst,
		JOB_SQUAD_MEDIC = /datum/equipment_preset/unsc/medic/odst,
		JOB_SQUAD_RTO = /datum/equipment_preset/unsc/rto/odst,
		JOB_SQUAD_TEAM_LEADER = /datum/equipment_preset/unsc/tl/odst,
		JOB_SQUAD_LEADER = /datum/equipment_preset/unsc/leader/odst,
		JOB_SQUAD_SPECIALIST = /datum/equipment_preset/unsc/spec/odst,
	)
	platoon_label = "ODST - 7th Shock Troops Battalion. \"War Cogs\""
	manifest_picture = /atom/movable/screen/text/screen_text/picture/starting/odst
	intro_picture = /atom/movable/screen/text/screen_text/picture/dark_was_the_night

/datum/authority/branch/role/proc/get_halo_ship_platoon_profile_type(platoon_type)
	platoon_type = normalize_ship_platoon_type(platoon_type)
	switch(platoon_type)
		if(/datum/squad/marine/halo/unsc/alpha)
			return /datum/modular_ship_platoon_profile/halo/unsc
		if(/datum/squad/marine/halo/odst/alpha)
			return /datum/modular_ship_platoon_profile/halo/odst

	return null

/datum/authority/branch/role/proc/get_halo_ship_platoon_profile_datum(platoon_type)
	var/profile_type = get_halo_ship_platoon_profile_type(platoon_type)
	if(!profile_type)
		return null

	return new profile_type

/datum/authority/branch/role/proc/get_halo_platoon_type_for_job(job_title)
	if(job_title in JOB_HALO_UNSC_SHIPSIDE_LIST)
		return /datum/squad/marine/halo/unsc/alpha
	if(job_title in JOB_HALO_ODST_SHIPSIDE_LIST)
		return /datum/squad/marine/halo/odst/alpha

	return null

/datum/authority/branch/role/proc/get_halo_main_ship_profile(platoon_type = MAIN_SHIP_PLATOON)
	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.build_profile()
