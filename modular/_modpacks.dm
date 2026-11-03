#define INIT_ORDER_MODPACKS 84

SUBSYSTEM_DEF(modpacks)
	name = "Modpacks"
	init_order = INIT_ORDER_MODPACKS
	flags = SS_NO_FIRE
	var/list/loaded_modpacks = list()
	// SS220 DemonicLynx "Lobby UI" - neutral optional provider registration; null preserves all standard fallbacks.
	/// Optional provider for lobby and character-preferences presentation.
	var/datum/modpack/lobby_ui_provider

/datum/controller/subsystem/modpacks/proc/register_lobby_ui_provider(datum/modpack/provider)
	if(!provider)
		return "Lobby UI provider is null"
	if(lobby_ui_provider && lobby_ui_provider != provider)
		return "Lobby UI provider is already registered by [lobby_ui_provider.name]"
	lobby_ui_provider = provider
	return null

/datum/controller/subsystem/modpacks/proc/lobby_ui_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	// SS220 DemonicLynx "Lobby UI" - neutral localization gateway; the standard input list is the fallback.
	if(lobby_ui_provider)
		return lobby_ui_provider.lobby_ui_localized_choice(preferences, user, prompt, title, options)
	return tgui_input_list(user, prompt, title, options)

/datum/controller/subsystem/modpacks/proc/lobby_ui_translate(datum/preferences/preferences, text)
	// SS220 DemonicLynx "Lobby UI" - neutral translation gateway; unchanged text is the fallback.
	return lobby_ui_provider?.lobby_ui_translate_text(preferences, text) || text

/datum/controller/subsystem/modpacks/proc/lobby_ui_text(datum/preferences/preferences, mob/user, prompt, title, default_value, max_length = MAX_MESSAGE_LEN, multiline = FALSE)
	// SS220 DemonicLynx "Lobby UI" - neutral themed text-input gateway; standard TGUI is the fallback.
	if(lobby_ui_provider)
		return lobby_ui_provider.lobby_ui_text_input(preferences, user, prompt, title, default_value, max_length, multiline)
	return tgui_input_text(user, prompt, title, default_value, max_length, multiline, encode = FALSE)

/datum/controller/subsystem/modpacks/proc/lobby_ui_number(datum/preferences/preferences, mob/user, prompt, title, default_value, max_value, min_value)
	// SS220 DemonicLynx "Lobby UI" - neutral themed number-input gateway; standard TGUI is the fallback.
	if(lobby_ui_provider)
		return lobby_ui_provider.lobby_ui_number_input(preferences, user, prompt, title, default_value, max_value, min_value)
	return tgui_input_number(user, prompt, title, default_value, max_value, min_value)

/datum/controller/subsystem/modpacks/Initialize()
	var/list/all_modpacks = list()
	for(var/modpack in subtypesof(/datum/modpack/))
		all_modpacks.Add(new modpack)
	// Pre-init and register all compiled modpacks.
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.pre_initialize()
		if(QDELETED(package))
			CRASH("Modpack of type [package.type] is null or queued for deletion.")
		if(fail_msg)
			CRASH("Modpack [package.name] failed to pre-initialize: [fail_msg].")
		if(loaded_modpacks[package.name])
			CRASH("Attempted to register duplicate modpack name [package.name].")
		loaded_modpacks.Add(package)

	// Handle init and post-init (two stages in case a modpack needs to implement behavior based on the presence of other packs).
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.initialize()
		if(fail_msg)
			CRASH("Modpack [(istype(package) && package.name) || "Unknown"] failed to initialize: [fail_msg]")
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.post_initialize()
		if(fail_msg)
			CRASH("Modpack [(istype(package) && package.name) || "Unknown"] failed to post-initialize: [fail_msg]")

/datum/controller/subsystem/modpacks/proc/get_modpack(modpack_type)
	if(!ispath(modpack_type, /datum/modpack))
		return null

	for(var/datum/modpack/package as anything in loaded_modpacks)
		if(istype(package, modpack_type))
			return package

	return null

/client/verb/modpacks_list()
	set name = "Modpacks List"
	set category = "OOC"

	if(!mob || !SSmodpacks.initialized)
		return

	if(length(SSmodpacks.loaded_modpacks))
		. = "<hr><br><center><b><font size = 3>Список модификаций</font></b></center><br><hr><br>"
		for(var/datum/modpack/M as anything in SSmodpacks.loaded_modpacks)
			if(M.name)
				. += "<div class = 'statusDisplay'>"
				. += "<center><b>[M.name]</b></center>"

				if(M.desc || M.author)
					. += "<br>"
					if(M.desc)
						. += "<br>Описание: [M.desc]"
					if(M.author)
						. += "<br><i>Автор: [M.author]</i>"
				. += "</div><br>"

		var/datum/browser/popup = new(mob, "modpacks_list", "Список Модификаций", 480, 580)
		popup.set_content(.)
		popup.open()
	else
		to_chat(src, "Этот сервер не использует какие-либо модификации.")
