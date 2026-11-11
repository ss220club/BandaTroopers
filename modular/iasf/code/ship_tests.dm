#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/iasf_turing_roles/Run()
	var/datum/modular_ship_platoon_profile/iasf/profile = new()
	profile.initialize_profile()
	if(length(profile.role_mappings) != 9)
		return Fail("Turing Base does not have all IASF roles", __FILE__, __LINE__)
	if(!islist(GLOB.RoleAuthority?.roles_by_path))
		return Fail("Role authority is unavailable", __FILE__, __LINE__)
	var/datum/squad/marine/iasf/iasf_squad = GLOB.RoleAuthority.squads_by_type[/datum/squad/marine/iasf]
	if(!iasf_squad?.usable)
		return Fail("IASF platoon is unavailable", __FILE__, __LINE__)
	var/datum/map_config/ship_config = SSmapping?.configs?[SHIP_MAP]
	if(ship_config?.map_name == "Turing Base" && text2path(ship_config.platoon) != /datum/squad/marine/iasf)
		return Fail("Turing Base does not use the IASF platoon", __FILE__, __LINE__)
	if(ship_config?.map_name == "Turing Base")
		if(!locate(/obj/docking_port/stationary/marine_dropship/golden_arrow_hangar))
			return Fail("Turing Base has no Gibraltar hangar port", __FILE__, __LINE__)
		if(!SSshuttle.getShuttle(DROPSHIP_GIBRALTAR))
			return Fail("Turing Base has no Gibraltar shuttle", __FILE__, __LINE__)
	for(var/job_type in profile.role_mappings)
		var/datum/job/registered_job = GLOB.RoleAuthority.roles_by_path[job_type]
		if(!registered_job || registered_job.total_positions < 1 || registered_job.spawn_positions < 1)
			return Fail("[job_type] is absent from role authority", __FILE__, __LINE__)
		if(ship_config?.map_name == "Turing Base")
			var/list/iasf_spawns = GLOB.spawns_by_squad_and_job[SQUAD_IASF_TURING]
			if(!length(iasf_spawns) || !length(iasf_spawns[job_type]))
				return Fail("[job_type] has no registered Turing spawn", __FILE__, __LINE__)
		var/datum/job/job = new job_type()
		if(!ispath(job.gear_preset, /datum/equipment_preset/iasf))
			return Fail("[job_type] has no IASF preset", __FILE__, __LINE__)
		var/preset_type = job.gear_preset
		var/datum/equipment_preset/preset = new preset_type()
		var/expected_assignment = findtext(job.title, "Turing ") == 1 ? copytext(job.title, 8) : job.title
		if(preset.origin_override != ORIGIN_TWE || preset.assignment != expected_assignment)
			return Fail("[job_type] has incorrect origin or assignment", __FILE__, __LINE__)
		var/skill_type = preset.skills
		var/datum/skills/skillset = new skill_type()
		if(skillset.get_skill_level(SKILL_CONSTRUCTION) != SKILL_CONSTRUCTION_ENGI || skillset.get_skill_level(SKILL_ENGINEER) != SKILL_ENGINEER_TRAINED)
			return Fail("[job_type] has incorrect construction or engineering", __FILE__, __LINE__)
		var/expected_medical = job.title == JOB_IASF_MEDIC ? SKILL_MEDICAL_DOCTOR : job.title == JOB_IASF_SERGEANT ? SKILL_MEDICAL_MEDIC : SKILL_MEDICAL_DEFAULT
		var/expected_surgery = job.title == JOB_IASF_MEDIC || job.title == JOB_IASF_SERGEANT ? SKILL_SURGERY_NOVICE : SKILL_SURGERY_DEFAULT
		if(skillset.get_skill_level(SKILL_MEDICAL) != expected_medical || skillset.get_skill_level(SKILL_SURGERY) != expected_surgery)
			return Fail("[job_type] has incorrect medical or surgery skill", __FILE__, __LINE__)
		qdel(skillset)
		qdel(preset)
		qdel(job)
	qdel(profile)

/datum/unit_test/iasf_turing_equipment/Run()
	for(var/magazine_type as anything in list(/obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/flak))
		var/obj/item/ammo_magazine/rifle/rmc_f90/marksman/magazine = new magazine_type()
		if(magazine.max_rounds != 60 || magazine.current_rounds != 60)
			return Fail("[magazine_type] does not contain 60 rounds", __FILE__, __LINE__)
		if(!(magazine.icon_state in icon_states(magazine.icon)))
			return Fail("[magazine_type] has no sprite", __FILE__, __LINE__)
		qdel(magazine)
	for(var/armor_type as anything in list(/obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf, /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher))
		var/obj/item/clothing/armor = new armor_type()
		if(!(armor.icon_state in icon_states(armor.icon)))
			return Fail("[armor_type] has no object sprite", __FILE__, __LINE__)
		qdel(armor)
	var/obj/item/storage/box/guncase/heavy/sniper/iasf/kit = new()
	if(length(kit.contents) != 10)
		return Fail("Turing sniper kit has incorrect item count", __FILE__, __LINE__)
	var/incendiary = 0
	var/impact = 0
	var/flak = 0
	for(var/obj/item/item in kit.contents)
		if(istype(item, /obj/item/clothing/suit))
			return Fail("Sniper armor is still inside the rifle kit", __FILE__, __LINE__)
		if(istype(item, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary))
			incendiary++
		else if(istype(item, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact))
			impact++
		else if(istype(item, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/flak))
			flak++
	if(incendiary != 3 || impact != 3 || flak != 3)
		return Fail("Turing sniper kit has incorrect ammunition", __FILE__, __LINE__)
	qdel(kit)

/datum/unit_test/iasf_armor_accessories/Run()
	var/obj/item/clothing/accessory/health/ceramic_plate/twe/plate = new()
	var/obj/item/clothing/accessory/storage/webbing/m3/webbing = new()
	for(var/armor_type as anything in list(/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf, /obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper, /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher))
		var/obj/item/clothing/armor = new armor_type()
		if(!armor.can_attach_accessory(plate) || !armor.can_attach_accessory(webbing))
			return Fail("[armor_type] does not accept TWE plates and webbing", __FILE__, __LINE__)
		qdel(armor)
	qdel(plate)
	qdel(webbing)

/datum/unit_test/iasf_p90_magazine_boxes/Run()
	for(var/box_type as anything in list(/obj/item/ammo_box/magazine/p90/twe, /obj/item/ammo_box/magazine/p90/twe/heap))
		var/obj/item/ammo_box/magazine/p90/twe/box = new box_type()
		if(length(box.contents) != 12)
			return Fail("[box_type] does not contain twelve magazines", __FILE__, __LINE__)
		if(!(box.icon_state in icon_states(box.icon)) || !("base_type[box.overlay_ammo_type]" in icon_states(box.text_markings_icon)))
			return Fail("[box_type] has missing box sprite states", __FILE__, __LINE__)
		for(var/obj/item/ammo_magazine/smg/p90/twe/magazine in box.contents)
			if(!istype(magazine, box.magazine_type) || magazine.gun_type != /obj/item/weapon/gun/smg/p90/twe || magazine.current_rounds != 50)
				return Fail("[box_type] contains incompatible or empty magazines", __FILE__, __LINE__)
		qdel(box)

/datum/unit_test/iasf_turing_power_and_comms/Run()
	if(SSmapping?.configs?[SHIP_MAP]?.map_name != "Turing Base")
		return
	var/apcs = 0
	for(var/obj/structure/machinery/power/apc/controller in world)
		if(!istype(get_area(controller), /area/turing))
			continue
		apcs++
		if(!controller.cell || controller.cell.charge <= 0)
			return Fail("Turing has an unpowered APC in [get_area(controller)]", __FILE__, __LINE__)
	if(apcs < 10)
		return Fail("Turing has fewer than ten active APCs", __FILE__, __LINE__)
	var/has_storage = FALSE
	for(var/obj/structure/machinery/power/smes/magical/storage in world)
		if(istype(get_area(storage), /area/turing))
			has_storage = TRUE
			break
	if(!has_storage)
		return Fail("Turing has no sustainable power storage", __FILE__, __LINE__)
	var/has_relay = FALSE
	for(var/obj/structure/machinery/telecomms/relay/preset/tower/relay in world)
		if(istype(get_area(relay), /area/turing) && !relay.inoperable())
			has_relay = TRUE
			break
	if(!has_relay)
		return Fail("Turing has no working telecom relay", __FILE__, __LINE__)

#endif
