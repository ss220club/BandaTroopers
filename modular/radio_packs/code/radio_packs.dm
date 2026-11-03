/obj/item/storage/backpack/marine/satchel/rto/twe_net
	name = "\improper Wireless Set No.207 Radio Telephone Pack"
	icon_state = "rmc_rto_backpack"
	item_state = "rmc_rto_backpack"
	phone_category = "TWE"
	networks_receive = list(FACTION_TWE)
	networks_transmit = list(FACTION_TWE)
	actions_types = list(/datum/action/item_action/rto_pack/use_phone/twe)
	max_storage_space = 18
	worn_accessible = FALSE
	bag_open_time = 2 SECONDS

/obj/item/storage/backpack/marine/satchel/rto/twe_net/Initialize()
	. = ..()
	var/datum/component/phone/phone = GetComponent(/datum/component/phone)
	if(phone)
		phone.phone_icon = "rmc_rpb_phone"

/obj/item/storage/backpack/marine/satchel/rto/twe_net/phone_picked_up()
	. = ..()
	item_state = "rmc_rto_backpack_ear"
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.back == src)
			wearer.update_inv_back()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/phone_hung_up()
	. = ..()
	item_state = "rmc_rto_backpack"
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.back == src)
			wearer.update_inv_back()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/get_icon_state(mob/user_mob, slot)
	if(slot == WEAR_BACK && icon_state == PHONE_RINGING_ICON_STATE)
		return initial(icon_state)
	return ..()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/small
	name = "\improper Wireless Set No.207 Small Radio Telephone Pack"
	max_storage_space = 13

/obj/item/storage/backpack/marine/satchel/rto/pmc_net
	name = "\improper Wireless Set No.208 Radio Telephone Pack"
	icon_state = "pmc_rto_backpack"
	item_state = "pmc_rto_backpack"
	phone_category = "PMC"
	networks_receive = list(FACTION_PMC)
	networks_transmit = list(FACTION_PMC)
	actions_types = list(/datum/action/item_action/rto_pack/use_phone/pmc)
	max_storage_space = 21
	worn_accessible = FALSE
	bag_open_time = 2 SECONDS

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/Initialize()
	. = ..()
	var/datum/component/phone/phone = GetComponent(/datum/component/phone)
	if(phone)
		phone.phone_icon = "pmc_rpb_phone"

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/phone_picked_up()
	. = ..()
	item_state = "pmc_rto_backpack_ear"
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.back == src)
			wearer.update_inv_back()

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/phone_hung_up()
	. = ..()
	item_state = "pmc_rto_backpack"
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.back == src)
			wearer.update_inv_back()

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/get_icon_state(mob/user_mob, slot)
	if(slot == WEAR_BACK && icon_state == PHONE_RINGING_ICON_STATE)
		return initial(icon_state)
	return ..()

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/small
	name = "\improper Wireless Set No.208 Small Radio Telephone Pack"
	max_storage_space = 16

/datum/action/item_action/rto_pack/use_phone/twe/New(mob/living/user, obj/item/holder)
	..()
	button.overlays.Cut()
	button.overlays += image('icons/obj/items/misc.dmi', button, "rmc_rpb_phone")

/datum/action/item_action/rto_pack/use_phone/twe/action_activate()
	if(istype(holder_item, /obj/item/storage/backpack/marine/satchel/rto/twe_net))
		SEND_SIGNAL(holder_item, COMSIG_ATOM_PHONE_BUTTON_USE, user = owner)

/datum/action/item_action/rto_pack/use_phone/pmc/New(mob/living/user, obj/item/holder)
	..()
	button.overlays.Cut()
	button.overlays += image('icons/obj/items/misc.dmi', button, "pmc_rpb_phone")

/datum/action/item_action/rto_pack/use_phone/pmc/action_activate()
	if(istype(holder_item, /obj/item/storage/backpack/marine/satchel/rto/pmc_net))
		SEND_SIGNAL(holder_item, COMSIG_ATOM_PHONE_BUTTON_USE, user = owner)

/datum/component/phone/virtual/Initialize(phone_category, phone_color, phone_id, phone_icon, do_not_disturb, list/networks_receive, list/networks_transmit, holder, virtual_user)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || src.phone_category != "Game Master")
		return
	var/list/faction_networks = list(FACTION_FIL, FACTION_UNSC, FACTION_TWE, FACTION_PMC, FACTION_NAVY, FACTION_ARMY)
	src.networks_receive |= faction_networks
	src.networks_transmit |= faction_networks
