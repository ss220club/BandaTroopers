/// Registry-owned immutable assets. URLs are resolved through the existing asset transport.
/datum/gear
	var/banda_catalog_asset_key

/datum/preferences
	var/banda_loadout_open = FALSE
	var/banda_loadout_building = FALSE

/// Own the close callback; the generic browser callback must not overwrite it later.
/datum/browser/banda_loadout
	var/datum/preferences/preferences
	var/generation

/datum/browser/banda_loadout/setup_onclose()
	set waitfor = FALSE
	for(var/attempt in 1 to 10)
		if(!user || !preferences.is_banda_loadout_request(user.mob, generation))
			return
		if(winexists(user, window_id))
			if(preferences.is_banda_loadout_request(user.mob, generation))
				onclose(user, window_id, user, list("_src_" = "prefs", "preference" = "loadout", "task" = "close_picker", "generation" = generation))
			return

/datum/preferences/proc/get_banda_loadout_total_cost()
	var/total_cost = 0
	for(var/gear_name in gear)
		var/datum/gear/gear_entry = GLOB.gear_datums_by_name[gear_name]
		total_cost += gear_entry?.cost
	return total_cost

/datum/preferences/proc/get_banda_loadout_preview(datum/gear/gear_entry, client/viewer)
	if(!gear_entry?.path || !viewer || !ispath(gear_entry.path, /atom))
		return ""
	if(!gear_entry.banda_catalog_asset_key)
		var/atom/item_path = gear_entry.path
		var/icon_file = initial(item_path.icon)
		var/icon_state = initial(item_path.icon_state)
		if(!icon_file || isnull(icon_state) || !icon_exists(icon_file, icon_state))
			return ""
		var/icon/item_preview = icon(icon_file, icon_state, SOUTH)
		var/item_color = initial(item_path.color)
		if(item_color && item_color != "#FFFFFF")
			item_preview.Blend(item_color, ICON_MULTIPLY)
		gear_entry.banda_catalog_asset_key = icon2html(item_preview, viewer, keyonly = TRUE)
	else
		SSassets.transport.send_assets(viewer, gear_entry.banda_catalog_asset_key)
	var/item_url = SSassets.transport.get_asset_url(gear_entry.banda_catalog_asset_key)
	return "<img class='loadout-sprite' src='[item_url]' alt=''>"

/datum/preferences/proc/get_banda_loadout_presentation_steps()
	if(uses_banda_english_interface())
		var/static/list/english_steps = list(
			"ESTABLISHING ARCHIVE CONNECTION...",
			"VERIFYING PERSONAL IDENTIFIER...",
			"PERSONAL IDENTIFIER CONFIRMED...",
			"INDEXING STORAGE CATALOG...",
			"LOADING AVAILABLE EQUIPMENT LIST...",
			"FORMING CATALOG...",
			"CHECKING THE MONKEY AT THE WORKSTATION...",
			"PREPARING ISSUE TERMINAL...",
			"EQUIPMENT CATALOG CONFIRMED",
		)
		return english_steps
	var/static/list/russian_steps = list(
		"УСТАНОВКА СОЕДИНЕНИЯ С АРХИВОМ...",
		"ПРОВЕРКА ЛИЧНОГО ИДЕНТИФИКАТОРА...",
		"ЛИЧНЫЙ ИДЕНТИФИКАТОР ПОДТВЕРЖДЕН...",
		"ИНДЕКСАЦИЯ СКЛАДСКОГО КАТАЛОГА...",
		"ЗАГРУЗКА СПИСКА ДОСТУПНОГО СНАРЯЖЕНИЯ...",
		"ФОРМИРОВАНИЕ СПИСКА...",
		"ПРОВЕРКА МАРТЫШКИ НА РАБОЧЕМ МЕСТЕ...",
		"ПОДГОТОВКА ТЕРМИНАЛА ВЫДАЧИ...",
		"КАТАЛОГ СНАРЯЖЕНИЯ ПОДТВЕРЖДЕН",
	)

	return russian_steps

/// Open once. The browser requests data only after installing its receiver.
/datum/preferences/proc/show_banda_loadout_picker(mob/user)
	if(!user?.client)
		return
	var/generation = ++banda_loadout_render_generation
	banda_loadout_open = TRUE
	banda_loadout_building = FALSE
	var/datum/asset/simple/banda_terminal/assets = get_asset_datum(/datum/asset/simple/banda_terminal)
	var/list/urls = assets.get_url_mappings()
	var/english = uses_banda_english_interface()
	var/dat = get_banda_accessory_picker_styles()
	dat += get_banda_terminal_styles("loadout")
	dat += "<div id='bandaLoadout' class='picker-crt[get_banda_terminal_effect_class()][get_banda_terminal_glow_class()]' data-generation='[generation]' data-equipped='[english ? "EQUIPPED" : "ЭКИПИРОВАНО"]' data-points='[english ? "PTS" : "ОЧК."]' style='[get_banda_terminal_palette_style()]'><div class='picker-terminal'>"
	dat += "<div class='picker-header'><div class='picker-heading'><div class='picker-title'>[english ? "LOADOUT CATALOG" : "КАТАЛОГ ЛОДАУТА"]</div><div class='picker-subtitle'>[english ? "ARCHIVE DATA INITIALIZATION" : "ИНИЦИАЛИЗАЦИЯ ДАННЫХ АРХИВА"]</div></div><div class='picker-actions'>"
	dat += "<a id='loadoutReset' class='picker-close' style='display:none' href='byond://?_src_=prefs;preference=loadout;task=reset_picker;generation=[generation]'>[english ? "RESET" : "СБРОСИТЬ"]</a><a class='picker-close' href='byond://?_src_=prefs;preference=loadout;task=close_picker;generation=[generation]'>[english ? "CLOSE" : "ЗАКРЫТЬ"]</a></div></div>"
	dat += "<div id='loadoutLoader' class='loadout-loader'>"
	var/list/steps = get_banda_loadout_presentation_steps()
	for(var/index in 1 to length(steps))
		dat += "<div class='loadout-command' style='display:[index == 1 ? "flex" : "none"]'><span class='loadout-command-text'>&gt; [steps[index]]</span><span class='loadout-command-status'>&#91; ... &#93;</span></div>"
	dat += "<div id='loadoutWait' class='loadout-final-wait' style='display:none'>&gt; [english ? "LOADING DATA" : "ЗАГРУЗКА ДАННЫХ"]<span class='loadout-wait-dots'><span>.</span><span>.</span><span>.</span></span></div></div><div id='loadoutCatalog' style='display:none'></div></div></div><script src='[urls["banda-loadout.js"]]'></script>"
	var/datum/browser/banda_loadout/popup = new(user, "banda_loadout_picker", english ? "Loadout Catalog" : "Каталог лодаута", GLOB.stylesheets[stylesheet] || GLOB.stylesheets["Modern"], 900, 720)
	popup.preferences = src
	popup.generation = generation
	popup.set_content(dat)
	popup.open()

/datum/preferences/proc/is_banda_loadout_request(mob/user, generation)
	return user?.client == owner && owner && uses_banda_terminal_interface() && banda_loadout_open && generation == banda_loadout_render_generation

/datum/preferences/proc/send_banda_loadout_update(mob/user, generation, list/payload)
	if(!is_banda_loadout_request(user, generation))
		return
	payload["generation"] = generation
	user << output(list2params(list(json_encode(payload))), "banda_loadout_picker.browser:receiveBandaLoadout")

/// No HTML rebuild, sorting or image work on a selection change.
/datum/preferences/proc/refresh_banda_loadout_picker(mob/user)
	var/list/equipped = list()
	for(var/gear_name in gear)
		var/datum/gear/entry = GLOB.gear_datums_by_name[gear_name]
		if(entry)
			equipped += "loadout-[md5(REF(entry))]"
	var/total_cost = get_banda_loadout_total_cost()
	var/summary = "[uses_banda_english_interface() ? "POINTS USED" : "ИСПОЛЬЗОВАНО ОЧКОВ"]: [total_cost] / [MAX_GEAR_COST] // [uses_banda_english_interface() ? "REMAINING" : "ОСТАЛОСЬ"]: [MAX_GEAR_COST - total_cost]"
	send_banda_loadout_update(user, banda_loadout_render_generation, list("equipped" = equipped, "summary" = summary, "error_feedback" = banda_loadout_error_feedback))
	banda_loadout_error_feedback = FALSE

/// This registry is initialized once; category keys are labels including the price.
/datum/preferences/proc/get_banda_sorted_loadout_catalog()
	var/static/list/catalog
	if(!catalog)
		catalog = list()
		for(var/category in sortList(GLOB.gear_datums_by_category))
			catalog[category] = sortList(GLOB.gear_datums_by_category[category])
	return catalog

/datum/preferences/proc/prepare_banda_loadout_picker(mob/user, generation)
	if(!is_banda_loadout_request(user, generation) || banda_loadout_building)
		return
	banda_loadout_building = TRUE
	if(!islist(GLOB.gear_datums_by_category))
		send_banda_loadout_update(user, generation, list("error" = uses_banda_english_interface() ? "CATALOG UNAVAILABLE" : "КАТАЛОГ НЕДОСТУПЕН"))
		return
	var/list/catalog = get_banda_sorted_loadout_catalog()
	var/dat = "<div id='loadoutSummary' class='loadout-summary'></div>"
	var/category_index = 0
	for(var/category in catalog)
		category_index++
		var/list/items = catalog[category]
		var/list/category_gear = GLOB.gear_datums_by_category[category]
		var/content_id = "loadout-category-[category_index]"
		dat += "<div class='loadout-category'><a class='loadout-category-toggle' href='#' onclick=\"toggleLoadoutCategory('[content_id]', this); return false;\"><span class='loadout-category-marker'>&#91;+&#93;</span><span class='loadout-category-name'>[html_encode(banda_translate_loadout_label(category, banda_interface_language))]</span><span class='loadout-category-count'>[length(items)]</span></a><div id='[content_id]' class='loadout-category-items' style='display:none'>"
		for(var/gear_label in items)
			CHECK_TICK
			if(!is_banda_loadout_request(user, generation))
				return
			var/datum/gear/entry = category_gear[gear_label]
			if(!entry)
				continue
			var/preview = get_banda_loadout_preview(entry, user.client)
			dat += "<a id='loadout-[md5(REF(entry))]' class='loadout-card' href='byond://?_src_=prefs;preference=loadout;task=toggle;gear=\ref[entry];generation=[generation]'><span class='loadout-sprite-box'>[preview]</span><span class='loadout-card-name'>[html_encode(banda_translate_loadout_label(entry.display_name, banda_interface_language))]</span><span class='loadout-card-cost'>[entry.cost] [uses_banda_english_interface() ? "PTS" : "ОЧК."]</span><span class='loadout-card-state'></span></a>"
		dat += "</div></div>"
	// Actual HTML and assets are prepared before the client may complete its sequence.
	send_banda_loadout_update(user, generation, list("html" = dat))
	if(is_banda_loadout_request(user, generation))
		refresh_banda_loadout_picker(user)
