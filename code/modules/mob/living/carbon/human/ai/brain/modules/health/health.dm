#define HUMAN_AI_TREATMENT_STAGE_BRUTE 1
#define HUMAN_AI_TREATMENT_STAGE_BLEED 2
#define HUMAN_AI_TREATMENT_STAGE_BONEBREAK 3
#define HUMAN_AI_TREATMENT_STAGE_BURN 4
#define HUMAN_AI_TREATMENT_STAGE_PAIN 5
#define HUMAN_AI_TREATMENT_STAGE_TOX 6
#define HUMAN_AI_TREATMENT_STAGE_OXY 7

#define HUMAN_AI_TREATMENT_URGENCY_STABLE 1
#define HUMAN_AI_TREATMENT_URGENCY_SEVERE 2
#define HUMAN_AI_TREATMENT_URGENCY_CRITICAL 3

/datum/human_ai_module/health
	module_id = "health"
	required_module_types = list(/datum/human_ai_module/faction, /datum/human_ai_module/profile, /datum/human_ai_module/targeting, /datum/human_ai_module/inventory)

	/// At what percentage of max HP to start searching for medical treatment
	var/healing_start_threshold = 0.7
	/// At what percentage of max HP a non-critical AI should seek cover before treating in combat.
	var/tactical_treatment_health_threshold = 0.5
	/// Requires this much damage of one type to consider it a problem
	var/damage_problem_threshold = 5
	/// Pain percentage (out of 100) for the AI to consider using painkillers
	var/pain_percentage_threshold = 1

	/// Are we currently treating someone?
	var/healing_someone = FALSE
	var/treatment_generation = 0 // SS220 EDIT: cancellation invalidates every suspended frame of this treatment
	/// Patient currently reserved by this health module.
	var/mob/living/carbon/human/current_treatment_target

	/// Reference for found injured ally
	var/mob/living/carbon/human/found_injured_ally
	/// Current ally selected by the treat ally action.
	var/mob/living/carbon/human/active_ally_treatment_target

	/// Cooldown on using pills to avoid OD. This isn't the best solution as it prevents the AI from using more than 1 pill of any kind every 20s, but it'll work for now
	COOLDOWN_DECLARE(pill_use_cooldown)
	/// How long to wait before repeating pill-based treatment for the same patient and treatment stage.
	var/pill_treatment_effect_wait = 45 SECONDS
	/// How long to wait before repeating injected reagent treatment for the same patient and treatment stage.
	var/injected_treatment_effect_wait = 15 SECONDS
	/// Patient-stage treatment repeat locks. Keyed by patient ref and treatment stage.
	var/list/recent_patient_treatments = list()

	/// How many stacks of "wasn't able to treat" this AI has. If these stacks pass a certain threshold, the AI can no longer be treated by others for a small period of time. Stacks decay when not being accumulated
	var/cant_be_treated_stacks = 0

	/// How many stacks are required to stop this AI from recieving treatment
	var/treatment_stack_threshold = 10

/datum/human_ai_module/health/Destroy(force, ...)
	cancel_treatment() // SS220 EDIT: invalidate sleeping work before clearing the owning brain
	lose_injured_ally()
	return ..()

/datum/human_ai_module/health/reset_module()
	cancel_treatment() // SS220 EDIT: reset invalidates suspended treatment before clearing actions
	active_ally_treatment_target = null
	lose_injured_ally()
	recent_patient_treatments = list()

/datum/human_ai_module/health/suspend_module(clear_inventory = FALSE)
	active_ally_treatment_target = null
	lose_injured_ally()
	cancel_treatment() // SS220 EDIT: resumed AI must not inherit an old treatment continuation
	recent_patient_treatments = list()

/datum/human_ai_module/health/proc/is_treating()
	return healing_someone

/datum/human_ai_module/health/proc/can_retry_self_treatment()
	return cant_be_treated_stacks < treatment_stack_threshold

/datum/human_ai_module/health/proc/can_continue_health_work()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/health/proc/is_owner_friendly_target(atom/target)
	return brain.is_friendly_target(target)

/datum/human_ai_module/health/proc/get_owner_view_distance()
	return brain.get_view_distance()

/datum/human_ai_module/health/proc/has_owner_current_target()
	return brain.has_current_target()

/datum/human_ai_module/health/proc/has_owner_offscreen_fire_target()
	return brain.has_offscreen_fire_target()

/datum/human_ai_module/health/proc/is_owner_in_combat()
	return brain.is_in_combat()

/datum/human_ai_module/health/proc/find_owner_usable_treatment_item(list/item_types, mob/living/carbon/human/target)
	RETURN_TYPE(/obj/item)
	return brain.find_usable_equipment_by_type_list(item_types, HUMAN_AI_HEALTHITEMS, target)

/datum/human_ai_module/health/proc/clear_owner_main_hand()
	return brain.clear_main_hand()

/datum/human_ai_module/health/proc/equip_owner_treatment_item(obj/item/item)
	return brain.equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, item)

/datum/human_ai_module/health/proc/get_owner_action_delay()
	return brain.get_action_delay()

/datum/human_ai_module/health/proc/get_owner_storage_slot_for_item(obj/item/item)
	return brain.storage_has_room(item)

/datum/human_ai_module/health/proc/store_owner_treatment_item(obj/item/item, storage_slot)
	return brain.store_item(item, storage_slot, HUMAN_AI_HEALTHITEMS)

/datum/human_ai_module/health/proc/increment_treatment_stacks()
	if(!can_continue_health_work())
		return

	cant_be_treated_stacks++
	addtimer(CALLBACK(src, PROC_REF(clear_treatment_stacks)), 5 SECONDS, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/datum/human_ai_module/health/proc/clear_treatment_stacks()
	if(QDELETED(src) || !can_continue_health_work())
		return

	cant_be_treated_stacks = 0
