/datum/modpack/localization/proc/halo_ai_line_pack_keys()
	return list(
		"enter_combat_lines",
		"exit_combat_lines",
		"squad_member_death_lines",
		"grenade_thrown_lines",
		"reload_lines",
		"reload_internal_mag_lines",
		"need_healing_lines",
	)

/datum/modpack/localization/proc/halo_ai_build_line_pack(list/enter_lines = null, list/exit_lines = null, list/death_lines = null, list/grenade_lines = null, list/reload_lines = null, list/reload_internal_lines = null, list/heal_lines = null)
	var/list/pack = list()
	if(islist(enter_lines))
		pack["enter_combat_lines"] = enter_lines.Copy()
	if(islist(exit_lines))
		pack["exit_combat_lines"] = exit_lines.Copy()
	if(islist(death_lines))
		pack["squad_member_death_lines"] = death_lines.Copy()
	if(islist(grenade_lines))
		pack["grenade_thrown_lines"] = grenade_lines.Copy()
	if(islist(reload_lines))
		pack["reload_lines"] = reload_lines.Copy()
	if(islist(reload_internal_lines))
		pack["reload_internal_mag_lines"] = reload_internal_lines.Copy()
	if(islist(heal_lines))
		pack["need_healing_lines"] = heal_lines.Copy()
	return pack

/datum/modpack/localization/proc/halo_ai_copy_line_pack(list/source_pack)
	var/list/copied_pack = list()
	if(!islist(source_pack))
		return copied_pack

	for(var/key in halo_ai_line_pack_keys())
		var/list/source_lines = source_pack[key]
		if(islist(source_lines))
			copied_pack[key] = source_lines.Copy()

	return copied_pack

/datum/modpack/localization/proc/halo_ai_merge_line_pack(list/base_pack, list/extra_pack)
	var/list/merged_pack = halo_ai_copy_line_pack(base_pack)
	if(!islist(extra_pack))
		return merged_pack

	for(var/key in halo_ai_line_pack_keys())
		var/list/extra_lines = extra_pack[key]
		if(!islist(extra_lines))
			continue

		if(!islist(merged_pack[key]))
			merged_pack[key] = extra_lines.Copy()
			continue

		var/list/combined_lines = merged_pack[key]
		combined_lines += extra_lines
		merged_pack[key] = combined_lines

	return merged_pack

/datum/modpack/localization/proc/halo_ai_apply_line_pack(datum/target, list/pack, append = FALSE)
	if(!target || !islist(pack))
		return

	for(var/key in halo_ai_line_pack_keys())
		var/list/pack_lines = pack[key]
		if(!islist(pack_lines))
			continue

		if(!append || !islist(target.vars[key]))
			target.vars[key] = pack_lines.Copy()
			continue

		var/list/existing_lines = target.vars[key]
		existing_lines = existing_lines.Copy()
		existing_lines += pack_lines
		target.vars[key] = existing_lines

/datum/modpack/localization/proc/halo_ai_get_faction_localization_pack(faction_name)
	var/list/general_pack = halo_ai_get_general_faction_localization_pack(faction_name)
	if(islist(general_pack))
		return general_pack

	return halo_ai_get_halo_faction_localization_pack(faction_name)

/datum/modpack/localization/proc/halo_ai_localize_human_ai_factions(datum/controller/subsystem/human_ai/subsystem)
	if(!subsystem)
		return

	for(var/faction_name in subsystem.human_ai_factions)
		var/list/localized_pack = halo_ai_get_faction_localization_pack(faction_name)
		if(!islist(localized_pack))
			continue

		var/datum/human_ai_faction/faction_datum = subsystem.human_ai_factions[faction_name]
		halo_ai_apply_line_pack(faction_datum, localized_pack)
		faction_datum.reapply_faction_data()

/datum/modpack/localization/proc/halo_ai_apply_default_fallback_to_brain(datum/human_ai_brain/brain)
	if(!brain)
		return

	var/datum/human_ai_faction/faction_datum
	if(SShuman_ai && brain.tied_human?.faction)
		faction_datum = SShuman_ai.human_ai_factions[brain.tied_human.faction]

	var/list/default_pack = halo_ai_get_default_fallback_pack()
	for(var/key in halo_ai_line_pack_keys())
		if(length(faction_datum?.vars[key]))
			continue
		var/list/default_lines = default_pack[key]
		brain.vars[key] = default_lines.Copy()

/datum/human_ai_brain/proc/modular_finalize_human_ai_brain(mob/living/carbon/human/new_human)
	var/datum/modpack/localization/localization_pack
	if(SSmodpacks)
		localization_pack = SSmodpacks.get_modpack(/datum/modpack/localization)
	if(!localization_pack)
		return

	localization_pack.halo_ai_apply_default_fallback_to_brain(src)
