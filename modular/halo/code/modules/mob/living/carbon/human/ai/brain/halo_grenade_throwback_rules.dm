/datum/equipment_preset
	var/halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/get_human_ai_action_blacklist()
	. = ..()
	if(halo_ai_can_throw_back_grenades)
		return
	LAZYOR(., /datum/ai_action/throw_back_nade)

/datum/human_ai_brain/proc/halo_disable_grenade_throwback()
	add_action_blacklist(list(/datum/ai_action/throw_back_nade))
	set_grenade_throwback_enabled(FALSE)

/datum/human_ai_brain/proc/halo_enable_grenade_throwback()
	remove_action_blacklist(list(/datum/ai_action/throw_back_nade))
	set_grenade_throwback_enabled(TRUE)

/datum/equipment_preset/proc/modular_apply_human_ai_brain_capabilities(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	if(!brain)
		return
	if(halo_ai_can_throw_back_grenades)
		brain.halo_enable_grenade_throwback()
		return
	brain.halo_disable_grenade_throwback()

/datum/equipment_preset/covenant/unggoy
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/insurgent/partisan
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/rebel/guerilla
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/clf/guerilla
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/clf/synth
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/clf/synth/combat
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/canc/newblood
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/canc/newblood_machinegunner
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/canc/remnant/lowgear
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/canc_dogwar/militia
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/militia
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/colonist
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/researcher
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/doctor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/admin
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/cargo
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/engineer
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/operations
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/police
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/prisoner
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/mildoctor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/synth
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/upp/synth/commando
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/synth/working_joe/upp
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/synth/working_joe/upp/combat
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/wy
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/bluecollar
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/miner
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/construction
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/roughneck
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/cook
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/chef
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/priest
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/whitecollar
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/researcher
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/doctor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/admin
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/cargo
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/technician
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/engineer
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/operations
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/prisoner
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/security
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/colonist/security/guard
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/police/officer
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/police/officer/geared
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/police/officer/sergeant/geared
	halo_ai_can_throw_back_grenades = TRUE

/datum/equipment_preset/unsc_crew
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/survivor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/synth/survivor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/pmc/doctor
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/pmc/technician
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/pmc/director
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/pmc/synth
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/mercenary/grunt
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/mercenary/pilot
	halo_ai_can_throw_back_grenades = FALSE

/datum/equipment_preset/mercenary/coordinator
	halo_ai_can_throw_back_grenades = FALSE
