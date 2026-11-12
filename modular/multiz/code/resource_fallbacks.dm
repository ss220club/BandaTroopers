// The imported maps use two fedora labels whose original DMI states are absent in both source PRs.
// Reuse the existing fedora shape for object, worn and in-hand rendering.
/obj/item/clothing/head/fedora
	icon_state = "fedora"
	item_state = "fedora"
	color = "#BB9160"

/obj/item/clothing/head/fedora/brown
	icon_state = "fedora"
	item_state = "fedora"
	color = "#78583E"

// Cordon is a black border; the referenced pclosed state is absent from the source DMI.
/turf/closed/cordon
	icon = 'icons/turf/floors/space.dmi'
	icon_state = "black"
