// Raw setup primitives

/datum/human_tied_controller/proc/set_species(new_species)
	if(!can_setup_puppet() || !new_species)
		return FALSE
	tied_human.set_species(new_species)
	return TRUE

/datum/human_tied_controller/proc/set_skills(skill_type)
	if(!can_setup_puppet() || !skill_type)
		return FALSE
	tied_human.set_skills(skill_type)
	return TRUE

/datum/human_tied_controller/proc/strip_weapons()
	if(!can_setup_puppet())
		return FALSE
	tied_human.strip_weapons()
	return TRUE

/datum/human_tied_controller/proc/strip_all()
	if(!can_setup_puppet())
		return FALSE
	tied_human.strip_all()
	return TRUE

/datum/human_tied_controller/proc/paradrop()
	if(!can_setup_puppet())
		return FALSE
	tied_human.paradrop()
	return TRUE

/datum/human_tied_controller/proc/force_setup_move(turf/target_turf)
	if(!can_setup_puppet() || !target_turf)
		return FALSE
	tied_human.forceMove(target_turf)
	return TRUE
