// Semantic master-sync coverage for upstream Covenant gear PRs #129/#138.

/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle
	name = "Sangheili Minor (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_elite_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/minor/needler
	name = "Sangheili Minor (Needler)"

/datum/equipment_preset/covenant/sangheili/minor/needler/load_gear(mob/living/carbon/human/new_human)
	add_elite_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)

/datum/equipment_preset/covenant/sangheili/minor/carbine
	name = "Sangheili Minor (Carbine)"

/datum/equipment_preset/covenant/sangheili/minor/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)

/datum/equipment_preset/covenant/sangheili/major/plasma_rifle
	name = "Sangheili Major (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/major/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_elite_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/major/needler
	name = "Sangheili Major (Needler)"

/datum/equipment_preset/covenant/sangheili/major/needler/load_gear(mob/living/carbon/human/new_human)
	add_elite_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)

/datum/equipment_preset/covenant/sangheili/major/carbine
	name = "Sangheili Major (Carbine)"

/datum/equipment_preset/covenant/sangheili/major/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)

/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle
	name = "Sangheili Ultra (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_elite_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_rank_utility(new_human, "ultra")

/datum/equipment_preset/covenant/sangheili/ultra/carbine
	name = "Sangheili Ultra (Carbine)"

/datum/equipment_preset/covenant/sangheili/ultra/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "ultra")

/datum/equipment_preset/covenant/sangheili/zealot/plasma_rifle
	name = "Sangheili Zealot (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/zealot/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_elite_zealot(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_rank_utility(new_human, "zealot")

/datum/equipment_preset/covenant/sangheili/zealot/carbine
	name = "Sangheili Zealot (Carbine)"

/datum/equipment_preset/covenant/sangheili/zealot/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_zealot(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "zealot")

/datum/equipment_preset/covenant/sangheili/zealot/cloaking
	name = "Sangheili Zealot (Cloaking)"

/datum/equipment_preset/covenant/sangheili/zealot/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_elite_zealot(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_rank_utility(new_human, "zealot")
	elite_camouflage(new_human)

/datum/equipment_preset/covenant/sangheili/specops
	name = "Sangheili Special Operations"
	assignment = JOB_COV_SPECOPS
	rank = JOB_COV_SPECOPS
	paygrades = list(PAY_SHORT_SANG_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps"
	languages = list(LANGUAGE_SANGHEILI)
	faction = FACTION_SPECOPS_SANGHEILI

/datum/equipment_preset/covenant/sangheili/specops/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/specops/plasma_rifle
	name = "Sangheili Special Operations (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/specops/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	..()

/datum/equipment_preset/covenant/sangheili/specops/carbine
	name = "Sangheili Special Operations (Carbine)"

/datum/equipment_preset/covenant/sangheili/specops/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)

/datum/equipment_preset/covenant/sangheili/specops/cloaking
	name = "Sangheili Special Operations (Cloaking)"

/datum/equipment_preset/covenant/sangheili/specops/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	elite_camouflage(new_human)

/datum/equipment_preset/covenant/sangheili/specops_ultra
	name = "Sangheili Special Operations Ultra"
	assignment = JOB_COV_SPECOPS_ULTRA
	rank = JOB_COV_SPECOPS_ULTRA
	paygrades = list(PAY_SHORT_SANG_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps Ultra"
	languages = list(LANGUAGE_SANGHEILI)
	faction = FACTION_SPECOPS_SANGHEILI

/datum/equipment_preset/covenant/sangheili/specops_ultra/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/specops_ultra/plasma_rifle
	name = "Sangheili Special Operations Ultra (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/specops_ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	..()

/datum/equipment_preset/covenant/sangheili/specops_ultra/carbine
	name = "Sangheili Special Operations Ultra (Carbine)"

/datum/equipment_preset/covenant/sangheili/specops_ultra/carbine/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)

/datum/equipment_preset/covenant/sangheili/specops_ultra/cloaking
	name = "Sangheili Special Operations Ultra (Cloaking)"

/datum/equipment_preset/covenant/sangheili/specops_ultra/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_elite_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	elite_camouflage(new_human)

/datum/equipment_preset/covenant/sangheili/stealth
	name = "Sangheili Stealth"
	assignment = JOB_COV_STEALTH
	rank = JOB_COV_STEALTH
	paygrades = list(PAY_SHORT_SANG_STEALTH = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Stealth"
	languages = list(LANGUAGE_SANGHEILI)
	faction = FACTION_SPECOPS_SANGHEILI

/datum/equipment_preset/covenant/sangheili/stealth/load_gear(mob/living/carbon/human/new_human)
	add_elite_stealth(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/stealth/plasma_rifle
	name = "Sangheili Stealth (Plasma Rifle)"

/datum/equipment_preset/covenant/sangheili/stealth/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	..()

/datum/equipment_preset/covenant/sangheili/stealth/needler
	name = "Sangheili Stealth (Needler)"

/datum/equipment_preset/covenant/sangheili/stealth/needler/load_gear(mob/living/carbon/human/new_human)
	add_elite_stealth(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)

/datum/equipment_preset/covenant/sangheili/stealth/needler/cloaking
	name = "Sangheili Stealth (Needler, Cloaking)"

/datum/equipment_preset/covenant/sangheili/stealth/needler/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_elite_stealth(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)
	elite_camouflage(new_human)

/datum/equipment_preset/covenant/sangheili/stealth/plasma_rifle/cloaking
	name = "Sangheili Stealth (Plasma Rifle, Cloaking)"

/datum/equipment_preset/covenant/sangheili/stealth/plasma_rifle/cloaking/load_gear(mob/living/carbon/human/new_human)
	..()
	elite_camouflage(new_human)

/datum/equipment_preset/covenant/sangheili/honor_guard
	name = "Sangheili Honor Guard"
	assignment = JOB_COV_HONOR_GUARD
	rank = JOB_COV_HONOR_GUARD
	paygrades = list(PAY_SHORT_SANG_HONOR_GUARD = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Honor Guard"
	languages = list(LANGUAGE_SANGHEILI)

/datum/equipment_preset/covenant/sangheili/honor_guard/load_gear(mob/living/carbon/human/new_human)
	add_elite_honor_guard(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/covenant/energy_sword(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol
	name = "Unggoy Minor (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/minor/needler
	name = "Unggoy Minor (Needler)"

/datum/equipment_preset/covenant/unggoy/minor/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/minor/plasma_rifle
	name = "Unggoy Minor (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/minor/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/major/plasma_pistol
	name = "Unggoy Major (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/major/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/major/needler
	name = "Unggoy Major (Needler)"

/datum/equipment_preset/covenant/unggoy/major/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/major/plasma_rifle
	name = "Unggoy Major (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/major/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/heavy/plasma_pistol
	name = "Unggoy Heavy (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/heavy/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/heavy/needler
	name = "Unggoy Heavy (Needler)"

/datum/equipment_preset/covenant/unggoy/heavy/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle
	name = "Unggoy Heavy (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/ultra/plasma_pistol
	name = "Unggoy Ultra (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/ultra/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/ultra/needler
	name = "Unggoy Ultra (Needler)"

/datum/equipment_preset/covenant/unggoy/ultra/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle
	name = "Unggoy Ultra (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/specops/plasma_pistol
	name = "Unggoy Special Operations (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/specops/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/specops/needler
	name = "Unggoy Special Operations (Needler)"

/datum/equipment_preset/covenant/unggoy/specops/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle
	name = "Unggoy Special Operations (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/specops/cloaking
	name = "Unggoy Special Operations (Cloaking)"

/datum/equipment_preset/covenant/unggoy/specops/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	grunt_camouflage(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol
	name = "Unggoy Special Operations Ultra (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/specops_ultra/needler
	name = "Unggoy Special Operations Ultra (Needler)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle
	name = "Unggoy Special Operations Ultra (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking
	name = "Unggoy Special Operations Ultra (Cloaking)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	grunt_camouflage(new_human)

/datum/equipment_preset/covenant/unggoy/deacon/plasma_pistol
	name = "Unggoy Deacon (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/deacon/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	add_grunt_deacon(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/deacon/needler
	name = "Unggoy Deacon (Needler)"

/datum/equipment_preset/covenant/unggoy/deacon/needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_deacon(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	grunt_needler_crystals(new_human)

/datum/equipment_preset/covenant/unggoy/deacon/plasma_rifle
	name = "Unggoy Deacon (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/deacon/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	add_grunt_deacon(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/proc/add_elite_basics(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/covenant/sangheili(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/covenant(new_human), WEAR_L_EAR)

/datum/equipment_preset/proc/add_elite_minor(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/minor(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/minor(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/minor(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/minor(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/minor = 70, /obj/item/clothing/head/helmet/marine/sangheili/minor/manta_hat = 30))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/minor = 50, /obj/item/clothing/accessory/pads/sangheili/minor/variant_2 = 30, /obj/item/clothing/accessory/pads/sangheili/minor/variant_3 = 20))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_major(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/major(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/major(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/major(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/major(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/major = 70, /obj/item/clothing/head/helmet/marine/sangheili/major/manta_hat = 30))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/major = 50, /obj/item/clothing/accessory/pads/sangheili/major/variant_2 = 30, /obj/item/clothing/accessory/pads/sangheili/major/variant_3 = 20))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_ultra(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/ultra(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/ultra(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/ultra(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/ultra(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/ultra = 50, /obj/item/clothing/head/helmet/marine/sangheili/ultra/manta_hat = 50))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/ultra = 50, /obj/item/clothing/accessory/pads/sangheili/ultra/variant_2 = 25, /obj/item/clothing/accessory/pads/sangheili/ultra/variant_3 = 25))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_zealot(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/cloaking/zealot(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/zealot(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/zealot(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/zealot(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/zealot = 50, /obj/item/clothing/head/helmet/marine/sangheili/zealot/manta_hat = 50))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/zealot = 20, /obj/item/clothing/accessory/pads/sangheili/zealot/variant_2 = 20, /obj/item/clothing/accessory/pads/sangheili/zealot/variant_3 = 60))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_specops(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/cloaking/specops(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/specops(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/specops(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/specops(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/specops = 30, /obj/item/clothing/head/helmet/marine/sangheili/specops/assault = 70))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/specops = 25, /obj/item/clothing/accessory/pads/sangheili/specops/variant_2 = 25, /obj/item/clothing/accessory/pads/sangheili/specops/variant_3 = 50))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_specops_ultra(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/cloaking/specops/ultra(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/specops/ultra(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/specops/ultra(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/specops/ultra(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/specops/ultra = 20, /obj/item/clothing/head/helmet/marine/sangheili/specops/ultra/assault = 80))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/specops/ultra = 25, /obj/item/clothing/accessory/pads/sangheili/specops/ultra/variant_2 = 25, /obj/item/clothing/accessory/pads/sangheili/specops/ultra/variant_3 = 50))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_stealth(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/cloaking/stealth(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/stealth(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/stealth(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/stealth(new_human), WEAR_WAIST)
	var/pick_hat = pick_weight(list(/obj/item/clothing/head/helmet/marine/sangheili/stealth = 10, /obj/item/clothing/head/helmet/marine/sangheili/stealth/manta_hat = 10, /obj/item/clothing/head/helmet/marine/sangheili/stealth/assault = 80))
	var/pick_pads = pick_weight(list(/obj/item/clothing/accessory/pads/sangheili/stealth = 15, /obj/item/clothing/accessory/pads/sangheili/stealth/variant_2 = 80, /obj/item/clothing/accessory/pads/sangheili/stealth/variant_3 = 5))
	new_human.equip_to_slot_or_del(new pick_hat(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new pick_pads(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/add_elite_honor_guard(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	add_elite_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/shielded/sangheili/honor_guard(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/sangheili/honor_guard(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sangheili/honor_guard(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/covenant/sangheili/honor_guard(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/sangheili/honor_guard(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/sangheili/honor_guard(new_human), WEAR_ACCESSORY)

/datum/equipment_preset/proc/elite_camouflage(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	for(var/obj/item/clothing/suit/marine/shielded/sangheili/cloaking/camouflage in new_human.contents)
		camouflage.camouflage(new_human)

/datum/equipment_preset/proc/grunt_needler_crystals(mob/living/carbon/human/new_human, count = 5)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/needler_crystal(new_human), WEAR_IN_BELT)

/datum/equipment_preset/proc/add_grunt_basics(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/covenant/unggoy(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/covenant(new_human), WEAR_L_EAR)

/datum/equipment_preset/proc/add_grunt_rank_gear(mob/living/carbon/human/new_human, suit_type, belt_type, mask_rank, tank_rank, pads_rank)
	add_grunt_basics(new_human)
	new_human.equip_to_slot_or_del(new suit_type(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new belt_type(new_human), WEAR_WAIST)
	if(prob(35))
		var/helmet_path = text2path("/obj/item/clothing/head/helmet/marine/unggoy/[mask_rank]")
		if(helmet_path)
			new_human.equip_to_slot_or_del(new helmet_path(new_human), WEAR_HEAD)
	else
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/unggoy(new_human), WEAR_FACE)
	var/list/tanks = list("pointy", "curlback", "doubleprong", "canister")
	var/tank_pick = pick(tanks)
	var/tank_path = text2path("/obj/item/storage/backpack/covenant/unggoy/[tank_rank]/[tank_pick]")
	if(tank_path)
		new_human.equip_to_slot_or_del(new tank_path(new_human), WEAR_BACK)
	if(prob(25))
		var/gloves_path = text2path("/obj/item/clothing/gloves/marine/unggoy/[pads_rank]")
		if(gloves_path)
			new_human.equip_to_slot_or_del(new gloves_path(new_human), WEAR_HANDS)
	if(prob(25))
		var/shoes_path = text2path("/obj/item/clothing/shoes/unggoy/[pads_rank]")
		if(shoes_path)
			new_human.equip_to_slot_or_del(new shoes_path(new_human), WEAR_FEET)
	var/shoulder_path = text2path("/obj/item/clothing/accessory/pads/unggoy/[pads_rank]")
	var/bicep_path = text2path("/obj/item/clothing/accessory/pads/unggoy/bicep/[pads_rank]")
	if(shoulder_path)
		new_human.equip_to_slot_or_del(new shoulder_path(new_human), WEAR_ACCESSORY)
	if(bicep_path)
		new_human.equip_to_slot_or_del(new bicep_path(new_human), WEAR_ACCESSORY)
	ensure_grunt_full_kit(new_human, mask_rank, tank_rank, pads_rank)

/datum/equipment_preset/proc/ensure_grunt_full_kit(mob/living/carbon/human/new_human, mask_rank, tank_rank, pads_rank)
	if(!istype(new_human))
		return

	if(!new_human.head && !new_human.wear_mask)
		var/helmet_path = text2path("/obj/item/clothing/head/helmet/marine/unggoy/[mask_rank]")
		if(helmet_path)
			new_human.equip_to_slot_or_del(new helmet_path(new_human), WEAR_HEAD)
		else
			new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/unggoy(new_human), WEAR_FACE)

	if(!new_human.back)
		var/list/tank_candidates = list(
			text2path("/obj/item/storage/backpack/covenant/unggoy/[tank_rank]/pointy"),
			text2path("/obj/item/storage/backpack/covenant/unggoy/[tank_rank]/curlback"),
			text2path("/obj/item/storage/backpack/covenant/unggoy/[tank_rank]/doubleprong"),
			text2path("/obj/item/storage/backpack/covenant/unggoy/[tank_rank]/canister"),
		)
		for(var/tank_path in tank_candidates)
			if(!tank_path)
				continue
			new_human.equip_to_slot_or_del(new tank_path(new_human), WEAR_BACK)
			if(new_human.back)
				break

	if(!new_human.gloves)
		var/gloves_path = text2path("/obj/item/clothing/gloves/marine/unggoy/[pads_rank]")
		if(gloves_path)
			new_human.equip_to_slot_or_del(new gloves_path(new_human), WEAR_HANDS)

	if(!new_human.shoes)
		var/shoes_path = text2path("/obj/item/clothing/shoes/unggoy/[pads_rank]")
		if(shoes_path)
			new_human.equip_to_slot_or_del(new shoes_path(new_human), WEAR_FEET)

/datum/equipment_preset/proc/add_grunt_minor(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/minor, /obj/item/storage/belt/marine/covenant/unggoy/minor, "minor", "minor", "minor")

/datum/equipment_preset/proc/add_grunt_major(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/major, /obj/item/storage/belt/marine/covenant/unggoy/major, "major", "major", "major")

/datum/equipment_preset/proc/add_grunt_ultra(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/ultra, /obj/item/storage/belt/marine/covenant/unggoy/ultra, "ultra", "ultra", "ultra")

/datum/equipment_preset/proc/add_grunt_heavy(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/heavy, /obj/item/storage/belt/marine/covenant/unggoy/heavy, "heavy", "heavy", "heavy")

/datum/equipment_preset/proc/add_grunt_specops(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/cloaking/specops, /obj/item/storage/belt/marine/covenant/unggoy/specops, "specops", "specops", "specops")

/datum/equipment_preset/proc/add_grunt_specops_ultra(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/cloaking/specops_ultra, /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra, "specops_ultra", "specops_ultra", "specops_ultra")

/datum/equipment_preset/proc/add_grunt_deacon(mob/living/carbon/human/new_human)
	add_grunt_rank_gear(new_human, /obj/item/clothing/suit/marine/unggoy/deacon, /obj/item/storage/belt/marine/covenant/unggoy/ultra, "ultra", "ultra", "ultra")

/datum/equipment_preset/proc/grunt_camouflage(mob/living/carbon/human/new_human)
	if(!istype(new_human))
		return
	for(var/obj/item/clothing/suit/marine/unggoy/cloaking/camouflage in new_human.contents)
		camouflage.camouflage(new_human)
