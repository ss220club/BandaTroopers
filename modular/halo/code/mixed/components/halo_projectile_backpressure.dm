#define HALO_PROJECTILE_QUEUE_SOFT_LIMIT 120
#define HALO_PROJECTILE_QUEUE_HARD_LIMIT 180

GLOBAL_VAR_INIT(halo_projectile_pressure_cache_time, -1)
GLOBAL_VAR_INIT(halo_projectile_pressure_cache_queue, 0)

/proc/halo_get_projectile_queue_length()
	if(GLOB.halo_projectile_pressure_cache_time != world.time)
		GLOB.halo_projectile_pressure_cache_time = world.time
		GLOB.halo_projectile_pressure_cache_queue = SSprojectiles.get_projectile_queue_length()

	return GLOB.halo_projectile_pressure_cache_queue

/proc/halo_is_projectile_queue_soft_limited(queued_projectiles_override = null)
	var/queued_projectiles = isnull(queued_projectiles_override) ? halo_get_projectile_queue_length() : queued_projectiles_override
	return queued_projectiles >= HALO_PROJECTILE_QUEUE_SOFT_LIMIT

/proc/halo_is_projectile_queue_hard_limited(queued_projectiles_override = null)
	var/queued_projectiles = isnull(queued_projectiles_override) ? halo_get_projectile_queue_length() : queued_projectiles_override
	return queued_projectiles >= HALO_PROJECTILE_QUEUE_HARD_LIMIT

/proc/halo_get_gun_combat_ammo(obj/item/weapon/gun/gun)
	if(!gun)
		return null

	if(gun.in_chamber?.ammo)
		return gun.in_chamber.ammo

	if(gun.current_mag?.current_rounds > 0)
		var/obj/item/ammo_magazine/magazine = gun.current_mag
		if(istype(magazine, /obj/item/ammo_magazine/internal))
			var/obj/item/ammo_magazine/internal/internal_magazine = magazine
			if(length(internal_magazine.chamber_contents) && internal_magazine.chamber_contents[internal_magazine.chamber_position] != "empty")
				var/datum/ammo/chambered_ammo = GLOB.ammo_list[internal_magazine.chamber_contents[internal_magazine.chamber_position]]
				if(istype(chambered_ammo))
					return chambered_ammo

		if(magazine.default_ammo)
			var/datum/ammo/default_mag_ammo = GLOB.ammo_list[magazine.default_ammo]
			if(istype(default_mag_ammo))
				return default_mag_ammo

	if(istype(gun.ammo))
		return gun.ammo

	return null

/proc/halo_should_backpressure_ai_only_gun_fire(obj/item/weapon/gun/gun, atom/firer_atom, atom/target_atom, queued_projectiles_override = null)
	return halo_should_backpressure_ai_only_projectile_fire(firer_atom, target_atom, halo_get_gun_combat_ammo(gun), queued_projectiles_override)

/proc/halo_should_backpressure_ai_only_projectile_fire(atom/firer_atom, atom/target_atom, datum/ammo/ammo_datum, queued_projectiles_override)
	if(!halo_is_projectile_pressure_relevant_ammo(ammo_datum))
		return FALSE

	if(!istype(firer_atom, /mob/living/carbon/human) || !istype(target_atom, /mob/living/carbon/human))
		return FALSE

	if(!halo_is_ai_only_combat_pair(firer_atom, target_atom))
		return FALSE

	return halo_is_projectile_queue_soft_limited(queued_projectiles_override)

/datum/component/halo_projectile_backpressure/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GUN_BEFORE_FIRE, PROC_REF(check_projectile_pressure))

/datum/component/halo_projectile_backpressure/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_GUN_BEFORE_FIRE)

/datum/component/halo_projectile_backpressure/proc/check_projectile_pressure(obj/item/weapon/gun/firing_weapon, obj/projectile/projectile_to_fire, atom/target, mob/living/user)
	SIGNAL_HANDLER

	var/atom/effective_target = projectile_to_fire?.original || target
	if(!halo_should_backpressure_ai_only_projectile_fire(user, effective_target, projectile_to_fire?.ammo, null))
		return NONE

	if(istype(firing_weapon))
		firing_weapon.last_fired = world.time

	halo_perf_bump_projectile_throttles()
	return COMPONENT_HARD_CANCEL_GUN_BEFORE_FIRE

#undef HALO_PROJECTILE_QUEUE_SOFT_LIMIT
#undef HALO_PROJECTILE_QUEUE_HARD_LIMIT
