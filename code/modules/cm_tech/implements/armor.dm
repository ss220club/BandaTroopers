/obj/item/clothing/accessory/health
	name = "armor plate"
	desc = "A metal trauma plate, able to absorb some blows."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "regular2_100"
	var/base_icon_state = "regular2"

	slot = ACCESSORY_SLOT_ARMOR_C
	w_class = SIZE_MEDIUM
	/// Whether this accessory provides armor boost
	var/is_armor = TRUE

	/// Reference to the suit this plate is attached to
	var/obj/item/clothing/parent_suit

// Global storage for armor plate data
GLOBAL_LIST_EMPTY(armor_plate_data)

/obj/item/clothing/accessory/health/Destroy()
	if(parent_suit && is_armor)
		remove_armor_boost(parent_suit)
	parent_suit = null
	. = ..()

/obj/item/clothing/accessory/health/on_attached(obj/item/clothing/S, mob/living/carbon/human/user)
	// Only one armor plate per suit
	if(is_armor)
		var/list/plates = get_attached_plates(S)
		for(var/obj/item/clothing/accessory/health/A in plates)
			if(A != src && A.is_armor)
				to_chat(user, SPAN_WARNING("You cannot attach another armor plate, there is already one installed on this suit."))
				return FALSE

	. = ..()
	if(.)
		parent_suit = S
		if(is_armor)
			apply_armor_boost(S)

/obj/item/clothing/accessory/health/on_removed(mob/living/user, obj/item/clothing/C)
	. = ..()
	if(.)
		if(is_armor)
			remove_armor_boost(C)
		parent_suit = null

/// Helper: get stored original armor values for a suit
/obj/item/clothing/accessory/health/proc/get_original_armor(obj/item/clothing/suit)
	var/list/data = GLOB.armor_plate_data[suit]
	if(data)
		return data["original_armor"] // returns associative list with "bullet" and "bomb"
	return null

/// Helper: set stored original armor values for a suit
/obj/item/clothing/accessory/health/proc/set_original_armor(obj/item/clothing/suit, bullet_value, bomb_value)
	if(!GLOB.armor_plate_data[suit])
		GLOB.armor_plate_data[suit] = list()
	var/list/data = GLOB.armor_plate_data[suit]
	data["original_armor"] = list("bullet" = bullet_value, "bomb" = bomb_value)

/// Helper: get list of attached plates for a suit
/obj/item/clothing/accessory/health/proc/get_attached_plates(obj/item/clothing/suit)
	var/list/data = GLOB.armor_plate_data[suit]
	if(data && data["plates"])
		return data["plates"]
	return list()

/// Helper: set list of attached plates for a suit
/obj/item/clothing/accessory/health/proc/set_attached_plates(obj/item/clothing/suit, list/plates)
	if(!GLOB.armor_plate_data[suit])
		GLOB.armor_plate_data[suit] = list()
	var/list/data = GLOB.armor_plate_data[suit]
	data["plates"] = plates

/// Applies armor boost to the suit: +10 bullet, +5 bomb
/obj/item/clothing/accessory/health/proc/apply_armor_boost(obj/item/clothing/suit)
	if(!suit)
		return

	// Store original armor values if not already stored
	var/original = get_original_armor(suit)
	if(original == null)
		var/original_bullet = suit.armor_bullet
		var/original_bomb = suit.armor_bomb // may be null or 0 if not defined
		set_original_armor(suit, original_bullet, original_bomb)

	var/list/attached_plates = get_attached_plates(suit)
	if(!(src in attached_plates))
		attached_plates += src
		set_attached_plates(suit, attached_plates)

	update_suit_armor(suit)

/// Recalculates suit armor based on number of attached plates (each gives +10 bullet, +5 bomb)
/obj/item/clothing/accessory/health/proc/update_suit_armor(obj/item/clothing/suit)
	var/list/original_data = get_original_armor(suit)
	var/original_bullet = original_data ? original_data["bullet"] : suit.armor_bullet
	var/original_bomb = original_data ? original_data["bomb"] : (suit.armor_bomb || 0)

	var/plate_count = length(get_attached_plates(suit))
	var/new_bullet = original_bullet + (plate_count * 10)
	var/new_bomb = original_bomb + (plate_count * 10)

	suit.armor_bullet = new_bullet
	suit.armor_bomb = new_bomb

/// Removes armor boost from the suit
/obj/item/clothing/accessory/health/proc/remove_armor_boost(obj/item/clothing/suit)
	if(!suit)
		return
	var/list/attached_plates = get_attached_plates(suit)
	if(attached_plates)
		attached_plates -= src
		if(length(attached_plates) == 0)
			// Restore original values
			var/list/original_data = get_original_armor(suit)
			if(original_data)
				suit.armor_bullet = original_data["bullet"]
				suit.armor_bomb = original_data["bomb"]
			// Clean up global data
			GLOB.armor_plate_data -= suit
		else
			set_attached_plates(suit, attached_plates)
			update_suit_armor(suit)

// ==================== CONCRETE PLATE TYPES ====================

/obj/item/clothing/accessory/health/ceramic_plate
	name = "ceramic plate"
	desc = "A strong trauma plate, able to protect the user from a large amount of bullets. Ineffective against sharp objects."
	icon_state = "ceramic2_100"
	base_icon_state = "ceramic2"

/obj/item/clothing/accessory/health/ceramic_plate/marine
	name = "ASAPP armor plate"
	desc = "Advanced Small Arms Protective Plate is a modular clip-on armor plate, designed to provide additional protection for USCMC combat personell, gives you extremely good protection against any bullet types, stops full metal jacket, armor piercing and even HEAP rounds."
	icon_state = "armor_plate_100"
	base_icon_state = "armor_plate"
	slot = ACCESSORY_SLOT_PLATE

/obj/item/clothing/accessory/health/ceramic_plate/twe
	name = "HASP armor plate"
	desc = "Hyper Advanced Shield Plate is a modular clip-on armor plate, designed to provide additional protection for RMC combat personell, gives you extremely good protection against any bullet types, stops full metal jacket, armor piercing and even HEAP rounds. This plate includes titanium and can stop even super sonic rounds."
	icon_state = "rmc_armor_plate_100"
	base_icon_state = "rmc_armor_plate"
	slot = ACCESSORY_SLOT_PLATE2

/obj/item/clothing/accessory/health/ceramic_plate/twe/wy
	desc = "Hyper Advanced Shield Plate is a modular clip-on armor plate, designed to provide additional protection for RMC combat personell, though this one has been painted white for service with Weyland Yutani's elite tactical teams. gives you extremely good protection against any bullet types, stops full metal jacket, armor piercing and even HEAP rounds. This plate includes titanium and can stop even super sonic rounds."
	icon_state = "pmc_armor_plate_100"
	base_icon_state = "pmc_armor_plate"

/obj/item/clothing/accessory/health/ceramic_plate/upp
	name = "TNAP armor plate"
	desc = "Titanium Nanocrystalline Alloy Plate is a modular clip-on armor plate, designed to provide additional protection for UPP combat personell, gives you extremely good protection against any bullet types, stops full metal jacket, armor piercing and even HEAP rounds. This plate can stop almost any firearm rounds and have highest protection."
	icon_state = "upp_armor_plate_100"
	base_icon_state = "upp_armor_plate"
	slot = ACCESSORY_SLOT_PLATE3

/obj/item/clothing/accessory/health/scrap
	name = "scrap metal"
	desc = "A weak armor plate, only able to protect from a little bit of damage. Perhaps that will be enough."
	icon_state = "scrap_100"
	base_icon_state = "scrap"

// ==================== RESEARCH PLATES (no armor boost) ====================

/obj/item/clothing/accessory/health/research_plate
	name = "experimental uniform attachment"
	desc = "Attachment to the uniform which gives X (this shouldn't be in your handdssss)"
	is_armor = FALSE
	icon_state = "plate_research"
	var/obj/item/clothing/attached_uni
	///can the plate be recycled after X condition? 0 means it cannot be recycled, otherwise put in the biomass points to refund.
	var/recyclable_value = 0

/obj/item/clothing/accessory/health/research_plate/Destroy()
	attached_uni = null
	. = ..()

/obj/item/clothing/accessory/health/research_plate/on_attached(obj/item/clothing/attached_to, mob/living/carbon/human/user)
	. = ..()
	attached_uni = attached_to
	RegisterSignal(user, COMSIG_MOB_ITEM_UNEQUIPPED, PROC_REF(on_removed_sig))

/obj/item/clothing/accessory/health/research_plate/proc/can_recycle(mob/living/user) //override this proc for check if you can recycle the plate.
	return FALSE

/obj/item/clothing/accessory/health/research_plate/on_removed(mob/living/user, obj/item/clothing/C)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_ITEM_UNEQUIPPED)

/obj/item/clothing/accessory/health/research_plate/proc/on_removed_sig(mob/living/user, slot)
	SIGNAL_HANDLER
	if(slot != attached_uni)
		return FALSE
	UnregisterSignal(user, COMSIG_MOB_ITEM_UNEQUIPPED)
	return TRUE

/obj/item/clothing/accessory/health/research_plate/translator
	name = "experimental language translator"
	desc = "Translates any language heard by the microphones on the plate without any linguistical input, allowing to translate languages never heard before and known languages alike."

/obj/item/clothing/accessory/health/research_plate/translator/on_attached(obj/item/clothing/S, mob/living/carbon/human/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("[src] buzzes as it begins to listen for input."))
	user.universal_understand = TRUE

/obj/item/clothing/accessory/health/research_plate/translator/on_removed(mob/living/carbon/human/user, obj/item/clothing/C)
	. = ..()
	if(user.universal_understand)
		to_chat(user, SPAN_NOTICE("[src] makes a sad woop sound as it powers down."))
		attached_uni = null
		if(user.chem_effect_flags & CHEM_EFFECT_HYPER_THROTTLE) // we are currently under effect of simular univeral understand drug.
			return
		user.universal_understand = FALSE

/obj/item/clothing/accessory/health/research_plate/translator/on_removed_sig(mob/living/carbon/human/user, slot)
	. = ..()
	if(. == FALSE)
		return
	if(user.universal_understand)
		to_chat(user, SPAN_NOTICE("[src] makes a woop sound as it is powered down."))
		if(user.chem_effect_flags & CHEM_EFFECT_HYPER_THROTTLE) // we are currently under effect of simular univeral understand drug.
			return
		attached_uni = null
		user.universal_understand = FALSE

/obj/item/clothing/accessory/health/research_plate/coagulator
	name = "experimental blood coagulator"
	desc = "A device that encourages clotting through the coordinated effort of multiple sensors and radiation emitters. The Surgeon General warns that continuous exposure to radiation may be hazardous to your health."

/obj/item/clothing/accessory/health/research_plate/coagulator/on_attached(obj/item/clothing/S, mob/living/carbon/human/user)
	. = ..()
	if (user.chem_effect_flags & CHEM_EFFECT_NO_BLEEDING)
		return
	user.chem_effect_flags |= CHEM_EFFECT_NO_BLEEDING
	to_chat(user, SPAN_NOTICE("You feel tickling as you activate [src]."))

/obj/item/clothing/accessory/health/research_plate/coagulator/on_removed(mob/living/carbon/human/user, obj/item/clothing/C)
	. = ..()
	if (user.chem_effect_flags & CHEM_EFFECT_NO_BLEEDING)
		user.chem_effect_flags &= CHEM_EFFECT_NO_BLEEDING
		to_chat(user, SPAN_NOTICE("You feel [src] peeling off from your skin."))
		attached_uni = null

/obj/item/clothing/accessory/health/research_plate/coagulator/on_removed_sig(mob/living/carbon/human/user, slot)
	. = ..()
	if(. == FALSE)
		return
	if(user.chem_effect_flags & CHEM_EFFECT_NO_BLEEDING)
		to_chat(user, SPAN_NOTICE("You feel [src] peeling off from your skin."))
		user.chem_effect_flags &= CHEM_EFFECT_NO_BLEEDING
		attached_uni = null

/obj/item/clothing/accessory/health/research_plate/emergency_injector
	name = "emergency chemical plate"
	desc = "One-time disposable research plate packing all kinds of chemicals injected at the will of the user by pressing two buttons on the sides simultaneously. The injection is painless, instant and packs much more chemicals than your normal emergency injector. Features OD Protection in three modes."
	var/od_protection_mode = EMERGENCY_PLATE_OD_PROTECTION_STRICT
	var/datum/action/item_action/activation
	var/mob/living/wearer
	var/used = FALSE
	/// 1 means the player overdosed with OD_OFF mode. 2 means the plate adjusted the chemicals injected.
	var/warning_type = FALSE
	var/list/chemicals_to_inject = list(
		"oxycodone" = 20,
		"bicaridine" = 30,
		"kelotane" = 30,
		"meralyne" = 15,
		"dermaline" = 15,
		"dexalinp" = 1,
		"inaprovaline" = 30,
	)
	recyclable_value = 100

/obj/item/clothing/accessory/health/research_plate/emergency_injector/Destroy()
	wearer = null
	if(!QDELETED(activation))
		QDEL_NULL(activation)
	. = ..()

/obj/item/clothing/accessory/health/research_plate/emergency_injector/get_examine_text(mob/user)
	. = ..()
	. += SPAN_INFO("ALT-Clicking the plate will toggle overdose protection")
	. += SPAN_INFO("Overdose protection seems to be [od_protection_mode == 1 ? "ON" : od_protection_mode == 2 ? "DYNAMIC" : "OFF"]")
	if(used)
		. += SPAN_WARNING("It is already used!")

/obj/item/clothing/accessory/health/research_plate/emergency_injector/clicked(mob/user, list/mods)
	. = ..()
	if(mods[ALT_CLICK])
		var/text = "You toggle overdose protection "
		if(od_protection_mode == EMERGENCY_PLATE_OD_PROTECTION_DYNAMIC)
			od_protection_mode = EMERGENCY_PLATE_OD_PROTECTION_OFF
			text += "to OVERRIDE. Overdose protection is now offline."
		else
			od_protection_mode++
			if(od_protection_mode == EMERGENCY_PLATE_OD_PROTECTION_DYNAMIC)
				text += "to DYNAMIC. Overdose subsystems will inject chemicals but will not go above overdose levels."
			else
				text += "to STRICT. Overdose subsystems will refuse to inject if any of chemicals will overdose."
		to_chat(user, SPAN_NOTICE(text))
		return TRUE
	return

/obj/item/clothing/accessory/health/research_plate/emergency_injector/can_recycle(mob/living/user)
	if(used)
		return TRUE
	return FALSE

/obj/item/clothing/accessory/health/research_plate/emergency_injector/on_attached(obj/item/clothing/S, mob/living/carbon/human/user)
	. = ..()
	wearer = user
	activation = new /datum/action/item_action/emergency_plate/inject_chemicals(src, attached_uni)
	activation.give_to(wearer)

/obj/item/clothing/accessory/health/research_plate/emergency_injector/on_removed(mob/living/user, obj/item/clothing/C)
	. = ..()
	QDEL_NULL(activation)
	attached_uni = null

/obj/item/clothing/accessory/health/research_plate/emergency_injector/on_removed_sig(mob/living/carbon/human/user, slot)
	. = ..()
	if(. == FALSE)
		return
	QDEL_NULL(activation)
	attached_uni = null

//Action buttons
/datum/action/item_action/emergency_plate/inject_chemicals/New(Target, obj/item/holder)
	. = ..()
	name = "Inject Emergency Plate"
	action_icon_state = "plate_research"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/obj/items/items.dmi', button, action_icon_state)

/obj/item/clothing/accessory/health/research_plate/emergency_injector/ui_action_click(mob/owner, obj/item/holder)
	if(used)
		to_chat(wearer, SPAN_DANGER("[src]'s inner reserve is empty, replace the plate!"))
		return
	for(var/chemical in chemicals_to_inject)
		var/datum/reagent/reag = GLOB.chemical_reagents_list[chemical]
		if(wearer.reagents.get_reagent_amount(chemical) + chemicals_to_inject[chemical] > reag.overdose)
			if(od_protection_mode == EMERGENCY_PLATE_OD_PROTECTION_STRICT)
				to_chat(wearer, SPAN_DANGER("You hold the two buttons, but the plate buzzes and refuses to inject, indicating the potential overdose!"))
				return
			if (od_protection_mode == EMERGENCY_PLATE_OD_PROTECTION_DYNAMIC)
				var/adjust_volume_to_inject = reag.overdose - wearer.reagents.get_reagent_amount(chemical)
				chemicals_to_inject[chemical] = adjust_volume_to_inject
				warning_type = EMERGENCY_PLATE_ADJUSTED_WARNING
		if(wearer.reagents.get_reagent_amount(chemical) + chemicals_to_inject[chemical] > reag.overdose && od_protection_mode == EMERGENCY_PLATE_OD_PROTECTION_OFF)
			warning_type = EMERGENCY_PLATE_OD_WARNING
		wearer.reagents.add_reagent(chemical, chemicals_to_inject[chemical])
	if(warning_type == EMERGENCY_PLATE_OD_WARNING)
		to_chat(wearer, SPAN_DANGER("You hold the two buttons, and the plate injects the chemicals, but makes a worrying beep, indicating overdose!"))
	if(warning_type == EMERGENCY_PLATE_ADJUSTED_WARNING)
		to_chat(wearer, SPAN_DANGER("You hold the two buttons, and the plate injects the chemicals, but makes a relieving beep, indicating it adjusted amounts it injected to prevent overdose!"))
	playsound(loc, "sound/items/air_release.ogg", 100, TRUE)
	used = TRUE

/obj/item/clothing/accessory/health/research_plate/anti_decay
	name = "experimental preservation plate"
	desc = "preservation plate which activates once the user is dead, uses variety of different substances and sensors to slow down the decay and increase the time before the user is permanently dead, due to small tank of preservatives, it needs to be replaced on each death."
	var/mob/living/carbon/human/wearer
	var/used = FALSE

/obj/item/clothing/accessory/health/research_plate/anti_decay/Destroy()
	. = ..()
	wearer = null

/obj/item/clothing/accessory/health/research_plate/anti_decay/get_examine_text(mob/user)
	. = ..()
	if(used)
		. += SPAN_WARNING("It is used!")

/obj/item/clothing/accessory/health/research_plate/anti_decay/on_attached(obj/item/clothing/S, mob/living/carbon/human/user)
	. = ..()
	wearer = user
	if(!used)
		RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(begin_preserving))
		user.revive_grace_period += 4 MINUTES

/obj/item/clothing/accessory/health/research_plate/anti_decay/on_removed(mob/living/user, obj/item/clothing/C)
	. = ..()
	wearer = null
	attached_uni = null

/obj/item/clothing/accessory/health/research_plate/anti_decay/on_removed_sig(mob/living/user, slot)
	. = ..()
	if(. == FALSE)
		return
	wearer = null
	attached_uni = null

/obj/item/clothing/accessory/health/research_plate/anti_decay/proc/begin_preserving()
	SIGNAL_HANDLER
	UnregisterSignal(wearer, COMSIG_MOB_DEATH)
	to_chat(wearer, SPAN_NOTICE("The [src] detects your death and starts injecting various chemicals to slow down your final demise!"))
	RegisterSignal(wearer, COMSIG_HUMAN_REVIVED, PROC_REF(onetime_use))
	used = TRUE

/obj/item/clothing/accessory/health/research_plate/anti_decay/proc/onetime_use()
	SIGNAL_HANDLER
	UnregisterSignal(wearer, COMSIG_HUMAN_REVIVED)
	to_chat(wearer, SPAN_NOTICE("[icon2html(src, viewers(src))] \The <b>[src]</b> beeps: Chemical preservatives reserves depleted, replace the [src]"))
	wearer.revive_grace_period = 5 MINUTES
