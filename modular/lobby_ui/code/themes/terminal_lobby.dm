// DemonicLynx for BandaMarines

/mob/new_player
	var/banda_lobby_intro_played = FALSE
	var/banda_last_briefing_text
	var/banda_lobby_visible = FALSE
	var/banda_lobby_render_generation = 0

/mob/new_player/proc/show_terminal_lobby(refresh = FALSE)
	if(!client)
		return
	client.prefs.banda_character_editor_open = FALSE
	close_browser(src, "playersetup")
	banda_lobby_visible = TRUE
	var/render_generation = ++banda_lobby_render_generation
	var/datum/preferences/preferences = client.prefs
	var/preview_pending = SSticker.current_state < GAME_STATE_PREGAME
	if(preview_pending)
		RegisterSignal(SSdcs, COMSIG_GLOB_MODE_PREGAME_LOBBY, PROC_REF(on_banda_lobby_pregame), override = TRUE)
	else
		UnregisterSignal(SSdcs, COMSIG_GLOB_MODE_PREGAME_LOBBY)
	var/effect_class = preferences?.get_banda_terminal_effect_class() || ""
	var/glow_class = preferences?.get_banda_terminal_glow_class() || ""
	var/effects_enabled = preferences?.uses_banda_terminal_decorative_effects()
	var/play_lobby_intro = !banda_lobby_intro_played && effects_enabled
	banda_lobby_intro_played = TRUE
	var/lobby_intro_class = play_lobby_intro ? " booting" : ""
	if(play_lobby_intro)
		play_banda_lobby_startup_effect()
		addtimer(CALLBACK(src, PROC_REF(play_banda_lobby_authorized_effect), render_generation), 27)

	var/round_pending = !SSticker || !SSticker.mode || SSticker.current_state <= GAME_STATE_PREGAME
	var/primary_choice
	var/primary_title
	var/primary_subtitle
	var/primary_icon
	var/primary_state_class

	if(round_pending)
		primary_choice = ready ? "unready" : "ready"
		primary_title = ready ? "ГОТОВ" : "НЕ ГОТОВ"
		primary_subtitle = ready ? "Ожидание начала операции" : "Нажмите, чтобы подтвердить"
		primary_icon = ready ? "<svg viewBox='0 0 64 64'><rect x='12' y='12' width='40' height='40'/><path d='M20 33l8 8 17-21'/></svg>" : "<svg viewBox='0 0 64 64'><rect x='12' y='12' width='40' height='40'/><path d='M21 32h22'/></svg>"
		primary_state_class = ready ? "ready-active" : "ready-inactive"
	else
		primary_choice = "late_join"
		primary_title = "ПРИСОЕДИНИТЬСЯ"
		primary_subtitle = "Войти в текущий раунд"
		primary_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><path d='M18 10l38 22-38 22z'/></svg>"
		primary_state_class = "join-active"

	var/text_override_class = preferences?.get_banda_terminal_text_override_class() || ""
	var/text_override_style = preferences?.get_banda_terminal_palette_style() || ""
	var/character_highlight_class = preferences?.banda_lobby_character_highlight ? " character-highlight" : ""
	var/character_name = html_encode(preferences?.real_name || client.key || "НЕИЗВЕСТНО")
	var/character_age = preferences ? html_encode("[preferences.age]") : "—"
	var/character_gender = "—"
	var/character_species = "—"
	var/character_body_size = "—"
	var/character_body_type = "—"
	var/character_origin = "—"
	var/character_squad = "—"
	var/character_job = "—"
	var/character_wy_relation = "—"

	if(preferences)
		character_gender = preferences.gender == MALE ? "МУЖСКОЙ" : "ЖЕНСКИЙ"
		character_species = html_encode(banda_translate_character_preference_text(preferences.species || "—"))
		character_body_size = html_encode(banda_translate_character_preference_text(preferences.body_size || "—"))
		character_body_type = html_encode(banda_translate_character_preference_text(preferences.body_type || "—"))
		character_origin = html_encode(banda_translate_character_preference_text(preferences.origin || "—"))
		if(preferences.preferred_squad && preferences.preferred_squad != "None")
			character_squad = html_encode(banda_translate_character_preference_text(preferences.preferred_squad))
		var/list/high_priority_jobs = preferences.get_jobs_by_priority(HIGH_PRIORITY)
		if(length(high_priority_jobs))
			var/preferred_job_bucket = high_priority_jobs[1]
			var/preferred_job_title = GLOB.RoleAuthority?.get_active_role_title_for_preference_bucket(preferred_job_bucket) || preferred_job_bucket
			var/datum/job/preferred_job
			if(GLOB.RoleAuthority)
				preferred_job = GLOB.RoleAuthority.roles_by_name[preferred_job_title]
			character_job = html_encode(preferred_job?.disp_title || preferred_job?.title || preferred_job_bucket)
		character_wy_relation = html_encode(banda_translate_character_preference_text(preferences.weyland_yutani_relation || "—"))

	var/character_image
	if(preferences)
		var/character_url = preferences.get_banda_lobby_preview_asset(client)
		if(character_url)
			character_image = "<img class='character-sprite[character_highlight_class]' src='[character_url]' alt='[character_name]'>"

	if(!character_image)
		var/placeholder = preview_pending ? "ПОДГОТОВКА ИЗОБРАЖЕНИЯ..." : "НЕТ ИЗОБРАЖЕНИЯ"
		if(preferences?.uses_banda_english_interface())
			placeholder = preview_pending ? "PREPARING PREVIEW..." : "NO PREVIEW"
		character_image = "<div class='character-fallback'>[placeholder]</div>"

	var/mission_details = "ОЖИДАНИЕ ОПЕРАТИВНОЙ СВОДКИ...<span class='terminal-cursor'>&#9608;</span>"
	var/mission_typewriter_source = ""
	var/mission_typing_class = ""
	var/datum/custom_event_info/global_event = GLOB.custom_event_info_list?["Global"]
	if(global_event?.msg)
		var/briefing_text = "[global_event.msg]"
		var/safe_briefing = html_encode(briefing_text)
		mission_details = replacetext(safe_briefing, "\n", "<br>")
		if(briefing_text != banda_last_briefing_text)
			banda_last_briefing_text = briefing_text
			if(effects_enabled)
				mission_details = ""
				mission_typing_class = " typing"
				mission_typewriter_source = "<textarea id='missionTypewriterSource' class='mission-typewriter-source'>[safe_briefing]</textarea>"
				var/typewriter_sound_delay = max(1, CEILING(length(briefing_text) / 25, 1))
				addtimer(CALLBACK(src, PROC_REF(play_banda_lobby_type_complete_effect), briefing_text, render_generation), typewriter_sound_delay)
	else
		banda_last_briefing_text = null

	var/source_ref = "\ref[src]"
	var/brand_icon = "<svg viewBox='0 0 72 82'><path d='M8 8v34l28 27 28-27V8L36 35z'/><path d='M8 8l28 27L64 8'/><path d='M18 50l18 18 18-18'/></svg>"
	var/character_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><circle cx='32' cy='20' r='11'/><path d='M12 53c1-14 9-21 20-21s19 7 20 21z'/></svg>"
	var/manifest_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><circle cx='32' cy='18' r='8'/><circle cx='14' cy='24' r='6'/><circle cx='50' cy='24' r='6'/><path d='M19 53c0-13 5-22 13-22s13 9 13 22zM3 52c0-11 4-19 11-19 4 0 7 2 9 6-3 4-5 8-5 13zM46 52c0-5-2-9-5-13 2-4 5-6 9-6 7 0 11 8 11 19z'/></svg>"
	var/observe_icon = "<svg viewBox='0 0 64 64'><path d='M5 32s10-17 27-17 27 17 27 17-10 17-27 17S5 32 5 32z'/><circle cx='32' cy='32' r='9' class='icon-fill'/></svg>"
	var/html = {"
		[preferences.get_banda_terminal_styles("lobby")]
		<div class='crt-shell[lobby_intro_class][text_override_class][effect_class][glow_class]' style='[text_override_style]'>
			<div class='crt-speckle'></div>
			<div class='signal-interference'></div>
			<div class='crt-frame'></div>
			<div class='boot-flare'></div>
			<div class='terminal'>
				<div class='brand'>
					<div class='brand-line'>
						<div class='brand-rule'>-----</div>
						<div class='brand-main'><div class='brand-mark'>[brand_icon]</div><div class='brand-title'>ТЕРМИНАЛ ПЕРСОНАЛА</div></div>
						<div class='brand-rule'>-----</div>
					</div>
					<div class='system-status'>&#9679; СИСТЕМА АКТИВНА</div>
				</div>
				<div class='main-grid'>
					<div class='menu'>
						<a class='menu-item primary [primary_state_class]' href='byond://?src=[source_ref];lobby_choice=[primary_choice]'><span class='menu-icon'>[primary_icon]</span><span class='menu-copy'><span class='menu-title'>[primary_title]</span><span class='menu-subtitle'>[primary_subtitle]</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=show_preferences'><span class='menu-icon'>[character_icon]</span><span class='menu-copy'><span class='menu-title'>ПЕРСОНАЖ</span><span class='menu-subtitle'>Настройка персонажа</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=manifest'><span class='menu-icon'>[manifest_icon]</span><span class='menu-copy'><span class='menu-title'>МАНИФЕСТ</span><span class='menu-subtitle'>Список текущего экипажа</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=observe'><span class='menu-icon'>[observe_icon]</span><span class='menu-copy'><span class='menu-title'>НАБЛЮДАТЬ</span><span class='menu-subtitle'>Войти как наблюдатель</span></span></a>
					</div>
					<div class='main-divider'></div>
					<div class='dossier'>
						<div class='dossier-title'>ЛИЧНОЕ ДЕЛО</div>
						<div class='dossier-auth'><div class='dossier-auth-line'>ПОИСК ЗАПИСИ...</div><div class='dossier-auth-line'>ИДЕНТИФИКАЦИЯ...</div><div class='dossier-auth-line granted'>ДОСТУП РАЗРЕШЁН</div></div>
						<div class='dossier-content'>
						<div class='dossier-main'>
							<div class='portrait'>[character_image]</div>
							<div class='dossier-data'>
								<div class='dossier-name prefs-no-translate'>[character_name]</div>
								<div class='data-row'><span class='data-label'>ВОЗРАСТ</span><span class='data-separator'>:</span><span class='data-value'>[character_age]</span></div>
								<div class='data-row'><span class='data-label'>ПОЛ</span><span class='data-separator'>:</span><span class='data-value'>[character_gender]</span></div>
								<div class='data-row'><span class='data-label'>ВИД</span><span class='data-separator'>:</span><span class='data-value'>[character_species]</span></div>
								<div class='data-row'><span class='data-label'>КОМПЛЕКЦИЯ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_size]</span></div>
								<div class='data-row'><span class='data-label'>ТЕЛОСЛОЖЕНИЕ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_type]</span></div>
								<div class='data-row'><span class='data-label'>ПРОИСХОЖДЕНИЕ</span><span class='data-separator'>:</span><span class='data-value'>[character_origin]</span></div>
								<div class='data-row'><span class='data-label'>ОТРЯД</span><span class='data-separator'>:</span><span class='data-value'>[character_squad]</span></div>
								<div class='data-row'><span class='data-label'>ОТНОШЕНИЕ К WY</span><span class='data-separator'>:</span><span class='data-value'>[character_wy_relation]</span></div>
								<div class='data-row'><span class='data-label'>ДОЛЖНОСТЬ</span><span class='data-separator'>:</span><span class='data-value'>[character_job]</span></div>
							</div>
						</div>
						<div class='dossier-footer'><div class='footer-globe'><span class='globe-orbit orbit-a'></span><span class='globe-orbit orbit-b'></span></div><div class='footer-copy'>АРХИВ ПЕРСОНАЛА<br>ЛИЧНОСТЬ ПОДТВЕРЖДЕНА</div><div class='footer-bars'></div></div>
						</div>
					</div>
				</div>
				<div class='mission'>
					<div class='mission-heading'><span class='mission-label'><span>ДЕТАЛИ МИССИИ</span><span class='mission-diags'>///</span></span><span class='mission-rule'></span><span class='mission-dots'>...</span></div>
					<div class='mission-body prefs-no-translate'><span id='missionText' class='mission-text[mission_typing_class]'>[mission_details]</span>[mission_typewriter_source]</div>
				</div>
			</div>
		</div>
		<script>
			(function() {
				var source = document.getElementById('missionTypewriterSource');
				var output = document.getElementById('missionText');
				if (!source || !output) return;
				var text = source.value || '';
				var position = 0;
				var timer = window.setInterval(function() {
					position = Math.min(position + 4, text.length);
					output.textContent = text.substring(0, position);
					if (position >= text.length) {
						window.clearInterval(timer);
						output.className = 'mission-text typed';
					}
				}, 16);
			})();
		</script>
	"}
	html += get_banda_character_preferences_translation_script(preferences?.banda_interface_language || "ru")

	if(refresh)
		close_browser(src, "lobbybrowser")
	winset(client, "mapwindow.lobbybrowser", "is-visible=true")
	show_browser(src, html, null, "lobbybrowser", "can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0", existing_container = "mapwindow")

/mob/new_player/proc/on_banda_lobby_pregame(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_GLOB_MODE_PREGAME_LOBBY)
	// Ticker sends this signal just before assigning GAME_STATE_PREGAME.
	addtimer(CALLBACK(src, PROC_REF(refresh_banda_lobby_preview), banda_lobby_render_generation), 1)

/mob/new_player/proc/refresh_banda_lobby_preview(expected_generation)
	if(!client?.prefs?.uses_banda_terminal_interface() || !banda_lobby_visible || banda_lobby_render_generation != expected_generation)
		return
	show_terminal_lobby()
