#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/localized_warcry_sounds/Run()
	var/mob/living/carbon/human/test_human = new(locate(1, 1, 1))
	var/datum/emote/living/carbon/human/warcry/test_warcry = new
	for(var/language in list(LANGUAGE_RUSSIAN, LANGUAGE_PORTUGUESE, LANGUAGE_SPANISH, LANGUAGE_POLISH, LANGUAGE_RUSPATOIS, LANGUAGE_GERMAN, LANGUAGE_SCANDINAVIAN))
		test_human.set_languages(list(language))
		test_human.gender = MALE
		var/male_sound = test_warcry.get_language_warcry_sound(test_human)
		test_human.gender = FEMALE
		var/female_sound = test_warcry.get_language_warcry_sound(test_human)
		if(!male_sound || !female_sound || male_sound == female_sound)
			return Fail("[language] has no distinct male and female warcry sounds", __FILE__, __LINE__)
	test_human.set_languages(list(LANGUAGE_ENGLISH))
	if(test_warcry.get_language_warcry_sound(test_human))
		return Fail("Unsupported language overrides the existing warcry", __FILE__, __LINE__)
	qdel(test_warcry)
	qdel(test_human)
#endif
