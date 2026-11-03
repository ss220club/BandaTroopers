// Human AI perception API.
// Perception-owned projectile and detection helpers.

/datum/human_ai_brain/proc/clear_perception_detection_radius()
	var/datum/human_ai_module/perception/perception_module = get_perception_module()
	perception_module?.clear_detection_radius()
