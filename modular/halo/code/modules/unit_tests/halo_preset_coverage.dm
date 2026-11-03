#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/halo_preset_coverage

/datum/unit_test/halo_preset_coverage/Run()
	var/list/equipment_presets = list(
		/datum/equipment_preset/covenant/sangheili/minor,
		/datum/equipment_preset/covenant/sangheili/major,
		/datum/equipment_preset/covenant/sangheili/ultra,
		/datum/equipment_preset/covenant/sangheili/zealot,
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle,
		/datum/equipment_preset/covenant/sangheili/minor/needler,
		/datum/equipment_preset/covenant/sangheili/minor/carbine,
		/datum/equipment_preset/covenant/sangheili/major/plasma_rifle,
		/datum/equipment_preset/covenant/sangheili/major/needler,
		/datum/equipment_preset/covenant/sangheili/major/carbine,
		/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle,
		/datum/equipment_preset/covenant/sangheili/ultra/carbine,
		/datum/equipment_preset/covenant/sangheili/zealot/plasma_rifle,
		/datum/equipment_preset/covenant/sangheili/zealot/carbine,
		/datum/equipment_preset/covenant/sangheili/zealot/cloaking,
		/datum/equipment_preset/covenant/sangheili/zealot/stealth,
		/datum/equipment_preset/covenant/sangheili/specops,
		/datum/equipment_preset/covenant/sangheili/specops/carbine,
		/datum/equipment_preset/covenant/sangheili/specops/cloaking,
		/datum/equipment_preset/covenant/sangheili/specops_ultra,
		/datum/equipment_preset/covenant/sangheili/specops_ultra/carbine,
		/datum/equipment_preset/covenant/sangheili/specops_ultra/cloaking,
		/datum/equipment_preset/covenant/sangheili/stealth,
		/datum/equipment_preset/covenant/sangheili/stealth/needler,
		/datum/equipment_preset/covenant/sangheili/honor_guard,
		/datum/equipment_preset/covenant/unggoy/minor,
		/datum/equipment_preset/covenant/unggoy/major,
		/datum/equipment_preset/covenant/unggoy/heavy,
		/datum/equipment_preset/covenant/unggoy/ultra,
		/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/minor/needler,
		/datum/equipment_preset/covenant/unggoy/minor/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/major/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/major/needler,
		/datum/equipment_preset/covenant/unggoy/major/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/heavy/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/heavy/needler,
		/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/ultra/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/ultra/needler,
		/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/specops,
		/datum/equipment_preset/covenant/unggoy/specops/lesser,
		/datum/equipment_preset/covenant/unggoy/specops_ultra,
		/datum/equipment_preset/covenant/unggoy/deacon,
		/datum/equipment_preset/covenant/unggoy/specops/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/specops/needler,
		/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle/cloaked,
		/datum/equipment_preset/covenant/unggoy/specops/lesser/needler,
		/datum/equipment_preset/covenant/unggoy/specops/lesser/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/needler,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle/cloaked,
		/datum/equipment_preset/covenant/unggoy/deacon/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/deacon/needler,
		/datum/equipment_preset/covenant/unggoy/deacon/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical,
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber,
		/datum/equipment_preset/covenant/ruuhtian/minor,
		/datum/equipment_preset/covenant/ruuhtian/major,
		/datum/equipment_preset/covenant/ruuhtian/ultra,
		/datum/equipment_preset/covenant/ruuhtian/marksman,
		/datum/equipment_preset/covenant/ruuhtian/sniper,
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler,
		/datum/equipment_preset/covenant/ruuhtian/major/needler,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle,
		/datum/equipment_preset/covenant/ruuhtian/ultra/needler,
		/datum/equipment_preset/covenant/ruuhtian/ultra/plasma_rifle,
		/datum/equipment_preset/covenant/ruuhtian/ultra/carbine,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine,
		/datum/equipment_preset/covenant/ruuhtian/sniper/carbine,
		/datum/equipment_preset/unsc/pfc/equipped,
		/datum/equipment_preset/unsc/medic/equipped,
		/datum/equipment_preset/unsc/rto/equipped,
		/datum/equipment_preset/unsc/tl/equipped,
		/datum/equipment_preset/unsc/leader/equipped,
		/datum/equipment_preset/unsc/platco/equipped,
		/datum/equipment_preset/unsc/pilot/equipped,
		/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper,
		/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man,
		/datum/equipment_preset/unsc/spartan/equipped,
		/datum/equipment_preset/unsc/spartan/sniper,
		/datum/equipment_preset/unsc/spartan/spnkr,
		/datum/equipment_preset/unsc/spartan/cqc,
		/datum/equipment_preset/unsc/pfc/odst/equipped,
		/datum/equipment_preset/unsc/medic/odst/equipped,
		/datum/equipment_preset/unsc/rto/odst/equipped,
		/datum/equipment_preset/unsc/tl/odst/equipped,
		/datum/equipment_preset/unsc/leader/odst/equipped,
		/datum/equipment_preset/unsc/platco/odst/equipped,
		/datum/equipment_preset/unsc/spec/odst/equipped_sniper/ai_sniper,
		/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/ai_man,
		/datum/equipment_preset/oni/security,
		/datum/equipment_preset/oni/security/corpsman,
		/datum/equipment_preset/oni/security/lead,
		/datum/equipment_preset/oni/field,
		/datum/equipment_preset/oni/field/agent,
		/datum/equipment_preset/oni/field/agent/senior,
		/datum/equipment_preset/police/officer/geared,
		/datum/equipment_preset/police/officer/geared/smg,
		/datum/equipment_preset/police/officer/geared/enforcer,
		/datum/equipment_preset/police/officer/sergeant/geared,
		/datum/equipment_preset/police/officer/chief,
		/datum/equipment_preset/insurgent/rifleman,
		/datum/equipment_preset/insurgent/rifleman/breacher,
		/datum/equipment_preset/insurgent/rifleman/sl,
		/datum/equipment_preset/insurgent/technician,
		/datum/equipment_preset/insurgent/specialist/ai_man,
		/datum/equipment_preset/insurgent/specialist/sniper,
		/datum/equipment_preset/insurgent/officer,
		/datum/equipment_preset/insurgent/cell_leader,
	)

	var/list/equipment_presets_to_validate = list()
	for(var/preset_path as anything in equipment_presets)
		equipment_presets_to_validate[preset_path] = TRUE

	validate_cloaked_preset_hud_cleanup(/datum/equipment_preset/covenant/sangheili/specops/cloaking)
	validate_cloaked_preset_hud_cleanup(/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle/cloaked)

	validate_leader_dmr(/datum/equipment_preset/unsc/tl/equipped)
	validate_leader_dmr(/datum/equipment_preset/unsc/leader/equipped)
	validate_leader_dmr(/datum/equipment_preset/unsc/platco/equipped)
	validate_leader_dmr(/datum/equipment_preset/unsc/platco/odst/equipped)
	validate_leader_dmr(/datum/equipment_preset/unsc/tl/odst/equipped)
	validate_leader_dmr(/datum/equipment_preset/unsc/leader/odst/equipped)

	validate_species_preset(/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle, SPECIES_SANGHEILI)
	validate_species_preset(/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol, SPECIES_UNGGOY)
	validate_species_preset(/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol, SPECIES_RUUHTIAN)
	validate_species_preset(/datum/equipment_preset/unsc/spartan/equipped, SPECIES_SPARTAN)

	validate_equipment_faction(/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle, FACTION_SANGHEILI)
	validate_equipment_faction(/datum/equipment_preset/covenant/sangheili/specops/cloaking, FACTION_SPECOPS_SANGHEILI)
	validate_equipment_faction(/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol, FACTION_UNGGOY)
	validate_equipment_faction(/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle, FACTION_SPECOPS_UNGGOY)
	validate_equipment_faction(/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol, FACTION_KIGYAR)
	validate_equipment_faction(/datum/equipment_preset/unsc/spartan/equipped, FACTION_UNSC)

	validate_store_weapon(/datum/equipment_preset/covenant/sangheili/minor, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/sangheili/major, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/sangheili/ultra, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/sangheili/zealot, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/minor, /obj/item/weapon/gun/energy/plasma/plasma_pistol)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/major, /obj/item/weapon/gun/energy/plasma/plasma_pistol)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/heavy, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/ultra, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops/lesser, /obj/item/weapon/gun/energy/plasma/plasma_pistol)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops/lesser/needler, /obj/item/weapon/gun/smg/covenant_needler)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops/lesser/plasma_rifle, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops_ultra, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/deacon, /obj/item/weapon/gun/energy/plasma/plasma_pistol)
	validate_store_weapon(/datum/equipment_preset/covenant/ruuhtian/minor, /obj/item/weapon/gun/energy/plasma/plasma_pistol)
	validate_store_weapon(/datum/equipment_preset/covenant/ruuhtian/major, /obj/item/weapon/gun/smg/covenant_needler)
	validate_store_weapon(/datum/equipment_preset/covenant/ruuhtian/ultra, /obj/item/weapon/gun/smg/covenant_needler)
	validate_store_weapon(/datum/equipment_preset/covenant/ruuhtian/marksman, /obj/item/weapon/gun/rifle/covenant_carbine)
	validate_store_weapon(/datum/equipment_preset/covenant/ruuhtian/sniper, /obj/item/weapon/gun/rifle/covenant_carbine)
	validate_spnkr_pack(/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man)
	validate_spnkr_pack(/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/ai_man)
	validate_spnkr_pack(/datum/equipment_preset/unsc/spartan/spnkr)
	validate_spnkr_pack(/datum/equipment_preset/unsc/spartan/spnkr/ai_man)
	validate_designated_rifle_resupply()

	collect_halo_human_ai_equipment(equipment_presets_to_validate)
	collect_halo_squad_equipment(equipment_presets_to_validate)
	for(var/preset_path as anything in equipment_presets_to_validate)
		validate_equipment_preset(preset_path)

	validate_halo_species_icon_templates()
	validate_halo_item_tree_icons()

/datum/unit_test/halo_preset_coverage/proc/create_test_human()
	return new /mob/living/carbon/human(run_loc_floor_bottom_left)

/datum/unit_test/halo_preset_coverage/proc/is_halo_human_ai_preset_path(ai_preset_path)
	return ispath(ai_preset_path, /datum/human_ai_equipment_preset/covenant) \
		|| ispath(ai_preset_path, /datum/human_ai_equipment_preset/unsc) \
		|| ispath(ai_preset_path, /datum/human_ai_equipment_preset/unsc_crew) \
		|| ispath(ai_preset_path, /datum/human_ai_equipment_preset/oni) \
		|| ispath(ai_preset_path, /datum/human_ai_equipment_preset/police) \
		|| ispath(ai_preset_path, /datum/human_ai_equipment_preset/insurgent)

/datum/unit_test/halo_preset_coverage/proc/is_halo_squad_preset_path(squad_preset_path)
	return ispath(squad_preset_path, /datum/human_ai_squad_preset/covenant) \
		|| ispath(squad_preset_path, /datum/human_ai_squad_preset/unsc) \
		|| ispath(squad_preset_path, /datum/human_ai_squad_preset/oni) \
		|| ispath(squad_preset_path, /datum/human_ai_squad_preset/police) \
		|| ispath(squad_preset_path, /datum/human_ai_squad_preset/insurgent)

/datum/unit_test/halo_preset_coverage/proc/collect_halo_human_ai_equipment(list/equipment_presets_to_validate)
	for(var/datum/human_ai_equipment_preset/ai_preset_path as anything in subtypesof(/datum/human_ai_equipment_preset))
		if(!is_halo_human_ai_preset_path(ai_preset_path))
			continue
		if(!ai_preset_path::name || !ai_preset_path::path)
			continue

		var/datum/human_ai_equipment_preset/ai_preset = new ai_preset_path
		if(!ispath(ai_preset.path, /datum/equipment_preset))
			Fail("[ai_preset_path] points to missing equipment preset [ai_preset.path]", __FILE__, __LINE__)
		else
			equipment_presets_to_validate[ai_preset.path] = TRUE
		qdel(ai_preset)

/datum/unit_test/halo_preset_coverage/proc/collect_halo_squad_equipment(list/equipment_presets_to_validate)
	for(var/datum/human_ai_squad_preset/squad_preset_path as anything in subtypesof(/datum/human_ai_squad_preset))
		if(!is_halo_squad_preset_path(squad_preset_path))
			continue
		if(!squad_preset_path::name)
			continue

		var/datum/human_ai_squad_preset/squad_preset = new squad_preset_path
		for(var/equipment_preset_path as anything in squad_preset.ai_to_spawn)
			if(ispath(equipment_preset_path, /datum/equipment_preset))
				equipment_presets_to_validate[equipment_preset_path] = TRUE
		qdel(squad_preset)

/datum/unit_test/halo_preset_coverage/proc/validate_equipment_preset(preset_path)
	if(!ispath(preset_path, /datum/equipment_preset))
		Fail("[preset_path] is not an equipment preset path", __FILE__, __LINE__)
		return
	var/datum/equipment_preset/preset = new preset_path
	if(!(preset.flags & EQUIPMENT_PRESET_EXTRA))
		Fail("[preset_path] is not exposed through extra presets", __FILE__, __LINE__)
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	if(halo_preset_requires_combat_gear(preset_path))
		if(!test_human.get_item_by_slot(WEAR_BODY))
			Fail("[preset_path] did not equip a uniform", __FILE__, __LINE__)
		if(!test_human.get_item_by_slot(WEAR_JACKET))
			Fail("[preset_path] did not equip armor/suit", __FILE__, __LINE__)
		if(!halo_human_has_combat_item(test_human))
			Fail("[preset_path] did not equip a combat weapon", __FILE__, __LINE__)
	validate_halo_human_inventory_icons(test_human, "[preset_path]")
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/halo_preset_requires_combat_gear(preset_path)
	if(ispath(preset_path, /datum/equipment_preset/unsc_crew))
		return FALSE
	if(preset_path == /datum/equipment_preset/police/officer || preset_path == /datum/equipment_preset/police/officer/sergeant)
		return FALSE
	if(ispath(preset_path, /datum/equipment_preset/insurgent/partisan/plainclothes))
		return FALSE
	return TRUE

/datum/unit_test/halo_preset_coverage/proc/halo_human_has_combat_item(mob/living/carbon/human/test_human)
	var/list/seen_items = list()
	var/list/combat_slots = list(
		WEAR_J_STORE,
		WEAR_BACK,
		WEAR_WAIST,
		WEAR_L_HAND,
		WEAR_R_HAND,
	)
	for(var/slot as anything in combat_slots)
		var/obj/item/item = test_human.get_item_by_slot(slot)
		if(halo_item_tree_has_combat_item(item, seen_items))
			return TRUE
	for(var/obj/item/item in test_human.contents)
		if(halo_item_tree_has_combat_item(item, seen_items))
			return TRUE
	return FALSE

/datum/unit_test/halo_preset_coverage/proc/halo_item_tree_has_combat_item(obj/item/item, list/seen_items)
	if(!item || seen_items[item])
		return FALSE
	seen_items[item] = TRUE
	if(istype(item, /obj/item/weapon/gun) || istype(item, /obj/item/weapon/covenant/energy_sword) || istype(item, /obj/item/explosive))
		return TRUE
	for(var/obj/item/contained_item in item.contents)
		if(halo_item_tree_has_combat_item(contained_item, seen_items))
			return TRUE
	return FALSE

/datum/unit_test/halo_preset_coverage/proc/is_halo_icon_file(icon_file)
	if(!icon_file)
		return FALSE
	var/icon_path = "[icon_file]"
	return findtext(icon_path, "modular/halo/") || findtext(icon_path, "icons/halo/")

/datum/unit_test/halo_preset_coverage/proc/is_halo_object_icon_file(icon_file)
	if(!icon_file)
		return FALSE
	var/icon_path = "[icon_file]"
	return findtext(icon_path, "modular/halo/icons/halo/obj/") || findtext(icon_path, "icons/halo/obj/")

/datum/unit_test/halo_preset_coverage/proc/should_audit_halo_item(obj/item/item)
	if(!item)
		return FALSE
	var/type_path = "[item.type]"
	if(findtext(type_path, "/covenant") || findtext(type_path, "/sangheili") || findtext(type_path, "/unggoy") || findtext(type_path, "/ruuhtian") || findtext(type_path, "/kigyar"))
		return TRUE
	if(findtext(type_path, "/spartan") || findtext(type_path, "/spnkr") || findtext(type_path, "/halo") || findtext(type_path, "/ma5") || findtext(type_path, "/br55") || findtext(type_path, "/dmr"))
		return TRUE
	if(findtext(type_path, "/unsc") || findtext(type_path, "/odst") || findtext(type_path, "/oni"))
		return TRUE
	if(is_halo_icon_file(item.icon) || is_halo_icon_file(item.icon_override))
		return TRUE
	if(LAZYLEN(item.item_icons))
		for(var/slot as anything in item.item_icons)
			if(is_halo_icon_file(item.item_icons[slot]))
				return TRUE
	if(LAZYLEN(item.sprite_sheets))
		for(var/bodytype as anything in item.sprite_sheets)
			if(is_halo_icon_file(item.sprite_sheets[bodytype]))
				return TRUE
	if(istype(item, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/accessory = item
		for(var/slot as anything in accessory.accessory_icons)
			if(is_halo_icon_file(accessory.accessory_icons[slot]))
				return TRUE
	return FALSE

/datum/unit_test/halo_preset_coverage/proc/halo_icon_state_exists(icon_file, icon_state)
	if(!icon_file || isnull(icon_state) || !length("[icon_state]"))
		return TRUE
	var/static/list/icon_state_cache = list()
	var/icon_key = "[icon_file]"
	if(isnull(icon_state_cache[icon_key]))
		icon_state_cache[icon_key] = icon_states(icon_file, 1)
	return "[icon_state]" in icon_state_cache[icon_key]

/datum/unit_test/halo_preset_coverage/proc/validate_halo_icon_state(context, icon_file, icon_state)
	if(!icon_file || isnull(icon_state) || !length("[icon_state]"))
		return
	if(!halo_icon_state_exists(icon_file, icon_state))
		Fail("[context] references missing icon_state \"[icon_state]\" in '[icon_file]'", __FILE__, __LINE__)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_human_inventory_icons(mob/living/carbon/human/test_human, context)
	var/list/seen_items = list()
	var/list/worn_slots = list(
		WEAR_BODY,
		WEAR_JACKET,
		WEAR_HANDS,
		WEAR_FEET,
		WEAR_HEAD,
		WEAR_WAIST,
		WEAR_BACK,
		WEAR_J_STORE,
		WEAR_L_EAR,
		WEAR_R_EAR,
		WEAR_EYES,
		WEAR_FACE,
		WEAR_ID,
		WEAR_ACCESSORY,
		WEAR_L_HAND,
		WEAR_R_HAND,
	)
	for(var/slot as anything in worn_slots)
		var/worn_slot_value = test_human.get_item_by_slot(slot)
		if(islist(worn_slot_value))
			for(var/obj/item/worn_list_item in worn_slot_value)
				validate_halo_item_icon_states(worn_list_item, test_human, context, seen_items, slot)
			continue
		var/obj/item/worn_item = worn_slot_value
		if(worn_item)
			validate_halo_item_icon_states(worn_item, test_human, context, seen_items, slot)
	for(var/obj/item/item in test_human.contents)
		validate_halo_item_icon_states(item, test_human, context, seen_items)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_item_icon_states(obj/item/item, mob/living/carbon/human/test_human, context, list/seen_items, worn_slot = null)
	if(!item || seen_items[item])
		return
	seen_items[item] = TRUE

	var/audit_item = should_audit_halo_item(item)
	if(audit_item)
		validate_halo_icon_state("[context] [item.type] object", item.icon, item.icon_state)
		if(!isnull(worn_slot))
			validate_halo_worn_icon_state(item, test_human, context, worn_slot)
		if(istype(item, /obj/item/attachable))
			var/obj/item/attachable/attachable = item
			validate_halo_icon_state("[context] [item.type] attach overlay", attachable.icon, attachable.attach_icon)
		if(istype(item, /obj/item/clothing/accessory))
			validate_halo_accessory_icon_states(item, context, worn_slot)

	if(istype(item, /obj/item/clothing))
		var/obj/item/clothing/clothing = item
		for(var/obj/item/clothing/accessory/accessory in clothing.accessories)
			validate_halo_item_icon_states(accessory, test_human, context, seen_items, worn_slot)

	for(var/obj/item/contained_item in item.contents)
		validate_halo_item_icon_states(contained_item, test_human, context, seen_items)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_worn_icon_state(obj/item/item, mob/living/carbon/human/test_human, context, worn_slot)
	var/worn_state = item.get_icon_state(test_human, worn_slot)
	var/worn_icon
	var/uses_contained_sprite = FALSE
	if(item.icon_override)
		worn_icon = item.icon_override
		if(worn_slot == WEAR_L_HAND)
			worn_state = "[worn_state]_l"
		else if(worn_slot == WEAR_R_HAND)
			worn_state = "[worn_state]_r"
	else if(ishuman(test_human))
		var/bodytype = test_human.species.get_bodytype(test_human)
		if(item.use_spritesheet(bodytype, worn_slot, worn_state))
			worn_icon = item.sprite_sheets[bodytype]
	if(!worn_icon && item.contained_sprite)
		uses_contained_sprite = TRUE
		worn_icon = item.icon
	if(!worn_icon && LAZYISIN(item.item_icons, worn_slot))
		worn_icon = item.item_icons[worn_slot]
	if(!worn_icon && LAZYISIN(GLOB.default_onmob_icons, worn_slot))
		worn_icon = GLOB.default_onmob_icons[worn_slot]
	if(worn_icon)
		validate_halo_worn_icon_source(item, context, worn_slot, worn_icon, uses_contained_sprite)
		validate_halo_icon_state("[context] [item.type] worn slot [worn_slot]", worn_icon, worn_state)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_worn_icon_source(obj/item/item, context, worn_slot, worn_icon, uses_contained_sprite)
	if(worn_slot == WEAR_L_HAND || worn_slot == WEAR_R_HAND)
		return

	if(uses_contained_sprite && is_halo_object_icon_file(item.icon))
		Fail("[context] [item.type] worn slot [worn_slot] uses contained_sprite from object icon '[item.icon]'", __FILE__, __LINE__)

	if(is_halo_object_icon_file(worn_icon))
		Fail("[context] [item.type] worn slot [worn_slot] uses object icon '[worn_icon]' as an onmob overlay", __FILE__, __LINE__)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_accessory_icon_states(obj/item/clothing/accessory/accessory, context, worn_slot = null)
	var/accessory_state = accessory.overlay_state ? accessory.overlay_state : accessory.icon_state
	if(!isnull(worn_slot) && LAZYISIN(accessory.accessory_icons, worn_slot))
		validate_halo_icon_state("[context] [accessory.type] accessory slot [worn_slot]", accessory.accessory_icons[worn_slot], accessory_state)
	if(accessory.icon_override && halo_icon_state_exists(accessory.icon_override, "[accessory_state]_mob"))
		validate_halo_icon_state("[context] [accessory.type] accessory override", accessory.icon_override, "[accessory_state]_mob")

/datum/unit_test/halo_preset_coverage/proc/validate_halo_item_tree_icons()
	var/list/item_roots = list(
		list(/obj/item/clothing/gloves/marine/sangheili, SPECIES_SANGHEILI, WEAR_HANDS),
		list(/obj/item/clothing/head/helmet/marine/sangheili, SPECIES_SANGHEILI, WEAR_HEAD),
		list(/obj/item/clothing/shoes/sangheili, SPECIES_SANGHEILI, WEAR_FEET),
		list(/obj/item/clothing/suit/marine/shielded/sangheili, SPECIES_SANGHEILI, WEAR_JACKET),
		list(/obj/item/clothing/suit/marine/shielded/sangheili/cloaking, SPECIES_SANGHEILI, WEAR_JACKET),
		list(/obj/item/clothing/accessory/pads/sangheili, SPECIES_SANGHEILI, WEAR_JACKET),
		list(/obj/item/clothing/gloves/marine/unggoy, SPECIES_UNGGOY, WEAR_HANDS),
		list(/obj/item/clothing/head/helmet/marine/unggoy, SPECIES_UNGGOY, WEAR_HEAD),
		list(/obj/item/clothing/shoes/unggoy, SPECIES_UNGGOY, WEAR_FEET),
		list(/obj/item/clothing/suit/marine/unggoy, SPECIES_UNGGOY, WEAR_JACKET),
		list(/obj/item/clothing/suit/marine/unggoy/cloaking, SPECIES_UNGGOY, WEAR_JACKET),
		list(/obj/item/clothing/accessory/pads/unggoy, SPECIES_UNGGOY, WEAR_JACKET),
		list(/obj/item/storage/belt/marine/covenant/unggoy, SPECIES_UNGGOY, WEAR_WAIST),
		list(/obj/item/storage/backpack/covenant/unggoy, SPECIES_UNGGOY, WEAR_BACK),
		list(/obj/item/clothing/gloves/marine/ruuhtian, SPECIES_RUUHTIAN, WEAR_HANDS),
		list(/obj/item/clothing/head/helmet/marine/ruuhtian, SPECIES_RUUHTIAN, WEAR_HEAD),
		list(/obj/item/clothing/shoes/ruuhtian, SPECIES_RUUHTIAN, WEAR_FEET),
		list(/obj/item/clothing/suit/marine/ruuhtian, SPECIES_RUUHTIAN, WEAR_JACKET),
		list(/obj/item/storage/belt/marine/covenant/ruuhtian, SPECIES_RUUHTIAN, WEAR_WAIST),
		list(/obj/item/attachable/flashlight/ma5, null, null),
		list(/obj/item/attachable/attached_gun/grenade/ma5, null, null),
		list(/obj/item/weapon/gun/rifle/halo, null, WEAR_BACK),
		list(/obj/item/weapon/gun/rifle/halo, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/rifle/halo, null, WEAR_R_HAND),
		list(/obj/item/weapon/gun/smg/halo, null, WEAR_BACK),
		list(/obj/item/weapon/gun/smg/halo, null, WEAR_WAIST),
		list(/obj/item/weapon/gun/smg/halo, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/shotgun/pump/halo, null, WEAR_BACK),
		list(/obj/item/weapon/gun/shotgun/pump/halo, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/rifle/sniper/halo, null, WEAR_BACK),
		list(/obj/item/weapon/gun/energy/plasma, null, WEAR_BACK),
		list(/obj/item/weapon/gun/energy/plasma/plasma_pistol, null, WEAR_WAIST),
		list(/obj/item/weapon/gun/energy/plasma, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/smg/covenant_needler, null, WEAR_BACK),
		list(/obj/item/weapon/gun/smg/covenant_needler, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/rifle/covenant_carbine, null, WEAR_BACK),
		list(/obj/item/weapon/gun/rifle/covenant_carbine, null, WEAR_J_STORE),
		list(/obj/item/weapon/gun/halo_launcher/spnkr, null, WEAR_BACK),
		list(/obj/item/storage/large_holster/spnkr, null, WEAR_BACK),
		list(/obj/item/storage/belt/gun/m6, null, WEAR_WAIST),
		list(/obj/item/storage/belt/gun/m7, null, WEAR_WAIST),
	)

	for(var/list/item_root_data as anything in item_roots)
		validate_halo_item_type_tree(item_root_data[1], item_root_data[2], item_root_data[3])

/datum/unit_test/halo_preset_coverage/proc/validate_halo_species_icon_templates()
	validate_halo_adjusted_species_template(/datum/species/sangheili)
	validate_halo_adjusted_species_template(/datum/species/unggoy)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_adjusted_species_template(species_path)
	var/datum/species/species = new species_path
	if(species.icon_template != 'modular/halo/icons/mob/humans/template_96.dmi')
		Fail("[species_path] uses [species.icon_template] instead of the modular PVE 96x96 offset template", __FILE__, __LINE__)
	qdel(species)

/datum/unit_test/halo_preset_coverage/proc/validate_halo_item_type_tree(item_root, species_name, worn_slot)
	var/list/item_types = list(item_root)
	item_types += subtypesof(item_root)
	for(var/item_type as anything in item_types)
		if(!ispath(item_type, /obj/item))
			continue
		var/obj/item/item_path = item_type
		if(initial(item_path.flags_item) & ITEM_ABSTRACT)
			continue
		var/mob/living/carbon/human/test_human = create_test_human()
		if(species_name)
			test_human.set_species(species_name)
		var/obj/item/item = new item_type(test_human)
		validate_halo_item_icon_states(item, test_human, "[item_type]", list(), worn_slot)
		qdel(test_human)

/datum/unit_test/halo_preset_coverage/proc/validate_cloaked_preset_hud_cleanup(preset_path)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/datum/mob_hud/security/advanced/security_hud = GLOB.huds[MOB_HUD_SECURITY_ADVANCED]
	var/datum/mob_hud/xeno_infection/infection_hud = GLOB.huds[MOB_HUD_XENO_INFECTION]
	qdel(test_human)
	if(test_human in security_hud.hudmobs)
		Fail("[preset_path] left a qdel'd human in the advanced security HUD", __FILE__, __LINE__)
	if(test_human in infection_hud.hudmobs)
		Fail("[preset_path] left a qdel'd human in the xeno infection HUD", __FILE__, __LINE__)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_leader_dmr(preset_path)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/weapon/gun/rifle/halo/dmr/leader_dmr = test_human.get_item_by_slot(WEAR_J_STORE)
	if(!istype(leader_dmr))
		Fail("[preset_path] did not equip an M392 DMR in suit storage", __FILE__, __LINE__)
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_species_preset(preset_path, expected_species)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	if(!test_human.species || test_human.species.name != expected_species)
		Fail("[preset_path] expected species [expected_species], got [test_human.species?.name || "none"]", __FILE__, __LINE__)
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_store_weapon(preset_path, expected_type)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/stored_item = test_human.get_item_by_slot(WEAR_J_STORE)
	if(!istype(stored_item, expected_type))
		Fail("[preset_path] expected [expected_type] in suit storage, got [stored_item?.type || "none"]", __FILE__, __LINE__)
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_spnkr_pack(preset_path)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = create_test_human()
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/storage/large_holster/spnkr/spnkr_pack = test_human.get_item_by_slot(WEAR_BACK)
	if(!istype(spnkr_pack))
		Fail("[preset_path] did not equip a SPNKr transport pack on the back slot", __FILE__, __LINE__)
		qdel(test_human)
		qdel(preset)
		return
	var/ammo_count = 0
	for(var/obj/item/ammo_magazine/spnkr/ammo in spnkr_pack.contents)
		ammo_count++
	if(ammo_count != 2)
		Fail("[preset_path] expected 2 SPNKr rocket tubes in the pack, got [ammo_count]", __FILE__, __LINE__)
	var/obj/item/weapon/gun/halo_launcher/spnkr/launcher = locate(/obj/item/weapon/gun/halo_launcher/spnkr) in spnkr_pack.contents
	if(!launcher)
		Fail("[preset_path] expected an M41 SPNKr inside the pack", __FILE__, __LINE__)
	else
		if(istype(launcher, /obj/item/weapon/gun/halo_launcher/spnkr/unloaded) || !launcher.current_mag)
			Fail("[preset_path] expected a loaded M41 SPNKr inside the pack", __FILE__, __LINE__)
	if(spnkr_pack.icon_state != "spnkrpack_2")
		Fail("[preset_path] expected a full SPNKr pack icon_state, got [spnkr_pack.icon_state]", __FILE__, __LINE__)
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_designated_rifle_resupply()
	var/obj/item/ammo_box/magazine/unsc/dmr/dmr_box = new
	if(dmr_box.magazine_type != /obj/item/ammo_magazine/rifle/halo/dmr)
		Fail("HALO DMR ammo box points to [dmr_box.magazine_type] instead of the M392 magazine type", __FILE__, __LINE__)
	if(dmr_box.num_of_magazines != 24)
		Fail("HALO DMR ammo box expected 24 magazines, got [dmr_box.num_of_magazines]", __FILE__, __LINE__)
	qdel(dmr_box)

	var/obj/structure/largecrate/supply/ammo/halo/rifle/rifle_case = new
	if(rifle_case.supplies[/obj/item/ammo_box/magazine/unsc/br55])
		Fail("HALO rifle ammo case still carries BR55 magazines instead of keeping them with designated-rifle resupply", __FILE__, __LINE__)
	qdel(rifle_case)

	var/obj/structure/largecrate/supply/ammo/halo/marksman/marksman_case = new
	if(marksman_case.supplies[/obj/item/ammo_box/magazine/unsc/br55] != 2)
		Fail("HALO designated-rifle ammo case is missing BR55 reserve boxes", __FILE__, __LINE__)
	if(marksman_case.supplies[/obj/item/ammo_box/magazine/unsc/dmr] != 2)
		Fail("HALO designated-rifle ammo case is missing DMR reserve boxes", __FILE__, __LINE__)
	qdel(marksman_case)

/datum/unit_test/halo_preset_coverage/proc/validate_equipment_faction(preset_path, expected_faction)
	var/datum/equipment_preset/preset = new preset_path
	if(preset.faction != expected_faction)
		Fail("[preset_path] expected faction [expected_faction], got [preset.faction]", __FILE__, __LINE__)
	qdel(preset)

#endif
