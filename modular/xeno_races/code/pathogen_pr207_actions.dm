// Pathogen PR207 additions kept separate from local xeno changes.

/datum/action/xeno_action/onclick/xeno_resting/pathogen
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'

/datum/action/xeno_action/onclick/shift_spits/conditor
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'
	ability_primacy = XENO_PRIMARY_ACTION_4

/datum/action/xeno_action/onclick/choose_resin/pathogen
	name = "Choose Mycelium Structure"
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'

/datum/action/xeno_action/onclick/choose_resin/pathogen/not_primary
	ability_primacy = XENO_NOT_PRIMARY_ACTION

/datum/action/xeno_action/onclick/choose_resin/pathogen/overmind_macro //so it doesn't screw other macros up
	ability_primacy = XENO_PRIMARY_ACTION_4

/datum/action/xeno_action/activable/secrete_resin/pathogen
	name = "Shape Mycelium"
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'

/datum/action/xeno_action/activable/secrete_resin/pathogen/archon
	ability_primacy = XENO_PRIMARY_ACTION_4

/datum/action/xeno_action/activable/secrete_resin/pathogen/thick
	name = "Shape Thick Mycelium"
	thick = TRUE

/datum/action/xeno_action/activable/secrete_resin/pathogen/overmind_macro
	ability_primacy = XENO_PRIMARY_ACTION_5

/datum/action/xeno_action/onclick/emit_pheromones/pathogen
	name = "Emit Pheremone Spores (30)"
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'

/datum/action/xeno_action/onclick/xenohide/pathogen
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'

/datum/action/xeno_action/onclick/toggle_seethrough/pathogen
	button_icon_state = "template_pathogen"
	icon_file = 'icons/mob/hud/actions_pathogen.dmi'



/datum/action/xeno_action/onclick/send_thoughts // and prayers
	name = "Psychic Communication"
	action_icon_state = "psychic_whisper"
	plasma_cost = 0


/datum/action/xeno_action/onclick/send_thoughts/use_ability(atom/Atom)
	var/mob/living/carbon/xenomorph/queen/thought_sender = owner
	var/static/list/options = list(
		"Psychic Radiance (100)" = icon(/datum/action/xeno_action::icon_file, "psychic_radiance"),
		"Psychic Whisper (0)" = icon(/datum/action/xeno_action::icon_file, "psychic_whisper"),
		"Give Order (100)" = icon(/datum/action/xeno_action::icon_file, "queen_order")
	)

	var/choice
	if(thought_sender.client?.prefs.no_radials_preference)
		choice = tgui_input_list(thought_sender, "Communicate", "Send Thoughts", options, theme="hive_status")
	else
		choice = show_radial_menu(thought_sender, thought_sender?.client.eye, options)

	if(!choice)
		return

	return ..()


/datum/action/xeno_action/onclick/tail_sweep/ai
	action_type = XENO_ACTION_CLICK
	default_ai_action = TRUE
	xeno_cooldown = 12 SECONDS

/datum/action/xeno_action/onclick/tail_sweep/ai/process_ai(mob/living/carbon/xenomorph/using_xeno, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time))
		return

	// The sweep only hits adjacent mobs.
	if(using_xeno.count_ai_targets_in_range(1) < 2)
		return

	if(using_xeno.action_busy)
		return

	use_ability_async()


/datum/action/xeno_action/activable/scissor_cut/ai
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/scissor_cut/ai/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time))
		return

	// The cut only goes in a straight line, the same way use_ability() builds it.
	var/turf/target_turf = get_turf(parent.current_target)
	var/facing = Get_Compass_Dir(parent, target_turf)
	var/turf/checked_turf = get_turf(parent)
	for(var/i in 1 to 4)
		checked_turf = get_step(checked_turf, facing)
		if(!checked_turf || checked_turf.density)
			return
		if(checked_turf == target_turf)
			use_ability_async(parent.current_target)
			return


/obj/effect/pathogen_construct
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/mob/pathogen/pathogen_effects.dmi'

/obj/effect/pathogen_construct/door
	icon_state = "DoorConstruct"

/obj/effect/pathogen_construct/thickdoor
	icon_state = "ThickDoorConstruct"

/obj/effect/pathogen_construct/thick
	icon_state = "ThickConstruct"

/obj/effect/pathogen_construct/weak
	icon_state = "WeakConstruct"

/obj/effect/pathogen_construct/transparent/thick
	icon_state = "ThickTransparentConstruct"

/obj/effect/pathogen_construct/transparent/weak
	icon_state = "WeakTransparentConstruct"

// Use the pathogen construction artwork in the resin selection UI.
/datum/resin_construction/resin_turf/wall/pathogen
	construction_icon = 'icons/mob/hud/xeno_building.dmi'

/datum/resin_construction/resin_turf/membrane/pathogen
	construction_icon = 'icons/mob/hud/xeno_building.dmi'

/datum/resin_construction/resin_obj/door/pathogen
	construction_icon = 'icons/mob/hud/xeno_building.dmi'

/datum/resin_construction/resin_obj/popper_cocoon
	construction_icon = 'icons/mob/hud/xeno_building.dmi'

#undef WEED_BASE_GROW_SPEED


/datum/hive_status/pathogen/can_delay_round_end(mob/living/carbon/xenomorph/xeno)
	if(HAS_TRAIT(src, TRAIT_NO_HIVE_DELAY))
		return FALSE

	var/danger_mobs = 0
	for(var/mob/living/carbon/xenomorph/mob in totalXenos)
		if(ispopper(mob) || !mob.counts_for_roundend)
			continue
		if(mob == living_xeno_queen)
			continue
		danger_mobs++

	if(!danger_mobs)
		return FALSE
	return TRUE

/datum/hive_status/pathogen/respawn_on_turf(client/xeno_client, turf/spawning_turf)
	var/mob/living/carbon/xenomorph/new_xeno = spawn_hivenumber_larva(spawning_turf, hivenumber)
	if(isnull(new_xeno))
		return FALSE

	if(!SSticker.mode.transfer_xeno(xeno_client.mob, new_xeno))
		qdel(new_xeno)
		return FALSE

	new_xeno.visible_message(SPAN_XENODANGER("A bloodburster suddenly emerges from a dead husk!"),
	SPAN_XENOANNOUNCE("The confluence has no core! You manage to emerge from your old husk as a bloodburster!"))
	msg_admin_niche("[key_name(new_xeno)] respawned at \a [spawning_turf]. [ADMIN_JMP(spawning_turf)]")
	to_chat(new_xeno, SPAN_XENOANNOUNCE("Remember you should not be leaving the safety of the confluence unless under threat, and should be keeping yourself safe until you evolve!"))
	playsound(new_xeno, 'sound/effects/xeno_newlarva.ogg', 50, 1)
	if(new_xeno.client?.prefs?.toggles_flashing & FLASH_POOLSPAWN)
		window_flash(new_xeno.client)

	hive_ui.update_burrowed_larva()

/datum/hive_status/pathogen/do_buried_larva_spawn(mob/xeno_candidate)
	var/spawning_area
	if(hive_location)
		spawning_area = hive_location
	else if(living_xeno_queen)
		spawning_area = living_xeno_queen
	else
		for(var/mob/living/carbon/xenomorpheus as anything in totalXenos)
			if(isbloodburster(xenomorpheus) || isxeno_builder(xenomorpheus)) //next to xenos that should be in a safe spot
				spawning_area = xenomorpheus
	if(!spawning_area)
		spawning_area = pick(totalXenos) // FUCK IT JUST GO ANYWHERE
	var/list/turf_list
	for(var/turf/open/open_turf in orange(3, spawning_area))
		if(istype(open_turf, /turf/open/space))
			continue
		LAZYADD(turf_list, open_turf)
	// just on the off-chance
	if(!LAZYLEN(turf_list))
		return FALSE
	var/turf/open/spawning_turf = pick(turf_list)

	var/mob/living/carbon/xenomorph/new_xeno = spawn_hivenumber_larva(spawning_turf, hivenumber)
	if(isnull(new_xeno))
		return FALSE

	if(!SSticker.mode.transfer_xeno(xeno_candidate, new_xeno))
		qdel(new_xeno)
		return FALSE
	new_xeno.visible_message(SPAN_XENODANGER("A bloodburster suddenly burrows out of \the [spawning_turf]!"),
	SPAN_XENODANGER("You burrow out of \the [spawning_turf] and awaken from your slumber. For the Confluence!"))
	msg_admin_niche("[key_name(new_xeno)] burrowed out from \a [spawning_turf]. [ADMIN_JMP(spawning_turf)]")
	playsound(new_xeno, 'sound/effects/xeno_newlarva.ogg', 50, 1)
	to_chat(new_xeno, SPAN_XENOANNOUNCE("You are a pathogen bloodburster awakened from slumber!"))
	to_chat(new_xeno, SPAN_XENOANNOUNCE("Remember you should not be leaving the safety of the confluence unless under threat, and should be keeping yourself safe until you evolve!"))
	if(new_xeno.client)
		if(new_xeno.client?.prefs?.toggles_flashing & FLASH_POOLSPAWN)
			window_flash(new_xeno.client)

	stored_larva--
	hive_ui.update_burrowed_larva()
