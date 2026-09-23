/datum/round_cinematics_sequence
	var/list/phases = list()

/datum/round_cinematics_sequence/proc/execute(datum/round_cinematics_session/session)
	if(!session || session.cleaned_up)
		return

	for(var/datum/round_cinematics_phase/phase as anything in phases)
		if(session.cleaned_up)
			break
		phase.play(session)

/// Returns maptext HTML for the terminal header bar.
/// Override in subclasses for faction-specific branding.
/datum/round_cinematics_sequence/proc/get_header_html()
	return ""

/// Returns maptext HTML for the terminal footer bar.
/// Override in subclasses for faction-specific indicators.
/datum/round_cinematics_sequence/proc/get_footer_html()
	return ""
