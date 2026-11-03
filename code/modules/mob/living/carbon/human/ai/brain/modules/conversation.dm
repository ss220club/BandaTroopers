/datum/human_ai_module/conversation
	module_id = "conversation"
	required_module_types = list(/datum/human_ai_module/combat)

	/// If TRUE, this AI is currently in a conversation with others
	var/in_conversation = FALSE
	/// The chance that the AI will try to initiate a conversation. Trying to initiate a conversation is on a 1 second cooldown, so this is really every 5 ticks
	/// Disabled until more conversations are added
	var/conversation_start_prob = 0 //0.75 // at 1 chance / sec, this'll mean we hit the equivalent of a 50% chance of a conversation at ~90 chances, which would take ~90 seconds
	COOLDOWN_DECLARE(conversation_start_cooldown)
	/// Cooldown upon a successful conversation, started on everyone involved at the end of the conversation
	COOLDOWN_DECLARE(conversation_success_cooldown)
	/// Length of the conversation success cooldown
	var/conversation_success_cooldown_time = 45 SECONDS

/datum/human_ai_module/conversation/proc/is_in_conversation()
	return in_conversation

/datum/human_ai_module/conversation/proc/is_owner_in_combat()
	return brain.is_in_combat()

/datum/human_ai_module/conversation/proc/can_try_start()
	if(!COOLDOWN_FINISHED(src, conversation_start_cooldown))
		return FALSE

	COOLDOWN_START(src, conversation_start_cooldown, 1 SECONDS)

	if(!can_participate())
		return FALSE

	return prob(conversation_start_prob)

/datum/human_ai_module/conversation/proc/can_participate()
	var/datum/human_tied_controller/controller = context?.controller
	if(!context?.can_continue())
		return FALSE

	if(is_owner_in_combat() || in_conversation || controller.is_health_below(HEALTH_THRESHOLD_CRIT))
		return FALSE

	return TRUE

/datum/human_ai_module/conversation/proc/can_continue()
	var/datum/human_tied_controller/controller = context?.controller
	if(!context?.can_continue())
		return FALSE

	if(is_owner_in_combat() || !is_in_conversation() || !controller || controller.is_health_below(HEALTH_THRESHOLD_CRIT))
		return FALSE

	return TRUE

/datum/human_ai_module/conversation/proc/try_start_conversation(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/list/ai_nearby = list()
	for(var/mob/living/carbon/human/nearby_human in controller.get_view(2))
		var/datum/human_ai_brain/other_brain = nearby_human.get_ai_brain()
		if(!other_brain?.can_participate_in_conversation())
			continue

		ai_nearby += other_brain

	if(length(ai_nearby) <= 1)
		return ONGOING_ACTION_COMPLETED

	var/datum/human_ai_conversation/picked_convo
	var/picked_index

	for(var/i = length(GLOB.human_ai_conversations), i > 1, i--)
		var/list/viable_conversations = list()
		for(var/datum/human_ai_conversation/convo as anything in GLOB.human_ai_conversations[i])
			if(!convo.conversation_allowed(brain))
				continue
			viable_conversations += convo

		if(!length(viable_conversations))
			continue

		picked_index = i
		picked_convo = pick(viable_conversations)

	if(length(ai_nearby) > picked_index)
		var/list/cut_down_ai_nearby = list()
		for(var/i in 1 to picked_index)
			cut_down_ai_nearby += pick_n_take(ai_nearby)
		ai_nearby = cut_down_ai_nearby

	var/datum/human_ai_conversation/gotten_convo = picked_convo
	INVOKE_ASYNC(gotten_convo, TYPE_PROC_REF(/datum/human_ai_conversation, initiate_conversation), ai_nearby)
	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/conversation/proc/start_conversation()
	in_conversation = TRUE

/datum/human_ai_module/conversation/proc/end_conversation(success = FALSE)
	in_conversation = FALSE
	if(success)
		COOLDOWN_START(src, conversation_success_cooldown, conversation_success_cooldown_time)
