// DemonicLynx for BandaMarines

/datum/preferences
	var/banda_show_combat_gear = FALSE

/obj/item/clothing/under/banda_preview_accessory_carrier
	name = "preview accessory carrier"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	contained_sprite = TRUE

/datum/preferences/proc/equip_banda_preview_loadout_cosmetics()
	if(!preview_dummy || !islist(gear))
		return

	var/static/list/preview_categories = list(
		"Eyewear",
		"Headwear",
		"Masks and scarves",
		"Non-standard clothing",
	)
	var/static/list/visible_slots = list(
		WEAR_BODY,
		WEAR_JACKET,
		WEAR_HEAD,
		WEAR_FEET,
		WEAR_FACE,
		WEAR_HANDS,
		WEAR_L_EAR,
		WEAR_R_EAR,
		WEAR_EYES,
		WEAR_WAIST,
	)
	var/obj/item/clothing/under/banda_preview_accessory_carrier/accessory_carrier

	for(var/gear_name in gear)
		var/datum/gear/gear_entry = GLOB.gear_datums_by_name[gear_name]
		if(!gear_entry || !(gear_entry.category in preview_categories) || !ispath(gear_entry.path, /obj/item))
			continue

		var/obj/item/cosmetic_item = new gear_entry.path
		if(istype(cosmetic_item, /obj/item/clothing/accessory))
			var/obj/item/clothing/accessory/accessory = cosmetic_item
			if(!accessory_carrier)
				accessory_carrier = new()
				if(!preview_dummy.equip_to_slot_if_possible(accessory_carrier, WEAR_BODY, del_on_fail = FALSE, disable_warning = TRUE))
					qdel(accessory_carrier)
					accessory_carrier = null
			if(accessory_carrier?.can_attach_accessory(accessory))
				accessory_carrier.attach_accessory(null, accessory, TRUE)
			else
				qdel(accessory)
			continue

		var/equipped = FALSE
		if(gear_entry.slot)
			equipped = preview_dummy.equip_to_slot_if_possible(cosmetic_item, gear_entry.slot, del_on_fail = FALSE, disable_warning = TRUE)
		else
			equipped = preview_dummy.equip_to_appropriate_slot(cosmetic_item, slot_equipment_priority = visible_slots)

		if(!equipped)
			qdel(cosmetic_item)

/// Applies only appearance-safe prosthetic traits to the preferences mannequin.
/// Other character traits may alter skills, components or inventory and must never run on a preview mob.
/datum/preferences/proc/apply_banda_preview_robotic_limbs()
	if(!preview_dummy || !islist(traits))
		return
	for(var/trait_path in traits)
		if(!ispath(trait_path, /datum/character_trait/robo_limb))
			continue
		var/datum/character_trait/robo_limb/robotic_limb = GLOB.character_traits[trait_path]
		robotic_limb?.apply_trait(preview_dummy)

/datum/preferences/proc/get_banda_character_preferences_preview(client/viewer)
	if(!viewer || !preview_dummy)
		return "<div class='prefs-preview-fallback'>NO PREVIEW</div>"

	var/character_url = get_banda_preview_asset(viewer, preview_dummy.dir)
	if(!character_url)
		return "<div class='prefs-preview-fallback'>NO PREVIEW</div>"

	return "<img class='prefs-character-sprite' src='[character_url]' alt='Character preview'>"
