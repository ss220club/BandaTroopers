

/obj/item/attachable/ma5c_muzzle
	name = "\improper кожух MA5C"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma5c_muzzle"
	attach_icon = "ma5c_muzzle"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0
	hud_offset_mod = -3

/obj/item/attachable/attached_gun/grenade/ma5c
	name = "\improper 40-мм гранатомёт M301C"
	desc = "Подствольный 40-мм гранатомёт. Вариант M301C специально разработан для платформы MA5C ICWS и одновременно служит передней рукоятью, подобно штатному фонарю MA5C."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma5c_gl"
	attach_icon = "ma5c_gl"
	current_rounds = 0
	max_rounds = 1
	max_range = 10
	attachment_firing_delay = 5
	layer_addition = 0.1
	caliber = "40mm"

/obj/item/attachable/ma3a_shroud
	name = "\improper кожух MA3A"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma3a_shroud"
	attach_icon = "ma3a_shroud"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0
	hud_offset_mod = -3

/obj/item/attachable/vk78_front
	name = "\improper цевьё VK78"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "vk78_front"
	attach_icon = "vk78_front"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0
	size_mod = 0
	hud_offset_mod = -3

/obj/item/attachable/vk78_front/New()
	..()
	recoil_mod = -RECOIL_AMOUNT_TIER_2

/obj/item/attachable/br55_muzzle
	name = "\improper дульный модуль BR55"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "br55_muzzle"
	attach_icon = "br55_muzzle"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0
	hud_offset_mod = -7

/obj/item/attachable/ma5b_muzzle
	name = "\improper дульный модуль MA5B"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma5b_muzzle"
	attach_icon = "ma5b_muzzle"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0
	hud_offset_mod = -7

/obj/item/attachable/m90_muzzle
	name = "\improper дульный модуль M90 CAWS"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m90_muzzle"
	attach_icon = "m90_muzzle"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0 //Integrated attachment for visuals, stats handled on main gun.
	size_mod = 0
	hud_offset_mod = -7

/obj/item/attachable/dmr_front
	name = "\improper цевьё M392 DMR"
	desc = "Эта деталь не должна отделяться от оружия. Как это вообще произошло?"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "dmr_front"
	attach_icon = "dmr_front"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0
	size_mod = 0
	hud_offset_mod = -3

/obj/item/attachable/flashlight/ma5c
	name = "\improper встроенный фонарь MA5C"
	desc = "Встроенный фонарь MA5C, штатно устанавливаемый на любую штурмовую винтовку серии MA5."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma5c_flashlight"
	attach_icon = "ma5c_flashlight"
	original_state = "ma5c_flashlight"
	original_attach = "ma5c_flashlight"
	slot = "under"

/obj/item/attachable/flashlight/ma5b
	name = "\improper встроенный фонарь MA5B"
	desc = "Встроенный фонарь MA5B, штатно устанавливаемый на любую штурмовую винтовку серии MA5 и фактически необходимый для нормального хвата."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma5b_flashlight"
	attach_icon = "ma5b_flashlight"
	original_state = "ma5b_flashlight"
	original_attach = "ma5b_flashlight"
	slot = "under"

/obj/item/attachable/flashlight/ma5c/ma3a
	name = "\improper встроенный фонарь MA3A"
	desc = "Подствольная рукоять для MA3A, совмещённая с фонарём."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma3a_flashlight"
	attach_icon = "ma3a_flashlight"
	original_state = "ma3a_flashlight"
	original_attach = "ma3a_flashlight"
	slot = "under"

/obj/item/attachable/flashlight/ma5c/ma3a/New()
	..()
	recoil_mod = -RECOIL_AMOUNT_TIER_4

/obj/item/attachable/flashlight/m90
	name = "\improper встроенный фонарь M90"
	desc = "Встроенный фонарь M90, штатный для любого дробовика серии M90 и встроенный в цевьё. Вообще вы не должны видеть его отдельно."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m90_flashlight"
	attach_icon = "m90_flashlight_a"
	original_state = "m90_flashlight"
	original_attach = "m90_flashlight_a"
	slot = "under"

/obj/item/attachable/flashlight/m90/police
	icon_state = "m90_police_flashlight"
	attach_icon = "m90_police_flashlight_a"
	original_state = "m90_police_flashlight"
	original_attach = "m90_police_flashlight_a"

/obj/item/attachable/vk78_barrel
	name = "\improper ствол VK78"
	desc = "Ствол винтовки VK78 Commando. Лучше без него не уходить."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "vk78_barrel"
	attach_icon = "vk78_barrel"
	slot = "muzzle"
	size_mod = 0

/obj/item/attachable/vk78_barrel/New()
	..()
	scatter_mod = -SCATTER_AMOUNT_TIER_2
	burst_scatter_mod = -SCATTER_AMOUNT_TIER_3

/obj/item/attachable/ma3a_barrel
	name = "\improper ствол MA3A"
	desc = "Ствол штурмовой винтовки MA3A ICWS. Лучше без него не уходить."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma3a_barrel"
	attach_icon = "ma3a_barrel"
	slot = "muzzle"
	size_mod = 0

/obj/item/attachable/br55_barrel
	name = "\improper ствол BR55"
	desc = "Ствол боевой винтовки BR55. Лучше без него не уходить."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "br55_barrel"
	attach_icon = "br55_barrel"
	slot = "muzzle"
	size_mod = 0

/obj/item/attachable/br55_barrel/New()
	..()
	scatter_mod = -9
	burst_scatter_mod = -SCATTER_AMOUNT_TIER_3

/obj/item/attachable/dmr_barrel
	name = "\improper ствол M392 DMR"
	desc = "Ствол M392 DMR. Лучше без него не уходить."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "dmr_barrel"
	attach_icon = "dmr_barrel"
	slot = "muzzle"
	size_mod = 0

/obj/item/attachable/dmr_barrel/New()
	..()
	scatter_mod = -SCATTER_AMOUNT_TIER_2
	burst_scatter_mod = -SCATTER_AMOUNT_TIER_3

/obj/item/attachable/scope/spnkr
	name = "\improper прицел SPNKr"
	desc = "Эта деталь вообще не должна сниматься со SPNKr..."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "spnkr_scope"
	attach_icon = null
	size_mod = 0
	hidden = TRUE

/obj/item/attachable/scope/mini/br55
	name = "\improper прицел A2"
	desc = "Телескопический прицел с двукратным увеличением. Обычно он надёжен, но для идеальной точности нередко требует юстировки и тонкой настройки."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "br55_scope"
	attach_icon = "br55_scope"
	size_mod = 0

/obj/item/attachable/scope/mini/vk78
	name = "\improper прицел VK78"
	desc = "Старый телескопический прицел, часто идущий в паре с VK78 Commando."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "vk78_scope"
	attach_icon = "vk78_scope"
	size_mod = 0

/obj/item/attachable/scope/mini/dmr
	name = "\improper прицел M392 DMR"
	desc = "Трёхкратный прицел для M392 DMR, который на эту винтовку ставят чаще всего. По общему мнению, вполне надёжен."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "dmr_scope"
	attach_icon = "dmr_scope"
	size_mod = 0

/obj/item/attachable/scope/mini/ma3a
	name = "\improper прицел MA3A"
	desc = "Прицел для MA3A. Он не интегрирован в платформу, но его часто ставят ради прибавки к точности."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "ma3a_scope"
	attach_icon = "ma3a_scope"
	size_mod = 0

/obj/item/attachable/scope/mini/ma3a/New()
	..()
	scatter_mod = -SCATTER_AMOUNT_TIER_3
	burst_scatter_mod = -SCATTER_AMOUNT_TIER_3
	accuracy_mod = -HIT_ACCURACY_MULT_TIER_4

/obj/item/attachable/srs_barrel
	name = "\improper ствол снайперской винтовки SRS99-AM"
	desc = "Съёмный ствол снайперской винтовки SRS99-AM с крупным дульным тормозом на конце. Критически важен для работы винтовки. Благодаря съёмной конструкции может заменяться другими стволами с альтернативными интегрированными модулями."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "srs_barrel"
	attach_icon = "srs_barrel"
	slot = "muzzle"
	size_mod = 0
	flags_attach_features = NO_FLAGS

/obj/item/attachable/srs_barrel/New()
	..()
	scatter_mod = -SCATTER_AMOUNT_TIER_1

/obj/item/attachable/scope/variable_zoom/oracle
	name = "\improper прицел Oracle варианта N"
	desc = "Одна из самых распространённых снайперских оптических систем ККОН. Позволяет переключаться между разными режимами увеличения. Некоторые версии даже оснащены приборами ночного видения."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "oracle_scope"
	attach_icon = "oracle_scope"
	slot = "rail"

/obj/item/attachable/scope/variable_zoom/m6d
	name = "\improper умный прицел KFA-2/D Model II"
	desc = "Умный прицел, предназначенный для установки на магнум M6D. Версия Model II заметно точнее и позволяет переключаться между двухкратным и четырёхкратным увеличением. Связывается с оптикой ККОН и выводит в HUD прицельную марку и счётчик боезапаса."
	slot = "rail"

/obj/item/attachable/srs_assembly
	name = "\improper сборка SRS99-AM"
	desc = "Эта часть не должна сниматься. Пожалуй, стоит сообщить об этом начальству..."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "srs_assembly"
	attach_icon = "srs_assembly"
	slot = "special"
	flags_attach_features = NO_FLAGS

/obj/item/attachable/bipod/srs_bipod
	name = "\improper сошки SRS99-AM"
	desc = "Съёмная система сошек для снайперской винтовки SRS99-AM. Зачем вообще снимать их с такой громоздкой винтовки - отдельная загадка."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "srs_bipod"
	attach_icon = "srs_bipod"
	flags_attach_features = NO_FLAGS

/obj/item/attachable/scope/mini/smartscope
	name = "\improper умный прицел KFA-2 x2"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = null
	slot = "rail"
	zoom_offset = 3

/obj/item/attachable/scope/mini/smartscope/m6g
	name = "\improper умный прицел KFA-2/G"
	desc = "Умный прицел для магнума M6G, обеспечивающий расширенные режимы увеличения и связь с оптикой ККОН для вывода в HUD прицельной марки и счётчика боезапаса."
	icon_state = "m6c_smartscope_obj"
	attach_icon = "m6g_smartscope"

/obj/item/attachable/scope/mini/smartscope/m6c
	name = "\improper умный прицел KFA-2/C"
	desc = "Умный прицел для магнума M6C, обеспечивающий расширенные режимы увеличения и связь с оптикой ККОН для вывода в HUD прицельной марки и счётчика боезапаса."
	icon_state = "m6c_smartscope_obj"
	attach_icon = "m6c_smartscope"

/obj/item/attachable/flashlight/m6
	name = "\improper фонарь M6"
	desc = "Фонарь M6. О нём особенно нечего сказать: он просто включается и выключается."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "flashlight"
	attach_icon = "m6g_light"
	original_state = "flashlight"
	original_attach = "m6g_light"
	slot = "under"

/obj/item/attachable/flashlight/m6/Attach(obj/item/weapon/gun/subject)
	if(istype(subject, /obj/item/weapon/gun/pistol/halo/m6g))
		attach_icon = "m6g_light"
		original_attach = "m6g_light"
		..()
	if(istype(subject, /obj/item/weapon/gun/pistol/halo/m6c))
		attach_icon = "m6c_light"
		original_attach = "m6c_light"
		..()
	if(istype(subject, /obj/item/weapon/gun/pistol/halo/m6d))
		attach_icon = "m6d_light"
		original_attach = "m6d_light"
		..()
	else return

/obj/item/attachable/flashlight/m6c_socom
	name = "\improper фонарь/лазерный целеуказатель M6C/SOCOM"
	desc = "Штатный модуль для всех моделей M6C/SOCOM, сочетающий фонарь и лазерный целеуказатель. Может устанавливаться только на пистолеты серии M6C/SOCOM из-за изменённых точек крепления."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "socom_under"
	attach_icon = "socom_under"
	original_state = "socom_under"
	original_attach = "socom_under"
	slot = "under"

/obj/item/attachable/flashlight/m6c_socom/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_1
	movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
	scatter_mod = -SCATTER_AMOUNT_TIER_10
	scatter_unwielded_mod = -SCATTER_AMOUNT_TIER_9
	accuracy_unwielded_mod = HIT_ACCURACY_MULT_TIER_1

/obj/item/attachable/suppressor/m6c_socom
	name = "\improper глушитель M6C/SOCOM"
	desc = "Съёмный глушитель, который можно установить только на пистолеты серии M6C/SOCOM из-за изменённых точек крепления."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "socom_barrel"
	attach_icon = "socom_barrel"
	hud_offset_mod = -3
	new_fire_sound = "gun_socom"

/obj/item/attachable/suppressor/m6c_socom/New()
	return

/obj/item/attachable/suppressor/m7
	name = "\improper глушитель M7/SOCOM"
	desc = "Съёмный глушитель для комплекта модернизации M7/SOCOM."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m7_suppressor"
	attach_icon = "m7_suppressor"
	hud_offset_mod = -3
	new_fire_sound = "gun_socom_smg"

/obj/item/attachable/suppressor/m7/New()
	return

/obj/item/attachable/reddot/m7
	name = "\improper коллиматор M7/SOCOM"
	desc = "Коллиматорный прицел для комплекта модернизации M7/SOCOM."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m7_red_dot"
	attach_icon = "m7_red_dot"

/obj/item/attachable/flashlight/m7
	name = "\improper фонарь M7"
	desc = "Боковой фонарь для установки на пистолет-пулемёт M7."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m7_flashlight"
	attach_icon = "m7_flashlight"
	original_state = "m7_flashlight"
	original_attach = "m7_flashlight"
	slot = "special"
	layer_addition = 0.1

/obj/item/attachable/stock/m7
	name = "складной приклад M7 SMG"
	desc = "Складной приклад для M7 SMG. В разложенном виде он мешает стрельбе одной рукой и уже не помещается в ремни, зато заметно улучшает точность и разброс оружия."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m7_stock"
	attach_icon = "m7_stock"
	w_class = SIZE_TINY
	flags_attach_features = ATTACH_ACTIVATION
	collapsible = TRUE
	stock_activated = FALSE
	collapse_delay  = 0.5 SECONDS
	attachment_action_type = /datum/action/item_action/toggle
	slot = "stock"

/obj/item/attachable/stock/m7/New()
	..()

	accuracy_mod = 0
	scatter_mod = 0
	movement_onehanded_acc_penalty_mod = 0
	accuracy_unwielded_mod = 0
	scatter_unwielded_mod = 0
	wield_delay_mod = 0
	recoil_unwielded_mod = 0
	size_mod = 2

/obj/item/attachable/stock/m7/apply_on_weapon(obj/item/weapon/gun/gun)
	if(stock_activated)
		//folded up
		accuracy_mod = HIT_ACCURACY_MULT_TIER_2
		scatter_mod = -SCATTER_AMOUNT_TIER_9
		movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
		accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_4
		scatter_unwielded_mod = SCATTER_AMOUNT_TIER_6
		recoil_unwielded_mod = RECOIL_AMOUNT_TIER_5
		icon_state = "m7_stock-on"
		attach_icon = "m7_stock-on"
		size_mod = 2
		wield_delay_mod = WIELD_DELAY_VERY_FAST

	else
		accuracy_mod = 0
		recoil_mod = 0
		scatter_mod = 0
		movement_onehanded_acc_penalty_mod = 0
		accuracy_unwielded_mod = 0
		scatter_unwielded_mod = 0
		icon_state = "m7_stock"
		attach_icon = "m7_stock"
		size_mod = 0
		wield_delay_mod = WIELD_DELAY_NONE //stock is folded so no wield delay
		recoil_unwielded_mod = 0

	gun.recalculate_attachment_bonuses()
	gun.update_overlays(src, "stock")

/obj/item/attachable/stock/m7/grip
	name = "складная рукоять M7 SMG"
	desc = "Складная рукоять, штатно устанавливаемая на M7 SMG. В сложенном виде делает оружие компактнее и быстрее в приведении, но немного ухудшает точность и разброс."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_attachments.dmi'
	icon_state = "m7_grip"
	attach_icon = "m7_grip-on"
	flags_attach_features = ATTACH_ACTIVATION
	collapsible = TRUE
	stock_activated = FALSE
	collapse_delay  = 0.5 SECONDS
	attachment_action_type = /datum/action/item_action/toggle
	slot = "under"

/obj/item/attachable/stock/m7/grip/New()
	..()

	accuracy_mod = 0
	scatter_mod = 0
	movement_onehanded_acc_penalty_mod = 0
	accuracy_unwielded_mod = 0
	scatter_unwielded_mod = 0
	wield_delay_mod = 0
	recoil_unwielded_mod = 0
	size_mod = 0
	icon_state = "m7_grip-on"
	attach_icon = "m7_grip-on"

/obj/item/attachable/stock/m7/grip/apply_on_weapon(obj/item/weapon/gun/gun)
	if(stock_activated)
		//folded down
		accuracy_mod = HIT_ACCURACY_MULT_TIER_2
		scatter_mod = -SCATTER_AMOUNT_TIER_9
		movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
		accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_3
		scatter_unwielded_mod = SCATTER_AMOUNT_TIER_7
		recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_5
		icon_state = "m7_grip"
		attach_icon = "m7_grip"
		wield_delay_mod = WIELD_DELAY_NONE
		size_mod = 1

	else
		accuracy_mod = 0
		recoil_mod = 0
		scatter_mod = 0
		movement_onehanded_acc_penalty_mod = 0
		accuracy_unwielded_mod = 0
		scatter_unwielded_mod = 0
		icon_state = "m7_grip-on"
		attach_icon = "m7_grip-on"
		wield_delay_mod = 0 //stock is folded up so no wield delay
		recoil_unwielded_mod = 0
		size_mod = 0

	gun.recalculate_attachment_bonuses()
	gun.update_overlays(src, "under")

/obj/item/attachable/stock/m7/grip/folded_down
	stock_activated = TRUE
	attach_icon = "m7_grip"

/obj/item/attachable/stock/m7/grip/folded_down/New()
	..()

	accuracy_mod = HIT_ACCURACY_MULT_TIER_2
	scatter_mod = -SCATTER_AMOUNT_TIER_9
	movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
	accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_3
	scatter_unwielded_mod = SCATTER_AMOUNT_TIER_7
	recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_5
	icon_state = "m7_grip"
	attach_icon = "m7_grip"
	wield_delay_mod = WIELD_DELAY_NONE
	size_mod = 1
