/obj/item/proc/validate_uscm_map_skin(base_icon_state, base_item_state, base_worn_state, slot)
	var/worn_icon = item_icons[slot]
	var/worn_state = base_worn_state
	var/has_matching_worn_style = TRUE
	if(base_worn_state && worn_icon && icon_state != base_icon_state)
		var/style_prefix = copytext(icon_state, 1, 3)
		if(style_prefix in list("s_", "d_", "c_", "u_"))
			var/styled_worn_state = "[style_prefix][base_worn_state]"
			if(styled_worn_state in icon_states(worn_icon))
				LAZYSET(item_state_slots, slot, styled_worn_state)
				worn_state = styled_worn_state
			else
				has_matching_worn_style = FALSE
	if(!worn_state)
		worn_state = icon_state
	if(has_matching_worn_style && icon_state in icon_states(icon) && (!worn_icon || worn_state in icon_states(worn_icon)))
		return
	icon_state = base_icon_state
	item_state = base_item_state
	if(base_worn_state)
		LAZYSET(item_state_slots, slot, base_worn_state)

/obj/item/clothing/suit/storage/marine/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	var/base_icon_state = icon_state
	var/base_item_state = item_state
	var/base_worn_state = LAZYACCESS(item_state_slots, WEAR_JACKET)
	. = ..()
	validate_uscm_map_skin(base_icon_state, base_item_state, base_worn_state, WEAR_JACKET)

/obj/item/clothing/suit/marine/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	var/base_icon_state = icon_state
	var/base_item_state = item_state
	var/base_worn_state = LAZYACCESS(item_state_slots, WEAR_JACKET)
	. = ..()
	validate_uscm_map_skin(base_icon_state, base_item_state, base_worn_state, WEAR_JACKET)

/obj/item/clothing/head/helmet/marine/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	var/base_icon_state = icon_state
	var/base_item_state = item_state
	var/base_worn_state = LAZYACCESS(item_state_slots, WEAR_HEAD)
	. = ..()
	validate_uscm_map_skin(base_icon_state, base_item_state, base_worn_state, WEAR_HEAD)

/obj/item/clothing/head/helmet/marine/specialist
	flags_atom = NO_NAME_OVERRIDE
