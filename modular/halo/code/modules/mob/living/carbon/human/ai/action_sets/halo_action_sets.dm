/datum/human_ai_action_set/halo_sangheili
	included_action_set_types = list(/datum/human_ai_action_set/default)
	action_whitelist = list(
		/datum/ai_action/sangheili_sword_charge,
		/datum/ai_action/sangheili_overheat_response,
		/datum/ai_action/sangheili_kick,
	)

/datum/human_ai_action_set/halo_unggoy
	included_action_set_types = list(/datum/human_ai_action_set/default)
	action_whitelist = list(/datum/ai_action/unggoy_panic_retreat)

/datum/human_ai_action_set/halo_unggoy_suicide_bomber
	action_whitelist = list(/datum/ai_action/unggoy_suicide_bomber)
	action_blacklist = list(/datum/ai_action/throw_grenade)
