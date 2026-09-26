#define FACTION_MUSIC_KEY_USCM "USCM"
#define FACTION_MUSIC_KEY_ODST "ODST"
#define FACTION_MUSIC_KEY_UNSC "UNSC"
#define FACTION_MUSIC_KEY_UPP "UPP"
#define FACTION_MUSIC_KEY_WY "WY"
#define FACTION_MUSIC_KEY_COLONIAL_MILITIA "COLONIAL_MILITIA"
#define FACTION_MUSIC_KEY_CLF "CLF"
#define FACTION_MUSIC_KEY_PMC "PMC"

/// Returns the stable music key for the character's assigned role.
/proc/get_faction_music_key(mob/living/carbon/human/character)
	if(!character)
		return null
	return get_faction_music_key_for_values(character.job, character.faction)

/// Pure value resolver kept separate so role mapping can be regression-tested without creating a mob.
/proc/get_faction_music_key_for_values(job, faction)
	if(job in JOB_HALO_ODST_SHIPSIDE_LIST)
		return FACTION_MUSIC_KEY_ODST
	if(job in UACG_JOB_LIST)
		return FACTION_MUSIC_KEY_COLONIAL_MILITIA

	switch(faction)
		if(FACTION_MARINE)
			return FACTION_MUSIC_KEY_USCM
		// DemonicLynx for BandaMarines: UNSC Marines and UNSC Navy/crew share the UNSC playlist; ODST was resolved above.
		if(FACTION_UNSC, FACTION_UNSCN)
			return FACTION_MUSIC_KEY_UNSC
		if(FACTION_UPP)
			return FACTION_MUSIC_KEY_UPP
		if(FACTION_WY, FACTION_WY_DEATHSQUAD, FACTION_CONTRACTOR)
			return FACTION_MUSIC_KEY_WY
		if(FACTION_UACG)
			return FACTION_MUSIC_KEY_COLONIAL_MILITIA
		if(FACTION_CLF)
			return FACTION_MUSIC_KEY_CLF
		if(FACTION_PMC)
			return FACTION_MUSIC_KEY_PMC

	return null

/// Returns only the tracks assigned to this faction key. Empty factions intentionally stay silent.
/proc/get_faction_music_tracks(music_key)
	if(!music_key)
		return
	return GLOB.faction_music_tracks[music_key]

/// Plays one private streamed track after equipment has assigned job and faction data.
/proc/play_faction_music(mob/living/carbon/human/character)
	var/client/player_client = character?.client
	if(!player_client?.prefs)
		return FALSE

	var/music_key = get_faction_music_key(character)
	var/list/tracks = get_faction_music_tracks(music_key)
	if(!length(tracks))
		return FALSE

	var/sound/faction_music = sound(pick(tracks), channel = SOUND_CHANNEL_MUSIC)
	faction_music.status = SOUND_STREAM
	faction_music.volume = player_client.prefs.volume_preferences[VOLUME_MUSIC] * 100
	sound_to(player_client, faction_music)
	return TRUE

/client/proc/stop_faction_music_playback()
	src << sound(null, channel = SOUND_CHANNEL_MUSIC)

/client/verb/adjust_volume_faction_music()
	set name = "Adjust Volume Faction Music"
	set category = "Preferences.Sound"
	adjust_volume_prefs(VOLUME_MUSIC, "Set the volume for faction music", SOUND_CHANNEL_MUSIC)

/client/verb/stop_faction_music()
	set name = "Stop Faction Music"
	set category = "Preferences.Sound"
	stop_faction_music_playback()

#undef FACTION_MUSIC_KEY_USCM
#undef FACTION_MUSIC_KEY_ODST
#undef FACTION_MUSIC_KEY_UNSC
#undef FACTION_MUSIC_KEY_UPP
#undef FACTION_MUSIC_KEY_WY
#undef FACTION_MUSIC_KEY_COLONIAL_MILITIA
#undef FACTION_MUSIC_KEY_CLF
#undef FACTION_MUSIC_KEY_PMC
