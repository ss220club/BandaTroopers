// HALO upstream master flavor overrides from cmss13-devs/cmss13-pve-halo#118.

/obj/structure/machinery/computer/med_data/laptop
	desc = "Laptop computer tied into medical records database."

#define DEPARTMENT_UNSC "UNSCDF Local Command Link"

/obj/structure/machinery/faxmachine/unsc
	name = "UNSCDF Fax Machine"
	desc = "While considerably long in the tooth by the current century, fax machines remain hooked to human telecomms through increasingly arcane methods."
	network = "UNSCDF Auxiliary Compatibility Protocol"
	department = "UNSC Common Compatibility Tunnel"
	target_department = DEPARTMENT_UNSC

#undef DEPARTMENT_UNSC

/obj/structure/machinery/newscaster
	desc = "Public noticeboard and advertisement eyesore."

/obj/item/newspaper
	desc = "A newspaper with little interesting news. Maybe this unit's going to be the next story, but whether or not it's happy is in one's own hands."

/obj/structure/machinery/cm_vending/sorted/medical/blood
	name = "blood storage unit"
	desc = "Refrigerated bloodbag storage system with integrated bookkeeping for maintaining freshness."

/obj/item/reagent_container/food/drinks/cans/classcola
	desc = "The classic red and white. A United States liquid confection, still canned in the United Republic of North America, and a few colonies."

/obj/item/reagent_container/food/drinks/cans/pepsi
	desc = "Red white and blue. Still canned in the United Republic of North America, and a few colonies."

/obj/item/reagent_container/food/condiment/hotsauce/sriracha
	name = "sriracha sauce bottle"
	desc = "Sriracha sauce originates from Thailand, and has since become an enduring staple. It tastes of chiles and garlic, with vinegar and a subtle sweetness as a secondary."

/obj/item/reagent_container/food/condiment/hotsauce/tabasco
	name = "tabasco sauce bottle"
	desc = "Tabasco sauce originally hails from the United States despite its namesake being a Mexican city. It is seasoned heavily, with a good deal of vinegar cut with a little sweet and smoke."

/obj/item/reagent_container/food/snacks/sosjerky
	name = "beef jerky"
	desc = "Salty, dry, savory beef jerky. Not much to write home about."

/obj/item/reagent_container/food/snacks/no_raisin
	name = "raisins"
	desc = "Dried grapes. Sweet and just a little moist."

/obj/item/reagent_container/food/snacks/chips
	name = "potato chips"
	desc = "Fried potatoes, sliced thin and salted. A classic."

/obj/item/reagent_container/food/snacks/wy_chips/pepper
	name = "black pepper potato chips"
	desc = "Somehow fragrant and a touch spicy in addition to the salt and crunch."

/obj/item/reagent_container/food/snacks/kepler_crisps
	name = "potato crisps"
	desc = "Crunchy. Technically healthier than potato chips for your heart."

/obj/item/reagent_container/food/snacks/kepler_crisps/flamehot
	name = "spicy potato crisps"
	desc = "Crunchy and spicy. Truly, it is an age of wonders. Now if only they'd invent a spice coat that didn't rub off on the fingers..."

/obj/item/reagent_container/food/snacks/microwavable/donkpocket
	name = "microwave pocket sandwich"
	desc = "A simple sandwich with meat, cheese, and sauce filling. For best results, microwave inside the pocket."
	warm_desc = "A warmed sandwich with meat, cheese, and sauce filling. Though acceptable, not wonderful."

/obj/item/reagent_container/food/snacks/microwavable/packaged_burrito
	name = "microwave burrito"
	desc = "Burrito in a microwavable package. There's a cartoon mascot on the side of the cheap paper hull."
	warm_desc = "Warmed burrito in a microwavable package. A little soggy, but serviceable."

/obj/item/reagent_container/food/snacks/microwavable/packaged_burger
	name = "microwave cheeseburger"
	desc = "Buns, sad little cheese slice, thin patty. But it's reliable."
	warm_desc = "Warmed cheeseburger. Moist, maybe a little too moist, but savory and tasty."

/obj/item/reagent_container/food/snacks/microwavable/packaged_hdogs
	name = "microwave hotdog and bun"
	desc = "Bun, hotdog, and a plastic wrapper. Instructions say stick it in the microwave for three minutes, experience tells it's best to do two or less."
	warm_desc = "Warmed hotdog. Casing's split a little and the bun's kinda dry, but it's still good."

/obj/item/clothing/mask/cigarette/cigar
	name = "Sweet William cigar"
	desc = "A rolled tube of dried and fermented tobacco with a slick brown paper hull. Gives the air of a real UNSC sergeant."

/obj/item/toy/deck/uno
	desc = "A deck of the classic UNO playing cards, on stain-resistant plastic."

/obj/item/trash/chips
	name = "empty potato chip bag"
	desc = "Empty and greasy plastic bag lined with foil."

/obj/item/trash/wy_chips_pepper
	name = "empty black pepper chips bag"
	desc = "Sad little bag of crumbs and pepper. Even good things don't last forever."

/obj/item/trash/kepler
	name = "empty potato crisps tube"
	desc = "Empty cardboard tube. Only useful now for arts and crafts. Or reuse, that's another thing one could do."

/obj/item/trash/kepler/flamehot
	name = "empty spicy potato crisps tube"
	desc = "Empty cardboard tube. Rinse before reuse or one might discover a spicy surprise."

/obj/item/trash/buritto
	name = "microwave burrito wrapper"
	desc = "Plastic-and-paper package streaked by unidentifiable things. Used to hold a burrito."

/obj/item/trash/burger
	name = "microwave burger wrapper"
	desc = "Greasy plastic package, now burglarized of its burger."

/obj/item/trash/hotdog
	name = "microwave hotdog wrapper"
	desc = "Oily plastic package that once held a hotdog."

/obj/item/weapon/knife/marine
	name = "M1 Combat Knife"
	desc = "Standard UNSC cold weapon. 20cm high carbon steel blade with anti-flash carbide coating. Balanced for throwing and close quarters combat, though mostly intended as a multitool... Especially these days."

/obj/structure/machinery/shower
	desc = "A stainless alloy corrosion treated showerhead."

/obj/structure/prop/almayer/computers/mission_planning_system
	name = "aerospace mission planning computer"
	desc = "Tactical data analysis, suggestion, and visualizer for combat aircraft pilots."

/obj/structure/prop/almayer/computers/mapping_computer
	name = "aerospace zone imaging computer"
	desc = "Uses known data and battlenet information to synthesize terrain contour combined with local atmospherics."

/obj/structure/prop/almayer/whiteboard/clear
	desc = "A clear whiteboard, useful for backlit use and plotting. Otherwise operates identically to a regular whiteboard."

/obj/structure/prop/almayer/ship_memorial
	name = "memorial slab"
	desc = "Once almost ceremonial, now a solemn memorial for those who have died in action in service to the UNSCDF and all humankind."

/obj/item/clothing/mask/gas/military
	name = "combat gas mask"
	desc = "A low breathing resistance, durable gas mask in use with police and combat units."

/obj/item/clothing/suit/storage/jacket/marine/service
	desc = "A UNSCDF service jacket. It's surprisingly durable thanks to its high quality construction."

/obj/structure/machinery/atm
	name = "automated teller machine"
	desc = "An automated point of service for expeditionary banking operations."
