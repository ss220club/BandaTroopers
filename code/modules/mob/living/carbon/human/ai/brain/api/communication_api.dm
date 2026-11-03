// Human AI communication API.
// Voice lines and squad/combat communication hooks.

/datum/human_ai_brain/proc/get_reload_line_chance()
	var/datum/human_ai_module/communication/communication_module = get_communication_module()
	return communication_module?.get_reload_line_chance() || 0

/datum/human_ai_brain/proc/set_reload_line_chance(new_chance)
	var/datum/human_ai_module/communication/communication_module = get_communication_module()
	communication_module?.set_reload_line_chance(new_chance)

/datum/human_ai_brain/proc/say_reload_line()
	var/datum/human_ai_module/communication/communication_module = get_communication_module()
	communication_module?.say_reload_line()

/datum/human_ai_brain/proc/say_grenade_thrown_line()
	var/datum/human_ai_module/communication/communication_module = get_communication_module()
	communication_module?.say_grenade_thrown_line()

/datum/human_ai_brain/proc/on_squad_member_death(mob/living/carbon/human/dead_mob)
	var/datum/human_ai_module/communication/communication_module = get_communication_module()
	communication_module?.on_squad_member_death(dead_mob)
