/datum/game_mode/colonialmarines/ai
	name = "Distress Signal: Lowpop"
	config_tag = "Distress Signal: Lowpop"
	required_players = 0
	votable = TRUE

	flags_round_type = MODE_INFESTATION|MODE_NEW_SPAWN|MODE_NO_XENO_EVOLVE

	var/list/squad_limit = list(
		/datum/squad/marine/alpha
	)

	var/list/objectives = list()
	var/initial_objectives = 0

	var/game_started = FALSE

	role_mappings = list(
		/datum/job/command/bridge/ai = JOB_SO,
		/datum/job/marine/leader/ai = JOB_SQUAD_LEADER,
		/datum/job/marine/medic/ai = JOB_SQUAD_MEDIC,
		/datum/job/marine/tl/ai = JOB_SQUAD_TEAM_LEADER,
		/datum/job/marine/smartgunner/ai = JOB_SQUAD_SMARTGUN,
		/datum/job/marine/standard/ai = JOB_SQUAD_MARINE,
	)

	static_comms_amount = 0
	requires_comms = FALSE
	toggleable_flags = MODE_NO_JOIN_AS_XENO|MODE_HARDCORE_PERMA|MODE_DISABLE_FS_PORTRAIT

/datum/game_mode/colonialmarines/ai/can_start()
	return ..()

/datum/game_mode/colonialmarines/ai/pre_setup()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, PROC_REF(handle_xeno_spawn))
	var/datum/authority/branch/role/role_authority = GLOB.RoleAuthority
	if(role_authority) // SS220 EDIT: lowpop ship-side roster and squad family are selected through modular platoon helpers
		squad_limit = role_authority.get_main_ship_lowpop_keep_types()
		role_mappings = role_authority.get_main_ship_role_mappings(TRUE)
		role_authority.handle_main_ship_mode_changed()
		role_authority.reset_roles()
		role_authority.filter_role_authority_squads_to_types(squad_limit) // SS220 EDIT: trim active squad pool to the current ship-mode family
	else
		squad_limit = list(MAIN_SHIP_PLATOON || text2path(MAIN_SHIP_DEFAULT_PLATOON))
	var/datum/squad/main_squad
	if(role_authority) // SS220 EDIT: lowpop main platoon follows active ship-profile resolver when RoleAuthority is available
		var/active_ship_platoon = role_authority.get_active_ship_platoon_type()
		main_squad = role_authority.squads_by_type[active_ship_platoon]
	if(main_squad)
		GLOB.main_platoon_name = main_squad.name
		GLOB.main_platoon_initial_name = main_squad.name

	. = ..()

/datum/game_mode/colonialmarines/ai/post_setup()
	set_lz_resin_allowed(TRUE)
	spawn_personal_weapon()
	return ..()

/datum/game_mode/colonialmarines/ai/announce_bioscans()
	return

/datum/game_mode/colonialmarines/ai/end_round_message()
	return ..()

/datum/game_mode/colonialmarines/ai/proc/handle_xeno_spawn(datum/source, mob/living/carbon/xenomorph/spawning_xeno, ai_hard_off = FALSE)
	SIGNAL_HANDLER
	if(ai_hard_off)
		return

	spawning_xeno.make_ai()

/datum/game_mode/colonialmarines/ai/check_win()
	if(!game_started || round_finished || SSticker.current_state != GAME_STATE_PLAYING)
		return

/datum/game_mode/colonialmarines/ai/get_roles_list()
	// return GLOB.platoon_to_role_list[MAIN_SHIP_PLATOON]
	return GLOB.RoleAuthority?.get_main_ship_lowpop_roles() || GLOB.platoon_to_role_list[MAIN_SHIP_PLATOON] // SS220 EDIT: ship-side lowpop roster resolves through modular platoon helpers when RoleAuthority is available

/datum/game_mode/colonialmarines/ai/check_queen_status()
	return

GLOBAL_LIST_INIT(platoon_to_jobs, list(/datum/squad/marine/alpha = list(/datum/job/command/bridge/ai = JOB_SO,\
		/datum/job/marine/leader/ai = JOB_SQUAD_LEADER,\
		/datum/job/marine/medic/ai = JOB_SQUAD_MEDIC,\
		/datum/job/marine/tl/ai = JOB_SQUAD_TEAM_LEADER,\
		/datum/job/marine/smartgunner/ai = JOB_SQUAD_SMARTGUN,\
		/datum/job/marine/standard/ai = JOB_SQUAD_MARINE),\
		/datum/squad/marine/upp = list(/datum/job/command/bridge/ai/upp = JOB_SO,\
		/datum/job/marine/leader/ai/upp = JOB_SQUAD_LEADER,\
		/datum/job/marine/medic/ai/upp = JOB_SQUAD_MEDIC,\
		/datum/job/marine/tl/ai/upp = JOB_SQUAD_TEAM_LEADER,\
		/datum/job/marine/smartgunner/ai/upp = JOB_SQUAD_SMARTGUN,\
		/datum/job/marine/standard/ai/upp = JOB_SQUAD_MARINE),\
		/datum/squad/marine/pmc = list(/datum/job/marine/tl/ai/pmc = JOB_SQUAD_TEAM_LEADER,\
		/datum/job/marine/standard/ai/pmc =  JOB_SQUAD_MARINE,\
		/datum/job/marine/medic/ai/pmc = JOB_SQUAD_MEDIC,\
		/datum/job/marine/smartgunner/ai/pmc = JOB_SQUAD_SMARTGUN,\
		/datum/job/marine/leader/ai/pmc = JOB_SQUAD_LEADER,\
		/datum/job/command/bridge/ai/pmc = JOB_PMCPLAT_OW),\
		/datum/squad/marine/forecon = list(/datum/job/marine/standard/ai/forecon = JOB_SQUAD_MARINE,\
		/datum/job/marine/standard/ai/rto = JOB_SQUAD_RTO,\
		/datum/job/marine/leader/ai/forecon = JOB_SQUAD_LEADER,\
		/datum/job/marine/medic/ai/forecon = JOB_SQUAD_MEDIC,\
		/datum/job/marine/tl/ai/forecon = JOB_SQUAD_TEAM_LEADER,\
		/datum/job/marine/smartgunner/ai/forecon = JOB_SQUAD_SMARTGUN),\
		/datum/squad/marine/pmc/small = list(/datum/job/marine/tl/ai/pmc/small = JOB_SQUAD_TEAM_LEADER,\
		/datum/job/marine/standard/ai/pmc/small =  JOB_SQUAD_MARINE,\
		/datum/job/marine/medic/ai/pmc/small = JOB_SQUAD_MEDIC,\
		/datum/job/marine/smartgunner/ai/pmc/small = JOB_SQUAD_SMARTGUN,\
		/datum/job/marine/leader/ai/pmc/small = JOB_SQUAD_LEADER),\
		/datum/squad/marine/rmc = list(/datum/job/command/bridge/ai/rmc = JOB_TWE_RMC_LIEUTENANT,\
		/datum/job/marine/leader/ai/rmc = JOB_TWE_RMC_TROOPLEADER,\
		/datum/job/marine/tl/ai/rmc = JOB_TWE_RMC_SECTIONLEADER,\
		/datum/job/marine/tl/ai/rmc2ic = JOB_TWE_RMC_TEAMLEADER,\
		/datum/job/marine/smartgunner/ai/rmc = JOB_TWE_RMC_SMARTGUNNER,\
		/datum/job/marine/medic/ai/rmc = JOB_TWE_RMC_MEDIC,\
		/datum/job/marine/engineer/ai/rmc = JOB_TWE_RMC_ENGI,\
		/datum/job/marine/engineer/ai/rmcmortar = JOB_TWE_RMC_BREACHER,\
		/datum/job/marine/specialist/ai/rmc = JOB_TWE_RMC_MARKSMAN,\
		/datum/job/marine/standard/ai/rmc = JOB_TWE_RMC_RIFLEMAN)))

GLOBAL_LIST_INIT(platoon_to_role_list, list(/datum/squad/marine/alpha = ROLES_AI,\
												/datum/squad/marine/upp = ROLES_AI_UPP,\
												/datum/squad/marine/pmc = ROLES_PMCPLT,\
												/datum/squad/marine/forecon = ROLES_AI_FORECON,\
												/datum/squad/marine/pmc/small = ROLES_PMCPLT_SMALL,\
												/datum/squad/marine/rmc = ROLES_RMCTROOP))


GLOBAL_LIST_INIT(personal_weapons_list, list("Ithaca 37 shotgun-stakeout" = /obj/item/storage/large_holster/m37/full/noammo,\
											"Ithaca 37 shotgun-traditional" = /obj/item/weapon/gun/shotgun/pump/stock,\
											"Sawn-off double barrel shotgun" = /obj/item/weapon/gun/shotgun/double/sawn,\
											"M79 grenade launcher" = /obj/item/weapon/gun/launcher/grenade/m81/m79/modified,\
											"Cut down M79 grenade launcher" = /obj/item/weapon/gun/launcher/grenade/m81/m79/modified/sawnoff,\
											"4 M15 grenades" = /obj/effect/essentials_set/m15_4_pack))

/datum/game_mode/colonialmarines/ai/proc/spawn_personal_weapon()
	var/datum/squad/squad = locate() in GLOB.RoleAuthority.squads
	if(!squad || squad.faction != FACTION_MARINE || !squad.marines_list.len > 0)
		return
	if(!GLOB.personal_weapon.len)
		return
	var/mob/living/carbon/human/marine
	var/chosen_weapon
	var/iteration = 0 //10 marines with no personal weapon selected? its more likely than you think!
	var/list/temporary_list = squad.marines_list
	while(!chosen_weapon && iteration < squad.marines_list.len)
		iteration++
		marine = pick(temporary_list)
		if(!squad.marines_list.Find(marine))
			chosen_weapon = "bugged"
			break
		if(marine.job == JOB_SO) //get outta here butter bars
			temporary_list.Remove(marine)
			continue
		if(!marine.client)
			temporary_list.Remove(marine)
			continue
		if(marine.client.prefs.personal_weapon == "None")
			temporary_list.Remove(marine)
			continue
		chosen_weapon = marine.client.prefs.personal_weapon
	if(!isnull(chosen_weapon)) //Probably highly unlikely that all marines have it set to None but uhhhhh you never know.
		if(chosen_weapon == "bugged")
			log_debug("Chosen Weapon selected a bugged marine.")
		else
			var/obj/item/storage/box/personalcase/pcase = new(get_turf(pick(GLOB.personal_weapon)))
			pcase.assign_owner(marine.real_name)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), marine, SPAN_NOTICE("You remember that you've successfully snuck in your <b>heirloom weapon</b> aboard: <b>[marine.client.prefs.personal_weapon]</b>. It's in the armory")), 5 SECONDS)
			var/the_gun = GLOB.personal_weapons_list[chosen_weapon]
			new the_gun(pcase)
			for(var/obj/effect/landmark/personal_weapon/PW in GLOB.personal_weapon)
				qdel(PW)
	temporary_list = null
