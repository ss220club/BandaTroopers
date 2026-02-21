
/datum/authority/branch/role/setup_candidates_and_roles(list/overwritten_roles_for_mode)
	. = ..()

	// Подсчитываем игроков
	var/players_ready = 0
	for(var/mob/new_player/player in GLOB.new_player_list)
		if(player.client && player.ready)
			players_ready++

	// Открываем сквад
	for(var/datum/squad/sq in GLOB.RoleAuthority.squads)
		if(!sq)
			continue
		if(sq.usable)
			continue
		if(!sq.ready_players_usable && !sq.platoon_associated_type) // Хотя бы один должен быть для продолжения
			continue
		if(sq.ready_players_usable && players_ready < sq.ready_players_usable)
			continue
		if(sq.platoon_associated_type)
			if(sq.platoon_associated_type != MAIN_SHIP_PLATOON) //!istype(MAIN_SHIP_PLATOON, sq.platoon_associated_type))
				continue
			associated_squad_job_positions(sq.platoon_associated_type)

		sq.usable = TRUE


/datum/authority/branch/role/proc/associated_squad_job_positions(platoon_associated_type)
	var/datum/squad/associated_squad = GLOB.RoleAuthority.squads_by_type[platoon_associated_type]
	for(var/role in GLOB.RoleAuthority.roles_by_path)
		var/datum/job/job = GLOB.RoleAuthority.roles_by_path[role]
		// var/datum/job/job_mapped = GET_MAPPED_ROLE(job_path)
		var/additional_positions = 0
		switch(job.title)
			if(JOB_SQUAD_MARINE)
				additional_positions = associated_squad.max_riflemen
			if(JOB_SQUAD_ENGI)
				additional_positions = associated_squad.max_engineers
			if(JOB_SQUAD_MEDIC)
				additional_positions = associated_squad.max_medics
			if(JOB_SQUAD_SPECIALIST)
				additional_positions = associated_squad.max_specialists
			if(JOB_SQUAD_SMARTGUN)
				additional_positions = associated_squad.max_smartgun
			if(JOB_SQUAD_LEADER)
				additional_positions = associated_squad.max_leaders
			if(JOB_SQUAD_TEAM_LEADER)
				additional_positions = associated_squad.max_tl
			if(JOB_SQUAD_RTO)
				additional_positions = associated_squad.max_rto
			if(JOB_SO)
				additional_positions = associated_squad.staff_per_squad
		job.total_positions += additional_positions
		job.spawn_positions += additional_positions

/datum/authority/branch/role/check_squad_capacity(mob/living/carbon/human/transfer_marine, datum/squad/new_squad)
	. = ..()
	if(transfer_marine.job == JOB_SQUAD_RTO)
		if(new_squad.num_rto >= new_squad.max_rto)
			return TRUE
	if(transfer_marine.job == JOB_SQUAD_MARINE)
		if(new_squad.num_riflemen >= new_squad.max_riflemen)
			return TRUE
