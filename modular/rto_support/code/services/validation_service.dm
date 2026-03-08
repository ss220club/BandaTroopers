/// Validation service for zone deployment, support calls, and utility targeting.
/datum/rto_support_validation_service

/// Validates a visibility zone deployment attempt.
/datum/rto_support_validation_service/proc/validate_zone_deploy(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars)
	var/datum/rto_support_validation_result/result = validate_support_context(controller, target_turf, user, binoculars, FALSE, FALSE)
	if(!result.success)
		return result
	if(!controller.active_template)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Сначала выберите пакет поддержки.")
		return failure
	if(!controller.template_requires_zone())
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Этот пакет не использует сектор наведения.")
		return failure
	if(!controller.can_deploy_zone())
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure(controller.get_action_block_message(RTO_SUPPORT_ARM_VISIBILITY_ZONE))
		return failure
	if(controller.active_template.visibility_altitude_requirement == RTO_SUPPORT_ALTITUDE_HIGH && !is_high_altitude_target_valid(user, target_turf))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Точка недоступна для авиационного сектора.")
		return failure
	var/datum/rto_support_validation_result/success = new
	success.set_success()
	return success

/// Validates a support call attempt.
/datum/rto_support_validation_service/proc/validate_support_call(datum/rto_support_controller/controller, datum/rto_support_action_template/action_template, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars)
	if(!action_template)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Способность поддержки недоступна.")
		return failure
	var/require_zone = action_template.requires_visibility_zone && controller?.template_requires_zone()
	var/datum/rto_support_validation_result/result = validate_support_context(controller, target_turf, user, binoculars, require_zone, action_template.allow_closed_turf)
	if(!result.success)
		return result
	if(controller.get_remaining_shared_cooldown() > 0)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure(controller.get_action_block_message(action_template.action_id))
		return failure
	if(controller.get_remaining_action_cooldown(action_template.action_id) > 0)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure(controller.get_action_block_message(action_template.action_id))
		return failure
	if(action_template.altitude_requirement == RTO_SUPPORT_ALTITUDE_HIGH && !is_high_altitude_target_valid(user, target_turf))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Точка недоступна для этого типа поддержки.")
		return failure
	var/datum/rto_support_validation_result/success = new
	success.set_success()
	return success

/// Validates explicit coordinate acquisition.
/datum/rto_support_validation_service/proc/validate_coordinate_target(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars)
	return validate_utility_context(controller, target_turf, user, binoculars)

/// Validates manual marker placement.
/datum/rto_support_validation_service/proc/validate_manual_marker_target(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars)
	return validate_utility_context(controller, target_turf, user, binoculars)

/datum/rto_support_validation_service/proc/validate_support_context(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars, require_zone, allow_closed_turf)
	var/datum/rto_support_validation_result/result = validate_common_context(controller, target_turf, user, binoculars, TRUE, FALSE, allow_closed_turf, require_zone)
	if(!result.success)
		return result
	var/datum/rto_support_validation_result/success = new
	success.set_success()
	return success

/datum/rto_support_validation_service/proc/validate_utility_context(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars)
	var/datum/rto_support_validation_result/result = validate_common_context(controller, target_turf, user, binoculars, FALSE, TRUE, TRUE, FALSE)
	if(!result.success)
		return result
	var/datum/rto_support_validation_result/success = new
	success.set_success()
	return success

/datum/rto_support_validation_service/proc/validate_common_context(datum/rto_support_controller/controller, turf/target_turf, mob/living/carbon/human/user, obj/item/device/binoculars/rto/binoculars, require_template, allow_shipside, allow_closed_turf, require_zone)
	if(!controller || !controller.owner || user != controller.owner)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Контроллер поддержки недоступен.")
		return failure
	if(require_template && !controller.active_template)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Сначала выберите пакет поддержки.")
		return failure
	if(!controller.has_rto_binocular_in_hand())
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Нужен RTO-бинокль.")
		return failure
	if(!target_turf || QDELETED(target_turf))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Цель недоступна.")
		return failure
	if(!binoculars || binoculars != user.interactee)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Нужно смотреть через RTO-бинокль.")
		return failure
	if(user.is_mob_incapacitated())
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Вы не можете использовать поддержку в текущем состоянии.")
		return failure
	if(!allow_shipside && (is_mainship_level(user.z) || is_mainship_level(target_turf.z)))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Поддержка недоступна на корабле.")
		return failure
	if(user.z != target_turf.z)
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Цель должна находиться на том же уровне.")
		return failure
	if(!allow_closed_turf && istype(target_turf, /turf/closed))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Цель должна быть на открытом тайле.")
		return failure
	if(!can_see_target(user, target_turf, binoculars))
		var/datum/rto_support_validation_result/failure = new
		failure.set_failure("Нет прямой видимости до цели.")
		return failure
	if(require_zone)
		var/datum/rto_visibility_zone/zone = controller.get_active_zone()
		if(!zone)
			var/zone_state = controller.get_zone_state()
			if(zone_state == RTO_SUPPORT_ZONE_STATE_COOLDOWN)
				var/datum/rto_support_validation_result/failure = new
				failure.set_failure("Сектор наведения ещё перезаряжается.")
				return failure
			var/datum/rto_support_validation_result/failure = new
			failure.set_failure("Сначала разверните сектор наведения.")
			return failure
		if(!zone.contains_turf(target_turf))
			var/datum/rto_support_validation_result/failure = new
			failure.set_failure("Цель вне сектора наведения.")
			return failure
	var/datum/rto_support_validation_result/success = new
	success.set_success()
	return success

/datum/rto_support_validation_service/proc/can_see_target(mob/living/carbon/human/user, turf/target_turf, obj/item/device/binoculars/rto/binoculars)
	if(QDELETED(target_turf))
		return FALSE
	return binoculars.can_see_target(target_turf, user)

/datum/rto_support_validation_service/proc/is_high_altitude_target_valid(mob/living/carbon/human/user, turf/target_turf)
	var/area/target_area = get_area(target_turf)
	var/area/user_area = get_area(user)
	var/is_outside = FALSE

	switch(target_area?.ceiling)
		if(CEILING_NONE, CEILING_GLASS)
			is_outside = TRUE

	switch(user_area?.ceiling)
		if(CEILING_NONE, CEILING_GLASS)
			if(target_area?.ceiling <= CEILING_PROTECTION_TIER_3)
				is_outside = TRUE

	if(protected_by_pylon(TURF_PROTECTION_CAS, target_turf))
		is_outside = FALSE

	return is_outside
