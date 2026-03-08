//===========================//CUSTOM ARMOR COSMETIC PLATES\\================================\\

/obj/item/clothing/accessory/pads/unsc
	name = "\improper M52B Shoulder Pads"
	desc = "A set shoulder pads attachable to the M52B armor set worn by the UNSC."
	icon = 'icons/halo/obj/items/clothing/accessories/accessories.dmi'
	icon_state = "pads"
	item_state = "pads"
	slot = ACCESSORY_SLOT_DECORARMOR
	flags_atom = NO_SNOW_TYPE
	accessory_icons = list(WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/accessories/accessories.dmi', WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/accessories/accessories.dmi')

/obj/item/clothing/accessory/pads/unsc/bracers
	name = "\improper M52B Arm Bracers"
	desc = "A set arm bracers worn in conjunction to the M52B body armor of the UNSC."
	icon_state = "bracers"
	item_state = "bracers"
	slot = ACCESSORY_SLOT_DECORBRACER
	flags_atom = NO_SNOW_TYPE

/obj/item/clothing/accessory/pads/unsc/bracers/police
	name = "\improper Police Shoulder Bracers"
	desc = "A set arm bracers worn in conjunction to an armoured vest, commonly issued to Police forces."
	icon_state = "bracers_police"
	item_state = "bracers_police"

/obj/item/clothing/accessory/pads/unsc/neckguard
	name = "\improper M52B Neck Guard"
	desc = "An attachable neck guard option for the M52B body armor worn by the UNSC."
	icon_state = "neckguard"
	item_state = "neckguard"
	slot = ACCESSORY_SLOT_DECORNECK
	flags_atom = NO_SNOW_TYPE

/obj/item/clothing/accessory/pads/unsc/neckguard/police
	name = "\improper Police Neck Guard"
	desc = "An attachable neck guard option for basic ballistic vests, commonly issued to the Police."
	icon_state = "neckguard_police"
	item_state = "neckguard_police"

/obj/item/clothing/accessory/pads/unsc/greaves
	name = "\improper M52B Shin Guards"
	desc = "A set shinguards designed to be worn in conjuction with M52B body armor."
	icon_state = "shinguards"
	item_state = "shinguards"
	slot = ACCESSORY_SLOT_DECORSHIN
	flags_atom = NO_SNOW_TYPE

/obj/item/clothing/accessory/pads/unsc/groin
	name = "\improper M52B Groin Plate"
	desc = "A plate designed to attach to M52B body armor to protect the babymakers of the Corps. Standardized protection of the UNSC often seen worn more often than not."
	icon_state = "groinplate"
	item_state = "groinplate"
	slot = ACCESSORY_SLOT_DECORGROIN
	flags_atom = NO_SNOW_TYPE

/obj/item/clothing/accessory/pads/unsc/groin/police
	name = "\improper Police Groin Plate"
	desc = "A plate designed to attach to an armoured Vest to protect the babymakers. Most commonly attached to Police Vests."
	icon_state = "groinplate_police"
	item_state = "groinplate_police"

/obj/item/clothing/accessory/pads/unsc/insurrection
	icon_state = "pads_insurgent"
	item_state = "pads_insurgent"

/obj/item/clothing/accessory/pads/unsc/bracers/insurrection
	icon_state = "bracers_insurgent"
	item_state = "bracers_insurgent"

/obj/item/clothing/accessory/pads/unsc/neckguard/insurrection
	icon_state = "neckguard_insurgent"
	item_state = "neckguard_insurgent"

/obj/item/clothing/accessory/pads/unsc/greaves/insurrection
	icon_state = "shinguards_insurgent"
	item_state = "shinguards_insurgent"

/obj/item/clothing/accessory/pads/unsc/groin/insurrection
	icon_state = "groinplate_insurgent"
	item_state = "groinplate_insurgent"

/obj/item/clothing/accessory/pads/unsc/odst
	name = "\improper M70DT Shoulder Pads"
	desc = "A set shoulder pads attachable to the M70DT armor set worn by the ODSTs."
	icon_state = "odst_pads"
	item_state = "odst_pads"

/obj/item/clothing/accessory/pads/unsc/bracers/odst
	name = "\improper M70DT Bracers"
	desc = "A set arm bracers worn in conjunction to the M70DT body armor of the ODSTs."
	icon_state = "odst_bracers"
	item_state = "odst_bracers"

/obj/item/clothing/accessory/pads/unsc/greaves/odst
	name = "\improper M70DT Greaves"
	desc = "A set greaves designed to be worn in conjuction with M70DT body armor."
	icon_state = "odst_shinguards"
	item_state = "odst_shinguards"

/obj/item/clothing/accessory/pads/unsc/groin/odst
	name = "\improper M70DT Groin Plate"
	desc = "A plate designed to attach to M70DT body armor to protect the babymakers of the Corps. Standardized protection of the ODSTs often seen worn more often than not."
	icon_state = "odst_groinplate"
	item_state = "odst_groinplate"


/obj/item/clothing/accessory/pads/unsc/oni
	icon_state = "pads_oni"
	item_state = "pads_oni"

/obj/item/clothing/accessory/pads/unsc/bracers/oni
	icon_state = "bracers_oni"
	item_state = "bracers_oni"

/obj/item/clothing/accessory/pads/unsc/neckguard/oni
	icon_state = "neckguard_oni"
	item_state = "neckguard_oni"

/obj/item/clothing/accessory/pads/unsc/greaves/oni
	icon_state = "shinguards_oni"
	item_state = "shinguards_oni"

/obj/item/clothing/accessory/pads/unsc/groin/insurrection
	icon_state = "groinplate_insurgent"
	item_state = "groinplate_insurgent"

//===========================//WEBBING & STORAGE\\================================\\




/obj/item/clothing/accessory/storage/webbing/m52b
	name = "\improper M52B Pattern Webbing"
	desc = "A sturdy mess of synthcotton belts and buckles designed to attach to the M52B body armor armor standard for the UNSC. This one is the slimmed down model designed for general purpose storage."
	icon = 'icons/halo/obj/items/clothing/accessories/accessories.dmi'
	icon_state = "m52b_webbing"
	hold = /obj/item/storage/internal/accessory/webbing/m52bgeneric
	slot = ACCESSORY_SLOT_M3UTILITY
	flags_atom = NO_SNOW_TYPE
	accessory_icons = list(WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/accessories/accessories.dmi', WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/accessories/accessories.dmi')

/obj/item/storage/internal/accessory/webbing/m52bgeneric
	cant_hold = list(
		/obj/item/ammo_magazine/handful/shotgun,
		/obj/item/ammo_magazine/rifle,
	)

/obj/item/clothing/accessory/storage/webbing/m52b/mag
	name = "\improper M52B Pattern Magazine Webbing"
	desc = "A variant of the M52B pattern webbing that features pouches for pulse rifle magazines."
	icon_state = "m52b_magwebbing"
	hold = /obj/item/storage/internal/accessory/webbing/m52bmag

/obj/item/storage/internal/accessory/webbing/m52bmag
	storage_slots = 5
	can_hold = list(
		/obj/item/attachable/bayonet,
		/obj/item/weapon/knife,
		/obj/item/device/flashlight/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/m60,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_container/food/snacks,
		/obj/item/ammo_magazine/plasma,
	)
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/plasma,
	)

//Partial Pre-load For Props

/obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5c
	hold = /obj/item/storage/internal/accessory/webbing/m52bmag/ma5c

/obj/item/storage/internal/accessory/webbing/m52bmag/ma5c/fill_preset_inventory()
	new /obj/item/ammo_magazine/rifle/halo/ma5c(src)
	new /obj/item/ammo_magazine/rifle/halo/ma5c(src)
	new /obj/item/ammo_magazine/rifle/halo/ma5c(src)
	new /obj/item/ammo_magazine/rifle/halo/ma5c(src)
	new /obj/item/ammo_magazine/rifle/halo/ma5c(src)

//===

/obj/item/clothing/accessory/storage/webbing/m52b/shotgun
	name = "\improper M52B Pattern Shell Webbing"
	desc = "A slightly modified variant of the M52B pattern webbing, fitted for 12 gauge shotgun shells."
	icon_state = "m52b_shotgunwebbing"
	hold = /obj/item/storage/internal/accessory/black_vest/m52bshotgun

/obj/item/storage/internal/accessory/black_vest/m52bshotgun
	can_hold = list(
		/obj/item/ammo_magazine/handful,
	)

/obj/item/clothing/accessory/storage/webbing/m52b/small
	name = "\improper M52B Pattern Small Pouch Webbing"
	desc = "A set of M52B pattern webbing fully outfitted with pouches and pockets to carry a while array of small items."
	icon_state = "m52b_smallwebbing"
	hold = /obj/item/storage/internal/accessory/black_vest/m52bgeneric
	slot = ACCESSORY_SLOT_M3UTILITY

/obj/item/storage/internal/accessory/black_vest/m52bgeneric
	cant_hold = list(
		/obj/item/ammo_magazine/handful/shotgun,
		/obj/item/ammo_magazine/plasma,
	)

/obj/item/clothing/accessory/storage/webbing/m52b/grenade
	name = "\improper M52B Pattern Grenade Webbing"
	desc = "A variation of the M52B pattern webbing fitted with loops for storing M40 grenades."
	icon_state = "m52b_grenadewebbing"
	hold = /obj/item/storage/internal/accessory/black_vest/m52bgrenade

/obj/item/storage/internal/accessory/black_vest/m52bgrenade
	storage_slots = 5
	can_hold = list(
		/obj/item/explosive/grenade/high_explosive,
		/obj/item/explosive/grenade/high_explosive/super,
		/obj/item/explosive/grenade/high_explosive/airburst/canister,
		/obj/item/explosive/grenade/high_explosive/impact/heap,
		/obj/item/explosive/grenade/high_explosive/impact/tmfrag,
		/obj/item/explosive/grenade/high_explosive/impact/flare,
		/obj/item/explosive/grenade/high_explosive/training,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/explosive/grenade/smokebomb/green,
		/obj/item/explosive/grenade/smokebomb/red,
		/obj/item/explosive/grenade/metal_foam,
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/slug/baton,
		/obj/item/explosive/grenade/tear/marine,
	)

/obj/item/clothing/accessory/storage/webbing/m52b/grenade/m9_frag
	hold = /obj/item/storage/internal/accessory/black_vest/m52bgrenade/unsc

/obj/item/storage/internal/accessory/black_vest/m52bgrenade/unsc/fill_preset_inventory()
	new /obj/item/explosive/grenade/high_explosive/m15/unsc(src)
	new /obj/item/explosive/grenade/high_explosive/m15/unsc(src)
	new /obj/item/explosive/grenade/high_explosive/m15/unsc(src)
	new /obj/item/explosive/grenade/high_explosive/m15/unsc(src)
	new /obj/item/explosive/grenade/high_explosive/m15/unsc(src)
