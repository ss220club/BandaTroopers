/datum/custom_hud
	var/UI_MOTION_LOC = "EAST-1:28,10:20"

/datum/hud
	var/atom/movable/screen/motion_sensor/motion_sensor

/datum/hud/proc/draw_motion_sensor(datum/custom_hud/ui_datum, ui_alpha)
	motion_sensor = new /atom/movable/screen/motion_sensor()
	motion_sensor.screen_loc = ui_datum.UI_MOTION_LOC
	infodisplay += motion_sensor

/datum/hud/human/Destroy()
	if(motion_sensor)
		infodisplay -= motion_sensor
		QDEL_NULL(motion_sensor)
	return ..()

/atom/movable/screen/motion_sensor
	name = "motion sensor"
	icon = 'icons/halo/mob/hud/motion_sensor.dmi'
	icon_state = "base"
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/shape/ellipse/circle/range_bounds
	var/iff_signal = FACTION_UNSC
	var/friendly_color = "#ddff00"
	var/hostile_color = "#d30000"
	var/radius = 16
	var/mob/our_mob

/atom/movable/screen/motion_sensor/Initialize(mapload, ...)
	. = ..()
	range_bounds = new()
	color = "#0080ae"

/atom/movable/screen/motion_sensor/Destroy()
	remove()
	range_bounds = null
	return ..()

/atom/movable/screen/motion_sensor/proc/give(mob/new_mob)
	our_mob = new_mob
	alpha = 255
	mouse_opacity = MOUSE_OPACITY_ICON
	if(!(src in SSfastobj.processing))
		START_PROCESSING(SSfastobj, src)

/atom/movable/screen/motion_sensor/proc/remove()
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	overlays.Cut()
	our_mob = null
	if(src in SSfastobj.processing)
		STOP_PROCESSING(SSfastobj, src)

/atom/movable/screen/motion_sensor/proc/configure(iff = FACTION_UNSC, background_color = "#0080ae", friendly_color = "#ddff00", enemy_color = "#d30000")
	src.iff_signal = iff
	src.color = background_color
	src.friendly_color = friendly_color
	src.hostile_color = enemy_color

/atom/movable/screen/motion_sensor/process(delta_time)
	if(!our_mob?.client)
		remove()
		return

	var/turf/cur_turf = get_turf(our_mob)
	dir = our_mob.dir
	if(!istype(cur_turf))
		return

	overlays.Cut()
	range_bounds.set_shape(cur_turf.x, cur_turf.y, radius)
	var/list/ping_candidates = SSquadtree.players_in_range(range_bounds, cur_turf.z, QTREE_EXCLUDE_OBSERVER | QTREE_SCAN_MOBS)

	for(var/obj/vehicle/multitile/vehicle as anything in GLOB.all_multi_vehicles)
		if(vehicle.z != cur_turf.z || !range_bounds.contains_atom(vehicle))
			continue
		var/image/vehicle_blip = image(icon, src, "blip_vehicle")
		if(!vehicle.vehicle_faction)
			vehicle_blip.color = "#ffffff"
		else if(vehicle.get_target_lock(iff_signal))
			vehicle_blip.color = friendly_color
		else
			vehicle_blip.color = hostile_color
		vehicle_blip.alpha = 128
		vehicle_blip.pixel_x = vehicle.x - cur_turf.x
		vehicle_blip.pixel_y = vehicle.y - cur_turf.y
		vehicle_blip.appearance_flags = RESET_COLOR
		overlays += vehicle_blip

	for(var/mob/living/living_mob as anything in ping_candidates)
		if(!living_mob.x || !living_mob.y || HAS_TRAIT(living_mob, TRAIT_CLOAKED) || living_mob.stat == DEAD)
			continue

		var/blip_state = "blip"
		if(living_mob.mob_size >= MOB_SIZE_BIG)
			blip_state = "blip_large"
		else if(living_mob.mob_size < MOB_SIZE_HUMAN || living_mob.mob_size == MOB_SIZE_XENO_VERY_SMALL)
			blip_state = "blip_small"

		var/image/mob_blip = image(icon, src, blip_state)
		if(living_mob.get_target_lock(iff_signal))
			mob_blip.color = friendly_color
		else
			mob_blip.color = hostile_color
		mob_blip.pixel_x = living_mob.x - cur_turf.x + round((living_mob.pixel_x + living_mob.pixel_w) / world.icon_size, 1)
		mob_blip.pixel_y = living_mob.y - cur_turf.y + round((living_mob.pixel_y + living_mob.pixel_z) / world.icon_size, 1)
		mob_blip.appearance_flags = RESET_COLOR
		overlays += mob_blip

/datum/component/halo_motion_sensor_manager
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/datum/action/item_action/halo_motion_sensor/sensor_action

/datum/component/halo_motion_sensor_manager/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/halo_motion_sensor_manager/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_unequipped))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(on_unequipped))
	sensor_action = new /datum/action/item_action/halo_motion_sensor(parent)
	RegisterSignal(sensor_action, COMSIG_ACTION_ACTIVATED, PROC_REF(toggle))

/datum/component/halo_motion_sensor_manager/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_UNEQUIPPED,
	))
	if(sensor_action)
		UnregisterSignal(sensor_action, COMSIG_ACTION_ACTIVATED)
		QDEL_NULL(sensor_action)

/datum/component/halo_motion_sensor_manager/proc/on_equipped(obj/item/source, mob/living/carbon/human/human, slot)
	SIGNAL_HANDLER
	if(!ishuman(human) || !human.hud_used?.motion_sensor)
		return
	if(is_equipped(human))
		human.hud_used.motion_sensor.give(human)
	else
		human.hud_used.motion_sensor.remove()

/datum/component/halo_motion_sensor_manager/proc/on_unequipped(obj/item/source, mob/living/carbon/human/human, slot)
	SIGNAL_HANDLER
	if(!ishuman(human) || !human.hud_used?.motion_sensor)
		return
	if(!is_equipped(human))
		human.hud_used.motion_sensor.remove()

/datum/component/halo_motion_sensor_manager/proc/toggle()
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(!ishuman(parent_item.loc))
		return

	var/mob/living/carbon/human/human = parent_item.loc
	if(!human.hud_used?.motion_sensor)
		return
	if(!is_equipped(human))
		human.hud_used.motion_sensor.remove()
		return

	if(human.hud_used.motion_sensor.alpha == 0)
		human.hud_used.motion_sensor.give(human)
	else
		human.hud_used.motion_sensor.remove()

/datum/component/halo_motion_sensor_manager/proc/is_equipped(mob/living/carbon/human/human)
	if(!ishuman(human))
		return FALSE
	var/obj/item/parent_item = parent
	return parent_item.is_valid_slot(human.get_slot_by_item(parent_item), TRUE)

/datum/action/item_action/halo_motion_sensor/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle Motion Sensor"
	button.name = name

/datum/action/item_action/halo_motion_sensor/action_activate()
	if(!ismob(holder_item.loc))
		return
	return ..()
