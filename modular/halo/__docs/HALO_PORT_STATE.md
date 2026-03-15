# HALO PORT STATE

Canonical source of truth for the current HALO upstream baseline. For HALO port, sync, or update tasks, read this document before planning or editing. `HALO_PORT_BACKLOG.md` stays secondary and must not redefine the baseline here.

## Source Baseline
- Source repository: `https://github.com/cmss13-devs/cmss13-pve-halo`
- Previous pinned upstream commit: `7e498b805686ab870ddcfaa3cdf348103c0e3f51` (2026-03-05)
- Current pinned upstream commit: `95a84ab9f59f9118e5543f664b2793e7a1841c55` (2026-03-11)
- Current port wave: `CORE + SQUADS-owned ship runtime + weapons/assets + ODST drop pod sync`

## Scope Summary
- HALO content ownership stays split by module boundary:
- `modular/halo/**` owns HALO content, gear, weapons, assets, AI, drop pods, and map-specific runtime support.
- `modular/squads/**` owns active HALO platoon families, squad/job datums, locker routing, and ship-role profile helpers.
- This sync ports the upstream wave for MA5B and M6D support, SPNKr, covenant melee, elite shield and temporary visual content, ODST drop pods, and the related HALO map updates.
- Active HALO ship maps still use HALO platoon families through ship JSON `platoon` defaults plus optional `allowed_platoons` overrides; legacy single-squad ODST runtime paths remain invalid.

## BandaTroopers Sync Anchor
- Current local workspace head while applying this sync: `7d8b26d9a555a5a846a401b9c37a254a0d23cfb0`
- Previous HALO upstream pin for local work: `7e498b805686ab870ddcfaa3cdf348103c0e3f51`

## Intentional Source Deviations
- HALO squad and platoon runtime is not returned to upstream `code/game/jobs/**`; it stays in `modular/squads/**`.
- HALO shared string contracts stay in `code/__DEFINES/halo_jobs.dm`.
- Upstream legacy ODST map landmarks and single-squad ODST typepaths are not restored. HALO maps must target current `modular/squads` runtime and existing marine `alpha/bravo/charlie/delta` landmark surfaces.
- HALO ship JSON stays on `/datum/squad/marine/halo/{unsc,odst}/alpha` plus optional `allowed_platoons`, even though upstream `unsc_dark_was_the_night*.json` reverted to old non-HALO squad paths.
- ODST drop pod transit support uses the modular compat layer in `modular/halo/code/mixed/compat/halo_droppod_support.dm` instead of scattering direct upstream changes across the non-modular tree.
- Drop pod reservation cleanup keeps the local fix that requests `/datum/turf_reservation/transit/drop_pod` and releases the reservation after landing.

## Compatibility Hotspots
- Recheck `modular/halo/code/mixed/compat/**` on every upstream sync, especially `halo_core_*` and `halo_droppod_support.dm`.
- Recheck HALO map-support content in `modular/halo/code/mixed/{ammo_boxes,structures,effects}/` and `modular/halo/code/modules/{halo_drop_pod,admin,projectiles}/`.
- Recheck the small HALO glue surface in `code/**`: `code/game/sound.dm`, `code/modules/admin/{admin_verbs,topic/topic}.dm`, and `code/modules/mob/living/living_verbs.dm`.
- Recheck HALO ship/runtime ownership surfaces in `modular/squads/code/job/{halo_modular_platoons,ship_platoon_profiles}.dm` and HALO locker files in `modular/squads/code/closets/`.
- Recheck HALO ship JSON and map files together: `maps/{unsc_stalwart_frigate,unsc_dark_was_the_night,unsc_dark_was_the_night_odst}.json` and the three HALO ship DMMs.
- Recheck `tgui/packages/tgui/interfaces/GameMasterDroppodMenu.jsx` on future upstream UI syncs.

## Runtime Toggle
- `HALO_PERF_DEBUG` is a runtime config flag for temporary HALO combat profiling.
- Config surface: add `HALO_PERF_DEBUG` to `config/config.txt` or uncomment it in the example config template.
- Default state: off.
- Effect when enabled: exposes HALO-specific counters in MC stat output for projectile FX, human AI cover/path churn, and active shield harness processing.
- Production guidance: leave it off in normal production. Enable only for local repros or short diagnostic sessions around HALO AI-vs-AI battle stalls.

## Last Validation Snapshot
- Validation date: 2026-03-12
- Clean verification tree: `C:\Users\Alexey\Documents\GitHub\_tmp_bt_halo_buildcheck2`
- `tools/build/build dm --ci -DCIBUILDING -DANSICOLORS -Werror`: passed.
- `tools/build/build dm --ci -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_BASE`: passed.
- `tools/build/build dm --ci -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_EXTRA`: passed.
- `tools/build/build dm-test --ci -DCIBUILDING -DANSICOLORS -Werror`: wrapper still returned non-zero on Windows, but `data/unit_tests.json` reported all tests green and `data/logs/ci/clean_run.lk` contained `Success!`.
- maplint passed for `maps/map_files/UNSC_Stalwart_Frigate/UNSC_Stalwart_Frigate.dmm`, `maps/map_files/unsc_dark_was_the_night/unsc_dark_was_the_night.dmm`, and `maps/map_files/unsc_dark_was_the_night_odst/unsc_dark_was_the_night_odst.dmm`.

## Update Protocol
- Any future HALO upstream baseline change must update this file in the same change.
- If a HALO sync introduces a new intentional deviation, compatibility hotspot, or accepted tooling caveat, record it here immediately.
- If this file and `HALO_PORT_BACKLOG.md` diverge, this file wins.
