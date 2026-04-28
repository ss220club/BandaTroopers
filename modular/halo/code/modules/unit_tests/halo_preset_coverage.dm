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
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/needler,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle,
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

	for(var/preset_path as anything in equipment_presets)
		validate_equipment_preset(preset_path)

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
	validate_store_weapon(/datum/equipment_preset/covenant/unggoy/specops/lesser, /obj/item/weapon/gun/energy/plasma/plasma_rifle)
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

	var/list/human_ai_presets = list(
		/datum/human_ai_equipment_preset/covenant/sangheili/minor = FACTION_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/sangheili/honor_guard = FACTION_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/unggoy/heavy/plasma_rifle = FACTION_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/specops_unggoy/specops/plasma_pistol = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/suicide_bomber = FACTION_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/minor = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/major/plasma_rifle = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/marksman = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/unsc/squadleader = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/odst/spnkr = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/assault = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/cqc = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/spnkr = FACTION_UNSC,
		/datum/human_ai_equipment_preset/oni/security = FACTION_ONI,
		/datum/human_ai_equipment_preset/oni/field/agent/senior = FACTION_ONI,
		/datum/human_ai_equipment_preset/police/officer/geared/smg = FACTION_UEG_POLICE,
		/datum/human_ai_equipment_preset/police/officer/sergeant/geared = FACTION_UEG_POLICE,
		/datum/human_ai_equipment_preset/insurgent/specialist = FACTION_INSURGENT,
		/datum/human_ai_equipment_preset/insurgent/breacher = FACTION_INSURGENT,
		/datum/human_ai_equipment_preset/insurgent/sl = FACTION_INSURGENT,
	)
	for(var/ai_preset_path as anything in human_ai_presets)
		validate_human_ai_preset(ai_preset_path, human_ai_presets[ai_preset_path])

	var/list/squad_presets = list(
		/datum/human_ai_squad_preset/covenant/ruuhtian_sniper_cell,
		/datum/human_ai_squad_preset/covenant/covenant_specops_strike_cell,
		/datum/human_ai_squad_preset/covenant/kigyar_raider_lance,
		/datum/human_ai_squad_preset/unsc/sniper,
		/datum/human_ai_squad_preset/unsc/atteam,
		/datum/human_ai_squad_preset/unsc/support_section,
		/datum/human_ai_squad_preset/unsc/spartan/sniper_cell,
		/datum/human_ai_squad_preset/unsc/spartan/strike_team,
		/datum/human_ai_squad_preset/unsc/odst/sniper,
		/datum/human_ai_squad_preset/unsc/odst/atteam,
		/datum/human_ai_squad_preset/unsc/odst/strike_team,
		/datum/human_ai_squad_preset/oni/field_cell,
		/datum/human_ai_squad_preset/police/enforcer_response,
		/datum/human_ai_squad_preset/insurgent/command_cell,
	)
	for(var/squad_preset_path as anything in squad_presets)
		validate_squad_preset(squad_preset_path)

/datum/unit_test/halo_preset_coverage/proc/validate_equipment_preset(preset_path)
	if(!ispath(preset_path, /datum/equipment_preset))
		Fail("[preset_path] is not an equipment preset path", __FILE__, __LINE__)
		return
	var/datum/equipment_preset/preset = new preset_path
	if(!(preset.flags & EQUIPMENT_PRESET_EXTRA))
		Fail("[preset_path] is not exposed through extra presets", __FILE__, __LINE__)
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	if(!test_human.get_item_by_slot(WEAR_BODY))
		Fail("[preset_path] did not equip a uniform", __FILE__, __LINE__)
	if(!test_human.get_item_by_slot(WEAR_JACKET))
		Fail("[preset_path] did not equip armor/suit", __FILE__, __LINE__)
	if(!test_human.get_item_by_slot(WEAR_J_STORE) && !test_human.get_item_by_slot(WEAR_BACK))
		Fail("[preset_path] did not equip a primary or back weapon", __FILE__, __LINE__)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_leader_dmr(preset_path)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/weapon/gun/rifle/halo/dmr/leader_dmr = test_human.get_item_by_slot(WEAR_J_STORE)
	if(!istype(leader_dmr))
		Fail("[preset_path] did not equip an M392 DMR in suit storage", __FILE__, __LINE__)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_species_preset(preset_path, expected_species)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	if(!test_human.species || test_human.species.name != expected_species)
		Fail("[preset_path] expected species [expected_species], got [test_human.species?.name || "none"]", __FILE__, __LINE__)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_store_weapon(preset_path, expected_type)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/stored_item = test_human.get_item_by_slot(WEAR_J_STORE)
	if(!istype(stored_item, expected_type))
		Fail("[preset_path] expected [expected_type] in suit storage, got [stored_item?.type || "none"]", __FILE__, __LINE__)
	qdel(preset)

/datum/unit_test/halo_preset_coverage/proc/validate_spnkr_pack(preset_path)
	var/datum/equipment_preset/preset = new preset_path
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human)
	preset.load_preset(test_human, FALSE, FALSE, null, TRUE)
	var/obj/item/storage/large_holster/spnkr/spnkr_pack = test_human.get_item_by_slot(WEAR_BACK)
	if(!istype(spnkr_pack))
		Fail("[preset_path] did not equip a SPNKr transport pack on the back slot", __FILE__, __LINE__)
		qdel(preset)
		return
	var/ammo_count = 0
	for(var/obj/item/ammo_magazine/spnkr/ammo in spnkr_pack.contents)
		ammo_count++
	if(ammo_count != 2)
		Fail("[preset_path] expected 2 SPNKr rocket tubes in the pack, got [ammo_count]", __FILE__, __LINE__)
	if(!locate(/obj/item/weapon/gun/halo_launcher/spnkr/unloaded, spnkr_pack.contents))
		Fail("[preset_path] expected an unloaded M41 SPNKr inside the pack", __FILE__, __LINE__)
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

/datum/unit_test/halo_preset_coverage/proc/validate_human_ai_preset(ai_preset_path, expected_faction)
	if(!ispath(ai_preset_path, /datum/human_ai_equipment_preset))
		Fail("[ai_preset_path] is not a HumanAI preset path", __FILE__, __LINE__)
		return
	var/datum/human_ai_equipment_preset/ai_preset = new ai_preset_path
	if(ai_preset.faction != expected_faction)
		Fail("[ai_preset_path] expected faction [expected_faction], got [ai_preset.faction]", __FILE__, __LINE__)
	if(!ispath(ai_preset.path, /datum/equipment_preset))
		Fail("[ai_preset_path] points to missing equipment preset [ai_preset.path]", __FILE__, __LINE__)
	qdel(ai_preset)

/datum/unit_test/halo_preset_coverage/proc/validate_squad_preset(squad_preset_path)
	if(!ispath(squad_preset_path, /datum/human_ai_squad_preset))
		Fail("[squad_preset_path] is not a HumanAI squad preset path", __FILE__, __LINE__)
		return
	var/datum/human_ai_squad_preset/squad_preset = new squad_preset_path
	if(!length(squad_preset.ai_to_spawn))
		Fail("[squad_preset_path] has no equipment presets", __FILE__, __LINE__)
	for(var/equipment_preset_path as anything in squad_preset.ai_to_spawn)
		if(!ispath(equipment_preset_path, /datum/equipment_preset))
			Fail("[squad_preset_path] points to missing equipment preset [equipment_preset_path]", __FILE__, __LINE__)
	qdel(squad_preset)

#endif
