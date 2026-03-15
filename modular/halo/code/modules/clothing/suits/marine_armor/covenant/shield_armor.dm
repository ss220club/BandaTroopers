/obj/item/clothing/suit/marine/shielded
	/// Whether a shield is broken. Used for keeping track of it in the code.
	var/shield_broken = FALSE
	/// The "health" of the shield
	var/shield_strength
	/// The maximum "health" of the shield
	var/max_shield_strength
	/// The value of shield regeneration
	var/shield_regen_rate
	/// Shield datum
	var/datum/halo_shield/shield = TESTER_SHIELD
	/// Whether or not any of the shield features are enabled
	var/shield_enabled = TRUE
	///is shield shimmering effect active
	var/shield_effect = FALSE
	/// Time in seconds until the shield begins to regenerate after taking damage
	COOLDOWN_DECLARE(time_to_regen)
	/// Time that it takes for the shield to reach full strength
	var/recovery_time
	/// Shield crackle cooldown?
	COOLDOWN_DECLARE(shield_sparks)

	// sounds
	COOLDOWN_DECLARE(shield_noise_cd)
	COOLDOWN_DECLARE(shield_hit_sound_cd)
	COOLDOWN_DECLARE(shield_hit_visual_cd)

	actions_types = list(/datum/action/item_action/toggle_shield)

// ------------------ PROCS ------------------

/obj/item/clothing/suit/marine/shielded/Initialize()
	. = ..()
	shield_strength = shield.max_shield_strength
	max_shield_strength = shield.max_shield_strength
	recovery_time = shield.recovery_time
	shield_regen_rate = max_shield_strength / max(recovery_time * 0.1, 0.1)
	addtimer(CALLBACK(src, PROC_REF(update_shield_runtime_state)), 0)

/obj/item/clothing/suit/marine/shielded/Destroy()
	STOP_PROCESSING(SSfastobj, src)
	halo_unregister_active_shield_harness(src)
	return ..()

/obj/item/clothing/suit/marine/shielded/equipped(mob/user, slot, silent)
	. = ..()
	update_shield_runtime_state()

/obj/item/clothing/suit/marine/shielded/unequipped(mob/user, slot)
	. = ..()
	update_shield_runtime_state()

/obj/item/clothing/suit/marine/shielded/proc/get_shield_user()
	var/mob/living/carbon/human/current_user = src.loc
	if(istype(current_user) && current_user.wear_suit == src)
		return current_user

/obj/item/clothing/suit/marine/shielded/proc/should_process_shield()
	var/mob/living/carbon/human/current_user = get_shield_user()
	if(!current_user || !shield_enabled)
		return FALSE

	if(current_user.stat == DEAD)
		return TRUE

	if(shield_broken)
		return TRUE

	if(shield_strength < max_shield_strength)
		return TRUE

	return !COOLDOWN_FINISHED(src, time_to_regen)

/obj/item/clothing/suit/marine/shielded/proc/update_shield_runtime_state()
	if(should_process_shield())
		start_process()
		return

	end_process()

/obj/item/clothing/suit/marine/shielded/proc/intercept_projectile_damage(mob/living/carbon/human/target, damage_taken)
	if(target != get_shield_user())
		return max(damage_taken, 0)

	return take_damage(damage_taken, target)

/obj/item/clothing/suit/marine/shielded/proc/toggle_shield()
	var/mob/living/carbon/human/current_user = src.loc
	if(ishuman(current_user))
		if(shield_enabled)
			shield_enabled = FALSE
			shield_strength = 0
			playsound(src, 'sound/effects/shields/shield_manual_down.ogg')
			end_process(TRUE)
			to_chat(current_user, SPAN_NOTICE("You hear a low hum and a hiss as your shield powers off."))
			return
		if(!shield_enabled)
			shield_enabled = TRUE
			playsound(src, 'sound/effects/shields/shield_manual_up.ogg')
			COOLDOWN_START(src, time_to_regen, shield.time_to_regen)
			update_shield_runtime_state()
			to_chat(current_user, SPAN_NOTICE("You hear a low hum as your shield powers on."))
			return

/obj/item/clothing/suit/marine/shielded/proc/disable_shield()
	var/mob/living/carbon/human/current_user = src.loc
	if(ishuman(current_user))
		shield_enabled = FALSE
		shield_strength = 0
		playsound(src, 'sound/effects/shields/shield_manual_down.ogg')
		to_chat(current_user, SPAN_NOTICE("You hear a low hum and a hiss as your shield powers off."))
		end_process(TRUE)
		return

/obj/item/clothing/suit/marine/shielded/proc/take_damage(damage_taken, mob/living/carbon/human/user)
	if(!ishuman(user))
		user = src.loc
	if(!ishuman(user) || damage_taken <= 0)
		return max(damage_taken, 0)
	if(!shield_enabled || shield_broken || shield_strength <= 0)
		return damage_taken

	if(COOLDOWN_FINISHED(src, shield_hit_sound_cd))
		playsound(src, "shield_hit")
		COOLDOWN_START(src, shield_hit_sound_cd, 3 DECISECONDS)

	if(!shield_effect && COOLDOWN_FINISHED(src, shield_hit_visual_cd))
		var/image/shield_flicker = image('icons/halo/mob/humans/onmob/clothing/sangheili/armor.dmi', icon_state = "+flicker", layer = ABOVE_MOB_LAYER)
		shield_flicker.dir = user.dir
		flick_overlay(user, shield_flicker, 22)
		user.add_filter("shield", 2, list("type" = "outline", "color" = "#bce0ff9a", "size" = 1))
		shield_effect = TRUE
		COOLDOWN_START(src, shield_hit_visual_cd, 22)
		addtimer(CALLBACK(src, PROC_REF(remove_shield_effect)), 22)
		var/obj/shield_hit_fx = new /obj/effect/temp_visual/plasma_explosion/shield_hit(user.loc)
		shield_hit_fx.pixel_x = rand(-5, 5)
		shield_hit_fx.pixel_y = rand(-16, 16)

	var/absorbed_damage = min(damage_taken, shield_strength)
	shield_strength = max(shield_strength - absorbed_damage, 0)
	COOLDOWN_START(src, time_to_regen, shield.time_to_regen)

	if(shield_strength <= 0 && !shield_broken)
		shield_pop(user)
		shield_broken = TRUE

	update_shield_runtime_state()

	return max(damage_taken - absorbed_damage, 0)


/obj/item/clothing/suit/marine/shielded/proc/shield_pop(mob/living/carbon/human/user)
	var/mob/living/carbon/human/current_user = src.loc
	if(ishuman(current_user))
		playsound(src, "shield_pop", falloff = 5)
		new /obj/effect/temp_visual/plasma_explosion/shield_pop(current_user.loc)
		new /obj/effect/temp_visual/shield_spark(current_user.loc)
		remove_shield_effect()
		current_user.visible_message(SPAN_NOTICE("[current_user]s energy shield shimmers and pops, overloading!"), SPAN_DANGER("Your energy shield shimmers and pops, overloading!"))

// ------------------ PROCESS PROCS ------------------

/obj/item/clothing/suit/marine/shielded/proc/start_process()
	START_PROCESSING(SSfastobj, src)
	halo_register_active_shield_harness(src)

/obj/item/clothing/suit/marine/shielded/proc/end_process(reset_regen_cooldown = FALSE)
	STOP_PROCESSING(SSfastobj, src)
	halo_unregister_active_shield_harness(src)
	if(reset_regen_cooldown)
		COOLDOWN_RESET(src, time_to_regen)

/obj/item/clothing/suit/marine/shielded/process(delta_time)
	var/mob/living/carbon/human/current_user = get_shield_user()
	if(!ishuman(current_user) || !shield_enabled)
		end_process()
		return

	if(shield_broken || current_user.stat == DEAD)
		if(COOLDOWN_FINISHED(src, shield_sparks))
			var/obj/shield_sparkle = new /obj/effect/temp_visual/plasma_explosion/shield_hit(current_user.loc)
			shield_sparkle.pixel_x = rand(-5, 5)
			shield_sparkle.pixel_y = rand(-16, 16)
			current_user.add_filter("shield", 2, list("type" = "outline", "color" = "#bce0ff9a", "size" = 1))
			addtimer(CALLBACK(src, PROC_REF(remove_shield_effect)), 5)
			shield_effect = TRUE
			COOLDOWN_START(src, shield_sparks, rand(4, 6) SECONDS)

	if(current_user.stat == DEAD)
		disable_shield()
		return

	if(COOLDOWN_FINISHED(src, time_to_regen) && shield_strength < max_shield_strength)
		shield_strength = min(shield_strength + (shield_regen_rate * delta_time), max_shield_strength)
		if(shield_strength > 0)
			shield_broken = FALSE
		if(COOLDOWN_FINISHED(src, shield_noise_cd))
			playsound(src, "shield_charge", vary = TRUE)
			current_user.visible_message(SPAN_NOTICE("[current_user]s energy shield emitters hum, regenerating the shield around them!"), SPAN_DANGER("Your energy shields hum and begin to regenerate."))
			COOLDOWN_START(src, shield_noise_cd, shield.time_to_regen)

	update_shield_runtime_state()

/obj/item/clothing/suit/marine/shielded/proc/remove_shield_effect()
	var/mob/living/carbon/human/current_user = src.loc
	if(ishuman(current_user))
		current_user.remove_filter("shield")
	shield_effect = FALSE

// ------------------ ARMOR ------------------

/obj/item/clothing/suit/marine/shielded/sangheili
	name = "ВЫ НЕ ДОЛЖНЫ ЭТО ВИДЕТЬ"
	desc = "Центральный элемент комплекта продвинутой боевой брони производства Ковенанта. Выполнен из наноламината и оснащён энергетическими щитами, поэтому намного прочнее экипировки большинства других видов."
	icon = 'icons/halo/obj/items/clothing/covenant/armor.dmi'
	icon_state = "sang_minor"
	item_state = "sang_minor"

	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/sangheili/armor.dmi'
	)

	allowed_species_list = list(SPECIES_SANGHEILI)
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	slowdown = SLOWDOWN_ARMOR_LIGHT

	valid_accessory_slots = list(ACCESSORY_SLOT_SANG_SHOULDER, ACCESSORY_SLOT_SANG_WEBBING)
	restricted_accessory_slots = list(ACCESSORY_SLOT_SANG_SHOULDER, ACCESSORY_SLOT_SANG_WEBBING)

// Minor

/obj/item/clothing/suit/marine/shielded/sangheili/minor
	name = "\improper Sangheili Minor combat harness"
	desc = "Синяя боевая сбруя, которую носят 'миноры' - самый низкий ранг воинов сангхейли. Надеваемая поверх техкостюма, эта броня состоит из грудной клетки-каркаса на торсе с наплечниками, наручами, набедренниками и поножами, обеспечивая высокий уровень защиты, хотя главным оборонительным достоинством всё равно остаются энергетические щиты."
	desc_lore = "Хотя ранг Minor - самый низкий, который может носить сангхейли, сам синий цвет уже отделяет его от любых низших каст. И некоторые этим охотно пользуются."

	shield = SANG_SHIELD_MINOR
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/suit/marine/shielded/sangheili/minor/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/pads/sangheili/minor/pads = new()
	src.attach_accessory(null, pads, TRUE)

/obj/item/clothing/suit/marine/shielded/sangheili/major

	name = "\improper Sangheili Major combat harness"
	desc = "Эта красная сбруя обозначает владельца как 'майора' - более опытного и закалённого воина сангхейли. Формально от доспеха минора её по-настоящему отличает лишь окраска, но у майора эта броня всё же получает более мощные энергетические щиты."
	desc_lore = "Благодаря большему опыту майоры командуют как минорами своего вида, так и всеми низшими кастами в роли полевых офицеров."

	icon_state = "sang_major"
	item_state = "sang_major"

	shield = SANG_SHIELD_MAJOR
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/shielded/sangheili/major/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/pads/sangheili/major/pads = new()
	src.attach_accessory(null, pads, TRUE)

/obj/item/clothing/suit/marine/shielded/sangheili/ultra

	name = "\improper Sangheili Ultra combat harness"
	desc = "Белая сбруя, которую носит сангхейли ранга 'ультра' - исключительно опытный ветеран, стоящий вне обычной легионной иерархии как член Evocati. По сравнению со стандартными комплектами других рангов эта броня использует более совершенные технологии, рассчитана на штурмовые атаки и жестокие поединки и обладает значительно более мощными щитами."
	desc_lore = "Evocatii нередко служат в силах Ковенанта век и дольше, передавая младшим офицерам и тем, кто ищет совета, критически важный боевой и тактический опыт. Но лучше всего они проявляют себя в прямом бою - ведут яростные атаки и берутся за особые задания."

	icon_state = "sang_ultra"
	item_state = "sang_ultra"

	shield = SANG_SHIELD_ULTRA
	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/shielded/sangheili/ultra/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/pads/sangheili/ultra/pads = new()
	src.attach_accessory(null, pads, TRUE)

/obj/item/clothing/suit/marine/shielded/sangheili/zealot

	name = "\improper Sangheili Zealot combat harness"
	desc = "Золотой блеск этой сбруи выдаёт в гордом сангхейли одного из прославленных зилотов - воинов почётных Орденов. Она неизмеримо превосходит любые более низкие комплекты: говорят, её наноламинатные сплавы напрямую насыщены священными металлами, благодаря чему броня одновременно удивительно лёгкая и нелепо прочная. К этой обычной прочности добавляются мощные энергетические щиты, превращающие воина в неудержимую силу на пути к цели."
	desc_lore = "Будь то личное ведение войск в славный бой или захват Святых Реликвий в дерзких и не слишком афишируемых операциях, с носителем этой сбруи лучше не шутить и тем более не становиться у него на пути."

	icon_state = "sang_zealot"
	item_state = "sang_zealot"

	shield = SANG_SHIELD_ZEALOT
	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/shielded/sangheili/zealot/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/pads/sangheili/zealot/pads = new()
	src.attach_accessory(null, pads, TRUE)
