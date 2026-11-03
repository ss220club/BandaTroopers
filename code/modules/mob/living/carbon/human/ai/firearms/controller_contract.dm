// Isolated Human AI firearm subsystem integration contract. Not included in colonialmarines.dme yet.

// Existing controller API this subsystem expects:
// - /datum/human_tied_controller/proc/can_ai_use_weapon(obj/item/weapon/weapon)
// - /datum/human_tied_controller/proc/get_ai_followup_fire_callback(obj/item/weapon/gun/weapon, atom/movable/current_target)
// - /datum/human_tied_controller/proc/get_ai_followup_fire_delay(obj/item/weapon/gun/weapon, atom/movable/current_target)
// - /datum/human_tied_controller/proc/get_ai_followup_fire_cooldown(obj/item/weapon/gun/weapon, atom/movable/current_target)
// - /datum/human_tied_controller/proc/unwield_weapon(obj/item/weapon/gun/weapon)
// - /datum/human_tied_controller/proc/swap_hand()
// - /datum/human_tied_controller/proc/drop_held_item(obj/item/item)
// - /datum/human_tied_controller/proc/start_weapon_fire(obj/item/weapon/gun/weapon, delay)
// - /datum/human_tied_controller/proc/start_weapon_unique_action(obj/item/weapon/weapon, delay)

// Controller API that must be added before wiring this subsystem into action code:
// - /datum/human_tied_controller/proc/ensure_weapon_safety_off(obj/item/weapon/gun/weapon)
// - /datum/human_tied_controller/proc/unload_weapon_for_reload(obj/item/weapon/gun/weapon)
// - /datum/human_tied_controller/proc/attackby_with_item(obj/item/target, obj/item/used_item)
// - /datum/human_tied_controller/proc/use_weapon_unique_action(obj/item/weapon/weapon)
// - /datum/human_tied_controller/proc/alt_click_item(obj/item/item)
// - /datum/human_tied_controller/proc/open_weapon_chamber(obj/item/weapon/gun/weapon)
// - weapon-specific controller bridges may be added in modular files when a module owns the weapon behavior.

// Boundaries for the future integration:
// - handlers choose weapon-specific behavior;
// - handlers may inspect firearm state;
// - equipment buckets are candidate sources only; handler can_reload_with() validates the actual item against the actual weapon;
// - handlers must not receive raw puppet/user arguments;
// - all mob/user side effects go through /datum/human_tied_controller.
