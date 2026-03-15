//===========================//MAIN UNSC PREP\\================================\\

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc
	name = "\improper автомат формы ККОН"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/populate_product_list(scale)
	listed_products = list(
		list("СТАНДАРТНОЕ СНАРЯЖЕНИЕ", -1, null, null, null),
		list("Боевые ботинки морпеха", floor(scale * 15), /obj/item/clothing/shoes/marine/knife, VENDOR_ITEM_REGULAR),
		list("Униформа морпеха, адаптивный камуфляж", floor(scale * 15), /obj/item/clothing/under/marine, VENDOR_ITEM_REGULAR),
		list("Униформа морпеха, джунглевый BDU", floor(scale * 15), /obj/item/clothing/under/marine/standard, VENDOR_ITEM_REGULAR),
		list("Боевые перчатки морпеха", floor(scale * 15), /obj/item/clothing/gloves/marine, VENDOR_ITEM_REGULAR),
		list("Радиогарнитура морпеха", floor(scale * 15), /obj/item/device/radio/headset/almayer/marine/solardevils, VENDOR_ITEM_REGULAR),
		list("Шлем морпеха образца CH252", floor(scale * 15), /obj/item/clothing/head/helmet/marine/unsc, VENDOR_ITEM_REGULAR),
		list("Гарнитура с камерой образца M5", floor(scale * 15), /obj/item/device/overwatch_camera, VENDOR_ITEM_REGULAR),
		list("Служебная кепка, джунгли", floor(scale * 15), /obj/item/clothing/head/cmcap, VENDOR_ITEM_REGULAR),
		list("Служебная кепка, снег", floor(scale * 15), /obj/item/clothing/head/cmcap/snow, VENDOR_ITEM_REGULAR),
		list("Служебная кепка, пустыня", floor(scale * 15), /obj/item/clothing/head/cmcap/desert, VENDOR_ITEM_REGULAR),
		list("Оперативная кепка, зелёная", floor(scale * 15), /obj/item/clothing/head/cmcap/bridge, VENDOR_ITEM_REGULAR),
		list("Оперативная кепка, песочная", floor(scale * 15), /obj/item/clothing/head/cmcap/bridge/tan, VENDOR_ITEM_REGULAR),
		list("Панама, джунгли", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie, VENDOR_ITEM_REGULAR),
		list("Панама, пустыня", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie/tan, VENDOR_ITEM_REGULAR),
		list("Стрелковые очки ККОН", floor(scale * 15), /obj/item/clothing/glasses/sunglasses/big/unsc, VENDOR_ITEM_REGULAR),

		list("РАЗГРУЗКА", -1, null, null),
		list("Разгрузка образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b, VENDOR_ITEM_REGULAR),
		list("Разгрузка под магазины образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/mag, VENDOR_ITEM_REGULAR),
		list("Разгрузка под дробовые патроны образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/shotgun, VENDOR_ITEM_REGULAR),
		list("Гранатная разгрузка M40 образца M52B", 0.75, /obj/item/clothing/accessory/storage/webbing/m52b/grenade, VENDOR_ITEM_REGULAR),
		list("Разгрузка под малые подсумки образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/small, VENDOR_ITEM_REGULAR),
		list("Сбросной подсумок", 4, /obj/item/clothing/accessory/storage/droppouch, VENDOR_ITEM_REGULAR),
		list("Набедренный подсумок", 4, /obj/item/clothing/accessory/storage/smallpouch, VENDOR_ITEM_REGULAR),
		list("Плечевая кобура", round(max(1,(scale * 0.5))), /obj/item/clothing/accessory/storage/holster, VENDOR_ITEM_REGULAR),

		list("БРОНЯ", -1, null, null),
		list("Стандартный комплект брони M52B", round(scale * 15), /obj/item/storage/box/guncase/m52barmor, VENDOR_ITEM_REGULAR),
		list("Броня M52B", round(scale * 10), /obj/item/clothing/suit/marine/unsc, VENDOR_ITEM_REGULAR),
		list("Наплечники M52B", round(scale * 10), /obj/item/clothing/accessory/pads/unsc, VENDOR_ITEM_REGULAR),
		list("Паховая пластина M52B", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/groin, VENDOR_ITEM_REGULAR),
		list("Поножи M52B", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/greaves, VENDOR_ITEM_REGULAR),
		list("Наручи M52B", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/bracers, VENDOR_ITEM_REGULAR),
		list("Защита шеи M52B", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/neckguard, VENDOR_ITEM_REGULAR),

		list("РЮКЗАКИ", -1, null, null, null),
		list("Рюкзак ККОН", floor(scale * 15), /obj/item/storage/backpack/marine/unsc, VENDOR_ITEM_REGULAR),
		list("Задний подсумок ККОН", floor(scale * 15), /obj/item/storage/backpack/marine/satchel/unsc, VENDOR_ITEM_REGULAR),

		list("ПОЯСА", -1, null, null),
		list("Разгрузка для боеприпасов образца M276", floor(scale * 15), /obj/item/storage/belt/marine, VENDOR_ITEM_REGULAR),
		list("Гранатная разгрузка образца M276", floor(scale * 10), /obj/item/storage/belt/grenade, VENDOR_ITEM_REGULAR),
		list("Кобура под пистолет M6", floor(scale * 15), /obj/item/storage/belt/gun/m6, VENDOR_ITEM_REGULAR),
		list("Кобура образца M276 под M82F", floor(scale * 5), /obj/item/storage/belt/gun/flaregun, VENDOR_ITEM_REGULAR),
		list("Универсальный подсумок M276 G8-A", floor(scale * 15), /obj/item/storage/backpack/general_belt, VENDOR_ITEM_REGULAR),

		list("ПОДСУМКИ", -1, null, null, null),
		list("Подсумок первой помощи", floor(scale * 15), /obj/item/storage/pouch/firstaid, VENDOR_ITEM_REGULAR),
		list("Подсумок для фальшфейеров (полный)", floor(scale * 15), /obj/item/storage/pouch/flare/full, VENDOR_ITEM_REGULAR),
		list("Крупный подсумок для магазинов", floor(scale * 15), /obj/item/storage/pouch/magazine/large, VENDOR_ITEM_REGULAR),
		list("Средний универсальный подсумок", floor(scale * 15), /obj/item/storage/pouch/general/medium, VENDOR_ITEM_REGULAR),
		list("Подсумок для пистолетных магазинов", floor(scale * 15), /obj/item/storage/pouch/magazine/pistol/unsc, VENDOR_ITEM_REGULAR),
		list("Пистолетный подсумок", floor(scale * 15), /obj/item/storage/pouch/pistol/unsc, VENDOR_ITEM_REGULAR),

		list("ОГРАНИЧЕННЫЕ ПОДСУМКИ", -1, null, null, null),
		list("Строительный подсумок", 1.25, /obj/item/storage/pouch/construction, VENDOR_ITEM_REGULAR),
		list("Взрывной подсумок", 1.25, /obj/item/storage/pouch/explosive, VENDOR_ITEM_REGULAR),
		list("Подсумок экстренного реагирования", 2.5, /obj/item/storage/pouch/first_responder, VENDOR_ITEM_REGULAR),
		list("Крупный подсумок для пистолетных магазинов", floor(scale * 2), /obj/item/storage/pouch/magazine/pistol/unsc/large, VENDOR_ITEM_REGULAR),
		list("Подсумок для инструментов", 1.25, /obj/item/storage/pouch/tools, VENDOR_ITEM_REGULAR),
		list("Подсумок-слинг", 1.25, /obj/item/storage/pouch/sling, VENDOR_ITEM_REGULAR),

		list("МАСКИ", -1, null, null, null),
		list("Противогаз M5", floor(scale * 15), /obj/item/clothing/mask/gas/military, VENDOR_ITEM_REGULAR),
		list("Тактический шарф", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf/tacticalmask, VENDOR_ITEM_REGULAR),
		list("Теплопоглощающий подшлемник", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf, VENDOR_ITEM_REGULAR),

		list("ПРОЧЕЕ", -1, null, null, null),
		list("Баллистические очки", round(scale * 10), /obj/item/clothing/glasses/mgoggles, VENDOR_ITEM_REGULAR),
		list("Баллистические очки, солнцезащитные", round(scale * 10), /obj/item/clothing/glasses/mgoggles/black, VENDOR_ITEM_REGULAR),
		list("Баллистические очки, лазерозащитные (коричневые)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/orange, VENDOR_ITEM_REGULAR),
		list("Баллистические очки, лазерозащитные (зелёные)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/green, VENDOR_ITEM_REGULAR),
		list("Оружейная смазка", round(scale * 15), /obj/item/prop/helmetgarb/gunoil, VENDOR_ITEM_REGULAR),
		list("Спальник LRRP", round(scale * 15), /obj/item/roller/bedroll, VENDOR_ITEM_REGULAR),
		list("Штатный компас морпеха", round(scale * 15), /obj/item/prop/helmetgarb/compass, VENDOR_ITEM_REGULAR),
		)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc
	name = "\improper автомат взводного снаряжения ККОН"

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/populate_product_list(scale)
	listed_products = list(
		list("ЕДА", -1, null, null),
		list("MRE", floor(scale * 5), /obj/item/storage/box/mre, VENDOR_ITEM_REGULAR),
		list("Коробка MRE", floor(scale * 1), /obj/item/ammo_box/magazine/misc/unsc/mre, VENDOR_ITEM_REGULAR),

		list("МЕДИЦИНА", -1, null, null),
		list("Марля", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Мазь", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Шины", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),

		list("ИНСТРУМЕНТЫ", -1, null, null),
		list("Сапёрная лопатка (ET)", round(scale * 2), /obj/item/tool/shovel/etool/folded, VENDOR_ITEM_REGULAR),
		list("Отвёртка", round(scale * 5), /obj/item/tool/screwdriver, VENDOR_ITEM_REGULAR),
		list("Кусачки", round(scale * 5), /obj/item/tool/wirecutters, VENDOR_ITEM_REGULAR),
		list("Ломик", round(scale * 5), /obj/item/tool/crowbar, VENDOR_ITEM_REGULAR),
		list("Гаечный ключ", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Мультитул", round(scale * 1), /obj/item/device/multitool, VENDOR_ITEM_REGULAR),
		list("Сварочный аппарат", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("ВЗРЫВЧАТКА", -1, null, null),
		list("Пластичная взрывчатка", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Подрывной заряд", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("СВЕТ И СИГНАЛЫ", -1, null, null),
		list("Боевой фонарь", round(scale * 5), /obj/item/device/flashlight/combat, VENDOR_ITEM_REGULAR),
		list("Коробка фонарей", round(scale * 1), /obj/item/ammo_box/magazine/misc/flashlight, VENDOR_ITEM_REGULAR),
		list("Коробка фальшфейеров", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares, VENDOR_ITEM_REGULAR),
		list("Упаковка маркировочных фальшфейеров M94", round(scale * 10), /obj/item/storage/box/flare, VENDOR_ITEM_REGULAR),
		list("Упаковка сигнальных фальшфейеров M89-S", round(scale * 1), /obj/item/storage/box/flare/signal, VENDOR_ITEM_REGULAR),

		list("БОКОВОЕ ОРУЖИЕ", -1, null, null),
		list("Служебный магнум M6C", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6c/unloaded, VENDOR_ITEM_REGULAR),
		list("Служебный магнум M6G", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6g/unloaded, VENDOR_ITEM_REGULAR),
		list("Умный прицел KFA-2/G", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6g, VENDOR_ITEM_REGULAR),
		list("Умный прицел KFA-2/C", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6c, VENDOR_ITEM_REGULAR),
		list("Фонарь M6", round(scale * 4), /obj/item/attachable/flashlight/m6, VENDOR_ITEM_REGULAR),
		list("Ракетница M82F", round(scale * 1), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("ПРОЧЕЕ", -1, null, null),
		list("Огнетушитель", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Переносной огнетушитель", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Каталка", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Ножны для мачете (полные)", round(scale * 5), /obj/item/storage/large_holster/machete/full, VENDOR_ITEM_REGULAR),
		list("Тактический монокуляр", round(scale * 2), /obj/item/device/binoculars/range/monocular, VENDOR_ITEM_REGULAR),
		list("Боевой нож M13", round(scale * 25), /obj/item/weapon/knife/marine, VENDOR_ITEM_REGULAR),
		)

//===========================//ODST PREP\\================================\\

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/odst
	name = "\improper автомат формы ODST ККОН"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/odst/populate_product_list(scale)
	listed_products = list(
		list("СТАНДАРТНОЕ СНАРЯЖЕНИЕ", -1, null, null, null),
		list("Боевые ботинки ККОН", floor(scale * 15), /obj/item/clothing/shoes/marine/jungle/knife, VENDOR_ITEM_REGULAR),
		list("Нательный костюм ODST", floor(scale * 15), /obj/item/clothing/under/marine/odst, VENDOR_ITEM_REGULAR),
		list("Боевые перчатки морпеха", floor(scale * 15), /obj/item/clothing/gloves/marine, VENDOR_ITEM_MANDATORY),
		list("Гарнитура ODST", floor(scale * 15), /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/ferrymen, VENDOR_ITEM_REGULAR),
		list("Гарнитура с камерой образца M5", floor(scale * 15), /obj/item/device/overwatch_camera, VENDOR_ITEM_REGULAR),
		list("Патрульная кепка, джунглевый BDU", floor(scale * 15), /obj/item/clothing/head/cmcap, VENDOR_ITEM_REGULAR),
		list("Панама, джунглевый BDU", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie, VENDOR_ITEM_REGULAR),

		list("РАЗГРУЗКА", -1, null, null),
		list("Разгрузка образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b, VENDOR_ITEM_REGULAR),
		list("Разгрузка под магазины образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/mag, VENDOR_ITEM_REGULAR),
		list("Разгрузка под дробовые патроны образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/shotgun, VENDOR_ITEM_REGULAR),
		list("Гранатная разгрузка M40 образца M52B", 0.75, /obj/item/clothing/accessory/storage/webbing/m52b/grenade, VENDOR_ITEM_REGULAR),
		list("Разгрузка под малые подсумки образца M52B", 2, /obj/item/clothing/accessory/storage/webbing/m52b/small, VENDOR_ITEM_REGULAR),
		list("Сбросной подсумок", 4, /obj/item/clothing/accessory/storage/droppouch, VENDOR_ITEM_REGULAR),
		list("Набедренный подсумок", 4, /obj/item/clothing/accessory/storage/smallpouch, VENDOR_ITEM_REGULAR),
		list("Плечевая кобура", round(max(1,(scale * 0.5))), /obj/item/clothing/accessory/storage/holster, VENDOR_ITEM_REGULAR),

		list("БРОНЯ", -1, null, null),
		list("Шлем ODST CH381", floor(scale * 15), /obj/item/clothing/head/helmet/marine/unsc/odst, VENDOR_ITEM_MANDATORY),
		list("Стандартный комплект M70DT ODST BDU", round(scale * 15), /obj/item/storage/box/guncase/odstarmor, VENDOR_ITEM_MANDATORY),
		list("Комплект M70DT ODST BDU", round(scale * 10), /obj/item/clothing/suit/marine/unsc/odst, VENDOR_ITEM_REGULAR),
		list("Наплечники M70DT", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/odst, VENDOR_ITEM_REGULAR),
		list("Паховая пластина M70DT", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/groin/odst, VENDOR_ITEM_REGULAR),
		list("Поножи M70DT", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/greaves/odst, VENDOR_ITEM_REGULAR),
		list("Наручи M70DT", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/bracers/odst, VENDOR_ITEM_REGULAR),

		list("РЮКЗАКИ", -1, null, null, null),
		list("Рюкзак ККОН", floor(scale * 15), /obj/item/storage/backpack/marine/unsc, VENDOR_ITEM_REGULAR),
		list("Задний подсумок ККОН", floor(scale * 15), /obj/item/storage/backpack/marine/satchel/unsc, VENDOR_ITEM_REGULAR),

		list("ПОЯСА", -1, null, null),
		list("Разгрузка для боеприпасов образца M276", floor(scale * 15), /obj/item/storage/belt/marine, VENDOR_ITEM_REGULAR),
		list("Гранатная разгрузка образца M276", floor(scale * 10), /obj/item/storage/belt/grenade, VENDOR_ITEM_REGULAR),
		list("Кобура под пистолет M6", floor(scale * 15), /obj/item/storage/belt/gun/m6, VENDOR_ITEM_REGULAR),
		list("Кобура образца M276 под M82F", floor(scale * 5), /obj/item/storage/belt/gun/flaregun, VENDOR_ITEM_REGULAR),
		list("Универсальный подсумок M276 G8-A", floor(scale * 15), /obj/item/storage/backpack/general_belt, VENDOR_ITEM_REGULAR),
		list("Кобура под M7", floor(scale * 15), /obj/item/storage/belt/gun/m7, VENDOR_ITEM_REGULAR),

		list("ПОДСУМКИ", -1, null, null, null),
		list("Подсумок первой помощи", floor(scale * 15), /obj/item/storage/pouch/firstaid, VENDOR_ITEM_REGULAR),
		list("Подсумок для фальшфейеров (полный)", floor(scale * 15), /obj/item/storage/pouch/flare/full, VENDOR_ITEM_REGULAR),
		list("Крупный подсумок для магазинов", floor(scale * 15), /obj/item/storage/pouch/magazine/large, VENDOR_ITEM_REGULAR),
		list("Средний универсальный подсумок", floor(scale * 15), /obj/item/storage/pouch/general/medium, VENDOR_ITEM_REGULAR),
		list("Подсумок для пистолетных магазинов", floor(scale * 15), /obj/item/storage/pouch/magazine/pistol/unsc, VENDOR_ITEM_REGULAR),
		list("Пистолетный подсумок", floor(scale * 15), /obj/item/storage/pouch/pistol/unsc, VENDOR_ITEM_REGULAR),

		list("ОГРАНИЧЕННЫЕ ПОДСУМКИ", -1, null, null, null),
		list("Строительный подсумок", 1.25, /obj/item/storage/pouch/construction, VENDOR_ITEM_REGULAR),
		list("Взрывной подсумок", 1.25, /obj/item/storage/pouch/explosive, VENDOR_ITEM_REGULAR),
		list("Подсумок экстренного реагирования", 2.5, /obj/item/storage/pouch/first_responder, VENDOR_ITEM_REGULAR),
		list("Крупный подсумок для пистолетных магазинов", floor(scale * 2), /obj/item/storage/pouch/magazine/pistol/unsc/large, VENDOR_ITEM_REGULAR),
		list("Подсумок для инструментов", 1.25, /obj/item/storage/pouch/tools, VENDOR_ITEM_REGULAR),
		list("Подсумок-слинг", 1.25, /obj/item/storage/pouch/sling, VENDOR_ITEM_REGULAR),

		list("МАСКИ", -1, null, null, null),
		list("Противогаз M5", floor(scale * 15), /obj/item/clothing/mask/gas/military, VENDOR_ITEM_REGULAR),
		list("Тактический шарф", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf/tacticalmask, VENDOR_ITEM_REGULAR),
		list("Теплопоглощающий подшлемник", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf, VENDOR_ITEM_REGULAR),
		)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/odst
	name = "\improper автомат взводного снаряжения ODST ККОН"

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/odst/populate_product_list(scale)
	listed_products = list(
		list("ЕДА", -1, null, null),
		list("MRE", floor(scale * 5), /obj/item/storage/box/mre, VENDOR_ITEM_REGULAR),
		list("Коробка MRE", floor(scale * 1), /obj/item/ammo_box/magazine/misc/unsc/mre, VENDOR_ITEM_REGULAR),

		list("МЕДИЦИНА", -1, null, null),
		list("Марля", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Мазь", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Шины", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),

		list("ИНСТРУМЕНТЫ", -1, null, null),
		list("Сапёрная лопатка (ET)", round(scale * 2), /obj/item/tool/shovel/etool/folded, VENDOR_ITEM_REGULAR),
		list("Отвёртка", round(scale * 5), /obj/item/tool/screwdriver, VENDOR_ITEM_REGULAR),
		list("Кусачки", round(scale * 5), /obj/item/tool/wirecutters, VENDOR_ITEM_REGULAR),
		list("Ломик", round(scale * 5), /obj/item/tool/crowbar, VENDOR_ITEM_REGULAR),
		list("Гаечный ключ", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Мультитул", round(scale * 1), /obj/item/device/multitool, VENDOR_ITEM_REGULAR),
		list("Сварочный аппарат", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("ВЗРЫВЧАТКА", -1, null, null),
		list("Пластичная взрывчатка", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Подрывной заряд", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("СВЕТ И СИГНАЛЫ", -1, null, null),
		list("Боевой фонарь", round(scale * 5), /obj/item/device/flashlight/combat, VENDOR_ITEM_REGULAR),
		list("Коробка фонарей", round(scale * 1), /obj/item/ammo_box/magazine/misc/flashlight, VENDOR_ITEM_REGULAR),
		list("Коробка фальшфейеров", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares, VENDOR_ITEM_REGULAR),
		list("Упаковка маркировочных фальшфейеров M94", round(scale * 10), /obj/item/storage/box/flare, VENDOR_ITEM_REGULAR),
		list("Упаковка сигнальных фальшфейеров M89-S", round(scale * 1), /obj/item/storage/box/flare/signal, VENDOR_ITEM_REGULAR),

		list("БОКОВОЕ ОРУЖИЕ", -1, null, null),
		list("Магнум M6C/SOCOM", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6c/socom/unloaded, VENDOR_ITEM_REGULAR),
		list("Пистолет-пулемёт M7/SOCOM", round(scale * 4), /obj/item/weapon/gun/smg/halo/m7/socom/folded_up, VENDOR_ITEM_REGULAR),
		list("Умный прицел KFA-2/G", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6g, VENDOR_ITEM_REGULAR),
		list("Фонарь M6", round(scale * 4), /obj/item/attachable/flashlight/m6, VENDOR_ITEM_REGULAR),
		list("Ракетница M82F", round(scale * 1), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("ПРОЧЕЕ", -1, null, null),
		list("Огнетушитель", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Переносной огнетушитель", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Каталка", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Ножны для мачете (полные)", round(scale * 5), /obj/item/storage/large_holster/machete/full, VENDOR_ITEM_REGULAR),
		list("Тактический монокуляр", round(scale * 2), /obj/item/device/binoculars/range/monocular, VENDOR_ITEM_REGULAR),
		list("Боевой нож M13", round(scale * 25), /obj/item/weapon/knife/marine, VENDOR_ITEM_REGULAR),
		)

//===========================//CORPSMAN\\================================\\

GLOBAL_LIST_INIT(cm_vending_clothing_medic_unsc, list(

		list("ОСНОВНОЕ", 0, null, null, null),
		list("Основной меднабор", 0, /obj/effect/essentials_set/medic/unsc, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),

		list("МЕДИЦИНСКАЯ ОПТИКА (ВЫБЕРИТЕ 1)", 0, null, null, null),
		list("Медицинский визор на шлем", 0, /obj/item/device/helmet_visor/medical/advanced, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_RECOMMENDED),
		list("Медицинские HUD-очки", 0, /obj/item/clothing/glasses/hud/health, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_RECOMMENDED),
		list("Визор боевого медика Mark 2", 0, /obj/item/clothing/glasses/night/medhud/no_nvg, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),

		list("ПОЯС (ВЫБЕРИТЕ 1)", 0, null, null, null),
		list("Сумка спасателя M8A (полная)", 0, /obj/item/storage/belt/medical/lifesaver/unsc/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("Медразгрузка M8A (полная)", 0, /obj/item/storage/belt/medical/unsc/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("Сумка спасателя M8A (пустая)", 0, /obj/item/storage/belt/medical/lifesaver/unsc, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("Медразгрузка M8A (пустая)", 0, /obj/item/storage/belt/medical/unsc, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),

		list("ПОДСУМКИ (ВЫБЕРИТЕ 2)", 0, null, null, null),
		list("Подсумок для фальшфейеров (полный)", 0, /obj/item/storage/pouch/flare/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Подсумок-слинг", 0, /obj/item/storage/pouch/sling, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Крупный подсумок для пистолетных магазинов", 0, /obj/item/storage/pouch/magazine/pistol/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Подсумок для магазинов", 0, /obj/item/storage/pouch/magazine, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Подсумок для дробовых патронов", 0, /obj/item/storage/pouch/shotgun, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Подсумок меднабора", 0, /obj/item/storage/pouch/medkit/unsc, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Пистолетный подсумок", 0, /obj/item/storage/pouch/pistol/unsc, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("АКСЕССУАРЫ (ВЫБЕРИТЕ 1)", 0, null, null, null),
		list("Разгрузка образца M52B", 0, /obj/item/clothing/accessory/storage/webbing/m3, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Разгрузка под магазины образца M52B", 0, /obj/item/clothing/accessory/storage/webbing/m3/mag, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Разгрузка под дробовые патроны образца M52B", 0, /obj/item/clothing/accessory/storage/webbing/m3/shotgun, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Гранатная разгрузка образца M52B", 0, /obj/item/clothing/accessory/storage/webbing/m3/m40, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Разгрузка под малые подсумки образца M52B", 0, /obj/item/clothing/accessory/storage/webbing/m3/small, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_RECOMMENDED),
		list("Плечевая кобура", 0, /obj/item/clothing/accessory/storage/holster, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Сбросной подсумок", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/medic/unsc
	name = "\improper стойка медицинского снаряжения взвода ККОН"

/obj/structure/machinery/cm_vending/clothing/medic/unsc/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_medic_unsc

//===========================//PRESETS\\================================\\

/obj/effect/essentials_set/medic/unsc
	spawned_gear_list = list(
		/obj/item/storage/firstaid/unsc/corpsman,
		/obj/item/storage/firstaid/unsc/corpsman,
		/obj/item/device/healthanalyzer/halo,
		/obj/item/tool/surgery/surgical_line,
		/obj/item/tool/surgery/synthgraft,
		/obj/item/storage/surgical_case/regular,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/accessory/stethoscope,
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/antidote,
	)

/obj/item/storage/box/guncase/m52barmor //forgive me, father
	name = "\improper кейс брони M52B"
	desc = "Кейс со штатными компонентами комплекта бронезащиты M52B для ККОН. Отдельно части не выдаются."
	can_hold = list(/obj/item/clothing/suit/marine/unsc, /obj/item/clothing/accessory/pads/unsc, /obj/item/clothing/accessory/pads/unsc/greaves)
	storage_slots = 3

/obj/item/storage/box/guncase/m52barmor/fill_preset_inventory()
	new /obj/item/clothing/suit/marine/unsc(src)
	new /obj/item/clothing/accessory/pads/unsc(src)
	new /obj/item/clothing/accessory/pads/unsc/greaves(src)

/obj/item/storage/box/guncase/odstarmor //forgive me, father, SECOND edition
	name = "\improper кейс комплекта M70DT ODST BDU"
	desc = "Кейс со штатными компонентами комплекта M70DT ODST BDU для ККОН. Отдельно части не выдаются."
	can_hold = list(/obj/item/clothing/suit/marine/unsc/odst, /obj/item/clothing/accessory/pads/unsc/odst, /obj/item/clothing/accessory/pads/unsc/greaves/odst, /obj/item/clothing/accessory/pads/unsc/groin/odst, /obj/item/clothing/accessory/pads/unsc/bracers/odst)
	storage_slots = 5

/obj/item/storage/box/guncase/odstarmor/fill_preset_inventory()
	new /obj/item/clothing/suit/marine/unsc/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/greaves/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/groin/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/bracers/odst(src)
