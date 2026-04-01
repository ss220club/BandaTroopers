//CANC COPY OF SADAR

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc //single shot and disposable
	name = "\improper PF-199 Anti-Tank RPG"
	desc = "The PF-199 is a lightweight one-shot anti-armor weapon capable of engaging enemy vehicles at ranges up to 500m. Fully disposable, the rocket's launcher is discarded after firing. When stowed (unique-action), the PF-199 system consists of a watertight carbon-fiber composite blast tube, inside of which is an aluminum launch tube containing the missile. The weapon is fired by pushing a charge button on the trigger grip.  It is sighted and fired from the shoulder."
	icon = 'modular/canc_1337/icons/pf199_obj.dmi'
	item_icons = list(
		WEAR_L_HAND = 'modular/canc_1337/icons/lefthand_pf02.dmi',
		WEAR_R_HAND = 'modular/canc_1337/icons/righthand_pf02.dmi'
	)
	icon_state = "pf199"
	item_state = "pf199"
	base_gun_icon = "m83a2" // SS220 EDIT: PF-199 reuses the existing SADAR lineart state

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY_ID("vehicles", /datum/element/bullet_trait_damage_boost, 10, GLOB.damage_boost_vehicles),
	))

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can fold it up with unique-action.")

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	. = ..()
	if(.)
		fired = TRUE

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/unique_action(mob/M)
	if(fired)
		to_chat(M, SPAN_WARNING("\The [src] has already been fired - you can't fold it back up again!"))
		return

	M.visible_message(SPAN_NOTICE("[M] begins to fold up \the [src]."), SPAN_NOTICE("You start to fold and collapse closed \the [src]."))

	if(!do_after(M, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		to_chat(M, SPAN_NOTICE("You stop folding up \the [src]"))
		return

	fold(M)
	M.visible_message(SPAN_NOTICE("[M] finishes folding \the [src]."), SPAN_NOTICE("You finish folding \the [src]."))

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/fold(mob/user)
	var/obj/item/prop/folded_anti_tank_sadar/canc/F = new /obj/item/prop/folded_anti_tank_sadar/canc(src.loc)
	transfer_label_component(F)
	qdel(src)
	user.put_in_active_hand(F)

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/reload()
	to_chat(usr, SPAN_WARNING("You cannot reload \the [src]!"))
	return

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/unload()
	to_chat(usr, SPAN_WARNING("You cannot unload \the [src]!"))
	return

/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/handle_starting_attachment()

//folded version of the canc sadar
/obj/item/prop/folded_anti_tank_sadar/canc
	name = "\improper PF-199 Anti-Tank RPG (folded)"
	desc = "An PF-199 Anti-Tank RPG, compacted for easier storage. Can be unfolded with the Z key."
	icon = 'modular/canc_1337/icons/pf199_obj.dmi'
	item_icons = list(
		WEAR_L_HAND = 'modular/canc_1337/icons/lefthand_pf01.dmi',
		WEAR_R_HAND = 'modular/canc_1337/icons/righthand_pf01.dmi'
	)
	icon_state = "pf199_folded"
	w_class = SIZE_MEDIUM
	garbage = FALSE

/obj/item/prop/folded_anti_tank_sadar/canc/attack_self(mob/user)
	user.visible_message(SPAN_NOTICE("[user] begins to unfold \the [src]."), SPAN_NOTICE("You start to unfold and expand \the [src]."))
	playsound(src, 'sound/items/component_pickup.ogg', 20, TRUE, 5)

	if(!do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		to_chat(user, SPAN_NOTICE("You stop unfolding \the [src]"))
		return

	unfold(user)

	user.visible_message(SPAN_NOTICE("[user] finishes unfolding \the [src]."), SPAN_NOTICE("You finish unfolding \the [src]."))
	playsound(src, 'sound/items/component_pickup.ogg', 20, TRUE, 5)
	. = ..()

/obj/item/prop/folded_anti_tank_sadar/canc/unfold(mob/user)
	var/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc/F = new /obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc(src.loc)
	transfer_label_component(F)
	qdel(src)
	user.put_in_active_hand(F)
