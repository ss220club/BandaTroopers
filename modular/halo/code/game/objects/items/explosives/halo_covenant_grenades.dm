/obj/item/explosive/grenade/high_explosive/covenant
	icon = 'icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "m9"
	item_state = "m9"
	arm_sound = 'sound/weapons/grenade.ogg'
	falloff_mode = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF
	shrapnel_count = 0

/obj/item/explosive/grenade/high_explosive/covenant/plasma
	name = "плазменная граната Тип-1"
	desc = "Плазменная граната Ковенанта, адаптированная под ударные заряды ИИ. Детонирует короткой, но яростной вспышкой перегретой плазмы."
	desc_lore = "Это временная реализация, использующая доступный спрайт гранаты Halo до переноса отдельной графики для гранат Ковенанта."
	det_time = 40
	dangerous = TRUE
	explosion_power = 90
	explosion_falloff = 24
