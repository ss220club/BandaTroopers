#define HALO_FULL_CAMO_ALPHA 15
#define HALO_VISIBLE_CAMO_ALPHA 60
#define HALO_FULL_PVE_CAMO_ALPHA 30
#define HALO_VISIBLE_PVE_CAMO_ALPHA 75

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking
	var/camo_active = FALSE
	var/full_camo_alpha = HALO_FULL_PVE_CAMO_ALPHA
	var/incremental_shooting_camo_penalty = 6
	var/current_camo = HALO_FULL_PVE_CAMO_ALPHA
	var/visible_camo_alpha = HALO_VISIBLE_PVE_CAMO_ALPHA
	var/camouflage_break
	var/cloak_cooldown

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/dropped(mob/user)
	if(ishuman(user) && !issynth(user))
		deactivate_camouflage(user, FALSE)
	return ..()

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/attack_self(mob/user)
	. = ..()
	camouflage(user)

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/proc/camouflage(mob/user)
	if(!user || user.is_mob_incapacitated(TRUE) || !ishuman(user))
		return FALSE

	var/mob/living/carbon/human/human_user = user
	if(camo_active)
		deactivate_camouflage(human_user)
		return TRUE

	if(cloak_cooldown && cloak_cooldown > world.time)
		to_chat(human_user, SPAN_WARNING("Your cloak is malfunctioning and can't be enabled right now!"))
		return FALSE

	RegisterSignal(human_user, list(COMSIG_MOB_FIRED_GUN, COMSIG_MOB_FIRED_GUN_ATTACHMENT), PROC_REF(fade_in))
	RegisterSignal(human_user, COMSIG_HUMAN_EXTINGUISH, PROC_REF(wrapper_fizzle_camouflage))
	RegisterSignal(human_user, list(COMSIG_MOB_DEATH, COMSIG_MOB_EFFECT_CLOAK_CANCEL), PROC_REF(deactivate_camouflage), override = TRUE)

	camo_active = TRUE
	ADD_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	human_user.visible_message(SPAN_DANGER("[human_user] vanishes into thin air!"), SPAN_NOTICE("You activate your cloak's camouflage."), max_distance = 4)
	playsound(human_user.loc, 'sound/effects/cloak_scout_on.ogg', 15, TRUE)
	human_user.unset_interaction()

	human_user.alpha = full_camo_alpha
	human_user.FF_hit_evade = 1000

	var/datum/mob_hud/security/advanced/security_hud = GLOB.huds[MOB_HUD_SECURITY_ADVANCED]
	security_hud.remove_from_hud(human_user)
	var/datum/mob_hud/xeno_infection/infection_hud = GLOB.huds[MOB_HUD_XENO_INFECTION]
	infection_hud.remove_from_hud(human_user)

	anim(human_user.loc, human_user, 'icons/mob/mob.dmi', null, "cloak", null, human_user.dir)
	return TRUE

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/proc/fade_in(mob/user)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = user
	if(!camo_active || !istype(human_user))
		return

	if(current_camo < full_camo_alpha)
		current_camo = full_camo_alpha
	current_camo = clamp(current_camo + incremental_shooting_camo_penalty, full_camo_alpha, 255)
	human_user.alpha = current_camo
	if(current_camo > visible_camo_alpha)
		REMOVE_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
		to_chat(human_user, SPAN_BOLDNOTICE("Your cloak can't keep you perfectly hidden anymore!"))
	addtimer(CALLBACK(src, PROC_REF(fade_out_finish), human_user), camouflage_break, TIMER_OVERRIDE|TIMER_UNIQUE)
	animate(human_user, alpha = full_camo_alpha + 5, time = camouflage_break, easing = LINEAR_EASING, flags = ANIMATION_END_NOW)

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/proc/fade_out_finish(mob/living/carbon/human/human_user)
	if(camo_active && human_user?.wear_suit == src)
		ADD_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
		to_chat(human_user, SPAN_BOLDNOTICE("Your cloak shimmers, returning to its perfectly camouflaged state!"))
		animate(human_user, alpha = full_camo_alpha)
		current_camo = full_camo_alpha

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/proc/wrapper_fizzle_camouflage()
	SIGNAL_HANDLER
	var/mob/wearer = src.loc
	wearer.visible_message(SPAN_DANGER("[wearer]'s cloak fizzles out!"), SPAN_DANGER("Your cloak fizzles out!"))
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(5, 4, src)
	sparks.start()
	deactivate_camouflage(wearer, TRUE, TRUE)

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/proc/deactivate_camouflage(mob/living/carbon/human/human_user, anim = TRUE, forced)
	SIGNAL_HANDLER
	if(!istype(human_user))
		return FALSE

	UnregisterSignal(human_user, list(COMSIG_MOB_FIRED_GUN, COMSIG_MOB_FIRED_GUN_ATTACHMENT, COMSIG_HUMAN_EXTINGUISH, COMSIG_MOB_DEATH, COMSIG_MOB_EFFECT_CLOAK_CANCEL))

	if(forced)
		cloak_cooldown = world.time + 10 SECONDS

	camo_active = FALSE
	REMOVE_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	human_user.visible_message(SPAN_DANGER("[human_user] shimmers into existence!"), SPAN_WARNING("Your cloak's camouflage has deactivated!"), max_distance = 4)
	playsound(human_user.loc, 'sound/effects/cloak_scout_off.ogg', 15, TRUE)

	human_user.alpha = initial(human_user.alpha)
	human_user.FF_hit_evade = initial(human_user.FF_hit_evade)

	var/datum/mob_hud/security/advanced/security_hud = GLOB.huds[MOB_HUD_SECURITY_ADVANCED]
	security_hud.add_to_hud(human_user)
	var/datum/mob_hud/xeno_infection/infection_hud = GLOB.huds[MOB_HUD_XENO_INFECTION]
	infection_hud.add_to_hud(human_user)

	if(anim)
		anim(human_user.loc, human_user, 'icons/mob/mob.dmi', null, "uncloak", null, human_user.dir)
	return TRUE

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/zealot
	name = "\improper Sangheili Zealot combat harness"
	desc = "A gold coloured Sangheili combat harness worn by the Zealot rank."
	icon_state = "sang_zealot"
	shield = SANG_SHIELD_ZEALOT
	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/specops
	name = "\improper Sangheili Special Operations combat harness"
	icon_state = "sang_specops"
	shield = SANG_SHIELD_MAJOR
	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/specops/ultra
	name = "\improper Sangheili Special Operations Ultra combat harness"
	icon_state = "sang_specultra"
	shield = SANG_SHIELD_ULTRA
	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/stealth
	name = "\improper Sangheili Stealth combat harness"
	desc = "A light blue Sangheili combat harness for stealth operatives, fitted with active camouflage."
	icon_state = "sang_stealth"
	shield = SANG_SHIELD_STEALTH
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/unggoy/cloaking
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	icon = 'icons/halo/obj/items/clothing/covenant/armor.dmi'
	item_icons = list(WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/unggoy/armor.dmi')
	allowed_species_list = list(SPECIES_UNGGOY)
	valid_accessory_slots = list(ACCESSORY_SLOT_UNGGOY_BICEP, ACCESSORY_SLOT_UNGGOY_SHOULDER)
	restricted_accessory_slots = list(ACCESSORY_SLOT_UNGGOY_BICEP, ACCESSORY_SLOT_UNGGOY_SHOULDER)
	var/camo_active = FALSE
	var/full_camo_alpha = HALO_FULL_PVE_CAMO_ALPHA
	var/incremental_shooting_camo_penalty = 6
	var/current_camo = HALO_FULL_PVE_CAMO_ALPHA
	var/visible_camo_alpha = HALO_VISIBLE_PVE_CAMO_ALPHA
	var/camouflage_break
	var/cloak_cooldown

/obj/item/clothing/suit/marine/unggoy/cloaking/dropped(mob/user)
	if(ishuman(user) && !issynth(user))
		deactivate_camouflage(user, FALSE)
	return ..()

/obj/item/clothing/suit/marine/unggoy/cloaking/attack_self(mob/user)
	. = ..()
	camouflage(user)

/obj/item/clothing/suit/marine/unggoy/cloaking/proc/camouflage(mob/user)
	if(!user || user.is_mob_incapacitated(TRUE) || !ishuman(user))
		return FALSE

	var/mob/living/carbon/human/human_user = user
	if(camo_active)
		deactivate_camouflage(human_user)
		return TRUE

	if(cloak_cooldown && cloak_cooldown > world.time)
		to_chat(human_user, SPAN_WARNING("Your cloak is malfunctioning and can't be enabled right now!"))
		return FALSE

	RegisterSignal(human_user, list(COMSIG_MOB_FIRED_GUN, COMSIG_MOB_FIRED_GUN_ATTACHMENT), PROC_REF(fade_in))
	RegisterSignal(human_user, COMSIG_HUMAN_EXTINGUISH, PROC_REF(wrapper_fizzle_camouflage))
	RegisterSignal(human_user, list(COMSIG_MOB_DEATH, COMSIG_MOB_EFFECT_CLOAK_CANCEL), PROC_REF(deactivate_camouflage), override = TRUE)

	camo_active = TRUE
	ADD_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	human_user.visible_message(SPAN_DANGER("[human_user] vanishes into thin air!"), SPAN_NOTICE("You activate your cloak's camouflage."), max_distance = 4)
	playsound(human_user.loc, 'sound/effects/cloak_scout_on.ogg', 15, TRUE)
	human_user.unset_interaction()
	human_user.alpha = full_camo_alpha
	human_user.FF_hit_evade = 1000

	var/datum/mob_hud/security/advanced/security_hud = GLOB.huds[MOB_HUD_SECURITY_ADVANCED]
	security_hud.remove_from_hud(human_user)
	var/datum/mob_hud/xeno_infection/infection_hud = GLOB.huds[MOB_HUD_XENO_INFECTION]
	infection_hud.remove_from_hud(human_user)

	anim(human_user.loc, human_user, 'icons/mob/mob.dmi', null, "cloak", null, human_user.dir)
	return TRUE

/obj/item/clothing/suit/marine/unggoy/cloaking/proc/fade_in(mob/user)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = user
	if(!camo_active || !istype(human_user))
		return

	if(current_camo < full_camo_alpha)
		current_camo = full_camo_alpha
	current_camo = clamp(current_camo + incremental_shooting_camo_penalty, full_camo_alpha, 255)
	human_user.alpha = current_camo
	if(current_camo > visible_camo_alpha)
		REMOVE_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
		to_chat(human_user, SPAN_BOLDNOTICE("Your cloak can't keep you perfectly hidden anymore!"))
	addtimer(CALLBACK(src, PROC_REF(fade_out_finish), human_user), camouflage_break, TIMER_OVERRIDE|TIMER_UNIQUE)
	animate(human_user, alpha = full_camo_alpha + 5, time = camouflage_break, easing = LINEAR_EASING, flags = ANIMATION_END_NOW)

/obj/item/clothing/suit/marine/unggoy/cloaking/proc/fade_out_finish(mob/living/carbon/human/human_user)
	if(camo_active && human_user?.wear_suit == src)
		ADD_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
		to_chat(human_user, SPAN_BOLDNOTICE("Your cloak shimmers, returning to its perfectly camouflaged state!"))
		animate(human_user, alpha = full_camo_alpha)
		current_camo = full_camo_alpha

/obj/item/clothing/suit/marine/unggoy/cloaking/proc/wrapper_fizzle_camouflage()
	SIGNAL_HANDLER
	var/mob/wearer = src.loc
	wearer.visible_message(SPAN_DANGER("[wearer]'s cloak fizzles out!"), SPAN_DANGER("Your cloak fizzles out!"))
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(5, 4, src)
	sparks.start()
	deactivate_camouflage(wearer, TRUE, TRUE)

/obj/item/clothing/suit/marine/unggoy/cloaking/proc/deactivate_camouflage(mob/living/carbon/human/human_user, anim = TRUE, forced)
	SIGNAL_HANDLER
	if(!istype(human_user))
		return FALSE

	UnregisterSignal(human_user, list(COMSIG_MOB_FIRED_GUN, COMSIG_MOB_FIRED_GUN_ATTACHMENT, COMSIG_HUMAN_EXTINGUISH, COMSIG_MOB_DEATH, COMSIG_MOB_EFFECT_CLOAK_CANCEL))

	if(forced)
		cloak_cooldown = world.time + 10 SECONDS

	camo_active = FALSE
	REMOVE_TRAIT(human_user, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	human_user.visible_message(SPAN_DANGER("[human_user] shimmers into existence!"), SPAN_WARNING("Your cloak's camouflage has deactivated!"), max_distance = 4)
	playsound(human_user.loc, 'sound/effects/cloak_scout_off.ogg', 15, TRUE)
	human_user.alpha = initial(human_user.alpha)
	human_user.FF_hit_evade = initial(human_user.FF_hit_evade)

	var/datum/mob_hud/security/advanced/security_hud = GLOB.huds[MOB_HUD_SECURITY_ADVANCED]
	security_hud.add_to_hud(human_user)
	var/datum/mob_hud/xeno_infection/infection_hud = GLOB.huds[MOB_HUD_XENO_INFECTION]
	infection_hud.add_to_hud(human_user)

	if(anim)
		anim(human_user.loc, human_user, 'icons/mob/mob.dmi', null, "uncloak", null, human_user.dir)
	return TRUE

/obj/item/clothing/suit/marine/unggoy/cloaking/specops
	name = "Unggoy Special Operations combat harness"
	desc = "A dark purple harness reserved for Unggoy Special Operations forces."
	icon_state = "unggoy_specops"
	item_state = "unggoy_specops"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/suit/marine/unggoy/cloaking/specops_ultra
	name = "Unggoy Special Operations Ultra combat harness"
	desc = "A reinforced Special Operations harness used by veteran Unggoy specialists."
	icon_state = "unggoy_specultra"
	item_state = "unggoy_specultra"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH

#undef HALO_FULL_CAMO_ALPHA
#undef HALO_VISIBLE_CAMO_ALPHA
#undef HALO_FULL_PVE_CAMO_ALPHA
#undef HALO_VISIBLE_PVE_CAMO_ALPHA
