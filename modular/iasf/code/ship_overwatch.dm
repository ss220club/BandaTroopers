/datum/authority/branch/role/get_default_role_title(job_title)
	switch(job_title)
		if(JOB_IASF_SERGEANT)
			return JOB_SQUAD_LEADER
		if(JOB_IASF_TEAM)
			return JOB_SQUAD_TEAM_LEADER
	return ..()

/obj/structure/machinery/computer/overwatch/iasf
	name = "Turing Watch Overwatch Console"
	faction = FACTION_IASF
	minimap_type = MINIMAP_FLAG_TWE
	req_access = list(ACCESS_TWE_LEADERSHIP)
