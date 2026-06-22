#define ROUND_CINEMATICS_INTRO_ALLOW_SKIP_AFTER (5 SECONDS)
#define ROUND_CINEMATICS_INTRO_HARD_TIMEOUT (20 SECONDS)
#define ROUND_CINEMATICS_INTRO_PAGE_ROWS 6
#define ROUND_CINEMATICS_OUTRO_PAGE_ROWS 4
#define ROUND_CINEMATICS_TEXT_WIDTH 800
#define ROUND_CINEMATICS_TEXT_HEIGHT 480
#define ROUND_CINEMATICS_TEXT_LETTERS 2
#define ROUND_CINEMATICS_TEXT_DELAY 0.5
#define ROUND_CINEMATICS_TEXT_HOLD 2 SECONDS

#define ROUND_CINEMATICS_FONT_STACK "\"VCR OSD Mono\", \"Consolas\", \"Courier New\", monospace"

#define ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK "round_cinematics_intro_black"
#define ROUND_CINEMATICS_FULLSCREEN_INTRO_CRT "round_cinematics_intro_crt"
#define ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK "round_cinematics_outro_black"
#define ROUND_CINEMATICS_FULLSCREEN_OUTRO_CRT "round_cinematics_outro_crt"

GLOBAL_DATUM_INIT(round_cinematics, /datum/round_cinematics_controller, new)

/datum/modpack/round_cinematics
	name = "round cinematics modpack"
	desc = "Modular intro and outro cinematics."
	author = "Codex"

/datum/modpack/round_cinematics/initialize()
	. = ..()
	if(!SSticker)
		return

	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(handle_roundstart)))
	SSticker.OnRoundend(CALLBACK(src, PROC_REF(handle_roundend)))

/datum/modpack/round_cinematics/proc/handle_roundstart()
	GLOB.round_cinematics?.reset_round_tracking()
	GLOB.round_cinematics?.cleanup_all("roundstart_reset")

/datum/modpack/round_cinematics/proc/handle_roundend()
	var/admin_override = GLOB.round_cinematics?.admin_outcome_override?.id
	var/datum/round_cinematics_outcome_input/input = new /datum/round_cinematics_outcome_input(SSticker?.mode, SSticker?.mode?.round_finished, admin_override, "roundend")
	GLOB.round_cinematics?.try_start_round_outro(input)
