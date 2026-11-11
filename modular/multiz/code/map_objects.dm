/obj/structure/machinery/light/red
	icon_state = "rtube1"
	base_state = "rtube"
	brightness = 4
	light_color = LIGHT_COLOR_RED

/obj/structure/sign/calendar
	name = "calendar"
	desc = "A wall calendar marked with appointments."
	icon = 'icons/obj/structures/props/wall_decorations/posters.dmi'
	icon_state = "poster1"

/obj/structure/sign/calendar/wy
	name = "Weyland-Yutani calendar"

/obj/item/clothing/shoes/dress
	parent_type = /obj/item/clothing/shoes/leather
	name = "dress shoes"

/datum/equipment_preset/corpse/colonist
	parent_type = /datum/equipment_preset/corpse/bluecollar
	name = "Corpse - Colonist"

/datum/equipment_preset/corpse/colonist/burst
	xenovictim = TRUE

/datum/equipment_preset/corpse/colonist/random
	name = "Corpse - Colonist Random"

/datum/equipment_preset/corpse/colonist/random/load_gear(mob/living/carbon/human/new_human)
	var/list/survivor_types = SSmapping.configs[GROUND_MAP].survivor_types
	if(!length(survivor_types))
		return ..()
	var/preset_type = pick(survivor_types)
	var/datum/equipment_preset/survivor/preset = new preset_type
	preset.load_gear(new_human)
	qdel(preset)

/datum/equipment_preset/corpse/colonist/random/burst
	xenovictim = TRUE

/datum/equipment_preset/corpse/engineer
	parent_type = /datum/equipment_preset/corpse/bluecollar
	name = "Corpse - Engineer"
	assignment = "Engineer"

/datum/equipment_preset/corpse/ua_riot
	parent_type = /datum/equipment_preset/corpse/riot
	name = "Corpse - UA Riot Officer"

/obj/effect/landmark/corpsespawner/colonist
	name = "Corpse - Colonist"
	equip_path = /datum/equipment_preset/corpse/colonist

/obj/effect/landmark/corpsespawner/colonist/burst
	name = "Corpse - Burst Colonist"
	equip_path = /datum/equipment_preset/corpse/colonist/burst

/obj/effect/landmark/corpsespawner/colonist/random
	name = "Corpse - Random Colonist"
	equip_path = /datum/equipment_preset/corpse/colonist/random

/obj/effect/landmark/corpsespawner/colonist/random/burst
	name = "Corpse - Burst Random Colonist"
	equip_path = /datum/equipment_preset/corpse/colonist/random/burst

/obj/effect/landmark/corpsespawner/engineer
	name = "Corpse - Engineer"
	equip_path = /datum/equipment_preset/corpse/engineer

/obj/effect/landmark/corpsespawner/ua_riot
	name = "Corpse - UA Riot Officer"
	equip_path = /datum/equipment_preset/corpse/ua_riot

/obj/item/map/tyrargo_rift
	name = "\improper Tyrargo Rift map"
	desc = "A labeled blueprint of the UA city Tyrargo Rift."
	html_link = "images/7/79/Tyrargo_Rift.png"

/obj/item/map/white_antre_map
	name = "\improper White Antre Research Facility map"
	desc = "An overview of the White Antre facility schematics."
	html_link = "images/d/da/White_Antre_Research_Facility.png"
	color = "cyan"
