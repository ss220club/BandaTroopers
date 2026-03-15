/obj/item/shard/shrapnel/needler
	name = "осколок игольника"
	desc = "Длинный светящийся розово-фиолетовый шип. Выглядит особенно нестабильным."
	icon = 'icons/halo/obj/items/shards.dmi'
	icon_state = "needle"
	damage_on_move = 0

/obj/item/shard/shrapnel/needler/proc/remove_needles(mob/embedded_mob)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/target = embedded_mob
	for(var/obj/item/shard/shrapnel/needler/needle in target.embedded_items)
		qdel(needle)

/obj/item/shard/shrapnel/needler/Initialize()
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-12, 12)
	icon_state = "needle"
