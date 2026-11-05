#define HUMAN_AI_OBSTACLE_PASS "pass"
#define HUMAN_AI_OBSTACLE_OPEN "open_door"
#define HUMAN_AI_OBSTACLE_PRY "pry_door"
#define HUMAN_AI_OBSTACLE_CLIMB_BARRICADE "climb_barricade"
#define HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE "climb_structure"
#define HUMAN_AI_OBSTACLE_DESTROY "destroy"
#define HUMAN_AI_OBSTACLE_MOB "mob"
#define HUMAN_AI_OBSTACLE_RULE_LIMIT 256

GLOBAL_DATUM_INIT(human_ai_obstacle_policy, /datum/human_ai_obstacle_policy, new)

/// Live shared policy, not copied on spawn. No UI or persistence dependency.
/datum/human_ai_obstacle_policy
	var/list/permissions
	var/list/type_permissions

/datum/human_ai_obstacle_policy/New(inherit = FALSE)
	permissions = list(
		HUMAN_AI_OBSTACLE_OPEN = TRUE,
		HUMAN_AI_OBSTACLE_PRY = TRUE,
		HUMAN_AI_OBSTACLE_CLIMB_BARRICADE = TRUE,
		HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE = TRUE,
		HUMAN_AI_OBSTACLE_DESTROY = TRUE,
	)
	if(inherit)
		for(var/action in permissions)
			permissions[action] = null
	type_permissions = list()

/// Validated entry point for future admin controls. Null restores inheritance.
/datum/human_ai_obstacle_policy/proc/set_permission(action, allowed, atom_type)
	if(!(action in permissions) || (!isnull(allowed) && allowed != TRUE && allowed != FALSE))
		return FALSE
	if(isnull(atom_type))
		permissions[action] = allowed
		return TRUE
	if(!ispath(atom_type, /atom))
		return FALSE
	if(!(atom_type in type_permissions))
		if(length(type_permissions) >= HUMAN_AI_OBSTACLE_RULE_LIMIT)
			return FALSE
		type_permissions[atom_type] = list()
	var/list/rules = type_permissions[atom_type]
	rules[action] = allowed
	return TRUE

/// Any matching deny wins over a grant on a narrower subtype.
/datum/human_ai_obstacle_policy/proc/type_permission(atom/obstacle, action)
	var/result
	for(var/atom_type in type_permissions)
		if(!istype(obstacle, atom_type))
			continue
		var/list/rules = type_permissions[atom_type]
		var/value = rules[action]
		if(isnull(value))
			continue
		if(!value)
			return FALSE
		result = TRUE
	return result

/atom
	/// Explicit protection is authoritative, including for unknown ownership.
	var/human_ai_navigation_protected = FALSE
	/// Optional per-instance action exceptions. Null entries inherit.
	var/list/human_ai_navigation_permissions

/atom/proc/set_human_ai_navigation_permission(action, allowed)
	if(!(action in GLOB.human_ai_obstacle_policy.permissions) || (!isnull(allowed) && allowed != TRUE && allowed != FALSE))
		return FALSE
	if(!human_ai_navigation_permissions)
		human_ai_navigation_permissions = list()
	human_ai_navigation_permissions[action] = allowed
	return TRUE

/datum/human_ai_brain/proc/obstacle_action_allowed(atom/obstacle, action)
	if(QDELETED(obstacle))
		return FALSE
	if(action == HUMAN_AI_OBSTACLE_PASS || action == HUMAN_AI_OBSTACLE_MOB)
		return TRUE
	if(!setting(action))
		return FALSE
	if(action == HUMAN_AI_OBSTACLE_DESTROY && obstacle.human_ai_destruction_protected(src))
		return FALSE
	var/datum/human_ai_obstacle_policy/shared_policy = GLOB.human_ai_obstacle_policy
	if(!(action in shared_policy.permissions))
		return FALSE
	var/global_type_rule = shared_policy.type_permission(obstacle, action)
	var/object_rule = obstacle.human_ai_navigation_permissions?[action]
	if((!isnull(global_type_rule) && !global_type_rule) || (!isnull(object_rule) && !object_rule))
		return FALSE
	if(object_rule || global_type_rule)
		return TRUE
	return !!shared_policy.permissions[action]

/atom/proc/human_ai_destruction_protected(datum/human_ai_brain/brain)
	return human_ai_navigation_protected

/obj/human_ai_destruction_protected(datum/human_ai_brain/brain)
	return ..() || unacidable || indestructible

/obj/structure/human_ai_destruction_protected(datum/human_ai_brain/brain)
	return ..() || unslashable
