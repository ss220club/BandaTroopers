
//======================
// HOLSTER BELTS
//======================
/obj/item/storage/belt/gun/m6
	name = "\improper разгрузка-кобура под пистолет M6"
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
	name = "\improper разгрузка-кобура M7"
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
	name = "\improper медицинская разгрузка образца M8A"
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
	name = "\improper разгрузка медика образца M8A"
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

//======================
// POUCHES
//======================

/obj/item/storage/pouch/medkit/unsc
	name = "подсумок меднабора ККОН"
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

//======================
// HOLSTER POUCHES
//======================

/obj/item/storage/pouch/pistol/unsc
	name = "\improper кобура для M6"
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
	name = "подсумок под пистолетные магазины"
	icon = 'icons/halo/obj/items/clothing/pouches.dmi'
	icon_state = "pistolmag"
	can_hold = list(/obj/item/ammo_magazine/pistol/halo)

/obj/item/storage/pouch/magazine/pistol/unsc/large
	name = "большой подсумок под пистолетные магазины"
	icon_state = "pistolmag_large"
	storage_slots = 6

//======================
// BACKPACKS
//======================

/obj/item/storage/backpack/marine/satchel/rto/unsc
	name = "ранец радиста ККОН"
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
	name = "задний подсумок ККОН"
	desc = "Штатный задний подсумок пехоты ККОН."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "buttpack"
	item_state = "buttpack"
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')

/obj/item/storage/backpack/marine/unsc
	name = "рюкзак ККОН"
	desc = "Большой песочный рюкзак, крепящийся прямо к точкам подвеса брони M52B. Штатное снаряжение, используемое почти всеми ветвями ККОН с XXV века."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "rucksack"
	item_state = "rucksack"
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')

/obj/item/storage/backpack/marine/ammo_rack/spnkr
	name = "рюкзак для ракетных блоков SPNKr"
	desc = "Две отдельные тканевые сумки, каждая из которых вмещает один двухтрубный блок M19 для M41 SPNKr."
	icon = 'icons/halo/obj/items/clothing/back/back_by_faction/back_unsc.dmi'
	icon_state = "spnkrpack_0"
	base_icon_state = "spnkrpack"
	item_state = "spnkrpack"
	storage_slots = 2
	can_hold = list(/obj/item/ammo_magazine/spnkr)
	has_gamemode_skin = FALSE
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/back_by_faction/back_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi')

/obj/item/storage/backpack/marine/ammo_rack/spnkr/filled/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/ammo_magazine/spnkr(src)
	update_icon()

//======================
// BOXES
//======================

/obj/item/storage/unsc_speckit
	name = "ящик специалиста ККОН"
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
	name = "кейс снаряжения SPNKr"
	desc = "Кейс с самым необходимым для оружейного специалиста ККОН. На крышке этого экземпляра нанесена эмблема SPNKr."
	icon_state = "spnkr"
	open_state = "spnkr_o"
	icon_full = "spnkr"
	can_hold = list(/obj/item/ammo_magazine/spnkr, /obj/item/storage/backpack/marine/ammo_rack/spnkr, /obj/item/weapon/gun/halo_launcher/spnkr)
	storage_slots = 5

/obj/item/storage/unsc_speckit/spnkr/fill_preset_inventory()
	new /obj/item/ammo_magazine/spnkr(src)
	new /obj/item/ammo_magazine/spnkr(src)
	new /obj/item/ammo_magazine/spnkr(src)
	new /obj/item/storage/backpack/marine/ammo_rack/spnkr(src)
	new /obj/item/weapon/gun/halo_launcher/spnkr/unloaded(src)

/obj/item/storage/unsc_speckit/srs99
	name = "кейс снаряжения SRS99-AM"
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
	name = "\improper пояс боеприпасов Ковенанта"
	desc = "Модульное крепление для боевого снаряжения воина, принимающее несколько жёстких контейнеров для личного хранения и кобурирования оружия. Благодаря развитию умных материалов пояс теоретически действительно подходит всем."
	icon = 'icons/halo/obj/items/clothing/covenant/belts.dmi'
	icon_state = "sangbelt_minor"
	has_gamemode_skin = FALSE
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
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

/obj/item/storage/belt/marine/covenant/sangheili
	name = "\improper пояс боеприпасов сангхейли"
	icon_state = "sangbelt_minor"
	item_state = "sangbelt_minor"
	storage_slots = 9
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/sangheili/belts.dmi'
		)

/obj/item/storage/belt/marine/covenant/sangheili/minor
	name = "\improper пояс боеприпасов сангхейли-минор"

/obj/item/storage/belt/marine/covenant/sangheili/minor/stored_needles

/obj/item/storage/belt/marine/covenant/sangheili/major
	name = "\improper пояс боеприпасов сангхейли-майор"
	icon_state = "sangbelt_major"
	item_state = "sangbelt_major"

/obj/item/storage/belt/marine/covenant/sangheili/major/stored_needles

/obj/item/storage/belt/marine/covenant/sangheili/ultra
	name = "\improper пояс боеприпасов сангхейли-ультра"
	icon_state = "sangbelt_ultra"
	item_state = "sangbelt_ultra"

/obj/item/storage/belt/marine/covenant/sangheili/zealot
	name = "\improper пояс боеприпасов сангхейли-зилота"
	icon_state = "sangbelt_zealot"
	item_state = "sangbelt_zealot"

/obj/item/storage/belt/marine/covenant/unggoy
	name = "\improper пояс боеприпасов унггоя"
	icon_state = "gruntbelt_minor"
	item_state = "gruntbelt_minor"
	item_icons = list(
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/unggoy/belts.dmi'
		)

/obj/item/storage/belt/marine/covenant/unggoy/minor
	name = "\improper пояс боеприпасов унггоя-минор"
	icon_state = "gruntbelt_minor"
	item_state = "gruntbelt_minor"

/obj/item/storage/belt/marine/covenant/unggoy/major
	name = "\improper пояс боеприпасов унггоя-майор"
	icon_state = "gruntbelt_major"
	item_state = "gruntbelt_major"

/obj/item/storage/belt/marine/covenant/unggoy/heavy
	name = "\improper тяжёлый пояс боеприпасов унггоя"
	icon_state = "gruntbelt_heavy"
	item_state = "gruntbelt_heavy"

/obj/item/storage/belt/marine/covenant/unggoy/ultra
	name = "\improper пояс боеприпасов унггоя-ультра"
	icon_state = "gruntbelt_ultra"
	item_state = "gruntbelt_ultra"

/obj/item/storage/belt/marine/covenant/unggoy/specops
	name = "\improper пояс боеприпасов унггоя спецопераций"
	icon_state = "gruntbelt_specops"
	item_state = "gruntbelt_specops"

/obj/item/storage/belt/marine/covenant/unggoy/specops_ultra
	name = "\improper пояс боеприпасов унггоя спецопераций"
	icon_state = "gruntbelt_specops_ultra"
	item_state = "gruntbelt_specops_ultra"
