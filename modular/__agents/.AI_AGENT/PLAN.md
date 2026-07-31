# PLAN - Canonical Building Layout correctness continuation

Status: IN PROGRESS
Date: 2026-07-31
Contract: appended verdict for `91afe9c71c4a5e156c73d4972caac292e4745394` in `modular/world_edit/docs/rework_docs/tech_rework/17.07.06_review.md`
Baseline: `91afe9c71c4a5e156c73d4972caac292e4745394`
Approval: user explicitly requested implementation of this contract on 2026-07-31.

## Goal

Keep the useful typed datums and bounded infrastructure added in `91afe9c71c`, but make the existing canonical pipeline enforce authored topology, routing, partition and composition geometry:

`build_building_layout_candidate_state() -> solve_building_layout() -> emit_building_layout_plan()`.

## MUST

- Preserve circulation node identity through candidate connections and split edge kind, opening policy and route policy.
- Give all seven topology families hard invariants and typed route constraints; axial remains dimension-gated and last-resort.
- Make allocation edge-specific for `SHARED`, `OPEN_MERGE`, `SECURE`, `NESTED` and `ROUTE`, then compare the best complete route-feasible partials.
- Build a minimum-incremental-cost, family-aware terminal route network with stable segment ownership and bounded cleanup.
- Replace room-perimeter/corner-join wall rasterization with canonical ownership boundary segments and opening cuts.
- Compute residual directly from interior minus explicit owners/materialized geometry; no legacy label-based false-green.
- Size rooms from authored module footprint and require curated atomic compositions with explicit capacity/relations.
- Unify validators, separate structural topology signature from exact geometry hash and export sufficient semantic/debug evidence.
- Remove legacy route/overlay/support/fallback, duplicate validator and obsolete semantic/BSP/room-graph/divider paths after migration and zero-callsite audits.

## KEEP

- One production solver entrypoint and existing generator/config/UI preview/apply/undo contracts.
- Existing bounded caps unless a contract-backed change is required: 24 candidates, beam 6, 8 rectangles per node, 96 expansions, bounded A*.
- `world_edit_semantic/v1` compatibility; new fields remain optional.
- `tools/world_edit_visual` as read-only exporter/renderer/acceptance harness.
- The user's uncommitted review-document addition and unrelated repository state.

## REJECT

- No v3/next/experimental path, runtime flag, fallback solver, compatibility wrapper or visualizer-side generation/repair.
- No root auto-connect, universal room-to-route, blanket open-bay overlay, required singleton/generated fallback, budget inflation or per-member module pruning.
- No family-name-only validation, first-complete beam winner, global farthest-terminal trunk, root-forced open bay, diagonal corner joins or label-based residual.
- No score/counter tuning as a substitute for hard geometry.

## Delivery order

1. Refresh seven-case baseline for exact HEAD and lock expectations.
2. Remove dead/masking paths and fix residual ownership.
3. Normalize typed topology/opening/route contracts and circulation IDs.
4. Add seven family hard validators and typed route constraints.
5. Implement edge-aware beam allocation and best-complete selection.
6. Implement family-aware minimum-cost route ownership and canonical partition segments.
7. Add module-aware sizing and authored atomic composition contracts.
8. Unify quality/signatures/reporting, remove obsolete includes, and run the full acceptance matrix.

## Acceptance

- Fixed cases: living, hydroponics, workshop, kitchen, laboratory, dormitory and storage.
- Hard geometry/composition counters from the review are zero or within RECT/irregular residual limits.
- At least two hard-valid structural signatures for standard/spacious; compact may have one.
- Same seed reproduces the exact geometry hash; seed only breaks quality-prefix ties within the 0.5%/1-point band.
- Werror build, focused units, 840-case matrix, 15-program preview/apply/undo smoke, diff/old-path/process audits.
