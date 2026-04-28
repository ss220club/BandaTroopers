/obj/item/clothing/head/helmet/marine/unsc/mjolnir
	name = "\improper Mjolnir Mk IV helmet"
	desc = "A sealed VISR-equipped helmet for the Mjolnir Mk IV armor system."
	icon = 'icons/halo/obj/items/clothing/hats/hats_by_faction/hat_unsc.dmi'
	icon_state = "mk_iv_0"
	item_state = "mk_iv_0"
	light_system = DIRECTIONAL_LIGHT
	light_power = 3
	light_range = 5
	allowed_species_list = list(SPECIES_SPARTAN)
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_internaldamage = CLOTHING_ARMOR_VERYHIGH
	actions_types = list(/datum/action/item_action/toggle)
	item_icons = list(
		WEAR_HEAD = 'icons/halo/mob/humans/onmob/clothing/hats/hats_by_faction/hat_48.dmi',
	)
	var/toggleable = TRUE

/obj/item/clothing/head/helmet/marine/unsc/mjolnir/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/helmet/marine/unsc/mjolnir/update_icon()
	. = ..()
	if(light_on)
		icon_state = "mk_iv_[light_on]"
		item_state = "mk_iv_[light_on]"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)

/obj/item/clothing/head/helmet/marine/unsc/mjolnir/attack_self(mob/user)
	. = ..()
	if(!toggleable)
		to_chat(user, SPAN_WARNING("You cannot toggle [src] on or off."))
		return FALSE
	if(!isturf(user.loc))
		to_chat(user, SPAN_WARNING("You cannot turn the light [light_on ? "off" : "on"] while in [user.loc]."))
		return FALSE

	turn_light(user, !light_on)

/obj/item/clothing/head/helmet/marine/unsc/mjolnir/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(!toggle_on)
		playsound(src, 'sound/handling/click_2.ogg', 50, 1)
	playsound(src, 'sound/handling/suitlight_on.ogg', 50, 1)
	set_light_on(toggle_on)
	update_icon()
	if(user == loc)
		user.update_inv_head()
	for(var/datum/action/current_action as anything in actions)
		current_action.update_button_icon()
