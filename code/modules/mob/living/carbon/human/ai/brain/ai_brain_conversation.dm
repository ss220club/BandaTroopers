GLOBAL_LIST_INIT(human_ai_conversations, initialize_human_ai_conversations())

/// Populates the AI conversation data structure
/proc/initialize_human_ai_conversations()
	var/list/return_list = list()
	for(var/datum/human_ai_conversation/subtype_convo as anything in subtypesof(/datum/human_ai_conversation))
		if(subtype_convo::amount_ai_involved == -1)
			continue

		var/datum/human_ai_conversation/new_convo = new subtype_convo
		if(new_convo.amount_ai_involved > length(return_list))
			return_list.len = new_convo.amount_ai_involved
			for(var/i in length(return_list) + 1 to new_convo.amount_ai_involved)
				return_list[i] = list()
		return_list[new_convo.amount_ai_involved] += list(new_convo)
	return return_list

/datum/human_ai_conversation
	/// How many AI are involved in this conversation. If -1, this conversation is abstract.
	var/amount_ai_involved = -1
	/// P#: The AI of that number (randomly assigned when conversation is created) will say the message after the P#.
	/// You can use || to divide one message into multiple that the AI will randomly choose between.
	/// D #: Will delay the conversation for however many deciseconds listed.
	var/list/conversation_data = list(
		"P1 Message 1",
		"D 25",
		"P2 Message 2",
		"D 25",
		"P1 Random||Chance||Messages"
	)

/datum/human_ai_conversation/proc/get_conversation_module(datum/human_ai_brain/brain)
	RETURN_TYPE(/datum/human_ai_module/conversation)
	var/datum/human_ai_context/module_context = brain?.create_context()
	if(!module_context?.can_continue())
		qdel(module_context)
		return null
	var/datum/human_ai_module/conversation/conversation = module_context?.get_module(/datum/human_ai_module/conversation)
	qdel(module_context)
	return conversation

/datum/human_ai_conversation/proc/end_conversation_for_brains(list/brains_involved, finished = FALSE)
	for(var/datum/human_ai_brain/conversation_brain as anything in brains_involved)
		var/datum/human_ai_module/conversation/conversation = get_conversation_module(conversation_brain)
		conversation?.end_conversation(finished)

/datum/human_ai_conversation/proc/can_continue_for_brains(list/brains_involved)
	if(!length(brains_involved))
		return FALSE

	for(var/datum/human_ai_brain/conversation_brain as anything in brains_involved)
		if(should_interrupt_conversation(conversation_brain))
			return FALSE
	return TRUE

/// Processes a conversation with other nearby AI.
/datum/human_ai_conversation/proc/initiate_conversation(list/brains_involved)
	if(!length(brains_involved))
		return

	var/list/valid_brains = list()
	for(var/datum/human_ai_brain/brain as anything in brains_involved)
		if(!get_conversation_module(brain))
			continue
		valid_brains += brain

	brains_involved = valid_brains
	if(!length(brains_involved))
		return
	if(!can_continue_for_brains(brains_involved))
		return

	for(var/datum/human_ai_brain/brain as anything in brains_involved)
		var/datum/human_ai_module/conversation/conversation = get_conversation_module(brain)
		conversation?.start_conversation()

	for(var/string in conversation_data)
		switch(string[1])
			if("P")
				var/ai_index = text2num(string[2]) // doesn't currently support indexes >9, but can be fixed if that ever comes up, somehow
				var/datum/human_ai_brain/brain = brains_involved[ai_index]
				if(!can_continue_for_brains(brains_involved) || should_interrupt_conversation(brain))
					end_conversation_for_brains(brains_involved)
					return

				var/datum/human_ai_context/speaker_context = brain.create_context()
				if(!speaker_context.can_continue())
					qdel(speaker_context)
					end_conversation_for_brains(brains_involved)
					return
				var/datum/human_tied_controller/speaker_controller = speaker_context.controller
				if(!speaker_controller)
					qdel(speaker_context)
					end_conversation_for_brains(brains_involved)
					return

				for(var/datum/human_ai_brain/other_brain as anything in brains_involved)
					if(brain == other_brain)
						continue
					var/datum/human_ai_context/listener_context = other_brain.create_context()
					if(listener_context.can_continue())
						listener_context.controller?.turn_to_conversation_partner(speaker_controller)
					qdel(listener_context)

				if(!can_continue_for_brains(brains_involved))
					qdel(speaker_context)
					end_conversation_for_brains(brains_involved)
					return
				speaker_controller.say(pick(splittext(copytext(string, 4), "||")))
				qdel(speaker_context)

			if("D")
				sleep(text2num(copytext(string, 3)))
				if(!can_continue_for_brains(brains_involved))
					end_conversation_for_brains(brains_involved)
					return

	end_conversation_for_brains(brains_involved, TRUE)

/// Simple check to see if a conversation should stop at a given line
/datum/human_ai_conversation/proc/should_interrupt_conversation(datum/human_ai_brain/brain)
	if(!brain)
		return TRUE

	return !brain.can_continue_conversation()

/// Check to be overridden to see if an AI should be able to start a conversation
/datum/human_ai_conversation/proc/conversation_allowed(datum/human_ai_brain/brain)
	return TRUE

/datum/human_ai_conversation/hello
	amount_ai_involved = 2
	conversation_data = list(
		"P1 Hello.",
		"D 16",
		"P2 Hello.",
		"D 25",
		"P1 How are you doing?",
		"D 25",
		"P2 I'm doing well, how are you?||Could be better, you?||Fine, I guess. How about you?",
		"D 15",
		"P1 I'm doin' pretty alright.",
	)

/datum/human_ai_conversation/smoke
	amount_ai_involved = 2
	conversation_data = list(
		"P1 Hey, got a smoke?",
		"D 20",
		"P2 Nah, sorry man.",
		"D 22",
		"P1 Damn.",
	)

/datum/human_ai_conversation/faction
	/// What faction(s) can say this line.
	var/list/acceptable_factions

/datum/human_ai_conversation/faction/conversation_allowed(datum/human_ai_brain/brain)
	var/datum/human_ai_context/context = brain.create_context()
	if(!context.can_continue())
		qdel(context)
		return FALSE
	var/datum/human_tied_controller/controller = context.controller
	if(controller?.faction_in(acceptable_factions))
		qdel(context)
		return ..()
	qdel(context)
	return FALSE
