/datum/preferences/proc/get_banda_valid_accessory_styles(facial = FALSE)
	var/list/valid_styles = list()
	var/list/source_styles = facial ? GLOB.facial_hair_styles_list : GLOB.hair_styles_list

	for(var/style_name in source_styles)
		var/datum/sprite_accessory/accessory = source_styles[style_name]
		if(!accessory || !(species in accessory.species_allowed) || !accessory.selectable)
			continue
		valid_styles[style_name] = accessory

	return valid_styles

/datum/preferences
	/// At most one hair palette and one facial-hair palette per preferences datum.
	var/list/banda_accessory_preview_keys = list()
	var/list/banda_accessory_preview_colors = list()

/datum/preferences/proc/get_banda_accessory_preview(datum/sprite_accessory/accessory, client/viewer, facial = FALSE)
	if(!accessory || !viewer || !accessory.icon || isnull(accessory.icon_state))
		return "<span class='picker-no-preview'>NO IMAGE</span>"
	var/kind = facial ? "facial" : "hair"
	var/accessory_color = facial ? rgb(r_facial, g_facial, b_facial) : rgb(r_hair, g_hair, b_hair)
	if(banda_accessory_preview_colors[kind] != accessory_color)
		banda_accessory_preview_colors[kind] = accessory_color
		banda_accessory_preview_keys[kind] = list()
	var/list/keys = banda_accessory_preview_keys[kind]
	var/key = keys[accessory.type]
	if(!key)
		var/image/appearance = image(icon = accessory.icon, icon_state = "[accessory.icon_state]_s", dir = SOUTH)
		if(accessory.do_coloration)
			appearance.color = list(null, null, null, null, accessory_color)
		var/icon/preview = getFlatIcon(appearance, defdir = SOUTH, no_anim = TRUE)
		if(!preview)
			return "<span class='picker-no-preview'>NO IMAGE</span>"
		key = icon2html(preview, viewer, keyonly = TRUE)
		keys[accessory.type] = key
	else
		SSassets.transport.send_assets(viewer, key)
	var/position_class = facial ? " picker-sprite-facial" : " picker-sprite-hair"
	return "<img class='picker-sprite[position_class]' src='[SSassets.transport.get_asset_url(key)]' alt='Accessory preview'>"

/datum/preferences/proc/get_banda_accessory_picker_styles()
	return {"
		[get_banda_terminal_styles("picker")]
		[get_banda_character_preferences_translation_script(banda_interface_language)]
	"}

/datum/preferences
	var/banda_accessory_generation = 0
	var/list/banda_accessory_requests = list()

/datum/preferences/proc/get_banda_accessory_context(kind)
	return md5(json_encode(list(default_slot, species, kind == "facial" ? list(r_facial, g_facial, b_facial) : list(r_hair, g_hair, b_hair), banda_interface_language, banda_terminal_interface_color, banda_terminal_text_color, banda_terminal_font, banda_terminal_font_size, banda_terminal_glow, banda_terminal_effect_intensity)))

/datum/preferences/proc/close_banda_accessory_picker(kind)
	banda_accessory_requests -= kind
	if(owner)
		close_browser(owner, kind == "facial" ? "banda_facial_hair_picker" : "banda_hair_picker")

/datum/preferences/proc/close_banda_accessory_pickers(stale_only = FALSE)
	for(var/kind in banda_accessory_requests.Copy())
		var/list/request = banda_accessory_requests[kind]
		if(!stale_only || request["context"] != get_banda_accessory_context(kind))
			close_banda_accessory_picker(kind)

/datum/preferences/proc/is_banda_accessory_request(mob/user, kind, generation)
	var/list/request = banda_accessory_requests[kind]
	return owner && user?.client == owner && uses_banda_terminal_interface() && request && request["generation"] == generation && request["context"] == get_banda_accessory_context(kind)

/datum/browser/banda_accessory
	var/datum/preferences/preferences
	var/kind
	var/generation

/datum/browser/banda_accessory/setup_onclose()
	set waitfor = FALSE
	for(var/attempt in 1 to 10)
		if(!user || !preferences.is_banda_accessory_request(user.mob, kind, generation))
			return
		if(winexists(user, window_id))
			if(preferences.is_banda_accessory_request(user.mob, kind, generation))
				onclose(user, window_id, user, list("_src_" = "prefs", "preference" = "close_accessory_picker", "kind" = kind, "generation" = generation))
			return

/// First paint contains the first command. Expensive icon work starts only on ready.
/datum/preferences/proc/show_banda_accessory_picker(mob/user, facial = FALSE)
	if(user?.client != owner || !owner || !uses_banda_terminal_interface())
		return
	var/kind = facial ? "facial" : "hair"
	var/generation = ++banda_accessory_generation
	banda_accessory_requests[kind] = list("generation" = generation, "context" = get_banda_accessory_context(kind), "building" = FALSE)
	var/english = uses_banda_english_interface()
	var/window_title = english ? (facial ? "Facial Hair" : "Hairstyle") : (facial ? "Растительность на лице" : "Причёска")
	var/catalog_title = english ? (facial ? "FACIAL HAIR SELECTION" : "HAIRSTYLE SELECTION") : (facial ? "ВЫБОР РАСТИТЕЛЬНОСТИ НА ЛИЦЕ" : "ВЫБОР ПРИЧЁСКИ")
	var/datum/asset/simple/banda_terminal/assets = get_asset_datum(/datum/asset/simple/banda_terminal)
	var/list/urls = assets.get_url_mappings()
	SSassets.transport.send_assets(owner, "banda-accessory.js")
	var/dat = get_banda_accessory_picker_styles()
	dat += get_banda_terminal_styles("loadout")
	dat += "<div id='bandaAccessory' class='picker-crt[get_banda_terminal_effect_class()][get_banda_terminal_glow_class()]' data-generation='[generation]' data-kind='[kind]' data-subtitle='[english ? "SELECT A STYLE BY ITS PREVIEW" : "ВЫБЕРИТЕ ВАРИАНТ ПО СПРАЙТУ"]' style='[get_banda_terminal_palette_style()]'><div class='picker-terminal'>"
	dat += "<div class='picker-header'><div class='picker-heading'><div class='picker-title'>[catalog_title]</div><div class='picker-subtitle'>[english ? "ARCHIVE DATA INITIALIZATION" : "ИНИЦИАЛИЗАЦИЯ ДАННЫХ АРХИВА"]</div></div>"
	dat += "<a class='picker-close' href='byond://?_src_=prefs;preference=close_accessory_picker;kind=[kind];generation=[generation]'>[english ? "CLOSE" : "ЗАКРЫТЬ"]</a></div><div id='accessoryLoader' class='loadout-loader'>"
	var/list/steps = english ? list("ESTABLISHING ARCHIVE CONNECTION...", "VERIFYING PERSONAL IDENTIFIER...", "PERSONAL IDENTIFIER CONFIRMED...", "INDEXING STYLE CATALOG...", "LOADING AVAILABLE STYLES...", "APPLYING SELECTED COLOR...", "CHECKING THE MONKEY AT THE WORKSTATION...", "PREPARING STYLE PREVIEWS...", "STYLE CATALOG CONFIRMED") : list("УСТАНОВКА СОЕДИНЕНИЯ С АРХИВОМ...", "ПРОВЕРКА ЛИЧНОГО ИДЕНТИФИКАТОРА...", "ЛИЧНЫЙ ИДЕНТИФИКАТОР ПОДТВЕРЖДЕН...", "ИНДЕКСАЦИЯ КАТАЛОГА ВНЕШНОСТИ...", "ЗАГРУЗКА ДОСТУПНЫХ ВАРИАНТОВ...", "ПРИМЕНЕНИЕ ВЫБРАННОГО ЦВЕТА...", "ПРОВЕРКА МАРТЫШКИ НА РАБОЧЕМ МЕСТЕ...", "ПОДГОТОВКА ОБРАЗОВ ВНЕШНОСТИ...", "КАТАЛОГ ВНЕШНОСТИ ПОДТВЕРЖДЕН")
	for(var/index in 1 to length(steps))
		dat += "<div class='loadout-command' style='display:[index == 1 ? "flex" : "none"]'><span class='loadout-command-text'>&gt; [steps[index]]</span><span class='loadout-command-status'>&#91; ... &#93;</span></div>"
	dat += "<div id='accessoryWait' class='loadout-final-wait' style='display:none'>&gt; [english ? "LOADING DATA" : "ЗАГРУЗКА ДАННЫХ"]<span class='loadout-wait-dots'><span>.</span><span>.</span><span>.</span></span></div></div><div id='accessoryCatalog' class='picker-scroll' style='display:none'></div></div></div>"
	dat += "<script src='[urls["banda-loadout.js"]]'></script><script src='[urls["banda-accessory.js"]]'></script>"
	var/datum/browser/banda_accessory/popup = new(user, facial ? "banda_facial_hair_picker" : "banda_hair_picker", window_title, GLOB.stylesheets[stylesheet] || GLOB.stylesheets["Modern"], 850, 680)
	popup.preferences = src
	popup.kind = kind
	popup.generation = generation
	popup.set_content(dat)
	popup.open()

/datum/preferences/proc/send_banda_accessory_update(mob/user, kind, generation, list/payload)
	if(!is_banda_accessory_request(user, kind, generation))
		return
	payload["generation"] = generation
	var/window_id = kind == "facial" ? "banda_facial_hair_picker" : "banda_hair_picker"
	user << output(list2params(list(json_encode(payload))), "[window_id].browser:receiveBandaAccessory")

/datum/preferences/proc/prepare_banda_accessory_picker(mob/user, kind, generation)
	if(!is_banda_accessory_request(user, kind, generation))
		return
	var/list/request = banda_accessory_requests[kind]
	if(request["building"])
		return
	request["building"] = TRUE
	var/facial = kind == "facial"
	var/list/styles = get_banda_valid_accessory_styles(facial)
	var/english = uses_banda_english_interface()
	var/dat = "<div class='picker-grid'>"
	if(!length(styles))
		dat += "<div class='picker-empty'>[english ? "NO AVAILABLE STYLES" : "НЕТ ДОСТУПНЫХ ВАРИАНТОВ"]</div>"
	for(var/style_name in sortList(styles))
		CHECK_TICK
		if(!is_banda_accessory_request(user, kind, generation))
			return
		var/datum/sprite_accessory/accessory = styles[style_name]
		var/preview = get_banda_accessory_preview(accessory, user.client, facial)
		var/label = html_encode(english ? style_name : banda_translate_character_preference_text(style_name))
		dat += "<a id='accessory-[md5(REF(accessory))]' class='picker-card' data-selected-label='[english ? "SELECTED" : "ВЫБРАНО"]' href='byond://?_src_=prefs;preference=select_accessory_style;kind=[kind];generation=[generation];accessory=\ref[accessory]'><span class='picker-sprite-box'>[preview]</span><span class='picker-label'>[label]</span></a>"
	dat += "</div>"
	var/current_style = facial ? f_style : h_style
	send_banda_accessory_update(user, kind, generation, list("html" = dat, "selected" = "accessory-[md5(REF(styles[current_style]))]"))

/datum/preferences/proc/select_banda_accessory_style(datum/sprite_accessory/selected_accessory, facial = FALSE)
	if(!selected_accessory)
		return FALSE

	var/list/valid_styles = get_banda_valid_accessory_styles(facial)
	for(var/style_name in valid_styles)
		if(valid_styles[style_name] != selected_accessory)
			continue
		if(facial)
			f_style = style_name
		else
			h_style = style_name
		return TRUE

	return FALSE
