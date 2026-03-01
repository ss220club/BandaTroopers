/datum/squad_name_manager/proc/move_simple_bucket(list/assoc_list, old_key, new_key)
	if(!islist(assoc_list) || old_key == new_key)
		return

	var/list/old_bucket = assoc_list[old_key]
	if(!islist(old_bucket))
		return

	assoc_list -= old_key
	var/list/new_bucket = assoc_list[new_key]
	if(!islist(new_bucket))
		assoc_list[new_key] = old_bucket
		return

	for(var/entry in old_bucket)
		if(!(entry in new_bucket))
			new_bucket += entry

/datum/squad_name_manager/proc/move_spawn_bucket(old_name, new_name)
	if(old_name == new_name)
		return

	var/list/old_bucket = GLOB.spawns_by_squad_and_job[old_name]
	if(!islist(old_bucket))
		return

	GLOB.spawns_by_squad_and_job -= old_name
	var/list/new_bucket = GLOB.spawns_by_squad_and_job[new_name]
	if(!islist(new_bucket))
		GLOB.spawns_by_squad_and_job[new_name] = old_bucket
		return

	for(var/job in old_bucket)
		var/list/old_job_bucket = old_bucket[job]
		if(!islist(old_job_bucket))
			continue

		var/list/new_job_bucket = new_bucket[job]
		if(!islist(new_job_bucket))
			new_bucket[job] = old_job_bucket
			continue

		for(var/entry in old_job_bucket)
			if(!(entry in new_job_bucket))
				new_job_bucket += entry

/datum/squad_name_manager/proc/update_datacore_records(old_name, new_name)
	if(!GLOB.data_core || !islist(GLOB.data_core.general) || old_name == new_name)
		return

	for(var/datum/data/record/cycled_data_record in GLOB.data_core.general)
		if(cycled_data_record.fields["squad"] == old_name)
			cycled_data_record.fields["squad"] = new_name

/datum/squad_name_manager/proc/update_members_id_assignments(datum/squad/target_squad, new_name)
	if(!istype(target_squad, /datum/squad/marine))
		target_squad.name = new_name
		return

	var/datum/squad/marine/marine_squad = target_squad
	var/old_name = marine_squad.name
	marine_squad.rename_platoon(null, new_name, old_name)

/datum/squad_name_manager/proc/update_global_mappings(datum/squad/target_squad, old_name, new_name)
	if(old_name == new_name)
		return

	var/channel = GLOB.radiochannels[old_name]
	if(!isnull(channel))
		GLOB.radiochannels -= old_name
		GLOB.radiochannels[new_name] = channel

	var/list/keys_to_update = list()
	for(var/key in GLOB.department_radio_keys)
		if(GLOB.department_radio_keys[key] == old_name)
			keys_to_update += key
	for(var/key in keys_to_update)
		GLOB.department_radio_keys[key] = new_name

	move_simple_bucket(GLOB.frozen_items, old_name, new_name)
	move_simple_bucket(GLOB.latejoin_by_squad, old_name, new_name)
	move_spawn_bucket(old_name, new_name)
	update_datacore_records(old_name, new_name)

	update_members_id_assignments(target_squad, new_name)
