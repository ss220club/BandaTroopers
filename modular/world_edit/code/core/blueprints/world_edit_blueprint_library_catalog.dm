/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_type_rules()
	. = list()

	world_edit_register_blueprint_type(., /obj/structure/barricade/metal, "barricade", "Металлическая баррикада")
	world_edit_register_blueprint_type(., /obj/structure/barricade/metal/wired, "barricade", "Металлическая баррикада с проволокой")
	world_edit_register_blueprint_type(., /obj/structure/barricade/sandbags/full, "barricade", "Мешки с песком")
	world_edit_register_blueprint_type(., /obj/structure/barricade/metal/plasteel, "barricade", "Пласталевая баррикада")
	world_edit_register_blueprint_type(., /obj/structure/barricade/metal/plasteel/wired, "barricade", "Пласталевая баррикада с проволокой")
	world_edit_register_blueprint_type(., /obj/structure/barricade/wooden, "barricade", "Деревянная баррикада")
	world_edit_register_blueprint_type(., /obj/structure/barricade/snow, "barricade", "Снежная баррикада")
	world_edit_register_blueprint_type(., /obj/structure/barricade/deployable, "barricade", "Portable Barricade")
	world_edit_register_blueprint_type(., /obj/structure/covenant_barricade, "barricade", "Covenant Barrier")
	world_edit_register_blueprint_type(., /obj/structure/covenant_barricade/wide, "barricade", "Covenant Triptych Barrier")

	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry, "sentry", "Турель USCM")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry/dmr, "sentry", "Турель USCM DMR")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry/shotgun, "sentry", "Турель USCM дробовик")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry/mini, "sentry", "Турель USCM mini")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry/upp, "sentry", "Турель UPP")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/sentry/wy, "sentry", "Турель W-Y")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/tesla_coil, "defense", "Тесла-башня USCM")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/tesla_coil/stun, "defense", "Тесла-башня USCM - Overclocked")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/tesla_coil/micro, "defense", "Тесла-башня USCM - Micro")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/bell_tower, "defense", "Колокольная башня USCM")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/bell_tower/md, "defense", "Колокольная башня USCM - MD")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/bell_tower/cloaker, "defense", "Колокольная башня USCM - Cloaker")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/planted_flag, "defense", "Флаг USCM")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/planted_flag/range, "defense", "Флаг USCM - Range+")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/planted_flag/warbanner, "defense", "Флаг USCM - Warbanner")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/planted_flag/upp, "defense", "Флаг UPP")
	world_edit_register_blueprint_type(., /obj/structure/machinery/defenses/planted_flag/wy, "defense", "Флаг W-Y")

	world_edit_register_blueprint_type(., /obj/structure/closet/crate/ammo, "support_prop", "Ящик с боеприпасами")
	world_edit_register_blueprint_type(., /obj/structure/closet/crate/medical, "support_prop", "Медицинский ящик")
	world_edit_register_blueprint_type(., /obj/structure/bed/medevac_stretcher, "support_prop", "Медэвак-носилки")
	world_edit_register_blueprint_type(., /obj/structure/largecrate/supply/generator, "support_prop", "Ящик с генератором")
	world_edit_register_blueprint_type(., /obj/structure/deployable_beacon, "support_prop", "Развертываемый маяк")

	world_edit_register_blueprint_type(., /obj/structure/machinery/recharger/covenant, "support_prop", "Covenant Plasma Charger")
	world_edit_register_blueprint_type(., /obj/structure/machinery/prop/almayer/CICmap/yautja/empty, "support_prop", "Covenant Globe")

	world_edit_register_blueprint_type(., /obj/structure/barricade/plasteel/metal, "barricade", "Metal Folding Barricade")
	world_edit_register_blueprint_type(., /obj/structure/barricade/plasteel/metal/wired, "barricade", "Metal Folding Barricade - Wired")
	world_edit_register_blueprint_type(., /obj/structure/barricade/plasteel, "barricade", "Plasteel Folding Barricade")
	world_edit_register_blueprint_type(., /obj/structure/barricade/plasteel/wired, "barricade", "Plasteel Folding Barricade - Wired")
	world_edit_register_blueprint_type(., /obj/structure/barricade/razorwire, "wire_object", "Razor Wire")

	world_edit_register_blueprint_type(., /obj/item/explosive/mine/active, "mine", "Claymore")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/strong/active, "mine", "Claymore - Strong")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/pmc/active, "mine", "Claymore PMC")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/pmc/strong/active, "mine", "Claymore PMC - Strong")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/sebb/active, "mine", "SEBB Mine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/m760ap/active, "mine", "M760AP Mine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/m760ap/strong/active, "mine", "M760AP Mine - Strong")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/m5a3betty/active, "mine", "M5A3 Bounding Mine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/m5a3betty/strong/active, "mine", "M5A3 Bounding Mine - Strong")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/fzd91/active, "mine", "FZD-91 Landmine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/fzd91/strong/active, "mine", "FZD-91 Landmine - Strong")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/tn13/active, "mine", "TN-13 Landmine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/tn13/strong/active, "mine", "TN-13 Landmine - Regular")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/covenant/plasma/active, "mine", "Covenant Plasma Mine")
	world_edit_register_blueprint_type(., /obj/item/explosive/mine/covenant/needle_mine/active, "mine", "Covenant Needle Mine")
	world_edit_register_blueprint_type(., /obj/item/device/assembly/prox_sensor/active, "mine", "Prox Sensor Mine")

/datum/world_edit_blueprint_service/proc/world_edit_register_blueprint_type(list/rules, obj_path, category, label)
	rules["[obj_path]"] = list(
		"obj_path" = obj_path,
		"category" = category,
		"label" = label,
	)

/datum/world_edit_blueprint_service/proc/world_edit_register_blueprint_building_object_type(list/rules, path_value, label = "Building object", allow_wall_turf = FALSE)
	var/obj_path = ispath(path_value, /obj) ? path_value : text2path("[path_value]")
	if(!ispath(obj_path, /obj))
		return
	world_edit_register_blueprint_type(rules, obj_path, "building_object", label)
	var/list/rule = rules["[obj_path]"]
	if(islist(rule) && allow_wall_turf)
		rule["allow_wall_turf"] = TRUE

/datum/world_edit_blueprint_service/proc/world_edit_register_blueprint_building_turf_type(list/rules, path_value, category = "building_turf", label = "Building turf")
	var/turf_path = ispath(path_value, /turf) ? path_value : text2path("[path_value]")
	if(!ispath(turf_path, /turf))
		return
	rules["[turf_path]"] = list(
		"turf_path" = turf_path,
		"category" = category,
		"label" = label,
	)

/datum/world_edit_blueprint_service/proc/world_edit_collect_building_preset_blueprint_rules(list/object_rules, list/turf_rules, list/preset)
	if(!islist(preset))
		return
	world_edit_register_blueprint_building_turf_type(turf_rules, preset["wall_path"], "building_wall", "Building wall")
	world_edit_register_blueprint_building_turf_type(turf_rules, preset["floor_path"], "building_floor", "Building floor")
	world_edit_register_blueprint_building_object_type(object_rules, preset["door_path"], "Building door")
	world_edit_register_blueprint_building_object_type(object_rules, preset["window_path"], "Building window")
	var/list/interior_paths = preset["interior_paths"]
	if(islist(interior_paths))
		for(var/interior_id as anything in interior_paths)
			world_edit_register_blueprint_building_object_type(object_rules, interior_paths[interior_id], "Building fixture")

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_building_type_rules()
	. = list()

	var/datum/world_edit_generator/building_layout/building_generator = new
	if(istype(building_generator) && hascall(building_generator, "get_building_faction_catalog"))
		var/list/catalog = call(building_generator, "get_building_faction_catalog")()
		if(islist(catalog))
			for(var/preset_id as anything in catalog)
				world_edit_collect_building_preset_blueprint_rules(., list(), catalog[preset_id])
	qdel(building_generator)

	for(var/path_value as anything in list(
		"/obj/effect/decal/warning_stripes",
		"/obj/effect/decal/hefa_cult_decals",
		"/obj/effect/decal/hefa_cult_decals/d32",
		"/obj/effect/decal/hefa_cult_decals/d96",
		"/obj/effect/decal/cleanable/crayon",
		"/obj/effect/decal/cleanable/dirt",
		"/obj/effect/decal/cleanable/dirt/greenglow",
		"/obj/effect/decal/strata_decals/grime/grime1",
		"/obj/effect/decal/strata_decals/grime/grime2",
	))
		world_edit_register_blueprint_building_object_type(., path_value, "Building detail", TRUE)

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_building_turf_rules()
	. = list()

	var/list/object_rules = list()
	var/datum/world_edit_generator/building_layout/building_generator = new
	if(istype(building_generator) && hascall(building_generator, "get_building_faction_catalog"))
		var/list/catalog = call(building_generator, "get_building_faction_catalog")()
		if(islist(catalog))
			for(var/preset_id as anything in catalog)
				world_edit_collect_building_preset_blueprint_rules(object_rules, ., catalog[preset_id])
	qdel(building_generator)

	for(var/path_value as anything in list(
		"/turf/open/floor/prison/sterile_white",
		"/turf/open/floor/prison/greenblue",
		"/turf/open/floor/prison/green",
		"/turf/open/floor/prison/kitchen",
		"/turf/open/floor/interior/wood/alt",
		"/turf/open/floor/prison/blue_plate",
		"/turf/open/floor/prison/cell_stripe",
		"/turf/open/floor/prison/blue",
		"/turf/open/floor/almayer/orange",
		"/turf/open/floor/almayer/cargo",
	))
		world_edit_register_blueprint_building_turf_type(., path_value, "building_floor", "Building floor")

/datum/world_edit_blueprint_service/proc/world_edit_get_blueprint_type_rule(obj_path)
	if(!ispath(obj_path, /obj))
		return null
	var/list/rule = world_edit_blueprint_type_rules["[obj_path]"]
	if(islist(rule))
		return rule
	return world_edit_blueprint_building_type_rules["[obj_path]"]

/datum/world_edit_blueprint_service/proc/world_edit_get_blueprint_turf_rule(turf_path)
	if(!ispath(turf_path, /turf))
		return null
	return world_edit_blueprint_building_turf_rules["[turf_path]"]
