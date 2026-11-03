/datum/unit_test/faction_radio_packs/Run()
	check_pack(/obj/item/storage/backpack/marine/satchel/rto/twe_net, FACTION_TWE, "rmc_rto_backpack", "rmc_rpb_phone")
	if(!succeeded)
		return
	check_pack(/obj/item/storage/backpack/marine/satchel/rto/twe_net/small, FACTION_TWE, "rmc_rto_backpack", "rmc_rpb_phone")
	if(!succeeded)
		return
	check_pack(/obj/item/storage/backpack/marine/satchel/rto/pmc_net, FACTION_PMC, "pmc_rto_backpack", "pmc_rpb_phone")
	if(!succeeded)
		return
	check_pack(/obj/item/storage/backpack/marine/satchel/rto/pmc_net/small, FACTION_PMC, "pmc_rto_backpack", "pmc_rpb_phone")
	if(!succeeded)
		return
	check_vendor(/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/rmc, /obj/item/storage/backpack/marine/satchel/rto/twe_net, /obj/item/storage/backpack/marine/satchel/rto/twe_net/small)
	if(!succeeded)
		return
	check_vendor(/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/pmc, /obj/item/storage/backpack/marine/satchel/rto/pmc_net, /obj/item/storage/backpack/marine/satchel/rto/pmc_net/small)
	if(!succeeded)
		return
	check_game_master_networks()

/datum/unit_test/faction_radio_packs/proc/check_game_master_networks()
	var/atom/movable/holder = allocate(/atom/movable, run_loc_floor_bottom_left)
	var/list/original_networks = list(FACTION_MARINE, FACTION_UPP, FACTION_COLONIST, FACTION_WY)
	var/datum/component/phone/virtual/phone = holder.AddComponent(/datum/component/phone/virtual/radio_pack_test, "Game Master", "white", "Company Command", null, PHONE_DND_ON, original_networks, original_networks, null, null)
	if(!phone)
		return Fail("Game Master test phone could not be initialized")
	for(var/network in list(FACTION_MARINE, FACTION_UPP, FACTION_COLONIST, FACTION_WY, FACTION_FIL, FACTION_UNSC, FACTION_TWE, FACTION_PMC, FACTION_NAVY, FACTION_ARMY))
		if(!(network in phone.networks_receive) || !(network in phone.networks_transmit))
			return Fail("Game Master phone cannot use [network] network")

/datum/unit_test/faction_radio_packs/proc/check_vendor(vendor_type, pack_type, small_type)
	var/obj/structure/machinery/cm_vending/sorted/vendor = allocate(vendor_type, run_loc_floor_bottom_left)
	var/has_large = FALSE
	var/has_small = FALSE
	for(var/list/product in vendor.listed_products)
		if(product[3] == pack_type)
			has_large = TRUE
		if(product[3] == small_type)
			has_small = TRUE
	if(!has_large || !has_small)
		return Fail("[vendor_type] stock check for [pack_type]: entries=[length(vendor.listed_products)], large=[has_large], small=[has_small]")

/datum/unit_test/faction_radio_packs/proc/check_pack(pack_type, faction, state, phone_state)
	var/obj/item/storage/backpack/marine/satchel/rto/pack = allocate(pack_type, run_loc_floor_bottom_left)
	var/datum/component/phone/phone = pack.GetComponent(/datum/component/phone)
	if(!phone)
		return Fail("[pack_type] has no phone component")
	if(!(faction in phone.networks_receive) || !(faction in phone.networks_transmit))
		return Fail("[pack_type] has incorrect phone networks")
	if(phone.phone_icon != phone_state)
		return Fail("[pack_type] uses the wrong TGUI phone icon")
	var/list/object_states = icon_states('icons/obj/items/clothing/backpacks.dmi')
	for(var/check_state in list(state, "[state]_ear", "[state]_ring", "+[state]_full", "+[state]_half"))
		if(!(check_state in object_states))
			return Fail("[pack_type] lacks object sprite [check_state]")
	var/list/worn_states = icon_states('icons/mob/humans/onmob/back.dmi')
	if(!(state in worn_states) || !("[state]_ear" in worn_states))
		return Fail("[pack_type] lacks a worn sprite")
	if(!(phone_state in icon_states('icons/obj/items/misc.dmi')))
		return Fail("[pack_type] lacks its phone button sprite")
	pack.phone_picked_up()
	if(pack.icon_state != "[state]_ear" || pack.get_icon_state(null, WEAR_BACK) != "[state]_ear")
		return Fail("[pack_type] did not show its lifted receiver")
	pack.phone_hung_up()
	if(pack.icon_state != state || pack.get_icon_state(null, WEAR_BACK) != state)
		return Fail("[pack_type] did not restore its base sprite")
	pack.phone_ringing()
	if(pack.icon_state != "[state]_ring")
		return Fail("[pack_type] did not show its ringing sprite")
	if(pack.get_icon_state(null, WEAR_BACK) != state)
		return Fail("[pack_type] lost its worn sprite while ringing")
	pack.phone_stopped_ringing()
	if(pack.icon_state != state)
		return Fail("[pack_type] did not restore its sprite after ringing")

/datum/component/phone/virtual/radio_pack_test/handle_initial_variables(phone_category, phone_color, phone_id, phone_icon, do_not_disturb, list/networks_receive, list/networks_transmit, holder, virtual_user)
	src.phone_category = phone_category
	src.networks_receive = networks_receive.Copy()
	src.networks_transmit = networks_transmit.Copy()
	return TRUE
