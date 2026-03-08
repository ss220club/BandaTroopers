# HALO PORT STATE

Канонический source of truth для текущего HALO upstream baseline. Для задач на HALO port/sync/update этот документ нужно читать до планирования и правок. [`../HALO_PORT_BACKLOG.md`](../HALO_PORT_BACKLOG.md) остается вторичным рабочим backlog и не переопределяет baseline.

## Source Baseline
- Source repository: `https://github.com/cmss13-devs/cmss13-pve-halo`
- Pinned upstream commit: `7e498b805686ab870ddcfaa3cdf348103c0e3f51` (2026-03-05)
- Current port wave: `CORE + ODST parity glue`

## Scope Summary
- HALO CORE parity currently covers species/support, weapons/ammo, armor/clothing, radios/scanners, chemistry, cryo/monitor/organs.
- HALO map-critical runtime typepaths required by `halo_new_irvine` and `unsc_dark_was_the_night*` are present in `modular/halo/**`.
- ODST gameplay glue landed in `code/**` for squads/jobs/constants/landmarks/comms/preferences/intro alerts.

## BandaTroopers Sync Anchor
- Last local sync anchor commit: `e87823c878970babe535ddd0fe239516ebb8e8b8` (2026-03-06, `ODST part port`)
- Previous HALO core landing anchor: `4174552cd42952710791e2019e9de318cb82d8b0` (2026-03-06, `HALO BUILD PORT`)

## Intentional Source Deviations
- `/obj/effect/landmark/start/marine/rto/odst` points to `/datum/job/marine/standard/ai/rto/odst` instead of generic `/ai/odst` to preserve ODST RTO role correctness.

## Compatibility Hotspots
- Recheck `modular/halo/code/mixed/compat/**` on every upstream sync.
- Recheck ODST/HALO glue surfaces in `code/**`: `code/__DEFINES/{job,mode}.dm`, `code/controllers/subsystem/communications.dm`, `code/game/jobs/job/marine/{squads.dm,squad/*}.dm`, `code/game/objects/effects/landmarks/landmarks.dm`, `code/modules/mob/new_player/preferences_setup.dm`, `code/game/gamemodes/colonialmarines/colonialmarines.dm`, `code/modules/mob/living/carbon/human/human.dm`, `code/modules/maptext_alerts/misc_alert.dm`.
- Recheck HALO map activation/config surfaces: `map_config/maps.txt` and `map_config/shipmaps.txt`.

## Last Validation Snapshot
- `tools/build/build dm --ci --define=CIBUILDING --define=CITESTING --define=ALL_MAPS --define=ALL_MAPS_STAGE_BASE`: passed.
- `tools/build/build dm --ci --define=CIBUILDING --define=CITESTING --define=ALL_MAPS --define=ALL_MAPS_STAGE_EXTRA`: passed.
- `tools/build/build dm --ci --define=ALL_MAPS`: passed.
- maplint on 3 HALO maps: passed.
- Known local caveat: monolithic `tools/build/build dm --ci --define=ALL_MAPS --define=CIBUILDING` crashes DM process (`3221225477`) after map loading; staged CI-equivalent map compile remains the accepted signal.

## Update Protocol
- Any HALO upstream baseline change must update this file in the same change.
- If a HALO sync introduces new intentional deviations, compatibility hotspots, or validation expectations, update this file in the same change.
- [`../HALO_PORT_BACKLOG.md`](../HALO_PORT_BACKLOG.md) may track deferred work and open caveats, but it must not replace or contradict this document.
- If this file and backlog diverge, this file wins.
