/mob/living/carbon/xenomorph
	var/is_pony_xeno = FALSE

/obj/effect/temp_visual/dir_setting/bloodsplatter/pony
	icon = 'modular/pony_xeno/icons/effects/pony_blood.dmi'
	splatter_type = "csplatter"
	color = "#FF99CC"

/obj/effect/decal/cleanable/blood/pony
	name = "sparkling blood"
	desc = "Bright, glittering ichor that absolutely should not exist in nature."
	icon = 'modular/pony_xeno/icons/effects/pony_blood.dmi'
	basecolor = "#FF99CC"
	amount = 1

/obj/effect/decal/cleanable/blood/gibs/pony
	name = "pony gibs"
	gender = PLURAL
	desc = "A tragic and theatrical spread of barded equine remains."
	icon = 'modular/pony_xeno/icons/effects/pony_blood.dmi'
	base_icon = 'modular/pony_xeno/icons/effects/pony_blood.dmi'
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	basecolor = "#FF99CC"

/obj/effect/decal/cleanable/blood/gibs/pony/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/pony/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/pony/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/blood/gibs/pony/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/proc/pgibs(atom/location, list/viruses)
	new /obj/effect/spawner/gibspawner/pony(get_turf(location), viruses)

/obj/effect/spawner/gibspawner/pony
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs/pony,
		/obj/effect/decal/cleanable/blood/gibs/pony/limb,
		/obj/effect/decal/cleanable/blood/gibs/pony/core,
	)
	gibamounts = list(1, 1, 1)

/obj/effect/spawner/gibspawner/pony/Initialize(mapload, list/viruses, mob/living/ml, fleshcolor, bloodcolor)
	gibdirections = list(GLOB.alldirs, GLOB.alldirs, list())
	. = ..()

/mob/living/carbon/xenomorph/pony
	is_pony_xeno = TRUE
	name = "pony xeno"
	desc = "A militarized pony horror that still rides the full xenomorph lifecycle underneath its barding."
	voice_name = "pony xeno"
	icon = PONY_XENO_ICON_STATES_BASE
	icon_state = PONY_XENO_ICON_STATE_EMPTY
	icon_xeno = PONY_XENO_ICON_STATES_BASE
	icon_xenonid = PONY_XENO_ICON_STATES_BASE
	icon_size = 64
	pixel_x = -16
	old_x = -16
	base_pixel_x = 0
	base_pixel_y = -18
	layer = MOB_LAYER
	plasma_types = list(PLASMA_CATECHOLAMINE)

	var/pony_sprite_seed = 0
	var/pony_designation_name = null
	var/pony_title = "Warpony"
	var/pony_voice_name = "warpony"
	var/pony_default_armor_variant = PONY_XENO_NONE
	var/pony_render_offset_x = 0
	var/pony_render_offset_y = 0
	var/pony_directional_north_x = 0
	var/pony_directional_north_y = -1
	var/pony_directional_south_x = 0
	var/pony_directional_south_y = 0
	var/pony_directional_east_x = 1
	var/pony_directional_east_y = 0
	var/pony_directional_west_x = -1
	var/pony_directional_west_y = 0
	var/datum/pony_xeno_appearance/pony_appearance
	var/list/pony_body_variant_pool = list("battle")
	var/list/pony_mane_front_variant_pool = list("wintershield")
	var/list/pony_mane_back_variant_pool = list("wintershield")
	var/list/pony_tail_variant_pool = list("standard")
	var/list/pony_eye_variant_pool = list("standard")
	var/list/pony_horn_variant_pool = list(PONY_XENO_NONE)
	var/list/pony_wing_variant_pool = list(PONY_XENO_NONE)
	var/list/pony_cutie_mark_variant_pool = list(PONY_XENO_NONE)
	var/list/pony_armor_variant_pool = list(PONY_XENO_NONE)
	var/list/pony_body_palette_keys = list(PONY_XENO_PALETTE_BODY_PASTEL)
	var/list/pony_mane_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT)
	var/list/pony_tail_palette_keys = list(PONY_XENO_PALETTE_MANE_BRIGHT)
	var/list/pony_eye_palette_keys = list(PONY_XENO_PALETTE_EYES_STANDARD)
	var/list/pony_armor_palette_keys = list(PONY_XENO_PALETTE_ARMOR_CHITIN)
	var/next_pony_combat_sound = 0
	var/list/sound_meta_map = null
	var/list/sound_meta_spawn = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_spawn_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_spawn_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_MEDIUM)
	)
	var/list/sound_meta_speaking = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_speak_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_speak_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_death = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_death_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_death_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_emote_roar = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_combat_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_combat_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_emote_hiss = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_speak_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_emote_growl = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_combat_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_emote_needshelp = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_death_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_combat_alert = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_combat_1.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/pony_xeno/sounds/pony_combat_2.ogg', ARACHNID_SOUND_META_TIER = PONY_XENO_SOUND_TIER_SHORT)
	)
	var/list/sound_meta_magic = list()
	var/list/sound_emote_roar = list('modular/pony_xeno/sounds/pony_combat_1.ogg', 'modular/pony_xeno/sounds/pony_combat_2.ogg')
	var/list/sound_emote_hiss = list('modular/pony_xeno/sounds/pony_speak_2.ogg')
	var/list/sound_emote_growl = list('modular/pony_xeno/sounds/pony_combat_1.ogg')
	var/list/sound_emote_needshelp = list('modular/pony_xeno/sounds/pony_death_2.ogg')

/mob/living/carbon/xenomorph/pony/Initialize(mapload, mob/living/carbon/xenomorph/old_xeno, hivenumber, ai_hard_off = FALSE)
	if(istype(old_xeno, /mob/living/carbon/xenomorph/pony))
		var/mob/living/carbon/xenomorph/pony/old_pony = old_xeno
		pony_sprite_seed = old_pony.pony_sprite_seed
		pony_designation_name = old_pony.pony_designation_name
		if(old_pony.pony_appearance)
			pony_appearance = new
			pony_appearance.copy_from(old_pony.pony_appearance)

	if(!pony_sprite_seed)
		pony_sprite_seed = rand(1, 999999)

	. = ..()

	if(wound_icon_holder)
		vis_contents -= wound_icon_holder
		qdel(wound_icon_holder)
		wound_icon_holder = null

	voice_name = pony_voice_name
	update_icons()

/mob/living/carbon/xenomorph/pony/update_icon_source()
	if(!caste)
		return
	update_icons()

/mob/living/carbon/xenomorph/pony/update_icons()
	if(!caste)
		return

	update_fire()
	update_wounds()
	update_inv_back()

	if(behavior_delegate?.on_update_icons())
		return

	apply_generated_pony_appearance()

/mob/living/carbon/xenomorph/pony/recalculate_everything()
	. = ..()
	update_icons()

/mob/living/carbon/xenomorph/pony/setDir(newdir)
	var/old_render_direction = get_pony_render_direction(dir)
	. = ..()
	if(get_pony_render_direction(dir) != old_render_direction)
		apply_generated_pony_appearance()

/mob/living/carbon/xenomorph/pony/process_ai(delta_time)
	if(current_target && prob(PONY_XENO_COMBAT_SOUND_TRIGGER_CHANCE))
		play_combat_sound()
	return ..()

/mob/living/carbon/xenomorph/pony/proc/get_or_generate_pony_designation_name()
	if(pony_designation_name)
		return pony_designation_name

	if(length(GLOB.pony_xeno_names))
		pony_designation_name = pony_pick_from_list(GLOB.pony_xeno_names, "designation-name", "[pony_title] Spark")
	else
		pony_designation_name = "[pony_title] Spark"
	return pony_designation_name

/mob/living/carbon/xenomorph/pony/generate_name()
	if(!nicknumber)
		generate_and_set_nicknumber()

	var/datum/hive_status/in_hive = hive
	if(!in_hive)
		in_hive = GLOB.hive_datum[hivenumber]

	hud_set_marks()

	var/name_prefix = in_hive?.prefix || ""
	var/name_client_prefix = ""
	var/name_client_postfix = ""
	if(client)
		name_client_prefix = "[(client.xeno_prefix || client.xeno_postfix) ? client.xeno_prefix : "XX"]-"
		name_client_postfix = client.xeno_postfix ? ("-[client.xeno_postfix]") : ""
		age_xeno()

	full_designation = "[name_client_prefix][nicknumber][name_client_postfix]"
	if(in_hive && !HAS_TRAIT(src, TRAIT_NO_COLOR))
		color = in_hive.color

	var/name_display = ""
	if(show_name_numbers)
		name_display = show_only_numbers ? " ([nicknumber])" : " ([full_designation])"

	var/pony_name = get_or_generate_pony_designation_name()
	name = "[name_prefix][pony_title] [pony_name][name_display]"
	change_real_name(src, name)
	in_hive?.hive_ui.update_xeno_info()

/mob/living/carbon/xenomorph/pony/get_examine_text(mob/user)
	. = ..()
	. += "Its silhouette is unmistakably equine, but every motion still follows the hive's predatory rhythm."
	if(pony_appearance?.horn_variant != PONY_XENO_NONE)
		. += "A hostile horn crowns its skull with ugly, weaponized grace."
	if(pony_appearance?.wing_variant != PONY_XENO_NONE)
		. += "Its wings look built for flanking runs rather than flight displays."
	if(pony_appearance?.cutie_mark_variant != PONY_XENO_NONE)
		. += "A warped cutie mark glows through the armor plates on its flank."

/mob/living/carbon/xenomorph/pony/get_blood_color()
	if(caste?.royal_caste || caste_type == PONY_XENO_CASTE_ALICORN_MATRIARCH)
		return "#C7A6FF"
	if(caste_type == PONY_XENO_CASTE_UNICORN_CASTER)
		return "#A9B8FF"
	return "#FF99CC"

/mob/living/carbon/xenomorph/pony/add_splatter_floor(turf/T, small_drip, b_color)
	if(!T)
		T = get_turf(src)
	if(!T?.can_bloody)
		return

	var/obj/effect/decal/cleanable/blood/pony/decal = locate(/obj/effect/decal/cleanable/blood/pony) in T.contents
	if(!decal)
		decal = new(T)
		decal.color = b_color || get_blood_color()

/mob/living/carbon/xenomorph/pony/handle_blood_splatter(splatter_dir, duration)
	new /obj/effect/temp_visual/dir_setting/bloodsplatter/pony(loc, splatter_dir, duration, get_blood_color())

/mob/living/carbon/xenomorph/pony/spawn_gibs()
	pgibs(get_turf(src))

/mob/living/carbon/xenomorph/pony/gib_animation()
	new /obj/effect/temp_visual/dir_setting/bloodsplatter/pony(loc, SOUTH, 8, get_blood_color())

/mob/living/carbon/xenomorph/pony/gib(datum/cause_data/cause = create_cause_data("gibbing", src))
	if(legcuffed)
		drop_inv_item_on_ground(legcuffed)

	for(var/atom/movable/contained_atom in stomach_contents)
		stomach_contents.Remove(contained_atom)
		contained_atom.forceMove(get_turf(loc))
		contained_atom.acid_damage = 0
		if(ismob(contained_atom))
			visible_message(SPAN_DANGER("[contained_atom] bursts out of [src]!"))

	for(var/atom/movable/recursive_atom in contents_recursive())
		if(isobj(recursive_atom))
			var/obj/contained_object = recursive_atom
			if(contained_object.unacidable)
				contained_object.forceMove(get_turf(loc))
				contained_object.throw_atom(pick(range(1, get_turf(loc))), 1, SPEED_FAST)

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.pixel_x = pixel_x
	remains.icon = get_custom_remains_icon()
	remains.icon_state = get_custom_remains_icon_state()

	check_blood_splash(35, BURN, 65, 1)

	gibbing = TRUE
	death(cause, TRUE)
	gib_animation()
	if(!SSticker?.mode?.hardcore)
		spawn_gibs()
	SSround_recording.recorder.stop_tracking(src)
	SSminimaps.remove_marker(src)
	qdel(src)

/obj/effect/pony_xeno_test_spawner
	name = "pony xeno test spawner"
	icon = 'icons/landmarks.dmi'
	icon_state = "x4"
	anchored = TRUE

	var/pony_type = /mob/living/carbon/xenomorph/pony/pegasus_skirmisher
	var/hive_number = XENO_HIVE_NORMAL
	var/spawn_ai = TRUE

/obj/effect/pony_xeno_test_spawner/Initialize(mapload)
	. = ..()
	var/turf/spawn_turf = get_turf(src)
	if(!spawn_turf)
		return INITIALIZE_HINT_QDEL

	var/mob/living/carbon/xenomorph/pony/spawned_pony = new pony_type(spawn_turf, null, hive_number, !spawn_ai)
	if(spawn_ai && !spawned_pony.ai_movement_handler)
		spawned_pony.make_ai()
	return INITIALIZE_HINT_QDEL
