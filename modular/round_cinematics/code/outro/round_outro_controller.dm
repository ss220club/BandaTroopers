/datum/round_cinematics_session/outro
	var/datum/round_cinematics_outro_context/context

/datum/round_cinematics_session/outro/New(datum/round_cinematics_controller/controller, client/owner_client, datum/round_cinematics_outro_context/context, preview = FALSE)
	..(controller, owner_client?.mob, preview)
	client = owner_client
	src.context = context
	var/datum/round_cinematics_visual_profile/profile
	if(context?.outcome)
		switch(context.outcome.id)
			if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
				profile = GLOB.round_cinematics?.get_visual_profile("outro_victory")
			if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
				profile = GLOB.round_cinematics?.get_visual_profile("outro_defeat")
			if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
				profile = GLOB.round_cinematics?.get_visual_profile("outro_inconclusive")
			else
				profile = GLOB.round_cinematics?.get_visual_profile("outro_inconclusive")
	sequence = new /datum/round_cinematics_sequence/round_outro(context, profile)
	completion_reason = "outro complete"
	skip_allowed_at = world.time
