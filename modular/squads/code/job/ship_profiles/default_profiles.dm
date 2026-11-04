/datum/modular_ship_platoon_profile/default/initialize_profile()
	if(platoon_type == /datum/squad/marine/clf)
		distress_roles = GLOB.ROLES_AI_CLF + GLOB.ROLES_GROUND
		lowpop_roles = GLOB.ROLES_AI_CLF
		preview_presets = list(
			JOB_SQUAD_MARINE = /datum/equipment_preset/uscm/clf/preview,
			JOB_SQUAD_ENGI = /datum/equipment_preset/uscm/clf/preview/engineer,
			JOB_SQUAD_MEDIC = /datum/equipment_preset/uscm/clf/preview/medic,
			JOB_SQUAD_LEADER = /datum/equipment_preset/uscm/clf/preview/leader,
		)
		role_mappings = list(
			/datum/job/marine/leader/ai/clf = JOB_SQUAD_LEADER,
			/datum/job/marine/engineer/ai/clf = JOB_SQUAD_ENGI,
			/datum/job/marine/medic/ai/clf = JOB_SQUAD_MEDIC,
			/datum/job/marine/standard/ai/clf = JOB_SQUAD_MARINE,
		)
	if(platoon_type == /datum/squad/marine/alpha)
		family_types = list(
			/datum/squad/marine/alpha,
			/datum/squad/marine/bravo,
			/datum/squad/marine/charlie,
			/datum/squad/marine/delta,
		)
		family_secondary_types = list(
			/datum/squad/marine/bravo,
			/datum/squad/marine/charlie,
			/datum/squad/marine/delta,
		)
		lowpop_personal_weapon_options = get_default_personal_weapon_options()
		lowpop_personal_weapon_spawn_types = list(
			"Shotgun" = /obj/item/weapon/gun/shotgun/pump/stock,
			"Compact shotgun" = /obj/item/storage/large_holster/m37/full/noammo,
			"Double-barrel shotgun" = /obj/item/weapon/gun/shotgun/double/sawn,
			"Grenade launcher" = /obj/item/weapon/gun/launcher/grenade/m81/m79/modified,
			"Compact grenade launcher" = /obj/item/weapon/gun/launcher/grenade/m81/m79/modified/sawnoff,
			"Grenade pack" = /obj/effect/essentials_set/m15_4_pack,
		)
		lowpop_personal_weapon_legacy_aliases = get_default_personal_weapon_legacy_aliases()
		lowpop_personal_weapon_default = "Shotgun"
		lowpop_personal_weapon_label = "Personal Weapon"
		lowpop_personal_weapon_prompt = "Choose your character's personal weapon:"
		lowpop_personal_weapon_title = "Character Preference (USCM Only)"
		lowpop_personal_weapon_notice_text = "You remember that your <b>%weapon%</b> is waiting in your personal locker."
		lowpop_personal_weapon_required_faction = FACTION_MARINE

/datum/authority/branch/role/proc/get_default_ship_platoon_profile_datum(platoon_type)
	platoon_type = normalize_ship_platoon_type(platoon_type)
	if(!platoon_type)
		return null

	return new /datum/modular_ship_platoon_profile/default(platoon_type)
