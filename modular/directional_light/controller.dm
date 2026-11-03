/// Opt-in is intentionally narrower than all luminous items.
/atom
	var/directional_beam_enabled = FALSE
	var/directional_beam_mouse_aim = TRUE

/obj/item/device/flashlight
	directional_beam_enabled = TRUE

/obj/item/device/flashlight/lamp
	directional_beam_enabled = FALSE

/obj/item/device/flashlight/lantern
	directional_beam_enabled = FALSE

/obj/item/device/flashlight/flare
	directional_beam_enabled = FALSE

/obj/item/device/flashlight/slime
	directional_beam_enabled = FALSE

/obj/item/device/flashlight/pen
	directional_beam_enabled = FALSE

/obj/item/device/flashlight/drone
	directional_beam_enabled = FALSE

/obj/item/weapon/gun
	directional_beam_enabled = TRUE

/obj/item/clothing/head/helmet/marine
	directional_beam_enabled = TRUE

/obj/item/clothing/head/hardhat
	directional_beam_enabled = TRUE

/obj/item/clothing/suit/marine
	directional_beam_enabled = TRUE
	directional_beam_mouse_aim = FALSE

/obj/item/clothing/suit/storage/marine
	directional_beam_enabled = TRUE
	directional_beam_mouse_aim = FALSE

/datum/component/directional_beam
	var/datum/dynamic_light_source/emitter
	var/beam_angle = 0
	var/last_event_state = "off"
	var/mob/living/watched_holder
	var/client/watched_client
	/// Lifecycle/parameters dominate any coalesced aim-only request.
	var/full_update_pending = TRUE

/datum/component/directional_beam/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/source = parent
	beam_angle = dir2angle(source.dir)

/datum/component/directional_beam/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_ON, PROC_REF(on_toggle))
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT, PROC_REF(wake))
	RegisterSignal(parent, list(COMSIG_ATOM_SET_LIGHT_RANGE, COMSIG_ATOM_SET_LIGHT_POWER, COMSIG_ATOM_SET_LIGHT_COLOR), PROC_REF(wake))
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(wake))
	wake()

/datum/component/directional_beam/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_SET_LIGHT_ON, COMSIG_ATOM_SET_LIGHT, COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED))
	UnregisterSignal(parent, list(COMSIG_ATOM_SET_LIGHT_RANGE, COMSIG_ATOM_SET_LIGHT_POWER, COMSIG_ATOM_SET_LIGHT_COLOR))
	watch_holder(null)
	STOP_PROCESSING(SSdirectional_light, src)
	QDEL_NULL(emitter)
	return ..()

/datum/component/directional_beam/Destroy()
	watch_holder(null)
	STOP_PROCESSING(SSdirectional_light, src)
	QDEL_NULL(emitter)
	return ..()

/datum/component/directional_beam/proc/wake()
	SIGNAL_HANDLER
	var/obj/item/source = parent
	if(!source.light_on)
		// set_light(0) assigns light_on before signaling, unlike set_light_on().
		stop_emission()
		return
	full_update_pending = TRUE
	START_PROCESSING(SSdirectional_light, src)

/// Both light APIs must release the emitter and all carrier subscriptions when off.
/datum/component/directional_beam/proc/stop_emission()
	watch_holder(null)
	STOP_PROCESSING(SSdirectional_light, src)
	QDEL_NULL(emitter)
	full_update_pending = FALSE
	last_event_state = "off"

/datum/component/directional_beam/proc/wake_aim()
	SIGNAL_HANDLER
	// Stored items need lifecycle/movement notifications, not mouse or facing work.
	if(emitter)
		START_PROCESSING(SSdirectional_light, src)

/// Subscribe to the current carrier, never to a global mob scan.
/datum/component/directional_beam/proc/watch_holder(mob/living/holder)
	var/client/new_client = holder?.client
	if(watched_client != new_client)
		if(watched_client)
			UnregisterSignal(watched_client, COMSIG_CLIENT_RESET_VIEW)
		watched_client = new_client
		if(watched_client)
			RegisterSignal(watched_client, COMSIG_CLIENT_RESET_VIEW, PROC_REF(wake))
	if(watched_holder == holder)
		return
	if(watched_holder)
		UnregisterSignal(watched_holder, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_MOB_CHANGE_VIEW, "directional_light_aim"))
	watched_holder = holder
	if(holder)
		RegisterSignal(holder, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT), PROC_REF(wake))
		RegisterSignal(holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(wake_aim))
		var/obj/item/source = parent
		if(source.directional_beam_mouse_aim)
			RegisterSignal(holder, list(COMSIG_MOB_CHANGE_VIEW, "directional_light_aim"), PROC_REF(wake_aim))

/datum/component/directional_beam/proc/on_toggle(datum/source, enabled)
	SIGNAL_HANDLER
	if(enabled)
		full_update_pending = TRUE
		// Setters signal before assignment. Render even a one-tick muzzle flash immediately.
		process(0, TRUE)
		STOP_PROCESSING(SSdirectional_light, src)
	else
		stop_emission()

/// Publish movement immediately; completed shadow work must not repeat in the queue.
/datum/component/directional_beam/proc/sync_position()
	if(!emitter)
		return
	var/obj/item/source = parent
	var/turf/destination = get_turf(source)
	if(!destination)
		return
	var/same_container = emitter.cached_loc == source.loc
	if(destination != emitter.source_turf)
		var/turf/previous = emitter.source_turf
		var/atom/movable/lighting_mask/flashlight_60/beam_mask = emitter.our_mask
		beam_mask.movement_shadow_pending = TRUE
		beam_mask.queue_mask_update()
		if(SSlighting.initialized)
			beam_mask.calculate_lighting_shadows()
			if(!beam_mask.awaiting_update)
				SSlighting.mask_queue -= beam_mask
		// Initialization can yield while consuming the queue; leave it untouched.
		else if(!previous || previous.z != destination.z || get_dist(previous, destination) > 1)
			emitter.mask_holder.moveToNullspace()
	if(!same_container)
		emitter.find_containing_atom()
	emitter.source_turf = destination
	emitter.cached_loc = source.loc

/datum/component/directional_beam/process(delta_time, force_on = FALSE)
	var/obj/item/source = parent
	if(!force_on && !full_update_pending && emitter && source.light_on)
		update_aim()
		return PROCESS_KILL
	full_update_pending = FALSE
	if(!source.light_on && !force_on)
		stop_emission()
		return PROCESS_KILL
	var/mob/living/holder = isliving(source.loc) ? source.loc : null
	watch_holder(holder)
	var/usable = isturf(source.loc)
	if(holder && isturf(holder.loc))
		usable = holder.is_holding(source)
		if(ishuman(holder))
			var/mob/living/carbon/human/human_holder = holder
			usable = usable || human_holder.head == source || human_holder.wear_suit == source
	if(!usable || !get_turf(source))
		QDEL_NULL(emitter)
		last_event_state = "stored"
		return PROCESS_KILL
	var/beam_range = 10
	if(isgun(source))
		var/obj/item/weapon/gun/gun = source
		if(!(gun.flags_gun_features & GUN_FLASHLIGHT_ON))
			beam_range = clamp(gun.light_range, 0, 10)
	if(beam_range <= 0)
		QDEL_NULL(emitter)
		return PROCESS_KILL
	if(!emitter)
		emitter = new /datum/dynamic_light_source(source, /atom/movable/lighting_mask/flashlight_60)
	else if(emitter.source_turf != get_turf(source) || emitter.cached_loc != source.loc)
		sync_position()
	emitter.source_turf = get_turf(source)
	emitter.cached_loc = source.loc
	emitter.set_light(beam_range, 8, source.light_color)
	update_aim()
	var/atom/movable/lighting_mask/flashlight_60/mask = emitter.our_mask
	mask.ensure_shadows_ready()
	return PROCESS_KILL

/datum/component/directional_beam/proc/update_aim()
	var/obj/item/source = parent
	var/mob/living/holder = watched_holder
	if(holder)
		var/aim_with_mouse = source.directional_beam_mouse_aim && holder.client
		beam_angle = aim_with_mouse ? holder.client.directional_light_angle(holder) : dir2angle(holder.dir)
		last_event_state = aim_with_mouse ? holder.client.directional_light_event : "body facing"
	else
		beam_angle = dir2angle(source.dir)
		last_event_state = "floor"
	var/desired_angle = beam_angle - 180
	var/angle_delta = abs(desired_angle - emitter.our_mask.current_angle)
	// DM's % truncates fractions; preserve sub-degree values across the seam.
	angle_delta -= round(angle_delta / 360) * 360
	angle_delta = min(angle_delta, 360 - angle_delta)
	var/mouse_aim = holder?.client && source.directional_beam_mouse_aim && holder.client.directional_light_params
	if(angle_delta && (!mouse_aim || angle_delta >= 1))
		emitter.our_mask.rotate(desired_angle)
