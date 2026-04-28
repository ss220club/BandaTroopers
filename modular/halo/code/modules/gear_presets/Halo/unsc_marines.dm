/datum/equipment_preset/unsc
	name = "UNSC"
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	var/odst_visual_role = FALSE

/mob/living/carbon/human/proc/load_halo_preset_name()
	if(!istype(src))
		return

	src.gender = pick(75;MALE,25;FEMALE)
	var/datum/preferences/A = new
	A.randomize_appearance(src)
	var/random_name = capitalize(pick(src.gender == MALE ? GLOB.first_names_male : GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	var/static/list/colors = list("BLACK" = list(15, 15, 10), "BROWN" = list(48, 38, 18), "BROWN" = list(48, 38, 18),"BLUE" = list(29, 51, 65), "GREEN" = list(40, 61, 39), "STEEL" = list(46, 59, 54))
	var/static/list/hair_colors = list("BLACK" = list(15, 15, 10), "BROWN" = list(48, 38, 18), "AUBURN" = list(77, 48, 36), "BLONDE" = list(95, 76, 44))
	var/hair_color = pick(hair_colors)
	src.r_hair = hair_colors[hair_color][1]
	src.g_hair = hair_colors[hair_color][2]
	src.b_hair = hair_colors[hair_color][3]
	src.r_facial = hair_colors[hair_color][1]
	src.g_facial = hair_colors[hair_color][2]
	src.b_facial = hair_colors[hair_color][3]
	var/eye_color = pick(colors)
	src.r_eyes = colors[eye_color][1]
	src.g_eyes = colors[eye_color][2]
	src.b_eyes = colors[eye_color][3]
	if(src.gender == MALE)
		src.h_style = pick("Undercut", "Partly Shaved", "Side Undercut", "Side Hang Undercut (Reverse)", "Undercut, Top", "Medium Fade", "High Fade", "Coffee House Cut")
		src.f_style = pick("Shaved", "Shaved", "Shaved", "Shaved", "Shaved", "Shaved", "3 O'clock Shadow", "3 O'clock Moustache", "5 O'clock Shadow", "5 O'clock Moustache", "7 O'clock Shadow", "7 O'clock Moustache",)
	else
		src.h_style = pick("Side Undercut", "Side Hang Undercut (Reverse)", "Undercut, Top", "CIA", "Mulder", "Pvt. Redding", "Pixie Cut Left", "Pixie Cut Right", "Bun")
	src.change_real_name(src, random_name)
	src.age = rand(20,35)

/proc/load_halo_preset_name(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return

	new_human.load_halo_preset_name()

/datum/equipment_preset/unsc/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_VERYLOW

/datum/equipment_preset/unsc/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/mob/living/carbon/human
	var/tmp/halo_runtime_spawn_context = null

/mob/living/carbon/human/proc/mark_halo_runtime_spawn_context(context)
	halo_runtime_spawn_context = context

/mob/living/carbon/human/proc/clear_halo_runtime_spawn_context()
	halo_runtime_spawn_context = null

/mob/living/carbon/human/proc/halo_maybe_equip_accessory(accessory_type, chance = 100)
	if(isnull(accessory_type) || !prob(chance))
		return

	src.equip_to_slot_or_del(new accessory_type(src), WEAR_ACCESSORY)

/mob/living/carbon/human/proc/halo_equip_unsc_service_patch(role_profile = "line", odst = FALSE)
	if(!istype(src))
		return

	var/list/patch_pool = list(
		/obj/item/clothing/accessory/patch/usasf,
		/obj/item/clothing/accessory/patch/army/infantry,
		/obj/item/clothing/accessory/patch/ua,
		/obj/item/clothing/accessory/patch/usa,
	)

	switch(role_profile)
		if("medical")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army,
				/obj/item/clothing/accessory/patch/ua,
				/obj/item/clothing/accessory/patch/usa,
			)
		if("signal")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army/spook,
				/obj/item/clothing/accessory/patch/ua,
				/obj/item/clothing/accessory/patch/usa,
			)
		if("command")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army/infantry,
				/obj/item/clothing/accessory/patch/army/armor,
				/obj/item/clothing/accessory/patch/ua,
				/obj/item/clothing/accessory/patch/usa,
			)
		if("recon")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army/spook,
				/obj/item/clothing/accessory/patch/army/infantry,
				/obj/item/clothing/accessory/patch/ua,
			)
		if("heavy")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army/armor,
				/obj/item/clothing/accessory/patch/army,
				/obj/item/clothing/accessory/patch/ua,
				/obj/item/clothing/accessory/patch/usa,
			)
		if("pilot")
			patch_pool = list(
				/obj/item/clothing/accessory/patch/usasf,
				/obj/item/clothing/accessory/patch/army/armor,
				/obj/item/clothing/accessory/patch/ua,
				/obj/item/clothing/accessory/patch/usa,
			)

	if(odst)
		patch_pool += list(/obj/item/clothing/accessory/patch/usasf/helljumper)

	var/patch_type = pick(patch_pool)
	src.equip_to_slot_or_del(new patch_type(src), WEAR_ACCESSORY)

/mob/living/carbon/human/proc/halo_equip_unsc_armor_trim(role_profile = "line", odst = FALSE)
	if(!istype(src))
		return

	var/shoulders_type = odst ? /obj/item/clothing/accessory/pads/unsc/odst : /obj/item/clothing/accessory/pads/unsc
	var/greaves_type = odst ? /obj/item/clothing/accessory/pads/unsc/greaves/odst : /obj/item/clothing/accessory/pads/unsc/greaves
	var/bracers_type = odst ? /obj/item/clothing/accessory/pads/unsc/bracers/odst : /obj/item/clothing/accessory/pads/unsc/bracers
	var/groin_type = odst ? /obj/item/clothing/accessory/pads/unsc/groin/odst : /obj/item/clothing/accessory/pads/unsc/groin
	var/neckguard_type = odst ? null : /obj/item/clothing/accessory/pads/unsc/neckguard

	switch(role_profile)
		if("medical")
			src.halo_maybe_equip_accessory(shoulders_type, 60)
			src.halo_maybe_equip_accessory(greaves_type, 60)
			src.halo_maybe_equip_accessory(bracers_type, 20)
		if("signal")
			src.halo_maybe_equip_accessory(shoulders_type)
			src.halo_maybe_equip_accessory(greaves_type)
			src.halo_maybe_equip_accessory(bracers_type, 30)
			src.halo_maybe_equip_accessory(neckguard_type, 20)
		if("command")
			src.halo_maybe_equip_accessory(shoulders_type)
			src.halo_maybe_equip_accessory(greaves_type)
			src.halo_maybe_equip_accessory(bracers_type, 45)
			src.halo_maybe_equip_accessory(groin_type, 35)
			src.halo_maybe_equip_accessory(neckguard_type, 35)
		if("recon")
			src.halo_maybe_equip_accessory(shoulders_type, 45)
			src.halo_maybe_equip_accessory(greaves_type)
			src.halo_maybe_equip_accessory(bracers_type, 35)
			src.halo_maybe_equip_accessory(groin_type, 20)
		if("heavy")
			src.halo_maybe_equip_accessory(shoulders_type)
			src.halo_maybe_equip_accessory(greaves_type)
			src.halo_maybe_equip_accessory(bracers_type)
			src.halo_maybe_equip_accessory(groin_type)
			src.halo_maybe_equip_accessory(neckguard_type, 65)
		if("pilot")
			src.halo_maybe_equip_accessory(shoulders_type)
			src.halo_maybe_equip_accessory(greaves_type, 60)
			src.halo_maybe_equip_accessory(bracers_type, 20)
		else
			src.halo_maybe_equip_accessory(shoulders_type)
			src.halo_maybe_equip_accessory(greaves_type)
			src.halo_maybe_equip_accessory(bracers_type, 25)
			src.halo_maybe_equip_accessory(groin_type, 25)

/mob/living/carbon/human/proc/halo_equip_odst_visual_core(role_profile = "line")
	if(!istype(src))
		return

	src.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/odst(src), WEAR_L_EAR)
	src.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/odst(src), WEAR_HEAD)
	src.equip_to_slot_or_del(new /obj/item/clothing/under/marine/odst(src), WEAR_BODY)
	src.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/odst(src), WEAR_JACKET)
	src.halo_equip_unsc_service_patch(role_profile, TRUE)
	src.halo_equip_unsc_armor_trim(role_profile, TRUE)

///Equipped Presets need doing///

/// Marine Rifleman
/datum/equipment_preset/unsc/pfc
	name = "Стрелок отделения UNSC"
	parent_type = /datum/equipment_preset/uscm/pfc
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_SQUAD_MARINE_UNSC
	rank = JOB_SQUAD_MARINE_UNSC
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "RFN"
	skills = /datum/skills/pfc
	minimap_icon = "private"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/pfc/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/pfc/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME1 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/pfc/odst
	name = "Стрелок отделения ODST"
	assignment = JOB_SQUAD_MARINE_ODST
	rank = JOB_SQUAD_MARINE_ODST
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "ODST-RFN"
	skills = /datum/skills/pfc

/datum/equipment_preset/unsc/pfc/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/// Marine Corpsman
/datum/equipment_preset/unsc/medic
	name = "Корпусман UNSC"
	parent_type = /datum/equipment_preset/uscm/medic
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	assignment = JOB_SQUAD_MEDIC_UNSC
	rank = JOB_SQUAD_MEDIC_UNSC
	paygrades = list(PAY_SHORT_NE5 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "HC"
	skills = /datum/skills/combat_medic
	minimap_icon = "medic"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/medic/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/medic/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_NE4 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/medic/pfc
	name = "UNSC Hospital Corpsman (Private First Class Equivalent)"
	paygrades = list(PAY_SHORT_NE3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/medic/private
	name = "UNSC Hospital Corpsman (Private Equivalent)"
	paygrades = list(PAY_SHORT_NE2 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/medic/odst
	name = "Корпусман ODST"
	assignment = JOB_SQUAD_MEDIC_ODST
	rank = JOB_SQUAD_MEDIC_ODST
	role_comm_title = "ODST-HC"
	skills = /datum/skills/combat_medic/odst

/datum/equipment_preset/unsc/medic/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_NE4 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/medic/odst/pfc
	name = "ODST Hospital Corpsman (Private First Class Equivalent)"
	paygrades = list(PAY_SHORT_NE3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/medic/odst/private
	name = "ODST Hospital Corpsman (Private Equivalent)"
	paygrades = list(PAY_SHORT_NE2 = JOB_PLAYTIME_TIER_0)

/// Marine RTO
/datum/equipment_preset/unsc/rto
	name = "Радиооператор UNSC"
	parent_type = /datum/equipment_preset/uscm/rto
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	assignment = JOB_SQUAD_RTO_UNSC
	rank = JOB_SQUAD_RTO_UNSC
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "RTO"
	skills = /datum/skills/pfc
	minimap_icon = "rto"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/rto/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/rto/proc/finalize_rto_support_loadout(
	mob/living/carbon/human/new_human,
	pouch_type = /obj/item/storage/pouch/sling/rto,
	binocular_type = null,
)
	if(!istype(new_human))
		return FALSE

	new_human.equip_rto_support_binocular_kit(pouch_type, binocular_type)

	var/datum/rto_support_controller/controller = new_human.ensure_rto_support_controller()
	if(controller?.can_select_template())
		controller.select_template("logistics")

	new_human.try_relocate_rto_to_squad_spawn()
	return TRUE

/datum/equipment_preset/unsc/rto/load_gear(mob/living/carbon/human/new_human)
	. = ..()
	GLOB.character_traits[/datum/character_trait/skills/spotter].apply_trait(new_human)
	new_human.ensure_rto_support_controller()
	new_human.try_relocate_rto_to_squad_spawn()

/datum/equipment_preset/unsc/rto/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/rto/odst
	name = "Радиооператор ODST"
	assignment = JOB_SQUAD_RTO_ODST
	rank = JOB_SQUAD_RTO_ODST
	role_comm_title = "ODST-RTO"
	skills = /datum/skills/pfc

/datum/equipment_preset/unsc/rto/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/// Marine Spec
/datum/equipment_preset/unsc/spec
	name = "Специалист вооружения UNSC"
	parent_type = /datum/equipment_preset/uscm/specialist_equipped
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	assignment = JOB_SQUAD_SPECIALIST_UNSC
	rank = JOB_SQUAD_SPECIALIST_UNSC
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Spc"
	skills = /datum/skills/specialist
	minimap_icon = "spec"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/spec/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/spec/proc/get_roundstart_specialist_loadout_preset()
	return /datum/equipment_preset/unsc/spec/equipped_spnkr

/datum/equipment_preset/unsc/spec/odst/get_roundstart_specialist_loadout_preset()
	return /datum/equipment_preset/unsc/spec/odst/equipped_spnkr

/datum/equipment_preset/unsc/spec/proc/uses_non_roundstart_specialist_baseline(mob/living/carbon/human/new_human, late_join)
	if(late_join)
		return TRUE

	return new_human?.halo_runtime_spawn_context == "cryo"

/datum/equipment_preset/unsc/spec/proc/load_non_roundstart_specialist_gear(mob/living/carbon/human/new_human)
	return

/datum/equipment_preset/unsc/spec/odst/load_non_roundstart_specialist_gear(mob/living/carbon/human/new_human)
	return

/datum/equipment_preset/unsc/spec/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE, late_join)
	if(uses_non_roundstart_specialist_baseline(new_human, late_join))
		new_human?.mark_halo_runtime_spawn_context(late_join ? "latejoin" : "cryo")

	. = ..()

	if(new_human?.halo_runtime_spawn_context == "latejoin" || new_human?.halo_runtime_spawn_context == "cryo")
		new_human.clear_halo_runtime_spawn_context()

/datum/equipment_preset/unsc/spec/load_gear(mob/living/carbon/human/new_human, client/mob_client)
	load_non_roundstart_specialist_gear(new_human)
	return

/datum/equipment_preset/unsc/spec/load_status(mob/living/carbon/human/new_human, client/mob_client)
	new_human.nutrition = NUTRITION_VERYLOW

/datum/equipment_preset/unsc/spec/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/spec/odst
	name = "Специалист вооружения ODST"
	assignment = JOB_SQUAD_SPECIALIST_ODST
	rank = JOB_SQUAD_SPECIALIST_ODST
	role_comm_title = "ODST-Spc"
	skills = /datum/skills/specialist

/datum/equipment_preset/unsc/spec/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/// Group Leader
/datum/equipment_preset/unsc/tl
	name = "Командир огневой группы UNSC"
	parent_type = /datum/equipment_preset/uscm/tl
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_TL_PREP)
	assignment = JOB_SQUAD_TEAM_LEADER_UNSC
	rank = JOB_SQUAD_TEAM_LEADER_UNSC
	paygrades = list(PAY_SHORT_ME4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "GrpLdr"
	skills = /datum/skills/tl
	minimap_icon = "tl"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/tl/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/tl/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/tl/odst
	name = "Командир огневой группы ODST"
	assignment = JOB_SQUAD_TEAM_LEADER_ODST
	rank = JOB_SQUAD_TEAM_LEADER_ODST
	role_comm_title = "ODST-GrpLdr"
	skills = /datum/skills/tl

/datum/equipment_preset/unsc/tl/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)

/// Marine Squad Leader
/datum/equipment_preset/unsc/leader
	name = "Сержант отделения UNSC"
	parent_type = /datum/equipment_preset/uscm/leader
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	assignment = JOB_SQUAD_LEADER_UNSC
	rank = JOB_SQUAD_LEADER_UNSC
	paygrades = list(PAY_SHORT_ME6 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SqLdr"
	minimum_age = 27
	skills = /datum/skills/SL
	minimap_icon = "leader"
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/leader/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/leader/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME5 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/leader/odst
	name = "Сержант отделения ODST"
	assignment = JOB_SQUAD_LEADER_ODST
	rank = JOB_SQUAD_LEADER_ODST
	role_comm_title = "ODST-SqLdr"
	minimum_age = 27
	skills = /datum/skills/SL

/datum/equipment_preset/unsc/leader/odst/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_ME5 = JOB_PLAYTIME_TIER_0)

// PlatCo
/datum/equipment_preset/unsc/platco
	name = "Командир взвода UNSC"
	parent_type = /datum/equipment_preset/uscm_ship/so
	faction = FACTION_UNSC
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	assignment = JOB_SO_UNSC
	rank = JOB_SO_UNSC
	paygrades = list(PAY_SHORT_MO2 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "PltCo"
	minimum_age = 25
	skills = /datum/skills/SO
	minimap_icon = list("cic" = COLOR_SILVER)
	minimap_background = MINIMAP_ICON_BACKGROUND_CIC
	var/odst_visual_role = FALSE

/datum/equipment_preset/unsc/platco/load_name(mob/living/carbon/human/new_human, randomise)
	load_halo_preset_name(new_human)

/datum/equipment_preset/unsc/platco/handle_late_join(mob/living/carbon/human/new_human, late_join)
	GLOB.squad_name_manager?.try_apply_platoon_commander_preference(new_human)
	if(late_join || !new_human.client?.prefs)
		return

	var/obj/docking_port/mobile/marine_dropship/midway/midway = SSshuttle.getShuttle(DROPSHIP_MIDWAY, FALSE)
	midway?.apply_runtime_camo(new_human.client.prefs.dropship_camo)
	midway?.apply_runtime_name(new_human.client.prefs.dropship_name)

/datum/equipment_preset/unsc/platco/lesser_rank
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_MO1 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc/platco/odst
	name = "Командир взвода ODST"
	parent_type = /datum/equipment_preset/unsc/platco
	assignment = JOB_SO_ODST
	rank = JOB_SO_ODST
	paygrades = list(PAY_SHORT_MO2 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "PltCo-ODST"
	skills = /datum/skills/SO

/datum/equipment_preset/unsc/platco/odst/lesser_rank
	parent_type = /datum/equipment_preset/unsc/platco/odst
	name = parent_type::name + " (пониженный ранг)"
	paygrades = list(PAY_SHORT_MO1 = JOB_PLAYTIME_TIER_0)

// Pilot
/datum/equipment_preset/unsc/pilot
	name = "Пилот UNSC"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/silver
	access = list(ACCESS_MARINE_COMMAND, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT)
	assignment = JOB_DROPSHIP_PILOT
	rank = JOB_DROPSHIP_PILOT
	paygrades = list(PAY_SHORT_MO1 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "PO"
	skills = /datum/skills/pilot
	minimap_icon = "pilot"

// ================== EQUIPPED ==================

//rifleman
/datum/equipment_preset/unsc/pfc/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/pfc/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/weldingtool(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/wirecutters(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("line", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("line", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/pfc/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//weapon spec (sniper)
/datum/equipment_preset/unsc/spec/equipped_sniper
	name = parent_type::name + " (снайпер, снаряжен)"

/datum/equipment_preset/unsc/spec/equipped_sniper/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/halo(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("recon", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("recon", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/equipped_sniper/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper
	name = parent_type::name + " (снайпер, снаряжен, AI)"

/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/halo(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	//accessories
	new_human.halo_equip_unsc_service_patch("recon", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("recon", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//weapon spec (spnkr)
/datum/equipment_preset/unsc/spec/equipped_spnkr
	name = parent_type::name + " (SPNKR, снаряжен)"

/datum/equipment_preset/unsc/spec/equipped_spnkr/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/spnkr/filled/launcher(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("heavy", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("heavy", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/equipped_spnkr/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man
	name = parent_type::name + " (SPNKR, снаряжен, AI)"

/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/spnkr/filled/launcher(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	//accessories
	new_human.halo_equip_unsc_service_patch("heavy", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("heavy", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/equipped_spnkr/ai_man/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//hospital corpsman
/datum/equipment_preset/unsc/medic/equipped
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/medic/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc/corpsman(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc/corpsman(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.halo_equip_unsc_service_patch("medical", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("medical", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/unsc/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/medic/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//rto
/datum/equipment_preset/unsc/rto/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/rto/equipped/load_gear(mob/living/carbon/human/new_human)
	GLOB.character_traits[/datum/character_trait/skills/spotter].apply_trait(new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("signal", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("signal", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)
	finalize_rto_support_loadout(new_human, /obj/item/storage/pouch/sling/rto/halo/unsc, /obj/item/device/binoculars/rto/halo/unsc)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/rto/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//group leader
/datum/equipment_preset/unsc/tl/equipped
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/tl/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("command", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("command", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/tl/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

//squad leader

/datum/equipment_preset/unsc/leader/equipped
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/leader/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("command", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("command", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/leader/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

/datum/equipment_preset/unsc/platco/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/platco/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("command", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("command", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6g(new_human), WEAR_IN_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/platco/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

/datum/equipment_preset/unsc/platco/odst/equipped
	parent_type = /datum/equipment_preset/unsc/platco/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = "ODST Platoon Commander (Equipped)"
	assignment = JOB_SO_ODST
	rank = JOB_SO_ODST
	role_comm_title = "PltCo-ODST"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/platco/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/odst(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	//accessories
	new_human.halo_equip_unsc_service_patch("command", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("command", src.odst_visual_role)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6g(new_human), WEAR_IN_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/pilot/equipped
	name = parent_type::name + " (снаряжен)"

/datum/equipment_preset/unsc/pilot/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/unsc(new_human), WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf(new_human), WEAR_FACE)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/pilot(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/standard(new_human), WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc(new_human), WEAR_JACKET)
	//accessories
	new_human.halo_equip_unsc_service_patch("pilot", src.odst_visual_role)
	new_human.halo_equip_unsc_armor_trim("pilot", src.odst_visual_role)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m7/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6g(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc/pilot/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

// ODST

//rifleman
/datum/equipment_preset/unsc/pfc/odst/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = parent_type::name + " (снаряжен)"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/pfc/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.halo_equip_odst_visual_core("line")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/br55(new_human), WEAR_J_STORE)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55/extended(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55/extended(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/pfc/odst/equipped/load_status(mob/living/carbon/human/new_human)
	new_human.nutrition = NUTRITION_HIGH

/datum/equipment_preset/unsc/medic/odst/equipped
	parent_type = /datum/equipment_preset/unsc/medic/equipped
	name = "ODST Hospital Corpsman (Equipped)"
	assignment = JOB_SQUAD_MEDIC_ODST
	rank = JOB_SQUAD_MEDIC_ODST
	role_comm_title = "ODST-HC"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/medic/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc/corpsman(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc/corpsman(new_human), WEAR_IN_BACK)
	new_human.halo_equip_odst_visual_core("medical")
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/unsc/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/rto/odst/equipped
	parent_type = /datum/equipment_preset/unsc/rto/equipped
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	name = "Радиооператор ODST (Снаряжен)"
	assignment = JOB_SQUAD_RTO_ODST
	rank = JOB_SQUAD_RTO_ODST
	role_comm_title = "ODST-RTO"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/rto/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.halo_equip_odst_visual_core("signal")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)
	finalize_rto_support_loadout(new_human, /obj/item/storage/pouch/sling/rto/halo/odst, /obj/item/device/binoculars/rto/halo/odst)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/tl/odst/equipped
	parent_type = /datum/equipment_preset/unsc/tl/equipped
	name = "ODST Group Leader (Equipped)"
	assignment = JOB_SQUAD_TEAM_LEADER_ODST
	rank = JOB_SQUAD_TEAM_LEADER_ODST
	role_comm_title = "ODST-GrpLdr"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/tl/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	new_human.halo_equip_odst_visual_core("command")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/leader/odst/equipped
	parent_type = /datum/equipment_preset/unsc/leader/equipped
	name = "ODST Squad Leader (Equipped)"
	assignment = JOB_SQUAD_LEADER_ODST
	rank = JOB_SQUAD_LEADER_ODST
	role_comm_title = "ODST-SqLdr"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/leader/odst/equipped/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/sergeant(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.halo_equip_odst_visual_core("command")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/odst/equipped_sniper
	parent_type = /datum/equipment_preset/unsc/spec/equipped_sniper
	name = "ODST Squad Weapons Specialist (Sniper)"
	assignment = JOB_SQUAD_SPECIALIST_ODST
	rank = JOB_SQUAD_SPECIALIST_ODST
	role_comm_title = "ODST-Spc"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/spec/odst/equipped_sniper/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/halo(new_human), WEAR_BACK)
	new_human.halo_equip_odst_visual_core("recon")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/odst/equipped_sniper/ai_sniper
	name = "ODST Squad Weapons Specialist (Sniper, AI)"

/datum/equipment_preset/unsc/spec/odst/equipped_spnkr
	parent_type = /datum/equipment_preset/unsc/spec/equipped_spnkr
	name = "ODST Squad Weapons Specialist (SPNKr)"
	assignment = JOB_SQUAD_SPECIALIST_ODST
	rank = JOB_SQUAD_SPECIALIST_ODST
	role_comm_title = "ODST-Spc"
	odst_visual_role = TRUE

/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Marine Undershirt"
	new_human.underwear = "Marine Boxers"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/spnkr/filled/launcher(new_human), WEAR_BACK)
	new_human.halo_equip_odst_visual_core("heavy")
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)

/datum/equipment_preset/unsc/spec/odst/equipped_spnkr/ai_man
	name = "ODST Squad Weapons Specialist (SPNKr, AI)"
