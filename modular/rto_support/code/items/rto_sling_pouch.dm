/// Dedicated sling pouch paired with one RTO binocular set.
/obj/item/storage/pouch/sling/rto
	name = "RTO подсумок-слинг"
	desc = "Специальный подсумок-слинг для связанного комплекта RTO-бинокля."
	can_hold = list(/obj/item/device/binoculars/rto)
	var/obj/item/device/binoculars/rto/paired_binocular

/obj/item/storage/pouch/sling/rto/Initialize()
	. = ..()
	if(!ensure_paired_binocular())
		qdel(src)
		return INITIALIZE_HINT_QDEL
	return .

/obj/item/storage/pouch/sling/rto/Destroy()
	cleanup_paired_runtime()
	if(paired_binocular?.paired_pouch == src)
		paired_binocular.paired_pouch = null
	paired_binocular = null
	return ..()

/obj/item/storage/pouch/sling/rto/attack_self(mob/user)
	. = ..()
	if(user)
		to_chat(user, SPAN_NOTICE("[src] жёстко привязан к своему RTO-биноклю."))
	return .

/obj/item/storage/pouch/sling/rto/empty(mob/user)
	if(user)
		to_chat(user, SPAN_NOTICE("[src] не позволяет вручную извлечь связанный RTO-бинокль."))
	return

/obj/item/storage/pouch/sling/rto/can_be_inserted(obj/item/item, mob/user, stop_messages = FALSE)
	if(!istype(item, /obj/item/device/binoculars/rto))
		if(!stop_messages && user)
			to_chat(user, SPAN_WARNING("[src] принимает только связанный RTO-бинокль."))
		return FALSE

	var/obj/item/device/binoculars/rto/binoculars = item
	if(paired_binocular && paired_binocular != binoculars)
		if(!stop_messages && user)
			to_chat(user, SPAN_WARNING("[src] уже привязан к другому комплекту бинокля."))
		return FALSE
	if(binoculars.paired_pouch && binoculars.paired_pouch != src)
		if(!stop_messages && user)
			to_chat(user, SPAN_WARNING("[binoculars] уже привязан к другому подсумку-слингу."))
		return FALSE

	return ..()

/obj/item/storage/pouch/sling/rto/_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user)
	var/obj/item/device/binoculars/rto/binoculars = item
	if(istype(binoculars))
		pair_with_binocular(binoculars)
	..()

/obj/item/storage/pouch/sling/rto/unsling()
	return FALSE

/obj/item/storage/pouch/sling/rto/dropped(mob/user)
	. = ..()
	if(!paired_binocular || paired_binocular.loc == src || !user)
		return
	if(paired_binocular == user.l_hand || paired_binocular == user.r_hand)
		if(handle_item_insertion(paired_binocular, TRUE, user))
			to_chat(user, SPAN_NOTICE("[paired_binocular] возвращается в [src]."))

/obj/item/storage/pouch/sling/rto/proc/pair_with_binocular(obj/item/device/binoculars/rto/binoculars)
	if(!istype(binoculars))
		return FALSE
	if(paired_binocular && paired_binocular != binoculars)
		return FALSE
	paired_binocular = binoculars
	if(binoculars.paired_pouch != src)
		binoculars.pair_with_pouch(src)
	return TRUE

/obj/item/storage/pouch/sling/rto/proc/ensure_paired_binocular()
	if(QDELETED(src))
		return FALSE
	if(paired_binocular && paired_binocular.loc == src)
		if(!slung)
			_item_insertion(paired_binocular, TRUE)
		return TRUE

	var/obj/item/device/binoculars/rto/binoculars = locate(/obj/item/device/binoculars/rto) in contents
	if(!binoculars)
		binoculars = new /obj/item/device/binoculars/rto(src)
	if(!pair_with_binocular(binoculars))
		return FALSE
	if(slung != binoculars)
		_item_insertion(binoculars, TRUE)
	return TRUE

/obj/item/storage/pouch/sling/rto/proc/cleanup_paired_runtime()
	if(slung)
		if(!QDELETED(slung))
			slung.RemoveElement(/datum/element/drop_retrieval/pouch_sling, src)
		slung = null
	if(paired_binocular?.paired_pouch == src)
		paired_binocular.paired_pouch = null
	return TRUE
