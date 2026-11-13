#define DEFAULT_SPAWN_HIVE_STRING XENO_HIVE_NORMAL

/datum/game_master_submenu/infest
	tgui_menu_name = "GameMasterSubmenuInfest"
	tgui_menu_title = "Infest Control"

	/// Current selected hive for the embryo
	var/selected_hive = DEFAULT_SPAWN_HIVE_STRING

	/// Current selected embryo subtype token
	var/selected_embryo_type = "standard" // SS220 EDIT: GM hybrid embryo selector

	/// Target growth stage for the embryo
	var/embryo_stage = 0

/datum/game_master_submenu/infest/ui_data(mob/user)
	. = ..()

	var/list/data = list()

	data["selected_hive"] = selected_hive
	data["selected_embryo_type"] = selected_embryo_type // SS220 EDIT: GM hybrid embryo selector
	data["embryo_stage"] = embryo_stage

	return data

/datum/game_master_submenu/infest/ui_static_data(mob/user)
	. = ..()

	var/list/data = list()

	data["selectable_hives"] = ALL_XENO_HIVES
	data["selectable_embryos"] = xeno_races_get_embryo_options() // SS220 EDIT: GM hybrid embryo selector

	return data

/datum/game_master_submenu/infest/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("set_selected_hive")
			selected_hive = params["new_hive"]
			return TRUE

		// SS220 EDIT - START: GM hybrid embryo selector
		if("set_selected_embryo_type")
			var/list/embryo_registry = xeno_races_get_embryo_registry()
			if(embryo_registry[params["new_embryo_type"]])
				selected_embryo_type = params["new_embryo_type"]
			else
				selected_embryo_type = "standard"
			return TRUE
		// SS220 EDIT - END

		if("set_embryo_stage")
			embryo_stage = params["stage"]
			return TRUE

		if("infest")
			setup_embryo()
			return TRUE

		if("clear_infest")
			remove_embryo()
			return TRUE

		if("burst")
			force_burst()
			return TRUE

// SS220 EDIT - START: support modular embryo subtypes
/datum/game_master_submenu/infest/proc/setup_embryo()
	var/selected_embryo_typepath = xeno_races_get_embryo_type(selected_embryo_type)
	// SS220 EDIT: Pathogen infestations must create the pathogen embryo.
	if(selected_hive == XENO_HIVE_PATHOGEN)
		selected_embryo_typepath = /obj/item/alien_embryo/bloodburster
	var/obj/item/alien_embryo/infesting_embryo
	for(var/obj/item/alien_embryo/embryo in referenced_atom) //if this hive's embryo already exists, reuse it; otherwise clear it out
		if(!infesting_embryo && embryo.hivenumber == selected_hive && embryo.type == selected_embryo_typepath)
			infesting_embryo = embryo
		else
			qdel(embryo)

	if(!infesting_embryo) //else, make a new one
		infesting_embryo = new selected_embryo_typepath(referenced_atom)
		infesting_embryo.hivenumber = selected_hive

		var/mob/living/carbon/human/infested_host = referenced_atom
		infested_host.species?.larva_impregnated(infesting_embryo) //Yautja handling

	if(selected_hive == XENO_HIVE_PATHOGEN)
		infesting_embryo.flags_embryo |= FLAG_EMBRYO_PATHOGEN // SS220 EDIT: convert reused embryos as well

	infesting_embryo.stage = embryo_stage
// SS220 EDIT - END

/datum/game_master_submenu/infest/proc/remove_embryo()
	for(var/obj/item/alien_embryo/embryo in referenced_atom)
		qdel(embryo)

// SS220 EDIT - START: support modular embryo subtypes
/datum/game_master_submenu/infest/proc/force_burst()
	var/selected_embryo_typepath = xeno_races_get_embryo_type(selected_embryo_type)
	var/selected_xeno_typepath = xeno_races_get_embryo_xeno_type(selected_embryo_type)
	// SS220 EDIT: Force burst uses a bloodburster, including aberrant predator hosts.
	if(selected_hive == XENO_HIVE_PATHOGEN)
		selected_embryo_typepath = /obj/item/alien_embryo/bloodburster
		selected_xeno_typepath = isyautja(referenced_atom) ? /mob/living/carbon/xenomorph/bloodburster/aberrant : /mob/living/carbon/xenomorph/bloodburster
	var/mob/living/carbon/xenomorph/infesting_xeno
	for(var/mob/living/carbon/xenomorph/existing_xeno in referenced_atom) //if this hive's selected xeno already exists, use it
		if(!infesting_xeno && existing_xeno.hivenumber == selected_hive && istype(existing_xeno, selected_xeno_typepath))
			infesting_xeno = existing_xeno
		else
			qdel(existing_xeno)
	if(infesting_xeno)
		infesting_xeno.chest_burst(referenced_atom)
		return

	var/obj/item/alien_embryo/infesting_embryo
	for(var/obj/item/alien_embryo/embryo in referenced_atom) //else if this hive's embryo already exists, convert to larva and use it
		if(!infesting_embryo && embryo.hivenumber == selected_hive && embryo.type == selected_embryo_typepath)
			infesting_embryo = embryo
		else
			qdel(embryo)

	if(infesting_embryo)
		infesting_embryo.become_larva()
		for(var/mob/living/carbon/xenomorph/new_xeno in referenced_atom)
			if(new_xeno.hivenumber == selected_hive && istype(new_xeno, selected_xeno_typepath))
				infesting_xeno = new_xeno
				break
		if(infesting_xeno)
			infesting_xeno.chest_burst(referenced_atom)
		return

	infesting_xeno = new selected_xeno_typepath(referenced_atom, null, selected_hive) //else, make a new xeno
	var/mob/living/carbon/human/infested_host = referenced_atom
	infesting_xeno.ckey = infested_host.ckey
	infesting_xeno.chest_burst(referenced_atom)
// SS220 EDIT - END

#undef DEFAULT_SPAWN_HIVE_STRING
