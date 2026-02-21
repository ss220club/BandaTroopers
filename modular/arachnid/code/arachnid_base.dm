// Ключи событий модульной аудиосистемы.
#define ARACHNID_SOUND_EVENT_SPEAKING "speaking"
#define ARACHNID_SOUND_EVENT_EMOTE "emote"
#define ARACHNID_SOUND_EVENT_COMBAT "combat"
#define ARACHNID_SOUND_EVENT_SPAWN "spawn"
#define ARACHNID_SOUND_EVENT_PRIME "prime"
#define ARACHNID_SOUND_EVENT_POUNCE "pounce"
#define ARACHNID_SOUND_EVENT_DEATH "death"

// Технические константы общего выбора.
#define ARACHNID_RANDOM_ROLL_MIN 1
#define ARACHNID_VISIBLE_MESSAGE_RANGE_CLOSE 5

// Ключи записи метаданных звука.
#define ARACHNID_SOUND_META_PATH "path"
#define ARACHNID_SOUND_META_TIER "tier"
#define ARACHNID_SOUND_META_WEIGHT "weight"
#define ARACHNID_SOUND_META_COOLDOWN "cooldown"
#define ARACHNID_SOUND_META_CHANCE "chance"

// Категории длины/интенсивности звука.
#define ARACHNID_SOUND_TIER_SHORT 1
#define ARACHNID_SOUND_TIER_MEDIUM 2
#define ARACHNID_SOUND_TIER_LONG 3

// Вес выбора внутри одного банка.
#define ARACHNID_SOUND_WEIGHT_SHORT 100
#define ARACHNID_SOUND_WEIGHT_MEDIUM 40
#define ARACHNID_SOUND_WEIGHT_LONG 15

// Базовые кулдауны для tier-групп.
#define ARACHNID_SOUND_COOLDOWN_SHORT 3 SECONDS
#define ARACHNID_SOUND_COOLDOWN_MEDIUM 6 SECONDS
#define ARACHNID_SOUND_COOLDOWN_LONG 10 SECONDS

// Шансы воспроизведения (chance-gate) по типам событий.
#define ARACHNID_SOUND_CHANCE_SPEAKING_SHORT 25
#define ARACHNID_SOUND_CHANCE_SPEAKING_MEDIUM 15
#define ARACHNID_SOUND_CHANCE_SPEAKING_LONG 8
#define ARACHNID_SOUND_CHANCE_EMOTE_SHORT 25
#define ARACHNID_SOUND_CHANCE_EMOTE_MEDIUM 15
#define ARACHNID_SOUND_CHANCE_EMOTE_LONG 8
#define ARACHNID_SOUND_CHANCE_COMBAT_SHORT 20
#define ARACHNID_SOUND_CHANCE_COMBAT_MEDIUM 12
#define ARACHNID_SOUND_CHANCE_COMBAT_LONG 6
#define ARACHNID_SOUND_CHANCE_SPAWN 10
#define ARACHNID_SOUND_CHANCE_PRIME 25
#define ARACHNID_SOUND_CHANCE_POUNCE 100
#define ARACHNID_SOUND_CHANCE_DEATH 100

// Базовые уровни громкости.
#define ARACHNID_SOUND_VOLUME_DIVISOR 4
#define ARACHNID_SOUND_VOLUME_SPEAKING 25
#define ARACHNID_SOUND_VOLUME_SPAWN 45
#define ARACHNID_SOUND_VOLUME_COMBAT 45
#define ARACHNID_SOUND_VOLUME_BOMBARDIER_POUNCE 55
#define ARACHNID_SOUND_VOLUME_BOMBARDIER_PRIME 60

// Базовые кулдауны каналов событий.
#define ARACHNID_SOUND_COOLDOWN_SPEAKING_BASE 2 SECONDS
#define ARACHNID_SOUND_COOLDOWN_COMBAT_BASE 5 SECONDS

// Прочие шансы поведения арахнида.
#define ARACHNID_HISS_EMOTE_CHANCE 10
#define ARACHNID_COMBAT_SOUND_TRIGGER_CHANCE 8

// Ключевые механики бомбардира.
#define ARACHNID_BOMBARDIER_EXPLOSION_POWER 45
#define ARACHNID_BOMBARDIER_EXPLOSION_FALLOFF 15
#define ARACHNID_BOMBARDIER_POUNCE_RANGE 4
#define ARACHNID_BOMBARDIER_POUNCE_MISS_CHANCE 35
#define ARACHNID_BOMBARDIER_POUNCE_MISS_RADIUS 2
#define ARACHNID_BOMBARDIER_POUNCE_KNOCKDOWN_DURATION 1
#define ARACHNID_BOMBARDIER_DETONATION_DELAY 2.5 SECONDS
#define ARACHNID_BOMBARDIER_PIXEL_X_MIN -16
#define ARACHNID_BOMBARDIER_PIXEL_X_MAX 16
#define ARACHNID_BOMBARDIER_PIXEL_Y_MIN -8
#define ARACHNID_BOMBARDIER_PIXEL_Y_MAX 20

/mob/living/carbon/xenomorph
	var/next_modular_speaking_sound = 0

/// Возвращает банк метаданных для события (переопределяется в модуле арахнидов).
/mob/living/carbon/xenomorph/proc/get_sound_meta_bank(event_key, emote_key)
	return null

/// Безопасно извлекает путь к звуку из записи метаданных.
/mob/living/carbon/xenomorph/proc/get_sound_meta_path(list/meta_entry)
	if(islist(meta_entry))
		return meta_entry[ARACHNID_SOUND_META_PATH]
	return null

/// Безопасно извлекает tier звука из записи метаданных.
/mob/living/carbon/xenomorph/proc/get_sound_meta_tier(list/meta_entry)
	if(islist(meta_entry))
		return meta_entry[ARACHNID_SOUND_META_TIER]
	return ARACHNID_SOUND_TIER_SHORT

/// Возвращает вес выбора звука из записи метаданных.
/mob/living/carbon/xenomorph/proc/get_sound_meta_weight(list/meta_entry)
	if(islist(meta_entry) && !isnull(meta_entry[ARACHNID_SOUND_META_WEIGHT]))
		return meta_entry[ARACHNID_SOUND_META_WEIGHT]
	return ARACHNID_SOUND_WEIGHT_SHORT

/// Возвращает кулдаун для выбранного звука.
/mob/living/carbon/xenomorph/proc/get_sound_meta_cooldown(list/meta_entry, default_cooldown)
	return default_cooldown

/// Возвращает шанс воспроизведения для выбранного звука.
/mob/living/carbon/xenomorph/proc/get_sound_meta_chance(event_key, list/meta_entry)
	return 100

/// Ищет запись метаданных по пути к звуку.
/mob/living/carbon/xenomorph/proc/get_sound_meta_by_path(sound_path)
	return null

/// Выбирает звук по весу из банка метаданных или возвращает стандартный.
/mob/living/carbon/xenomorph/proc/pick_sound_meta_or_default(event_key, list/meta_bank, default_sound)
	if(!length(meta_bank))
		return default_sound

	var/total_weight = 0
	var/list/weighted_entries = list()
	for(var/list/meta_entry as anything in meta_bank)
		var/sound_path = get_sound_meta_path(meta_entry)
		if(!sound_path)
			continue
		var/weight = max(0, round(get_sound_meta_weight(meta_entry)))
		if(weight <= 0)
			continue
		weighted_entries += list(meta_entry)
		total_weight += weight

	if(total_weight <= 0 || !length(weighted_entries))
		return default_sound

	var/roll = rand(ARACHNID_RANDOM_ROLL_MIN, total_weight)
	var/current_weight = 0
	for(var/list/meta_entry as anything in weighted_entries)
		current_weight += max(0, round(get_sound_meta_weight(meta_entry)))
		if(roll <= current_weight)
			return get_sound_meta_path(meta_entry)

	return default_sound

/mob/living/carbon/xenomorph/arachnid
	var/next_combat_sound = 0
	var/sound_aliases_initialized = FALSE
	var/list/sound_meta_map = list()

	var/list/sound_meta_spawn = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#3_grind.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#4_chirps.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
	)
	var/list/sound_meta_speaking = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#4_rumbles.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#5.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#6.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#3_low_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#4_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
	)
	var/list/sound_meta_death = list(
		list(ARACHNID_SOUND_META_PATH = 'sound/voice/alien_death.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'sound/voice/alien_death2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	var/list/sound_meta_emote_roar = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#3_low_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#4_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#3_grind.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#4_chirps.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
	)
	var/list/sound_meta_emote_hiss = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#4_chirps.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#5.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#6.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	var/list/sound_meta_emote_growl = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#4_rumbles.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#8.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#3_low_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#4_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_5_sec_#3_grind.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_LONG),
	)
	var/list/sound_meta_emote_needshelp = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
	)
	var/list/sound_meta_combat_alert = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#4_rumbles.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#5.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#6.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#7.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_1_sec_#8.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#3_low_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/arachnid_roar_2_sec_#4_rumble.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_MEDIUM),
	)

	// Алиасы для обратной совместимости со старыми вызовами `sound_*`.
	var/list/sound_spawn = list()
	var/list/sound_speaking = list()
	var/list/sound_death = list()
	var/list/sound_emote_roar = list()
	var/list/sound_emote_hiss = list()
	var/list/sound_emote_growl = list()
	var/list/sound_emote_needshelp = list()
	var/list/sound_combat_alert = list()

/mob/living/carbon/xenomorph/arachnid/bombardier
	sound_meta_spawn = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_click.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	sound_meta_speaking = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_click.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_3.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	sound_meta_death = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_died.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	sound_meta_combat_alert = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_click.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_talk_3.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	var/list/sound_meta_bombardier_prime = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_prepare_before_boom.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)
	var/list/sound_meta_bombardier_pounce = list(
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_chirp_and_whoosh_1.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_chirp_and_whoosh_2.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
		list(ARACHNID_SOUND_META_PATH = 'modular/arachnid/sounds/bombardir/bombardir_click.ogg', ARACHNID_SOUND_META_TIER = ARACHNID_SOUND_TIER_SHORT),
	)

	// Алиасы для обратной совместимости со старыми вызовами `sound_*`.
	var/list/sound_bombardier_prime = list()
	var/list/sound_bombardier_pounce = list()

/// Преобразует банк метаданных в список путей (для совместимых алиасов).
/mob/living/carbon/xenomorph/arachnid/proc/sound_meta_to_paths(list/meta_bank)
	var/list/paths = list()
	for(var/list/meta_entry as anything in meta_bank)
		var/sound_path = get_sound_meta_path(meta_entry)
		if(sound_path)
			paths += sound_path
	return paths

/// Добавляет записи банка в кэш метаданных по ключу `path`.
/mob/living/carbon/xenomorph/arachnid/proc/add_sound_meta_bank_to_map(list/meta_bank)
	for(var/list/meta_entry as anything in meta_bank)
		var/sound_path = get_sound_meta_path(meta_entry)
		if(sound_path)
			sound_meta_map[sound_path] = meta_entry

/// Обновляет совместимые алиасы `sound_*` из банков метаданных.
/mob/living/carbon/xenomorph/arachnid/proc/rebuild_sound_path_aliases()
	sound_spawn = sound_meta_to_paths(sound_meta_spawn)
	sound_speaking = sound_meta_to_paths(sound_meta_speaking)
	sound_death = sound_meta_to_paths(sound_meta_death)
	sound_emote_roar = sound_meta_to_paths(sound_meta_emote_roar)
	sound_emote_hiss = sound_meta_to_paths(sound_meta_emote_hiss)
	sound_emote_growl = sound_meta_to_paths(sound_meta_emote_growl)
	sound_emote_needshelp = sound_meta_to_paths(sound_meta_emote_needshelp)
	sound_combat_alert = sound_meta_to_paths(sound_meta_combat_alert)

	sound_meta_map = list()
	var/list/all_meta_banks = list(
		sound_meta_spawn,
		sound_meta_speaking,
		sound_meta_death,
		sound_meta_emote_roar,
		sound_meta_emote_hiss,
		sound_meta_emote_growl,
		sound_meta_emote_needshelp,
		sound_meta_combat_alert,
	)
	for(var/list/bank as anything in all_meta_banks)
		add_sound_meta_bank_to_map(bank)

	sound_aliases_initialized = TRUE

/mob/living/carbon/xenomorph/arachnid/bombardier/rebuild_sound_path_aliases()
	..()
	sound_bombardier_prime = sound_meta_to_paths(sound_meta_bombardier_prime)
	sound_bombardier_pounce = sound_meta_to_paths(sound_meta_bombardier_pounce)
	add_sound_meta_bank_to_map(sound_meta_bombardier_prime)
	add_sound_meta_bank_to_map(sound_meta_bombardier_pounce)

/// Отложенная инициализация алиасов, чтобы не дублировать работу.
/mob/living/carbon/xenomorph/arachnid/proc/ensure_sound_aliases_initialized()
	if(!sound_aliases_initialized)
		rebuild_sound_path_aliases()

/// Подбирает корректный банк метаданных по событию и, при необходимости, ключу эмоута.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_bank(event_key, emote_key)
	ensure_sound_aliases_initialized()

	switch(event_key)
		if(ARACHNID_SOUND_EVENT_SPAWN)
			return sound_meta_spawn
		if(ARACHNID_SOUND_EVENT_SPEAKING)
			return sound_meta_speaking
		if(ARACHNID_SOUND_EVENT_DEATH)
			return sound_meta_death
		if(ARACHNID_SOUND_EVENT_COMBAT)
			return sound_meta_combat_alert
		if(ARACHNID_SOUND_EVENT_EMOTE)
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

/// Расширяет выбор банков звуков бомбардира специализированными событиями.
/mob/living/carbon/xenomorph/arachnid/bombardier/get_sound_meta_bank(event_key, emote_key)
	switch(event_key)
		if(ARACHNID_SOUND_EVENT_PRIME)
			return sound_meta_bombardier_prime
		if(ARACHNID_SOUND_EVENT_POUNCE)
			return sound_meta_bombardier_pounce
	return ..()

/// Поиск записи метаданных через кэш-карту `path -> meta_entry`.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_by_path(sound_path)
	if(!sound_path)
		return null
	ensure_sound_aliases_initialized()
	return sound_meta_map[sound_path]

/// Возвращает вес звука: либо явный в метаданных, либо дефолт для tier.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_weight(list/meta_entry)
	if(islist(meta_entry) && !isnull(meta_entry[ARACHNID_SOUND_META_WEIGHT]))
		return meta_entry[ARACHNID_SOUND_META_WEIGHT]

	switch(get_sound_meta_tier(meta_entry))
		if(ARACHNID_SOUND_TIER_LONG)
			return ARACHNID_SOUND_WEIGHT_LONG
		if(ARACHNID_SOUND_TIER_MEDIUM)
			return ARACHNID_SOUND_WEIGHT_MEDIUM
	return ARACHNID_SOUND_WEIGHT_SHORT

/// Возвращает tier записи метаданных с безопасным резервным значением.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_tier(list/meta_entry)
	if(islist(meta_entry) && !isnull(meta_entry[ARACHNID_SOUND_META_TIER]))
		return meta_entry[ARACHNID_SOUND_META_TIER]
	return ARACHNID_SOUND_TIER_SHORT

/// Возвращает кулдаун звука с учетом метаданных и tier-политики.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_cooldown(list/meta_entry, default_cooldown)
	if(islist(meta_entry) && !isnull(meta_entry[ARACHNID_SOUND_META_COOLDOWN]))
		return max(default_cooldown, meta_entry[ARACHNID_SOUND_META_COOLDOWN])

	switch(get_sound_meta_tier(meta_entry))
		if(ARACHNID_SOUND_TIER_LONG)
			return max(default_cooldown, ARACHNID_SOUND_COOLDOWN_LONG)
		if(ARACHNID_SOUND_TIER_MEDIUM)
			return max(default_cooldown, ARACHNID_SOUND_COOLDOWN_MEDIUM)
	return max(default_cooldown, ARACHNID_SOUND_COOLDOWN_SHORT)

/// Возвращает итоговый шанс воспроизведения по событию и tier.
/mob/living/carbon/xenomorph/arachnid/get_sound_meta_chance(event_key, list/meta_entry)
	if(islist(meta_entry) && !isnull(meta_entry[ARACHNID_SOUND_META_CHANCE]))
		return meta_entry[ARACHNID_SOUND_META_CHANCE]

	var/tier = get_sound_meta_tier(meta_entry)
	switch(event_key)
		if(ARACHNID_SOUND_EVENT_DEATH)
			return ARACHNID_SOUND_CHANCE_DEATH
		if(ARACHNID_SOUND_EVENT_POUNCE)
			return ARACHNID_SOUND_CHANCE_POUNCE
		if(ARACHNID_SOUND_EVENT_SPAWN)
			return ARACHNID_SOUND_CHANCE_SPAWN
		if(ARACHNID_SOUND_EVENT_PRIME)
			return ARACHNID_SOUND_CHANCE_PRIME
		if(ARACHNID_SOUND_EVENT_SPEAKING)
			switch(tier)
				if(ARACHNID_SOUND_TIER_LONG)
					return ARACHNID_SOUND_CHANCE_SPEAKING_LONG
				if(ARACHNID_SOUND_TIER_MEDIUM)
					return ARACHNID_SOUND_CHANCE_SPEAKING_MEDIUM
				else
					return ARACHNID_SOUND_CHANCE_SPEAKING_SHORT
		if(ARACHNID_SOUND_EVENT_EMOTE)
			switch(tier)
				if(ARACHNID_SOUND_TIER_LONG)
					return ARACHNID_SOUND_CHANCE_EMOTE_LONG
				if(ARACHNID_SOUND_TIER_MEDIUM)
					return ARACHNID_SOUND_CHANCE_EMOTE_MEDIUM
				else
					return ARACHNID_SOUND_CHANCE_EMOTE_SHORT
		if(ARACHNID_SOUND_EVENT_COMBAT)
			switch(tier)
				if(ARACHNID_SOUND_TIER_LONG)
					return ARACHNID_SOUND_CHANCE_COMBAT_LONG
				if(ARACHNID_SOUND_TIER_MEDIUM)
					return ARACHNID_SOUND_CHANCE_COMBAT_MEDIUM
				else
					return ARACHNID_SOUND_CHANCE_COMBAT_SHORT
	return ..()

/// Воспроизводит боевой звук арахнида через metadata-пайплайн.
/mob/living/carbon/xenomorph/arachnid/proc/play_combat_sound(volume = ARACHNID_SOUND_VOLUME_COMBAT, cooldown = ARACHNID_SOUND_COOLDOWN_COMBAT_BASE)
	var/list/combat_meta_bank = get_sound_meta_bank(ARACHNID_SOUND_EVENT_COMBAT, null)
	if(world.time < next_combat_sound || !length(combat_meta_bank))
		return FALSE

	var/combat_sound = pick_sound_meta_or_default(ARACHNID_SOUND_EVENT_COMBAT, combat_meta_bank, null)
	if(!combat_sound || !modular_should_play_sound(ARACHNID_SOUND_EVENT_COMBAT, combat_sound))
		return FALSE

	playsound(src, combat_sound, modular_get_sound_volume(volume), FALSE)
	var/list/combat_meta = get_sound_meta_by_path(combat_sound)
	next_combat_sound = world.time + get_sound_meta_cooldown(combat_meta, cooldown)
	return TRUE
