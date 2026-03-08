/// Immutable configuration datum for one support action inside a template.
/datum/rto_support_action_template
	/// Stable identifier used by runtime and UI layers.
	var/action_id
	/// Display name shown on the action button.
	var/name = "RTO Support Action"
	/// Description shown in UI.
	var/description = ""
	/// Adapter-facing dispatch key.
	var/dispatch_key = "fire_support"
	/// Configured scatter override for a fresh support instance.
	var/scatter = 0
	/// Shared cooldown applied to all support actions on the controller.
	var/shared_cooldown = 0
	/// Personal cooldown applied only to this action.
	var/personal_cooldown = 0
	/// Whether the action requires an active visibility sector.
	var/requires_visibility_zone = TRUE
	/// Optional grouping label for UI.
	var/category = ""
	/// Icon file used by the action button overlay.
	var/icon_file = 'icons/mob/radial.dmi'
	/// Icon state used by the action button overlay.
	var/icon_state = null
	/// Fire support path instantiated by the dispatch adapter.
	var/fire_support_path
	/// Altitude requirement for the target area.
	var/altitude_requirement = RTO_SUPPORT_ALTITUDE_ANY
	/// Whether the ability may target a closed turf.
	var/allow_closed_turf = TRUE
	/// Marker style used for the target preview.
	var/target_marker_style = RTO_SUPPORT_MARKER_STATIC

/// Builds a UI DTO for the action list.
/datum/rto_support_action_template/proc/build_ui_entry(datum/rto_support_controller/controller = null)
	var/datum/rto_support_ui_action_entry/entry = new
	entry.action_id = action_id
	entry.name = name
	entry.description = description
	entry.dispatch_key = dispatch_key
	entry.scatter = scatter
	entry.shared_cooldown = controller ? controller.get_effective_shared_cooldown(src) : shared_cooldown
	entry.personal_cooldown = controller ? controller.get_effective_personal_cooldown(src) : personal_cooldown
	entry.requires_visibility_zone = requires_visibility_zone
	entry.icon_state = icon_state
	entry.altitude_requirement = altitude_requirement
	entry.allow_closed_turf = allow_closed_turf
	return entry
