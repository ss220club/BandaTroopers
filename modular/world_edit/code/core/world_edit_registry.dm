/// Generator definitions exposed by the active World Edit runtime surface.
/datum/world_edit_generator_definition
	var/id = ""
	var/name_ru = ""
	var/category_ru = "General"
	var/description_ru = ""
	var/required_rights = R_DEBUG
	var/supports_preview = TRUE
	var/execution_mode = WORLD_EDIT_EXECUTION_BATCH
	var/generator_type = /datum/world_edit_generator
	var/list/default_params = list()
	var/status = WORLD_EDIT_STATUS_DRAFT

/datum/world_edit_generator_definition/outpost_radius
	id = "outpost_radius"
	name_ru = "Форпост по радиусу"
	category_ru = "Строительство"
	description_ru = "Безопасный генератор периметрального форпоста по радиусу."
	required_rights = R_EVENT
	supports_preview = TRUE
	execution_mode = WORLD_EDIT_EXECUTION_BATCH
	generator_type = /datum/world_edit_generator/outpost_radius
	default_params = list(
		"defense_profile" = "none",
		"layout_variant" = "crossroads",
		"opening_width" = "layout",
		"radius" = 4,
		"faction" = FACTION_MARINE,
		"turned_on" = TRUE,
		"sentry_layer_profile" = "none",
		"sentry_type" = /datum/human_ai_defense/defense/sentry/uscm,
		"extra_defense_layer_profile" = "none",
		"extra_defense_type" = /datum/human_ai_defense/defense/tesla,
		"flag_type" = "none",
		"wire_layer_profile" = "none",
		"wire_offset" = 3,
		"wire_rows" = 1,
		"wire_row_step" = 1,
		"wire_spacing" = 2,
		"wire_concentration_percent" = 70,
		"minefield_profile" = "none",
		"mine_type" = /datum/human_ai_defense/mine/claymore,
		"minefield_offset" = 3,
		"minefield_depth" = 3,
		"minefield_density_percent" = 35,
		"minefield_seed" = 0,
		"primary_material_path" = /datum/human_ai_defense/barricade/metal,
		"secondary_material_path" = /datum/human_ai_defense/barricade/sandbag,
		"primary_material_share_percent" = 50,
		"place_barricade_doors" = FALSE,
		"primary_door_path" = "follow_material",
		"secondary_door_path" = "follow_material",
		"barricade_pattern" = "alternating"
	)
	status = WORLD_EDIT_STATUS_READY

/datum/world_edit_generator_definition/fortify_room
	id = "fortify_room"
	name_ru = "Fortify Room"
	category_ru = "Construction"
	description_ru = "Point-seeded room fortification with preview-first additive barricade placement."
	required_rights = R_DEBUG
	supports_preview = TRUE
	execution_mode = WORLD_EDIT_EXECUTION_BATCH
	generator_type = /datum/world_edit_generator/fortify_room
	default_params = list(
		"preset_id" = "legacy_metal",
		"material_family" = "metal",
		"material_wired" = FALSE,
		"door_policy" = "auto",
		"door_material_family" = "metal",
		"door_wired" = FALSE,
		"room_tile_cap" = 195,
		"treat_windows_as_boundary" = TRUE,
		"fortify_windows" = TRUE,
		"treat_doors_as_boundary" = TRUE,
	)
	status = WORLD_EDIT_STATUS_READY

/datum/world_edit_generator_definition/destruction_pack
	id = "destruction_pack"
	name_ru = "Пакет разрушения"
	category_ru = "Разрушение"
	description_ru = "Ограниченный пакет shuffle/scatter/огня/взрыва/урона по радиусу для подвижных атомов."
	required_rights = R_DEBUG
	supports_preview = TRUE
	execution_mode = WORLD_EDIT_EXECUTION_BATCH
	generator_type = /datum/world_edit_generator/destruction_pack
	default_params = list(
		"radius" = 3,
		"shuffle_enabled" = TRUE,
		"scatter_enabled" = FALSE,
		"scatter_steps" = 2,
		"persistent_fire_enabled" = FALSE,
		"persistent_fire_density" = 10,
		"persistent_fire_mode" = "damaging",
		"persistent_fire_color" = "amber",
		"persistent_fire_custom_color" = "",
		"blast_enabled" = FALSE,
		"blast_power" = 250,
		"blast_falloff" = 600,
		"damage_profile" = "none",
		"max_atoms" = 60,
		"affect_anchored" = FALSE
	)
	status = WORLD_EDIT_STATUS_READY

/datum/world_edit_generator_definition/blueprint_stamp
	id = "blueprint_stamp"
	name_ru = "Штамп шаблона"
	category_ru = "Шаблоны"
	description_ru = "Безопасное штампование структур из библиотеки World Edit Blueprint Lite."
	required_rights = R_EVENT
	supports_preview = TRUE
	execution_mode = WORLD_EDIT_EXECUTION_BATCH
	generator_type = /datum/world_edit_generator/blueprint_stamp
	default_params = list(
		"blueprint_id" = "",
	)
	status = WORLD_EDIT_STATUS_READY

/datum/world_edit_generator_definition/building_layout
	id = "building_layout"
	name_ru = "Постройки"
	category_ru = "Строительство"
	description_ru = "Генератор живых построек по прямоугольнику или форме панели размещения."
	required_rights = R_EVENT
	supports_preview = TRUE
	execution_mode = WORLD_EDIT_EXECUTION_BATCH
	generator_type = /datum/world_edit_generator/building_layout
	default_params = list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 0,
		"half_width" = 4,
		"half_depth" = 4,
		"window_density" = 40,
		"detail_budget" = 60,
		"back_exit" = FALSE,
		"respect_blockers" = TRUE,
		"replace_blocked_turfs" = FALSE,
	)
	status = WORLD_EDIT_STATUS_READY

GLOBAL_DATUM_INIT(world_edit_registry, /datum/world_edit_registry_service, new)

/datum/world_edit_registry_service
	var/list/definitions_by_id = list()

/datum/world_edit_registry_service/New()
	. = ..()
	definitions_by_id = build_generator_definition_index()

/datum/world_edit_registry_service/proc/build_generator_definition_index()
	. = list()
	for(var/definition_type in subtypesof(/datum/world_edit_generator_definition))
		var/datum/world_edit_generator_definition/definition = new definition_type()

		if(!definition.id)
			CRASH("World Edit: generator [definition_type] is missing id.")
		if(!definition.name_ru)
			CRASH("World Edit: generator [definition.id] is missing name_ru.")
		if(!ispath(definition.generator_type, /datum/world_edit_generator))
			CRASH("World Edit: generator [definition.id] has an invalid generator_type ([definition.generator_type]).")
		if(.[definition.id])
			CRASH("World Edit: duplicate generator id detected ([definition.id]).")

		.[definition.id] = definition

/datum/world_edit_registry_service/proc/get_generator_definition(id)
	if(!id)
		return null
	return definitions_by_id[id]
