/// Возвращает итоговую громкость звука (может переопределяться модулем).
/mob/living/carbon/xenomorph/proc/modular_get_sound_volume(base_volume)
	return base_volume

/// Возвращает вес выбора для конкретного пути звука.
/mob/living/carbon/xenomorph/proc/modular_get_sound_pick_weight(sound_path)
	return ARACHNID_SOUND_WEIGHT_SHORT

/// Возвращает кулдаун звука для конкретного пути звука.
/mob/living/carbon/xenomorph/proc/modular_get_sound_cooldown(sound_path, default_cooldown)
	return default_cooldown

/// Возвращает шанс воспроизведения звука (0..100).
/mob/living/carbon/xenomorph/proc/modular_get_sound_play_chance(event_key, sound_path)
	return 100

/// Гейт воспроизведения: общий фильтр по шансам для события.
/mob/living/carbon/xenomorph/proc/modular_should_play_sound(event_key, sound_path)
	var/chance = clamp(round(modular_get_sound_play_chance(event_key, sound_path)), 0, 100)
	if(chance >= 100)
		return TRUE
	if(chance <= 0)
		return FALSE
	return prob(chance)

/// Выбирает звук из простого банка путей по весам.
/mob/living/carbon/xenomorph/proc/pick_weighted_sound(list/bank)
	if(!length(bank))
		return null

	var/total_weight = 0
	var/list/sound_weights = list()
	for(var/sound_path in bank)
		var/weight = max(0, modular_get_sound_pick_weight(sound_path))
		if(weight <= 0)
			continue
		sound_weights[sound_path] = weight
		total_weight += weight

	if(total_weight <= 0)
		return null

	var/roll = rand(ARACHNID_RANDOM_ROLL_MIN, total_weight)
	var/current_weight = 0
	for(var/sound_path in sound_weights)
		current_weight += sound_weights[sound_path]
		if(roll <= current_weight)
			return sound_path

	return null

/// Совместимый хелпер: выбрать звук из банка или вернуть стандартный.
/mob/living/carbon/xenomorph/proc/pick_sound_or_default(list/bank, default_sound)
	var/picked_sound = pick_weighted_sound(bank)
	return picked_sound ? picked_sound : default_sound

/// Совместимый контракт получения emote-банка (legacy-путь).
/mob/living/carbon/xenomorph/proc/get_emote_bank(emote_key)
	return null

/// Хук выбора звука речи.
/mob/living/carbon/xenomorph/proc/modular_sound_pick_speaking(default_sound)
	return default_sound

/// Хук выбора звука смерти.
/mob/living/carbon/xenomorph/proc/modular_sound_pick_death(default_sound)
	return default_sound

/// Хук выбора звука эмоута.
/mob/living/carbon/xenomorph/proc/modular_sound_pick_emote(emote_key, default_sound)
	return default_sound

/// Хук звука при спавне.
/mob/living/carbon/xenomorph/proc/modular_sound_on_spawn()
	return

/// Базовое воспроизведение голоса (резерв для не-арахнидов).
/mob/living/carbon/xenomorph/proc/modular_say()
	playsound(loc, speaking_noise, ARACHNID_SOUND_VOLUME_SPEAKING, TRUE)

/// Арахнид: снижает громкость через модульный делитель.
/mob/living/carbon/xenomorph/arachnid/modular_get_sound_volume(base_volume)
	return max(1, round(base_volume / ARACHNID_SOUND_VOLUME_DIVISOR))

/// Арахнид: получает веса из записи метаданных.
/mob/living/carbon/xenomorph/arachnid/modular_get_sound_pick_weight(sound_path)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	return get_sound_meta_weight(meta_entry)

/// Арахнид: получает кулдаун из записи метаданных.
/mob/living/carbon/xenomorph/arachnid/modular_get_sound_cooldown(sound_path, default_cooldown)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	return get_sound_meta_cooldown(meta_entry, default_cooldown)

/// Арахнид: получает шанс из записи метаданных.
/mob/living/carbon/xenomorph/arachnid/modular_get_sound_play_chance(event_key, sound_path)
	var/list/meta_entry = get_sound_meta_by_path(sound_path)
	return get_sound_meta_chance(event_key, meta_entry)

/// Совместимый emote-банк из алиасов sound_emote_*.
/mob/living/carbon/xenomorph/arachnid/get_emote_bank(emote_key)
	ensure_sound_aliases_initialized()
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

/// Выбор звука речи из банка метаданных арахнида.
/mob/living/carbon/xenomorph/arachnid/modular_sound_pick_speaking(default_sound)
	var/list/meta_bank = get_sound_meta_bank(ARACHNID_SOUND_EVENT_SPEAKING, null)
	return pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_SPEAKING, meta_bank, default_sound)

/// Выбор звука смерти из банка метаданных арахнида.
/mob/living/carbon/xenomorph/arachnid/modular_sound_pick_death(default_sound)
	var/list/meta_bank = get_sound_meta_bank(ARACHNID_SOUND_EVENT_DEATH, null)
	return pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_DEATH, meta_bank, default_sound)

/// Выбор звука эмоута из банка метаданных арахнида.
/mob/living/carbon/xenomorph/arachnid/modular_sound_pick_emote(emote_key, default_sound)
	var/list/meta_bank = get_sound_meta_bank(ARACHNID_SOUND_EVENT_EMOTE, emote_key)
	return pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_EMOTE, meta_bank, default_sound)

/// Спавн-звук арахнида с шанс-гейтом.
/mob/living/carbon/xenomorph/arachnid/modular_sound_on_spawn()
	var/list/meta_bank = get_sound_meta_bank(ARACHNID_SOUND_EVENT_SPAWN, null)
	var/spawn_sound = pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_SPAWN, meta_bank, null)
	if(spawn_sound && modular_should_play_sound(ARACHNID_SOUND_EVENT_SPAWN, spawn_sound))
		playsound(src, spawn_sound, modular_get_sound_volume(ARACHNID_SOUND_VOLUME_SPAWN), FALSE)

/// Речь арахнида: подбор из метаданных + chance-gate + кулдаун.
/mob/living/carbon/xenomorph/arachnid/modular_say()
	if(!speaking_noise || world.time < next_modular_speaking_sound)
		return

	var/speaking_sound = modular_sound_pick_speaking(speaking_noise)
	if(!speaking_sound)
		return

	if(!modular_should_play_sound(ARACHNID_SOUND_EVENT_SPEAKING, speaking_sound))
		return

	playsound(loc, speaking_sound, modular_get_sound_volume(ARACHNID_SOUND_VOLUME_SPEAKING), TRUE)
	var/list/speaking_meta = get_sound_meta_by_path(speaking_sound)
	next_modular_speaking_sound = world.time + get_sound_meta_cooldown(speaking_meta, ARACHNID_SOUND_COOLDOWN_SPEAKING_BASE)

/// Injection в xeno emote: модульная подмена/гейтинг/кулдаун для арахнидов.
/datum/emote/living/carbon/xeno/get_sound(mob/living/user)
	. = ..()
	if(ispredalien(user) && predalien_sound)
		. = predalien_sound
	if(islarva(user) && larva_sound)
		. = larva_sound

	var/base_volume = initial(volume)
	var/base_audio_cooldown = initial(audio_cooldown)
	volume = base_volume
	audio_cooldown = base_audio_cooldown

	var/mob/living/carbon/xenomorph/xeno_user = user
	if(!istype(xeno_user))
		return

	. = xeno_user.modular_sound_pick_emote(key, .)
	if(!.)
		return

	if(!xeno_user.modular_should_play_sound(ARACHNID_SOUND_EVENT_EMOTE, .))
		. = null
		return

	var/list/meta_entry = xeno_user.get_sound_meta_by_path(.)
	volume = xeno_user.modular_get_sound_volume(base_volume)
	audio_cooldown = xeno_user.get_sound_meta_cooldown(meta_entry, base_audio_cooldown)
