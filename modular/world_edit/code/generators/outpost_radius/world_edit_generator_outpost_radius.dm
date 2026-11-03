#define WORLD_EDIT_OUTPOST_RADIUS_MAX 40
#define WORLD_EDIT_OUTPOST_SINGLE_POINT_SAFE_PLACEMENT_CAP 300
#define WORLD_EDIT_OUTPOST_MAX_FOOTPRINT_TURFS 2400
#define WORLD_EDIT_OUTPOST_MAX_SCAN_TURFS 65536
#define WORLD_EDIT_OUTPOST_MAX_CANDIDATE_SLOTS 7200
#define WORLD_EDIT_OUTPOST_MAX_PREVIEW_OBJECT_SPECS 2400
#define WORLD_EDIT_OUTPOST_MAX_HOVER_PREVIEW_OBJECT_SPECS 512
#define WORLD_EDIT_OUTPOST_HOVER_OBJECT_PREVIEW_MAX_ANCHORS 32
#define WORLD_EDIT_OUTPOST_MAX_ENDPOINT_CLAMP_ATTEMPTS 0
#define WORLD_EDIT_OUTPOST_PLANNER_VERSION "stable_v1"

/datum/world_edit_generator/outpost_radius
	requires_preview_before_apply = TRUE
	var/static/list/valid_factions = list(FACTION_MARINE, FACTION_UA_REBEL, FACTION_UPP, FACTION_CANC, FACTION_WY, FACTION_FREELANCER, FACTION_TWE, FACTION_TWE_REBEL, FACTION_MERCENARY)
	var/static/list/allowed_barricade_types = list(
		/datum/human_ai_defense/barricade/metal,
		/datum/human_ai_defense/barricade/metal/wired,
		/datum/human_ai_defense/barricade/sandbag,
		/datum/human_ai_defense/barricade/plasteel,
		/datum/human_ai_defense/barricade/plasteel/wired,
		/datum/human_ai_defense/barricade/wooden,
		/datum/human_ai_defense/barricade/snow,
		/datum/human_ai_defense/barricade/deployable,
	)
	var/static/list/allowed_outpost_door_types = list(
		/datum/human_ai_defense/barricade/metal_folding,
		/datum/human_ai_defense/barricade/metal_folding/wired,
		/datum/human_ai_defense/barricade/plasteel_folding,
		/datum/human_ai_defense/barricade/plasteel_folding/wired,
	)
	var/static/list/allowed_sentry_types = list(
		/datum/human_ai_defense/defense/sentry/uscm,
		/datum/human_ai_defense/defense/sentry/uscm/dmr,
		/datum/human_ai_defense/defense/sentry/uscm/shotgun,
		/datum/human_ai_defense/defense/sentry/uscm/mini,
		/datum/human_ai_defense/defense/sentry/upp,
		/datum/human_ai_defense/defense/sentry/wy,
	)
	var/static/list/allowed_extra_defense_types = list(
		/datum/human_ai_defense/defense/tesla,
		/datum/human_ai_defense/defense/tesla/stun,
		/datum/human_ai_defense/defense/tesla/micro,
		/datum/human_ai_defense/defense/bell_tower,
		/datum/human_ai_defense/defense/bell_tower/md,
		/datum/human_ai_defense/defense/bell_tower/cloaked,
	)
	var/static/list/allowed_flag_types = list(
		/datum/human_ai_defense/defense/flag/uscm,
		/datum/human_ai_defense/defense/flag/uscm/range,
		/datum/human_ai_defense/defense/flag/uscm/warbanner,
		/datum/human_ai_defense/defense/flag/upp,
		/datum/human_ai_defense/defense/flag/wy,
	)
	var/static/list/allowed_wire_types = list(
		/datum/human_ai_defense/misc_defences/razorwire,
	)
	var/static/list/allowed_mine_types = list(
		/datum/human_ai_defense/mine/claymore,
		/datum/human_ai_defense/mine/claymore/strong,
		/datum/human_ai_defense/mine/claymore/wy,
		/datum/human_ai_defense/mine/claymore/wy/strong,
		/datum/human_ai_defense/mine/sebb,
		/datum/human_ai_defense/mine/prox_sensor,
		/datum/human_ai_defense/mine/m760ap,
		/datum/human_ai_defense/mine/m760ap/strong,
		/datum/human_ai_defense/mine/m5a3betty,
		/datum/human_ai_defense/mine/m5a3betty/strong,
		/datum/human_ai_defense/mine/fzd91,
		/datum/human_ai_defense/mine/fzd91/strong,
		/datum/human_ai_defense/mine/tn13,
		/datum/human_ai_defense/mine/tn13/strong,
	)
	var/static/list/outpost_defense_profiles = list(
		"none" = list(
			"label" = "Без обороны",
			"description" = "Только периметр без дополнительных оборонительных объектов.",
			"defense_rules" = list(),
			"wired_groups" = list(),
		),
		"outrider_camp" = list(
			"label" = "Легкий дозор",
			"description" = "Небольшое прикрытие для мобильного поста с минимумом техники.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "guard_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/mini,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "wire_object",
					"group" = "opening_flanks",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/misc_defences/razorwire,
				),
			),
			"wired_groups" = list(),
		),
		"lane_fort" = list(
			"label" = "Линейный форт",
			"description" = "Фронтальные турельные точки, проволока у входов и мины на подступах.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "guard_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/shotgun,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "wire_object",
					"group" = "opening_flanks",
					"limit" = 4,
					"defense_path" = /datum/human_ai_defense/misc_defences/razorwire,
				),
				list(
					"kind" = "mine",
					"group" = "exterior_mine_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/mine/claymore,
					"faction" = FACTION_MARINE,
				),
			),
			"wired_groups" = list("opening_flanks"),
		),
		"fallback_redoubt" = list(
			"label" = "Редут отхода",
			"description" = "Удерживает тыл, помечает безопасную точку и закрывает подступы.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "rear_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "wire_object",
					"group" = "opening_flanks",
					"limit" = 4,
					"defense_path" = /datum/human_ai_defense/misc_defences/razorwire,
				),
				list(
					"kind" = "mine",
					"group" = "exterior_mine_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/mine/prox_sensor,
					"faction" = FACTION_MARINE,
				),
				list(
					"kind" = "extra_defense",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/flag/uscm/range,
				),
			),
			"wired_groups" = list(),
		),
		"pocket_defense" = list(
			"label" = "Оборонительный карман",
			"description" = "Жесткая оборона узкого входа с теслой и внутренней страховкой.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "guard_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/shotgun,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "extra_defense",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/tesla/stun,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "mine",
					"group" = "exterior_mine_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/mine/sebb,
					"faction" = FACTION_MARINE,
				),
			),
			"wired_groups" = list("opening_flanks"),
		),
		"crossfire_hub" = list(
			"label" = "Узел перекрестного огня",
			"description" = "Глубокие турельные углы с башней поддержки и минами на подступах.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "corner_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/dmr,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "extra_defense",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/bell_tower/md,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "mine",
					"group" = "exterior_mine_slots",
					"limit" = 3,
					"defense_path" = /datum/human_ai_defense/mine/m760ap,
					"faction" = FACTION_MARINE,
				),
			),
			"wired_groups" = list("opening_flanks"),
		),
		"anti_vehicle_stop" = list(
			"label" = "Противотранспортный стоп",
			"description" = "Тяжелые DMR-позиции, усиленный фронт и мины на подходе.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "guard_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/dmr,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "sentry",
					"group" = "corner_slots",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/dmr,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "mine",
					"group" = "exterior_mine_slots",
					"limit" = 3,
					"defense_path" = /datum/human_ai_defense/mine/m760ap/strong,
					"faction" = FACTION_MARINE,
				),
				list(
					"kind" = "extra_defense",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/tesla,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
			),
			"wired_groups" = list("opening_flanks", "corner_slots"),
		),
		"forward_medical_cover" = list(
			"label" = "Передовое медукрытие",
			"description" = "Минимум оружия, понятный ориентир и безопасные подходы.",
			"defense_rules" = list(
				list(
					"kind" = "sentry",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/sentry/uscm/mini,
					"faction" = FACTION_MARINE,
					"turned_on" = TRUE,
				),
				list(
					"kind" = "wire_object",
					"group" = "opening_flanks",
					"limit" = 2,
					"defense_path" = /datum/human_ai_defense/misc_defences/razorwire,
				),
				list(
					"kind" = "extra_defense",
					"group" = "rear_slots",
					"limit" = 1,
					"defense_path" = /datum/human_ai_defense/defense/flag/uscm,
				),
			),
			"wired_groups" = list(),
		),
	)
	var/static/type_list_extensions_applied = FALSE

	var/static/list/outpost_layout_profiles = list(
		"crossroads" = list(
			"label" = "Крест",
			"description" = "По одному центральному проходу на каждой стороне.",
			"opening_dirs" = list(NORTH, EAST, SOUTH, WEST),
			"opening_width" = 1,
		),
		"wide_crossroads" = list(
			"label" = "Широкий крест",
			"description" = "Широкие проходы со всех сторон для максимальной проходимости.",
			"opening_dirs" = list(NORTH, EAST, SOUTH, WEST),
			"opening_width" = 3,
		),
		"lane" = list(
			"label" = "Линия",
			"description" = "Проходы вперед и назад, ориентированные по текущему направлению.",
			"opening_dirs" = list("forward", "back"),
			"opening_width" = 3,
		),
		"gate" = list(
			"label" = "Ворота",
			"description" = "Один фронтальный проход, привязанный к текущему направлению.",
			"opening_dirs" = list("forward"),
			"opening_width" = 3,
		),
		"corner" = list(
			"label" = "Угол",
			"description" = "Проходы вперед и вправо, повернутые по текущему направлению.",
			"opening_dirs" = list("forward", "right"),
			"opening_width" = 1,
		),
		"sealed_redoubt" = list(
			"label" = "Запечатанный редут",
			"description" = "Без прямых проходов, только внутренние дуги охвата.",
			"opening_dirs" = list(),
			"opening_width" = 1,
		),
		"t_junction" = list(
			"label" = "Т-образный перекресток",
			"description" = "Открыты вперед, влево и вправо, а тыл закрыт.",
			"opening_dirs" = list("forward", "left", "right"),
			"opening_width" = 1,
		),
		"three_side_open" = list(
			"label" = "Три стороны открыты",
			"description" = "Открыто вперед, влево и вправо, а тыл заперт.",
			"opening_dirs" = list("forward", "left", "right"),
			"opening_width" = 3,
		),
		"three_side_lock" = list(
			"label" = "Три стороны под замком",
			"description" = "Три открытых стороны с дополнительным приоритетом охраны закрытого тыла.",
			"opening_dirs" = list("forward", "left", "right"),
			"opening_width" = 1,
		),
		"double_gate" = list(
			"label" = "Двойные ворота",
			"description" = "Парные широкие проходы по оси вперед-назад.",
			"opening_dirs" = list("forward", "back"),
			"opening_width" = 3,
		),
		"funnel_front" = list(
			"label" = "Фронтальная воронка",
			"description" = "Широкий фронтальный вход с боковым давлением охраны в проход.",
			"opening_dirs" = list("forward"),
			"opening_width" = 3,
		),
		"narrow_funnel" = list(
			"label" = "Узкая воронка",
			"description" = "Тесная фронтальная горловина с минимальной шириной входа.",
			"opening_dirs" = list("forward"),
			"opening_width" = 1,
		),
		"broad_funnel" = list(
			"label" = "Широкая воронка",
			"description" = "Очень широкий фронтальный прием с сохранением бокового давления охраны.",
			"opening_dirs" = list("forward"),
			"opening_width" = 5,
		),
		"inner_pocket" = list(
			"label" = "Внутренний карман",
			"description" = "Один контролируемый фронтальный вход с более глубоким внутренним охватом.",
			"opening_dirs" = list("forward"),
			"opening_width" = 1,
		),
		"fallback_pocket_layout" = list(
			"label" = "Карман отхода",
			"description" = "Фронтально ориентированная схема отхода с боковым карманом выживания.",
			"opening_dirs" = list("forward", "right"),
			"opening_width" = 1,
		),
		"split_mouth" = list(
			"label" = "Раздвоенный вход",
			"description" = "Два малых фронтальных входа вместо одного центрального прохода.",
			"opening_dirs" = list("forward"),
			"opening_width" = 1,
			"opening_slots_per_dir" = 2,
			"opening_slot_mode" = "split_pair",
		),
		"split_entry_guard" = list(
			"label" = "Раздвоенный вход с охраной",
			"description" = "Раздвоенные фронтальные входы с более широким боковым охватом.",
			"opening_dirs" = list("forward"),
			"opening_width" = 1,
			"opening_slots_per_dir" = 2,
			"opening_slot_mode" = "split_pair",
		),
		"corner_wide" = list(
			"label" = "Широкий угол",
			"description" = "Угловая схема с более широкими выходами вперед и вправо.",
			"opening_dirs" = list("forward", "right"),
			"opening_width" = 3,
		),
		"lane_narrow" = list(
			"label" = "Узкая линия",
			"description" = "Более плотный контроль линии по оси вперед-назад.",
			"opening_dirs" = list("forward", "back"),
			"opening_width" = 1,
		),
		"lane_wide" = list(
			"label" = "Широкая линия",
			"description" = "Широкий линейный контроль по оси вперед-назад.",
			"opening_dirs" = list("forward", "back"),
			"opening_width" = 5,
		),
		"bastion_face" = list(
			"label" = "Фасад бастиона",
			"description" = "Один главный боевой проход с боковыми дугами поддержки.",
			"opening_dirs" = list("forward"),
			"opening_width" = 1,
		),
		"sealed_shell" = list(
			"label" = "Запечатанная оболочка",
			"description" = "Почти полностью закрытое внешнее кольцо только с внутренней логикой охраны.",
			"opening_dirs" = list(),
			"opening_width" = 1,
		),
		"sealed_redoubt_heavy" = list(
			"label" = "Тяжелый запечатанный редут",
			"description" = "Полностью закрытая внешняя оболочка для тяжелых внутренних узлов обороны.",
			"opening_dirs" = list(),
			"opening_width" = 1,
		),
	)

/datum/world_edit_generator/outpost_radius/New()
	. = ..()
	apply_type_list_extensions()

/datum/world_edit_generator/outpost_radius/proc/apply_type_list_extensions()
	if(type_list_extensions_applied)
		return
	type_list_extensions_applied = TRUE
	if(hascall(src, "modular_append_outpost_radius_valid_factions"))
		call(src, "modular_append_outpost_radius_valid_factions")(valid_factions)
	if(hascall(src, "modular_append_outpost_radius_allowed_barricade_types"))
		call(src, "modular_append_outpost_radius_allowed_barricade_types")(allowed_barricade_types)
	if(hascall(src, "modular_append_outpost_radius_allowed_mine_types"))
		call(src, "modular_append_outpost_radius_allowed_mine_types")(allowed_mine_types)

/datum/world_edit_generator/outpost_radius/get_supported_placement_modes()
	return list("single", "repeat")

/datum/world_edit_generator/outpost_radius/get_supported_placement_shapes()
	return GLOB.world_edit_placement_shapes.world_edit_get_supported_shape_ids()

/datum/world_edit_generator/outpost_radius/supports_placement_direction()
	return TRUE

/datum/world_edit_generator/outpost_radius/get_default_placement_direction()
	return NORTH

/datum/world_edit_generator/outpost_radius/should_attempt_preview_endpoint_clamp(shape_id, turf/start_turf, turf/requested_end_turf, turf/segment_start_turf = null, list/runtime_params = null, list/placement_context = null)
	return FALSE

/datum/world_edit_generator/outpost_radius/get_preview_endpoint_clamp_attempt_limit()
	return WORLD_EDIT_OUTPOST_MAX_ENDPOINT_CLAMP_ATTEMPTS

/datum/world_edit_generator/outpost_radius/should_preview_collector_points_before_commit(shape_id, list/proposed_points = null)
	return FALSE
