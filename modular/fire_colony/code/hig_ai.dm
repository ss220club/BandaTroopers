// HIG presets equip their main gun before the AI brain may subscribe to equip signals.
// Ordinary appraisal sees the suit-storage gun only as a secondary weapon.
/datum/human_ai_brain/proc/ensure_hig_issued_primary()
	if(!istype(tied_human?.assigned_equipment_preset, /datum/equipment_preset/survivor/lasalle_merc))
		return
	var/obj/item/weapon/gun/issued_gun = tied_human.s_store
	if(!istype(issued_gun) || primary_weapon == issued_gun)
		return
	if(issued_gun in secondary_weapons)
		remove_secondary_weapon(issued_gun)
	set_primary_weapon(issued_gun)
