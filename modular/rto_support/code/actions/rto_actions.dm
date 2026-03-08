/// Base class for RTO HUD actions.
/datum/action/human_action/rto
	name = "RTO Action"
	button_icon_state = "template"
	var/datum/rto_support_controller/controller

/datum/action/human_action/rto/New(datum/rto_support_controller/new_controller)
	controller = new_controller
	..()
	button.icon_state = "template"
	refresh_from_controller()

/datum/action/human_action/rto/Destroy()
	controller = null
	return ..()

/datum/action/human_action/rto/can_use_action()
	if(!..())
		return FALSE
	var/mob/living/carbon/human/human = owner
	return istype(human) && !human.is_mob_incapacitated() && !HAS_TRAIT(human, TRAIT_DAZED) && controller?.has_rto_binocular_in_hand()

/datum/action/human_action/rto/proc/refresh_from_controller()
	return

/datum/action/human_action/rto/proc/set_button_state(button_state, disabled = FALSE)
	if(!button)
		return
	button.icon_state = button_state == RTO_SUPPORT_BUTTON_STATE_ARMED ? "template_on" : "template"
	if(button_state == RTO_SUPPORT_BUTTON_STATE_ARMED)
		button.color = rgb(255, 210, 90, 255)
		return
	if(disabled)
		button.color = rgb(120, 120, 120, 220)
		return
	button.color = rgb(255, 255, 255, 255)

/datum/action/human_action/rto/proc/set_button_countdown(text, color = "#f2f2f2")
	if(!button)
		return
	if(!length(text))
		button.set_maptext(null)
		return
	button.set_maptext(SMALL_FONTS_COLOR(7, text, color), 18, 2)

/datum/action/human_action/rto/proc/format_seconds(ds_value)
	return "[round(max(0, ds_value) / 10)]s"

/datum/action/human_action/rto/proc/build_action_name(base_name, primary_label, list/secondary_labels)
	var/list/parts = list()
	if(length(primary_label))
		parts += primary_label
	if(length(secondary_labels))
		parts += secondary_labels
	return length(parts) ? "[base_name] ([jointext(parts, "; ")])" : base_name

/datum/action/human_action/rto/select_preset
	name = "Выбрать пакет поддержки"
	action_icon_state = "designator_swap_mortar"

/datum/action/human_action/rto/select_preset/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(!controller?.is_support_enabled_by_rules())
		to_chat(owner, SPAN_WARNING("Disabled by Game Rule Panel"))
		return
	if(!controller?.can_select_template())
		to_chat(owner, SPAN_WARNING("Пакет поддержки уже выбран."))
		return
	new /datum/rto_support_preset_menu(owner, controller)

/datum/action/human_action/rto/select_preset/refresh_from_controller()
	var/list/secondary = list()
	var/disabled_by_rules = !controller?.is_support_enabled_by_rules()
	var/has_binocular = controller?.has_rto_binocular_in_hand()
	var/label = disabled_by_rules ? "Disabled by Game Rule Panel" : (has_binocular ? RTO_SUPPORT_STATUS_READY : RTO_SUPPORT_STATUS_NO_BINOCULAR)
	set_name(build_action_name("Выбрать пакет поддержки", label, secondary))
	set_button_state(RTO_SUPPORT_BUTTON_STATE_READY, disabled_by_rules || !has_binocular)
	set_button_countdown(disabled_by_rules ? "GM" : (has_binocular ? null : "B"), "#c6c6c6")

/datum/action/human_action/rto/visibility_zone
	name = "Развернуть сектор наведения"

/datum/action/human_action/rto/visibility_zone/New(datum/rto_support_controller/new_controller)
	if(new_controller?.active_template)
		name = new_controller.active_template.visibility_zone_name
		icon_file = new_controller.active_template.visibility_action_icon_file
		action_icon_state = new_controller.active_template.visibility_action_icon_state
	..()

/datum/action/human_action/rto/visibility_zone/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(controller?.is_action_armed(RTO_SUPPORT_ARM_VISIBILITY_ZONE))
		controller.disarm_action()
		return
	controller?.arm_action(RTO_SUPPORT_ARM_VISIBILITY_ZONE)

/datum/action/human_action/rto/visibility_zone/refresh_from_controller()
	if(!controller?.active_template || !controller.template_requires_zone())
		set_button_state(RTO_SUPPORT_BUTTON_STATE_DISABLED, TRUE)
		set_button_countdown(null)
		return

	var/list/state = controller.build_visibility_action_state()
	var/button_state = state["is_armed"] ? RTO_SUPPORT_BUTTON_STATE_ARMED : RTO_SUPPORT_BUTTON_STATE_READY
	var/disabled = state["is_disabled"]
	var/button_name = build_action_name(controller.active_template.visibility_zone_name, state["primary_label"], null)

	set_name(button_name)
	set_button_state(button_state, disabled)
	set_button_countdown(state["countdown_text"], state["countdown_color"])

/datum/action/human_action/rto/coordinates
	name = "Координаты"
	action_icon_state = "spotter_target"
	icon_file = 'icons/mob/hud/actions.dmi'

/datum/action/human_action/rto/coordinates/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(controller?.is_action_armed(RTO_SUPPORT_ARM_COORDINATES))
		controller.disarm_action()
		return
	controller?.arm_action(RTO_SUPPORT_ARM_COORDINATES)

/datum/action/human_action/rto/coordinates/refresh_from_controller()
	var/disabled = !controller?.has_rto_binocular_in_hand()
	var/button_state = controller?.is_action_armed(RTO_SUPPORT_ARM_COORDINATES) ? RTO_SUPPORT_BUTTON_STATE_ARMED : RTO_SUPPORT_BUTTON_STATE_READY
	var/label = controller?.is_action_armed(RTO_SUPPORT_ARM_COORDINATES) ? RTO_SUPPORT_STATUS_TARGETING : (disabled ? RTO_SUPPORT_STATUS_NO_BINOCULAR : RTO_SUPPORT_STATUS_READY)

	set_name(build_action_name("Координаты", label, null))
	set_button_state(button_state, disabled)
	set_button_countdown(controller?.is_action_armed(RTO_SUPPORT_ARM_COORDINATES) ? "ARM" : (disabled ? "B" : null), controller?.is_action_armed(RTO_SUPPORT_ARM_COORDINATES) ? "#ffd25a" : "#c6c6c6")

/datum/action/human_action/rto/manual_marker
	name = "Лазерная отметка"
	action_icon_state = "designator_mortar"
	icon_file = 'icons/mob/hud/actions.dmi'

/datum/action/human_action/rto/manual_marker/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(controller?.is_action_armed(RTO_SUPPORT_ARM_MARKER))
		controller.disarm_action()
		return
	controller?.arm_action(RTO_SUPPORT_ARM_MARKER)

/datum/action/human_action/rto/manual_marker/refresh_from_controller()
	var/disabled = !controller?.has_rto_binocular_in_hand()
	var/button_state = controller?.is_action_armed(RTO_SUPPORT_ARM_MARKER) ? RTO_SUPPORT_BUTTON_STATE_ARMED : RTO_SUPPORT_BUTTON_STATE_READY
	var/label = controller?.is_action_armed(RTO_SUPPORT_ARM_MARKER) ? RTO_SUPPORT_STATUS_TARGETING : (disabled ? RTO_SUPPORT_STATUS_NO_BINOCULAR : RTO_SUPPORT_STATUS_READY)

	set_name(build_action_name("Лазерная отметка", label, null))
	set_button_state(button_state, disabled)
	set_button_countdown(controller?.is_action_armed(RTO_SUPPORT_ARM_MARKER) ? "ARM" : (disabled ? "B" : null), controller?.is_action_armed(RTO_SUPPORT_ARM_MARKER) ? "#ffd25a" : "#c6c6c6")

/datum/action/human_action/rto/support
	unique = FALSE
	var/datum/rto_support_action_template/action_template

/datum/action/human_action/rto/support/New(datum/rto_support_controller/new_controller, datum/rto_support_action_template/new_action_template)
	action_template = new_action_template
	if(action_template)
		name = action_template.name
		icon_file = action_template.icon_file
		action_icon_state = action_template.icon_state
	..(new_controller)

/datum/action/human_action/rto/support/Destroy()
	action_template = null
	return ..()

/datum/action/human_action/rto/support/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(controller?.is_action_armed(action_template?.action_id))
		controller.disarm_action()
		return
	controller?.arm_action(action_template?.action_id)

/datum/action/human_action/rto/support/refresh_from_controller()
	if(!controller?.active_template || !action_template)
		set_button_state(RTO_SUPPORT_BUTTON_STATE_DISABLED, TRUE)
		set_button_countdown(null)
		return

	var/list/state = controller.build_support_action_state(action_template.action_id)
	var/button_state = state["is_armed"] ? RTO_SUPPORT_BUTTON_STATE_ARMED : RTO_SUPPORT_BUTTON_STATE_READY
	var/disabled = state["is_disabled"]
	var/button_name = build_action_name(action_template.name, state["primary_label"], null)

	set_name(button_name)
	set_button_state(button_state, disabled)
	set_button_countdown(state["countdown_text"], state["countdown_color"])
