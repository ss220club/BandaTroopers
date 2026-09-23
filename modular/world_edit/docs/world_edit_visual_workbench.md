# World Edit Visual Workbench

The World Edit Visual Workbench is a local file-based review harness for World Edit generation cases.

Canonical runtime state is under repo-root `tools/world_edit_visual`:

```text
tools/world_edit_visual/enabled.txt
tools/world_edit_visual/inbox/*.json
tools/world_edit_visual/out/<case_id>/report.json
tools/world_edit_visual/out/<case_id>/semantic.json
tools/world_edit_visual/out/<case_id>/semantic.png
tools/world_edit_visual/out/<case_id>/semantic_sprites.png
tools/world_edit_visual/out/<case_id>/semantic_sprites.error.txt
tools/world_edit_visual/out/<case_id>/semantic_sprites.error.json
tools/world_edit_visual/out/<case_id>/workflow.error.txt
tools/world_edit_visual/out/<case_id>/workflow.error.json
tools/world_edit_visual/out/<case_id>/ascii_dump.txt
tools/world_edit_visual/workflow.log
tools/world_edit_visual/index.md
```

## DM Side

The workbench starts only when `tools/world_edit_visual/enabled.txt` exists before world initialization. It polls `tools/world_edit_visual/inbox`, loads case JSON files, executes the requested generator, and writes structured output under `tools/world_edit_visual/out/<case_id>`.

`world_edit_visual_semantic/v1` exports semantic flags plus live appearance metadata:

- `features.appearance` and `appearance_schema`;
- `tiles[].appearance` for the live turf;
- `tiles[].objects[].appearance` for each live object;
- appearance fields: `icon`, `icon_state`, `dir_value`, `dir`, `pixel_x`, `pixel_y`, `layer`, `plane`, `alpha`, `color`.

The workbench export path is allowed to change for visualization fidelity. `building_layout` generation behavior is not part of this renderer/tooling contract.

## Tooling

Run the full all-case workflow:

```bat
tools\world_edit_visual\bin\run_all.bat
```

`run_all.bat` and `render_all.bat` both prepare cases, stamp the selected batch with a workflow run id, restart DreamDaemon once with `-trusted` for a clean workbench run, wait for matching-run `semantic.json`, render cropped review artifacts, and stop the managed DreamDaemon process when the workflow is done.

Normal menu/bin output is a compact user-facing status screen. Full runtime
commands, DreamDaemon output, per-case renderer output, temporary paths, and
process-stop details are written to `tools/world_edit_visual/workflow.log`.
Use `render_workflow.py --verbose` only when that detail should also be printed
to the console.

```bat
tools\world_edit_visual\bin\render_all.bat
```

Render PNG outputs only:

```bat
tools\world_edit_visual\bin\render_all_png.bat
```

Watch completed outputs:

```bat
tools\world_edit_visual\bin\watch_all.bat
```

`tools/world_edit_visual/bin` is all-case and automation-only. It must not contain single-case batch wrappers or `pause`.

Use the menu for single-case work and generation parameters:

```bat
tools\world_edit_visual\menu.bat
```

The menu can render all cases, render one selected case, open generated output, and launch the case wizard. Selecting Render is the only normal user action needed; prepare, DreamDaemon restart, wait, artifact rendering, and DreamDaemon cleanup are implied.

`render_workflow.py --isolated` is available for diagnostics when a single case needs a clean DreamDaemon process. It is intentionally not the normal menu/bin path.

Generated local cases are written by:

```bat
py -3 tools\world_edit_visual\scripts\case_wizard.py
```

to `tools/world_edit_visual/cases/generated/<safe_id>.json`.

## Render Contract

`semantic.png` is a schematic debug image produced from semantic flags.

`semantic_sprites.png` is appearance-backed:

- Python first validates `features.appearance`, `appearance_schema`, and actual appearance entries;
- Python uses `appearance.icon`, `appearance.icon_state`, and `appearance.dir_value`;
- smooth walls use exported overlay specs from live `walltype` and `wall_connections`;
- DMI frames are extracted through `tools/dmitool/dmitool.py`;
- extracted frames are cached under `tools/world_edit_visual/.cache/sprites/`;
- turf is composed first;
- objects are composed bottom-to-top by plane/layer/order;
- pixel offsets and alpha are applied;
- extraction retries without direction when directional extraction fails;
- old semantic JSON without appearance fails quickly with one regeneration message.

The full workflow clears stale success artifacts for the cases it is about to run. If DreamDaemon cannot start or does not produce matching-run semantic output, the current result is `workflow.error.txt/json`, not old PNG/report links.
In normal batch mode, completed cases are still rendered even when another selected case times out; missing cases receive workflow error files.

`render_all.py` writes sprite renders atomically once fresh semantic output exists. It replaces `semantic_sprites.png` only on success, writes `semantic_sprites.error.txt` and `semantic_sprites.error.json` when the current sprite render fails, and still updates schematic/debug outputs.

`semantic.png`, `semantic_sprites.png`, and `ascii_dump.txt` are cropped by
default around useful generated content plus padding. `semantic.json` remains the
full exported canvas/source of truth. Use the explicit Python `--full-canvas`
flag for diagnostic full-canvas renders.

The explicit schematic fallback flag is a developer-only debug path and is not used by normal `bin` or menu flows.

## Verification

Recommended checks after renderer/tooling changes:

```bat
py -3 -m compileall tools/world_edit_visual/scripts
py -3 -c "import sys, tempfile, os; sys.path.append('tools/dmitool'); import dmitool; p=dmitool.extract_state('icons/turf/floors/floors.dmi', os.path.join(tempfile.gettempdir(), 'wev_probe.png'), 'wood'); raise SystemExit(p.wait())"
py -3 tools/world_edit_visual/scripts/render_sprites.py --semantic-json tools/world_edit_visual/tests/fixtures/semantic_appearance_smoke.json --output tools/world_edit_visual/tests/fixtures/semantic_appearance_smoke.png
tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
```

Live acceptance:

```bat
tools\world_edit_visual\bin\run_all.bat
tools\world_edit_visual\bin\render_all.bat
```

Confirm available completed cases refresh `semantic.png`, `semantic_sprites.png` or sprite error files, `ascii_dump.txt`, workflow error files when applicable, and `index.md`.
