/// Маркер для маппинга шаблонов генерации построек через DMM.
/// Ставится на тайл в DMM, парсер забирает из него slot, category, wall_required, major.
/obj/effect/world_edit_slot_marker
	name = "world edit slot marker"
	desc = "Маркер слота для генератора построек World Edit."
	icon = 'icons/landmarks.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	layer = 100 // Чтобы легко выделялось поверх остального в маппере, но не мешало

	var/slot = "table"
	var/category = "table"
	var/wall_required = FALSE
	var/major = TRUE

/obj/effect/world_edit_slot_marker/Initialize(mapload, ...)
	. = ..()
	// Если мы заспавнились в игре (а не парсились мапером), мы нам не нужны. Удаляемся.
	return INITIALIZE_HINT_QDEL
