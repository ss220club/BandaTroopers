/datum/world_edit_manager/proc/apply_ui_payload(list/data, list/payload)
	if(!islist(data) || !islist(payload))
		return data

	for(var/key in payload)
		data[key] = payload[key]
	return data

/datum/world_edit_manager/proc/build_generator_ui_payload(has_generator, list/ui_fields, requires_preview, list/generator_payload = null)
	return list(
		"has_generator" = has_generator ? TRUE : FALSE,
		"current_generator_id" = current_definition?.id,
		"current_generator_supports_preview" = current_definition?.supports_preview ? TRUE : FALSE,
		"requires_preview_before_apply" = requires_preview ? TRUE : FALSE,
		"ui_fields" = ui_fields,
		"generator_payload" = islist(generator_payload) ? generator_payload : list(),
	)
