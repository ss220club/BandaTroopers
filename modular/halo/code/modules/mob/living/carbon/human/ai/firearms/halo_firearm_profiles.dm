// Isolated HALO firearm profiles for the Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_profile/covenant

/datum/human_ai_firearm_profile/covenant/plasma
	gun_types = list(/obj/item/weapon/gun/energy/plasma)
	primary_weight = 7
	burst_amount_max = 4
	count_every_shot_toward_burst_limit = TRUE

/datum/human_ai_firearm_profile/covenant/plasma/pistol
	gun_types = list(/obj/item/weapon/gun/energy/plasma/plasma_pistol)
	minimum_range = 1
	optimal_range = 4
	maximum_range = 9
	burst_amount_max = 2
	count_every_shot_toward_burst_limit = TRUE
	primary_weight = 6

/datum/human_ai_firearm_profile/covenant/plasma/rifle
	gun_types = list(/obj/item/weapon/gun/energy/plasma/plasma_rifle)
	minimum_range = 2
	optimal_range = 5
	maximum_range = 11
	burst_amount_max = 3
	count_every_shot_toward_burst_limit = TRUE
	primary_weight = 7

/datum/human_ai_firearm_profile/covenant/needler
	gun_types = list(/obj/item/weapon/gun/smg/covenant_needler)
	minimum_range = 1
	optimal_range = 4
	maximum_range = 9
	burst_amount_max = 2
	count_every_shot_toward_burst_limit = TRUE
	primary_weight = 7

/datum/human_ai_firearm_profile/halo_carbine
	gun_types = list(/obj/item/weapon/gun/rifle/covenant_carbine)
	minimum_range = 2
	optimal_range = 6
	maximum_range = 12
	burst_amount_max = 3
	count_every_shot_toward_burst_limit = TRUE
	primary_weight = 5

/datum/human_ai_firearm_profile/halo_spnkr
	gun_types = list(/obj/item/weapon/gun/halo_launcher/spnkr)
	minimum_range = 3
	optimal_range = 7
	maximum_range = 14
	burst_amount_max = 1
	primary_weight = 15
