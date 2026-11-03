#ifdef UNIT_TESTS
// No client/savefile/random-name setup is needed for pure preference contracts.
/datum/preferences/lobby_ui_test/New()
	return

// The production preferences Del intentionally crashes; this fixture is disposable.
/datum/preferences/lobby_ui_test/Del()
	return

// Count attempts without constructing a mob while simulating server startup.
/datum/preferences/lobby_ui_test/preview
	var/preview_updates = 0

/datum/preferences/lobby_ui_test/preview/update_preview_icon(refresh_limb_status)
	preview_updates++

/datum/unit_test/lobby_ui_preview_startup/Run()
	var/datum/preferences/lobby_ui_test/preview/preferences = allocate(/datum/preferences/lobby_ui_test/preview)
	var/original_state = SSticker.current_state
	SSticker.current_state = GAME_STATE_STARTUP
	var/startup_ready = preferences.ensure_banda_character_preview()
	var/startup_updates = preferences.preview_updates
	SSticker.current_state = GAME_STATE_PREGAME
	var/missing_preview_ready = preferences.ensure_banda_character_preview()
	SSticker.current_state = original_state // Restore before any assertion can return.

	TEST_ASSERT(!startup_ready && !startup_updates, "Early login must not construct a preview before pregame")
	TEST_ASSERT_EQUAL(preferences.preview_updates, 1, "Ready server must allow the existing preview renderer")
	TEST_ASSERT(!missing_preview_ready && isnull(preferences.banda_preview_signature), "Unsuccessful preview must not be cached as current")
	TEST_ASSERT(!length(preferences.banda_preview_assets), "Failed preview must not publish an image")

/datum/unit_test/lobby_ui_terminal/Run()
	var/datum/preferences/lobby_ui_test/interface_preferences = allocate(/datum/preferences/lobby_ui_test)
	TEST_ASSERT_EQUAL(interface_preferences.banda_menu_interface, BANDA_MENU_INTERFACE_TERMINAL, "Terminal interface must be the default")
	var/savefile/interface_save = new()
	interface_preferences.set_banda_menu_interface(BANDA_MENU_INTERFACE_CLASSIC)
	interface_preferences.save_banda_menu_interface(interface_save)
	var/datum/preferences/lobby_ui_test/interface_loaded = allocate(/datum/preferences/lobby_ui_test)
	interface_loaded.load_banda_menu_interface(interface_save)
	TEST_ASSERT_EQUAL(interface_loaded.banda_menu_interface, BANDA_MENU_INTERFACE_CLASSIC, "Explicit Classic choice must survive preference reload")
	interface_preferences.set_banda_menu_interface(BANDA_MENU_INTERFACE_TERMINAL)
	interface_preferences.save_banda_menu_interface(interface_save)
	interface_loaded.set_banda_menu_interface(BANDA_MENU_INTERFACE_CLASSIC)
	interface_loaded.load_banda_menu_interface(interface_save)
	TEST_ASSERT_EQUAL(interface_loaded.banda_menu_interface, BANDA_MENU_INTERFACE_TERMINAL, "Explicit Terminal choice must survive preference reload")
	interface_save["banda_menu_interface"] << null
	interface_loaded.set_banda_menu_interface(BANDA_MENU_INTERFACE_CLASSIC)
	interface_loaded.load_banda_menu_interface(interface_save)
	TEST_ASSERT_EQUAL(interface_loaded.banda_menu_interface, BANDA_MENU_INTERFACE_TERMINAL, "Missing choice must default to Terminal")
	interface_save["banda_menu_interface"] << "invalid"
	interface_loaded.set_banda_menu_interface(BANDA_MENU_INTERFACE_CLASSIC)
	interface_loaded.load_banda_menu_interface(interface_save)
	TEST_ASSERT_EQUAL(interface_loaded.banda_menu_interface, BANDA_MENU_INTERFACE_TERMINAL, "Invalid choice must default to Terminal")

	var/datum/preferences/lobby_ui_test/category_preferences = allocate(/datum/preferences/lobby_ui_test)
	TEST_ASSERT(!category_preferences.banda_category_blocks, "Category cards must default off")
	category_preferences.toggle_banda_category_blocks()
	var/savefile/category_save = new()
	category_preferences.save_banda_menu_interface(category_save)
	var/datum/preferences/lobby_ui_test/category_loaded = allocate(/datum/preferences/lobby_ui_test)
	category_loaded.load_banda_menu_interface(category_save)
	TEST_ASSERT(category_loaded.banda_category_blocks, "Category cards must survive preference reload")
	category_loaded.reset_banda_terminal_settings()
	TEST_ASSERT(!category_loaded.banda_category_blocks, "Personal interface reset must disable category cards")
	category_save["banda_category_blocks"] << null
	category_loaded.banda_category_blocks = TRUE
	category_loaded.load_banda_menu_interface(category_save)
	TEST_ASSERT(!category_loaded.banda_category_blocks, "Older saves must retain the existing layout")
	category_save["banda_category_blocks"] << "invalid"
	category_loaded.load_banda_menu_interface(category_save)
	TEST_ASSERT(!category_loaded.banda_category_blocks, "Invalid category setting must default off")
	var/datum/preferences/lobby_ui_test/preferences = allocate(/datum/preferences/lobby_ui_test)
	preferences.real_name = "Марк Смит"
	preferences.update_banda_character_feedback()
	TEST_ASSERT(!preferences.banda_terminal_dirty, "Initial terminal state must be clean")
	preferences.real_name = "Марк Иванов"
	preferences.update_banda_character_feedback()
	TEST_ASSERT(preferences.banda_terminal_dirty, "Actual slot edits must set dirty")
	preferences.save_character() // No path: the unchanged persistence layer rejects this.
	TEST_ASSERT(preferences.banda_terminal_dirty && !preferences.banda_terminal_notice, "Failed save must not report success")
	preferences.real_name = "Марк Смит"
	preferences.update_banda_character_feedback()
	TEST_ASSERT(!preferences.banda_terminal_dirty, "Reverting the value must clear dirty")

	var/long_record = ""
	for(var/index in 1 to MAX_RECORDS_MESSAGE_LEN + 1)
		long_record += "Я"
	TEST_ASSERT(preferences.save_banda_record_editor("med_record", long_record), "Valid record must be accepted")
	TEST_ASSERT_EQUAL(length_char(html_decode(preferences.med_record)), MAX_RECORDS_MESSAGE_LEN, "Cyrillic limit must count characters, not bytes")
	TEST_ASSERT(!preferences.save_banda_record_editor("real_name", "Injected"), "Record editor must reject unrelated fields")
	TEST_ASSERT_EQUAL(preferences.real_name, "Марк Смит", "Rejected key must preserve the character")

	var/signature = preferences.get_banda_preview_signature()
	preferences.r_eyes = (preferences.r_eyes + 1) % 256
	TEST_ASSERT_NOTEQUAL(preferences.get_banda_preview_signature(), signature, "Eye color must invalidate portrait cache")
	signature = preferences.get_banda_preview_signature()
	preferences.r_gradient = (preferences.r_gradient + 1) % 256
	TEST_ASSERT_NOTEQUAL(preferences.get_banda_preview_signature(), signature, "Hair gradient must invalidate portrait cache")

	preferences.banda_terminal_interface_color = "#e0bd44"
	preferences.banda_terminal_text_color = "#eeeeee"
	var/base_typography = preferences.apply_banda_terminal_typography(".probe { font-size: 10px; line-height: 12px; }")
	var/lobby_typography = preferences.apply_banda_terminal_typography(".probe { font-size: 10px; line-height: 12px; }", preferences.get_banda_terminal_font_size_offset("lobby"))
	var/dossier_typography = preferences.apply_banda_terminal_typography(".probe { font-size: 10px/*banda-no-lobby-offset*/; line-height: 12px/*banda-no-lobby-offset*/; }", preferences.get_banda_terminal_font_size_offset("lobby"))
	TEST_ASSERT(findtext(base_typography, "font-size: 10px !important") && findtext(base_typography, "line-height: 12px !important"), "Non-lobby typography must retain its existing scale")
	TEST_ASSERT(findtext(lobby_typography, "font-size: 13px !important") && findtext(lobby_typography, "line-height: 15px !important"), "Main lobby typography must add exactly three pixels after scaling")
	TEST_ASSERT(findtext(dossier_typography, "font-size: 10px !important") && findtext(dossier_typography, "line-height: 12px !important"), "Marked dossier declarations must opt out of only the lobby presentation offset")
	var/original_font_size = preferences.banda_terminal_font_size
	preferences.banda_terminal_font_size = 20
	var/capped_dossier_typography = preferences.apply_banda_terminal_typography(".probe { font-size: 13px/*banda-no-lobby-offset-cap14*/; line-height: 17px/*banda-no-lobby-offset-cap14*/; }", preferences.get_banda_terminal_font_size_offset("lobby"))
	TEST_ASSERT(findtext(capped_dossier_typography, "font-size: 13px !important") && findtext(capped_dossier_typography, "line-height: 17px !important"), "Dossier information must stay capped at the standard compact size")
	preferences.banda_terminal_font_size = original_font_size
	TEST_ASSERT_EQUAL(preferences.get_banda_terminal_font_size_offset("character"), 0, "Character editor typography must not receive the lobby boost")
	preferences.banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
	TEST_ASSERT(preferences.uses_banda_terminal_decorative_effects(), "Full effects must retain decorative server sequences")
	preferences.banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_REDUCED
	TEST_ASSERT(!preferences.uses_banda_terminal_decorative_effects(), "Reduced effects must suppress decorative server sequences")
	preferences.banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_OFF
	TEST_ASSERT(!preferences.uses_banda_terminal_decorative_effects(), "Off effects must suppress decorative server sequences")
	for(var/sheet in list("character", "auxiliary", "picker", "loadout", "manifest", "lobby"))
		var/key = preferences.get_banda_terminal_stylesheet_key(sheet)
		var/datum/asset_cache_item/asset = SSassets.cache[key]
		var/css = file2text(asset.resource)
		TEST_ASSERT(length(css) && !findtext(css, "var(--banda-"), "Browser CSS must contain resolved colors, including on Trident")
		TEST_ASSERT_EQUAL(preferences.get_banda_terminal_stylesheet_key(sheet), key, "Unchanged palette must reuse cached CSS")

	var/datum/modpack/provider = SSmodpacks.lobby_ui_provider
	TEST_ASSERT_NOTNULL(provider, "Enabled module must have its provider")
	preferences.real_name = "Новый Слот"
	provider.lobby_ui_character_persisted(preferences, "save")
	preferences.update_banda_character_feedback()
	TEST_ASSERT(!preferences.banda_terminal_dirty, "Successful persistence must capture the current slot state")
	preferences.banda_menu_interface = BANDA_MENU_INTERFACE_CLASSIC
	preferences.banda_terminal_notice = "unchanged"
	provider.lobby_ui_character_persisted(preferences, "reload")
	TEST_ASSERT_EQUAL(preferences.banda_terminal_notice, "unchanged", "Persistence presentation hook must ignore the classic editor")

#ifdef LOBBY_UI_REGRESSION_TEST
TEST_FOCUS(/datum/unit_test/lobby_ui_terminal)
#endif
#endif
