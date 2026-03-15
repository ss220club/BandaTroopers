/obj/structure/machinery/cm_vending/sorted/marine_food/unsc
	name = "военный пищевой автомат"
	desc = "Автоматизированная станция приготовления и выдачи пищи. Заранее подготавливает еду и напитки для персонала ККОН и автоматически очищает себя и возвращённые в неё подносы. Функцию самоочистки часто отключают, чтобы поддерживать дисциплину среди морпехов."
	icon = 'icons/halo/obj/structures/machinery/vending.dmi'
	icon_state = "top_unsc_food"
	tiles_with = list(
		/obj/structure/window/framed/unsc,
		/obj/structure/machinery/door/airlock,
		/turf/closed/wall/unsc,
	)

/obj/structure/machinery/cm_vending/sorted/marine_food/unsc/alt
	icon_state = "unsc_food"

/obj/structure/machinery/vending/dinnerware/unsc
	name = "\improper автомат военных столовых приборов"
	desc = "В паре с пищевым автоматом эта машина выглядит куда проще и требует лишь ручного пополнения."
	icon = 'icons/halo/obj/structures/machinery/vending.dmi'
	icon_state = "top_unsc_dinnerware"
	icon_vend = "top_unsc_dinnerware_vend"
	icon_deny = "top_unsc_dinnerware_deny"
	tiles_with = list(
		/obj/structure/window/framed/unsc,
		/obj/structure/machinery/door/airlock,
		/turf/closed/wall/unsc,
	)

/obj/structure/machinery/vending/dinnerware/unsc/alt
	icon_state = "unsc_dinnerware"
	icon_vend = "unsc_dinnerware_vend"
	icon_deny = "unsc_dinnerware_deny"

/obj/structure/machinery/cm_vending/sorted/medical/unsc
	name = "\improper военный медавтомат Optican"
	desc = "Автомат по выдаче медикаментов и фармацевтики. Поставляется компанией Optican."
	icon = 'icons/halo/obj/structures/machinery/vending.dmi'
	icon_state = "shipmed"
	vendor_theme = VENDOR_THEME_USCM

/obj/structure/machinery/cm_vending/sorted/medical/unsc/populate_product_list(scale)
	listed_products = list(
		list("ПРЕДМЕТЫ ПЕРВОЙ НЕОБХОДИМОСТИ", -1, null, null),
		list("Шприц", floor(scale * 7), /obj/item/reagent_container/syringe/halo, VENDOR_ITEM_MANDATORY),
		list("Пустая аптечка ККОН", floor(scale * 1), /obj/item/storage/firstaid/unsc/empty, VENDOR_ITEM_REGULAR),
		list("Футляр для шприцов", floor(scale * 2), /obj/item/storage/syringe_case/unsc, VENDOR_ITEM_REGULAR),

		list("ПОЛЕВОЕ СНАРЯЖЕНИЕ", -1, null, null),
		list("Мазь", floor(scale * 10), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Рулон марли", floor(scale * 10), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Шины", floor(scale * 10), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),\

		list("ЛЕЧЕНИЕ ТРАВМ", -1, null, null),
		list("Травмкомплект", floor(scale * 10), /obj/item/stack/medical/advanced/bruise_pack, VENDOR_ITEM_RECOMMENDED),
		list("Автоинъектор (бикаридин)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (бикаридин)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/bicaridine, VENDOR_ITEM_RECOMMENDED),

		list("ЛЕЧЕНИЕ ОЖОГОВ", -1, null, null),
		list("Ожоговый комплект", floor(scale * 10), /obj/item/stack/medical/advanced/ointment, VENDOR_ITEM_RECOMMENDED),
		list("Optican BurnGuard", floor(scale * 9), /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard, VENDOR_ITEM_RECOMMENDED),

		list("ЛЕЧЕНИЕ ГИПОКСИИ", -1, null, null),
		list("Автоинъектор (дексалин+)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/dexalinp/halo, VENDOR_ITEM_RECOMMENDED),
		list("Медицинский флакон (дексалин)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/dexalin, VENDOR_ITEM_REGULAR),

		list("ОБЕЗБОЛИВАНИЕ", -1, null, null),
		list("Автоинъектор (оксикодон)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo, VENDOR_ITEM_REGULAR),
		list("Автоинъектор (трамадол)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/tramadol/halo, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (трамадол)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/tramadol, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (оксикодон)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/oxycodone, VENDOR_ITEM_REGULAR),

		list("ПРОЧЕЕ ЛЕЧЕНИЕ", -1, null, null),
		list("Автоинъектор (инапровалин)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/inaprovaline/halo, VENDOR_ITEM_REGULAR),
		list("Автоинъектор (перидаксон)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/halo_peridaxon, VENDOR_ITEM_REGULAR),
		list("Автоинъектор (диловен)", floor(scale * 5), /obj/item/reagent_container/hypospray/autoinjector/dylovene/halo, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (инапровалин)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/inaprovaline, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (перидаксон)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/peridaxon, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (диловен)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/dylovene, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (хоротазин)", floor(scale * 3), /obj/item/reagent_container/glass/beaker/unsc/chorotazine, VENDOR_ITEM_RECOMMENDED),

		list("МЕДИЦИНСКИЕ ИНСТРУМЕНТЫ", -1, null, null),
		list("Хирургическая леска", floor(scale * 2), /obj/item/tool/surgery/surgical_line, VENDOR_ITEM_REGULAR),
		list("Синт-графт", floor(scale * 2), /obj/item/tool/surgery/synthgraft, VENDOR_ITEM_REGULAR),
		list("Анализатор здоровья", floor(scale * 5), /obj/item/device/healthanalyzer/halo, VENDOR_ITEM_REGULAR),
		list("Медразгрузка M8A", floor(scale * 2), /obj/item/storage/belt/medical/unsc, VENDOR_ITEM_REGULAR),
		list("Сумка спасателя M8A", floor(scale * 2), /obj/item/storage/belt/medical/lifesaver/unsc, VENDOR_ITEM_REGULAR),
		list("Медицинские HUD-очки", floor(scale * 3), /obj/item/clothing/glasses/hud/health, VENDOR_ITEM_REGULAR)
	)

GLOBAL_LIST_INIT(cm_vending_chemical_medic_halo, list(
		list("МЕДИЦИНСКИЕ ФЛАКОНЫ", 0, null, null, null),
		list("Медицинский флакон (железо)", 40, /obj/item/reagent_container/glass/beaker/unsc/iron, null, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (мералин)", 40, /obj/item/reagent_container/glass/beaker/unsc/meralyne, null, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (дермалин)", 40, /obj/item/reagent_container/glass/beaker/unsc/dermaline, null, VENDOR_ITEM_REGULAR),
		list("Медицинский флакон (дексалин+)", 40, /obj/item/reagent_container/glass/beaker/unsc/dexplus, null, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/gear/medic_chemical/unsc
	name = "\improper военный химавтомат Optican"
	desc = "Автоматизированная стойка со специализированной химией для госпитального корсмана ККОН."
	icon = 'icons/halo/obj/structures/machinery/vending_32x64.dmi'
	icon_state = "chemvendor"
	show_points = TRUE
	use_snowflake_points = TRUE
	vendor_role = list(JOB_SQUAD_MEDIC)
	req_access = list(ACCESS_MARINE_MEDPREP)

/obj/structure/machinery/cm_vending/gear/medic_chemical/unsc/get_listed_products(mob/user)
	return GLOB.cm_vending_chemical_medic_halo
