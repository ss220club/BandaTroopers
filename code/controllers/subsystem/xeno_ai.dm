/datum/admins/proc/toggle_ai()
	set name = "Toggle xeno AI"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	var/new_state = FALSE
	var/datum/npc_ai_controller/xeno/xeno_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/xeno)
	if(xeno_controller)
		xeno_controller.ai_kill = !xeno_controller.ai_kill
		new_state = xeno_controller.ai_kill
	message_admins("[key_name_admin(usr)] [new_state ? "killed" : "revived"] all xeno AI.")
