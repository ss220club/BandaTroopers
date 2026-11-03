/datum/human_ai_module/halo_covenant
	module_id = "halo_covenant"
	required_module_types = list(
		/datum/human_ai_module/targeting,
		/datum/human_ai_module/navigation,
		/datum/human_ai_module/inventory,
		/datum/human_ai_module/cover,
		/datum/human_ai_module/combat,
	)
	var/cached_threat_turf_time = -1
	var/atom/cached_threat_atom
	var/turf/cached_threat_turf
	var/ranged_fire_backoff_until = 0

/datum/human_ai_module/halo_unggoy
	module_id = "halo_unggoy"
	required_module_types = list(/datum/human_ai_module/halo_covenant, /datum/human_ai_module/squad)
	var/runtime = FALSE
	var/role
	var/panic_health_pct = 0
	var/panics_without_leader = FALSE
	var/ignore_panic = FALSE
	var/overheat_retreat = TRUE
	var/suicide_bomber = FALSE
	var/suicide_prime_range = 5
	var/cached_squad_anchor_time = -1
	var/turf/cached_squad_anchor

/datum/human_ai_module/halo_sangheili
	module_id = "halo_sangheili"
	required_module_types = list(/datum/human_ai_module/halo_covenant, /datum/human_ai_module/melee, /datum/human_ai_module/inventory, /datum/human_ai_module/guns)
	var/runtime = FALSE
	var/has_sword = FALSE
	var/sword_only = FALSE
	var/sword_charge_range = 5
	var/unarmed_commit_range = 2
	var/obj/item/weapon/covenant/energy_sword/drawn_sword
	var/sword_storage_loc
	var/melee_committed = FALSE
	var/obj/item/weapon/gun/committed_primary_weapon
	var/committed_tried_reload = FALSE
	var/committed_ignore_looting = FALSE
	var/cached_ranged_fallback_time = -1
	var/cached_ranged_fallback_available

/datum/human_ai_module_config/proc/modular_register_module_factory_types(list/module_factory_types)
	register_module_factory_type(module_factory_types, /datum/human_ai_module/halo_covenant)
	register_module_factory_type(module_factory_types, /datum/human_ai_module/halo_unggoy)
	register_module_factory_type(module_factory_types, /datum/human_ai_module/halo_sangheili)

/datum/human_ai_module_config/proc/modular_configure_module_lists(datum/human_ai_brain/brain)
	register_module_list_for_event(brain, HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR, list(/datum/human_ai_module/halo_covenant))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, list(/datum/human_ai_module/halo_covenant))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED, list(/datum/human_ai_module/halo_covenant))
