/datum/admins/proc/toggle_human_ai()
	set name = "Toggle Human AI"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	var/new_state = FALSE
	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/human)
	if(human_controller)
		human_controller.ai_kill = !human_controller.ai_kill
		new_state = human_controller.ai_kill
	message_admins("[key_name_admin(usr)] [new_state ? "killed" : "revived"] all human AI.")
