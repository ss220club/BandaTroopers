# PR #99: исполнимый план для Codex и субагентов

**Baseline:** PR #99, head `050a5790352b0b54f78585e0a54fce4dfacf7ebe` на 18 июня 2026 года.  
**Главная спецификация:** `PR99_TOTAL_REWORK_SPEC.md`  
**Режим:** Codex выполняет весь цикл самостоятельно; пользователь подключается только к финальному UAT.

---

## 1. Роль главного Codex-оркестратора

Оркестратор отвечает не за написание всего кода одним потоком, а за сохранение архитектурного контракта и сбор доказательств.

Обязанности:

1. Зафиксировать актуальный head SHA перед началом.
2. Провести discovery-first поиск по entrypoints, includes и callsites.
3. Создать локальные task-state notes, но не коммитить их.
4. Раздать субагентам непересекающееся владение файлами.
5. Не принимать handoff без tests и evidence.
6. Интегрировать через последовательные compile-clean commits.
7. Запускать автоматические gates после каждого merge субагента.
8. Не просить пользователя проверять промежуточные результаты.
9. Остановить merge, если остаётся хотя бы один hard blocker из спецификации.
10. Перед финалом назначить независимого red-team агента, который не участвовал в реализации.

### Первый обязательный discovery pass

```bash
rg -n "building_layout|world_edit_visual|world_edit_blueprint" colonialmarines.dme modular/modular.dme modular/world_edit code/modules/unit_tests tgui tools/world_edit_visual
rg -n "room_first_layout|supported_placement_shapes|apply_plan|finish_supported|expect_config|enabled.txt" modular/world_edit code tgui tools
rg -n "SS220 EDIT" code map_config
rg -n "SS220 EDIT" modular -g '!modular/__agents/**' -g '!modular/__docs/**'
```

Проверить include chain:

```text
colonialmarines.dme
  -> modular/modular.dme
  -> modular/world_edit/_world_edit.dme
```

До завершения discovery никаких mutating действий.

---

## 2. Схема веток/рабочих деревьев

Использовать отдельный worktree/branch для каждого субагента. Нельзя давать двум агентам одновременное владение одним production-файлом.

Рекомендуемые ветки:

```text
codex/pr99-cleanup
codex/pr99-blueprints
codex/pr99-domain
codex/pr99-solver
codex/pr99-furnishing
codex/pr99-transaction
codex/pr99-acceptance
codex/pr99-tgui
codex/pr99-red-team
```

Оркестратор cherry-pick/merge выполняет только после gate соответствующего этапа.

---

## 3. Dependency graph

```text
A Cleanup/Baseline
├── B Blueprint Library
└── C Domain Contracts
    ├── D Footprint/Topology/Partition Solver
    └── E Style/Furnishing System
         └──────┐
D ──────────────┼── F Apply Transaction + Undo
E ──────────────┘
C/D/E/F ─────────── G Acceptance Runner
C/D/E/F ─────────── H TGUI
B/C/D/E/F/G/H ───── I Independent Red Team
```

Параллельность:

- B и C можно выполнять параллельно после A.
- D и E можно выполнять параллельно после C.
- G и H можно выполнять параллельно после интеграции C–F.
- I выполняется только на собранной ветке.

---

## 4. Субагент A — Cleanup и baseline evidence

### Цель

Сделать PR обозримым и вернуть production startup к безопасному состоянию.

### Read scope

- PR changed file list/diff;
- `colonialmarines.dme`;
- `modular/modular.dme`;
- `modular/world_edit/_world_edit.dme`;
- `code/game/world.dm`;
- `.gitignore`;
- `tools/world_edit_visual/**`;
- docs/research files.

### Exclusive write ownership

- `code/game/world.dm`;
- `.gitignore`;
- `modular/world_edit/_world_edit.dm`;
- cleanup-only removals в `tools/world_edit_visual/**`;
- removal/consolidation of scratch docs/scripts.

### Tasks

1. Revert Workbench changes in `code/game/world.dm`.
2. Remove duplicate Workbench init from modpack until Agent G adds explicit test entrypoint.
3. Remove tracked `enabled.txt` and all outputs.
4. Remove `plan`, `_write.ps1`, `fix_stages.py`, user/local cases.
5. Remove temporary analysis scripts or move useful code into a single future validator stub.
6. Consolidate docs list; do not yet describe unimplemented target behavior as current.
7. Produce baseline test log on base SHA and current branch for comparison.
8. Verify no unrelated dirty files.

### Deliverables

- cleanup commit;
- `EVIDENCE` in handoff message, not tracked task file;
- exact list of removed artifacts;
- base/current build comparison.

### Gate

```bash
git diff --check
git ls-files tools/world_edit_visual/out tools/world_edit_visual/enabled.txt tools/world_edit_visual/inbox
```

Second command must be empty.

DM build must pass or have base-proven unrelated failures.

---

## 5. Субагент B — Transactional DMM Blueprint Library

### Цель

Завершить DMM migration без потери display metadata и без file-system split-brain.

### Read scope

- `modular/world_edit/code/core/blueprints/**`;
- manager blueprint actions/cache/payloads;
- blueprint stamp generator;
- old JSON seeds at base SHA;
- new DMM seeds;
- `code/modules/unit_tests/world_edit_blueprints.dm`;
- related TGUI types only read-only.

### Exclusive write ownership

- `modular/world_edit/code/core/blueprints/**`;
- `modular/world_edit/code/core/manager/session/blueprints/**`;
- blueprint-specific unit tests;
- `data/world_edit/blueprints/library.index.json` and migration data;
- no TGUI writes.

### Tasks

1. Define metadata index schema v1.
2. Migrate friendly names/created metadata from removed JSON seeds.
3. Add load/rebuild/fallback behavior for index.
4. Add temp-file transaction abstraction.
5. Rewrite save/import/rename/delete.
6. Use `frename` for same-directory atomic moves.
7. Implement rollback for index update failures.
8. Separate rename ID and rename display name service methods.
9. Add content-hash based cache invalidation.
10. Audit DMM parser allowlists and all 34 curated maps.
11. Add fault injection seam for tests; no production random failure code.
12. Ensure operations never leave cache ahead of disk.

### Required tests

- content roundtrip;
- metadata restart persistence;
- ID/display-name separation;
- rename rollback;
- delete rollback;
- import rollback;
- index rebuild;
- corrupted index;
- DMM hash mismatch;
- all curated DMM audit;
- unsafe path, vars, multi-z, oversize.

### Handoff contract

Return:

- public proc list;
- schema sample;
- migration report count;
- test commands/results;
- known limitations: must be empty for merge scope.

### Gate

DM build, unit tests, mapmerge/maplint, `git diff --check`.

---

## 6. Субагент C — Typed Domain и единый status contract

### Цель

Создать фундамент нового генератора без geometry implementation.

### Read scope

- current generator entrypoint;
- current archetypes/request/state/validators;
- World Edit shape/plan/preview contracts;
- manager runtime and history;
- current unit tests.

### Exclusive write ownership

- `building_layout/domain/**`;
- `building_layout/catalog/building_program_catalog.dm` skeleton;
- `building_layout/catalog/building_style_catalog.dm` skeleton;
- `building_layout/validation/building_validation_verdict.dm`;
- thin changes to `_world_edit.dme` includes for new files.

### Tasks

1. Define typed request fields.
2. Define size profiles and overwrite policy enums.
3. Define footprint, program node/edge, candidate and verdict datums.
4. Define stable error codes.
5. Define stage result contract.
6. Define compact production diagnostics and optional debug trace.
7. Remove use of a generic `config` assoc list after normalization boundary.
8. Create server-side capability payload contract for TGUI.
9. Add catalog validation at initialization.
10. Add unit tests independent of world map where possible.

### Hard decisions

- Supported placement shapes: point, rectangle, filled_rectangle.
- No hidden micro/degradation.
- No silent fallback.
- One definition of hard error.

### Gate

- catalog validation tests;
- request normalization tests;
- status invariant tests;
- build pass.

---

## 7. Субагент D — Footprint, topology, partition и routing solver

### Цель

Заменить monolithic room-first geometry настоящим bounded graph-constrained solver.

### Dependency

Agent C merged.

### Read scope

- current geometry/BSP/room graph/footprint code;
- shape contracts;
- current program definitions read-only;
- existing route validators.

### Exclusive write ownership

- `building_layout/solver/**`;
- `building_layout/validation/building_footprint_validator.dm`;
- `building_layout/validation/building_topology_validator.dm`;
- solver-specific unit tests.

### Tasks

1. Implement footprint normalization.
2. Implement RECT/L/T/U family mask builders for point mode.
3. Implement explicit rectangle exact mask.
4. Implement feasibility model.
5. Implement program graph materialization.
6. Implement constrained room ordering.
7. Implement beam-search partition.
8. Implement route/opening solver.
9. Implement hard topology validator.
10. Implement candidate scoring and deterministic tie-break.
11. Ensure all valid candidates are compared.
12. Remove first-valid break and legacy geometry fallback.
13. Track bounded expansion counters.
14. Add deterministic layout hashes.

### Required invariants

- no overlap;
- all mandatory rooms fit;
- required edges realized;
- entry reaches every mandatory room;
- no disconnected footprint;
- requested direction honored;
- no hard repair after emission.

### Required tests

- each family/direction;
- smallest valid footprint;
- one-cell-too-small rejection;
- best candidate selection;
- deterministic same seed;
- diversity across seeds;
- no-solution diagnostics;
- expansion limits.

### Gate

Fast solver matrix must pass before handoff. No furnishing required; placeholder capabilities can be mocked through Agent C interfaces.

---

## 8. Субагент E — Programs, styles и capability-based furnishing

### Цель

Перенести программы и presets из hardcoded/fallback системы в проверяемый catalog.

### Dependency

Agent C merged. Может выполняться параллельно с D.

### Read scope

- `building_layout_archetypes.dm`;
- `building_layout_programs_extra.dm`;
- faction catalog in main generator;
- fixtures/templates/macros/signatures/infrastructure;
- DMM template chunks;
- actual object type behavior.

### Exclusive write ownership

- `building_layout/catalog/programs/**`;
- `building_layout/catalog/styles/**`;
- `building_layout/furnishing/**`;
- furnishing validators/tests;
- map template chunks only when necessary.

### Tasks

1. Convert each current program to typed room/connection/capability definitions.
2. Separate mandatory and optional features.
3. Remove region-percentage hints that conflict with solver, or convert them to soft preferences.
4. Build functional capability taxonomy.
5. Audit every style provider against actual gameplay function.
6. Lock incompatible combinations rather than using visual substitutes.
7. Compile DMM templates to rotated module variants.
8. Add prefiltered anchor enumeration.
9. Place required fixtures atomically.
10. Eliminate semantic credit without emitted objects.
11. Eliminate generic single-object fallback for required clusters.
12. Keep decorative microvariation last and optional.
13. Set per-program style compatibility matrix.

### Special audit

Covenant mappings must be treated as unsupported unless actual equivalent paths exist. Barricades/rechargers cannot satisfy bed, sanitation, APC or alarm capabilities merely because a path is present.

### Required tests

- every registered program validates;
- every compatible style supplies all mandatory capabilities;
- every incompatible combination returns exact reason;
- required template rotations/clearance;
- route remains clear;
- object budgets;
- no fake credit/fallback.

### Gate

Capability matrix must have zero unexplained entries. Programs with no valid style are not registered as supported.

---

## 9. Субагент F — Plan emitter, atomic apply и undo

### Цель

Гарантировать all-or-nothing изменение мира.

### Dependencies

Agents C, D, E merged.

### Read scope

- World Edit plans/changesets/history;
- current apply code;
- blueprint stamp/outpost apply patterns;
- manager preview revision handling.

### Exclusive write ownership

- `building_layout/runtime/**`;
- generator preview/apply adapter portions;
- `world_edit_changesets.dm` только через согласованный минимальный extension;
- apply/undo tests.

### Tasks

1. Implement pure plan emitter.
2. Compute target state hash.
3. Implement resolve/conflict/commit/validate state machine.
4. Capture rollback snapshot before first mutation.
5. Roll back on any turf/object/post-validate failure.
6. Publish changeset only after successful commit.
7. Integrate with World Edit history.
8. Implement independent post-apply world inspection.
9. Implement undo restoration validation.
10. Set safe blocker defaults.
11. Add structured apply errors and no warning-success path.

### Fault injection

Provide test-only injected failures at:

- resolve N;
- ChangeTurf N;
- object creation N;
- post-apply validation;
- rollback N.

Production build must not expose user-facing fault switches.

### Gate

- 100% rollback tests;
- zero partial apply;
- undo restoration exact;
- build/unit tests.

---

## 10. Субагент G — One-shot acceptance runner и CI gate

### Цель

Заменить polling Workbench проверяемым headless runner.

### Dependencies

Agents C–F merged.

### Read scope

- current visual workbench DM;
- Python/BAT scripts;
- unit test harness;
- build workflows;
- semantic/sprite renderers.

### Exclusive write ownership

- `modular/world_edit/code/visual_workbench/**` либо новая `code/acceptance/**` директория;
- `tools/world_edit_visual/**` automation;
- acceptance cases/reports schema;
- runner tests;
- CI integration if within approved existing workflow contract.

### Tasks

1. Remove file poll loop and enable flag.
2. Implement explicit one-shot DM entrypoint.
3. Reuse production request/preview/apply interfaces.
4. Execute post-apply and undo validation.
5. Implement case schema v2.
6. Implement expectation validation.
7. Implement aggregate nonzero exit status.
8. Make Python workflow cross-platform or delegate to existing repo test tooling.
9. Preserve semantic/sprite rendering as optional artifacts.
10. Add report schema validator.
11. Add fast and full matrix generation.
12. Ensure outputs are temporary/ignored.
13. Add regression cases for every former known error.

### Required tests

- expectation mismatch;
- hard error status invariant;
- expected rejection;
- missing report;
- stale workflow artifact;
- batch aggregate failure;
- pass case;
- artifact-off mode.

### Gate

One command must:

- launch runner;
- execute cases;
- validate reports;
- exit 0/1 correctly;
- require no manual DreamDaemon interaction.

---

## 11. Субагент H — TGUI и admin workflow

### Цель

Сделать UI отражением server capabilities и безопасного runtime contract.

### Dependencies

Agents C–F merged. Может выполняться параллельно с G.

### Read scope

- TGUI WorldEditPanel;
- server payloads/actions;
- blueprint UI;
- generator fields.

### Exclusive write ownership

- `tgui/packages/tgui/interfaces/WorldEditPanel/**`;
- corresponding server UI payload/action files, согласованные с F/B;
- TGUI tests.

### Tasks

1. Render only server-supported shapes.
2. Filter styles by selected program compatibility.
3. Add size profile.
4. Remove misleading hidden auto-size semantics.
5. Show structured support/validation errors.
6. Invalidate preview on param change.
7. Add destructive replacement confirmation.
8. Separate blueprint display name and file ID.
9. Separate rename ID/name actions.
10. Keep selected blueprint preview performant.
11. Add full viewModel tests.

### Gate

```bash
tools/build/build --ci lint tgui-test
```

All viewModel tests pass, TypeScript clean.

---

## 12. Субагент I — Независимый red-team review

### Цель

Искать способы получить false success, partial world state, неподдерживаемую комбинацию или nondeterministic output.

### Ограничение

Этот агент не должен быть автором implementation commits.

### Read scope

Весь PR diff и test evidence.

### Write ownership

Только:

- новые regression tests;
- минимальные review fixes после согласования оркестратором;
- финальный audit report в PR description/comment, не внутренний agent doc.

### Attack scenarios

1. Изменение target turf после preview.
2. Dense object появляется после preview.
3. Invalid provider path.
4. Missing mandatory capability.
5. Tiny exact rectangle.
6. Edge of map/z boundary.
7. Duplicate object slots.
8. Direction rotation.
9. Same seed repeated in different invocation order.
10. Failed N-th apply placement.
11. Failed metadata index update.
12. Corrupted DMM/index.
13. Unexpected Workbench hard error with expected supported.
14. Undo после внешнего изменения созданного объекта.
15. Every advertised shape.
16. Every program/style compatibility row.

### Red-team exit criteria

- ни один false supported/pass;
- ни один partial apply;
- ни один untracked artifact;
- no unresolved review thread;
- all findings either fixed or remove affected capability from supported scope.

---

## 13. Integration procedure для оркестратора

После каждого агента:

1. Inspect diff, не доверять summary.
2. Проверить write scope.
3. Запустить `git diff --check`.
4. Запустить targeted tests.
5. Запустить DM build, если менялся DM.
6. Обновить local evidence ledger.
7. Merge/cherry-pick только green commit.
8. Перезапустить tests затронутых предыдущих подсистем.

После D+E:

- run catalog+solver matrix.

После F:

- run apply/undo fault matrix.

После G+H:

- run full DM/TGUI/map/acceptance suite.

После I:

- исправить findings;
- повторить full suite с нуля на clean checkout.

---

## 14. Команды финальной проверки

```bash
git status --short
git diff --check
rg -n "room_first_layout|enabled.txt|applied with warnings" modular/world_edit code tools
rg -n "TODO|FIXME|known issue|unresolved" modular/world_edit/code modular/world_edit/docs tools/world_edit_visual

tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
tools/build/build --ci lint tgui-test
tools/bootstrap/python -m tools.maplint.source --github
tools/bootstrap/python -m dmi.test
tools/bootstrap/python -m mapmerge2.dmm_test
tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_BASE
tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_EXTRA
```

Дополнительно:

- unit test workflow по репозиторному канону;
- fast acceptance matrix;
- full acceptance matrix;
- blueprint audit;
- no tracked artifacts check.

Любой nonzero result блокирует финал, кроме доказанного base failure. Base failure подтверждается тем же command на base SHA.

---

## 15. Формат handoff каждого субагента

Каждый агент возвращает оркестратору:

```text
Scope completed:
Files changed:
Contracts added/changed:
Tests added:
Commands run:
Results:
Artifacts/evidence:
Risks remaining:
Unsupported combinations removed:
```

`Risks remaining` для merge scope должен быть пустым. Если риск нельзя закрыть, соответствующая возможность удаляется из supported catalog/UI.

---

## 16. Финальный пакет пользователю

Пользователь получает только после полного green run:

- обновлённый PR;
- краткий список архитектурных изменений;
- таблицу реально поддерживаемых combinations;
- performance и acceptance summary;
- curated previews;
- одну финальную UAT-инструкцию.

До этого Codex и субагенты не просят пользователя:

- собирать проект;
- запускать DreamDaemon;
- проверять отдельные seeds;
- смотреть промежуточные PNG;
- подтверждать технические решения, уже зафиксированные этой спецификацией.
