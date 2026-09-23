# World Edit Visual Workbench

`tools/world_edit_visual` is the canonical local runtime path for the World Edit Visual Workbench.

## Runtime Files

- `tools/world_edit_visual/enabled.txt` enables the DM workbench at world initialization.
- `tools/world_edit_visual/inbox/*.json` is the case inbox watched by the running DM runtime.
- `tools/world_edit_visual/out/<case_id>/report.json` is the structured case report.
- `tools/world_edit_visual/out/<case_id>/semantic.json` is the semantic canvas export.
- `tools/world_edit_visual/out/<case_id>/semantic.png` is the schematic review PNG.
- `tools/world_edit_visual/out/<case_id>/semantic_sprites.png` is the real `.dmi` sprite render.
- `tools/world_edit_visual/out/<case_id>/semantic_sprites.error.txt` explains why real sprite rendering failed.
- `tools/world_edit_visual/out/<case_id>/semantic_sprites.error.json` is the structured sprite-render failure record.
- `tools/world_edit_visual/out/<case_id>/workflow.error.txt` explains why the prepare/runtime/wait workflow failed.
- `tools/world_edit_visual/out/<case_id>/workflow.error.json` is the structured workflow failure record.
- `tools/world_edit_visual/out/<case_id>/ascii_dump.txt` is the ASCII review dump.
- `tools/world_edit_visual/workflow.log` is the detailed log for the last menu/bin render workflow.
- `tools/world_edit_visual/index.md` is generated from local runtime reports.

Runtime output, generated cases, DMI frame cache, and `index.md` are ignored local state.

## Quick Start

Use the menu:

```bat
tools\world_edit_visual\menu.bat
```

Choose `Render all cases`. The workflow prepares cases, restarts DreamDaemon once for a clean trusted batch run, waits for fresh `semantic.json`, renders cropped review artifacts, and stops the managed DreamDaemon process when it is done.

Normal menu/bin output is intentionally short. Detailed runtime commands,
per-case renderer output, temporary file paths, and DreamDaemon stop/start
details are written to `tools/world_edit_visual/workflow.log`. Add `--verbose`
to direct Python workflow commands when you want that detail in the console.

For automation, run the same full workflow directly:

```bat
tools\world_edit_visual\bin\render_all.bat
```

`run_all.bat` is an alias for the same full workflow. `render_all_png.bat` runs the full workflow without the ASCII dump. `watch_all.bat` is an advanced watcher for already-running output updates.

The `bin` directory is automation-only. Batch wrappers do not pause and return non-zero on failure.

## Menu

Use the interactive menu for one-case workflows and generation parameter setup:

```bat
tools\world_edit_visual\menu.bat
```

The menu can render all cases, render one case, create a simple generated case, and open the output folder.

Single-case actions intentionally live in `menu.bat` and Python helpers, not in `tools/world_edit_visual/bin`.

## Generated Cases

Create a local generated case:

```bat
py -3 tools\world_edit_visual\scripts\case_wizard.py
```

The wizard writes `tools/world_edit_visual/cases/generated/<safe_id>.json`. The default wizard asks only for case id, shape, size, direction, and seed. Advanced tuning can be edited directly in the generated JSON.

## Renderers

`render_semantic.py` draws the schematic debug PNG from semantic flags. It does not use DMI art.

Human-facing artifacts are cropped by default around useful generated content
with a small tile padding: `semantic.png`, `semantic_sprites.png`, and
`ascii_dump.txt`. The machine-readable `semantic.json` remains the full exported
canvas. Use `--full-canvas` on the Python render commands only when debugging the
entire workbench canvas.

`render_sprites.py` draws real project sprites. Its default contract is:

- require semantic `features.appearance` and `appearance_schema`;
- use `tiles[].appearance` for the live turf;
- use `tiles[].objects[].appearance` for live objects;
- use smooth wall overlay specs exported from the live wall `walltype` and `wall_connections`;
- extract `appearance.icon` and `appearance.icon_state` through `tools/dmitool/dmitool.py`;
- cache extracted frames under `tools/world_edit_visual/.cache/sprites/`;
- compose turf first, then objects bottom-to-top by plane/layer/order;
- apply pixel offsets, alpha, and simple hex color tinting;
- retry extraction without direction when directional extraction fails;
- fail clearly if appearance metadata or a DMI state is missing.

The full workflow stamps prepared case JSON with one workflow run id for the
selected batch and waits for the same id in each `semantic.json`. At the start of
a case run it clears stale success artifacts for that case, so a runtime/wait
failure is represented by `workflow.error.txt/json` instead of old PNG/report
links. If a batch stalls, completed cases are still rendered and missing cases
get workflow error files.

`render_all.py` still writes sprites atomically when a fresh semantic export is
available. It renders to `semantic_sprites.tmp.png`, replaces
`semantic_sprites.png` only on success, and writes
`semantic_sprites.error.txt/json` when the current sprite render fails.

The explicit schematic fallback flag is for developer debugging only and is not used by normal `bin` or menu flows.

## Direct Python Commands

Run the full all-case workflow:

```bat
py -3 tools\world_edit_visual\scripts\render_workflow.py
```

Render one case by case id/name:

```bat
py -3 tools\world_edit_visual\scripts\render_workflow.py --case building_living_rectangle_colony
```

For diagnosis, `--isolated` keeps the slower restart-per-case behavior:

```bat
py -3 tools\world_edit_visual\scripts\render_workflow.py --isolated
```

Print detailed workflow logs to the console:

```bat
py -3 tools\world_edit_visual\scripts\render_workflow.py --verbose
```

Render complete canvases instead of cropped review artifacts:

```bat
py -3 tools\world_edit_visual\scripts\render_workflow.py --full-canvas
```

Run the canonical 10-seed acceptance matrix for the six target-room Building
Layout programs. The runner derives temporary cases from the committed target
cases, executes ordinary workflow batches in bounded shards, requires
same-seed replay and the shared hard gates, and writes one aggregate JSON report
under the generated `out/` directory:

```bat
py -3 tools\world_edit_visual\scripts\run_building_layout_seed_matrix.py
```

Use `--prepare-only` to inspect the 60 derived inputs without starting
DreamDaemon. `--program`, `--seed`, `--shard-size`, and `--timeout-seconds`
support focused diagnosis. `--resume-passed` keeps already passing reports after
an interrupted long run; the unfiltered command is the fresh acceptance
contract.

Render the committed appearance smoke fixture:

```bat
py -3 tools\world_edit_visual\scripts\render_sprites.py --semantic-json tools\world_edit_visual\tests\fixtures\semantic_appearance_smoke.json --output tools\world_edit_visual\tests\fixtures\semantic_appearance_smoke.png
```

## Source And Generated State

Source:

- `tools/world_edit_visual/scripts/*.py`
- `tools/world_edit_visual/bin/*.bat`
- `tools/world_edit_visual/menu.bat`
- `tools/world_edit_visual/cases/*.json`
- `tools/world_edit_visual/tests/fixtures/*.json`

Generated/local:

- `tools/world_edit_visual/enabled.txt`
- `tools/world_edit_visual/inbox/`
- `tools/world_edit_visual/out/`
- `tools/world_edit_visual/index.md`
- `tools/world_edit_visual/workflow.log`
- `tools/world_edit_visual/.cache/`
- `tools/world_edit_visual/cases/generated/`

## Cleanup

```powershell
Remove-Item -Recurse -Force tools/world_edit_visual/inbox -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force tools/world_edit_visual/out -ErrorAction SilentlyContinue
Remove-Item -Force tools/world_edit_visual/enabled.txt -ErrorAction SilentlyContinue
Remove-Item -Force tools/world_edit_visual/index.md -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force tools/world_edit_visual/.cache -ErrorAction SilentlyContinue
```

## Troubleshooting

- If `render_sprites.py` says appearance metadata is missing, use menu `Render` again; it prepares cases and restarts DreamDaemon.
- If no matching-run `semantic.json` appears, check `workflow.error.txt/json` in the case output folder.
- DreamDaemon is launched once per normal render batch with `-trusted`, matching the repo CI/docker runtime path, so the BYOND DLL Security Alert should not require a manual `Host Game` click. The workflow also stops the exact managed DreamDaemon process after the render run.
- If DreamDaemon automation cannot find BYOND, set `BYOND_DREAMDAEMON` to the full `dreamdaemon.exe` path.
- If DMI extraction fails, check the exact `icon`, `icon_state`, and case printed by the renderer.
- If Java or `tools/dmitool/dmitool.jar` is missing, sprite rendering fails with setup guidance.
- Locked/error cases should remain visible in `report.json`, `semantic.png`, `ascii_dump.txt`, and `index.md` after the runtime exports them. If the runtime/wait stage fails first, use `workflow.error.txt/json`; when only sprites fail, use `semantic_sprites.error.txt/json`.
