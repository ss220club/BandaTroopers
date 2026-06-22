/datum/round_cinematics_session/intro
	var/datum/round_cinematics_intro_context/context

/datum/round_cinematics_session/intro/New(datum/round_cinematics_controller/controller, mob/owner, obj/structure/machinery/cryopod/source_pod, preview = FALSE)
	..(controller, owner, preview)
	src.source_pod = source_pod
	should_lock_sleeping = TRUE
	context = new /datum/round_cinematics_intro_context(owner, source_pod, preview)
	var/datum/round_cinematics_visual_profile/profile = GLOB.round_cinematics?.get_visual_profile(context.affiliation?.visual_profile_id || "intro_uscm")
	sequence = new /datum/round_cinematics_sequence/cryo_intro(context, profile)
	completion_reason = "intro complete"
	skip_allowed_at = world.time + (preview ? 0 : ROUND_CINEMATICS_INTRO_ALLOW_SKIP_AFTER)
	hard_timeout_at = world.time + ROUND_CINEMATICS_INTRO_HARD_TIMEOUT
