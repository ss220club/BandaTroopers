# EVIDENCE - Canonical Building Layout correctness continuation

## Baseline discovery 2026-07-22

- `HEAD` and PR #99 head are `91afe9c71c4a5e156c73d4972caac292e4745394`; PR remains draft.
- Worktree contains only the user's appended `17.07.06_review.md`; it is preserved untouched.
- The one production entrypoint remains `build_building_layout_candidate_state() -> solve_building_layout() -> emit_building_layout_plan()`.
- `modular/modular.dme` includes `world_edit/_world_edit.dme`; that include file still loads canonical solver plus legacy semantic, room-graph and BSP layers.
- Existing local reports: living/hydroponics/workshop supported; kitchen/laboratory/dormitory/storage `no_solution`. They lack SHA metadata and are not final baseline evidence.
- GitHub checks for this SHA: Windows Build and unit matrices succeeded; Run Linters, OpenDream lint and MapDiffBot2 failed.

## Confirmed P0 code paths

- Family `hard_validate()` only checks family id and non-empty rooms; `route_hints` are seed metadata and are not consumed by terminal A*.
- Candidate connection compilation converts every non-functional topology endpoint to the literal `route`.
- Connection/opening datums overload `kind`; room `route_opening_kind` overrides topology edge kind.
- Beam conflict reserves a one-tile ring for every room, all non-route edge kinds use the same partition overlap check, and the first route-feasible complete partial wins.
- Terminal A* intentionally selects the farthest first terminal; entry ownership uses insertion order rather than BFS distance.
- Partitions are room-perimeter wall turfs plus `materialize_building_layout_partition_corner_joins()`; `open_bay_perimeter` can force the root open.
- Residual counting only sees route cells labelled `circulation_open_bay`, so unlabeled interior can false-green.
- Room preferred area still includes equal division of useful area; composition satisfaction uses fixture count credit and required generic fallback remains available.
- Old route/overlay helpers and duplicate canyon computation remain in the compiled source; topology signature includes exact room/route coordinates.

## SHA-bound baseline 2026-07-31

- Python tooling syntax check passed; Werror build passed with `0 errors, 0 warnings`.
- The bounded runtime wait fixed the startup race: all seven cases produced matching `report.json`, `semantic.json`, `semantic.png` and `semantic_sprites.png` with `source_sha=91afe9c71c4a5e156c73d4972caac292e4745394`.
- `building_workshop_target_rooms_6` is the only supported case (`open_bay_perimeter`, 4 hard-valid candidates, zero expectation diffs).
- Living, hydroponics, kitchen, laboratory, dormitory and storage are honest `program.insufficient_footprint` / `no_solution` failures with 18/8/6/6/7/7 expectation diffs respectively.
- Immutable artifacts and workflow log are preserved under `.AI_AGENT/logs/building_layout_baseline_91afe9c_20260731/`; no DreamDaemon process remains.

## Self plan-mapping challenge

Status: PASS WITH RISKS

Revalidated against unchanged `HEAD` on 2026-07-31 after explicit user approval. The entrypoint, P0 callsites, forbidden substitutions and unrelated review-document diff are unchanged; implementation may proceed in the recorded dependency order.

- PASS: all 18 review blockers map to existing canonical solver files and can be fixed without changing the public generator entrypoint.
- PASS: the old route/overlay definitions are not used by the current allocation orchestration and can be removed after exact callsite checks.
- PASS: current datums provide migration points for typed policies, segment ownership and composition recipes.
- RISK: deleting false-green paths will keep several cases red until later stages. Mitigation: preserve immutable expectations and report stage-specific failures.
- RISK: typed circulation IDs affect route terminal, opening, validator and semantic export consumers together. Mitigation: change the contract and all callsites atomically with focused tests.
- RISK: real nested geometry conflicts with the current universal partition ring. Mitigation: edge-specific candidate generation and a nested ownership model must land in the same slice.
- RISK: canonical partition segments touch openings and wall validation. Mitigation: segment extraction precedes materialization; no compatibility rasterizer remains reachable.
- RISK: legacy semantic helpers may still have productive callsites outside solver orchestration. Mitigation: migrate only proven reusable helpers, then require definition/include/callsite zero audits.

## Plan fidelity matrix

| ID | Requirement | Evidence | Status |
| --- | --- | --- | --- |
| M1 | Refresh exact-HEAD baseline and task contract. | SHA-bound baseline section and preserved artifacts. | DONE |
| M2-M9 | Remove masks; implement typed families/allocation/route/partition/composition/quality. | Source diff, focused units, reports and old-path audits. | PENDING |
| K1 | Preserve canonical public/runtime contracts. | Entrypoint/include and preview/apply/undo audits. | ACTIVE |
| R1 | No alternate/fallback/visual repair. | Forbidden-token and callsite audits. | ACTIVE |
| C1-C3 | Fixed artifacts, compile/units, full matrix/smoke/final audit. | Fresh logs and summaries. | PENDING |
