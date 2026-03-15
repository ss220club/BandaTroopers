/obj/item/weapon/gun/energy/plasma
	name = "оружие Ковенанта"
	desc = "Инопланетное оружие, стреляющее плазмой. В норме вы не должны видеть этот базовый экземпляр."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/covenant/covenant_weapons.dmi'
	icon_state = "plasma_pistol"
	flags_gun_features = GUN_CAN_POINTBLANK
	works_in_recharger = FALSE
	empty_click = null
	mouse_pointer = 'icons/halo/effects/mouse_pointer/plasma_pistol.dmi'
	muzzleflash_icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/rifles_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_cov.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

	var/works_in_cov_recharger = TRUE

	// Heat gain
	var/dispersing = FALSE
	/// The maximum heat the weapon can attain. The value of this should remain the same for all weapons.
	var/max_heat = 100
	/// The current heat of the weapon
	var/heat = 0
	/// The time it takes for overheating to cool down the weapon
	var/overheat_time = 8 SECONDS
	/// Heat gained per shot fired
	var/heat_per_shot = 4
	/// Whether or not the weapon has support for overheating overlays
	var/has_overheat_icon_state = TRUE
	/// Overheat cooldown
	COOLDOWN_DECLARE(cooldown)

	var/has_heat_overlay = FALSE

	// Heat dispersion
	/// The amount of time it takes to manually vent the heat from the weapon
	var/manual_dispersion_delay = 4 SECONDS
	COOLDOWN_DECLARE(manual_cooldown)
	/// The amount of heat passively dispersed every second
	var/passive_dispersion = 2
	/// The amount of additional heat dispersed when the weapon has not fired for the duration of the dispersion_delay
	var/active_dispersion = 4
	/// The delay until additional heat begins to disperse since the last shot
	var/dispersion_delay = 5 SECONDS
	COOLDOWN_DECLARE(dispersion_cooldown)

	// Overlays
	var/image/overheat_overlay
	var/image/venting_overlay
	var/image/heat_overlay

	// Sounds
	var/overheat_sound = 'sound/weapons/halo/plasma_overheat.ogg'
	var/manual_vent_sound = 'sound/weapons/halo/plasma_overheat.ogg'
	var/close_vent_sound = 'sound/weapons/handling/safety_toggle.ogg'

/obj/item/weapon/gun/energy/plasma/Initialize()
	. = ..()
	overheat_overlay = image(icon, icon_state = "[initial(icon_state)]_o")
	venting_overlay = image(icon, icon_state = "[initial(icon_state)]_v")
	heat_overlay = image(icon, icon_state = "[initial(icon_state)]_h0")
	update_heat_overlay()

/obj/item/weapon/gun/energy/plasma/Destroy()
	STOP_PROCESSING(SSdcs, src)
	return ..()

/obj/item/weapon/gun/energy/plasma/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("Уровень нагрева: [get_heat_percent()]%.")

/obj/item/weapon/gun/energy/plasma/proc/get_heat_percent()
	return 100.0*heat/max_heat

/obj/item/weapon/gun/energy/plasma/gun_safety_handle(mob/user)
	to_chat(user, SPAN_NOTICE("You toggle the power on the [src] [SPAN_BOLD(flags_gun_features & GUN_TRIGGER_SAFETY ? "off" : "on")]."))
	playsound(user, 'sound/weapons/handling/safety_toggle.ogg', 25, 1)

/obj/item/weapon/gun/energy/plasma/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	if(!COOLDOWN_FINISHED(src, cooldown) || !COOLDOWN_FINISHED(src, manual_cooldown))
		to_chat(user, SPAN_NOTICE("The [src] is still cooling down."))
		playsound(src, empty_click)
		return
	. = ..()
	if(.)
		heat += heat_per_shot
		COOLDOWN_START(src, dispersion_cooldown, dispersion_delay)
		start_process()
		update_heat_overlay()
		if(heat >= max_heat)
			overheat()

/obj/item/weapon/gun/energy/plasma/unload(mob/living/user)
	if(!COOLDOWN_FINISHED(src, cooldown) || !COOLDOWN_FINISHED(src, manual_cooldown))
		to_chat(user, SPAN_NOTICE("The [src] is still cooling down."))
		return
	if(!heat >= 1)
		to_chat(user, SPAN_NOTICE("Your [src] doesn't need to be purged of heat."))
	user.visible_message(SPAN_NOTICE("[user] manually vents their [src], carefully expelling the hot plasma into the air."), SPAN_DANGER("You manually vent your [src], carefully expelling the hot plasma into the air."))
	playsound(src, manual_vent_sound)
	heat = 0
	COOLDOWN_START(src, manual_cooldown, manual_dispersion_delay)
	if(has_overheat_icon_state)
		icon_state = "[initial(icon_state)]_open"
		addtimer(CALLBACK(src, PROC_REF(reset_icon), src), manual_dispersion_delay)
		flick_overlay(src, venting_overlay, manual_dispersion_delay)
	addtimer(CALLBACK(src, PROC_REF(end_overheat), src), manual_dispersion_delay)
	dispersing = TRUE
	start_process()
	update_heat_overlay()

/obj/item/weapon/gun/energy/plasma/proc/overheat()
	COOLDOWN_START(src, cooldown, overheat_time)
	gun_user.visible_message(SPAN_NOTICE("[gun_user]'s [src] overheats and vents scalding hot plasma from its side ports!"), SPAN_DANGER("Your [src] overheats and expels hot plasma from its side ports! IT'S HOT!"))
	if(ishuman(gun_user))
		var/mob/living/carbon/human/human = gun_user
		human.take_overall_armored_damage(30, ARMOR_LASER, BURN, 50)
	heat = 0
	playsound(src, overheat_sound)
	if(has_overheat_icon_state)
		icon_state = "[initial(icon_state)]_open"
		addtimer(CALLBACK(src, PROC_REF(reset_icon), src), overheat_time)
		flick_overlay(src, overheat_overlay, overheat_time)
	addtimer(CALLBACK(src, PROC_REF(end_overheat), src), overheat_time)
	dispersing = TRUE
	start_process()
	update_heat_overlay()

/obj/item/weapon/gun/energy/plasma/proc/start_process()
	START_PROCESSING(SSdcs, src)

/obj/item/weapon/gun/energy/plasma/proc/end_process()
	STOP_PROCESSING(SSdcs, src)

/obj/item/weapon/gun/energy/plasma/proc/should_process()
	if(heat > 0)
		return TRUE

	if(dispersing)
		return TRUE

	if(!COOLDOWN_FINISHED(src, cooldown))
		return TRUE

	if(!COOLDOWN_FINISHED(src, manual_cooldown))
		return TRUE

	return FALSE

/obj/item/weapon/gun/energy/plasma/proc/get_heat_overlay_state()
	switch(get_heat_percent())
		if(90 to 100)
			return "[initial(icon_state)]_h4"
		if(60 to 89)
			return "[initial(icon_state)]_h3"
		if(30 to 59)
			return "[initial(icon_state)]_h2"
		if(10 to 29)
			return "[initial(icon_state)]_h1"
		else
			return "[initial(icon_state)]_h0"

/obj/item/weapon/gun/energy/plasma/proc/update_heat_overlay()
	if(!has_heat_overlay || !heat_overlay)
		return

	overlays -= heat_overlay
	heat_overlay.icon_state = get_heat_overlay_state()
	overlays += heat_overlay

/obj/item/weapon/gun/energy/plasma/process()
	heat = max(heat - passive_dispersion, 0)
	if(COOLDOWN_FINISHED(src, dispersion_cooldown))
		heat = max(heat - active_dispersion, 0)

	update_heat_overlay()
	if(!should_process())
		end_process()

/obj/item/weapon/gun/energy/plasma/proc/reset_icon()
	icon_state = initial(icon_state)
	update_heat_overlay()

/obj/item/weapon/gun/energy/plasma/proc/end_overheat()
	playsound(src, close_vent_sound)
	dispersing = FALSE
	if(!should_process())
		end_process()

/obj/item/weapon/gun/energy/plasma/update_icon()
	. = ..()

	if(!cell)
		return

	update_heat_overlay()


/obj/item/weapon/gun/energy/plasma/plasma_pistol
	name = "\improper плазменный пистолет"
	desc = null
	icon_state = "plasma_pistol"
	item_state = "plasma_pistol"
	charge_cost = 20
	gun_category = GUN_CATEGORY_HANDGUN
	muzzleflash_iconstate = "muzzle_flash_teal"
	muzzle_flash_color = COLOR_PLASMA_TEAL
	flags_equip_slot = SLOT_WAIST
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ONE_HAND_WIELDED
	ammo = /datum/ammo/energy/halo_plasma/plasma_pistol

	fire_sound = "gun_lightplasma"

	var/datum/ammo/plasma_bolt = /datum/ammo/energy/halo_plasma/plasma_pistol
	var/datum/ammo/overcharged_bolt = /datum/ammo/energy/halo_plasma/plasma_pistol/overcharge
	var/overcharged = FALSE
	var/atom/movable/overlay/overcharge_overlay
	COOLDOWN_DECLARE(overcharge_cooldown)

/obj/item/weapon/gun/energy/plasma/plasma_pistol/get_examine_text(mob/living/carbon/human/user)
	. = ..()
	var/list/origin = .
	var/insert_line
	if(isunggoy(user) || issangheili(user))
		origin[1] = "[icon2html(src, user)] Это плазменный пистолет образца Eos'Mak"
		insert_line = "Надёжная рабочая лошадка бесчисленных воинств Ковенанта, которую можно увидеть как в руках почитаемых адмиралов и советников, так и у самых низших слуг. Обманчиво мощное оружие, способное отсекать конечности и убивать одним попаданием даже сквозь крепкую броню. Может накапливать избыточный заряд в один усиленный выстрел, сбивая щиты и разрывая тела."
	else
		origin[1] = "[icon2html(src, user)] Это плазменный пистолет Тип-25"
		insert_line = "Стандартное энергетическое оружие Ковенанта, стреляющее магнитно удерживаемыми сгустками высокоэнергетической плазмы с заметным кинетическим ударом. Несмотря на слово \"пистолет\", Тип-25 вполне способен убить полностью бронированного морпеха одним точным выстрелом. Некоторые бойцы Ковенанта ещё и перегружают его, превращая торс жертвы в месиво."
	origin.Insert(2, insert_line)
	. += SPAN_NOTICE("Вы можете перегрузить оружие для мощного выстрела, удерживая спуск через <b>уникальное действие</b>.")

/obj/item/weapon/gun/energy/plasma/plasma_pistol/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	set_burst_delay(FIRE_DELAY_TIER_9)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/energy/plasma/plasma_pistol/Initialize()
	plasma_bolt = GLOB.ammo_list[plasma_bolt] //Gun initialize calls replace_ammo() so we need to set these first.
	overcharged_bolt = GLOB.ammo_list[overcharged_bolt]
	. = ..()

/obj/item/weapon/gun/energy/plasma/plasma_pistol/unique_action(mob/living/carbon/human/user)
	if(!COOLDOWN_FINISHED(src, cooldown) || !COOLDOWN_FINISHED(src, manual_cooldown))
		to_chat(user, SPAN_NOTICE("The [src] is still cooling down."))
		return
	if(!COOLDOWN_FINISHED(src, overcharge_cooldown))
		return
	if(overcharged)
		user.visible_message(SPAN_NOTICE("[user] releases the trigger on the [src], no longer overcharging it!"), SPAN_DANGER("You stop overcharging the [src]!"))
		overcharged = FALSE
		toggle_ammo()
		toggle_overcharge_overlay()
		COOLDOWN_START(src, overcharge_cooldown, 1.5 SECONDS)
	else if(!overcharged)
		user.visible_message(SPAN_NOTICE("[user] holds down on the [src]'s trigger and begins to overcharge it!"), SPAN_DANGER("You hold down on the [src]'s trigger and begin to overcharge it!"))
		toggle_ammo()
		overcharged = TRUE
		toggle_overcharge_overlay()
		playsound(src, 'sound/weapons/halo/plasma_pistol_overcharge/overcharge.ogg', vary = TRUE)
		COOLDOWN_START(src, overcharge_cooldown, 1.5 SECONDS)

/obj/item/weapon/gun/energy/plasma/plasma_pistol/proc/toggle_overcharge_overlay()
	if(overcharged)
		overcharge_overlay = new()
		overcharge_overlay.alpha = 0
		overcharge_overlay.icon = icon
		overcharge_overlay.icon_state = "plasma_pistol_overcharge"
		overcharge_overlay.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		vis_contents += overcharge_overlay
		animate(overcharge_overlay, 1 SECONDS, alpha = 255)
	else
		animate(overcharge_overlay, 0.5 SECONDS, alpha = 0)
		addtimer(CALLBACK(src, PROC_REF(kill_overcharge_overlay)), 0.5 SECONDS)

/obj/item/weapon/gun/energy/plasma/plasma_pistol/proc/kill_overcharge_overlay()
	qdel(overcharge_overlay)

/obj/item/weapon/gun/energy/plasma/plasma_pistol/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	. = ..()
	if(.)
		if(overcharged)
			overheat()
			overcharged = FALSE
			toggle_ammo()
			qdel(overcharge_overlay)

/obj/item/weapon/gun/energy/plasma/plasma_pistol/proc/toggle_ammo()
	if(ammo == plasma_bolt)
		ammo = overcharged_bolt
		charge_cost = 1000
		fire_sound = "gun_plasma_overcharge"
	else if(ammo == overcharged_bolt)
		ammo = plasma_bolt
		charge_cost = 20
		fire_sound = "gun_lightplasma"

/obj/item/weapon/gun/energy/plasma/plasma_rifle
	name = "\improper плазменная винтовка"
	desc = null
	icon_state = "plasma_rifle"
	item_state = "plasma_rifle"
	heat_per_shot = 3
	charge_cost = 10
	ammo = /datum/ammo/energy/halo_plasma/plasma_rifle
	has_heat_overlay = TRUE
	has_overheat_icon_state = TRUE
	fire_sound = 'sound/weapons/halo/gun_plasmarifle_1.ogg'
	start_automatic = TRUE
	muzzleflash_iconstate = "muzzle_flash_blue"
	muzzle_flash_color = COLOR_PLASMA_BLUE
	mouse_pointer = 'icons/halo/effects/mouse_pointer/plasma_rifle.dmi'

/obj/item/weapon/gun/energy/plasma/plasma_rifle/Initialize(mapload, spawn_empty)
	. = ..()
	AddComponent(/datum/component/halo_projectile_backpressure)

/obj/item/weapon/gun/energy/plasma/plasma_rifle/get_examine_text(mob/living/carbon/human/user)
	. = ..()
	var/list/origin = .
	var/insert_line
	if(isunggoy(user) || issangheili(user))
		origin[1] = "[icon2html(src, user)] Это плазменная винтовка образца Okarda'phaa"
		insert_line = "Древнее и почтенное оружие, служившее Ковенанту многие столетия в руках его самых прославленных воинов. По-настоящему жестокий инструмент, наносящий чудовищный кинетический и тепловой урон, разнося броню в клочья и превращая плоть в кипящий туман. Чаще всего встречается у воинов-сангхейли и у ветеранов низших каст."
	else
		origin[1] = "[icon2html(src, user)] Это плазменная винтовка Тип-25"
		insert_line = "Это разрушительное оружие используют элиты Ковенанта и их более умелые бойцы. Характерный треск скорострельной плазменной винтовки - один из самых страшных звуков на поле боя; большинство морпехов видели её работу на изуродованных телах своих товарищей. И не перегревайте её: перчатки кожу не спасут."
	origin.Insert(2, insert_line)

/obj/item/weapon/gun/energy/plasma/plasma_rifle/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_delay(FIRE_DELAY_TIER_11)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_2

/obj/item/weapon/gun/smg/covenant_needler
	name = "\improper игольник"
	desc = null
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/covenant/covenant_weapons.dmi'
	icon_state = "needler"
	item_state = "needler"
	fire_sound = "gun_needler"
	reload_sound = 'sound/weapons/halo/gun_needler_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_needler_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_needler_reload.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK
	muzzleflash_icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	muzzleflash_iconstate = "muzzle_flash_pink"
	muzzle_flash_color = LIGHT_COLOR_PINK
	mouse_pointer = 'icons/halo/effects/mouse_pointer/needler.dmi'
	start_automatic = TRUE
	empty_sound = null
	current_mag = /obj/item/ammo_magazine/needler_crystal
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/rifles_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_cov.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

/obj/item/weapon/gun/smg/covenant_needler/Initialize(mapload, spawn_empty)
	. = ..()
	AddComponent(/datum/component/halo_projectile_backpressure)

/obj/item/weapon/gun/smg/covenant_needler/get_examine_text(mob/living/carbon/human/user)
	. = ..()
	var/list/origin = .
	var/insert_line
	if(isunggoy(user) || issangheili(user))
		origin[1] = "[icon2html(src, user)] Это игольник образца Eket'Vauh"
		insert_line = "Автоматическая пусковая установка самонаводящихся боеприпасов, стреляющая заряжёнными субанскими кристаллами, срезанными с центрального ядра. Образец Eket'Vauh производится на Высшей Милости, в сборочных кузнях Священного Обета. Более редкий вариант для тех, кто удостоился благосклонности Высшего Совета; фиолетово-розовые осколки этого оружия выносят приговор в виде яростной детонации."
	else
		origin[1] = "[icon2html(src, user)] Это игольник Тип-33"
		insert_line = "Экзотическое \"баллистическое\" оружие Ковенанта, выпускающее яркие розово-фиолетовые осколки заряжённого кристалла, самонаводящиеся по пока неясному принципу. Каждое попадание игольника почти смертельно само по себе: оно рвёт броню, плоть и кости, оставляя в теле микроскопические осколки и тяжёлые ожоги. Если кто-то словит \"суперкомбинацию\", от него останется только розовый туман."
	origin.Insert(2, insert_line)

/obj/item/weapon/gun/smg/covenant_needler/unique_action(mob/user)
	return

/obj/item/weapon/gun/smg/covenant_needler/unload_chamber(mob/user)
	return

/obj/item/weapon/gun/smg/covenant_needler/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_2

/obj/item/weapon/gun/smg/covenant_needler/cock(mob/user)
	if(flags_gun_features & (GUN_BURST_FIRING|GUN_INTERNAL_MAG))
		return

	cock_gun(user)
	ready_in_chamber()

/obj/item/weapon/gun/smg/covenant_needler/unload(mob/user, reload_override = 0, drop_override = 0, loc_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if(!reload_override && (flags_gun_features & (GUN_BURST_FIRING|GUN_INTERNAL_MAG)))
		return

	if(!current_mag || QDELETED(current_mag) || (current_mag.loc != src && !loc_override))
		current_mag = null
		update_icon()
		return

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.forceMove(get_turf(src))//Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message(SPAN_NOTICE("[user] unloads [current_mag] from [src]."),
	SPAN_NOTICE("You unload [current_mag] from [src]."), null, 4, CHAT_TYPE_COMBAT_ACTION)
	current_mag.update_icon()
	current_mag = null

	update_icon()

/obj/item/weapon/gun/rifle/covenant_carbine
	name = "\improper карабин"
	desc = null
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/covenant/covenant_weapons.dmi'
	icon_state = "carbine"
	item_state = "carbine"
	fire_sound = "gun_carbine"
	reload_sound = 'sound/weapons/halo/gun_carbine_reload.ogg'
	cocked_sound = 'sound/weapons/halo/gun_carbine_cocked.ogg'
	unload_sound = 'sound/weapons/halo/gun_carbine_unload.ogg'
	empty_sound = 'sound/weapons/halo/gun_carbine_dryfire.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER
	current_mag = /obj/item/ammo_magazine/carbine
	map_specific_decoration = FALSE
	attachable_allowed = list(/obj/item/attachable/carbine_muzzle)
	muzzleflash_icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	muzzleflash_iconstate = "muzzle_flash_green"
	muzzle_flash_color = LIGHT_COLOR_GREEN
	mouse_pointer = 'icons/halo/effects/mouse_pointer/carbine.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_x_dimension = 64
	worn_y_dimension = 64
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/rifles_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_cov.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo_64.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo_64.dmi'
	)

/obj/item/weapon/gun/rifle/covenant_carbine/Initialize(mapload, spawn_empty)
	. = ..()
	AddComponent(/datum/component/halo_projectile_backpressure)

/obj/item/weapon/gun/rifle/covenant_carbine/get_examine_text(mob/living/carbon/human/user)
	. = ..()
	var/list/origin = .
	var/insert_line
	if(isunggoy(user) || issangheili(user))
		origin[1] = "[icon2html(src, user)] Это карабин образца Vostu"
		insert_line = "Одно из немногих баллистических оружий Ковенанта, карабин образца Vostu стреляет безгильзовой радиоактивной пулей 8x60 мм, которая часто раскалывается после пробития цели, превращая даже небольшие раны в смертельные за счёт оставленного токсичного материала. Используется воинами-сангхейли и многими стрелками-киг'яр, которым нужно жестокое и точное оружие."
	else
		origin[1] = "[icon2html(src, user)] Это карабин Тип-51"
		insert_line = "Одно из немногих баллистических оружий Ковенанта. Карабин стреляет радиоактивными безгильзовыми пулями, сочетая высокую точность с тяжёлыми последствиями даже после неполного пробития. Им чаще всего вооружают элитных стрелков Ковенанта, и лучше не оказываться у них на линии огня."
	origin.Insert(2, insert_line)

/obj/item/weapon/gun/rifle/covenant_carbine/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 22, "rail_y" = 20, "under_x" = 32, "under_y" = 16, "stock_x" = 0, "stock_y" = 0, "special_x" = 48, "special_y" = 16)

/obj/item/weapon/gun/rifle/covenant_carbine/handle_starting_attachment()
	..()
	var/obj/item/attachable/carbine_muzzle/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)
	var/obj/item/attachable/scope/variable_zoom/scope = new(src)
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	scope.hidden = TRUE
	update_attachable(scope.slot)

/obj/item/weapon/gun/rifle/covenant_carbine/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_7)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	fa_scatter_peak = 16
	fa_max_scatter = 2

/obj/item/weapon/gun/rifle/covenant_carbine/unique_action(mob/user)
	return

/obj/item/weapon/gun/rifle/covenant_carbine/unload_chamber(mob/user)
	return
