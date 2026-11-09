/obj/item/weapon/shield/riot
	var/mob/living/carbon/human/stance_user
	var/stance_cooldown_until = 0
	var/stance_trait_source

/obj/item/weapon/shield/riot/proc/toggle_breacher_stance(mob/user)
	if(stance_user)
		end_breacher_stance()
		return TRUE
	var/mob/living/carbon/human/human = user
	if(!istype(human) || (human.l_hand != src && human.r_hand != src))
		return TRUE
	if(world.time < stance_cooldown_until)
		to_chat(human, SPAN_WARNING("Щит будет готов через [round((stance_cooldown_until - world.time) / 10)] секунд."))
		return TRUE
	if(human.is_mob_incapacitated() || human.body_position != STANDING_UP)
		return TRUE
	stance_user = human
	stance_trait_source = "breacher_shield_[REF(src)]"
	raise_shield(human)
	ADD_TRAIT(human, TRAIT_IMMOBILIZED, stance_trait_source)
	ADD_TRAIT(human, TRAIT_INCAPACITATED, stance_trait_source)
	RegisterSignal(human, COMSIG_KB_MOB_ACTIVATEINHAND_DOWN, PROC_REF(on_breacher_stance_z))
	RegisterSignal(human, COMSIG_HUMAN_PRE_BULLET_ACT, PROC_REF(on_breacher_stance_projectile))
	RegisterSignal(human, COMSIG_MOB_PRE_CLICK, PROC_REF(on_breacher_stance_click))
	RegisterSignal(human, COMSIG_PARENT_QDELETING, PROC_REF(on_breacher_stance_user_deleted))
	addtimer(CALLBACK(src, PROC_REF(end_breacher_stance)), 30 SECONDS)
	to_chat(human, SPAN_NOTICE("Вы упираете щит в землю. Повторное нажатие Z опустит его."))
	return TRUE

/obj/item/weapon/shield/riot/proc/end_breacher_stance()
	if(!stance_user)
		return
	var/mob/living/carbon/human/human = stance_user
	stance_user = null
	UnregisterSignal(human, list(COMSIG_KB_MOB_ACTIVATEINHAND_DOWN, COMSIG_HUMAN_PRE_BULLET_ACT, COMSIG_MOB_PRE_CLICK, COMSIG_PARENT_QDELETING))
	if(!QDELETED(human))
		REMOVE_TRAIT(human, TRAIT_INCAPACITATED, stance_trait_source)
		REMOVE_TRAIT(human, TRAIT_IMMOBILIZED, stance_trait_source)
		if(shield_readied)
			lower_shield(human)
	stance_cooldown_until = world.time + 3 MINUTES
	stance_trait_source = null

/obj/item/weapon/shield/riot/proc/on_breacher_stance_z(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	end_breacher_stance()
	return COMPONENT_KB_ACTIVATED

/obj/item/weapon/shield/riot/proc/on_breacher_stance_click(mob/living/carbon/human/human, atom/target, list/mods)
	SIGNAL_HANDLER
	return COMPONENT_INTERRUPT_CLICK

/obj/item/weapon/shield/riot/proc/on_breacher_stance_projectile(mob/living/carbon/human/human, obj/projectile/projectile)
	SIGNAL_HANDLER
	if(human != stance_user || !projectile?.starting)
		return
	var/incoming_dir = get_dir(human, projectile.starting)
	if(!(incoming_dir & human.dir))
		return
	projectile.ammo.on_shield_block(human, projectile)
	human.bullet_ping(projectile)
	return COMPONENT_CANCEL_BULLET_ACT

/obj/item/weapon/shield/riot/proc/on_breacher_stance_user_deleted(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	end_breacher_stance()

/obj/item/weapon/shield/riot/montage/attack_self(mob/user)
	return toggle_breacher_stance(user)

/obj/item/weapon/shield/riot/montage/marine
	base_icon_state = "marine_shield"

/obj/item/weapon/shield/riot/ballistic/iasf/attack_self(mob/user)
	return toggle_breacher_stance(user)

/obj/item/weapon/shield/riot/ballistic/twe/attack_self(mob/user)
	return toggle_breacher_stance(user)

/obj/item/weapon/shield/riot/dropped(mob/user)
	if(stance_user)
		end_breacher_stance()
	return ..()

/obj/item/weapon/shield/riot/equipped(mob/user, slot)
	if(stance_user)
		end_breacher_stance()
	return ..()

/obj/item/weapon/shield/riot/Destroy()
	if(stance_user)
		end_breacher_stance()
	return ..()
