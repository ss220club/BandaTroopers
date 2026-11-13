// The large injector pouch uses the existing W-Y art and carries a field supply.
/obj/item/storage/pouch/autoinjector/full/wy/large
	name = "W-Y large auto-injector pouch"
	storage_slots = 13

/obj/item/storage/pouch/autoinjector/full/wy/large/fill_preset_inventory()
	..()
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/kelotane(src)
	new /obj/item/reagent_container/hypospray/autoinjector/meralyne(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dermaline(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinp(src)
	new /obj/item/reagent_container/hypospray/autoinjector/emergency(src)

// The standard field revival case is medium-sized; this subtype explicitly fits backpacks.
/obj/item/storage/firstaid/whiteout/medical/commando/backpack
	name = "Commando backpack field revival kit"
	w_class = SIZE_MEDIUM

/obj/structure/closet/onyx_dogcatcher
	name = "Azure-16 Dog Catcher equipment locker"
	desc = "An equipment locker with a Dog Catcher combat kit."

/obj/structure/closet/onyx_dogcatcher/Initialize()
	. = ..()
	new /obj/item/clothing/suit/marine/veteran/pmc/apesuit(src)
	new /obj/item/clothing/head/helmet/marine/veteran/pmc/apesuit(src)
	new /obj/item/clothing/gloves/marine/veteran/pmc/apesuit(src)
	new /obj/item/storage/backpack/pmc/backpack/commando/apesuit(src)
