/obj/item/storage/belt/gun/xm52
	name = "\improper M276 pattern XM52 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is for the XM52 breaching scattergun, allowing easier storage of the weapon. It features pouches for storing two magazines along with extra shells."
	icon = 'modular/breacher/assets/icons/obj/items/clothing/belts.dmi'
	item_icons = list(
		WEAR_WAIST = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/jungle.dmi'
	)
	icon_state = "xm52_holster"
	var/gun_slot_icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/holstered_guns.dmi'
	flags_atom = FPRINT
	storage_slots = 8
	max_w_class = 6
	can_hold = list(
		/obj/item/weapon/gun/rifle/xm52,
		/obj/item/ammo_magazine/rifle/xm52,
		/obj/item/ammo_magazine/handful,
	)
	holster_slots = list(
		"1" = list(
			"icon_x" = 10,
			"icon_y" = -1))

	var/magazines = 0
	var/maxmag = 2
	var/obj/item/weapon/gun/rifle/xm52/magneted_xm
	var/magnetic_range = 2

/obj/item/storage/belt/gun/xm52/update_gun_icon(slot)
	var/mob/living/carbon/human/user = loc
	var/obj/item/weapon/gun/current_gun = holster_slots[slot]["gun"]
	if(current_gun)
		playsound(src, drawSound, 7, TRUE)
		var/image/gun_underlay = image(gun_slot_icon, "xm52")
		gun_underlay.pixel_x = holster_slots[slot]["icon_x"]
		gun_underlay.pixel_y = holster_slots[slot]["icon_y"]
		gun_underlay.color = current_gun.color
		holster_slots[slot]["underlay_sprite"] = gun_underlay
		underlays += gun_underlay
		icon_state += "_g"
		item_state = icon_state
	else
		playsound(src, sheatheSound, 7, TRUE)
		underlays -= holster_slots[slot]["underlay_sprite"]
		holster_slots[slot]["underlay_sprite"] = null
		icon_state = copytext(icon_state, 1, -2)
		item_state = icon_state
	if(istype(user))
		if(src == user.belt)
			user.update_inv_belt()
		else if(src == user.s_store)
			user.update_inv_s_store()

/obj/item/storage/belt/gun/xm52/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("jungle")
			icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/belts_by_map/jungle.dmi'
			item_icons[WEAR_WAIST] = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/jungle.dmi'
		if("classic")
			icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/belts_by_map/classic.dmi'
			item_icons[WEAR_WAIST] = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/classic.dmi'
		if("desert")
			icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/belts_by_map/desert.dmi'
			item_icons[WEAR_WAIST] = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/desert.dmi'
		if("snow")
			icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/belts_by_map/snow.dmi'
			item_icons[WEAR_WAIST] = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/snow.dmi'
		if("urban")
			icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/belts_by_map/urban.dmi'
			item_icons[WEAR_WAIST] = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/belts/belts_by_map/urban.dmi'

/obj/item/storage/belt/gun/xm52/dump_ammo_to(obj/item/ammo_magazine/ammo_dumping, mob/user, amount_to_dump)
	if(user.action_busy)
		return

	if(ammo_dumping.flags_magazine & AMMUNITION_CANNOT_REMOVE_BULLETS)
		to_chat(user, SPAN_WARNING("You can't remove ammo from \the [ammo_dumping]!"))
		return

	if(ammo_dumping.flags_magazine & AMMUNITION_HANDFUL_BOX)
		var/handfuls = round(ammo_dumping.current_rounds / amount_to_dump, 1)
		if(ammo_dumping.current_rounds != 0)
			if(length(contents) < storage_slots - 1)
				to_chat(user, SPAN_NOTICE("You start refilling [src] with [ammo_dumping]."))
				if(!do_after(user, 1.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC)) return
				for(var/i = 1 to handfuls)
					if(length(contents) < storage_slots - 1)
						var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful
						var/transferred_handfuls = min(ammo_dumping.current_rounds, amount_to_dump)
						new_handful.generate_handful(ammo_dumping.default_ammo, ammo_dumping.caliber, amount_to_dump, transferred_handfuls, ammo_dumping.gun_type)
						new_handful.icon = 'icons/obj/items/weapons/guns/handful.dmi'
						ammo_dumping.current_rounds -= transferred_handfuls
						handle_item_insertion(new_handful, TRUE,user)
						update_icon(-transferred_handfuls)
					else
						break
				playsound(user.loc, "rustle", 15, TRUE, 6)
				ammo_dumping.update_icon()
			else
				to_chat(user, SPAN_WARNING("[src] is full."))

	gun_slot_icon = 'modular/breacher/assets/icons/obj/items/clothing/belts/holstered_guns.dmi'

/obj/item/storage/belt/gun/xm52/can_be_inserted(obj/item/item, mob/user, stop_messages = FALSE)
	. = ..()
	if(magazines >= maxmag && istype(item, /obj/item/ammo_magazine/rifle/xm52))
		if(!stop_messages)
			to_chat(user, SPAN_WARNING("[src] can't hold any more magazines."))
		return FALSE

/obj/item/storage/belt/gun/xm52/handle_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines++

/obj/item/storage/belt/gun/xm52/remove_from_storage(obj/item/item as obj, atom/new_location)
	. = ..()
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines--

/obj/item/storage/belt/gun/xm52/on_stored_atom_del(atom/movable/item)
	if(istype(item, /obj/item/ammo_magazine/rifle/xm52))
		magazines--

/obj/item/storage/belt/gun/xm52/_item_insertion(obj/item/I, prevent_warning = FALSE, mob/user)
	if(I.type == /obj/item/weapon/gun/rifle/xm52)
		if(!magneted_xm)
			magneted_xm = I
			magneted_xm.AddElement(/datum/element/drop_retrieval/xm52, src)
		if(!prevent_warning)
			to_chat(user, SPAN_NOTICE("You attach the sling to [I]."))
	..()

/obj/item/storage/belt/gun/xm52/attack_self(mob/user)
	if(magneted_xm)
		to_chat(user, SPAN_NOTICE("You retract the sling from [magneted_xm]."))
		unsling()
		return
	return ..()

/obj/item/storage/belt/gun/xm52/proc/unsling()
	if(!magneted_xm)
		return
	magneted_xm.RemoveElement(/datum/element/drop_retrieval/xm52, src)
	magneted_xm = null

/obj/item/storage/belt/gun/xm52/proc/sling_return(mob/living/carbon/human/user)
	if(!magneted_xm || !magneted_xm.loc)
		return FALSE
	if(magneted_xm.loc == user)
		return TRUE
	if(!isturf(magneted_xm.loc))
		return FALSE
	if(get_dist(magneted_xm, src) > magnetic_range)
		return FALSE
	if(handle_item_insertion(magneted_xm))
		if(user)
			to_chat(user, SPAN_NOTICE("[magneted_xm] snaps back into [src]."))
		return TRUE

/obj/item/storage/belt/gun/xm52/proc/attempt_retrieval(mob/living/carbon/human/user)
	if(sling_return(user))
		return
	unsling()
	if(user && src.loc == user)
		to_chat(user, SPAN_WARNING("The sling of your [src] snaps back empty!"))

/obj/item/storage/belt/gun/xm52/proc/handle_retrieval(mob/living/carbon/human/user)
	if(magneted_xm && magneted_xm.loc == src)
		return
	addtimer(CALLBACK(src, PROC_REF(attempt_retrieval), user), 0.3 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/datum/element/drop_retrieval/xm52
	compatible_types = list(/obj/item/weapon/gun)
	var/obj/item/storage/belt/gun/xm52/container

/datum/element/drop_retrieval/xm52/Attach(datum/target, obj/item/storage/belt/gun/xm52/new_container)
	. = ..()
	if(.)
		return
	container = new_container

/datum/element/drop_retrieval/xm52/dropped(obj/item/I, mob/user)
	container?.handle_retrieval(user)

/obj/item/storage/belt/gun/brutepack
	name = "M271A2 Pattern Launcher Rig"
	desc = "A back mounted rig for the M6H-BRUTE launcher and its rockets."
	icon = 'modular/breacher/assets/icons/obj/items/clothing/backpack/backpacks_by_faction/UA.dmi'
	icon_state = "bruterig"
	item_icons = list(WEAR_BACK = 'modular/breacher/assets/icons/mob/humans/onmob/clothing/back/backpacks_by_faction/UA.dmi')
	flags_equip_slot = SLOT_BACK
	storage_slots = 7
	max_w_class = SIZE_MEDIUM
	can_hold = list(/obj/item/ammo_magazine, /obj/item/weapon/gun/launcher/rocket/brute)
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/brute)

/obj/item/storage/belt/gun/brutepack/update_icon()
	. = ..()
	var/mob/living/carbon/human/user = loc
	if(istype(user))
		user.update_inv_back()
