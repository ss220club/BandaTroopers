//Декалы крови арахнидов
/obj/effect/decal/cleanable/blood/arachnid
	name = "едкая кровь"
	desc = "Зеленая и густая гемолимфа. Выглядит как... <i>кровь?</i>"
	icon = 'icons/effects/blood.dmi'
	basecolor = BLOOD_COLOR_ARACHNID
	amount = 1

/obj/effect/decal/cleanable/blood/gibs/arachnid
	name = "едкие останки"
	gender = PLURAL
	desc = "Мерзотно..."
	icon = 'modular/arachnid/icons/effects/arachnid_blood.dmi'
	base_icon = 'modular/arachnid/icons/effects/arachnid_blood.dmi'
	icon_state = "agib1"
	random_icon_states = list(
		"agib1", "agib2", "agib3", "agib4", "agib5", "agib6", "agib7", "agib8", "agib9", "agib10",
		"agib11", "agib12", "agib13", "agib14", "agib15", "agib16"
		)
	basecolor = BLOOD_COLOR_ARACHNID

/obj/effect/decal/cleanable/blood/gibs/arachnid/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/arachnid/body
	random_icon_states = list(
		"agibhorn1", "agibhorn2", "agibhorn3",
		"agibhead1", "agibhead2", "agibhead3", "agibhead4",
		"agibbody1"
		)

/obj/effect/decal/cleanable/blood/gibs/arachnid/limb
	random_icon_states = list(
		"agibleg1", "agibleg2", "agibleg3", "agibleg4", "agibleg5",
		"agibleg6", "agibleg7", "agibleg8", "agibleg9", "agibleg10"
		)

/obj/effect/decal/cleanable/blood/gibs/arachnid/splat
	random_icon_states = list(
		"asplat1", "asplat2", "asplat3", "asplat4", "asplat5", "asplat6",
		"asplat7", "asplat8", "asplat9", "asplat10", "asplat11", "asplat12",
		"asplat13", "asplat14", "asplat15", "asplat16", "asplat17", "asplat18",
		"asplat19", "asplat20", "asplat21", "asplat22"
		)

/obj/effect/decal/cleanable/blood/gibs/arachnid/mess
	random_icon_states = list(
		"amess1", "amess2", "amess3", "amess4", "amess5", "amess6", "amess7", "amess8"
		)

/obj/effect/decal/cleanable/blood/atracks
	basecolor = BLOOD_COLOR_ARACHNID
