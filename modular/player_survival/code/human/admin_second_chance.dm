/mob/living/carbon/human
	var/player_survival_admin_second_chance_pending = FALSE
	var/player_survival_admin_second_chance_admin_ckey = null
	var/player_survival_admin_second_chance_source_ckey = null
	var/player_survival_admin_second_chance_requested_at = 0

/mob/living/carbon/human/proc/player_survival_log_admin_second_chance_event(log_text)
	log_admin(log_text)
	message_admins("[log_text] [ADMIN_JMP(src)]")

/mob/living/carbon/human/proc/player_survival_log_admin_second_chance_mark(client/admin_client, mob/dead/observer/source_ghost)
	var/area/current_area = get_area(src)
	var/admin_ckey = admin_client?.ckey || "unknown"
	var/source_ckey = source_ghost?.ckey || "unknown"
	player_survival_log_admin_second_chance_event("[admin_ckey] marked [key_name_admin(src)] for player_survival second chance using ghost [source_ckey] in [current_area] ([x],[y],[z]).")

/mob/living/carbon/human/proc/player_survival_log_admin_second_chance_applied(previous_health, final_health, cleared_flags = "none", admin_ckey = null, source_ckey = null)
	var/area/current_area = get_area(src)
	var/admin_name = admin_ckey || "unknown"
	var/source_name = source_ckey || "unknown"
	player_survival_log_admin_second_chance_event("player_survival second chance revived [key_name_admin(src)] in [current_area] ([x],[y],[z]); admin=[admin_name]; ghost=[source_name]; health=[previous_health]=>[final_health]; cleared=[cleared_flags].")

/mob/living/carbon/human/proc/player_survival_log_admin_second_chance_skipped(reason, admin_ckey = null, source_ckey = null)
	var/area/current_area = get_area(src)
	var/admin_name = admin_ckey || "unknown"
	var/source_name = source_ckey || "unknown"
	player_survival_log_admin_second_chance_event("player_survival second chance skipped for [key_name_admin(src)] in [current_area] ([x],[y],[z]); admin=[admin_name]; ghost=[source_name]; reason=[reason].")

/mob/living/carbon/human/proc/player_survival_mark_admin_second_chance_pending(client/admin_client, mob/dead/observer/source_ghost)
	player_survival_admin_second_chance_pending = TRUE
	player_survival_admin_second_chance_admin_ckey = admin_client?.ckey
	player_survival_admin_second_chance_source_ckey = source_ghost?.ckey
	player_survival_admin_second_chance_requested_at = world.time
	player_survival_log_admin_second_chance_mark(admin_client, source_ghost)

/mob/living/carbon/human/proc/player_survival_clear_admin_second_chance_pending()
	player_survival_admin_second_chance_pending = FALSE
	player_survival_admin_second_chance_admin_ckey = null
	player_survival_admin_second_chance_source_ckey = null
	player_survival_admin_second_chance_requested_at = 0

/mob/living/carbon/human/proc/player_survival_get_admin_second_chance_head()
	var/obj/limb/head/head = get_limb("head")
	if(!head || QDELETED(head))
		head = get_limb("synthetic head")
	return head

/mob/living/carbon/human/proc/player_survival_get_admin_second_chance_block_reason()
	if(stat != DEAD)
		return "target is not dead"

	if(!client)
		return "target has no client after possession"

	var/obj/limb/head/head = player_survival_get_admin_second_chance_head()
	if(!head || head.status & LIMB_DESTROYED)
		return "missing or destroyed head"

	if(!has_brain())
		return "missing brain"

	return null

/mob/living/carbon/human/proc/player_survival_heal_damage_pool(amount, damage_type)
	if(amount <= 0)
		return 0

	var/current_loss = 0
	switch(damage_type)
		if(BRUTE)
			current_loss = getBruteLoss()
		if(BURN)
			current_loss = getFireLoss()
		if(TOX)
			current_loss = getToxLoss()
		if(CLONE)
			current_loss = getCloneLoss()
		else
			return 0

	var/heal_amount = min(amount, current_loss)
	if(heal_amount <= 0)
		return 0

	apply_damage(-heal_amount, damage_type)
	return heal_amount

/mob/living/carbon/human/proc/player_survival_restore_admin_second_chance_flags(had_permanently_dead, had_undefibbable, had_spawned_corpse)
	if(had_permanently_dead)
		status_flags |= PERMANENTLY_DEAD
	else
		status_flags &= ~PERMANENTLY_DEAD

	undefibbable = had_undefibbable
	spawned_corpse = had_spawned_corpse

	if(had_spawned_corpse || (had_undefibbable && stat == DEAD))
		SShuman.processable_human_list -= src

/mob/living/carbon/human/proc/player_survival_restore_internal_organs_for_admin_second_chance()
	if(!species?.has_organ)
		return

	for(var/organ_slot in species.has_organ)
		if(organ_slot == "brain")
			continue
		if(internal_organs_by_name[organ_slot])
			continue

		var/internal_organ_type = species.has_organ[organ_slot]
		if(!internal_organ_type)
			continue

		var/datum/internal_organ/restored_organ = new internal_organ_type(src)
		internal_organs_by_name[organ_slot] = restored_organ

	for(var/organ_slot in internal_organs_by_name)
		var/datum/internal_organ/internal_organ = internal_organs_by_name[organ_slot]
		if(!internal_organ)
			continue

		internal_organ.cut_away = FALSE
		if(internal_organ.damage)
			internal_organ.heal_damage(internal_organ.damage)
		else
			internal_organ.set_organ_status()

/mob/living/carbon/human/proc/player_survival_reset_admin_second_chance_host_state()
	chestburst = 0

	var/obj/item/alien_embryo/embryo = locate() in src
	if(!embryo)
		return

	var/mob/living/carbon/xenomorph/larva/larva = locate() in src
	if(larva)
		qdel(larva)

	qdel(embryo)
	status_flags &= ~XENO_HOST

/mob/living/carbon/human/proc/player_survival_apply_admin_second_chance()
	if(!player_survival_admin_second_chance_pending)
		return FALSE

	var/admin_ckey = player_survival_admin_second_chance_admin_ckey
	var/source_ckey = player_survival_admin_second_chance_source_ckey
	var/requested_at = player_survival_admin_second_chance_requested_at
	player_survival_clear_admin_second_chance_pending()

	var/block_reason = player_survival_get_admin_second_chance_block_reason()
	if(block_reason)
		player_survival_log_admin_second_chance_skipped("[block_reason]; requested_at=[requested_at]", admin_ckey, source_ckey)
		return FALSE

	var/previous_health = health
	var/had_permanently_dead = !!(status_flags & PERMANENTLY_DEAD)
	var/had_undefibbable = undefibbable
	var/had_spawned_corpse = spawned_corpse

	undefibbable = FALSE
	status_flags &= ~PERMANENTLY_DEAD
	spawned_corpse = FALSE
	player_survival_reset_admin_second_chance_host_state()
	player_survival_restore_internal_organs_for_admin_second_chance()

	apply_damage(-12, BRUTE)
	apply_damage(-12, BURN)
	apply_damage(-12, TOX)
	apply_damage(-12, CLONE)
	apply_damage(-getOxyLoss(), OXY)
	updatehealth()

	if(health <= HEALTH_THRESHOLD_CRIT)
		var/target_health = HEALTH_THRESHOLD_CRIT + 10
		var/required_heal = target_health - health
		required_heal -= player_survival_heal_damage_pool(required_heal, BRUTE)
		required_heal -= player_survival_heal_damage_pool(required_heal, BURN)
		required_heal -= player_survival_heal_damage_pool(required_heal, TOX)
		required_heal -= player_survival_heal_damage_pool(required_heal, CLONE)
		updatehealth()

	if(health <= HEALTH_THRESHOLD_DEAD)
		player_survival_restore_admin_second_chance_flags(had_permanently_dead, had_undefibbable, had_spawned_corpse)
		player_survival_log_admin_second_chance_skipped("still dead after healing; requested_at=[requested_at]; health=[health]", admin_ckey, source_ckey)
		return FALSE

	if(health <= HEALTH_THRESHOLD_CRIT)
		player_survival_restore_admin_second_chance_flags(had_permanently_dead, had_undefibbable, had_spawned_corpse)
		player_survival_log_admin_second_chance_skipped("health floor not reached; requested_at=[requested_at]; health=[health]", admin_ckey, source_ckey)
		return FALSE

	SShuman.processable_human_list |= src
	handle_revive()

	var/list/cleared_flags = list()
	if(had_permanently_dead)
		cleared_flags += "PERMANENTLY_DEAD"
	if(had_undefibbable)
		cleared_flags += "undefibbable"
	if(had_spawned_corpse)
		cleared_flags += "spawned_corpse"

	player_survival_log_admin_second_chance_applied(previous_health, health, length(cleared_flags) ? cleared_flags.Join("/") : "none", admin_ckey, source_ckey)
	return TRUE
