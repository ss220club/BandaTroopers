/datum/world_edit_building_request
	var/list/config = list()
	var/datum/world_edit_building_archetype/archetype
	var/effective_seed = 1
	var/datum/world_edit_building_prng/program_rng
	var/datum/world_edit_building_prng/geometry_rng
	var/datum/world_edit_building_prng/fixture_rng
	var/datum/world_edit_building_prng/facade_rng
	var/datum/world_edit_building_prng/microvariation_rng

/datum/world_edit_generator/building_layout/proc/build_building_request(list/params, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	var/list/config = normalize_building_params(params)
	var/datum/world_edit_building_request/request = new
	request.config = config
	if(config["error"])
		return request

	request.archetype = get_building_archetype(config["archetype_id"])
	if(!istype(request.archetype))
		config["error"] = "Unable to resolve building archetype."
		return request

	request.effective_seed = build_effective_building_seed(config, shape_contract, placement_context)
	var/program_seed = build_stage_seed(request.effective_seed, "program")
	var/geometry_seed = build_stage_seed(request.effective_seed, "geometry")
	var/fixture_seed = build_stage_seed(request.effective_seed, "fixtures")
	var/facade_seed = build_stage_seed(request.effective_seed, "facade")
	var/microvariation_seed = build_stage_seed(request.effective_seed, "microvariation")
	request.program_rng = new /datum/world_edit_building_prng(program_seed)
	request.geometry_rng = new /datum/world_edit_building_prng(geometry_seed)
	request.fixture_rng = new /datum/world_edit_building_prng(fixture_seed)
	request.facade_rng = new /datum/world_edit_building_prng(facade_seed)
	request.microvariation_rng = new /datum/world_edit_building_prng(microvariation_seed)
	config["effective_seed"] = request.effective_seed
	config["root_seed"] = request.effective_seed
	config["stage_seed_program"] = program_seed
	config["stage_seed_geometry"] = geometry_seed
	config["stage_seed_fixtures"] = fixture_seed
	config["stage_seed_facade"] = facade_seed
	config["stage_seed_microvariation"] = microvariation_seed
	config["archetype_label"] = request.archetype.label
	config["placement_shape_id"] = "[shape_contract?.shape_id || placement_context["shape"] || WORLD_EDIT_SHAPE_POINT]"
	config["placement_direction"] = text2num("[placement_context["direction"]]")
	config["footprint_source"] = config["placement_shape_id"] == WORLD_EDIT_SHAPE_POINT ? "point_size" : "explicit_shape"
	return request
