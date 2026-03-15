/obj/item/storage/firstaid/unsc
	name = "аптечка ККОН"
	desc = "Первоклассные армейские медикаменты обычно лежат именно в этих восьмиугольных аптечках."
	icon = 'icons/halo/obj/items/storage/medical.dmi'
	icon_state = "healthpack"
	open_state = "healthpack_empty"
	storage_slots = 11

	maptext_height = 16
	maptext_width = 32
	maptext_x = 18
	maptext_y = 3
	w_class = SIZE_MEDIUM
	var/maptext_label
	var/display_maptext = TRUE

/obj/item/storage/firstaid/unsc/fill_preset_inventory()
	new /obj/item/device/healthanalyzer/halo(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/small(src)
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/hypospray/autoinjector/tramadol/halo(src)

/obj/item/storage/firstaid/unsc/corpsman/fill_preset_inventory()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_container/blood/OMinus(src)
	new /obj/item/reagent_container/blood/OMinus(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam(src)

/obj/item/storage/firstaid/unsc/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("Её можно заново подписать через alt+mmb.")

/obj/item/storage/firstaid/unsc/clicked(mob/living/carbon/human/user, mods)
	if(mods["alt"] && mods["middle"])
		maptext_label = tgui_input_text(user, "Введите новую подпись. Не более 4 символов.", "Новая подпись", max_length = 4, encode = TRUE)
		update_icon()
		return
	else
		. = ..()

/obj/item/storage/firstaid/unsc/update_icon()
	. = ..()
	if((isstorage(loc) || ismob(loc)) && display_maptext)
		maptext = SPAN_LANGCHAT("[maptext_label]")
	else
		maptext = ""

/obj/item/storage/firstaid/unsc/equipped()
	..()
	update_icon()

/obj/item/storage/firstaid/unsc/on_exit_storage()
	..()
	update_icon()

/obj/item/storage/firstaid/unsc/dropped()
	..()
	update_icon()

/obj/item/storage/firstaid/unsc/empty

/obj/item/storage/firstaid/unsc/empty/fill_preset_inventory()
	return

/obj/item/storage/syringe_case/unsc
	name = "футляр для шприцов"
	desc = "Медицинский футляр для хранения шприцов."
	icon = 'icons/halo/obj/items/storage/medical.dmi'
	icon_state = "syringecase"
	use_sound = "toolbox"
	throw_speed = SPEED_FAST
	throw_range = 8
	storage_slots = 3
	w_class = SIZE_SMALL
	matter = list("plastic" = 1000)
	can_hold = list(
		/obj/item/paper,
		/obj/item/reagent_container/syringe,
		/obj/item/reagent_container/hypospray/autoinjector,
	)
	cant_hold = list(
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam,
	)

/obj/item/storage/syringe_case/unsc/morphine
	name = "футляр с морфином"
	desc = "Стандартное содержимое индивидуальных аптечных пакетов ККОН. Внутри три одноразовые сиретты с морфином."
	icon_state = "morphinecase"
	can_hold = list(
		/obj/item/reagent_container/hypospray/autoinjector/primeable/morphine,
	)

/obj/item/storage/syringe_case/unsc/morphine/full/fill_preset_inventory()
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/morphine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/morphine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/morphine(src)

/obj/item/storage/syringe_case/unsc/full/fill_preset_inventory()
	new /obj/item/reagent_container/syringe/halo(src)
	new /obj/item/reagent_container/syringe/halo(src)
	new /obj/item/reagent_container/syringe/halo(src)

/obj/item/storage/syringe_case/unsc/burnguard
	name = "футляр Optican BurnGuard"
	desc = "Футляр на четыре упаковки Optican BurnGuard."
	icon_state = "burnguard"
	storage_slots = 4
	can_hold = list(
		/obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard,
	)

/obj/item/storage/syringe_case/unsc/burnguard/fill_preset_inventory()
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard(src)
