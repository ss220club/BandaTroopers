# 1
Read-only task. Repository: d:\GitHub\BandaTroopersFork. Follow AGENTS.md order enough for this task, but do not edit anything. User wants a detailed plan first, challenge/doubts, then only later implementation for World Edit building generator based on:
- modular/world_edit/docs/deepsearch/Генерация построек - разбор.md
- modular/world_edit/docs/deepsearch/Генерация построек - цель.md

You are subagent A: inspect the existing World Edit generator implementation. Use targeted rg and reads only. Report:
1) include graph/entrypoints for modular/world_edit in colonialmarines.dme/modular.dme/module dme;
2) files/types/procs that implement current building/DMM blueprint generation;
3) current generation pipeline and data flow;
4) callsites/UI/admin entrypoints and side effects;
5) extension points suitable for a modular-first rewrite;
6) evidence commands/files/line refs. Keep concise and factual.


Ответ:

**Subagent A Report**

1. **Include Graph / Entrypoints**
- `colonialmarines.dme` includes World Edit defines at [colonialmarines.dme](d:/GitHub/BandaTroopersFork/colonialmarines.dme:142) and the modular entrypoint at [colonialmarines.dme](d:/GitHub/BandaTroopersFork/colonialmarines.dme:2767).
- `modular/modular.dme` includes `world_edit/_world_edit.dme` at [modular.dme](d:/GitHub/BandaTroopersFork/modular/modular.dme:17).
- `modular/world_edit/_world_edit.dme` includes core types, blueprints, registry, generators, manager runtime/UI, then admin hook at lines [3](d:/GitHub/BandaTroopersFork/modular/world_edit/_world_edit.dme:3)-[78](d:/GitHub/BandaTroopersFork/modular/world_edit/_world_edit.dme:78).
- Upstream admin verb glue exposes `/client/proc/open_world_edit_panel` through R_DEBUG verbs at [admin_verbs.dm](d:/GitHub/BandaTroopersFork/code/modules/admin/admin_verbs.dm:395), removed at [admin_verbs.dm](d:/GitHub/BandaTroopersFork/code/modules/admin/admin_verbs.dm:445).

2. **Current Building / DMM Blueprint Implementation**
- Live building generator: `/datum/world_edit_generator/building_layout` in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:7).
- Registered as ready generator `building_layout`, category `Строительство`, required `R_EVENT`, defaults at [world_edit_registry.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_registry.dm:122)-[141](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_registry.dm:141).
- DMM blueprint service: `GLOB.world_edit_blueprints` and `/datum/world_edit_blueprint_service` at [world_edit_blueprints.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_blueprints.dm:23)-[30](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_blueprints.dm:30).
- DMM parse/load/serialize/save/import/delete/rename lives mainly in [world_edit_blueprint_library_storage.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:199), [333](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:333), [385](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:385), [413](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:413).
- Blueprint stamping generator: `/datum/world_edit_generator/blueprint_stamp` at [world_edit_generator_blueprint_stamp.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/blueprint_stamp/world_edit_generator_blueprint_stamp.dm:4); planning uses `world_edit_build_plan_from_blueprint()` at [blueprint_stamp_planning.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/blueprint_stamp/blueprint_stamp_planning.dm:43)-[120](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/blueprint_stamp/blueprint_stamp_planning.dm:120).
- Current save-to-DMM path only exports `outpost_radius` plans, not `building_layout`: [world_edit_manager_blueprints_actions.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/session/blueprints/world_edit_manager_blueprints_actions.dm:149)-[172](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/session/blueprints/world_edit_manager_blueprints_actions.dm:172).

3. **Current Generation Pipeline / Data Flow**
- Building params normalize faction/layout/material paths/density/blockers at [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:147)-[171](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:171).
- Shape footprint is resolved from placement shape or point rectangle at [417](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:417)-[457](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:457), then validated for size, z-level, connectivity, blockers, boundary/interior at [459](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:459)-[539](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:539).
- Plan assembly chooses doors/windows, optional internal partition, emits turf placements, object placements, reserved paths, then interior objects at [1484](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1484)-[1602](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1602).
- Interior is motif/slot based, with wall rows and table groups, not semantic graph/solver/anchor architecture: [1024](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1024)-[1342](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1342).
- Apply mutates live map directly via `ChangeTurf()` and `new obj_path()`, records a full undo changeset: [1770](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1770)-[1869](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1869).

4. **Callsites / UI / Side Effects**
- Admin entrypoint creates/reuses manager and opens TGUI: [world_edit_admin_hooks.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_admin_hooks.dm:2)-[17](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_admin_hooks.dm:17).
- TGUI backend routes `select_generator`, `run_preview`, `run_apply`, blueprint actions, placement mode actions through manager `ui_act`: [world_edit_manager_ui.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/ui/world_edit_manager_ui.dm:44)-[63](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/ui/world_edit_manager_ui.dm:63), [world_edit_manager_actions.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/ui/world_edit_manager_actions.dm:1)-[170](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/ui/world_edit_manager_actions.dm:170).
- Preview side effects: preview images/placement layers, chat feedback, preview state marks: [world_edit_manager_execution.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_execution.dm:1)-[43](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_execution.dm:43).
- Apply side effects: confirmation, generator apply, changeset stack, audit log, history, chat feedback: [world_edit_manager_execution.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_execution.dm:45)-[150](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_execution.dm:150).
- Click placement uses `client.click_intercept`: [world_edit_manager_click_mode.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_click_mode.dm:16)-[34](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_click_mode.dm:34), [65](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_click_mode.dm:65)-[78](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_click_mode.dm:78).

5. **Modular-First Rewrite Extension Points**
- Add/replace generator via new `/datum/world_edit_generator_definition/*` and `/datum/world_edit_generator/*`; registry auto-indexes `subtypesof()` at [world_edit_registry.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_registry.dm:152)-[168](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_registry.dm:168).
- Reuse base generator hooks: `validate_params`, `get_ui_fields`, `build_plan`, `build_plan_from_shape_contract`, `apply_plan`, preview object specs, placement shapes/directions at [world_edit_types.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_types.dm:51)-[168](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_types.dm:168).
- Reuse placement contract/candidate layer for shape-aware preview/apply: [world_edit_placement_contracts.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_placement_contracts.dm:136)-[185](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_placement_contracts.dm:185).
- Reuse preview layers and changesets instead of adding upstream UI plumbing: [world_edit_manager_placement_runtime.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_placement_runtime.dm:744)-[796](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_placement_runtime.dm:796), [world_edit_changesets.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_changesets.dm:20)-[89](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_changesets.dm:89).
- Current DMM Blueprint Lite is object-only over `/turf/template_noop,/area/template_noop`, with strict allowed object rules: [world_edit_blueprint_library_storage.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:150)-[188](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:188). A building rewrite that emits full building DMM chunks needs a new/expanded blueprint contract, not just `building_layout` save wiring.

6. **Evidence Commands**
- Read guidance/task state read-only: `Get-Content ... AGENTS-listed docs`, no edits.
- Include graph: `rg -n "world_edit|_world_edit|modular\\.dme" colonialmarines.dme modular/modular.dme modular/world_edit/_world_edit.dme`.
- File inventory: `rg --files modular/world_edit`.
- Implementation search: `rg -n "building_layout|blueprint|DMM|dmm|parsed_map|template" modular/world_edit/code ...`.
- Entrypoints/UI: `rg -n "WorldEdit|world_edit|ui_act|open_world_edit_panel|run_preview|run_apply" tgui code modular ...`.

No files were edited.



===================================================
# 2
Read-only task. Repository: d:\GitHub\BandaTroopersFork. Follow AGENTS.md order enough for this task, but do not edit anything. User wants a detailed plan first, challenge/doubts, then only later implementation for World Edit building generator based on:
- modular/world_edit/docs/deepsearch/Генерация построек - разбор.md
- modular/world_edit/docs/deepsearch/Генерация построек - цель.md

You are subagent B: requirements mapper. Read the two deepsearch docs and relevant current code only as needed. Do not edit anything. Produce a contract mapping for a future implementation:
- MUST / KEEP / REJECT / CHECK items;
- forbidden substitutions;
- old path audit candidates if rewrite/remove/replace/core-behavior is required;
- at least 3 doubts/assumptions and how to verify each;
- 2+ implementation alternatives and recommendation.
Keep it grounded in repo facts where possible.


Ответ:
**Read-Only Result**
No files were edited. The active `PLAN/TODO/DECISIONS/EVIDENCE` are stale for this scope, so before implementation they must be rewritten into a World Edit building-generator contract.

Grounded facts: `building_layout` is a ready World Edit generator included through [modular.dme](d:/GitHub/BandaTroopersFork/modular/modular.dme:17) and [_world_edit.dme](d:/GitHub/BandaTroopersFork/modular/world_edit/_world_edit.dme:47). Current core lives in one file, [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1), with caps of `512` footprint turfs, `16` interior objects, and `12` windows. It currently builds a `world_edit_plan` directly from footprint, doors/windows, simple partitions, and slot-based interior placement, not from semantic archetypes.

**MUST**
| ID | Requirement |
| --- | --- |
| M1 | Replace the current item-first core with `archetype -> semantic zones -> bounded geometry -> anchors/circulation -> major fixtures -> secondary/clutter -> facade -> validate/repair -> emit plan`. |
| M2 | Introduce declarative archetype/style data for at least the MVP archetypes explicitly chosen before implementation. Docs suggest `colony_living`, `uscm_workshop`, `storage`, `checkpoint`, `medbay`; do not silently promise the whole station library in one pass. |
| M3 | Add seeded deterministic generation. Preview and apply must produce the same plan for the same seed, params, shape, origin, and direction. |
| M4 | Add validators for reachability, doors, wall-mounted placement/dir, zone requirements, privacy, object density/repetition, corridors, and windows. |
| M5 | Keep the World Edit live contract: `get_ui_fields`, `set_ui_param`, preview-first apply, `world_edit_plan`, placement-layer preview, changeset undo/logging. |
| M6 | Keep bounded algorithms and caps. Any backtracking/repair/expressive-range loop needs explicit iteration and candidate limits. |
| M7 | Add focused unit/regression tests for golden seeds and failure cases; existing tests only cover World Edit blueprints in [world_edit_blueprints.dm](d:/GitHub/BandaTroopersFork/code/modules/unit_tests/world_edit_blueprints.dm:11). |

**KEEP**
- `building_layout` generator id and ready UI surface unless user explicitly approves temporary draft/gating. See [world_edit_registry.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/world_edit_registry.dm:122).
- Modular-first placement under `modular/world_edit/**`; no new business logic in `code/**`.
- Existing shape/placement manager contracts, blocker checks, one-z validation, preview/apply/undo/log history.
- Existing blueprint/DMM services as integration options, not forced into the first generator rewrite unless approved.

**REJECT**
- “More objects” by only expanding `get_interior_slots`, increasing caps, or tweaking densities.
- Random/scatter-first generation as the main algorithm.
- WFC/ML as primary zoning or furnishing logic; WFC may only be a late local-detail pass.
- A wrapper around the old generator core that leaves old placement reachable for rewritten archetypes.
- Manual screenshot approval as the only proof of quality.
- Unbounded solver/backtracking in preview/apply.

**CHECK**
- Compile through repo build tooling after implementation.
- Unit tests for semantic zones, fixture reachability, no major object in door cone, wall mount dir rules, density/repetition, and seeded determinism.
- UI smoke: params, preview, placement preview, apply, undo/history.
- If DMM/template overlays enter scope, add DMM schema/blueprint checks and keep runtime plan emission compatible.

**Forbidden Substitutions**
- Do not rename `layout_variant` to “archetype” while keeping the same switch-based slot logic.
- Do not leave `append_interior_placements()` as the production path for new archetypes.
- Do not use current wall rows/table groups as the “anchor system” unless they are rewritten behind real semantic anchors.
- Do not defer validation to map sanity only; generator-level validator is required.
- Do not move the core to `code/**` to make type access easier.

**Old Path Audit Candidates**
- Replace or retire as production core: `build_plan_from_shape_contract()` pipeline at [line 1484](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1484), `build_internal_partition()` at [line 992](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:992), `get_interior_slots()` at [line 1024](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1024), `append_interior_placements()` at [line 1249](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1249).
- Keep or adapt as utility only: footprint validation, blocker checks, preview spec building, `apply_plan()`.
- Audit UI/default params if adding `archetype_id`, `seed`, facade/detail settings.

**Doubts To Resolve**
1. MVP breadth: docs describe a large generator library. Verify exact first archetypes with user before coding.
2. Emitter contract: docs prefer DMM chunks/templates, current code emits `world_edit_plan`. Decide whether v1 may emit plans and add DMM later.
3. Seed source: add explicit `building_seed` or derive from shape/params? Verify desired UX and reproducibility.
4. Object catalogs/dirs: wall-mounted object `dir` conventions differ by type. Verify per-family dir rules before placing consoles, windows, machines.
5. Ready status risk: rewrite may temporarily regress a ready generator. Decide whether to keep `WORLD_EDIT_STATUS_READY` during phased rollout.

**Alternatives**
1. Recommended: staged modular core replacement. Split `building_layout` into archetypes, layout state, geometry solver, anchors, placer, validator, and plan emitter. Start with 3-5 archetypes, old core unreachable for those.
2. Minimal patch: extend current slot/cap/scoring logic. Fast, but fails the deepsearch goal and should be rejected for this request.
3. Template/DMM-first: build curated chunks and assemble them through blueprint/template services. Good later for clusters/facades, but too content-heavy as the core solver.

Recommendation: Alternative 1, with `layout_state -> world_edit_plan` as the first emitter and DMM/template overlays added only after the semantic pipeline and validators are stable.






====================================================
# 3
Read-only task. Repository: d:\GitHub\BandaTroopersFork. Follow AGENTS.md order enough for this task, but do not edit anything. User wants a detailed plan first, challenge/doubts, then only later implementation for World Edit building generator based on:
- modular/world_edit/docs/deepsearch/Генерация построек - разбор.md
- modular/world_edit/docs/deepsearch/Генерация построек - цель.md

You are subagent C: risk and verification analyst. Inspect existing World Edit generator code/tests/build docs as needed, read-only only. Focus on:
1) BYOND/DM list mutation safety and runtime runaway risk in current/planned generator path;
2) existing tests or testable seams for generated DMM/blueprint output;
3) likely minimal verification commands per repo rules;
4) missing validators/golden seed opportunities;
5) line/file evidence. Do not implement.


Ответ:
Read-only inspection completed. No files changed.

**Summary**
Current World Edit building generation is bounded enough for its present simple plan path, but the planned “semantic graph -> constraint geometry -> furnishing -> validation -> DMM/blueprint” generator would need stronger runtime budgets, list-mutation discipline, and deterministic output tests before implementation.

Active task-state files are currently for an unrelated AI-agent-instructions task, so before any later implementation the main agent should replace `PLAN.md`, `TODO.md`, `DECISIONS.md`, and `EVIDENCE.md` with a generator-specific contract.

**Key Risks**
1. Shape construction can run before generator footprint validation.
   The building generator caps validated footprints at 512 turfs and interiors/windows at small limits in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1), then validates in [same file](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:459). But shape turfs are built earlier by the placement runtime in [world_edit_manager_placement_runtime.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/manager/runtime/world_edit_manager_placement_runtime.dm:1012). Pair-end rectangles and derived-radius shapes can loop over large bounds before final anchor caps fire in [world_edit_placement_shapes.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/shared/world_edit_placement_shapes.dm:1210) and [world_edit_placement_shapes.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/shared/world_edit_placement_shapes.dm:1272).

2. Current building apply path is reasonably bounded.
   Preview is required in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:7), plan build is bounded by footprint/window/interior caps, and apply reuses `current_plan` in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1728). Apply iterates plan placements directly in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1770).

3. Planned solver/list-heavy stages are the bigger BYOND/DM list risk.
   I did not see an obvious unsafe nested-list removal pattern in the current building-layout file. Existing code mostly uses bounded loops and `Cut()` for clearing local lists, e.g. [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:943). For the planned generator, avoid `outer -= candidate` when candidates are lists; store indexes and use `Cut(index, index + 1)`.

4. Current generator lacks semantic validators.
   The existing generator uses hard-coded faction/layout slot catalogs in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:47) and furnishing slot sequences in [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1024). It does not yet validate room graph reachability after furnishing, door cones, privacy, wall-mounted direction rules, density/repetition, or facade/window consistency.

**Existing Test Seams**
There are existing blueprint/DMM unit tests, but not building-generator tests. `_unit_tests.dm` includes `world_edit_blueprints.dm` in [code/modules/unit_tests/_unit_tests.dm](d:/GitHub/BandaTroopersFork/code/modules/unit_tests/_unit_tests.dm:92). Those tests already cover parse/serialize/reparse, bounds, bad paths, unsupported vars, and safe IDs in [world_edit_blueprints.dm](d:/GitHub/BandaTroopersFork/code/modules/unit_tests/world_edit_blueprints.dm:19) and [world_edit_blueprints.dm](d:/GitHub/BandaTroopersFork/code/modules/unit_tests/world_edit_blueprints.dm:83).

Useful seams for new tests:
- call `build_plan_from_shape_contract()` directly from a unit test, [world_edit_generator_building_layout.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/generators/building_layout/world_edit_generator_building_layout.dm:1484)
- assert generated `plan.placements`, `affected_turfs`, and metadata
- serialize planned blueprint/DMM output through existing storage/schema code, especially [world_edit_blueprint_library_storage.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:199) and [world_edit_blueprint_library_storage.dm](d:/GitHub/BandaTroopersFork/modular/world_edit/code/core/blueprints/world_edit_blueprint_library_storage.dm:333)

**Minimal Verification Commands**
For later implementation, likely minimal path:

```powershell
tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
```

If adding blueprint/DMM golden files or parser-facing output:

```powershell
tools/bootstrap/python -m mapmerge2.dmm_test
```

If adding runtime unit tests, compile first, then run the repo’s unit-test target/server flow per CI rather than full `dm-test` on every iteration. Full runtime testing should be reserved for final validation or high-risk solver changes.

All-map compile is only warranted if the work changes committed map files or map templates.

**Missing Validators / Golden Seeds**
Add deterministic golden-seed coverage around:
- one compact living archetype
- one workshop/storage archetype
- one checkpoint/wedge archetype
- one invalid or repair-heavy seed
- DMM/blueprint roundtrip: generated output -> parse -> validate -> serialize -> reparse
- metrics assertions: connected rooms, valid doors, no blocked entry buffer, wall-mounted objects face walls, max density, no duplicate object slot, no excessive repeat index

**Challenge / Doubts**
The target docs describe a much larger system than the current generator: semantic rooms, anchors, scoring, repair, and mass seed validation. A partial wrapper around the existing `building_layout` path would not satisfy that plan. The risky part is not spawning the final objects; it is candidate generation, scoring, repair, and shape expansion. The implementation contract should explicitly cap every stage, require deterministic seeds, and reject substitutions that leave old scatter-like furnishing as the reachable core.





===================================================
# 4
Начинаем реализацию по доработке генератора построек WOrld Edit следуя документам:
```
modular/world_edit/docs/deepsearch/Генерация построек - разбор.md 
modular/world_edit/docs/deepsearch/Генерация построек - цель.md
```

Сначала подробный план, потом сверка и сомнения, и только потом реализация.
Работай как оркестратор с суб агентами.



Ответ:
Уже видно главное отличие текущего кода от цели: `building_layout` сейчас один монолитный proc-файл на 1800+ строк, где footprint, стены, двери, окна, перегородка, интерьер и runtime apply смешаны в одном типе. Это не обязательно значит “полный rewrite с нуля”, но old-path audit точно нужен: текущий scatter/slot-путь не должен остаться основным механизмом, если утверждаем семантический пайплайн.

Далее не доделали, необходимо продолжить.
