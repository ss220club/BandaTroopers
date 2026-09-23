/proc/round_cinematics_preview_target(client/C)
	var/mob/living/carbon/human/H = C?.mob
	if(!istype(H))
		return null
	return H

/client/proc/preview_cryo_intro()
	set name = "Preview Cryo Intro"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/H = round_cinematics_preview_target(src)
	if(!H)
		to_chat(src, SPAN_WARNING("You need a human body to preview the cryo intro."))
		return

	if(!GLOB.round_cinematics?.preview_cryo_intro(H))
		to_chat(src, SPAN_WARNING("Unable to start the cryo intro preview."))
		return

	var/admin_name = src.mob ? key_name_admin(src.mob) : "system"
	log_admin("[admin_name] previewed cryo intro for [key_name_admin(H)].")
	message_admins("[admin_name] previewed cryo intro for [key_name_admin(H)].")

/client/proc/preview_round_outro()
	set name = "Preview Round Outro"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	if(!round_cinematics_preview_target(src))
		to_chat(src, SPAN_WARNING("You need a human body to preview the round outro."))
		return

	if(!GLOB.round_cinematics?.preview_round_outro(src))
		to_chat(src, SPAN_WARNING("Unable to start the round outro preview."))
		return

	var/admin_name = src.mob ? key_name_admin(src.mob) : "system"
	log_admin("[admin_name] previewed round outro.")
	message_admins("[admin_name] previewed round outro.")

/client/proc/force_stop_round_cinematics()
	set name = "Force Stop Round Cinematics"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	GLOB.round_cinematics?.cleanup_all("admin_force_stop")
	var/admin_name = src.mob ? key_name_admin(src.mob) : "system"
	log_admin("[admin_name] forced round cinematics shutdown.")
	message_admins("[admin_name] forced round cinematics shutdown.")

/client/proc/set_round_outro_outcome_auto()
	set name = "Set Round Outro Outcome: Auto"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	GLOB.round_cinematics?.set_admin_outcome(ROUND_CINEMATICS_OUTCOME_AUTO, src.mob)

/client/proc/set_round_outro_outcome_marine_victory()
	set name = "Set Round Outro Outcome: Marine Victory"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	GLOB.round_cinematics?.set_admin_outcome(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY, src.mob)

/client/proc/set_round_outro_outcome_marine_defeat()
	set name = "Set Round Outro Outcome: Marine Defeat"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	GLOB.round_cinematics?.set_admin_outcome(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT, src.mob)

/client/proc/set_round_outro_outcome_inconclusive()
	set name = "Set Round Outro Outcome: Inconclusive"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	GLOB.round_cinematics?.set_admin_outcome(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE, src.mob)
