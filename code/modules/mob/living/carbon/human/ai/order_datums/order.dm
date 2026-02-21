/datum/ai_order
	var/name = "You shouldn't see this"
	var/desc = ""
	var/list/datum/human_ai_brain/brains = list()
	var/should_display = TRUE

/datum/ai_order/New(list/arguments)
	. = ..()
	register_human_ai_runtime_order(src)

/datum/ai_order/Destroy(force, ...)
	unregister_human_ai_runtime_order(src)
	return ..()

/datum/ai_order/proc/tgui_data()
	return list()
