# HALO PORT STATE

Canonical source of truth for the current HALO modular sync state on BandaTroopers.

## Active Baseline
- Source repository: `https://github.com/cmss13-devs/cmss13-pve-halo`
- Current merged BT master baseline: `upstream/master @ 5d2ad73b68727b88c7b02cf005a4af72f855babd`
- Meaning of that baseline: merged BT `PR #96` (`[HALO] Sync follow-up main wave`)
- Current gameplay-completion branch: `halo_jackal_spartan_wave_apr2026`
- Pre-refresh PR94 branch head before the master update: `6760808e61a60c596784bde67a8b6a594f57c089`
- Current upstream audit source for HALO content parity: `cmss13-devs/cmss13-pve-halo/master @ a4943e1cd28387b86e47ba282a8cd06e7b953c96`

## Branch Scope
- `PR #96` is already merged into BT master and is treated as the shared HALO base.
- This branch owns only the follow-up gameplay completion needed for `PR #94` after that merge.
- Requested user-facing scope on this branch:
  - refresh `PR #94` from current master;
  - keep Kig-Yar/Ruuhtian and Spartan content modular-first;
  - finish playable preset, HumanAI, and squad coverage for Kig-Yar, Sangheili, Unggoy, Spartan, and the remaining HALO combat families that still had exposure gaps.

## Ownership Rules
- HALO content stays in `modular/halo/**` by default.
- `code/**` keeps only minimal glue already required by merged BT master, such as Game Master menu entries and shared faction hooks.
- `modular/squads/**` remains the owner of HALO job and platoon systems that were already split there.

## Intentional Deviations From Upstream
- Kig-Yar content remains under the BT `ruuhtian` layout instead of restoring upstream file names.
- Spartan runtime stays modular through `modular/halo/**`; no HALO gameplay code is moved back into generic upstream gun or species trees.
- Covenant split-faction behavior is preserved through BT modular faction surfaces even when upstream used a different file layout.
- Public HALO equipment presets are allowed to carry split-faction ownership when that is required for `Create Humans`, `HumanAI Spawn`, or `Squad Spawner` parity.

## Current Compatibility Hotspots
- `modular/halo/code/modules/gear_presets/Halo/{sangheili,unggoy,ruuhtian,spartan,covenant_master_sync}.dm`
- `modular/halo/code/modules/mob/living/carbon/human/ai/ai_spawner/{ai_presets_ruuhtian,ai_presets_sangheili,ai_presets_unggoy,ai_presets_unsc,ai_presets_spartan}.dm`
- `modular/halo/code/modules/mob/living/carbon/human/ai/squad_spawner/halo/{squad_covenant,squad_unsc,squad_spartan}.dm`
- `code/modules/mob/living/carbon/human/ai/action_datums/{mg_nest,sniper_nest}.dm`
- `modular/halo/code/modules/unit_tests/halo_preset_coverage.dm`

## Validation Snapshot
- Last fully merged shared baseline validation belongs to BT `PR #96`.
- Post-merge validation for the current `PR #94` gameplay-completion pass is complete for the code and map surfaces touched on this branch.
- Passed on this branch:
  - `git diff --check`
  - `tools/ci/validate_dme.py < colonialmarines.dme`
  - `tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror`
  - `tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_BASE`
  - `tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_EXTRA`
  - `tools/bootstrap/python -m dmi.test`
- Residual local validation caveats:
  - `dm-test` compiled cleanly but hung during local Windows execution after launching DreamDaemon, so runtime unit execution still needs a clean CI run for final confirmation.
  - Windows-local `maplint` hit a decoding failure on `maps/map_files/UNSC_Stalwart_Frigate/UNSC_Stalwart_Frigate.dmm`, so that remaining check should be treated as an environment-specific follow-up unless CI reproduces it.

## Update Protocol
- If the HALO upstream baseline changes again, update this file in the same change.
- If `PR #94` scope expands or contracts, record the decision here and mirror the work split in `HALO_PORT_BACKLOG.md`.
- If this file disagrees with older port notes, this file wins.
