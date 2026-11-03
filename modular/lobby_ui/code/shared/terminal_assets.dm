/// Static resources are sent through the existing asset cache, never embedded per refresh.
/datum/asset/simple/banda_terminal
	assets = list(
		"banda-grand-pixel.ttf" = 'interface/Grand9K_Pixel.ttf',
		"banda-pix-cyrillic.ttf" = 'interface/Pix_Cyrillic.ttf',
		"banda-character.css" = 'modular/lobby_ui/assets/character.css',
		"banda-auxiliary.css" = 'modular/lobby_ui/assets/auxiliary.css',
		"banda-picker.css" = 'modular/lobby_ui/assets/picker.css',
		"banda-loadout.css" = 'modular/lobby_ui/assets/loadout.css',
		"banda-manifest.css" = 'modular/lobby_ui/assets/manifest.css',
		"banda-lobby.css" = 'modular/lobby_ui/assets/lobby.css',
		"banda-terminal.css" = 'modular/lobby_ui/assets/terminal.css',
		"banda-terminal.js" = 'modular/lobby_ui/assets/terminal.js',
		"banda-loadout.js" = 'modular/lobby_ui/assets/loadout.js',
		"banda-accessory.js" = 'modular/lobby_ui/assets/accessory.js',
	)

/datum/preferences/proc/get_banda_terminal_styles(sheet)
	var/datum/asset/simple/banda_terminal/assets = get_asset_datum(/datum/asset/simple/banda_terminal)
	var/list/urls = assets.get_url_mappings()
	var/font_size_offset = get_banda_terminal_font_size_offset(sheet)
	var/key = get_banda_terminal_stylesheet_key(sheet, font_size_offset)
	// The shared sheet is loaded second and owns the final root inheritance rule.
	var/shared_key = get_banda_terminal_stylesheet_key("terminal", font_size_offset)
	SSassets.transport.send_assets(owner, list(key, shared_key, "banda-terminal.js", "banda-loadout.js"))
	if(sheet == "lobby")
		SSassets.transport.send_assets(owner, list("banda-grand-pixel.ttf", "banda-pix-cyrillic.ttf"))
	return "<link rel='stylesheet' href='[SSassets.transport.get_asset_url(key)]'><link rel='stylesheet' href='[SSassets.transport.get_asset_url(shared_key)]'><script src='[urls["banda-terminal.js"]]'></script>"

/datum/preferences/proc/get_banda_terminal_stylesheet_key(sheet, font_size_offset = null)
	var/datum/asset/simple/banda_terminal/assets = get_asset_datum(/datum/asset/simple/banda_terminal)
	var/static/list/templates = list()
	var/resource = "banda-[sheet].css"
	if(isnull(font_size_offset))
		font_size_offset = get_banda_terminal_font_size_offset(sheet)
	if(!templates[resource])
		var/datum/asset_cache_item/template = assets.assets[resource]
		templates[resource] = file2text(template.resource)
	// Native browse windows can still use Trident: resolve CSS variables server-side.
	// The immutable result is cached by content, so refreshes never resend/rebuild it.
	var/list/colors = get_banda_terminal_palette()
	var/list/font_urls = list("Grand9K_Pixel.ttf" = SSassets.transport.get_asset_url("banda-grand-pixel.ttf"), "Pix_Cyrillic.ttf" = SSassets.transport.get_asset_url("banda-pix-cyrillic.ttf"))
	var/key = "banda-style-[md5("text-v4|[sheet]|[md5(templates[resource])]|[json_encode(colors)]|[json_encode(font_urls)]|[banda_terminal_font]|[banda_terminal_font_size]|[font_size_offset]")].css"
	if(!SSassets.cache[key])
		var/css = apply_banda_terminal_typography(templates[resource], font_size_offset)
		for(var/token in colors)
			css = replacetext(css, "var([token])", colors[token])
		for(var/font in font_urls)
			css = replacetext(css, "url('[font]')", "url('[font_urls[font]]')")
		var/temp_path = "data/[key]"
		if(fexists(temp_path))
			fdel(temp_path)
		text2file(css, temp_path)
		SSassets.transport.register_asset(key, fcopy_rsc(temp_path))
		fdel(temp_path)
	return key

/datum/preferences/proc/get_banda_terminal_palette()
	var/list/channels = ReadRGB(banda_terminal_interface_color)
	var/contrast = (channels[1] * 299 + channels[2] * 587 + channels[3] * 114) >= 128000 ? "#050805" : "#ffffff"
	return list(
		"--banda-accent-color" = banda_terminal_interface_color,
		"--banda-accent-rgb" = "[channels[1]], [channels[2]], [channels[3]]",
		"--banda-text-color" = banda_terminal_text_color || initial(banda_terminal_text_color),
		"--banda-on-accent" = contrast,
	)

/datum/preferences/proc/get_banda_terminal_palette_style()
	var/list/colors = get_banda_terminal_palette()
	var/list/declarations = list()
	for(var/token in colors)
		declarations += "[token]: [colors[token]];"
	return jointext(declarations, " ")
