/datum/unit_test/admin_music
	var/datum/admin_music_service/service
	var/list/temp_paths

/datum/unit_test/admin_music/Run()
	return

/datum/unit_test/admin_music/New()
	. = ..()
	service = new /datum/admin_music_service
	service.preset_library.reset_cache(TRUE)
	temp_paths = list()

/datum/unit_test/admin_music/Destroy()
	for(var/path in temp_paths)
		fdel(path)
	service = null
	temp_paths = null
	return ..()

/datum/unit_test/admin_music/proc/build_valid_preset(preset_name = "Admin Music Test")
	var/datum/admin_music_preset/preset = service.build_default_preset()
	preset.name = preset_name
	preset.description = "Unit test preset"
	preset.audience_mode = "global"
	preset.sound_type = "atmospheric"
	preset.show_title_to_players = TRUE
	preset.repeat = TRUE

	var/datum/admin_music_tier/tier = preset.tiers[1]
	tier.name = "Tier Alpha"
	tier.description = "Primary tier"

	var/datum/admin_music_variant/variant = tier.variants[1]
	variant.title = "Track Alpha"
	variant.description = "Primary track"
	variant.duration_seconds = 42
	variant.source_url = "https://example.com/alpha"
	return preset

/datum/unit_test/admin_music/proc/list_contains_text(list/haystack, needle)
	for(var/entry as anything in haystack)
		if(findtext("[entry]", needle))
			return TRUE
	return FALSE

/datum/unit_test/admin_music_json_round_trip
	parent_type = /datum/unit_test/admin_music

/datum/unit_test/admin_music_json_round_trip/Run()
	var/datum/admin_music_preset/preset = build_valid_preset("Round Trip")
	var/datum/admin_music_tier/second_tier = service.build_default_tier()
	second_tier.name = "Tier Beta"
	second_tier.description = "Secondary tier"
	var/datum/admin_music_variant/second_variant = second_tier.variants[1]
	second_variant.title = "Track Beta"
	second_variant.description = "Secondary track"
	second_variant.duration_seconds = 75
	second_variant.source_url = "https://example.com/beta"
	preset.tiers += second_tier

	var/list/parse_result = service.parse_preset_json_text(json_encode(preset.to_json_data()), "round_trip")
	var/list/errors = parse_result["errors"]
	TEST_ASSERT(!length(errors), "Round-trip preset parsing produced validation errors.")

	var/datum/admin_music_preset/parsed = parse_result["preset"]
	TEST_ASSERT_NOTNULL(parsed, "Round-trip preset parsing did not return a preset.")
	TEST_ASSERT_EQUAL(parsed.preset_id, "round_trip", "Preset id override did not survive parse.")
	TEST_ASSERT_EQUAL(parsed.name, preset.name, "Preset name changed after round-trip parse.")
	TEST_ASSERT_EQUAL(length(parsed.tiers), 2, "Round-trip parse lost preset tiers.")
	TEST_ASSERT_EQUAL(parsed.count_variants(), 2, "Round-trip parse lost preset variants.")
	TEST_ASSERT(parsed.show_title_to_players, "Round-trip parse changed show-title state.")
	TEST_ASSERT(parsed.repeat, "Round-trip parse changed repeat state.")

/datum/unit_test/admin_music_json_defaults
	parent_type = /datum/unit_test/admin_music

/datum/unit_test/admin_music_json_defaults/Run()
	var/datum/admin_music_preset/preset = build_valid_preset("Defaults")
	var/list/json_data = preset.to_json_data()
	json_data["playback"] = list(
		"audience_mode" = "global",
		"sound_type" = "atmospheric",
	)

	var/list/parse_result = service.parse_preset_json_text(json_encode(json_data), "defaults")
	var/list/errors = parse_result["errors"]
	TEST_ASSERT(!length(errors), "Preset parsing rejected a JSON object with omitted show-title flag.")

	var/datum/admin_music_preset/parsed = parse_result["preset"]
	TEST_ASSERT_NOTNULL(parsed, "Preset parsing returned no preset for defaulted show-title state.")
	TEST_ASSERT(parsed.show_title_to_players, "Omitted show-title flag should preserve the TRUE default.")
	TEST_ASSERT(!parsed.repeat, "Omitted repeat flag should preserve the FALSE default.") // SS220 EDIT: new admin-music presets no longer repeat by default

	json_data["version"] = 2
	parse_result = service.parse_preset_json_text(json_encode(json_data), "bad_version")
	errors = parse_result["errors"]
	TEST_ASSERT(length(errors), "Preset parsing accepted an unsupported schema version.")
	TEST_ASSERT(list_contains_text(errors, "version must be 1"), "Version error message was not returned for unsupported schema version.")

/datum/unit_test/admin_music_validation
	parent_type = /datum/unit_test/admin_music

/datum/unit_test/admin_music_validation/Run()
	var/datum/admin_music_preset/preset = build_valid_preset("Validation")
	preset.name = " "

	var/datum/admin_music_tier/duplicate_tier = service.build_default_tier()
	duplicate_tier.name = "tier alpha"
	duplicate_tier.description = "Duplicate"
	var/datum/admin_music_variant/duplicate_variant = duplicate_tier.variants[1]
	duplicate_variant.title = "Track Duplicate"
	duplicate_variant.description = "Duplicate variant"
	duplicate_variant.duration_seconds = 10
	duplicate_variant.source_url = "ftp://example.com/not-allowed"
	preset.tiers += duplicate_tier

	var/list/errors = service.validate_preset(preset)
	TEST_ASSERT(length(errors) >= 3, "Preset validation did not report all expected failures.")
	TEST_ASSERT(list_contains_text(errors, "Preset name cannot be empty"), "Preset validation did not reject an empty preset name.")
	TEST_ASSERT(list_contains_text(errors, "Tier names must be unique"), "Preset validation did not reject duplicate tier names.")
	TEST_ASSERT(list_contains_text(errors, "http or https"), "Preset validation did not reject a non-http variant source URL.")

/datum/unit_test/admin_music_merge_and_save
	parent_type = /datum/unit_test/admin_music

/datum/unit_test/admin_music_merge_and_save/Run()
	var/datum/admin_music_preset/existing = build_valid_preset("Merge Test")
	var/datum/admin_music_preset/saved_existing = service.save_draft(null, existing, FALSE)
	TEST_ASSERT_NOTNULL(saved_existing, "Initial preset save failed.")
	temp_paths += service.get_preset_path(saved_existing.preset_id)

	var/datum/admin_music_preset/loaded_existing = service.load_preset_from_file(service.get_preset_path(saved_existing.preset_id), saved_existing.preset_id)
	TEST_ASSERT_NOTNULL(loaded_existing, "Saved preset could not be loaded back from disk.")
	TEST_ASSERT_EQUAL(loaded_existing.name, saved_existing.name, "Loaded preset name drifted after save/load.")

	var/datum/admin_music_preset/imported = build_valid_preset("Merge Test")
	var/datum/admin_music_tier/imported_tier = imported.tiers[1]
	imported_tier.name = " tier alpha "
	var/datum/admin_music_variant/imported_base_variant = imported_tier.variants[1]
	imported_base_variant.source_url = " https://example.com/alpha "

	var/datum/admin_music_variant/new_variant = service.build_default_variant()
	new_variant.title = "Track Gamma"
	new_variant.description = "New merged track"
	new_variant.duration_seconds = 99
	new_variant.source_url = "https://example.com/gamma"
	imported_tier.variants += new_variant

	var/datum/admin_music_tier/new_tier = service.build_default_tier()
	new_tier.name = "Tier Omega"
	new_tier.description = "Merged tier"
	var/datum/admin_music_variant/new_tier_variant = new_tier.variants[1]
	new_tier_variant.title = "Track Omega"
	new_tier_variant.description = "Merged tier track"
	new_tier_variant.duration_seconds = 120
	new_tier_variant.source_url = "https://example.com/omega"
	imported.tiers += new_tier

	var/datum/admin_music_preset/merged = service.merge_imported_preset(saved_existing.copy(), imported)
	TEST_ASSERT_EQUAL(length(merged.tiers), 2, "Preset merge did not keep one existing tier and one new tier.")

	var/datum/admin_music_tier/alpha_tier = merged.tiers[1]
	TEST_ASSERT_EQUAL(length(alpha_tier.variants), 2, "Preset merge did not deduplicate variants by trimmed source URL.")

	var/datum/admin_music_preset/copied = service.save_draft(null, saved_existing.copy(), TRUE)
	TEST_ASSERT_NOTNULL(copied, "Save As Copy failed for a valid preset.")
	temp_paths += service.get_preset_path(copied.preset_id)
	TEST_ASSERT_EQUAL(copied.name, "Merge Test (2)", "Save As Copy did not assign the expected copy name.")
	TEST_ASSERT_EQUAL(copied.preset_id, service.build_preset_slug("Merge Test (2)"), "Save As Copy did not assign the expected preset id.")

/datum/unit_test/admin_music_panel_variant_action_targets
	parent_type = /datum/unit_test/admin_music

/datum/unit_test/admin_music_panel_variant_action_targets/Run()
	var/datum/admin_music_panel/panel = allocate(/datum/admin_music_panel, null)
	var/datum/admin_music_preset/preset = build_valid_preset("Panel Targeting")
	var/datum/admin_music_tier/tier = preset.tiers[1]
	var/datum/admin_music_variant/first_variant = tier.variants[1]
	var/second_variant_original_title = "Track Beta"
	var/second_variant_original_duration = 42

	var/datum/admin_music_variant/second_variant = service.build_default_variant()
	second_variant.title = second_variant_original_title
	second_variant.description = "Second track"
	second_variant.duration_seconds = second_variant_original_duration
	second_variant.source_url = "https://example.com/beta"
	tier.variants += second_variant

	panel.draft = preset
	panel.selected_tier_id = REF(tier)
	panel.selected_variant_id = REF(second_variant)
	panel.sync_selection()

	var/title_action_result = panel.handle_variant_action("set_variant_title", list(
		"tier_id" = REF(tier),
		"variant_id" = REF(first_variant),
		"title" = "Track Alpha Updated"
	))
	TEST_ASSERT(title_action_result, "Panel variant title action failed for an explicit non-selected target.")
	TEST_ASSERT_EQUAL(first_variant.title, "Track Alpha Updated", "Variant title edit did not apply to the explicit action target.")
	TEST_ASSERT_EQUAL(second_variant.title, second_variant_original_title, "Variant title edit leaked onto the currently selected track.")

	var/duration_action_result = panel.handle_variant_action("set_variant_duration", list(
		"tier_id" = REF(tier),
		"variant_id" = REF(first_variant),
		"duration_seconds" = "1:57"
	))
	TEST_ASSERT(duration_action_result, "Panel duration action failed for an explicit non-selected target.")
	TEST_ASSERT_EQUAL(first_variant.duration_seconds, 117, "Variant duration edit did not apply to the explicit action target.")
	TEST_ASSERT_EQUAL(second_variant.duration_seconds, second_variant_original_duration, "Variant duration edit leaked onto the currently selected track.")
