/datum/admins/proc/get_human_ai_machinegunner_equipment_presets()
	var/list/equipment_presets = list(
		/datum/equipment_preset/rebel/soldier::name = /datum/equipment_preset/rebel/soldier,
		/datum/equipment_preset/clf/soldier::name = /datum/equipment_preset/clf/soldier,
		/datum/equipment_preset/canc/remnant::name = /datum/equipment_preset/canc/remnant,
		/datum/equipment_preset/canc/remnant/snowman::name = /datum/equipment_preset/canc/remnant/snowman,
		/datum/equipment_preset/canc/newblood_machinegunner::name = /datum/equipment_preset/canc/newblood_machinegunner,
		/datum/equipment_preset/canc/machinegunner::name = /datum/equipment_preset/canc/machinegunner,
		/datum/equipment_preset/canc_dogwar/militia/lmg::name = /datum/equipment_preset/canc_dogwar/militia/lmg,
		/datum/equipment_preset/canc_dogwar/soldier/machinegunner::name = /datum/equipment_preset/canc_dogwar/soldier/machinegunner,
		/datum/equipment_preset/canc/machinegunner/snowman::name = /datum/equipment_preset/canc/machinegunner/snowman,
		/datum/equipment_preset/upp/machinegunner::name = /datum/equipment_preset/upp/machinegunner,
		/datum/equipment_preset/contractor/duty/heavy::name = /datum/equipment_preset/contractor/duty/heavy,
		/datum/equipment_preset/pmc/gunner::name = /datum/equipment_preset/pmc/gunner,
		/datum/equipment_preset/uscm/smartgunner_equipped::name = /datum/equipment_preset/uscm/smartgunner_equipped,
		/datum/equipment_preset/usa/gunner::name = /datum/equipment_preset/usa/gunner,
		/datum/equipment_preset/usa/heavygunner::name = /datum/equipment_preset/usa/heavygunner,
		/datum/equipment_preset/royal_marine/machinegun::name = /datum/equipment_preset/royal_marine/machinegun,
		/datum/equipment_preset/contractor/covert/heavy::name = /datum/equipment_preset/contractor/covert/heavy,
		/datum/equipment_preset/other/freelancer/machinegunner::name = /datum/equipment_preset/other/freelancer/machinegunner,
		/datum/equipment_preset/other/elite_merc/heavy::name = /datum/equipment_preset/other/elite_merc/heavy,
		/datum/equipment_preset/rebel/soldier/machinegunner::name = /datum/equipment_preset/rebel/soldier/machinegunner,
		/datum/equipment_preset/clf/soldier/machinegunner::name = /datum/equipment_preset/clf/soldier/machinegunner,
		/datum/equipment_preset/mercenary/sentinel/mg::name = /datum/equipment_preset/mercenary/sentinel/mg,
		/datum/equipment_preset/fil/rifleman/mg::name = /datum/equipment_preset/fil/rifleman/mg,
	)
	if(hascall(src, "modular_append_human_ai_machinegunner_equipment_presets"))
		call(src, "modular_append_human_ai_machinegunner_equipment_presets")(equipment_presets)
	return equipment_presets

/datum/admins/proc/create_human_ai_machinegunner()
	set name = "Create Human AI machinegunner"
	set category = "Game Master.HumanAI"

	var/list/machinegunner_equipment_presets = get_human_ai_machinegunner_equipment_presets()

	if(!check_rights(R_DEBUG))
		return

	if(tgui_input_list(usr, "Press Enter to select the home turf of the machinegunner.", "Home Turf", list("Enter", "Cancel")) != "Enter")
		return

	var/turf/home_turf = get_turf(usr)
	var/turf/target_turf

	while(TRUE)
		if(tgui_input_list(usr, "Press Enter to select the center of the machinegunner's overwatch. This must be within 30 tiles and not be blocked.", "Target Turf", list("Enter", "Cancel")) == "Enter")
			var/turf/maybe_target_turf = get_turf(usr)
			if(get_dist(home_turf, maybe_target_turf) > 30)
				to_chat(usr, SPAN_WARNING("This turf is too far away. Max range 30, attempted range [get_dist(home_turf, target_turf)]."))
				continue

			if(locate(/turf/closed) in get_line(home_turf, maybe_target_turf))
				to_chat(usr, SPAN_WARNING("A wall is located between the home and target turf."))
				continue
			target_turf = maybe_target_turf
		break

	if(!home_turf || !target_turf)
		return

	var/mob/living/carbon/human/ai_human = new()
	var/datum/component/human_ai/ai_comp = ai_human.AddComponent(/datum/component/human_ai)
	var/chosen_equipment_name = tgui_input_list(usr, "Select machinegunner equipment.", "machinegunner Equipment", machinegunner_equipment_presets)
	if(!chosen_equipment_name)
		qdel(ai_human)
		return
	arm_equipment(ai_human, machinegunner_equipment_presets[chosen_equipment_name], TRUE)

	var/datum/human_ai_context/setup_context = ai_comp.ai_brain.create_context()
	var/datum/human_tied_controller/controller = setup_context.controller
	if(!controller)
		qdel(setup_context)
		qdel(ai_human)
		return
	controller.forceMove(home_turf)
	qdel(setup_context)
	ai_comp.ai_brain.set_machinegunner_home(home_turf, get_cardinal_dir(home_turf, target_turf))

	to_chat(usr, SPAN_NOTICE("machinegunner has been created."))

/datum/admins/proc/get_human_ai_sniper_equipment_presets()
	var/list/equipment_presets = list(
		/datum/equipment_preset/clf/soldier/bolt::name = /datum/equipment_preset/clf/soldier/bolt,
		/datum/equipment_preset/clf/soldier/svd::name = /datum/equipment_preset/clf/soldier/svd,
		/datum/equipment_preset/rebel/sniper::name = /datum/equipment_preset/rebel/sniper,
		/datum/equipment_preset/canc/remnant/marksman::name = /datum/equipment_preset/canc/remnant/marksman,
		/datum/equipment_preset/canc_dogwar/soldier/marksman::name = /datum/equipment_preset/canc_dogwar/soldier/marksman,
		/datum/equipment_preset/canc_dogwar/militia/marksman::name = /datum/equipment_preset/canc_dogwar/militia/marksman,
		/datum/equipment_preset/canc_dogwar/upp/marksman::name = /datum/equipment_preset/canc_dogwar/upp/marksman,
		/datum/equipment_preset/canc_dogwar/specops/marksman::name = /datum/equipment_preset/canc_dogwar/specops/marksman,
		/datum/equipment_preset/canc/remnant/marksman/snowman::name = /datum/equipment_preset/canc/remnant/marksman/snowman,
		/datum/equipment_preset/canc/remnant/marksman/type88::name = /datum/equipment_preset/canc/remnant/marksman/type88,
		/datum/equipment_preset/canc/remnant/marksman/type88/snowman::name = /datum/equipment_preset/canc/remnant/marksman/type88/snowman,
		/datum/equipment_preset/pmc/sniper::name = /datum/equipment_preset/pmc/sniper,
		/datum/equipment_preset/upp/sniper::name = /datum/equipment_preset/upp/sniper,
		/datum/equipment_preset/uscm/specialist_equipped/sniper::name = /datum/equipment_preset/uscm/specialist_equipped/sniper,
		/datum/equipment_preset/other/freelancer/marksman::name = /datum/equipment_preset/other/freelancer/marksman,
		/datum/equipment_preset/royal_marine/sniper::name = /datum/equipment_preset/royal_marine/sniper/ai,
		/datum/equipment_preset/colonist/security/guard/marksman::name = /datum/equipment_preset/colonist/security/guard/marksman,
		/datum/equipment_preset/mercenary/sentinel/marksman::name = /datum/equipment_preset/mercenary/sentinel/marksman,
		/datum/equipment_preset/mercenary/infiltrator::name = /datum/equipment_preset/mercenary/infiltrator,
		/datum/equipment_preset/fil/rifleman/sniper::name = /datum/equipment_preset/fil/rifleman/sniper,
	)
	if(hascall(src, "modular_append_human_ai_sniper_equipment_presets"))
		call(src, "modular_append_human_ai_sniper_equipment_presets")(equipment_presets)
	return equipment_presets

/datum/admins/proc/create_human_ai_sniper()
	set name = "Create Human AI Sniper"
	set category = "Game Master.HumanAI"

	var/list/sniper_equipment_presets = get_human_ai_sniper_equipment_presets()

	if(!check_rights(R_DEBUG))
		return

	if(tgui_input_list(usr, "Press Enter to select the home turf of the sniper.", "Home Turf", list("Enter", "Cancel")) != "Enter")
		return

	var/turf/home_turf = get_turf(usr)
	var/turf/target_turf

	while(TRUE)
		if(tgui_input_list(usr, "Press Enter to select the center of the sniper's overwatch. This must be within 30 tiles and not be blocked.", "Target Turf", list("Enter", "Cancel")) == "Enter")
			var/turf/maybe_target_turf = get_turf(usr)
			if(get_dist(home_turf, maybe_target_turf) > 30)
				to_chat(usr, SPAN_WARNING("This turf is too far away. Max range 30, attempted range [get_dist(home_turf, target_turf)]."))
				continue

			if(locate(/turf/closed) in get_line(home_turf, maybe_target_turf))
				to_chat(usr, SPAN_WARNING("A wall is located between the home and target turf."))
				continue
			target_turf = maybe_target_turf
		break

	if(!home_turf || !target_turf)
		return

	var/mob/living/carbon/human/ai_human = new()
	var/datum/component/human_ai/ai_comp = ai_human.AddComponent(/datum/component/human_ai)
	var/chosen_equipment_name = tgui_input_list(usr, "Select sniper equipment.", "Sniper Equipment", sniper_equipment_presets)
	if(!chosen_equipment_name)
		qdel(ai_human)
		return
	arm_equipment(ai_human, sniper_equipment_presets[chosen_equipment_name], TRUE)

	var/datum/human_ai_context/setup_context = ai_comp.ai_brain.create_context()
	var/datum/human_tied_controller/controller = setup_context.controller
	if(!controller)
		qdel(setup_context)
		qdel(ai_human)
		return
	controller.forceMove(home_turf)
	qdel(setup_context)
	ai_comp.ai_brain.set_sniper_home(home_turf, get_cardinal_dir(home_turf, target_turf))

	to_chat(usr, SPAN_NOTICE("Sniper has been created."))
