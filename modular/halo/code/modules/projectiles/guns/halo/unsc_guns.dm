// Rifles

/obj/item/weapon/gun/rifle/halo
	name = "держатель винтовки Halo"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/ma5c.dmi'
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/rifles_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

/obj/item/weapon/gun/rifle/halo/ma5c
	name = "штурмовая винтовка MA5C ICWS"
	desc = "MA5C относится к платформе индивидуального боевого оружия MA5 и выпускается Misriah Armory. Это одна из основных винтовок корпуса морской пехоты ККОН. Использует коробчатый магазин на 32 патрона 7.62x51 мм FMJ."
	icon_state = "ma5c"
	item_state = "ma5c"
	caliber = "7.62x51mm"

	fire_sound = "gun_ma5c"
	reload_sound = 'sound/weapons/halo/gun_ma5c_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_ma5c_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_ma5c_unload.ogg'
	empty_click = "ma5b_dryfire"
	empty_sound = null

	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = TRUE
	map_specific_decoration = FALSE

	starting_attachment_types = list(/obj/item/attachable/flashlight/ma5c)
	current_mag = /obj/item/ammo_magazine/rifle/halo/ma5c
	attachable_allowed = list(
		/obj/item/attachable/attached_gun/grenade/ma5c,
		/obj/item/attachable/flashlight/ma5c,
		/obj/item/attachable/ma5c_muzzle,
	)

/obj/item/weapon/gun/rifle/halo/ma5c/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 16,"rail_x" = 0, "rail_y" = 0, "under_x" = 27, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 48, "special_y" = 16)

/obj/item/weapon/gun/rifle/halo/ma5c/handle_starting_attachment()
	..()
	var/obj/item/attachable/ma5c_muzzle/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/rifle/halo/ma5c/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_amount(BURST_AMOUNT_TIER_4)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4 + 2*HIT_ACCURACY_MULT_TIER_1
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	recoil = RECOIL_AMOUNT_TIER_5
	fa_scatter_peak = 30
	fa_max_scatter = SCATTER_AMOUNT_TIER_8

/obj/item/weapon/gun/rifle/halo/ma5c/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/gun/rifle/halo/ma5b
	name = "штурмовая винтовка MA5B ICWS"
	desc = "MA5B - более старый представитель линейки MA5 производства Misriah Armory, который до сих пор используется морской пехотой и армией. Стреляет стандартным патроном 7.62x51 мм из магазинов на 60 патронов, превосходя MA5C по темпу огня, но уступая ей в устойчивости и точности."
	desc_lore = "Хотя MA5C и была создана, чтобы решить многие проблемы, которые корпус морской пехоты ККОН видел в MA5B, прежде всего ненадёжные магазины и слабую дальнюю эффективность, винтовка по-прежнему популярна у ветеранов и специалистов по ближнему бою. Особенно в паре с боеприпасами Shredder."
	icon_state = "ma5b"
	item_state = "ma5b"
	caliber = "7.62x51mm"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/ma5b.dmi'

	fire_sound = "gun_ma5b"
	fire_rattle = "gun_ma5b"
	firesound_volume = 20
	reload_sound = 'sound/weapons/halo/ma5b/gun_ma5b_reload.ogg'
	cocked_sound = 'sound/weapons/halo/ma5b/gun_ma5b_cock.ogg'
	unload_sound = 'sound/weapons/halo/ma5b/gun_ma5b_unload.ogg'
	empty_click = "ma5b_dryfire"
	empty_sound = null

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = TRUE
	map_specific_decoration = FALSE
	current_mag = /obj/item/ammo_magazine/rifle/halo/ma5b
	attachable_allowed = list(
		/obj/item/attachable/ma5b_muzzle,
		/obj/item/attachable/flashlight/ma5b,
	)

/obj/item/weapon/gun/rifle/halo/ma5b/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 0, "rail_y" = 0, "under_x" = 48, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 48, "special_y" = 16)

/obj/item/weapon/gun/rifle/halo/ma5b/handle_starting_attachment()
	..()
	var/obj/item/attachable/ma5b_muzzle/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)
	var/obj/item/attachable/flashlight/ma5b/integrated2 = new(src)
	integrated2.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated2.Attach(src)
	update_attachable(integrated2.slot)

/obj/item/weapon/gun/rifle/halo/ma5b/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	set_burst_amount(BURST_AMOUNT_TIER_5)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4 + 2*HIT_ACCURACY_MULT_TIER_1
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT * 0.85
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	recoil = RECOIL_AMOUNT_TIER_5
	fa_scatter_peak = 60
	fa_max_scatter = SCATTER_AMOUNT_TIER_7
	effective_range_max = EFFECTIVE_RANGE_MAX_TIER_2

/obj/item/weapon/gun/rifle/halo/ma5b/unloaded
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/gun/rifle/halo/ma3a
	name = "штурмовая винтовка MA3A"
	desc = "Старый предшественник линейки MA5, MA3A прослужила сравнительно недолго, прежде чем её вытеснила более продуманная серия MA5. Тем не менее винтовок было выпущено достаточно, чтобы на десятилетия вперёд насытить рынки частной охраны и начинающих мятежников. В отличие от MA5, MA3A чаще всего оснащалась перегруженной и склонной к поломкам многорежимной оптикой на базе обычного вычислительного блока. Возможностей у неё хватало, но постоянная перенастройка и слабый ресурс батареи быстро вывели её из строевого использования в основных частях UNSCDF."
	icon_state = "ma3a"
	item_state = "ma5c"
	caliber = "7.62x51mm"

	fire_sound = "gun_ma5c"
	reload_sound = 'sound/weapons/halo/gun_ma5c_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_ma5c_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_ma5c_unload.ogg'
	empty_sound = null

	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = TRUE
	map_specific_decoration = FALSE

	starting_attachment_types = list(/obj/item/attachable/flashlight/ma5c/ma3a, /obj/item/attachable/ma3a_barrel, /obj/item/attachable/scope/mini/ma3a)
	current_mag = /obj/item/ammo_magazine/rifle/halo/ma3a
	attachable_allowed = list(
		/obj/item/attachable/ma3a_shroud,
		/obj/item/attachable/flashlight/ma5c/ma3a,
		/obj/item/attachable/ma3a_barrel,
		/obj/item/attachable/scope/mini/ma3a,
	)

/obj/item/weapon/gun/rifle/halo/ma3a/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16, "rail_x" = 16, "rail_y" = 16, "under_x" = 32, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 32, "special_y" = 16)

/obj/item/weapon/gun/rifle/halo/ma3a/handle_starting_attachment()
	..()
	var/obj/item/attachable/ma3a_shroud/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/rifle/halo/ma3a/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_burst_delay(FIRE_DELAY_TIER_10)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_8
	scatter = SCATTER_AMOUNT_TIER_2
	burst_scatter_mult = SCATTER_AMOUNT_TIER_3
	scatter_unwielded = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	recoil = RECOIL_AMOUNT_TIER_4
	fa_scatter_peak = 30
	fa_max_scatter = 2

/obj/item/weapon/gun/rifle/halo/ma3a/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/gun/rifle/halo/vk78
	name = "винтовка из запасов VK78"
	desc = "Эта винтовка 6.5x48 мм разрабатывалась Colonial Military Authority как замена устаревающей HMG-38, но за свою жизнь чаще стреляла по мишеням, чем по живым противникам. Благодаря удобной классической компоновке и исключительной механической простоте VK78 пережила падение CMA и до сих пор служит ополченцам, преступникам, поселенцам и мятежникам. Услышите на патруле её характерный лай - вряд ли это свои."
	icon_state = "vk78"
	item_state = "vk78"
	caliber = "6.5x48mm"

	fire_sound = "gun_ma5c"
	reload_sound = 'sound/weapons/halo/gun_ma5c_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_ma5c_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_ma5c_unload.ogg'
	empty_sound = null

	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = TRUE
	map_specific_decoration = FALSE

	starting_attachment_types = list(/obj/item/attachable/vk78_barrel, /obj/item/attachable/scope/mini/vk78)
	current_mag = /obj/item/ammo_magazine/rifle/halo/vk78
	attachable_allowed = list(
		/obj/item/attachable/vk78_front,
		/obj/item/attachable/vk78_barrel,
		/obj/item/attachable/scope/mini/vk78,
	)

/obj/item/weapon/gun/rifle/halo/vk78/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 16, "rail_y" = 16, "under_x" = 32, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 32, "special_y" = 16)


/obj/item/weapon/gun/rifle/halo/vk78/handle_starting_attachment()
	..()
	var/obj/item/attachable/vk78_front/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)


/obj/item/weapon/gun/rifle/halo/vk78/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_10)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_burst_delay(FIRE_DELAY_TIER_10)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_3
	burst_scatter_mult = SCATTER_AMOUNT_TIER_2
	scatter_unwielded = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	recoil = RECOIL_AMOUNT_TIER_4
	fa_scatter_peak = 30
	fa_max_scatter = 2


/obj/item/weapon/gun/rifle/halo/vk78/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null


/obj/item/weapon/gun/rifle/halo/br55
	name = "боевая винтовка BR55"
	desc = "Штатная марксманская винтовка корпуса морской пехоты ККОН. BR55 сочетает достойную мощность, приемлемый темп стрельбы и высокую точность. Оснащается стандартным съёмным коробчатым магазином на 36 экспериментальных патронов 9.5x40 мм HP-SAP-HE, что позволяет ей развивать большую скорость пули, чем серия MA5, несмотря на меньший метательный заряд."
	icon_state = "br55"
	item_state = "br55"
	caliber = "9.5x40mm"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/br55.dmi'

	fire_sound = "gun_br55"
	reload_sound = 'sound/weapons/halo/gun_br55_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_br55_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_br55_unload.ogg'
	empty_sound = null

	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = FALSE
	map_specific_decoration = FALSE

	starting_attachment_types = list(/obj/item/attachable/br55_barrel, /obj/item/attachable/scope/mini/br55)
	current_mag = /obj/item/ammo_magazine/rifle/halo/br55
	attachable_allowed = list(
		/obj/item/attachable/br55_barrel,
		/obj/item/attachable/br55_muzzle,
		/obj/item/attachable/scope/mini/br55,
	)

/obj/item/weapon/gun/rifle/halo/br55/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 24, "rail_y" = 20, "under_x" = 32, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 32, "special_y" = 16)

/obj/item/weapon/gun/rifle/halo/br55/handle_starting_attachment()
	..()
	var/obj/item/attachable/br55_muzzle/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/rifle/halo/br55/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_7)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_5
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	recoil = RECOIL_AMOUNT_TIER_4
	fa_scatter_peak = 16
	fa_max_scatter = 2

/obj/item/weapon/gun/rifle/halo/br55/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/gun/rifle/halo/dmr
	name = "винтовка M392 DMR"
	desc = "M392 Designated Marksman Rifle - компоновки bullpup под патрон 7.62x51 мм, обычно оснащаемая прицелом и магазином на 15 патронов. Наиболее широко использовалась армейскими подразделениями UNSCDF и расформированной Colonial Military Authority до и во время Восстания. На фоне современников винтовка механически проста, что вместе с массовым выбросом на рынок после падения CMA сделало её популярной на чёрном рынке."
	icon_state = "dmr"
	item_state = "dmr"
	caliber = "7.62x51mm"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/br55.dmi'

	fire_sound = null
	fire_sounds = list('sound/weapons/halo/gun_m392_1.ogg', 'sound/weapons/halo/gun_m392_2.ogg', 'sound/weapons/halo/gun_m392_3.ogg')
	reload_sound = 'sound/weapons/halo/gun_br55_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_br55_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_br55_unload.ogg'
	empty_sound = null


	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = FALSE
	map_specific_decoration = FALSE


	starting_attachment_types = list(/obj/item/attachable/dmr_front, /obj/item/attachable/dmr_barrel, /obj/item/attachable/scope/mini/dmr)
	current_mag = /obj/item/ammo_magazine/rifle/halo/dmr
	attachable_allowed = list(
		/obj/item/attachable/dmr_front,
		/obj/item/attachable/dmr_barrel,
		/obj/item/attachable/scope/mini/dmr,
	)


/obj/item/weapon/gun/rifle/halo/dmr/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 48, "muzzle_y" = 16,"rail_x" = 28, "rail_y" = 16, "under_x" = 32, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 32, "special_y" = 16)


/obj/item/weapon/gun/rifle/halo/dmr/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	recoil = RECOIL_AMOUNT_TIER_5
	fa_scatter_peak = 16
	fa_max_scatter = 2


/obj/item/weapon/gun/rifle/halo/dmr/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

// SMGs

/obj/item/weapon/gun/smg/halo
	name = "держатель ПП Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/smgs_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi',
		WEAR_WAIST = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi'
	)

/obj/item/weapon/gun/smg/halo/m7
	name = "пистолет-пулемёт M7"
	desc = "M7 - сравнительно компактный безгильзовый пистолет-пулемёт под 5-мм боеприпас. Благодаря складному прикладу и складывающейся передней рукояти он особенно прижился у абордажных групп и подразделений специальных операций, где ценятся компактность и умеренная мощность."
	icon_state = "m7"
	item_state = "m7"
	caliber = "5x23mm"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/ma5b.dmi'

	fire_sound = "gun_m7"
	fire_rattle = "gun_m7"
	reload_sound = 'sound/weapons/halo/gun_m7_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_m7_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_m7_unload.ogg'
	empty_sound = null
	w_class = SIZE_LARGE

	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK
	start_automatic = TRUE
	map_specific_decoration = FALSE
	current_mag = /obj/item/ammo_magazine/smg/halo/m7
	starting_attachment_types = list(/obj/item/attachable/stock/m7, /obj/item/attachable/stock/m7/grip/folded_down)
	attachable_allowed = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)

/obj/item/weapon/gun/smg/halo/m7/folded_up
	starting_attachment_types = list(/obj/item/attachable/stock/m7, /obj/item/attachable/stock/m7/grip)

/obj/item/weapon/gun/smg/halo/m7/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 15,"rail_x" = 16, "rail_y" = 16, "under_x" = 30, "under_y" = 15, "stock_x" = 13, "stock_y" = 14, "special_x" = 11, "special_y" = 16)

/obj/item/weapon/gun/smg/halo/m7/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	set_burst_delay(FIRE_DELAY_TIER_12)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	fa_scatter_peak = 40
	fa_max_scatter = 3

/obj/item/weapon/gun/smg/halo/m7/socom
	name = "пистолет-пулемёт M7"
	starting_attachment_types = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip/folded_down,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)

/obj/item/weapon/gun/smg/halo/m7/socom/folded_up
	starting_attachment_types = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)

// shotguns

/obj/item/weapon/gun/shotgun/pump/halo
	name = "держатель дробовика Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/shotguns_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

/obj/item/weapon/gun/shotgun/pump/halo/m90
	name = "\improper M90 CAWS"
	desc = "Разработанный и производимый Weapon System Technology, M90 CAWS - современный помповый дробовик, который ККОН использует для ближнего боя. Питается двенадцатью патронами 8-го калибра из внутреннего трубчатого магазина."
	icon_state = "m90"
	item_state = "m90"
	fire_sound = "gun_m90"
	pump_sound = 'sound/weapons/halo/gun_m90_pump.ogg'
	reload_sound = 'sound/weapons/halo/gun_m90_reload.ogg'
	mouse_pointer = 'icons/halo/effects/mouse_pointer/shotgun.dmi'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/m90
	attachable_allowed = list(/obj/item/attachable/flashlight/m90)
	starting_attachment_types = list(/obj/item/attachable/flashlight/m90)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	flags_equip_slot = SLOT_BACK
	gauge = "8g"

/obj/item/weapon/gun/shotgun/pump/halo/m90/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 21, "under_x" = 29, "under_y" = 15, "stock_x" = 16, "stock_y" = 15, "special_x" = 27, "special_y" = 16)

/obj/item/weapon/gun/shotgun/pump/halo/m90/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/shotgun/pump/halo/m90/handle_starting_attachment()
	..()
	var/obj/item/attachable/m90_muzzle/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/shotgun/pump/halo/m90/unloaded
	current_mag = /obj/item/ammo_magazine/internal/shotgun/m90/unloaded
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_TRIGGER_SAFETY

/obj/item/weapon/gun/shotgun/pump/halo/m90/police
	name = "\improper полицейский дробовик WMT"
	desc = "Гражданская вариация M90 CAWS производства WMT, рассчитанная на правоохранительные структуры... хотя временами она оказывается и в руках обычных граждан."
	icon_state = "m90_police"
	attachable_allowed = list(/obj/item/attachable/flashlight/m90/police)
	starting_attachment_types = list(/obj/item/attachable/flashlight/m90/police)
	current_mag = /obj/item/ammo_magazine/internal/shotgun/m90/police

// snipers

/obj/item/weapon/gun/rifle/sniper/halo
	name = "снайперская винтовка SRS99-AM"
	desc = "SRS99-AM - штатная снайперская винтовка всех родов войск ККОН благодаря своим выдающимся возможностям. Использует съёмный коробчатый магазин на 4 патрона 14.5x114 мм APFSDS и модульную систему, позволяющую снять весь стволовой узел и заменить его альтернативным вариантом."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = "srs99"
	item_state = "srs99"
	caliber = "14.5x114mm"
	mouse_pointer = 'icons/halo/effects/mouse_pointer/srs99.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_x_dimension = 64
	worn_y_dimension = 64
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/marksman_rifles_64.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo_64.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo_64.dmi'
	)

	fire_sound = "gun_srs99"
	reload_sound = 'sound/weapons/halo/gun_srs99_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_srs99_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_srs99_unload.ogg'
	empty_sound = null

	current_mag = /obj/item/ammo_magazine/rifle/halo/sniper
	force = 12
	wield_delay = WIELD_DELAY_HORRIBLE
	flags_equip_slot = SLOT_BLOCK_SUIT_STORE|SLOT_BACK
	zoomdevicename = "scope"
	attachable_allowed = list(/obj/item/attachable/srs_assembly, /obj/item/attachable/scope/variable_zoom/oracle, /obj/item/attachable/srs_barrel, /obj/item/attachable/bipod/srs_bipod)
	starting_attachment_types = list(/obj/item/attachable/scope/variable_zoom/oracle, /obj/item/attachable/srs_barrel, /obj/item/attachable/bipod/srs_bipod)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	map_specific_decoration = FALSE
	skill_locked = FALSE
	flags_item = TWOHANDED
	var/can_change_barrel = TRUE

/obj/item/weapon/gun/rifle/sniper/halo/verb/toggle_scope_zoom_level()
	set name = "Toggle Scope Zoom Level"
	set category = "Weapons"
	set src in usr
	var/obj/item/attachable/scope/variable_zoom/S = attachments["rail"]
	S.toggle_zoom_level()

/obj/item/weapon/gun/rifle/sniper/halo/handle_starting_attachment()
	..()
	var/obj/item/attachable/srs_assembly/S = new(src)
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachable(S.slot)

/obj/item/weapon/gun/rifle/sniper/halo/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 21,"rail_x" = 21, "rail_y" = 24, "under_x" = 32, "under_y" = 14, "special_x" = 48, "special_y" = 17)


/obj/item/weapon/gun/rifle/sniper/halo/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SNIPER)
	set_burst_amount(BURST_AMOUNT_TIER_1)
	accuracy_mult = BASE_ACCURACY_MULT * 3 //you HAVE to be able to hit
	scatter = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/rifle/sniper/halo/unloaded
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/mateba_key/halo_sniper
	name = "ключ ствола SRS99"
	desc = "Ключ для ствола SRS99, которым отпирают механизм и снимают ствол."

/obj/item/weapon/gun/rifle/sniper/halo/attackby(obj/item/subject, mob/user)
	if(istype(subject, /obj/item/weapon/mateba_key/halo_sniper) && can_change_barrel)
		if(attachments["muzzle"])
			var/obj/item/attachable/attachment = attachments["special"]
			visible_message(SPAN_NOTICE("[user] begins stripping [attachment] from [src]."),
			SPAN_NOTICE("You begin stripping [attachment] from [src]."), null, 4)

			if(!do_after(usr, 35, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
				return

			if(!(attachment == attachments[attachment.slot]))
				return

			visible_message(SPAN_NOTICE("[user] unlocks and removes [attachment] from [src]."),
			SPAN_NOTICE("You unlocks removes [attachment] from [src]."), null, 4)
			attachment.Detach(user, src)
			playsound(src, 'sound/handling/attachment_remove.ogg', 15, 1, 4)
			update_icon()
	. = ..()

/obj/item/weapon/gun/rifle/sniper/halo/able_to_fire(mob/living/user)
	if(!attachments["muzzle"])
		to_chat(user, SPAN_WARNING("You can't fire the [src] without a barrel!"))
		return
	. = ..()

// Pistols

/obj/item/weapon/gun/pistol/halo
	name = "держатель пистолета Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/pistols_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
	mouse_pointer = 'icons/halo/effects/mouse_pointer/magnum.dmi'
	reload_sound = 'sound/weapons/halo/gun_magnum_reload.ogg'
	unload_sound = 'sound/weapons/halo/gun_magnum_unload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_magnum_cocked.ogg'
	drop_sound = 'sound/items/halo/drop_lightweapon.ogg'
	pickup_sound = 'sound/items/halo/grab_lightweapon.ogg'
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK
	empty_sound = null

/obj/item/weapon/gun/pistol/halo/m6c
	name = "служебный магнум M6C"
	desc = "M6C - полуавтоматический пистолет под патрон 12.7x40 мм с автоматикой на отдаче и стандартным магазином на 12 патронов. От прочих боковых образцов платформы M6 он отличается отсутствием верхнего смарт-прицела. Некоторые морпехи, по слухам, ценят его именно за меньшую громоздкость."
	icon_state = "m6c"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c
	attachable_allowed = list(/obj/item/attachable/scope/mini/smartscope/m6c, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK

/obj/item/weapon/gun/pistol/halo/m6c/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6c/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/pistol/halo/m6c/socom
	name = "пистолет M6C/SOCOM \"Automag\""
	desc = "Модифицированный Special Operations Command вариант M6C, известный как M6C/SOCOM. Этот пистолет получил целый набор тонких доработок для улучшения боевой эффективности, а заодно и более эффектную окраску."
	icon_state = "m6c_socom"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c/socom
	attachable_allowed = list(/obj/item/attachable/flashlight/m6c_socom, /obj/item/attachable/suppressor/m6c_socom)
	starting_attachment_types = list(/obj/item/attachable/flashlight/m6c_socom, /obj/item/attachable/suppressor/m6c_socom)

/obj/item/weapon/gun/pistol/halo/m6c/socom/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/socom/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/pistol/halo/m6c/socom/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 19, "muzzle_y" = 15,"rail_x" = 16, "rail_y" = 16, "under_x" = 19, "under_y" = 16, "stock_x" = 0, "stock_y" = 0)

/obj/item/weapon/gun/pistol/halo/m6c/m4a
	name = "пистолет M4A"
	desc = "Устаревший пистолет под 12.7x40 мм, одинаково популярный у гражданских и преступников. M4A - предшественник куда более известной серии M6 от Misriah, снятый с официального вооружения в 2414 году, когда на сцену вышла M6. Его считают неточным, ослепительно ярким при выстреле и оглушительно громким, то есть непригодным для большинства практических задач, - именно поэтому он так нравится своей основной аудитории."
	icon_state = "m4a"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c
	attachable_allowed = list(/obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"

/obj/item/weapon/gun/pistol/halo/m6c/m4a/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/m4a/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6c/m4a/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT - BULLET_DAMAGE_MULT_TIER_1

/obj/item/weapon/gun/pistol/halo/m6g
	name = "служебный магнум M6G"
	desc = "Служебный магнум M6G - мощное табельное оружие ККОН, использующее патроны 12.7x40 мм из магазина на 8 патронов. За счёт более длинного ствола M6G точнее и обеспечивает большую начальную скорость, чем M6C."
	icon_state = "m6g"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6g
	attachable_allowed = list(/obj/item/attachable/scope/mini/smartscope/m6g, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6g"

/obj/item/weapon/gun/pistol/halo/m6g/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6g/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6g/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4
	velocity_add = AMMO_SPEED_TIER_1

/obj/item/weapon/gun/pistol/halo/m6d
	name = "служебный магнум M6D"
	desc = "Служебный магнум M6D - мощный пистолет, используемый ККОН, особенно офицерами и некоторыми бойцами спецподразделений. Стреляет патронами 12.7x40 мм Semi-Armour-Piercing-High-Explosive (SAPHE) из магазина на 12 патронов."
	desc_lore = "Увеличенный магазин и особая рукоять придают ему выразительный силуэт, который одни считают неуклюжим и громоздким, а другие готовы защищать за мощь и точность в сочетании с интегрированным прицелом KFA-2."
	icon_state = "m6d"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6d
	attachable_allowed = list(/obj/item/attachable/scope/variable_zoom/m6d, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6d"
	unload_sound = 'sound/weapons/halo/m6d/gun_m6d_unload.ogg'
	reload_sound = 'sound/weapons/halo/m6d/gun_m6d_reload.ogg'
	cocked_sound = 'sound/weapons/halo/m6d/gun_m6d_cock.ogg'
	empty_click = 'sound/weapons/halo/m6d/gun_m6d_dryfire.ogg'

/obj/item/weapon/gun/pistol/halo/m6g/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6d/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6d/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	scatter = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_9
	damage_mult = BASE_BULLET_DAMAGE_MULT * 2
	velocity_add = AMMO_SPEED_TIER_2

/obj/item/weapon/gun/pistol/halo/m6d/handle_starting_attachment()
	..()
	var/obj/item/attachable/scope/variable_zoom/m6d/scope = new(src)
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	scope.hidden = TRUE
	update_attachable(scope.slot)

/obj/item/weapon/gun/pistol/halo/m6a
	name = "служебный магнум M6A"
	desc = "M6A - полуавтоматический пистолет под 12.7x40 мм с автоматикой на отдаче и стандартным магазином на 12 патронов. Этот вариант часто выдаётся охранным и правоохранительным структурам как более компактная версия базового шаблона, хотя и с меньшим останавливающим действием."
	icon_state = "m6a"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6a
	attachable_allowed = list(/obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"

/obj/item/weapon/gun/pistol/halo/m6a/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6a/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)


/obj/item/weapon/gun/pistol/halo/m6a/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult =  BASE_BULLET_DAMAGE_MULT - BULLET_DAMAGE_MULT_TIER_4

// Grenades

/obj/item/explosive/grenade/high_explosive/m15/unsc
	name = "осколочная граната M9"
	desc = "Осколочно-фугасная граната, используемая ККОН."
	desc_lore = "Ходят слухи, что с каждым новым назначением дизайн осколочной гранаты M9 снова чем-то отличается от тех, что держали в руках раньше."
	icon = 'icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "m9"
	item_state = "m9"
	falloff_mode = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF

/obj/item/explosive/grenade/high_explosive/m15/unsc/launchable
	name = "40-мм фугасная граната"
	desc = "40-мм фугасная граната. Её нельзя привести в боевое положение вручную - она должна быть заряжена в подствольный гранатомёт винтовки."
	icon = 'icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "he_40mm"
	item_state = "he_40mm"
	caliber = "40mm"
	hand_throwable = FALSE
	has_arm_sound = FALSE
	dangerous = FALSE
	dual_purpose = TRUE
	underslug_launchable = TRUE
