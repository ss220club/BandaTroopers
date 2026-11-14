/datum/origin/wy
	name = ORIGIN_WY
	desc = "You were born into a Weyland-Yutani corporate family."

/datum/origin/wy/security
	name = ORIGIN_WY_SEC
	desc = "You served as corporate security, protecting Weyland-Yutani personnel and facilities."

/datum/origin/wy/security/pmc
	name = ORIGIN_WY_PMC
	desc = "You served as a Weyland-Yutani Private Military Contractor."

/proc/get_loadout_face_icon(paint_type)
	if(paint_type in list("clown_camo", "clown_camo_alt", "full_camo_snow", "full_camo_desert", "full_camo_jungle", "full_camo_urban"))
		return 'modular/cm_pve/icons/loadout/human_face.dmi'
	return 'icons/mob/humans/onmob/human_face.dmi'

/obj/item/clothing/glasses/regular/hippie
	name = "Rounded Prescription Glasses"
	desc = "Rounded glasses, makes you look smart and potentially reputable."
	icon = 'modular/cm_pve/icons/loadout/glasses.dmi'
	icon_state = "hippie_glasses"
	item_state = "hippie_glasses"
	item_icons = list(WEAR_EYES = 'modular/cm_pve/icons/loadout/glasses_onmob.dmi', WEAR_FACE = 'modular/cm_pve/icons/loadout/glasses_onmob.dmi')

/obj/item/clothing/glasses/kutjevo/alt
	name = "N95Z goggles"
	desc = "Protective goggles designed to shield the wearer's eyes from dust and debris."

/obj/item/clothing/mask/rebreather/scarf/tacticalmask/usa
	icon = 'modular/cm_pve/icons/loadout/masks.dmi'
	icon_state = "scarf_usa"
	item_state = "scarf_usa"
	original_state = "scarf_usa"
	item_icons = list(WEAR_FACE = 'modular/cm_pve/icons/loadout/mask_onmob.dmi')

/obj/item/clothing/mask/rebreather/scarf/keffiyeh
	name = "keffiyeh"
	desc = "A traditional headscarf worn for protection from the elements and to conceal the face."
	icon = 'modular/cm_pve/icons/loadout/masks.dmi'
	icon_state = "keffiyeh"
	item_state = "keffiyeh"
	original_state = "keffiyeh"
	item_icons = list(WEAR_FACE = 'modular/cm_pve/icons/loadout/mask_onmob.dmi')
	flags_inv_hide = HIDEFACE|HIDEALLHAIR|HIDEEARS

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/ui_action_click()
	pull_keffiyeh_down()

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/verb/pull_keffiyeh_down()
	set name = "Pull Up/Down"
	set category = "Object"
	set src in usr
	if(usr.stat == DEAD)
		return
	pulled = !pulled
	if(pulled)
		to_chat(usr, SPAN_NOTICE("You pull \the [src] down."))
		icon_state = "[original_state]_down"
		flags_inv_hide = HIDEFACE|HIDELOWHAIR
	else
		to_chat(usr, SPAN_NOTICE("You pull \the [src] up."))
		icon_state = original_state
		flags_inv_hide = HIDEFACE|HIDEALLHAIR|HIDEEARS
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_mask == src)
			H.update_hair()
	update_clothing_icon(src)

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/white
	icon_state = "keffiyeh_white"
	item_state = "keffiyeh_white"
	original_state = "keffiyeh_white"

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/red
	icon_state = "keffiyeh_red"
	item_state = "keffiyeh_red"
	original_state = "keffiyeh_red"

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/green
	icon_state = "keffiyeh_green"
	item_state = "keffiyeh_green"
	original_state = "keffiyeh_green"

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/black
	icon_state = "keffiyeh_black"
	item_state = "keffiyeh_black"
	original_state = "keffiyeh_black"

/obj/item/clothing/mask/rebreather/scarf/keffiyeh/blue
	icon_state = "keffiyeh_blue"
	item_state = "keffiyeh_blue"
	original_state = "keffiyeh_blue"

/obj/item/clothing/head/cmcap/boonie/fisherman
	name = "fisherman's boonie hat"
	desc = "A floppy boonie hat with fishing hooks and lines tucked around the band."
	icon = 'modular/cm_pve/icons/loadout/cm_hats.dmi'
	icon_state = "booniehat_fisher"
	item_state = "booniehat_fisher"
	item_icons = list(WEAR_HEAD = 'modular/cm_pve/icons/loadout/head_1.dmi')
	flags_atom = FPRINT|NO_SNOW_TYPE

/obj/item/clothing/shoes/marine/civilian/grey
	name = "grey rugged boots"
	icon = 'modular/cm_pve/icons/loadout/shoes.dmi'
	icon_state = "marine_grey"
	item_state = "marine_grey"
	item_icons = list(WEAR_FEET = 'modular/cm_pve/icons/loadout/feet.dmi')

/obj/item/clothing/shoes/marine/civilian/urban
	name = "urban rugged boots"
	icon = 'modular/cm_pve/icons/loadout/shoes.dmi'
	icon_state = "marine_grey_alt"
	item_state = "marine_grey_alt"
	item_icons = list(WEAR_FEET = 'modular/cm_pve/icons/loadout/feet.dmi')

/obj/item/clothing/shoes/marine/civilian/snow
	name = "snow rugged boots"
	icon = 'modular/cm_pve/icons/loadout/shoes.dmi'
	icon_state = "marine_snow"
	item_state = "marine_snow"
	item_icons = list(WEAR_FEET = 'modular/cm_pve/icons/loadout/feet.dmi')

/obj/item/clothing/gloves/alpha
	name = "red gloves"
	icon = 'modular/cm_pve/icons/loadout/gloves.dmi'
	icon_state = "red"
	item_state = "red"
	item_icons = list(WEAR_HANDS = 'modular/cm_pve/icons/loadout/hands.dmi')

/obj/item/clothing/gloves/delta
	name = "blue gloves"
	icon = 'modular/cm_pve/icons/loadout/gloves.dmi'
	icon_state = "blue"
	item_state = "blue"
	item_icons = list(WEAR_HANDS = 'modular/cm_pve/icons/loadout/hands.dmi')

/obj/item/clothing/gloves/bravo
	name = "yellow gloves"
	icon = 'modular/cm_pve/icons/loadout/gloves.dmi'
	icon_state = "yellow"
	item_state = "yellow"
	item_icons = list(WEAR_HANDS = 'modular/cm_pve/icons/loadout/hands.dmi')

/obj/item/clothing/gloves/charlie
	name = "purple gloves"
	icon = 'modular/cm_pve/icons/loadout/gloves.dmi'
	icon_state = "purple"
	item_state = "purple"
	item_icons = list(WEAR_HANDS = 'modular/cm_pve/icons/loadout/hands.dmi')

/obj/item/clothing/suit/storage/webbing/black
	icon = 'modular/cm_pve/icons/loadout/suits.dmi'
	icon_state = "webbing_black"
	item_state = "webbing_black"
	item_icons = list(WEAR_JACKET = 'modular/cm_pve/icons/loadout/suit_0.dmi')

/obj/item/clothing/accessory/patch/loadout
	icon = 'modular/cm_pve/icons/loadout/ties.dmi'
	accessory_icons = list(WEAR_BODY = 'modular/cm_pve/icons/loadout/ties_onmob.dmi', WEAR_JACKET = 'modular/cm_pve/icons/loadout/ties_onmob.dmi')

/obj/item/clothing/accessory/patch/loadout/Initialize()
	. = ..()
	inv_overlay = image("icon" = 'modular/cm_pve/icons/loadout/ties.dmi', "icon_state" = "[item_state ? item_state : icon_state]")

/obj/item/clothing/accessory/patch/loadout/medic_patch
	name = "Field Medic patch"
	icon_state = "medicpatch"

/obj/item/clothing/accessory/patch/loadout/cec_patch
	name = "CEC patch"
	icon_state = "cecpatch"
	item_state_slots = list(WEAR_AS_GARB = "cecpatch")

/obj/item/clothing/accessory/patch/loadout/conam_patch
	name = "Con-Amalagated Corporation patch"
	icon_state = "conampatch"

/obj/item/clothing/accessory/patch/loadout/hyperdyne_patch
	name = "Hyperdyne Corporation patch"
	icon_state = "hyperdynepatch"

/obj/item/facepaint/clown
	name = "clown makeup paint"
	icon = 'modular/cm_pve/icons/loadout/items.dmi'
	icon_state = "clown_camo"
	paint_type = "clown_camo"

/obj/item/facepaint/clown/alt
	icon_state = "clown_camo_alt"
	paint_type = "clown_camo_alt"

/obj/item/facepaint/sniper/snow
	name = "fullbody paint snow"
	icon = 'modular/cm_pve/icons/loadout/items.dmi'
	icon_state = "full_camo_snow"
	paint_type = "full_camo_snow"

/obj/item/facepaint/sniper/desert
	name = "fullbody paint desert"
	icon = 'modular/cm_pve/icons/loadout/items.dmi'
	icon_state = "full_camo_desert"
	paint_type = "full_camo_desert"

/obj/item/facepaint/sniper/jungle
	name = "fullbody paint jungle"
	icon = 'modular/cm_pve/icons/loadout/items.dmi'
	icon_state = "full_camo_jungle"
	paint_type = "full_camo_jungle"

/obj/item/facepaint/sniper/urban
	name = "fullbody paint urban"
	icon = 'modular/cm_pve/icons/loadout/items.dmi'
	icon_state = "full_camo_urban"
	paint_type = "full_camo_urban"

/obj/item/prop/magazine/book/bible
	name = "Bible"
	icon = 'modular/cm_pve/icons/loadout/books.dmi'
	icon_state = "bible"

/obj/item/prop/magazine/book/bible/quran
	name = "Quran"
	icon_state = "quran"

/obj/item/prop/magazine/book/bible/torah
	name = "Torah"
	icon_state = "torah"
