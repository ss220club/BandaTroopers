// From source/pr203:code/datums/vehicles.dm
/datum/map_template/interior/rt01
	name = "RT01"
	interior_id = "rt01"

// From source/pr203:code/game/objects/items/reagent_containers/food/condiment.dm
/obj/item/reagent_container/food/condiment/chocolate_syrup
	name = "\improper Chocolate Syrup bottle"
	desc = "A bottle of Weyland-Yutani brand chocolate syrup for adding chocolate flavor to space treats, or for sipping directly from the nozzle like a little kid."
	icon_state = "chocolate_syrup"
	possible_transfer_amounts = list(1,5,10,15,20,60) //the thought of marines having fisticuffs because somebody drank all the chocolate syrup is beyond hilarious.
	amount_per_transfer_from_this = 5
	volume = 60

// From source/pr203:code/game/objects/items/reagent_containers/food/condiment.dm
/obj/item/reagent_container/food/condiment/chocolate_syrup/Initialize()
	. = ..()
	reagents.add_reagent("coco", 60)

// From source/pr203:code/game/objects/items/reagent_containers/food/condiment.dm
/obj/item/reagent_container/food/condiment/chocolate_syrup/on_reagent_change()
	return //Yes, I do have my own sprite.

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger
	name = "Packaged Cheeseburger"
	desc = "A soggy microwavable burger. There's no time given for how long to cook it. Packaged by the Weyland-Yutani Corporation."
	icon_state = "burger"
	item_state = "pburger"
	icon = 'icons/obj/items/food/burgers.dmi'
	bitesize = 3
	package = 1

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger/Initialize()
	. = ..()
	reagents.add_reagent("bread", 5)
	reagents.add_reagent("meatprotein", 5)
	reagents.add_reagent("sodiumchloride", 2)

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger/attack_self(mob/user)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull off the wrapping from the squishy hamburger!"))
		package = 0
		user.put_in_hands(new /obj/item/trash/burger)
		icon_state = "hburger"
		item_state = "burger"
		return
	..()

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger/unbranded
	desc = "A soggy microwavable burger. There's no time given for how long to cook it."
	icon = 'icons/obj/items/food/junkfood.dmi'
	icon_state = "unbranded_packaged-burger"
	item_state = "unbranded_pburger"

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger/unbranded/attack_self(mob/user)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull off the wrapping from the squishy hamburger!"))
		package = 0
		user.put_in_hands(new /obj/item/trash/burger/alt)
		icon_state = "open-burger"
		item_state = "unbranded_burger"
		return
	..()

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burger/unbranded/Initialize()
	. = ..()
	reagents.add_reagent("bread", 5)
	reagents.add_reagent("meatprotein", 5)
	reagents.add_reagent("sodiumchloride", 2)

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_hdogs/unbranded
	desc = "A singular squishy, room temperature, hot dog. There's no time given for how long to cook it, so you assume its probably good to go."
	icon_state = "unbranded_packaged-hotdog"
	item_state = "unbranded_photdog"

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_hdogs/unbranded/attack_self(mob/user)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull off the wrapping from the squishy hotdog!"))
		package = 0
		user.put_in_hands(new /obj/item/trash/hotdog/alt)
		icon_state = "open-hotdog"
		item_state = "unbranded_hotdog"
		return
	..()

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_hdogs/unbranded/Initialize()
	. = ..()
	reagents.add_reagent("bread", 2)
	reagents.add_reagent("meatprotein", 1)
	reagents.add_reagent("sodiumchloride", 2)

// From source/pr203:code/game/objects/items/storage/boxes.dm
/obj/item/storage/box/m94
	name = "\improper M94 marking flare pack"
	desc = "A packet of eight M94 Marking Flares. Carried by USCM soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp."
	icon_state = "m94"
	icon = 'icons/obj/items/storage/packets.dmi'
	w_class = SIZE_MEDIUM
	storage_slots = 8
	max_storage_space = 8
	can_hold = list(/obj/item/device/flashlight/flare,/obj/item/device/flashlight/flare/signal)

// From source/pr203:code/game/objects/items/storage/boxes.dm
/obj/item/storage/box/m94/fill_preset_inventory()
	for(var/i = 1 to max_storage_space)
		new /obj/item/device/flashlight/flare(src)

// From source/pr203:code/game/objects/items/storage/boxes.dm
/obj/item/storage/box/m94/update_icon()
	if(!length(contents))
		icon_state = "m94_e"
	else
		icon_state = "m94"

// From source/pr203:code/game/objects/items/storage/pouch.dm
/obj/item/storage/pouch/document
	name = "large document pouch"
	desc = "It can contain papers, folders, disks, technical manuals, and clipboards."
	icon_state = "document"
	storage_slots = 21
	max_w_class = SIZE_MEDIUM
	max_storage_space = 21
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_CLICK_GATHER
	can_hold = list(
		/obj/item/paper,
		/obj/item/clipboard,
		/obj/item/folder,
		/obj/item/disk,
	)

// From source/pr203:code/game/objects/items/storage/pouch.dm
/obj/item/storage/pouch/document/small
	name = "small document pouch"
	desc = "A smaller version of the document pouch. It can contain papers, folders, disks, technical manuals, and clipboards."
	storage_slots = 7

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/structure/inflatable/popped/black
	icon_state = "wall_popped_black"
	icon_suffix = "_black"

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/structure/bed/bedroll/comfy
	name = "unfolded comfy bedroll"
	desc = "A bedroll so comfy, it’s technically illegal in three sectors for causing excessive napping."
	icon_state = "bedroll_comfy_o"
	foldabletype = /obj/item/roller/bedroll/comfy

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/structure/bed/bedroll/comfy/blue
	color = "#8cb9e2"
	foldabletype = /obj/item/roller/bedroll/comfy/blue

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/structure/bed/bedroll/comfy/pink
	color = "#eaa8b2"
	foldabletype = /obj/item/roller/bedroll/comfy/pink

// From source/pr203:code/modules/clothing/head/helmet.dm
/obj/item/clothing/head/helmet/marine/fireproof_hood
	name = "HZP-12 entry-type proximity hood"
	desc = "A sealed thermal hood component of the HZP-12 proximity suit system. It provides head and neck protection against extreme heat."
	icon_state = "fireproof_hood"
	item_state = "fireproof_hood"
	icon = 'icons/obj/items/clothing/hats/hazard.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hazard.dmi',
	)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROT
	flags_cold_protection = BODY_FLAG_HEAD
	flags_heat_protection = BODY_FLAG_HEAD
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_LOW
	unacidable = TRUE
	force = 0
	throwforce = 0
	flags_inventory = BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_marine_helmet = NO_FLAGS
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	built_in_visors = list()

// From source/pr203:code/modules/clothing/head/helmet.dm
/obj/item/clothing/head/helmet/marine/fireproof_hood/Initialize(mapload)
	. = ..()

// From source/pr203:code/modules/clothing/shoes/marine_shoes.dm
/obj/item/clothing/shoes/marine/upp/black
	icon_state = "marine"
	item_state = "marine"

// From source/pr203:code/modules/clothing/shoes/marine_shoes.dm
/obj/item/clothing/shoes/marine/upp/black/knife
	spawn_item_type = /obj/item/attachable/bayonet/upp

// From source/pr203:code/modules/clothing/under/marine_uniform.dm
/obj/item/clothing/under/marine/seegson_security
	name = "Seegson security uniform"
	desc = "An armored uniform worn by Seegson corporate security members."
	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/SEEGSON.dmi'
	item_icons = list(
		WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/SEEGSON.dmi',
	)
	icon_state = "seegson_security_uniform"
	worn_state = "seegson_security_uniform"

	flags_atom = FPRINT|NO_NAME_OVERRIDE|NO_SNOW_TYPE

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe
	name = "Deactivated Working Joe"
	assignment = JOB_WORKING_JOE
	idtype = /obj/item/card/id/lanyard
	var/new_bubble_icon = "machine"

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe/load_race(mob/living/carbon/human/new_human)
	new_human.set_species(SYNTH_WORKING_JOE)
	new_human.r_eyes = 78
	new_human.g_eyes = 74
	new_human.b_eyes = 59
	new_human.h_style = "Bald"
	new_human.f_style = "Shaved"

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe/load_name(mob/living/carbon/human/new_human, randomise)
	new_human.bubble_icon = new_bubble_icon
	new_human.age = rand(3, 5)
	if(faction == FACTION_UPP)
		new_human.change_real_name(new_human, "Dzho Automaton №[rand(9)][rand(9)][ascii2text(rand(65, 90))][ascii2text(rand(65, 90))]")
	else
		new_human.change_real_name(new_human, "Working Joe #[rand(100)][rand(100)]")

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe/load_gear(mob/living/carbon/human/new_human)
	add_ice_colony_survivor_equipment(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/rank/synthetic/joe(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/joe(new_human), WEAR_FEET)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/stack/nanopaste(new_human), WEAR_IN_BACK)

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe/fireproof
	name = "Deactivated - Fireproof - Working Joe"

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/working_joe/fireproof/load_gear(mob/living/carbon/human/new_human)
	add_ice_colony_survivor_equipment(new_human)
	var/i = rand(1,2)
	switch(i)
		if (1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/rank/synthetic/joe/fire(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/fireproof_boots(new_human), WEAR_FEET)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/fireproof_gloves(new_human), WEAR_HANDS)
			new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_WAIST)
		if (2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/rank/synthetic/joe/fire/overalls(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/fireproof_boots(new_human), WEAR_FEET)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/fireproof_gloves(new_human), WEAR_HANDS)
			new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_WAIST)

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/upp_spy
	name = "Corpse - Suspicious Colonist"
	faction = FACTION_UPP

// From source/pr203:code/modules/gear_presets/corpses.dm
/datum/equipment_preset/corpse/upp_spy/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/UPP(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/lasalle(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/black(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/document/small(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/black/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/np92/suppressed(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/black_market_hacking_device(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92/suppressed(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92/suppressed(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/black_vest/waistcoat(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/chrome(new_human), WEAR_EYES)

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01
	name = "RT-01 Transport"
	desc = "An aging eight-wheeled heavy transport built to haul personnel and equipment across a variety of terrain. Entrance on the back and sides."
	layer = ABOVE_XENO_LAYER

	icon = 'icons/obj/vehicles/rt01.dmi'
	icon_state = "rt01_base"
	pixel_x = -16
	pixel_y = -16

	bound_width = 64
	bound_height = 64

	bound_x = 0
	bound_y = 0

	interior_map = /datum/map_template/interior/rt01

	entrances = list(
		"left" = list(2, 0),
		"right" = list(-1, 0),
		"back_left" = list(1, 2),
		"back_right" = list(0, 2)
	)

	vehicle_flags = VEHICLE_CLASS_WEAK

	passengers_slots = 8
	xenos_slots = 2

	misc_multipliers = list(
		"move" = 0.5, // fucking annoying how this is the only way to modify speed
		"accuracy" = 1,
		"cooldown" = 1
	)

	movement_sound = 'sound/vehicles/rt_01_driving.ogg'
	honk_sound = 'sound/vehicles/rt_01_horn.ogg'

	vehicle_light_range = 8

	move_max_momentum = 3

	hardpoints_allowed = list(
		/obj/item/hardpoint/locomotion/van_wheels/rt01,
	)

	move_turn_momentum_loss_factor = 1

	req_access = list()
	req_one_access = list()

	door_locked = FALSE

	mob_size_required_to_hit = MOB_SIZE_XENO

	var/overdrive_next = 0
	var/overdrive_cooldown = 15 SECONDS
	var/overdrive_duration = 3 SECONDS
	var/overdrive_speed_mult = 0.3 // Additive (30% more speed, adds to 80% more speed)

	var/momentum_loss_on_weeds_factor = 0.2

	move_on_turn = TRUE

	var/list/mobs_under = list()
	var/image/under_image
	var/image/normal_image

	var/next_push = 0
	var/push_delay = 0.5 SECONDS

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/Initialize()
	. = ..()
	under_image = image(icon, src, icon_state, layer = BELOW_MOB_LAYER)
	under_image.alpha = 127

	normal_image = image(icon, src, icon_state, layer = layer)

	icon_state = null

	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(add_default_image))

	for(var/I in GLOB.player_list)
		add_default_image(SSdcs, I)

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/BlockedPassDirs(atom/movable/mover, target_dir)
	if(mover in mobs_under) //can't collide with the thing you're buckled to
		return NO_BLOCKED_MOVEMENT

	if(isliving(mover))
		var/mob/living/M = mover
		if(M.mob_flags & SQUEEZE_UNDER_VEHICLES)
			add_under_van(M)
			return NO_BLOCKED_MOVEMENT

		if(M.body_position == LYING_DOWN)
			return NO_BLOCKED_MOVEMENT

		if(M.mob_size >= MOB_SIZE_IMMOBILE && next_push < world.time)
			if(try_move(target_dir, force=TRUE))
				next_push = world.time + push_delay
				return NO_BLOCKED_MOVEMENT

	return ..()

/*
** PRESETS
*/

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/pre_movement()
	if(locate(/obj/effect/alien/weeds) in loc)
		move_momentum *= momentum_loss_on_weeds_factor

	. = ..()

	for(var/I in mobs_under)
		var/mob/M = I
		if(!(M.loc in locs))
			remove_under_van(M)

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/add_under_van(mob/living/L)
	if(L in mobs_under)
		return

	mobs_under += L
	RegisterSignal(L, COMSIG_PARENT_QDELETING, PROC_REF(remove_under_van))
	RegisterSignal(L, COMSIG_MOB_LOGGED_IN, PROC_REF(add_client))
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(check_under_van))

	if(L.client)
		add_client(L)

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/remove_under_van(mob/living/L)
	SIGNAL_HANDLER
	mobs_under -= L

	if(L.client)
		L.client.images -= under_image
		add_default_image(SSdcs, L)

	UnregisterSignal(L, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_MOB_LOGGED_IN,
		COMSIG_MOVABLE_MOVED,
	))

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/check_under_van(mob/M, turf/oldloc, direction)
	SIGNAL_HANDLER
	if(!(M.loc in locs))
		remove_under_van(M)

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/add_client(mob/living/L)
	SIGNAL_HANDLER
	L.client.images += under_image
	L.client.images -= normal_image

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/add_default_image(subsystem, mob/M)
	SIGNAL_HANDLER
	M.client.images += normal_image

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/Destroy()
	for(var/I in mobs_under)
		remove_under_van(I)

	for(var/I in GLOB.player_list)
		var/mob/M = I
		M.client.images -= normal_image

	QDEL_NULL(light_holder)

	return ..()

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/attackby(obj/item/O, mob/user)
	if(user.z != z)
		return ..()

	if(iswelder(O) && health >= initial(health))
		if(!HAS_TRAIT(O, TRAIT_TOOL_BLOWTORCH))
			to_chat(user, SPAN_WARNING("You need a stronger blowtorch!"))
			return
		var/obj/item/hardpoint/H
		for(var/obj/item/hardpoint/potential_hardpoint in hardpoints)
			if(potential_hardpoint.health < initial(potential_hardpoint.health))
				H = potential_hardpoint
				break

		if(H)
			H.handle_repair(O, user)
			update_icon()
			return

	. = ..()

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/handle_click(mob/living/user, atom/A, list/mods)
	if(mods[SHIFT_CLICK] && !mods[ALT_CLICK])
		if(overdrive_next > world.time)
			to_chat(user, SPAN_WARNING("You can't activate overdrive yet! Wait [round((overdrive_next - world.time) / 10, 0.1)] seconds."))
			return

		misc_multipliers["move"] -= overdrive_speed_mult
		addtimer(CALLBACK(src, PROC_REF(reset_overdrive)), overdrive_duration)

		overdrive_next = world.time + overdrive_cooldown
		to_chat(user, SPAN_NOTICE("You activate overdrive."))
		playsound(src, 'sound/vehicles/rt_01_overdrive_activate.ogg', 75, FALSE)
		return

	return ..()

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/proc/reset_overdrive()
	misc_multipliers["move"] += overdrive_speed_mult

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/get_projectile_hit_boolean(obj/projectile/P)
	if(src == P.original) //clicking on the van itself will hit it.
		var/hitchance = P.get_effective_accuracy()
		if(prob(hitchance))
			return TRUE
	return FALSE

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/vehicle/multitile/rt01/Collide(atom/A)
	if(!seats[VEHICLE_DRIVER])
		return FALSE

	if(istype(A, /obj/structure/barricade/plasteel))
		return ..()

	if(istype(A, /turf/closed/wall) || \
	   istype(A, /obj/structure/barricade/sandbags) || \
	   istype(A, /obj/structure/barricade/metal) || \
	   istype(A, /obj/structure/barricade/deployable) || \
	   istype(A, /obj/structure/machinery/cryopod)) //Can no longer runover cryopods

		return FALSE

	return ..()

/*
** PRESETS SPAWNERS
*/
