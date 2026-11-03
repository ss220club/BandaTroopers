/datum/admins/proc/modular_append_human_ai_machinegunner_equipment_presets(list/equipment_presets)
	equipment_presets += list(
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle::name = /datum/equipment_preset/covenant/sangheili/minor/plasma_rifle,
		/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol::name = /datum/equipment_preset/covenant/unggoy/minor/plasma_pistol,
		/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle::name = /datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle::name = /datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle,
		/datum/equipment_preset/unsc/pfc/equipped::name = /datum/equipment_preset/unsc/pfc/equipped,
		/datum/equipment_preset/police/officer/geared/smg::name = /datum/equipment_preset/police/officer/geared/smg,
		/datum/equipment_preset/oni/security::name = /datum/equipment_preset/oni/security,
		/datum/equipment_preset/insurgent/rifleman::name = /datum/equipment_preset/insurgent/rifleman,
	)

/datum/admins/proc/modular_append_human_ai_sniper_equipment_presets(list/equipment_presets)
	equipment_presets += list(
		/datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper::name = /datum/equipment_preset/unsc/spec/equipped_sniper/ai_sniper,
		/datum/equipment_preset/unsc/spartan/sniper::name = /datum/equipment_preset/unsc/spartan/sniper,
		/datum/equipment_preset/insurgent/specialist/sniper::name = /datum/equipment_preset/insurgent/specialist/sniper,
		/datum/equipment_preset/covenant/sangheili/minor/carbine::name = /datum/equipment_preset/covenant/sangheili/minor/carbine,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine::name = /datum/equipment_preset/covenant/ruuhtian/marksman/carbine,
		/datum/equipment_preset/covenant/ruuhtian/sniper/carbine::name = /datum/equipment_preset/covenant/ruuhtian/sniper/carbine,
	)

/datum/human_ai_breach_placer/proc/modular_append_human_ai_breach_charges(list/charge_options)
	charge_options += list(
		/obj/item/explosive/plastic/breaching_charge/plasma/halo::name = /obj/item/explosive/plastic/breaching_charge/plasma/halo,
	)

/datum/human_defense_creator_menu/proc/modular_append_human_defense_creator_factions(list/valid_factions)
	valid_factions += list(
		FACTION_COVENANT,
		FACTION_UNSC,
		FACTION_INSURGENT,
		FACTION_ONI,
		FACTION_UNSCN,
		FACTION_UEG_POLICE,
		FACTION_UNGGOY,
		FACTION_SANGHEILI,
		FACTION_KIGYAR,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_UNGGOY,
		FACTION_SPECOPS_KIGYAR,
	)

/datum/world_edit_generator/outpost_radius/proc/modular_append_outpost_radius_valid_factions(list/valid_factions)
	valid_factions += list(
		FACTION_COVENANT,
	)

/datum/world_edit_generator/outpost_radius/proc/modular_append_outpost_radius_faction_option_labels(list/labels)
	labels[FACTION_COVENANT] = "Covenant"

/datum/world_edit_generator/outpost_radius/proc/modular_append_outpost_radius_allowed_barricade_types(list/allowed_barricade_types)
	allowed_barricade_types += /datum/human_ai_defense/barricade/covenant

/datum/world_edit_generator/outpost_radius/proc/modular_append_outpost_radius_allowed_mine_types(list/allowed_mine_types)
	allowed_mine_types += list(
		/datum/human_ai_defense/mine/covenant/plasma,
		/datum/human_ai_defense/mine/covenant/needle,
	)
