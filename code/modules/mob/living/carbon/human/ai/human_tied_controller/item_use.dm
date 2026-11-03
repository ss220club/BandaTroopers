// Raw item interaction primitives

/datum/human_tied_controller/proc/can_use_item(obj/item/item, atom/target)
	if(!can_directly_control() || !item)
		return FALSE
	if(target)
		return item.ai_can_use(tied_human, brain, target)
	return item.ai_can_use(tied_human, brain)

/datum/human_tied_controller/proc/ai_use(obj/item/item, atom/target)
	if(!can_directly_control() || !item)
		return FALSE
	if(target)
		return item.ai_use(tied_human, brain, target)
	return item.ai_use(tied_human, brain)

// Raw ammo source primitive
/datum/human_tied_controller/proc/create_handful_from_ammo_source(obj/item/ammo_magazine/source, atom/display_source)
	RETURN_TYPE(/obj/item/ammo_magazine/handful)

	if(!can_directly_control() || !source || source.current_rounds <= 0)
		return null

	var/obj/item/old_active = get_active_hand()
	var/obj/item/old_inactive = get_inactive_hand()
	source.create_handful(tied_human, source.transfer_handful_amount, display_source || source)

	var/obj/item/ammo_magazine/handful/new_active = get_active_hand()
	if(istype(new_active) && new_active != old_active)
		return new_active

	var/obj/item/ammo_magazine/handful/new_inactive = get_inactive_hand()
	if(istype(new_inactive) && new_inactive != old_inactive)
		return new_inactive

	return null

/datum/human_tied_controller/proc/take_magazine_from_ammo_box(obj/item/ammo_box/magazine/ammo_box)
	RETURN_TYPE(/obj/item/ammo_magazine)

	if(!can_directly_control() || !ammo_box || ammo_box.handfuls || !length(ammo_box.contents))
		return null

	var/obj/item/ammo_magazine/magazine = locate(/obj/item/ammo_magazine) in ammo_box.contents
	if(!magazine)
		return null

	ammo_box.contents -= magazine
	if(!put_in_hands(magazine, FALSE))
		ammo_box.contents += magazine
		magazine.forceMove(ammo_box)
		return null

	ammo_box.update_icon()
	return magazine

/datum/human_tied_controller/proc/create_handful_from_ammo_box(obj/item/ammo_box/magazine/ammo_box)
	RETURN_TYPE(/obj/item/ammo_magazine/handful)

	if(!can_directly_control() || !ammo_box || !ammo_box.handfuls || !length(ammo_box.contents))
		return null

	var/obj/item/ammo_magazine/source = locate(/obj/item/ammo_magazine) in ammo_box.contents
	if(!source)
		return null

	var/obj/item/ammo_magazine/handful/handful = create_handful_from_ammo_source(source, ammo_box)
	if(handful)
		ammo_box.update_icon()
	return handful

/datum/human_tied_controller/proc/take_grenade_from_grenade_box(obj/item/ammo_box/magazine/nade_box/grenade_box, obj/item/weapon/gun/launcher/grenade/grenade_launcher)
	RETURN_TYPE(/obj/item/explosive/grenade)

	if(!can_directly_control() || !grenade_box || grenade_box.burning || !length(grenade_box.contents))
		return null

	for(var/obj/item/explosive/grenade/grenade as anything in grenade_box.contents)
		if(grenade.w_class == SIZE_HUGE)
			continue
		if(grenade_launcher && !grenade_launcher.allowed_ammo_type(grenade))
			continue

		grenade_box.contents -= grenade
		if(!put_in_hands(grenade, FALSE))
			grenade_box.contents += grenade
			grenade.forceMove(grenade_box)
			return null

		grenade_box.update_icon()
		return grenade

	return null
