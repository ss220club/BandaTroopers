/// Immutable configuration datum for one RTO support template.
/datum/rto_support_template
	/// Stable identifier used by selection logic and UI.
	var/template_id
	/// Display name shown to players.
	var/name = "RTO Support Template"
	/// Design description shown in the preset menu.
	var/description = ""
	/// Short gameplay summary shown in the preset menu.
	var/role_summary = ""
	/// Targeting summary shown in the preset menu.
	var/targeting_summary = ""
	/// Short restriction summary shown in the preset menu.
	var/restriction_summary = ""
	/// Whether the template needs a visibility zone.
	var/requires_visibility_zone = TRUE
	/// Display name for the visibility sector action.
	var/visibility_zone_name = "Развернуть сектор наведения"
	/// Short description of the sector type for UI.
	var/visibility_zone_type = ""
	/// Radius of the visibility sector.
	var/visibility_zone_radius = 0
	/// Lifetime of the visibility sector.
	var/visibility_zone_duration = 0
	/// Cooldown of the visibility sector action.
	var/visibility_zone_cooldown = 0
	/// Category or family name for UI grouping.
	var/category = ""
	/// Immutable list of action template instances.
	var/list/action_templates = list()
	/// Action template typepaths instantiated on New.
	var/list/action_template_types = list()
	/// Optional fire support payload played on successful sector deployment.
	var/visibility_support_path = null
	/// Altitude requirement for visibility zone deployment.
	var/visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_ANY
	/// Icon file used by the visibility zone action.
	var/visibility_action_icon_file = 'icons/mob/hud/actions.dmi'
	/// Icon state used by the visibility zone action.
	var/visibility_action_icon_state = "designator_mortar"
	/// Marker style used while placing the visibility zone.
	var/visibility_target_marker_style = RTO_SUPPORT_MARKER_SLOW_BLINK

/datum/rto_support_template/New()
	. = ..()
	action_templates = list()
	for(var/action_type in action_template_types)
		action_templates += new action_type

/datum/rto_support_template/Destroy()
	if(length(action_templates))
		for(var/datum/rto_support_action_template/action_template as anything in action_templates)
			qdel(action_template)
	action_templates = null
	action_template_types = null
	return ..()

/// Returns action templates bound to this support template.
/datum/rto_support_template/proc/get_action_templates()
	return action_templates.Copy()

/// Returns one action template by its stable identifier.
/datum/rto_support_template/proc/get_action_template(action_id)
	for(var/datum/rto_support_action_template/action_template as anything in action_templates)
		if(action_template.action_id == action_id)
			return action_template
	return null

/// Builds a UI DTO for the preset menu.
/datum/rto_support_template/proc/build_ui_entry(datum/rto_support_controller/controller = null)
	var/datum/rto_support_ui_preset_entry/entry = new
	entry.template_id = template_id
	entry.name = name
	entry.description = description
	entry.role_summary = role_summary
	entry.targeting_summary = targeting_summary
	entry.restriction_summary = restriction_summary
	entry.requires_visibility_zone = requires_visibility_zone
	entry.visibility_zone_name = visibility_zone_name
	entry.visibility_zone_type = visibility_zone_type
	entry.visibility_zone_radius = visibility_zone_radius
	entry.visibility_zone_duration = visibility_zone_duration
	entry.visibility_zone_cooldown = visibility_zone_cooldown
	entry.visibility_altitude_requirement = visibility_altitude_requirement
	entry.actions = list()
	for(var/datum/rto_support_action_template/action_template as anything in action_templates)
		var/datum/rto_support_ui_action_entry/action_entry = action_template.build_ui_entry(controller)
		entry.actions += list(action_entry.to_list())
	return entry
