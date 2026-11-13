// Spawn stuff
#define XENO_SPAWNER_CATEGORY_XENOMORPH "Xenomorphs"
#define XENO_SPAWNER_CATEGORY_PATHOGEN "Pathogen"

/// Caste names must be ones that get_caste_by_text() knows
#define XENO_SPAWNER_CASTES list( \
	XENO_SPAWNER_CATEGORY_XENOMORPH = list( \
		XENO_CASTE_LARVA, XENO_CASTE_PREDALIEN_LARVA, XENO_CASTE_FACEHUGGER, XENO_CASTE_LESSER_DRONE, \
		XENO_CASTE_DRONE, XENO_CASTE_RUNNER, RUNNER_ACIDER, XENO_CASTE_SENTINEL, XENO_CASTE_DEFENDER, \
		XENO_CASTE_SOLDIER, XENO_CASTE_BURROWER, XENO_CASTE_CARRIER, XENO_CASTE_HIVELORD, XENO_CASTE_LURKER, XENO_CASTE_WARRIOR, XENO_CASTE_SPITTER, \
		XENO_CASTE_BOILER, XENO_CASTE_PRAETORIAN, XENO_CASTE_CRUSHER, XENO_CASTE_RAVAGER, \
		XENO_CASTE_QUEEN, XENO_CASTE_KING, XENO_CASTE_PREDALIEN, XENO_CASTE_HELLHOUND \
	), \
	XENO_SPAWNER_CATEGORY_PATHOGEN = list( \
		PATHOGEN_CREATURE_BURSTER, PATHOGEN_CREATURE_ABER_BURSTER, PATHOGEN_CREATURE_POPPER, \
		PATHOGEN_CREATURE_SPRINTER, PATHOGEN_CREATURE_NEOPHYTE, \
		PATHOGEN_CREATURE_NEOMORPH, PATHOGEN_CREATURE_BLIGHT, \
		PATHOGEN_CREATURE_CONDITOR, PATHOGEN_CREATURE_BRUTE, PATHOGEN_CREATURE_VENATOR, PATHOGEN_CREATURE_HARBINGER, \
		PATHOGEN_CREATURE_MATRIARCH, PATHOGEN_CREATURE_ABERRATION, PATHOGEN_CREATURE_ARCHON \
	) \
)

#define XENO_SPAWNER_DEFAULT_HIVES list( \
	XENO_SPAWNER_CATEGORY_XENOMORPH = XENO_HIVE_NORMAL, \
	XENO_SPAWNER_CATEGORY_PATHOGEN = XENO_HIVE_PATHOGEN \
)

#define XENO_SPAWNER_MODE_SINGLE "single"
#define XENO_SPAWNER_MODE_SQUAD "squad"

/// Per caste, both in single mode and in a squad
#define XENO_SPAWNER_MAX_COUNT 10
#define XENO_SPAWNER_MAX_SQUAD_SIZE 30
#define XENO_SPAWNER_DEFAULT_SQUAD_RADIUS 2
#define XENO_SPAWNER_MAX_SQUAD_RADIUS 7

// Behavior stuff
#define XENO_SPAWNER_BEHAVIORS list( \
	"Attack" = /datum/component/ai_behavior_override/attack, \
	"Capture" = /datum/component/ai_behavior_override/capture, \
	"Hive" = /datum/component/ai_behavior_override/hive, \
	"Build" = /datum/component/ai_behavior_override/build \
)
#define XENO_SPAWNER_DEFAULT_BEHAVIOR "Attack"

/// Types of click intercepts used by /datum/xeno_ai_spawner_menu variable current_click_intercept_action
#define SPAWN_CLICK_INTERCEPT_ACTION "spawn_click_intercept_action"
#define BEHAVIOR_CLICK_INTERCEPT_ACTION "behavior_click_intercept_action"

/client/proc/open_xeno_ai_spawner_panel()
	set name = "Xeno Spawner Panel"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	if(!xeno_spawn_menu)
		xeno_spawn_menu = new /datum/xeno_ai_spawner_menu()

	xeno_spawn_menu.tgui_interact(mob)

/datum/xeno_ai_spawner_menu
	/// Associated list organized by category = list of caste names
	var/static/list/castes_by_category

	/// Associated list organized by caste name = category
	var/static/list/category_by_caste

	/// List of assoc lists that hold "id", "name" and "color" of every hive
	var/static/list/hive_ui_data

	/// Associated list organized by behavior name = behavior component type
	var/static/list/behavior_types

	/// Holds what type of click intercept we are using
	var/current_click_intercept_action


	// Spawn stuff

	/// The category of castes shown in the spawn section
	var/category = XENO_SPAWNER_CATEGORY_XENOMORPH

	/// If a click spawns the selected xeno or the whole squad
	var/mode = XENO_SPAWNER_MODE_SINGLE

	/// The hive selected to be spawned for each category, organized as category = hive
	var/list/selected_hives = XENO_SPAWNER_DEFAULT_HIVES

	/// If the spawned xeno is an AI
	var/spawn_ai = TRUE

	/// The xeno selected to be spawned in single mode
	var/selected_caste = XENO_CASTE_DRONE

	/// The amount of xenos to spawn in single mode
	var/spawn_count = 1

	/// The xenos to spawn in squad mode, organized as caste name = amount
	var/list/squad = list()

	/// How far from the clicked turf the squad is spread
	var/squad_radius = XENO_SPAWNER_DEFAULT_SQUAD_RADIUS

	/// Associated list of game master submenus opened by middle clicking while click spawning, organized by object_type = game_master_submenu
	var/static/list/submenu_types = list(
		/obj/structure/pipes/vents = /datum/game_master_submenu/ambush/vents,
		/obj/structure/tunnel = /datum/game_master_submenu/ambush/tunnels,
		/mob/living/carbon/human = /datum/game_master_submenu/infest,
	)

	/// List of current submenus
	var/list/datum/game_master_submenu/current_submenus = list()


	// Behavior stuff

	/// The current behavior to add when clicking with the behavior click intercept on
	var/selected_behavior = XENO_SPAWNER_DEFAULT_BEHAVIOR

/datum/xeno_ai_spawner_menu/New()
	. = ..()

	if(castes_by_category)
		return

	castes_by_category = XENO_SPAWNER_CASTES
	behavior_types = XENO_SPAWNER_BEHAVIORS

	category_by_caste = list()
	for(var/caste_category in castes_by_category)
		for(var/caste in castes_by_category[caste_category])
			category_by_caste[caste] = caste_category

	hive_ui_data = list()
	for(var/hivenumber in ALL_XENO_HIVES)
		var/datum/hive_status/hive = GLOB.hive_datum[hivenumber]
		if(!hive)
			continue
		hive_ui_data += list(list(
			"id" = hivenumber,
			"name" = hive.name,
			"color" = hive.ui_color,
		))

/datum/xeno_ai_spawner_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoAISpawner", "Xeno Spawner")
		ui.open()

	var/client/user_client = user.client
	if(!user_client)
		return

	// Behavior markers are only drawn for game masters
	GLOB.game_masters |= user_client
	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		user_client.images |= override.behavior_image

/datum/xeno_ai_spawner_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/xeno_ai_spawner_menu/ui_close(mob/user)
	. = ..()

	current_click_intercept_action = null

	var/client/user_client = user.client
	if(!user_client)
		return

	release_click_intercept(user)

	// The game master panel shows the same markers, leave them to it while it is open
	if(user_client.game_master_menu && SStgui.get_open_ui(user, user_client.game_master_menu))
		return

	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		user_client.images -= override.behavior_image

	if(!user_client.game_master_menu)
		GLOB.game_masters -= user_client

/datum/xeno_ai_spawner_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["categories"] = list()
	for(var/caste_category in castes_by_category)
		data["categories"] += list(list(
			"name" = caste_category,
			"castes" = castes_by_category[caste_category],
		))

	data["hives"] = hive_ui_data
	data["behaviors"] = list()
	for(var/behavior in behavior_types)
		data["behaviors"] += behavior
	data["max_count"] = XENO_SPAWNER_MAX_COUNT
	data["max_squad_size"] = XENO_SPAWNER_MAX_SQUAD_SIZE
	data["max_squad_radius"] = XENO_SPAWNER_MAX_SQUAD_RADIUS

	return data

/datum/xeno_ai_spawner_menu/ui_data(mob/user)
	var/list/data = list()

	// Another panel can take the click intercept away from us at any time
	var/intercepting = user.client?.click_intercept == src

	// Spawn stuff
	data["category"] = category
	data["mode"] = mode
	data["selected_hive"] = selected_hives[category]
	data["spawn_ai"] = spawn_ai
	data["selected_caste"] = selected_caste
	data["spawn_count"] = spawn_count
	data["squad"] = get_squad_ui_data()
	data["squad_radius"] = squad_radius
	data["spawn_click_intercept"] = intercepting && current_click_intercept_action == SPAWN_CLICK_INTERCEPT_ACTION

	// Behavior stuff
	data["selected_behavior"] = selected_behavior
	data["behavior_click_intercept"] = intercepting && current_click_intercept_action == BEHAVIOR_CLICK_INTERCEPT_ACTION

	return data

/// Returns the squad as a list of assoc lists that hold "caste", "category" and "count"
/datum/xeno_ai_spawner_menu/proc/get_squad_ui_data()
	var/list/squad_data = list()
	for(var/caste in squad)
		squad_data += list(list(
			"caste" = caste,
			"category" = category_by_caste[caste],
			"count" = squad[caste],
		))

	return squad_data

/datum/xeno_ai_spawner_menu/proc/get_squad_size()
	. = 0
	for(var/caste in squad)
		. += squad[caste]

/datum/xeno_ai_spawner_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)

		//Spawn Section
		if("set_category")
			var/new_category = params["category"]
			if(!castes_by_category[new_category])
				return

			category = new_category
			if(category_by_caste[selected_caste] != category)
				selected_caste = castes_by_category[category][1]
			return TRUE

		if("set_mode")
			var/new_mode = params["mode"]
			if(new_mode != XENO_SPAWNER_MODE_SINGLE && new_mode != XENO_SPAWNER_MODE_SQUAD)
				return

			mode = new_mode
			return TRUE

		if("set_selected_hive")
			var/new_hive = params["hive"]
			if(!(new_hive in ALL_XENO_HIVES))
				return

			selected_hives[category] = new_hive
			return TRUE

		if("toggle_spawn_ai")
			spawn_ai = !spawn_ai
			return TRUE

		if("set_selected_caste")
			var/new_caste = params["caste"]
			if(!category_by_caste[new_caste])
				return

			selected_caste = new_caste
			return TRUE

		if("set_spawn_count")
			var/new_count = text2num(params["count"])
			if(!isnum(new_count))
				return

			spawn_count = clamp(round(new_count), 1, XENO_SPAWNER_MAX_COUNT)
			return TRUE

		if("set_squad_count")
			var/caste = params["caste"]
			if(!category_by_caste[caste])
				return

			var/new_count = text2num(params["count"])
			if(!isnum(new_count))
				return

			var/free_slots = XENO_SPAWNER_MAX_SQUAD_SIZE - get_squad_size() + squad[caste]
			new_count = clamp(round(new_count), 0, min(XENO_SPAWNER_MAX_COUNT, free_slots))
			if(new_count)
				squad[caste] = new_count
			else
				squad -= caste
			return TRUE

		if("clear_squad")
			squad = list()
			return TRUE

		if("set_squad_radius")
			var/new_radius = text2num(params["radius"])
			if(!isnum(new_radius))
				return

			squad_radius = clamp(round(new_radius), 0, XENO_SPAWNER_MAX_SQUAD_RADIUS)
			return TRUE

		if("toggle_click_spawn")
			toggle_click_intercept(ui.user, SPAWN_CLICK_INTERCEPT_ACTION)
			return TRUE

		if("delete_all_xenos")
			if(tgui_alert(ui.user, "Do you want to delete all xenos?", "Confirmation", list("Yes", "No")) != "Yes")
				return

			for(var/mob/living/carbon/xenomorph/cycled_xeno in GLOB.alive_mob_list)
				qdel(cycled_xeno)
			return TRUE

		if("delete_xenos_in_view")
			if(tgui_alert(ui.user, "Do you want to delete all xenos within your view range?", "Confirmation", list("Yes", "No")) != "Yes")
				return

			for(var/mob/living/carbon/xenomorph/viewed_xeno in view(ui.user.client))
				qdel(viewed_xeno)
			return TRUE

		//Behavior Section
		if("set_selected_behavior")
			var/new_behavior = params["behavior"]
			if(!behavior_types[new_behavior])
				return

			selected_behavior = new_behavior
			return TRUE

		if("toggle_click_behavior")
			toggle_click_intercept(ui.user, BEHAVIOR_CLICK_INTERCEPT_ACTION)
			return TRUE

/// Turns the given click intercept on, or off if it is the one already in use
/datum/xeno_ai_spawner_menu/proc/toggle_click_intercept(mob/user, intercept_action)
	var/client/user_client = user.client
	if(!user_client)
		return

	if(current_click_intercept_action == intercept_action && user_client.click_intercept == src)
		current_click_intercept_action = null
		release_click_intercept(user)
		return

	current_click_intercept_action = intercept_action
	user_client.click_intercept = src

/// Stops intercepting clicks, handing them back to the game master panel if it is open
/datum/xeno_ai_spawner_menu/proc/release_click_intercept(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept != src)
		return

	user_client.click_intercept = null
	if(user_client.game_master_menu && SStgui.get_open_ui(user, user_client.game_master_menu))
		user_client.click_intercept = user_client.game_master_menu

/datum/xeno_ai_spawner_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)

	switch(current_click_intercept_action)
		if(SPAWN_CLICK_INTERCEPT_ACTION)
			if(LAZYACCESS(modifiers, MIDDLE_CLICK))
				if(isxeno(object))
					qdel(object)
				else
					open_submenu(user, object)
				return TRUE

			var/turf/spawn_turf = get_turf(object)
			if(!spawn_turf)
				return FALSE

			if(mode == XENO_SPAWNER_MODE_SQUAD)
				spawn_squad(user, spawn_turf)
			else
				spawn_xenos(user, selected_caste, spawn_count, list(spawn_turf))
			return TRUE

		if(BEHAVIOR_CLICK_INTERCEPT_ACTION)
			var/behavior_type = behavior_types[selected_behavior]

			if(LAZYACCESS(modifiers, MIDDLE_CLICK))
				if(object.datum_components?[behavior_type])
					var/component_to_remove = object.datum_components[behavior_type]
					qdel(component_to_remove)
				return TRUE

			object.AddComponent(behavior_type)
			return TRUE

	return FALSE

/// Opens the submenu of the object, reusing the one already made for it
/datum/xeno_ai_spawner_menu/proc/open_submenu(mob/user, atom/object)
	for(var/datum/game_master_submenu/submenu as anything in current_submenus)
		if(submenu.referenced_atom == object)
			submenu.tgui_interact(user)
			return

	for(var/submenu_type in submenu_types)
		if(istype(object, submenu_type))
			var/new_submenu_type = submenu_types[submenu_type]
			var/datum/game_master_submenu/new_submenu = new new_submenu_type(user, object)
			current_submenus += new_submenu
			RegisterSignal(new_submenu, COMSIG_PARENT_QDELETING, PROC_REF(submenu_deleted))
			return

/datum/xeno_ai_spawner_menu/proc/submenu_deleted(datum/game_master_submenu/submenu)
	SIGNAL_HANDLER

	current_submenus -= submenu

/// Spawns amount xenos of the caste, spreading them over spawn_turfs in order
/datum/xeno_ai_spawner_menu/proc/spawn_xenos(mob/user, caste, amount, list/turf/spawn_turfs)
	var/spawning_xeno_type = GLOB.RoleAuthority.get_caste_by_text(caste)
	if(!spawning_xeno_type)
		to_chat(user, SPAN_NOTICE(SPAN_BOLD("Unable to find xeno type by name: [caste]")))
		return

	var/hive = selected_hives[category_by_caste[caste]]
	for(var/i in 1 to amount)
		var/turf/spawn_turf = spawn_turfs[((i - 1) % length(spawn_turfs)) + 1]
		new spawning_xeno_type(spawn_turf, null, hive, !spawn_ai)

/// Spawns the whole squad around center, every caste into the hive selected for its category
/datum/xeno_ai_spawner_menu/proc/spawn_squad(mob/user, turf/center)
	if(!length(squad))
		to_chat(user, SPAN_WARNING("The squad is empty, add some castes to it first."))
		return

	var/list/turf/spawn_turfs = shuffle(get_squad_turfs(center))
	var/spawned = 0
	for(var/caste in squad)
		var/amount = squad[caste]
		// Start where the previous caste stopped, so the squad doesn't pile up on the first turfs
		var/offset = spawned % length(spawn_turfs)
		spawn_xenos(user, caste, amount, spawn_turfs.Copy(offset + 1) + spawn_turfs.Copy(1, offset + 1))
		spawned += amount

/// Returns the turfs within squad_radius of center that can be walked to from it, so nothing ends up behind a wall
/datum/xeno_ai_spawner_menu/proc/get_squad_turfs(turf/center)
	var/list/turf/reachable_turfs = list(center)

	var/checked = 0
	while(checked < length(reachable_turfs))
		checked++
		var/turf/current_turf = reachable_turfs[checked]
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(current_turf, direction)
			if(!neighbor || get_dist(center, neighbor) > squad_radius)
				continue
			if((neighbor in reachable_turfs) || is_blocked_turf(neighbor))
				continue
			reachable_turfs += neighbor

	return reachable_turfs

#undef XENO_SPAWNER_CATEGORY_XENOMORPH
#undef XENO_SPAWNER_CATEGORY_PATHOGEN
#undef XENO_SPAWNER_CASTES
#undef XENO_SPAWNER_DEFAULT_HIVES

#undef XENO_SPAWNER_MODE_SINGLE
#undef XENO_SPAWNER_MODE_SQUAD

#undef XENO_SPAWNER_MAX_COUNT
#undef XENO_SPAWNER_MAX_SQUAD_SIZE
#undef XENO_SPAWNER_DEFAULT_SQUAD_RADIUS
#undef XENO_SPAWNER_MAX_SQUAD_RADIUS

#undef XENO_SPAWNER_BEHAVIORS
#undef XENO_SPAWNER_DEFAULT_BEHAVIOR

#undef SPAWN_CLICK_INTERCEPT_ACTION
#undef BEHAVIOR_CLICK_INTERCEPT_ACTION
