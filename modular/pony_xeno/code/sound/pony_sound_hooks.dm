/mob/living/carbon/xenomorph/pony/proc/rebuild_pony_sound_meta_map()
	sound_meta_map = list()
	var/list/all_banks = list(
		sound_meta_spawn,
		sound_meta_speaking,
		sound_meta_death,
		sound_meta_emote_roar,
		sound_meta_emote_hiss,
		sound_meta_emote_growl,
		sound_meta_emote_needshelp,
		sound_meta_combat_alert,
		sound_meta_magic
	)

	for(var/list/meta_bank as anything in all_banks)
		for(var/list/meta_entry as anything in meta_bank)
			var/sound_path = get_sound_meta_path(meta_entry)
			if(sound_path)
				sound_meta_map[sound_path] = meta_entry

/mob/living/carbon/xenomorph/pony/get_sound_meta_bank(event_key, emote_key)
	if(!sound_meta_map)
		rebuild_pony_sound_meta_map()

	switch(lowertext("[event_key]"))
		if(PONY_XENO_SOUND_EVENT_SPAWN)
			return sound_meta_spawn
		if(PONY_XENO_SOUND_EVENT_SPEAKING)
			return sound_meta_speaking
		if(PONY_XENO_SOUND_EVENT_DEATH)
			return sound_meta_death
		if(PONY_XENO_SOUND_EVENT_COMBAT)
			return sound_meta_combat_alert
		if(PONY_XENO_SOUND_EVENT_MAGIC)
			return sound_meta_magic
		if(PONY_XENO_SOUND_EVENT_EMOTE)
			switch(lowertext("[emote_key]"))
				if("roar")
					return sound_meta_emote_roar
				if("hiss")
					return sound_meta_emote_hiss
				if("growl")
					return sound_meta_emote_growl
				if("needshelp")
					return sound_meta_emote_needshelp
	return null

/mob/living/carbon/xenomorph/pony/get_sound_meta_by_path(sound_path)
	if(!sound_meta_map)
		rebuild_pony_sound_meta_map()
	return sound_meta_map[sound_path]

/mob/living/carbon/xenomorph/pony/modular_get_sound_volume(base_volume)
	return max(1, round(base_volume / PONY_XENO_SOUND_VOLUME_DIVISOR))

/mob/living/carbon/xenomorph/pony/modular_get_sound_pick_weight(sound_path)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	return get_sound_meta_weight(meta_entry)

/mob/living/carbon/xenomorph/pony/modular_get_sound_cooldown(sound_path, default_cooldown)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	return get_sound_meta_cooldown(meta_entry, default_cooldown)

/mob/living/carbon/xenomorph/pony/modular_get_sound_play_chance(event_key, sound_path)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	if(!islist(meta_entry))
		return 100

	switch(lowertext("[event_key]"))
		if(PONY_XENO_SOUND_EVENT_COMBAT)
			switch(get_sound_meta_tier(meta_entry))
				if(PONY_XENO_SOUND_TIER_LONG)
					return 15
				if(PONY_XENO_SOUND_TIER_MEDIUM)
					return 22
				else
					return 35
		if(PONY_XENO_SOUND_EVENT_SPEAKING, PONY_XENO_SOUND_EVENT_EMOTE)
			switch(get_sound_meta_tier(meta_entry))
				if(PONY_XENO_SOUND_TIER_LONG)
					return 8
				if(PONY_XENO_SOUND_TIER_MEDIUM)
					return 16
				else
					return 28
		if(PONY_XENO_SOUND_EVENT_MAGIC)
			return 60
	return 100

/mob/living/carbon/xenomorph/pony/get_emote_bank(emote_key)
	switch(lowertext("[emote_key]"))
		if("roar")
			return sound_emote_roar
		if("hiss")
			return sound_emote_hiss
		if("growl")
			return sound_emote_growl
		if("needshelp")
			return sound_emote_needshelp
	return null

/mob/living/carbon/xenomorph/pony/modular_sound_pick_speaking(default_sound)
	return pick_sound_meta_or_default(PONY_XENO_SOUND_EVENT_SPEAKING, get_sound_meta_bank(PONY_XENO_SOUND_EVENT_SPEAKING, null), default_sound)

/mob/living/carbon/xenomorph/pony/modular_sound_pick_death(default_sound)
	return pick_sound_meta_or_default(PONY_XENO_SOUND_EVENT_DEATH, get_sound_meta_bank(PONY_XENO_SOUND_EVENT_DEATH, null), default_sound)

/mob/living/carbon/xenomorph/pony/modular_sound_pick_emote(emote_key, default_sound)
	return pick_sound_meta_or_default(PONY_XENO_SOUND_EVENT_EMOTE, get_sound_meta_bank(PONY_XENO_SOUND_EVENT_EMOTE, emote_key), default_sound)

/mob/living/carbon/xenomorph/pony/modular_sound_on_spawn()
	var/spawn_sound = pick_sound_meta_or_default(PONY_XENO_SOUND_EVENT_SPAWN, get_sound_meta_bank(PONY_XENO_SOUND_EVENT_SPAWN, null), null)
	if(spawn_sound && modular_should_play_sound(PONY_XENO_SOUND_EVENT_SPAWN, spawn_sound))
		playsound(src, spawn_sound, modular_get_sound_volume(PONY_XENO_SOUND_VOLUME_SPAWN), FALSE)

/mob/living/carbon/xenomorph/pony/modular_say()
	if(!speaking_noise || world.time < next_modular_speaking_sound)
		return

	var/speaking_sound = modular_sound_pick_speaking(speaking_noise)
	if(!speaking_sound || !modular_should_play_sound(PONY_XENO_SOUND_EVENT_SPEAKING, speaking_sound))
		return

	playsound(loc, speaking_sound, modular_get_sound_volume(PONY_XENO_SOUND_VOLUME_SPEAKING), TRUE)
	var/list/meta_entry = get_sound_meta_by_path(speaking_sound)
	next_modular_speaking_sound = world.time + get_sound_meta_cooldown(meta_entry, PONY_XENO_SOUND_COOLDOWN_SPEAKING)

/mob/living/carbon/xenomorph/pony/proc/play_combat_sound(volume = PONY_XENO_SOUND_VOLUME_COMBAT, cooldown = PONY_XENO_SOUND_COOLDOWN_COMBAT)
	var/list/combat_meta_bank = get_sound_meta_bank(PONY_XENO_SOUND_EVENT_COMBAT, null)
	if(world.time < next_pony_combat_sound || !length(combat_meta_bank))
		return FALSE

	var/combat_sound = pick_sound_meta_or_default(PONY_XENO_SOUND_EVENT_COMBAT, combat_meta_bank, null)
	if(!combat_sound || !modular_should_play_sound(PONY_XENO_SOUND_EVENT_COMBAT, combat_sound))
		return FALSE

	playsound(src, combat_sound, modular_get_sound_volume(volume), FALSE)
	var/list/combat_meta = get_sound_meta_by_path(combat_sound)
	next_pony_combat_sound = world.time + get_sound_meta_cooldown(combat_meta, cooldown)
	return TRUE
