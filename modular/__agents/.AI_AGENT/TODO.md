# TODO - Canonical Building Layout correctness continuation

| ID | Type | Requirement | Status |
| --- | --- | --- | --- |
| M1 | MUST | Refresh the exact-HEAD seven-case baseline and synchronize task-state to the `91afe9c71c` verdict. | DONE |
| M2 | MUST | Delete legacy route/overlay/support/fallback paths and make residual ownership label-independent. | PENDING |
| M3 | MUST | Preserve circulation IDs and separate edge/opening/route policies. | PENDING |
| M4 | MUST | Implement hard invariants and typed route constraints for all seven families. | PENDING |
| M5 | MUST | Implement edge-specific allocation and select the best route-feasible complete partial. | PENDING |
| M6 | MUST | Use minimum incremental route cost, family route policy, stable segment ownership and bounded cleanup. | PENDING |
| M7 | MUST | Replace perimeter rasterization/corner joins with canonical partition segments. | PENDING |
| M8 | MUST | Implement module-aware sizing and curated-only required atomic composition semantics. | PENDING |
| M9 | MUST | Unify validation, split structural signature/geometry hash and complete reporting/legacy include removal. | PENDING |
| K1 | KEEP | Preserve one canonical public pipeline, bounded execution and semantic/public runtime compatibility. | ACTIVE |
| R1 | REJECT | No alternate/fallback solver, masking repair, visualizer generation or score-only closure. | ACTIVE |
| C1 | CHECK | Seven fixed cases emit SHA-bound report/semantic/image artifacts without expectation weakening. | RED BASELINE CAPTURED; final green pending |
| C2 | CHECK | Focused solver units and Werror compile pass after each implementation slice. | PENDING |
| C3 | CHECK | 840-case matrix, 15-program smoke, determinism replay and final audits pass. | PENDING |

## P0 mapping

| Review blockers | Contract item |
| --- | --- |
| P0.1-P0.2 | M4: family invariants and typed route constraints |
| P0.3-P0.4 | M3: circulation identity and explicit policies |
| P0.5-P0.6 | M5: edge-aware beam and best complete partial |
| P0.7-P0.8 | M6: incremental route network and stable ownership |
| P0.9-P0.10 | M7/M4: partition segments and explicit open-bay owner |
| P0.11 | M2: honest residual ownership |
| P0.12 | M8: module-aware room sizing |
| P0.13-P0.15 | M8: recipe/capacity semantics and explicit wall/front/interaction dirs |
| P0.16-P0.17 | M2/M9: legacy removal and one validator per counter |
| P0.18 | M9: structural signature separate from geometry hash |

## Forbidden substitutions

- Wrapper/guard around legacy masking code instead of deletion.
- Family seed rectangles or score weights presented as family hard guarantees.
- Normalizing circulation endpoints back to the literal `route` identifier.
- Direct or synthetic room-route edges not authored by topology/route constraints.
- Generic/generated required composition fallback, budget inflation or member-level pruning.
- Post-emission RECT repair, diagonal corner joins or expectation weakening.
- Test-only closure without diff/callsite evidence.

## Old path audit

| Old path | Required result |
| --- | --- |
| `materialize_building_layout_circulation_overlay()` | Definition and callsites removed. |
| `solve_building_layout_route_after_rooms()` | Definition and callsites removed. |
| `connect_building_layout_route_to_rooms()` / `building_layout_room_plan_has_route_partition()` | Definitions and callsites removed. |
| scene support/budget/fallback helpers | Removed from required flow; generated fallback optional-only. |
| `materialize_building_layout_partition_corner_joins()` | Removed; segment builder owns joins. |
| immediate-neighbor canyon validator | Removed; route-band validator is sole counter writer. |
| circulation endpoint normalization to `route` | Removed from connection and validation flow. |
| legacy semantic/BSP/room-graph/divider includes | Removed after helper migration and zero callsites. |
