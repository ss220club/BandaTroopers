/obj/item/device/binoculars/fire_support/proc/is_fire_support_enabled_by_rules()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(!rules)
		return TRUE
	return !!rules.fire_support_enabled
