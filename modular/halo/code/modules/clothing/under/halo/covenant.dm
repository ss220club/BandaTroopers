/obj/item/clothing/under/marine/covenant
	name = "нижний костюм"
	desc = "Нижний костюм Ковенанта. Вы не должны это видеть."
	icon = 'icons/halo/obj/items/clothing/covenant/under.dmi'
	icon_state = "sangheili_undersuit"
	item_state = "sangheili_undersuit"
	worn_state = "sangheili_undersuit"
	flags_jumpsuit = null
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	drop_sound = "armorequip"
	allowed_species_list = list()

/obj/item/clothing/under/marine/covenant/sangheili
	name = "\improper нижний костюм сангхейли"
	desc = "Высокотехнологичный комбинезон, в основном повторяющий форму тела носителя. Благодаря вплетённым слоям наноламинатной брони он обеспечивает достойную защиту при высокой гибкости, позволяя владельцу действовать агрессивно и при этом не оставаться без прикрытия. Продвинутые магнитные проекторы костюма способны с большой силой фиксировать на нём элементы брони."
	icon = 'icons/halo/obj/items/clothing/covenant/under.dmi'
	icon_state = "sangheili_undersuit"
	item_state = "sangheili_undersuit"
	worn_state = "sangheili_undersuit"
	flags_jumpsuit = UNIFORM_SLEEVE_ROLLABLE
	drop_sound = "armorequip"
	allowed_species_list = list(SPECIES_SANGHEILI)
	item_state_slots = list()

	item_icons = list(
		WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/sangheili/uniforms.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

/obj/item/clothing/under/marine/covenant/unggoy
	name = "\improper магнитная разгрузка унггоя"
	desc = "Выдаваемая унггоям как часть боевого комплекта, эта система ремней с магнитными замками рассчитана на ношение вместе со штатной бронёй. Она неудобна и почти не спасает от натирания, но кожа у унггоев и без того весьма прочная."

	icon_state = "unggoy_harness"
	item_state = "unggoy_harness"
	worn_state = "unggoy_harness"
	flags_jumpsuit = null
	drop_sound = "armorequip"
	allowed_species_list = list(SPECIES_UNGGOY)
	item_state_slots = list()

	item_icons = list(
		WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/unggoy/uniforms.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
