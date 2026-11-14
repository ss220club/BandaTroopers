// The large injector pouch uses the existing W-Y art and carries a field supply.
/obj/item/storage/pouch/autoinjector/full/wy/large
	name = "W-Y large auto-injector pouch"
	storage_slots = 13

/obj/item/storage/pouch/autoinjector/full/wy/large/fill_preset_inventory()
	..()
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/kelotane(src)
	new /obj/item/reagent_container/hypospray/autoinjector/meralyne(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dermaline(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinp(src)
	new /obj/item/reagent_container/hypospray/autoinjector/emergency(src)

// The standard field revival case is medium-sized; this subtype explicitly fits backpacks.
/obj/item/storage/firstaid/whiteout/medical/commando/backpack
	name = "Commando backpack field revival kit"
	w_class = SIZE_MEDIUM

/obj/structure/closet/secure_closet/onyx_commando_gunner
	name = "Azure-16 heavy weapons specialist locker"
	req_access = list(ACCESS_PMC_GUNNER)

/obj/structure/closet/secure_closet/onyx_commando_gunner/Initialize()
	. = ..()
	new /obj/item/weapon/gun/smartgun/l56a2/elite(src)
	new /obj/item/clothing/suit/marine/veteran/pmc/smartgun/commando(src)
	new /obj/item/clothing/head/helmet/marine/veteran/pmc/enclosed/commando/sg(src)
	new /obj/item/clothing/glasses/night/m56_goggles(src)
	new /obj/item/storage/belt/gun/smartgunner/commando/full(src)
	new /obj/item/storage/pouch/magazine/large/pmc_sg/commando(src)
	new /obj/item/smartgun_battery(src)
	new /obj/item/smartgun_battery(src)

/obj/structure/closet/secure_closet/onyx_dogcatcher
	name = "Azure-16 Dog Catcher equipment locker"
	desc = "An equipment locker with a Dog Catcher combat kit."
	req_access = list(ACCESS_WY_GENERAL)

/obj/structure/closet/secure_closet/onyx_dogcatcher/Initialize()
	. = ..()
	new /obj/item/clothing/suit/marine/veteran/pmc/apesuit(src)
	new /obj/item/clothing/head/helmet/marine/veteran/pmc/apesuit(src)
	new /obj/item/clothing/gloves/marine/veteran/pmc/apesuit(src)
	new /obj/item/storage/backpack/pmc/backpack/commando/apesuit(src)

// Onyx-only personal closets keep the large PMC platoon unchanged.
/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando
	squad_type = SQUAD_PMCPLT_SMALL

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/spawn_gear()
	new /obj/item/clothing/under/marine/veteran/pmc/leader/commando(src)
	new /obj/item/clothing/shoes/veteran/pmc/commando/knife(src)
	new /obj/item/device/radio/headset/distress/pmc/commando(src)

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/rifleman
	job = JOB_PMCPLAT_SMALL_STANDARD

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/gunner
	job = JOB_PMCPLAT_SMALL_SG

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/team_leader
	job = JOB_PMCPLAT_SMALL_FTL

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/operations_leader
	job = JOB_PMCPLAT_SMALL_LEADER

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/operations_leader/spawn_gear()
	new /obj/item/clothing/under/marine/veteran/pmc/leader/commando/leader(src)
	new /obj/item/clothing/shoes/veteran/pmc/commando/knife(src)
	new /obj/item/device/radio/headset/distress/pmc/commando(src)

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/medic
	job = JOB_PMCPLAT_SMALL_MEDIC

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/engineer
	job = JOB_PMCPLAT_SMALL_ENGINEER

/obj/structure/closet/secure_closet/marine_personal/pmc/onyx_commando/dogcatcher
	job = JOB_PMCPLAT_SMALL_DOGCATCHER

// Medical levels are specific to the Onyx squad and do not change other PMC medics.
/datum/skills/pmc/engineer/onyx_commando
	name = "Azure-16 Corporate Engineer"
	skills = list(
		SKILL_FIREARMS = SKILL_FIREARMS_EXPERT,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_FIREMAN = SKILL_FIREMAN_SKILLED,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_MASTER,
		SKILL_ENGINEER = SKILL_ENGINEER_MASTER,
		SKILL_MEDICAL = SKILL_MEDICAL_MEDIC,
		SKILL_ENDURANCE = SKILL_ENDURANCE_WEAK,
		SKILL_JTAC = SKILL_JTAC_TRAINED,
		SKILL_CQC = SKILL_CQC_TRAINED,
		SKILL_POWERLOADER = SKILL_POWERLOADER_MASTER,
	)

/datum/skills/pmc/medic/onyx_commando
	name = "Azure-16 Medical Unit"
	skills = list(
		SKILL_CQC = SKILL_CQC_TRAINED,
		SKILL_FIREARMS = SKILL_FIREARMS_EXPERT,
		SKILL_POLICE = SKILL_POLICE_SKILLED,
		SKILL_FIREMAN = SKILL_FIREMAN_SKILLED,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_ENGINEER = SKILL_ENGINEER_TRAINED,
		SKILL_MEDICAL = SKILL_MEDICAL_DOCTOR,
		SKILL_SURGERY = SKILL_SURGERY_TRAINED,
		SKILL_ENDURANCE = SKILL_ENDURANCE_WEAK,
	)
