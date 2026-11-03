/proc/modular_spawn_human_ai_from_equipment_preset(equipment_preset_type, turf/spawn_turf, randomise = TRUE, facing_dir = null)
	if(!spawn_turf || !ispath(equipment_preset_type, /datum/equipment_preset))
		return null

	var/mob/living/carbon/human/ai_human = new(spawn_turf)
	arm_equipment(ai_human, equipment_preset_type, randomise)

	var/datum/equipment_preset/assigned_preset = ai_human.assigned_equipment_preset
	var/expected_species = assigned_preset?.expected_species
	if(expected_species && ai_human.species?.group != expected_species && ai_human.species?.name != expected_species)
		ai_human.set_species(expected_species)

	if(!isnull(facing_dir))
		ai_human.face_dir(facing_dir)

	var/datum/component/human_ai/ai_component = ai_human.AddComponent(/datum/component/human_ai)
	ai_component?.ai_brain?.appraise_inventory(armor = TRUE)

	return ai_human
