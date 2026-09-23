# Round Cinematics Implementation Notes

## Decisions
- Controller: `GLOB.round_cinematics` via `GLOBAL_DATUM_INIT(round_cinematics, /datum/round_cinematics_controller, new)`.
- State model: intro and outro use per-session datums with explicit cleanup and no long-lived mob state.
- HUD handling: the session owns HUD hide and restore by snapshotting the relevant screen state instead of changing shared HUD/action behavior.
- Visual layer: BYOND fullscreen overlays, screen text, and maptext only for v1.
- Legacy paths: `modular/fullscreen/**` and `modular/round_outro/**` are old browser paths and should be removed once the modular replacement is active.

## Discovery references
- Intro entrypoint: `code/modules/mob/living/carbon/human/human.dm:1686`
- Cryo exit hooks: `code/game/machinery/cryopod.dm:452`, `:457`, `:542`
- Round-end hooks: `code/game/gamemodes/colonialmarines/colonialmarines.dm:484`, `code/game/gamemodes/colonialmarines/huntergames.dm:396`, `code/game/gamemodes/colonialmarines/whiskey_outpost.dm:259`, `code/game/gamemodes/colonialmarines/xenovsxeno.dm:257`, `code/game/gamemodes/extended/extended.dm:37`, `code/game/gamemodes/extended/infection.dm:118`
- Existing helpers: `code/modules/maptext_alerts/screen_alerts.dm`, `code/_onclick/hud/fullscreen.dm`, `code/_onclick/hud/screen_objects.dm`

## Target shape
- `modular/round_cinematics/_round_cinematics.dm`
- `modular/round_cinematics/_round_cinematics.dme`
- `modular/round_cinematics/code/round_cinematics_controller.dm`
- `modular/round_cinematics/code/round_cinematics_session.dm`
- `modular/round_cinematics/code/round_cinematics_sequence.dm`
- `modular/round_cinematics/code/round_cinematics_phase.dm`
- `modular/round_cinematics/code/round_cinematics_screen.dm`
- `modular/round_cinematics/code/round_cinematics_cleanup.dm`
- `modular/round_cinematics/code/round_cinematics_helpers.dm`
- `modular/round_cinematics/code/intro/**`
- `modular/round_cinematics/code/outro/**`
- `modular/round_cinematics/code/admin/**`

