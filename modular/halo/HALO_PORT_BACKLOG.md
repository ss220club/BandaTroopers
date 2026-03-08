# HALO PORT BACKLOG

Canonical baseline: [`__docs/HALO_PORT_STATE.md`](./__docs/HALO_PORT_STATE.md). For any HALO port/sync/update task, read the state doc first. If this backlog and the state doc diverge, the state doc wins.

## Deferred Scope
- Broad HALO AI scenario parity beyond requested ODST/HALO flow.
- Additional non-critical flavor drift not affecting compile/playability.

## Next Sync Tasks
- Recheck the compatibility hotspots listed in [`__docs/HALO_PORT_STATE.md`](./__docs/HALO_PORT_STATE.md) before changing upstream-facing HALO glue.
- Keep documenting intentional source deviations from `cmss13-pve-halo`.
- Perform runtime smoke on live host/session.

## Open Caveats
- Local monolithic invocation `tools/build/build dm --ci --define=ALL_MAPS --define=CIBUILDING` crashes DM process (`3221225477`) after map loading; staged CI-equivalent map compile remains the current acceptance signal.
