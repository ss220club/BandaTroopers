/obj/item/clothing/head/beret/iasf/roaf_boonie
	name = "\improper Панама ИАСФ"
	desc = "Полевая панама снайперов ИАСФ."
	icon = 'modular/iasf/icons/roaf/head_obj.dmi'
	item_icons = list(WEAR_HEAD = 'modular/iasf/icons/roaf/head_worn.dmi')
	icon_state = "icon_hat"
	item_state = "head_hat"

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper
	name = "\improper Радиопак снайпера ИАСФ"
	icon = 'modular/iasf/icons/roaf/pack_obj.dmi'
	item_icons = list(
		WEAR_BACK = 'modular/iasf/icons/roaf/pack_worn.dmi',
		WEAR_L_HAND = 'modular/iasf/icons/rto_left.dmi',
		WEAR_R_HAND = 'modular/iasf/icons/rto_right.dmi',
	)
	icon_state = "icon_backpack"
	item_state = "item_backpack"
	item_state_slots = list(WEAR_BACK = "item_backpack")

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper/phone_picked_up()
	icon_state = initial(icon_state)

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper/phone_hung_up()
	icon_state = initial(icon_state)

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper/phone_ringing()
	icon_state = initial(icon_state)

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper/phone_stopped_ringing()
	icon_state = initial(icon_state)

/obj/structure/closet/secure_closet/marine_personal/iasf/sniper/spawn_gear()
	. = ..()
	new /obj/item/clothing/head/beret/iasf/roaf_boonie(src)
	new /obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper(src)
