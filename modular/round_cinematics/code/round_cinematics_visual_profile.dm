/datum/round_cinematics_visual_profile
	/// Unique identifier for this profile
	var/id = "default"
	/// Color for headers and primary text
	var/header_color = "#33FF33"
	/// Color for accents and secondary elements
	var/accent_color = "#33FF33"
	/// Background color
	var/background_color = "#000000"
	/// Warning/alert color
	var/warning_color = "#FF4444"
	/// Logo text displayed in header
	var/logo_text = "BW"
	/// Header label (e.g. "TERMINAL")
	var/header_label = "TERMINAL"
	/// Footer label (e.g. "READY")
	var/footer_label = "READY"
	/// Sound played on boot/power-on
	var/sound_boot = 'sound/effects/cryo_beep.ogg'
	/// Sound played on page transitions
	var/sound_page = null
	/// Sound played on final splash
	var/sound_final = null
	/// Glitch effect intensity (0-1)
	var/glitch_intensity = 0
	/// Number of flicker effects
	var/flicker_count = 0
	/// Typewriter text speed in deciseconds
	var/typewriter_speed = ROUND_CINEMATICS_TEXT_DELAY

// --- Intro profiles ---

/datum/round_cinematics_visual_profile/intro_universal
	id = "intro_universal"
	header_color = "#33FF33"
	accent_color = "#33FF33"
	background_color = "#000000"
	warning_color = "#FF4444"
	logo_text = "SYS"
	header_label = "CRYOGENIC REVIVAL SYSTEM"
	footer_label = "READY"
	sound_boot = 'sound/effects/cryo_beep.ogg'
	glitch_intensity = 0
	flicker_count = 0

// --- Outro profiles ---

/datum/round_cinematics_visual_profile/outro_victory
	id = "outro_victory"
	header_color = "#44FF44"
	accent_color = "#AAFFAA"
	background_color = "#000000"
	warning_color = "#FF4444"
	logo_text = "BW"
	header_label = "REPORT"
	footer_label = "COMPLETE"
	sound_boot = 'sound/effects/cryo_beep.ogg'
	glitch_intensity = 0
	flicker_count = 0

/datum/round_cinematics_visual_profile/outro_defeat
	id = "outro_defeat"
	header_color = "#FF4444"
	accent_color = "#FFAAAA"
	background_color = "#000000"
	warning_color = "#FF4444"
	logo_text = "BW"
	header_label = "REPORT"
	footer_label = "COMPLETE"
	sound_boot = 'sound/effects/cryo_beep.ogg'
	glitch_intensity = 0.4
	flicker_count = 3

/datum/round_cinematics_visual_profile/outro_inconclusive
	id = "outro_inconclusive"
	header_color = "#FFAA44"
	accent_color = "#FFDDAA"
	background_color = "#000000"
	warning_color = "#FF4444"
	logo_text = "BW"
	header_label = "REPORT"
	footer_label = "COMPLETE"
	sound_boot = 'sound/effects/cryo_beep.ogg'
	glitch_intensity = 0.15
	flicker_count = 1
