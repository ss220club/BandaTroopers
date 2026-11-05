/obj/item/storage/box/spec/breacher
	name = "Breacher equipment case"
	desc = "A case containing the M40 armor, N45 hammer, N30 shield, XM52 and breaching ammunition."
	icon = 'modular/breacher/assets/icons/obj/items/storage.dmi'
	icon_state = "kit_case"
	kit_overlay = "breacher"

/obj/item/storage/box/spec/breacher/fill_preset_inventory()
	new /obj/item/clothing/suit/storage/marine/m40(src)
	new /obj/item/clothing/head/helmet/marine/m40(src)
	new /obj/item/clothing/gloves/marine/m40(src)
	new /obj/item/weapon/twohanded/breacher_hammer(src)
	new /obj/item/weapon/shield/riot/montage(src)
	new /obj/item/weapon/gun/rifle/xm52(src)
	new /obj/item/weapon/gun/launcher/rocket/brute/breacher(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/storage/belt/gun/brutepack(src)
	new /obj/item/storage/belt/gun/xm52(src)
	new /obj/item/ammo_magazine/rifle/xm52(src)
	new /obj/item/ammo_magazine/rifle/xm52(src)
	new /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots(src)
	new /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots(src)

/obj/item/storage/box/spec/breacher/twe
	name = "TWE breacher equipment case"

/obj/item/storage/box/spec/breacher/twe/fill_preset_inventory()
	new /obj/item/clothing/suit/storage/marine/m40/twe(src)
	new /obj/item/clothing/head/helmet/marine/m40/twe(src)
	new /obj/item/clothing/gloves/marine/m40/twe(src)
	new /obj/item/weapon/twohanded/breacher_hammer(src)
	new /obj/item/weapon/shield/riot/montage/twe(src)
	new /obj/item/weapon/gun/rifle/xm52(src)
	new /obj/item/weapon/gun/launcher/rocket/brute/breacher(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/ammo_magazine/rocket/brute(src)
	new /obj/item/storage/belt/gun/brutepack(src)
	new /obj/item/storage/belt/gun/xm52(src)
	new /obj/item/ammo_magazine/rifle/xm52(src)
	new /obj/item/ammo_magazine/rifle/xm52(src)
	new /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots(src)
	new /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots(src)

/datum/specialist_set/breacher
	name = "Breacher Set"
	role_name = JOB_SQUAD_SPECIALIST_BREACHER
	skill_to_give = SKILL_SPEC_BREACHER
	trait_to_give = "breacher"
	kit_typepath = /obj/item/storage/box/spec/breacher

/datum/specialist_set/breacher/redeem_set(mob/living/redeemer, kit, silent)
	. = ..()
	if(!.)
		return .
	if(!skillcheck(redeemer, SKILL_ENDURANCE, SKILL_ENDURANCE_MAX))
		redeemer.skills?.set_skill(SKILL_ENDURANCE, SKILL_ENDURANCE_MAX)
	if(!skillcheck(redeemer, SKILL_MELEE_WEAPONS, SKILL_MELEE_SUPER))
		redeemer.skills?.set_skill(SKILL_MELEE_WEAPONS, SKILL_MELEE_SUPER)
	return TRUE
