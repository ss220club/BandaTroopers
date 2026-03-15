GLOBAL_DATUM_INIT(rto_support_registry, /datum/rto_support_registry, new)

/// Registry for RTO support controllers.
/datum/rto_support_registry
	/// Lookup storage keyed by owner identity.
	var/list/controllers = list()
	/// Immutable support template instances shared by all controllers.
	var/list/template_catalog = list()
	/// Template lookup keyed by stable template id.
	var/list/template_by_id = list()

/datum/rto_support_registry/New()
	. = ..()
	initialize_template_catalog()

/datum/rto_support_registry/Destroy()
	clear_controllers()
	clear_template_catalog()
	controllers = null
	template_catalog = null
	template_by_id = null
	return ..()

/// Returns a controller bound to a human.
/datum/rto_support_registry/proc/get_controller(mob/living/carbon/human/human)
	if(!human)
		return null
	var/datum/rto_support_controller/controller = controllers[human]
	if(controller && !QDELETED(controller))
		return controller
	controllers -= human
	return null

/// Ensures a controller exists for a human.
/datum/rto_support_registry/proc/ensure_controller(mob/living/carbon/human/human)
	if(!human || QDELETED(human))
		return null
	if(GET_DEFAULT_ROLE(human.job) != JOB_SQUAD_RTO)
		return null
	var/datum/rto_support_controller/controller = get_controller(human)
	if(controller)
		controller.ensure_runtime()
		return controller
	controller = new(human)
	controllers[human] = controller
	register_owner_signals(human)
	controller.ensure_runtime()
	return controller

/// Removes a controller bound to a human.
/datum/rto_support_registry/proc/remove_controller(mob/living/carbon/human/human)
	if(!human)
		return FALSE
	var/datum/rto_support_controller/controller = controllers[human]
	controllers -= human
	if(controller)
		qdel(controller)
	unregister_owner_signals(human)
	return TRUE

/// Clears all tracked controllers.
/datum/rto_support_registry/proc/clear_controllers()
	if(!length(controllers))
		return FALSE
	for(var/mob/living/carbon/human/human as anything in controllers)
		remove_controller(human)
	return TRUE

/datum/rto_support_registry/proc/initialize_template_catalog()
	if(length(template_catalog))
		return FALSE
	template_catalog = list(
		new /datum/rto_support_template/mortar,
		new /datum/rto_support_template/cas,
		new /datum/rto_support_template/heavy,
		new /datum/rto_support_template/logistics,
	)
	template_by_id = list()
	for(var/datum/rto_support_template/template as anything in template_catalog)
		if(!template?.template_id)
			continue
		template_by_id[template.template_id] = template
	return TRUE

/datum/rto_support_registry/proc/clear_template_catalog()
	if(length(template_catalog))
		for(var/datum/rto_support_template/template as anything in template_catalog)
			qdel(template)
	template_catalog = list()
	template_by_id = list()
	return TRUE

/datum/rto_support_registry/proc/get_template_catalog()
	if(!length(template_catalog))
		initialize_template_catalog()
	return template_catalog.Copy()

/datum/rto_support_registry/proc/find_template(template_id)
	if(!length(template_by_id))
		initialize_template_catalog()
	return template_by_id[template_id]

/datum/rto_support_registry/proc/propagate_rules_update()
	if(!length(controllers))
		return FALSE
	for(var/mob/living/carbon/human/human as anything in controllers)
		var/datum/rto_support_controller/controller = get_controller(human)
		controller?.apply_rules_update()
	return TRUE

/datum/rto_support_registry/proc/handle_owner_deleted(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	remove_controller(human)

/datum/rto_support_registry/proc/handle_owner_death(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_owner_death()

/datum/rto_support_registry/proc/handle_owner_revived(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_owner_revived()

/datum/rto_support_registry/proc/handle_owner_item_equipped(mob/living/carbon/human/human, obj/item/changed_item, slot)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_inventory_changed(changed_item, slot, COMSIG_HUMAN_EQUIPPED_ITEM)

/datum/rto_support_registry/proc/handle_owner_item_unequipped(mob/living/carbon/human/human, obj/item/changed_item, slot)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_inventory_changed(changed_item, slot, COMSIG_HUMAN_UNEQUIPPED_ITEM)

/datum/rto_support_registry/proc/handle_owner_item_picked_up(mob/living/carbon/human/human, obj/item/changed_item)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_inventory_changed(changed_item, null, COMSIG_MOB_PICKUP_ITEM)

/datum/rto_support_registry/proc/handle_owner_item_dropped(mob/living/carbon/human/human, obj/item/changed_item)
	SIGNAL_HANDLER
	var/datum/rto_support_controller/controller = get_controller(human)
	controller?.handle_inventory_changed(changed_item, null, COMSIG_MOB_ITEM_DROPPED)

/datum/rto_support_registry/proc/register_owner_signals(mob/living/carbon/human/human)
	if(!human)
		return FALSE
	RegisterSignal(human, COMSIG_PARENT_QDELETING, PROC_REF(handle_owner_deleted))
	RegisterSignal(human, COMSIG_MOB_DEATH, PROC_REF(handle_owner_death))
	RegisterSignal(human, COMSIG_HUMAN_REVIVED, PROC_REF(handle_owner_revived))
	RegisterSignal(human, COMSIG_HUMAN_EQUIPPED_ITEM, PROC_REF(handle_owner_item_equipped))
	RegisterSignal(human, COMSIG_HUMAN_UNEQUIPPED_ITEM, PROC_REF(handle_owner_item_unequipped))
	RegisterSignal(human, COMSIG_MOB_PICKUP_ITEM, PROC_REF(handle_owner_item_picked_up))
	RegisterSignal(human, COMSIG_MOB_ITEM_DROPPED, PROC_REF(handle_owner_item_dropped))
	return TRUE

/datum/rto_support_registry/proc/unregister_owner_signals(mob/living/carbon/human/human)
	if(!human)
		return FALSE
	UnregisterSignal(human, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_MOB_DEATH,
		COMSIG_HUMAN_REVIVED,
		COMSIG_HUMAN_EQUIPPED_ITEM,
		COMSIG_HUMAN_UNEQUIPPED_ITEM,
		COMSIG_MOB_PICKUP_ITEM,
		COMSIG_MOB_ITEM_DROPPED,
	))
	return TRUE
