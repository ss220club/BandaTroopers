
/obj/item/prop/helmetgarb/helmet_nvg/upp
	name = "\improper NZP-44 'Cyclop' night vision goggles"
	desc = "UPPAC standard NZP-44 Night vision goggles for military operations. Requires a battery in order to work"
	icon_state = "nvg_upp"
	active_powered_icon_state = "nvg_upp_down_powered"
	active_icon_state = "nvg_upp_down"
	inactive_icon_state = "nvg_upp"

/obj/item/prop/helmetgarb/helmet_nvg/upp/frogmen
	name = "\improper NZP-50 'Huginn' night vision goggles"
	desc = "With an integrated self-recharging battery, enemies of the Union will not hide from your vision. Put them on your helmet and press the button and it's go-time."
	cell_max_charge = -1

/obj/item/storage/backpack/marine/ammo_rack/upp
	name = "\improper UCCR5 ammo rack"
	desc = "A UPP military standard issue Union Combat Carry-Frame MK5 with buckles designed to hold multiple ammo cans and grenade boxes. Helps you lug around extra ammunition or supplies."
	has_gamemode_skin = FALSE
	storage_slots = 3
	icon_state = "upp_frame_0"
	base_icon_state = "upp_frame"

/obj/item/storage/backpack/marine/ammo_rack/upp/recon
	name = "\improper UCCR5-R ammo rack"
	desc = "A UPP military standard issue Union Combat Carry-Frame MK5 with buckles designed to hold multiple ammo cans and grenade boxes. Helps you lug around extra ammunition or supplies. Additional straps and buckles have improved stability of the package, making it easier to carry even fully loaded."
	move_delay_mult = 0

/obj/item/storage/belt/grenade/upp
	name="\improper Type 39 pattern grenade rig"
	desc = "The Type 39 grenade rig is the standard-issue load-bearing equipment of the UPP military. It consists of a modular belt with various clips for secure fastening on the armor, and two big pouches for general grenade storage. Requisition department department recommends to avoid accidental falls and drops on full pouches."
	icon_state = "upp_grenadebelt"
	item_state = "upp_grenadebelt"
	has_gamemode_skin = FALSE

/obj/item/storage/belt/grenade/large/upp
	name="\improper Type 40 pattern grenade rig"
	desc = "The Type 40 grenade rig is the modified variant of Type 39 rig. Besides 2 main pouches for general grenade storage, front-sided belt clips were changed to hold additional grenades, increasing the overall carriage."
	icon_state = "upp_grenadebelt"
	item_state = "upp_grenadebelt"
	has_gamemode_skin = FALSE

/obj/item/clothing/suit/marine/faction/UPP/recon
	name = "\improper 6B85-02 pattern UPP armor"
	desc = "Experimental development of the aging UPP armor system Vadasz. Provides moderate ballistic/shrapnel protection with wraparound soft armor and ceramic composite chestplate. Lightweight, whilst still providing adequate protection class and coverage. Unfortunately, the logistical costs involved prohibited mass production due to some exotic materials involved in the ceramite plating. It sees limited deployment amongst light infantry and recon elements."
	icon_state = "upp_armor_io"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	flags_inventory = BLOCKSHARPOBJ

	time_to_unequip = 15
	time_to_equip = 15
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_DECORARMOR,ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO, ACCESSORY_SLOT_PLATE3, ACCESSORY_SLOT_ARMOR_C, ACCESSORY_SLOT_DECORKNEE)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORARMOR,ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_PLATE3, ACCESSORY_SLOT_ARMOR_C, ACCESSORY_SLOT_DECORKNEE)
	specialty = "\improper 6B85-02 pattern"

/obj/item/clothing/accessory/patch/upp/recon
	name = "UPP 'Rozbójnik' Group patch"
	desc = "A fire-resistant shoulder patch, worn by the men and women of the 'Rozbójnik' Group who specialise in reconnaissance operations."
	icon_state = "uppreconpatch"

/obj/item/clothing/accessory/storage/webbing/m3/m40/upp
	name = "\improper Type 82 Pattern Grenade Webbing"
	desc = "A set of UPP webbing with small pouches that can carry up to 10 grenades, hand or impact."
	icon_state = "upp_webbing_grenade"
	flags_atom = NO_SNOW_TYPE
	slot = ACCESSORY_SLOT_M3UTILITY

/obj/item/clothing/accessory/storage/webbing/m3/m40/upp/Initialize(mapload)
	. = ..()
	inv_overlay = image(icon = accessory_icons[WEAR_JACKET], icon_state = icon_state, dir = SOUTH)

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/spawn_gear()
	new /obj/item/clothing/head/uppcap/beret/para(src)
	new /obj/item/clothing/under/marine/veteran/UPP(src)
	new /obj/item/clothing/shoes/marine/upp(src)
	new /obj/item/clothing/accessory/patch/upp/recon(src)
	new /obj/item/device/radio/headset/almayer/marine/solardevils/upp/forecon(src)

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/rifleman
	job = JOB_SQUAD_MARINE

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/smartgunner
	job = JOB_SQUAD_SMARTGUN

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/corpsman
	job = JOB_SQUAD_MEDIC

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/squad_leader
	job = JOB_SQUAD_TEAM_LEADER

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/platoon_leader
	job = JOB_SQUAD_LEADER

/obj/structure/closet/secure_closet/marine_personal/forecon_upp/rto
	job = JOB_SQUAD_RTO


/obj/structure/machinery/camera/autoname/golden_arrow/korobka
	network = list(CAMERA_NET_GOLDEN_ARROW, CAMERA_NET_KOROBKA)

/obj/item/storage/backpack/marine/upp
	name = "\improper UCBP4 combat backpack"
	desc = "A UPP military standard-issue Union Combat BackPack MK4. Very robust and heavy."
	icon_state = "marinepack_upp"
	item_state = "marinepack_upp"
	max_storage_space = 24
	bag_open_time = 3 SECONDS

/obj/item/storage/backpack/marine/upp/medic
	name = "\improper UCBP4-M sanitar backpack"
	desc = "A UPP military standard-issue Union Combat BackPack MK4. Very robust and heavy. Carried by UPP medics for extra supply carriage. Has a better layout within, which eases access to the inner storage."
	icon_state = "marinepack_medic_upp"
	item_state = "marinepack_medic_upp"
	bag_open_time = 2 SECONDS

/obj/item/storage/pouch/flare/upp/full/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/device/flashlight/flare/upp(src)

/obj/item/storage/belt/medical/upp/only_scanner/fill_preset_inventory()
	new /obj/item/device/healthanalyzer/soul(src)

/obj/item/storage/belt/gun/bizon
	name = "\improper Type 49 SMG holster rig"
	desc = "Special issue variant of Type 41 ammo belt with refitted holster for Type 64 Submachinegun. Uncommonly issued to the UPPN and UPPA support and specialist personnel."
	icon_state = "upp_smg"
	item_state = "upp_smg"
	storage_slots = 4
	max_w_class = 5
	can_hold = list(
		/obj/item/weapon/gun/smg/bizon,
		/obj/item/ammo_magazine/smg/bizon,
	)
	holster_slots = list(
		"1" = list(
			"icon_x" = -8,
			"icon_y" = -5))

/obj/item/storage/belt/gun/bizon/full/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/smg/bizon/upp())
	for(var/i = 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/smg/bizon(src)
