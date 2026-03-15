/// TGUI-backed preset selection menu for RTO support templates.
/datum/rto_support_preset_menu
	var/mob/living/carbon/human/user
	var/datum/rto_support_controller/controller
	var/closing = FALSE

/datum/rto_support_preset_menu/New(mob/living/carbon/human/new_user, datum/rto_support_controller/new_controller)
	user = new_user
	controller = new_controller
	. = ..()
	if(user)
		tgui_interact(user)

/datum/rto_support_preset_menu/Destroy()
	if(!closing)
		closing = TRUE
		SStgui.close_uis(src)
	user = null
	controller = null
	return ..()

/datum/rto_support_preset_menu/proc/request_close()
	if(closing)
		return FALSE
	closing = TRUE
	qdel(src)
	return TRUE

/datum/rto_support_preset_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RtoSupportPresetMenu", "RTO Support")
		ui.open()

/datum/rto_support_preset_menu/ui_status(mob/user, datum/ui_state/state)
	if(!istype(user, /mob/living/carbon/human))
		return UI_CLOSE
	if(!controller)
		return UI_CLOSE
	if(user != controller?.owner)
		return UI_CLOSE
	if(!controller.can_select_template())
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/rto_support_preset_menu/ui_static_data(mob/user)
	var/list/templates = list()
	if(controller)
		templates = controller.build_preset_ui_data()
	return list(
		"templates" = templates
	)

/datum/rto_support_preset_menu/ui_data(mob/user)
	var/can_select_template = FALSE
	var/active_template_name = null
	var/list/templates = list()
	if(controller)
		can_select_template = controller.can_select_template()
		active_template_name = controller.get_active_template()?.name
		templates = controller.build_preset_ui_data()
	return list(
		"can_select_template" = can_select_template,
		"active_template_name" = active_template_name,
		"templates" = templates
	)

/datum/rto_support_preset_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_template")
			var/template_id = params["template_id"]
			if(!length(template_id))
				return FALSE
			var/datum/rto_support_template/template = controller?.find_template(template_id)
			if(!template)
				return FALSE
			var/confirm_choice = tgui_alert(
				user,
				"Вы уверены, что хотите выбрать пакет поддержки \"[template.name]\"? Выбор нельзя изменить до конца жизни персонажа.",
				"Подтверждение выбора",
				list("Подтвердить", "Отмена"),
				15 SECONDS,
			)
			if(confirm_choice != "Подтвердить")
				return FALSE
			if(!controller?.select_template(template_id))
				to_chat(user, SPAN_WARNING("Не удалось выбрать пакет поддержки."))
				return FALSE
			to_chat(user, SPAN_NOTICE("Пакет поддержки выбран: [controller.active_template.name]."))
			request_close()
			return TRUE

	return FALSE

/datum/rto_support_preset_menu/ui_close(mob/user)
	if(closing)
		return FALSE
	closing = TRUE
	qdel(src)
	return TRUE
