/obj/structure/closet/secure_closet/marine_personal/unsc_crew
	name = "UNSC crew locker"
	desc = "An immobile card-locked storage unit for UNSC ship personnel."
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rm"
	icon_closed = "secure-rm"
	icon_locked = "secure1-rm"
	icon_opened = "secureopen-rm"
	icon_broken = "securebroken-rm"
	icon_off = "secureoff-rm"
	var/uniform_type
	var/shoes_type = /obj/item/clothing/shoes/marine
	var/headset_type = /obj/item/device/radio/headset/almayer/marine/solardevils/unsc
	var/back_type = /obj/item/storage/backpack/marine/satchel/unsc
	var/mre_type = /obj/item/storage/box/mre
	var/gloves_type
	var/waist_type
	var/jacket_type
	var/list/extra_item_types

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/proc/spawn_optional_item(item_type)
	if(item_type)
		new item_type(src)

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/spawn_gear()
	spawn_optional_item(uniform_type)
	spawn_optional_item(shoes_type)
	spawn_optional_item(headset_type)
	spawn_optional_item(back_type)
	spawn_optional_item(mre_type)
	spawn_optional_item(gloves_type)
	spawn_optional_item(waist_type)
	spawn_optional_item(jacket_type)

	if(extra_item_types)
		for(var/item_type as anything in extra_item_types)
			new item_type(src)

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/crewman
	name = "UNSC crewman's locker"
	job = JOB_UNSC_CREW
	uniform_type = /obj/item/clothing/under/marine/crew

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/engineering
	name = "UNSC engineering technician's locker"
	job = JOB_UNSC_CREW_ENGI
	icon_state = "secure1-eng"
	icon_closed = "secure-eng"
	icon_locked = "secure1-eng"
	icon_opened = "secureopen-eng"
	icon_broken = "securebroken-eng"
	icon_off = "secureoff-eng"
	uniform_type = /obj/item/clothing/under/marine/crew/engi
	gloves_type = /obj/item/clothing/gloves/yellow
	waist_type = /obj/item/storage/belt/utility/full

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/engineering/officer
	name = "UNSC engineering officer's locker"
	job = JOB_UNSC_CREW_ENGI_CHIEF
	uniform_type = /obj/item/clothing/under/marine/crew/engi/officer
	gloves_type = /obj/item/clothing/gloves/yellow
	waist_type = /obj/item/storage/belt/utility/full

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/flight
	name = "UNSC flight-deck technician's locker"
	job = JOB_UNSC_CREW_FLIGHT
	icon_state = "secure1-eng"
	icon_closed = "secure-eng"
	icon_locked = "secure1-eng"
	icon_opened = "secureopen-eng"
	icon_broken = "securebroken-eng"
	icon_off = "secureoff-eng"
	uniform_type = /obj/item/clothing/under/marine/crew/flight
	gloves_type = /obj/item/clothing/gloves/yellow
	waist_type = /obj/item/storage/belt/utility/full

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/flight/officer
	name = "UNSC flight-deck officer's locker"
	job = JOB_UNSC_CREW_FLIGHT_CHIEF
	uniform_type = /obj/item/clothing/under/marine/crew/flight/officer
	gloves_type = /obj/item/clothing/gloves/yellow
	waist_type = /obj/item/storage/belt/utility/full

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/operations
	name = "UNSC operations specialist's locker"
	job = JOB_UNSC_CREW_OPS
	icon_state = "secure1-rto"
	icon_closed = "secure-rto"
	icon_locked = "secure1-rto"
	icon_opened = "secureopen-rto"
	icon_broken = "securebroken-rto"
	icon_off = "secureoff-rto"
	uniform_type = /obj/item/clothing/under/marine/crew/operations

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/operations/officer
	name = "UNSC operations officer's locker"
	job = JOB_UNSC_CREW_OPS_CHIEF
	uniform_type = /obj/item/clothing/under/marine/crew/operations/officer

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/medical
	name = "UNSC medical specialist's locker"
	job = JOB_UNSC_CREW_MED
	icon_state = "secure1-med"
	icon_closed = "secure-med"
	icon_locked = "secure1-med"
	icon_opened = "secureopen-med"
	icon_broken = "securebroken-med"
	icon_off = "secureoff-med"
	uniform_type = /obj/item/clothing/under/marine/crew/med
	waist_type = /obj/item/storage/belt/medical/lifesaver/unsc/full
	extra_item_types = list(
		/obj/item/device/healthanalyzer/halo,
		/obj/item/tool/surgery/surgical_line,
		/obj/item/tool/surgery/synthgraft,
	)

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/medical/officer
	name = "UNSC chief medical officer's locker"
	job = JOB_UNSC_CREW_MED_CHIEF
	uniform_type = /obj/item/clothing/under/marine/crew/med/officer
	waist_type = /obj/item/storage/belt/medical/lifesaver/unsc/full
	jacket_type = /obj/item/clothing/suit/storage/labcoat
	extra_item_types = list(
		/obj/item/device/healthanalyzer/halo,
		/obj/item/tool/surgery/surgical_line,
		/obj/item/tool/surgery/synthgraft,
	)

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/command
	name = "UNSC bridge officer's locker"
	job = JOB_UNSC_CREW_COM
	icon_state = "secure1-ftl"
	icon_closed = "secure-ftl"
	icon_locked = "secure1-ftl"
	icon_opened = "secureopen-ftl"
	icon_broken = "securebroken-ftl"
	icon_off = "secureoff-ftl"
	uniform_type = /obj/item/clothing/under/marine/crew/command

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/command/xo
	name = "UNSC executive officer's locker"
	job = JOB_UNSC_CREW_COM_XO
	icon_state = "secure1-sl"
	icon_closed = "secure-sl"
	icon_locked = "secure1-sl"
	icon_opened = "secureopen-sl"
	icon_broken = "securebroken-sl"
	icon_off = "secureoff-sl"
	uniform_type = /obj/item/clothing/under/marine/crew/command

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/command/captain
	name = "UNSC captain's locker"
	job = JOB_UNSC_CREW_COM_CPT
	icon_state = "secure1-so"
	icon_closed = "secure-so"
	icon_locked = "secure1-so"
	icon_opened = "secureopen-so"
	icon_broken = "securebroken-so"
	icon_off = "secureoff-so"
	uniform_type = /obj/item/clothing/under/marine/crew/command

/obj/structure/closet/secure_closet/marine_personal/unsc_crew/science
	name = "UNSC science officer's locker"
	job = JOB_UNSC_CREW_RND
	icon_state = "secure1-spec"
	icon_closed = "secure-spec"
	icon_locked = "secure1-spec"
	icon_opened = "secureopen-spec"
	icon_broken = "securebroken-spec"
	icon_off = "secureoff-spec"
	uniform_type = /obj/item/clothing/under/marine/crew/rnd
	jacket_type = /obj/item/clothing/suit/storage/labcoat
