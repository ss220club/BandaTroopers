/obj/item/clothing/suit/marine/unggoy
	name = "заглушка боевой сбруи унггоя"
	desc = "Боевая сбруя, подогнанная под унггоя. Заглушка."
	slowdown = SLOWDOWN_ARMOR_LIGHT

	icon = 'icons/halo/obj/items/clothing/covenant/armor.dmi'
	icon_state = "unggoy_minor"
	item_state = "unggoy_minor"

	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/unggoy/armor.dmi'
	)
	allowed_species_list = list(SPECIES_UNGGOY)

	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW

	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE

/obj/item/clothing/suit/marine/unggoy/minor
	name = "боевая сбруя унггоя-минор"
	desc = "Боевая сбруя для воинов-унггоев, выполненная из прочного наноламинатного композита и окрашенная в соответствии с рангом владельца. Из-за веса метанового баллона, который обычно крепится к сбруе, реальная площадь бронирования остаётся сравнительно небольшой и прикрывает в основном грудь, талию и плечи. <b>Этот вариант указывает, что владелец - унггой-минор.</b>"

/obj/item/clothing/suit/marine/unggoy/major
	name = "боевая сбруя унггоя-майор"
	desc = "Красная сбруя обозначает унггоя-майора - более опытного воина, которому обычно доверяют группы миноров. По защитным качествам она не превосходит стандартную оранжевую сбрую низших, но сидит немного удобнее и обеспечивает владельца более качественным метаном."
	desc_lore = "Среди мелких улучшений - более надёжная система связи, позволяющая эффективнее поддерживать контакт с начальством, что отмечают как минус все, кто не является унггоем."
	icon_state = "unggoy_major"
	item_state = "unggoy_major"

/obj/item/clothing/suit/marine/unggoy/heavy
	name = "тяжёлая боевая сбруя унггоя"
	desc = "Эта зелёная боевая сбруя обозначает оператора специального оружия - от плазменных пушек и турелей Shade до топливных стержневых пушек и взрывного вооружения. Оснащена дополнительной подкладкой и особым составом наноламината, чтобы легче переживать взрывной урон от ответного огня противника или, что случается нередко, несчастных случаев."
	icon_state = "unggoy_heavy"
	item_state = "unggoy_heavy"

	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/unggoy/ultra
	name = "боевая сбруя унггоя-ультра"
	desc = "Белая боевая сбруя, обозначающая владельца как ультру - ветерана множества кампаний. Эта броня не только заметно превосходит прочие по материалам и защитным свойствам, но и точно подогнана под хозяина, обеспечивая удобную посадку и более естественную подвижность."
	icon_state = "unggoy_ultra"
	item_state = "unggoy_ultra"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/unggoy/deacon
	name = "сбруя унггоя-дьякона"
	desc = "Сбруя высочайшего качества, предназначенная для служителей министерств, исполняющих обязанности дьяконов при сан'шайуумских владыках. Среди её достоинств - индивидуальная подгонка, более прочные крепления и улучшенный наноламинатный композит, который остаётся лёгким без потери защиты, а иногда даже включает небольшие голографические проекторы для усиления проповедей и церемониальных обязанностей."
	icon_state = "unggoy_deacon"
	item_state = "unggoy_deacon"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/stealth/unggoy_specops
	name = "боевая сбруя унггоя спецопераций"
	desc = "Тёмно-фиолетовая сбруя, предназначенная для тех немногих унггоев, которые соответствуют требованиям Special Warfare Group. Помимо множества улучшений посадки и материалов по сравнению с обычными боевыми комплектами собратьев, вариант Spec-Ops заметно продвинут и в области маскировки."
	desc_lore = "От встроенной пассивной термальной и сенсорной незаметности до способности становиться полностью невидимым во всех спектрах при наличии модуля активного камуфляжа - эта сбруя вполне оправдывает бессчётные ночи тренировок."
	icon_state = "unggoy_specops"
	item_state = "unggoy_specops"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE

	icon = 'icons/halo/obj/items/clothing/covenant/armor.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/unggoy/armor.dmi'
	)
	allowed_species_list = list(SPECIES_UNGGOY)

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra
	name = "боевая сбруя унггоя спецопераций-ультра"
	desc = "Модификация сбруи Spec-Ops, используемая ветеранами и специалистами из Special Warfare Group. Это заметное улучшение по сравнению с обычной спецоперативной сбруей: усиленные композиты рассчитаны уже на прямой бой. Многие считают унггоев трусливыми и слабыми, но немногие из тех, кто увидел этот чёрный комплект, доживают до рассказа об этом - а те, кто доживает, меняют мнение."
	icon_state = "unggoy_specops_ultra"
	item_state = "unggoy_specops_ultra"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
