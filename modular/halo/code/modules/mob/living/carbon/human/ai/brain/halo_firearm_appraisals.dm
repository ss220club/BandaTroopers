/datum/firearm_appraisal/halo_plasma_pistol
	minimum_range = 1
	optimal_range = 4
	maximum_range = 9
	burst_amount_max = 2
	count_every_shot_toward_burst_limit = TRUE
	gun_types = list(
		/obj/item/weapon/gun/energy/plasma/plasma_pistol,
	)
	primary_weight = 2

/datum/firearm_appraisal/halo_plasma_rifle
	minimum_range = 2
	optimal_range = 5
	maximum_range = 11
	burst_amount_max = 3
	count_every_shot_toward_burst_limit = TRUE
	gun_types = list(
		/obj/item/weapon/gun/energy/plasma/plasma_rifle,
	)
	primary_weight = 5

/datum/firearm_appraisal/halo_needler
	minimum_range = 1
	optimal_range = 4
	maximum_range = 9
	burst_amount_max = 2
	count_every_shot_toward_burst_limit = TRUE
	gun_types = list(
		/obj/item/weapon/gun/smg/covenant_needler,
	)
	primary_weight = 4

/datum/firearm_appraisal/halo_carbine
	minimum_range = 2
	optimal_range = 6
	maximum_range = 12
	burst_amount_max = 3
	count_every_shot_toward_burst_limit = TRUE
	gun_types = list(
		/obj/item/weapon/gun/rifle/covenant_carbine,
	)
	primary_weight = 5

/datum/firearm_appraisal/halo_spnkr
	minimum_range = 3
	optimal_range = 7
	maximum_range = 14
	burst_amount_max = 1
	gun_types = list(
		/obj/item/weapon/gun/halo_launcher/spnkr,
	)
	primary_weight = 15

/datum/firearm_appraisal/halo_spnkr/before_fire(obj/item/weapon/gun/halo_launcher/spnkr/firearm, mob/living/carbon/user, datum/human_ai_brain/AI)
	. = ..()
	if(firearm.cover_open)
		firearm.toggle_cover(user)
		sleep(AI.micro_action_delay * AI.action_delay_mult)
	if(!firearm.in_chamber && firearm.current_mag?.current_rounds > 0)
		firearm.cock(user)

/datum/firearm_appraisal/halo_spnkr/do_reload(obj/item/weapon/gun/halo_launcher/spnkr/firearm, obj/item/ammo_magazine/spnkr/mag, mob/living/carbon/user, datum/human_ai_brain/AI)
	if(QDELETED(firearm) || QDELETED(mag) || QDELETED(user) || !AI || !AI.has_valid_tied_human())
		return
	AI.unholster_primary()
	AI.ensure_primary_hand(firearm)
	firearm.unwield(user)
	if(!firearm.cover_open)
		firearm.toggle_cover(user)
	sleep(AI.short_action_delay * AI.action_delay_mult)
	if(QDELETED(firearm) || QDELETED(mag) || QDELETED(user) || !AI.has_valid_tied_human())
		return
	if(firearm.current_mag)
		firearm.unload(user, FALSE, TRUE, FALSE)
	user.swap_hand()
	sleep(AI.micro_action_delay * AI.action_delay_mult)
	if(QDELETED(firearm) || QDELETED(mag) || QDELETED(user) || !AI.has_valid_tied_human())
		return
	AI.equip_item_from_equipment_map(HUMAN_AI_AMMUNITION, mag)
	sleep(AI.short_action_delay * AI.action_delay_mult)
	if(QDELETED(firearm) || QDELETED(mag) || QDELETED(user) || !AI.has_valid_tied_human())
		return
	firearm.attackby(mag, user)
	sleep(AI.short_action_delay * AI.action_delay_mult)
	if(QDELETED(firearm) || QDELETED(user) || !AI.has_valid_tied_human())
		return
	if(firearm.cover_open)
		firearm.toggle_cover(user)
	sleep(AI.micro_action_delay * AI.action_delay_mult)
	if(QDELETED(user) || !AI.has_valid_tied_human())
		return
	user.swap_hand()
	AI.wield_primary_sleep()
