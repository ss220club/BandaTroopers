
//======================
// HOLSTER BELTS
//======================
/obj/item/storage/belt/gun/m6
	name = "\improper M6 general pistol holster rig"
	desc = "M276 - стандартная система разгрузочного снаряжения ККОН. Она состоит из модульного пояса с различными креплениями. В этой версии установлен кобурный модуль, позволяющий носить самые распространённые пистолеты, а также боковые подсумки под большинство пистолетных магазинов."
	icon = 'icons/halo/obj/items/clothing/belts/belts_by_faction/belt_unsc.dmi'
	icon_state = "m6_holster"
	item_state = "s_marinebelt"
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/belts/belts_by_faction/belt_unsc.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi')
	storage_slots = 7
	can_hold = list(
		/obj/item/weapon/gun/pistol/halo,
		/obj/item/ammo_magazine/pistol/halo,
	)
	has_gamemode_skin = FALSE
	holster_slots = list(
		"1" = list(
			"icon_x" = -5,
			"icon_y" = 0))

/obj/item/storage/belt/gun/m6/full_m6c/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/halo/m6c())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/halo/m6c(src)

/obj/item/storage/belt/gun/m6/full_m6g/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/halo/m6g())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/halo/m6g(src)

/obj/item/storage/belt/gun/m6/full_m6d/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/halo/m6d())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/halo/m6d(src)

/obj/item/storage/belt/gun/m6/full_m6c/m4a/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/halo/m6c/m4a())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/halo/m6c(src)

/obj/item/storage/belt/gun/m6/full_m6a/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/halo/m6a())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/halo/m6a(src)

/obj/item/storage/belt/gun/m7
	name = "\improper M7 holster rig"
	desc = "Специальная разгрузка под M7, редко выдаваемая вспомогательному и специализированному персоналу ККОН в качестве PDW."
	icon = 'icons/halo/obj/items/clothing/belts/belts_by_faction/belt_unsc.dmi'
	icon_state = "m7_holster"
	item_state = "s_marinebelt"
	storage_slots = 3
	max_w_class = 6
	can_hold = list(
		/obj/item/weapon/gun/smg/halo/m7,
		/obj/item/ammo_magazine/smg/halo/m7,
	)
	holster_slots = list(
		"1" = list(
			"icon_x" = 0,
			"icon_y" = 0))
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/belts/belts_by_faction/belt_unsc.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi')

/obj/item/storage/belt/gun/m7/full/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/smg/halo/m7/folded_up())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/smg/halo/m7(src)

/obj/item/storage/belt/gun/m7/full/socom/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/smg/halo/m7/socom/folded_up())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/smg/halo/m7(src)

//======================
// BELTS
//======================

/obj/item/storage/belt/medical/unsc
	name = "\improper M8A pattern medical storage rig"
	icon = 'icons/halo/obj/items/clothing/belts/belts_by_faction/belt_unsc.dmi'
	desc = "M8A - один из стандартных разгрузочных комплектов ККОН. Он состоит из модульного пояса с различными креплениями. Эта конфигурация встречается реже и предназначена для переноски более громоздких медицинских принадлежностей. \nЩёлкните по спрайту правой кнопкой мыши и выберите \"toggle belt mode\", чтобы доставать таблетки из бутылочек простым нажатием."
	icon_state = "medicalbelt"
	item_state = "medicalbelt"
	has_gamemode_skin = FALSE
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/belts/belts_by_faction/belt_unsc.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi')
	item_state_slots = list(
		WEAR_L_HAND = "s_marinebelt",
		WEAR_R_HAND = "s_marinebelt")

/obj/item/storage/belt/medical/unsc/full/fill_preset_inventory()
	new /obj/item/reagent_container/glass/beaker/unsc/bicaridine(src)
	new /obj/item/storage/syringe_case/unsc/burnguard(src)
	new /obj/item/reagent_container/glass/beaker/unsc/tramadol(src)
	new /obj/item/reagent_container/glass/beaker/unsc/dexalin(src)
	new /obj/item/reagent_container/glass/beaker/unsc/inaprovaline(src)
	new /obj/item/reagent_container/glass/beaker/unsc/peridaxon(src)
	new /obj/item/reagent_container/glass/beaker/unsc/dylovene(src)
	new /obj/item/reagent_container/glass/beaker/unsc/chorotazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)

/obj/item/storage/belt/medical/lifesaver/unsc
	name = "\improper M8A pattern lifesaver rig"
	icon = 'icons/halo/obj/items/clothing/belts/belts_by_faction/belt_unsc.dmi'
	desc = "M8A - один из стандартных разгрузочных комплектов ККОН. В этой конфигурации к нему крепится сумка, заполненная различными инжекторами и лёгкими медицинскими средствами, поэтому она особенно популярна у медиков. \nЩёлкните по спрайту правой кнопкой мыши и выберите \"toggle belt mode\", чтобы доставать таблетки из бутылочек простым нажатием."
	icon_state = "medicbag"
	item_state = "medicbag"
	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/bodybag,
		/obj/item/reagent_container/glass/bottle,
		/obj/item/reagent_container/pill,
		/obj/item/reagent_container/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_container/hypospray/autoinjector,
		/obj/item/stack/medical,
		/obj/item/device/defibrillator/compact,
		/obj/item/device/reagent_scanner,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/reagent_container/glass/beaker,
	)
	has_gamemode_skin = FALSE
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/belts/belts_by_faction/belt_unsc.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi')
	item_state_slots = list(
		WEAR_L_HAND = "medicbag",
		WEAR_R_HAND = "medicbag")

/obj/item/storage/belt/medical/lifesaver/unsc/full/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinp/halo(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo(src)
	new /obj/item/reagent_container/glass/beaker/unsc/bicaridine(src)
	new /obj/item/reagent_container/glass/beaker/unsc/dexalin(src)
	new /obj/item/reagent_container/glass/beaker/unsc/dylovene(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/glass/beaker/unsc/inaprovaline(src)
	new /obj/item/reagent_container/glass/beaker/unsc/tramadol(src)
	new /obj/item/reagent_container/glass/beaker/unsc/chorotazine(src)
	new /obj/item/reagent_container/glass/beaker/unsc/peridaxon(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)

/obj/item/storage/belt/shotgun/unsc
	name = "\improper M276 pattern shotgun shell loading rig"

/obj/item/storage/belt/shotgun/unsc/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/ammo_magazine/handful/shotgun/buckshot_unsc(src)

//======================
// POUCHES
//======================

/obj/item/storage/pouch/medkit/unsc
	name = "UNSC medical kit pouch"
	icon = 'icons/halo/obj/items/clothing/pouches.dmi'
	icon_state = "medpouch"
	can_hold_skill = list(
		/obj/item/device/healthanalyzer = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/dropper = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/pill = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/glass/bottle = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/syringe = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/storage/pill_bottle = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/stack/medical = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/hypospray = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/storage/syringe_case = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/storage/surgical_case = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/tool/surgery/surgical_line = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/tool/surgery/synthgraft = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/roller = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/bodybag = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/blood = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/tool/surgery/FixOVein = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
		/obj/item/reagent_container/glass/beaker = list(SKILL_MEDICAL, SKILL_MEDICAL_MEDIC),
	)

/obj/item/storage/pouch/medkit/unsc/full/fill_preset_inventory()
	new /obj/item/device/healthanalyzer/halo(src)
	new /obj/item/storage/syringe_case/unsc/full(src)
	new /obj/item/storage/syringe_case/unsc/burnguard(src)
	new /obj/item/reagent_container/glass/beaker/unsc/bicaridine(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)

/obj/item/storage/pouch/medkit/unsc/full_bio/fill_preset_inventory()
	new /obj/item/storage/syringe_case/unsc/burnguard(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_container/glass/beaker/unsc/tramadol(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo(src)

//======================
// HOLSTER POUCHES
//======================

/obj/item/storage/pouch/pistol/unsc
	name = "\improper M6 pistol holster"
	icon = 'icons/halo/obj/items/clothing/pouches.dmi'
	icon_state = "m6"
	gun_underlay_path = 'icons/halo/obj/items/clothing/belts/belts_by_faction/belt_unsc.dmi'
	icon_x = 0
	icon_y = 0
	can_hold = list(
		/obj/item/weapon/gun/pistol/halo,
		/obj/item/ammo_magazine/pistol/halo,
	)

/obj/item/storage/pouch/magazine/pistol/unsc
	name = "pistol magazine pouch"
	icon = 'icons/halo/obj/items/clothing/pouches.dmi'
	icon_state = "pistolmag"
	can_hold = list(/obj/item/ammo_magazine/pistol/halo)

/obj/item/storage/pouch/magazine/pistol/unsc/large
	name = "large pistol magazine pouch"
	icon_state = "pistolmag_large"
	storage_slots = 6

//======================
// BACKPACKS
//======================

/obj/item/storage/backpack/marine/satchel/rto/unsc
	name = "UNSC radio backpack"
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "radiopack"
	item_state = "radiopack"
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')
	networks_receive = list(FACTION_UNSC, FACTION_MARINE)
	networks_transmit = list(FACTION_UNSC, FACTION_MARINE)
	phone_category = PHONE_UNSC

/obj/item/storage/backpack/marine/satchel/unsc
	name = "UNSC buttpack"
	desc = "Штатный задний подсумок пехоты ККОН."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "buttpack"
	item_state = "buttpack"
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')

/obj/item/storage/backpack/marine/unsc
	name = "UNSC rucksack"
	desc = "Большой песочный рюкзак, крепящийся прямо к точкам подвеса брони M52B. Штатное снаряжение, используемое почти всеми ветвями ККОН с XXV века."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "rucksack"
	item_state = "rucksack"
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')

/obj/item/storage/large_holster/spnkr
	name = "транспортный ранец для SPNKr"
	desc = "Транспортная рама с двумя жёсткими тубусами под блоки M19 и отдельной подвесной системой под сам M41 SPNKr."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "spnkrpack_0"
	item_state = "spnkrpack"
	flags_equip_slot = SLOT_BACK
	storage_slots = 3
	can_hold = list(/obj/item/ammo_magazine/spnkr, /obj/item/weapon/gun/halo_launcher/spnkr)
	has_gamemode_skin = FALSE
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')
	drawSound = "rustle"
	var/image/spnkr_overlay

/obj/item/storage/large_holster/spnkr/Initialize()
	. = ..()
	spnkr_overlay = overlay_image('icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi', "+spnkr")

/obj/item/storage/large_holster/spnkr/Destroy()
	QDEL_NULL(spnkr_overlay)
	. = ..()

/obj/item/storage/large_holster/spnkr/handle_item_insertion(obj/item/new_item, prevent_warning = FALSE, mob/user)
	if(istype(new_item, /obj/item/weapon/gun/halo_launcher/spnkr) && locate(/obj/item/weapon/gun/halo_launcher/spnkr, contents))
		return FALSE
	var/ammo_count = 0
	for(var/obj/item/ammo_magazine/spnkr/ammo in contents)
		ammo_count++
	if(istype(new_item, /obj/item/ammo_magazine/spnkr) && (ammo_count > 1))
		return FALSE
	return ..()

/obj/item/storage/large_holster/spnkr/update_icon()
	icon_state = "spnkrpack_0"
	overlays -= spnkr_overlay
	if(locate(/obj/item/weapon/gun/halo_launcher/spnkr, contents))
		overlays += spnkr_overlay
	var/ammo_count = 0
	for(var/obj/item/ammo_magazine/spnkr/ammo in contents)
		ammo_count++
		icon_state = "spnkrpack_[ammo_count]"
	item_state = "spnkrpack"
	var/mob/living/carbon/human/user = loc
	if(istype(user))
		user.update_inv_back()

/obj/item/storage/large_holster/spnkr/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(slot == WEAR_BACK && locate(/obj/item/weapon/gun/halo_launcher/spnkr, contents))
		var/image/weapon_holstered = overlay_image('icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi', "+spnkr", color, RESET_COLOR)
		ret.overlays += weapon_holstered
	return ret

/obj/item/storage/large_holster/spnkr/filled/fill_preset_inventory()
	for(var/i = 1 to 2)
		new /obj/item/ammo_magazine/spnkr(src)
	update_icon()

/obj/item/storage/large_holster/spnkr/filled/launcher/fill_preset_inventory()
	for(var/i = 1 to 2)
		new /obj/item/ammo_magazine/spnkr(src)
	handle_item_insertion(new /obj/item/weapon/gun/halo_launcher/spnkr/unloaded())
	update_icon()

/obj/item/storage/backpack/marine/ammo_rack/spnkr
	parent_type = /obj/item/storage/large_holster/spnkr

/obj/item/storage/backpack/marine/ammo_rack/spnkr/filled
	parent_type = /obj/item/storage/large_holster/spnkr/filled

//======================
// BOXES
//======================

/obj/item/storage/box/personalcase/unsc
	name = "оружейный кейс UNSC"
	desc = "Защищенный кейс с замком, содержащий чье-то заказное оружие."
	icon = 'icons/halo/obj/items/storage/kits.dmi'

/obj/item/storage/box/personalcase/unsc/assign_owner(new_owner)
	owner = new_owner
	name = "\improper оружейный кейс UNSC ([owner])"
	desc = "Защищенный кейс с замком, содержащий заказное оружие, закрепленное за [owner]."

/obj/item/storage/unsc_speckit
	name = "ящик комплекта специалиста UNSC"
	desc = "Неподписанный и никак не маркированный ящик со специализированным снаряжением. Остаётся лишь гадать, что лежит внутри."
	icon = 'icons/halo/obj/items/storage/spec_kits.dmi'
	icon_state = "template"
	var/open_state = "template_o"
	var/icon_full = "template" //icon state to use when kit is full
	var/possible_icons_full
	can_hold = list()
	max_w_class = SIZE_MASSIVE
	storage_flags = STORAGE_FLAGS_BOX

/obj/item/storage/unsc_speckit/Initialize()
	. = ..()

	if(possible_icons_full)
		icon_full = pick(possible_icons_full)
	else
		icon_full = initial(icon_state)

	update_icon()

/obj/item/storage/unsc_speckit/update_icon()
	if(content_watchers || !length(contents))
		icon_state = open_state
	else
		icon_state = icon_full

/obj/item/storage/unsc_speckit/attack_self(mob/living/user)
	..()

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.swap_hand()
		open(user)

/obj/item/storage/unsc_speckit/spnkr
	name = "кейс комплекта SPNKr"
	desc = "Кейс с самым необходимым для оружейного специалиста ККОН. На крышке этого экземпляра нанесена эмблема SPNKr."
	icon_state = "spnkr"
	open_state = "spnkr_o"
	icon_full = "spnkr"
	can_hold = list(/obj/item/ammo_magazine/spnkr, /obj/item/storage/large_holster/spnkr, /obj/item/weapon/gun/halo_launcher/spnkr)
	storage_slots = 5

/obj/item/storage/unsc_speckit/spnkr/fill_preset_inventory()
	new /obj/item/storage/large_holster/spnkr/filled/launcher(src)

/obj/item/storage/unsc_speckit/srs99
	name = "кейс комплекта SRS99-AM"
	desc = "Кейс с самым необходимым для оружейного специалиста ККОН. На крышке этого экземпляра нанесена эмблема SRS99-AM."
	icon_state = "srs99"
	open_state = "srs99_o"
	icon_full = "srs99"
	can_hold = list(/obj/item/weapon/gun/rifle/sniper/halo/unloaded, /obj/item/ammo_magazine/rifle/halo/sniper)
	storage_slots = 7

/obj/item/storage/unsc_speckit/srs99/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/sniper/halo/unloaded(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)
	new /obj/item/ammo_magazine/rifle/halo/sniper(src)


//======================
// COVIE BELTS
//======================

/obj/item/storage/belt/marine/covenant
	name = "\improper Covenant ammunition belt"
	desc = "Модульное крепление для боевого снаряжения воина, принимающее несколько жёстких контейнеров для личного хранения и кобурирования оружия. Благодаря развитию умных материалов пояс теоретически действительно подходит всем."
	icon = 'icons/halo/obj/items/clothing/covenant/belts.dmi'
	icon_state = "sangbelt_minor"
	has_gamemode_skin = FALSE
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
	var/mob/living/carbon/human/grenade_scatter_owner
	can_hold = list(
		/obj/item/attachable/bayonet,
		/obj/item/device/flashlight/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_container/food/snacks,
		/obj/item/reagent_container/hypospray/autoinjector,
		/obj/item/ammo_magazine/needler_crystal,
		/obj/item/ammo_magazine/carbine,
		/obj/item/weapon/covenant/energy_sword,
	)
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/needler_crystal,
		/obj/item/ammo_magazine/carbine,
	)

/obj/item/storage/belt/marine/covenant/Destroy()
	unregister_grenade_scatter_signal()
	return ..()

/obj/item/storage/belt/marine/covenant/equipped(mob/user, slot, silent)
	. = ..()
	register_grenade_scatter_signal(user, slot)

/obj/item/storage/belt/marine/covenant/unequipped(mob/user, slot)
	. = ..()
	unregister_grenade_scatter_signal(user)

/obj/item/storage/belt/marine/covenant/proc/register_grenade_scatter_signal(mob/living/carbon/human/user, slot)
	if(slot != WEAR_WAIST || user == grenade_scatter_owner)
		return

	unregister_grenade_scatter_signal()
	if(!ishuman(user) || user.belt != src)
		return

	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(handle_owner_death))
	grenade_scatter_owner = user

/obj/item/storage/belt/marine/covenant/proc/unregister_grenade_scatter_signal(mob/living/carbon/human/user = grenade_scatter_owner)
	if(!ishuman(user))
		user = grenade_scatter_owner
	if(!ishuman(user))
		return

	UnregisterSignal(user, COMSIG_MOB_DEATH)
	if(user == grenade_scatter_owner)
		grenade_scatter_owner = null

/obj/item/storage/belt/marine/covenant/proc/handle_owner_death(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(source != grenade_scatter_owner || source.belt != src)
		return
	if(!issangheili(source) && !isunggoy(source) && !isruuhtian(source))
		return

	INVOKE_ASYNC(src, PROC_REF(scatter_stored_grenades), source, get_turf(source))

/obj/item/storage/belt/marine/covenant/proc/scatter_stored_grenades(mob/living/carbon/human/source, turf/origin_turf)
	if(!isturf(origin_turf) || !length(contents))
		return

	var/list/grenades_to_scatter = get_stored_grenades_for_scatter()

	if(!length(grenades_to_scatter))
		return

	var/list/available_directions = GLOB.alldirs.Copy()

	for(var/obj/item/explosive/grenade/grenade as anything in grenades_to_scatter)
		var/direction = length(available_directions) ? pick(available_directions) : pick(GLOB.alldirs)
		available_directions -= direction

		var/turf/target_turf = origin_turf
		var/turf/current_turf = origin_turf
		var/throw_distance = rand(1, 2)
		for(var/i in 1 to throw_distance)
			var/turf/next_turf = get_step(current_turf, direction)
			if(!isturf(next_turf) || next_turf.density)
				break
			current_turf = next_turf
			target_turf = next_turf

		remove_from_storage(grenade, origin_turf)
		if(target_turf != origin_turf)
			grenade.throw_atom(target_turf, get_dist(origin_turf, target_turf), SPEED_FAST, source, TRUE)

/obj/item/storage/belt/marine/covenant/proc/get_stored_grenades_for_scatter()
	var/list/grenades_to_scatter = list()
	for(var/obj/item/stored_item as anything in contents)
		if(istype(stored_item, /obj/item/explosive/grenade))
			grenades_to_scatter += stored_item
	return grenades_to_scatter

/obj/item/storage/belt/marine/covenant/sangheili
	name = "\improper патронташ сангхейли"
	icon_state = "sangbelt_minor"
	item_state = "sangbelt_minor"
	storage_slots = 9
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/sangheili/belts.dmi'
		)

/obj/item/storage/belt/marine/covenant/sangheili/minor
	name = "\improper патронташ сангхейли-минора"

/obj/item/storage/belt/marine/covenant/sangheili/minor/stored_needles

/obj/item/storage/belt/marine/covenant/sangheili/major
	name = "\improper патронташ сангхейли-майора"
	icon_state = "sangbelt_major"
	item_state = "sangbelt_major"

/obj/item/storage/belt/marine/covenant/sangheili/major/stored_needles

/obj/item/storage/belt/marine/covenant/sangheili/ultra
	name = "\improper патронташ сангхейли-ультры"
	icon_state = "sangbelt_ultra"
	item_state = "sangbelt_ultra"

/obj/item/storage/belt/marine/covenant/sangheili/zealot
	name = "\improper патронташ сангхейли-зилота"
	icon_state = "sangbelt_zealot"
	item_state = "sangbelt_zealot"

/obj/item/storage/belt/marine/covenant/unggoy
	name = "\improper патронташ унггоя"
	icon_state = "gruntbelt_minor"
	item_state = "gruntbelt_minor"
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/unggoy/belts.dmi'
		)

/obj/item/storage/belt/marine/covenant/unggoy/minor
	name = "\improper патронташ унггоя-минора"
	icon_state = "gruntbelt_minor"
	item_state = "gruntbelt_minor"

/obj/item/storage/belt/marine/covenant/unggoy/major
	name = "\improper патронташ унггоя-майора"
	icon_state = "gruntbelt_major"
	item_state = "gruntbelt_major"

/obj/item/storage/belt/marine/covenant/unggoy/heavy
	name = "\improper тяжёлый патронташ унггоя"
	icon_state = "gruntbelt_heavy"
	item_state = "gruntbelt_heavy"

/obj/item/storage/belt/marine/covenant/unggoy/ultra
	name = "\improper патронташ унггоя-ультры"
	icon_state = "gruntbelt_ultra"
	item_state = "gruntbelt_ultra"

/obj/item/storage/belt/marine/covenant/unggoy/specops
	name = "\improper спецоперативный патронташ унггоя"
	icon_state = "gruntbelt_specops"
	item_state = "gruntbelt_specops"

/obj/item/storage/belt/marine/covenant/unggoy/specops_ultra
	name = "\improper спецоперативный патронташ унггоя-ультры"
	icon_state = "gruntbelt_specops_ultra"
	item_state = "gruntbelt_specops_ultra"

/obj/item/storage/belt/marine/covenant/ruuhtian
	name = "\improper Ruuhtian combat belt"
	desc = "A modular belt for Kig-Yar field gear and ammunition."
	icon_state = "ruuhtian_minor"
	item_state = "belt_minor"
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/ruuhtian/belts.dmi'
		)

/obj/item/storage/belt/marine/covenant/ruuhtian/minor
	name = "\improper Ruuhtian Minor combat belt"
	desc = "A light combat belt for Kig-Yar skirmishers."
	icon_state = "ruuhtian_minor"
	item_state = "ruuhtian_minor"

/obj/item/storage/belt/marine/covenant/ruuhtian/major
	name = "\improper Ruuhtian Major combat belt"
	desc = "A veteran combat belt for Kig-Yar skirmishers."
	icon_state = "ruuhtian_major"
	item_state = "ruuhtian_major"

/obj/item/storage/belt/marine/covenant/ruuhtian/ultra
	name = "\improper Ruuhtian Ultra combat belt"
	desc = "An elite combat belt for Kig-Yar line veterans."
	icon_state = "ruuhtian_ultra"
	item_state = "ruuhtian_ultra"
