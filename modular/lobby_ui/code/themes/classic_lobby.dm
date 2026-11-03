/mob/new_player/proc/show_classic_lobby(refresh = FALSE)
	if(!client)
		return

	close_browser(src, "lobbybrowser")
	winset(client, "mapwindow.lobbybrowser", "is-visible=false")

	var/tempnumber = rand(1, 999)
	var/postfix_text = client.xeno_postfix ? "-[client.xeno_postfix]" : ""
	var/prefix_text = client.xeno_prefix ? client.xeno_prefix : "XX"
	var/xeno_text = "[prefix_text]-[tempnumber][postfix_text]"
	var/round_start = !SSticker || !SSticker.mode || SSticker.current_state <= GAME_STATE_PREGAME

	var/output = "<div align='center'>Welcome,"
	output += "<br><b>[(client.prefs && client.prefs.real_name) ? client.prefs.real_name : client.key]</b>"
	output += "<br><b>[xeno_text]</b>"
	output += "<p><a href='byond://?src=\ref[src];lobby_choice=tutorial'>Tutorial</a></p>"
	output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_preferences'>Setup Character</a></p>"
	output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_playtimes'>View Playtimes</a></p>"

	if(round_start)
		output += "<p>\[ [ready ? "<b>Ready</b>" : "<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready ? "<a href='byond://?src=\ref[src];lobby_choice=unready'>Not Ready</a>" : "<b>Not Ready</b>"] \]</p>"
		output += "<b>Be Xenomorph:</b> [(client.prefs && client.prefs.get_job_priority(JOB_XENOMORPH)) ? "Yes" : "No"]"
	else
		output += "<a href='byond://?src=\ref[src];lobby_choice=manifest'>View the Crew Manifest</a><br><br>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join'>Join the round!</a></p>"

	output += "<p><a href='byond://?src=\ref[src];lobby_choice=observe'>Observe</a></p>"
	output += "</div>"

	if(refresh)
		close_browser(src, "playersetup")
	show_browser(src, output, null, "playersetup", "size=240x[round_start ? 500 : 610];can_close=0;can_minimize=0")
