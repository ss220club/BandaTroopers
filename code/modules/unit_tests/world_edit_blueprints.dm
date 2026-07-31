/datum/unit_test/world_edit_dmm_blueprints/proc/build_dmm_text(model_text, grid_text, z_level = 1)
	return "\"aaa\" = ([model_text])\n\n(1,1,[z_level]) = {\"\n[grid_text]\n\"}"

/datum/unit_test/world_edit_dmm_blueprints/proc/build_noop_line(width)
	var/list/model_keys = list()
	for(var/i in 1 to width)
		model_keys += "aaa"
	return model_keys.Join("")

/datum/unit_test/world_edit_dmm_blueprints/proc/parse_dmm(dmm_text, blueprint_id = "unit_test_blueprint")
	return GLOB.world_edit_blueprints.world_edit_parse_blueprint_dmm_text(dmm_text, blueprint_id, blueprint_id, "unit_test")

/datum/unit_test/world_edit_dmm_blueprints/proc/entry_offset_lookup(list/entries)
	var/list/offsets = list()
	for(var/list/entry as anything in entries)
		offsets["[entry["dx"]],[entry["dy"]]"] = TRUE
	return offsets

/datum/unit_test/world_edit_dmm_blueprints/proc/build_single_barricade_blueprint(blueprint_id, blueprint_name)
	return list(
		"id" = blueprint_id,
		"name" = blueprint_name,
		"created_at" = "unit-test-created",
		"created_by" = "unit_test",
		"source" = "unit_test",
		"entries" = list(
			list(
				"type" = "/obj/structure/barricade/metal",
				"dx" = 0,
				"dy" = 0,
				"dz" = 0,
				"dir" = SOUTH,
				"vars" = list(),
			),
		),
	)

/datum/unit_test/world_edit_dmm_blueprints/proc/cleanup_library_blueprint(blueprint_id)
	var/file_path = GLOB.world_edit_blueprints.world_edit_get_blueprint_file_path(blueprint_id)
	if(file_path && fexists(file_path))
		fdel(file_path)
	GLOB.world_edit_blueprints.world_edit_remove_blueprint_metadata(blueprint_id)

/datum/unit_test/world_edit_dmm_blueprints/Run()
	var/model_text = "/obj/structure/barricade/metal{dir = 2},/turf/template_noop,/area/template_noop"
	var/list/parse_result = parse_dmm(build_dmm_text(model_text, "aaa"), "unit_valid")
	TEST_ASSERT(!parse_result["error"], "valid DMM should parse")

	var/list/blueprint = parse_result["blueprint"]
	TEST_ASSERT_EQUAL(blueprint["id"], "unit_valid", "id should come from file stem")
	TEST_ASSERT_EQUAL(blueprint["name"], "unit_valid", "name should come from file stem")
	TEST_ASSERT_EQUAL(length(blueprint["entries"]), 1, "valid DMM should produce one entry")

	var/list/entry = blueprint["entries"][1]
	TEST_ASSERT_EQUAL(entry["type"], "/obj/structure/barricade/metal", "entry path should be preserved")
	TEST_ASSERT_EQUAL(entry["dx"], 0, "1x1 anchor should preserve dx=0")
	TEST_ASSERT_EQUAL(entry["dy"], 0, "1x1 anchor should preserve dy=0")
	TEST_ASSERT_EQUAL(entry["dir"], 2, "dir var edit should be preserved")

	var/list/summary = GLOB.world_edit_blueprints.world_edit_build_blueprint_summary(blueprint)
	var/list/preview_cells = summary["preview_cells"]
	TEST_ASSERT_EQUAL(length(preview_cells), 1, "summary should include one schematic preview cell")
	var/list/preview_cell = preview_cells[1]
	TEST_ASSERT_EQUAL(preview_cell["x"], 1, "preview cell x should be footprint-local")
	TEST_ASSERT_EQUAL(preview_cell["y"], 1, "preview cell y should be footprint-local")
	TEST_ASSERT_EQUAL(preview_cell["category"], "barricade", "preview cell should include blueprint category")
	TEST_ASSERT_EQUAL(preview_cell["tone"], "barricade", "preview cell should include UI tone")

	var/list/serialize_result = GLOB.world_edit_blueprints.world_edit_serialize_blueprint_to_dmm(blueprint)
	TEST_ASSERT(!serialize_result["error"], "valid blueprint should serialize to DMM")
	var/list/reparse_result = parse_dmm(serialize_result["dmm_text"], "unit_valid")
	TEST_ASSERT(!reparse_result["error"], "serialized DMM should parse again")

	var/tgm_text = "\"aaa\" = (\n/obj/structure/barricade/metal{\n\tdir = 2\n\t},\n/turf/template_noop,\n/area/template_noop)\n\n(1,1,1) = {\"\naaa\n\"}"
	var/list/tgm_result = parse_dmm(tgm_text, "unit_tgm")
	TEST_ASSERT(!tgm_result["error"], "TGM-style DMM should parse")

	var/list/anchored_blueprint = list(
		"id" = "unit_anchor",
		"name" = "unit_anchor",
		"entries" = list(
			list(
				"type" = "/obj/structure/barricade/metal",
				"dx" = -2,
				"dy" = 1,
				"dz" = 0,
				"dir" = 2,
				"vars" = list(),
			),
			list(
				"type" = "/obj/structure/barricade/metal/wired",
				"dx" = 1,
				"dy" = -1,
				"dz" = 0,
				"dir" = 2,
				"vars" = list(),
			),
		),
	)
	var/list/anchor_serialize_result = GLOB.world_edit_blueprints.world_edit_serialize_blueprint_to_dmm(anchored_blueprint)
	TEST_ASSERT(!anchor_serialize_result["error"], "anchored blueprint should serialize")
	var/list/anchor_parse_result = parse_dmm(anchor_serialize_result["dmm_text"], "unit_anchor")
	TEST_ASSERT(!anchor_parse_result["error"], "anchored DMM should parse")
	var/list/offsets = entry_offset_lookup(anchor_parse_result["blueprint"]["entries"])
	TEST_ASSERT(offsets["-2,1"], "DMM anchor should preserve negative x and positive y offset")
	TEST_ASSERT(offsets["1,-1"], "DMM anchor should preserve positive x and negative y offset")

	var/list/too_wide_result = parse_dmm(build_dmm_text("/turf/template_noop,/area/template_noop", build_noop_line(33)), "unit_too_wide")
	TEST_ASSERT(too_wide_result["error"], "33x1 DMM should reject")

	var/multi_z_dmm = "\"aaa\" = (/turf/template_noop,/area/template_noop)\n\n(1,1,1) = {\"\naaa\n\"}\n(1,1,2) = {\"\naaa\n\"}"
	var/list/multi_z_result = parse_dmm(multi_z_dmm, "unit_multi_z")
	TEST_ASSERT(multi_z_result["error"], "multi-z DMM should reject")

	var/list/bad_path_result = parse_dmm(build_dmm_text("/obj/not_a_real_path,/turf/template_noop,/area/template_noop", "aaa"), "unit_bad_path")
	TEST_ASSERT(bad_path_result["error"], "bad atom paths should reject")

	var/list/unsupported_var_result = parse_dmm(build_dmm_text("/obj/structure/barricade/metal{pixel_x = 1},/turf/template_noop,/area/template_noop", "aaa"), "unit_bad_var")
	TEST_ASSERT(unsupported_var_result["error"], "unsupported var edits should reject")

	var/list/template_var_result = parse_dmm(build_dmm_text("/turf/template_noop{icon_state = \"bad\"},/area/template_noop", "aaa"), "unit_template_var")
	TEST_ASSERT(template_var_result["error"], "template turf var edits should reject")

	TEST_ASSERT_NULL(GLOB.world_edit_blueprints.world_edit_get_blueprint_file_path("../bad"), "unsafe id should not produce a library path")
	TEST_ASSERT_NULL(GLOB.world_edit_blueprints.world_edit_get_blueprint_id_from_file_name("../bad.dmm"), "unsafe file name should reject")
	TEST_ASSERT_NULL(GLOB.world_edit_blueprints.world_edit_get_blueprint_id_from_file_name("bad.json"), "non-DMM file should reject")
	TEST_ASSERT_EQUAL(GLOB.world_edit_blueprints.world_edit_get_blueprint_file_path("safe_blueprint"), "data/world_edit/blueprints/safe_blueprint.dmm", "safe id should stay inside blueprint library")

	var/test_suffix = copytext(md5("[world.realtime]-[world.time]-[rand(1, 999999)]"), 1, 7)
	var/test_blueprint_id = "unit_meta_[test_suffix]"
	var/renamed_blueprint_id = "unit_rename_[test_suffix]"
	cleanup_library_blueprint(test_blueprint_id)
	cleanup_library_blueprint(renamed_blueprint_id)

	var/display_name = "Readable Unit Blueprint"
	var/list/saved_blueprint = build_single_barricade_blueprint(test_blueprint_id, display_name)
	var/saved_path = GLOB.world_edit_blueprints.world_edit_save_blueprint_definition(saved_blueprint)
	TEST_ASSERT(saved_path, "blueprint save should create a DMM file")
	var/list/saved_load_result = GLOB.world_edit_blueprints.world_edit_load_blueprint_from_file(saved_path)
	TEST_ASSERT(!saved_load_result["error"], "saved DMM blueprint should load")
	TEST_ASSERT_EQUAL(saved_load_result["blueprint"]["name"], display_name, "saved DMM blueprint should preserve display name through metadata")

	var/list/rename_result = GLOB.world_edit_blueprints.world_edit_rename_blueprint_file(test_blueprint_id, renamed_blueprint_id)
	TEST_ASSERT(!rename_result["error"], "DMM blueprint rename should succeed")
	TEST_ASSERT(!fexists(saved_path), "DMM blueprint rename should remove old file path")
	var/list/renamed_load_result = GLOB.world_edit_blueprints.world_edit_load_blueprint_from_file(rename_result["file_path"])
	TEST_ASSERT(!renamed_load_result["error"], "renamed DMM blueprint should load")
	TEST_ASSERT_EQUAL(renamed_load_result["blueprint"]["id"], renamed_blueprint_id, "renamed DMM blueprint should load from new file id")
	TEST_ASSERT_EQUAL(renamed_load_result["blueprint"]["name"], display_name, "renaming file id should not change display name")
	cleanup_library_blueprint(renamed_blueprint_id)
