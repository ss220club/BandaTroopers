// Isolated Human AI firearm profile proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_profile
	/// Weapon families described by this profile. More specific paths should win registry lookup.
	var/list/gun_types = list(/obj/item/weapon/gun)
	/// Minimum engagement range with weapon type.
	var/minimum_range = 2
	/// Optimal engagement range, try to stay at this distance.
	var/optimal_range = 6
	/// Maximum engagement range, stop firing at this distance.
	var/maximum_range = 16
	/// How many rounds to fire in one burst at most.
	var/burst_amount_max = 8
	/// If TRUE, every fired shot counts toward the burst cap even for semiauto or burstfire weapons.
	var/count_every_shot_toward_burst_limit = FALSE
	/// If TRUE, this gun is disposable and is not worth trying to reload.
	var/disposable = FALSE
	/// If FALSE, Human AI must not select this weapon even if it matches generic gun rules.
	var/available_to_ai = TRUE
	/// Selection weight used when choosing primary weapon.
	var/primary_weight = 1
	/// If TRUE, Human AI aims near human targets instead of directly at them.
	var/aim_adjacent_to_human_targets = FALSE
	/// Percent chance to fire directly at a human target despite adjacent aim policy.
	var/direct_human_target_chance = 0
	/// Percent chance to use safer adjacent turfs around a human target.
	var/safe_human_adjacent_target_chance = 0
	/// Percent chance to intentionally miss into less-safe adjacent turfs around a human target.
	var/miss_human_adjacent_target_chance = 0
	/// If TRUE, adjacent friendly fire-line caution is treated as blocked.
	var/block_cautious_fire_line = FALSE

/datum/human_ai_firearm_profile/proc/matches(obj/item/weapon/gun/firearm)
	return firearm && is_type_in_list(firearm, gun_types)

/datum/human_ai_firearm_profile/generic
	gun_types = list(/obj/item/weapon/gun)

/datum/human_ai_firearm_profile/sniper
	gun_types = list(/obj/item/weapon/gun/rifle/sniper)
	optimal_range = 7
	maximum_range = 30
	burst_amount_max = 1
	primary_weight = 8

/datum/human_ai_firearm_profile/xm51
	gun_types = list(/obj/item/weapon/gun/rifle/xm51)
	burst_amount_max = 1
	minimum_range = 1
	optimal_range = 1
	maximum_range = 3
	primary_weight = 4

/datum/human_ai_firearm_profile/rifle
	gun_types = list(/obj/item/weapon/gun/rifle)
	primary_weight = 5

/datum/human_ai_firearm_profile/smartgun
	gun_types = list(
		/obj/item/weapon/gun/smartgun,
		/obj/item/weapon/gun/pkp,
		/obj/item/weapon/gun/m60,
	)
	burst_amount_max = 18
	primary_weight = 10

/datum/human_ai_firearm_profile/m60
	gun_types = list(/obj/item/weapon/gun/m60)
	burst_amount_max = 14
	primary_weight = 8

/datum/human_ai_firearm_profile/smg
	gun_types = list(/obj/item/weapon/gun/smg)
	burst_amount_max = 10
	minimum_range = 1
	optimal_range = 5
	maximum_range = 10
	primary_weight = 4

/datum/human_ai_firearm_profile/shotgun_db
	gun_types = list(/obj/item/weapon/gun/shotgun/double)
	burst_amount_max = 2
	minimum_range = 1
	optimal_range = 1
	maximum_range = 3

/datum/human_ai_firearm_profile/shotgun
	gun_types = list(/obj/item/weapon/gun/shotgun)
	burst_amount_max = 2
	minimum_range = 1
	optimal_range = 1
	maximum_range = 3
	primary_weight = 4

/datum/human_ai_firearm_profile/lever_action
	gun_types = list(/obj/item/weapon/gun/lever_action)
	burst_amount_max = 1
	minimum_range = 1
	optimal_range = 4
	maximum_range = 10
	primary_weight = 4

/datum/human_ai_firearm_profile/boltaction
	gun_types = list(/obj/item/weapon/gun/boltaction)
	optimal_range = 7
	maximum_range = 30
	burst_amount_max = 1
	primary_weight = 4

/datum/human_ai_firearm_profile/flamer
	gun_types = list(/obj/item/weapon/gun/flamer)
	burst_amount_max = 1
	minimum_range = 3
	optimal_range = 4
	maximum_range = 5
	primary_weight = 7
	block_cautious_fire_line = TRUE

/datum/human_ai_firearm_profile/flamer/m240t
	gun_types = list(/obj/item/weapon/gun/flamer/M240T)
	primary_weight = 9

/datum/human_ai_firearm_profile/rpg
	gun_types = list(/obj/item/weapon/gun/launcher/rocket/anti_tank/disposable)
	minimum_range = 2
	optimal_range = 6
	disposable = TRUE
	primary_weight = 15
	block_cautious_fire_line = TRUE
	aim_adjacent_to_human_targets = TRUE
	direct_human_target_chance = 20
	safe_human_adjacent_target_chance = 70
	miss_human_adjacent_target_chance = 10

/datum/human_ai_firearm_profile/rpg/multi_use
	gun_types = list(/obj/item/weapon/gun/launcher/rocket)
	disposable = FALSE

/datum/human_ai_firearm_profile/pistol
	gun_types = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver,
	)
	maximum_range = 9

/datum/human_ai_firearm_profile/revolver
	gun_types = list(/obj/item/weapon/gun/revolver)
	burst_amount_max = 6
	minimum_range = 1
	optimal_range = 4
	maximum_range = 9
	primary_weight = 3

/datum/human_ai_firearm_profile/flare
	gun_types = list(/obj/item/weapon/gun/flare)
	burst_amount_max = 1
	minimum_range = 2
	optimal_range = 5
	maximum_range = 12
	primary_weight = 1

/datum/human_ai_firearm_profile/grenade_launcher
	gun_types = list(/obj/item/weapon/gun/launcher/grenade)
	burst_amount_max = 1
	minimum_range = 3
	optimal_range = 7
	maximum_range = 14
	primary_weight = 9
	block_cautious_fire_line = TRUE

/datum/human_ai_firearm_profile/xm99
	gun_types = list(/obj/item/weapon/gun/XM99)
	burst_amount_max = 1
	minimum_range = 3
	optimal_range = 7
	maximum_range = 16
	primary_weight = 10

/datum/human_ai_firearm_profile/souto
	gun_types = list(/obj/item/weapon/gun/souto)
	burst_amount_max = 1
	minimum_range = 2
	optimal_range = 5
	maximum_range = 10
	available_to_ai = FALSE
	primary_weight = 8

/datum/human_ai_firearm_profile/smg/ppsh
	gun_types = list(/obj/item/weapon/gun/smg/ppsh)
	primary_weight = 5

/datum/human_ai_firearm_profile/smg/uzi
	gun_types = list(/obj/item/weapon/gun/smg/uzi)
	primary_weight = 3

/datum/human_ai_firearm_profile/smg/nailgun
	gun_types = list(/obj/item/weapon/gun/smg/nailgun)
	burst_amount_max = 6
	minimum_range = 1
	optimal_range = 4
	maximum_range = 8
	primary_weight = 2

/datum/human_ai_firearm_profile/taser
	gun_types = list(/obj/item/weapon/gun/energy/taser)
	burst_amount_max = 1
	minimum_range = 1
	optimal_range = 4
	maximum_range = 8
	primary_weight = 2
