/mob/living/carbon/human
	var/player_survival_damage_block_until = 0
	var/player_survival_last_damage_block_log_until = 0

/mob/living/carbon/human/proc/player_survival_is_protected_player()
	if(!client)
		return FALSE
	if(stat == DEAD || health <= HEALTH_THRESHOLD_DEAD)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/player_survival_damage_type_name(damage_type)
	switch(damage_type)
		if(BRUTE)
			return "BRUTE"
		if(BURN)
			return "BURN"
		if(TOX)
			return "TOX"
		if(OXY)
			return "OXY"
		if(CLONE)
			return "CLONE"
		if(HALLOSS)
			return "HALLOSS"
		if(BRAIN)
			return "BRAIN"
	return "[damage_type]"

/mob/living/carbon/human/proc/player_survival_log_event(log_text, admin_text = null, notify_admins = FALSE)
	log_attack(log_text)
	if(notify_admins)
		message_admins("[admin_text ? admin_text : log_text] [ADMIN_JMP(src)]")

/mob/living/carbon/human/proc/player_survival_log_crit_grace_activation(block_duration)
	var/area/current_area = get_area(src)
	player_survival_log_event(
		"[key_name(src)] activated player_survival crit grace for [DisplayTimeText(block_duration)] in [current_area] ([x],[y],[z]); health=[health]."
	)

/mob/living/carbon/human/proc/player_survival_log_damage_block(block_source, blocked_damage = null, damage_type = null, explosion_severity = null)
	if(player_survival_last_damage_block_log_until == player_survival_damage_block_until)
		return

	player_survival_last_damage_block_log_until = player_survival_damage_block_until

	var/area/current_area = get_area(src)
	var/list/log_details = list("remaining=[DisplayTimeText(max(player_survival_damage_block_until - world.time, 0))]")
	if(!isnull(blocked_damage))
		log_details += "damage=[blocked_damage]"
	if(!isnull(damage_type))
		log_details += "type=[player_survival_damage_type_name(damage_type)]"
	if(!isnull(explosion_severity))
		log_details += "severity=[explosion_severity]"

	var/details_text = log_details.Join("; ")
	player_survival_log_event(
		"[key_name(src)] had damage blocked by player_survival crit grace via [block_source] in [current_area] ([x],[y],[z]); [details_text].",
		"[key_name_admin(src)] had damage blocked by player_survival crit grace via [block_source] in [current_area] ([x],[y],[z]); [details_text].",
		TRUE
	)

/mob/living/carbon/human/proc/player_survival_log_antigib_fallback(datum/cause_data/cause, explosion_damage, explosion_severity, anti_gib_triggered, obj/limb/detached_limb, previous_health)
	var/area/current_area = get_area(src)
	var/cause_name = cause?.cause_name || "unknown"
	var/mob/cause_mob = cause?.resolve_mob()
	var/source_log_text = cause_mob ? " by [key_name(cause_mob)]" : ""
	var/source_admin_text = cause_mob ? " by [key_name_admin(cause_mob)]" : ""
	var/limb_text = detached_limb ? detached_limb.name : "none"
	var/list/trigger_details = list("anti_gib_triggered=[anti_gib_triggered]")
	if(!isnull(explosion_damage))
		trigger_details += "explosion_damage=[explosion_damage]"
	if(!isnull(explosion_severity))
		trigger_details += "explosion_severity=[explosion_severity]"
	var/trigger_text = trigger_details.Join("; ")

	player_survival_log_event(
		"[key_name(src)] avoided gib via player_survival from [cause_name][source_log_text] in [current_area] ([x],[y],[z]); [trigger_text]; health=[previous_health]=>[health]; limb=[limb_text].",
		"[key_name_admin(src)] avoided gib via player_survival from [cause_name][source_admin_text] in [current_area] ([x],[y],[z]); [trigger_text]; health=[previous_health]=>[health]; limb=[limb_text].",
		TRUE
	)

/mob/living/carbon/human/proc/player_survival_is_damage_blocked()
	if(!player_survival_is_protected_player())
		return FALSE
	return world.time <= player_survival_damage_block_until

/mob/living/carbon/human/proc/player_survival_activate_crit_grace()
	if(!client)
		return FALSE

	var/block_duration = max(0, CONFIG_GET(number/player_survival_crit_immunity_seconds)) SECONDS
	if(!block_duration)
		return FALSE

	var/previous_block_until = player_survival_damage_block_until
	player_survival_damage_block_until = max(player_survival_damage_block_until, world.time + block_duration)
	if(player_survival_damage_block_until > previous_block_until)
		player_survival_log_crit_grace_activation(block_duration)
	return TRUE

/mob/living/carbon/human/proc/player_survival_detach_random_extremity(datum/cause_data/cause)
	var/static/list/extremity_zones = list(
		"l_hand",
		"r_hand",
		"l_foot",
		"r_foot"
	)

	var/list/obj/limb/limb_candidates = list()
	for(var/zone in extremity_zones)
		var/obj/limb/limb = get_limb(zone)
		if(!limb)
			continue
		if(limb.status & LIMB_DESTROYED)
			continue
		limb_candidates += limb

	if(!length(limb_candidates))
		return null

	var/obj/limb/selected_limb = pick(limb_candidates)
	selected_limb.droplimb(FALSE, FALSE, cause)
	return selected_limb

/mob/living/carbon/human/proc/player_survival_apply_non_gib_fallback(datum/cause_data/cause, explosion_damage = null, explosion_severity = null, anti_gib_triggered = FALSE)
	if(!player_survival_is_protected_player())
		return FALSE

	if(!istype(cause))
		cause = create_cause_data("player survival anti-gib", src)
	last_damage_data = cause
	var/previous_health = health

	var/target_health = HEALTH_THRESHOLD_CRIT - 5
	if(health > target_health)
		var/required_damage = health - target_health
		take_overall_damage(required_damage, 0, "Explosive Blast", 100)

	if(health > HEALTH_THRESHOLD_CRIT)
		adjustOxyLoss((health - HEALTH_THRESHOLD_CRIT) + 1)
		updatehealth()

	KnockDown(1 SECONDS)
	Stun(1 SECONDS)
	KnockOut(0.5 SECONDS)

	var/obj/limb/detached_limb = null
	if(anti_gib_triggered && prob(30))
		detached_limb = player_survival_detach_random_extremity(cause)

	if(health <= HEALTH_THRESHOLD_CRIT)
		player_survival_activate_crit_grace()

	player_survival_log_antigib_fallback(cause, explosion_damage, explosion_severity, anti_gib_triggered, detached_limb, previous_health)

	return TRUE
