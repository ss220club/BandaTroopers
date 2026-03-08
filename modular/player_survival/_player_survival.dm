/datum/modpack/player_survival
	name = "player survival modpack"
	desc = "Player anti-gib and crit grace protection."
	author = "codex"

/datum/modpack/player_survival/initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(handle_player_survival_logged_in))

/datum/modpack/player_survival/proc/handle_player_survival_logged_in(subsystem, mob/logged_in_mob)
	SIGNAL_HANDLER

	if(!ishuman(logged_in_mob))
		return

	var/mob/living/carbon/human/human = logged_in_mob
	if(human.player_survival_admin_second_chance_pending)
		human.player_survival_apply_admin_second_chance()
