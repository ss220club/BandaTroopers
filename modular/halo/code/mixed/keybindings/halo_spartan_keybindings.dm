/datum/keybinding/human/lunge
	category = CATEGORY_HUMAN_COMBAT
	hotkey_keys = list("F")
	classic_keys = list("Unbound")
	name = "lunge"
	full_name = "Lunge"
	keybind_signal = COMSIG_KB_LUNGE_DOWN

/datum/keybinding/human/lunge/down(client/user)
	. = ..()
	if(.)
		return
	var/datum/action/human_action/activable/lunge/lunge_action = locate() in user.mob.actions
	if(lunge_action)
		lunge_action.action_activate()
		return TRUE

/datum/keybinding/human/fling
	category = CATEGORY_HUMAN_COMBAT
	hotkey_keys = list("V")
	classic_keys = list("Unbound")
	name = "fling"
	full_name = "Fling"
	keybind_signal = COMSIG_KB_FLING_DOWN

/datum/keybinding/human/fling/down(client/user)
	. = ..()
	if(.)
		return
	var/datum/action/human_action/activable/fling/fling_action = locate() in user.mob.actions
	if(fling_action)
		fling_action.action_activate()
		return TRUE

/datum/keybinding/human/punch
	category = CATEGORY_HUMAN_COMBAT
	hotkey_keys = list("G")
	classic_keys = list("Unbound")
	name = "punch"
	full_name = "Punch"
	keybind_signal = COMSIG_KB_PUNCH_DOWN

/datum/keybinding/human/punch/down(client/user)
	. = ..()
	if(.)
		return
	var/datum/action/human_action/activable/punch/punch_action = locate() in user.mob.actions
	if(punch_action)
		punch_action.action_activate()
		return TRUE

/datum/keybinding/human/strength
	category = CATEGORY_HUMAN_COMBAT
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "strength"
	full_name = "Strength"
	keybind_signal = COMSIG_KB_STRENGTH_DOWN

/datum/keybinding/human/strength/down(client/user)
	. = ..()
	if(.)
		return
	var/datum/action/human_action/activable/strength/strength_action = locate() in user.mob.actions
	if(strength_action)
		strength_action.action_activate()
		return TRUE

/datum/keybinding/living/jump
	hotkey_keys = list("C")
	classic_keys = list("Unbound")
	name = "jump"
	full_name = "Jump"
	description = "Jump."
	keybind_signal = COMSIG_KB_LIVING_JUMP_DOWN

/datum/keybinding/living/jump/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_JUMP_UP)
	return TRUE
