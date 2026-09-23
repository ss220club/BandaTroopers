# DECISIONS - Canonical Building Layout correctness continuation

## D-001: The `91afe9c71c` verdict supersedes the July 17 task-state

The original `cc210d` rewrite contract remains architectural context, but the appended head review is the active implementation contract. M4-M10 are partially scaffolded, not pending-from-zero and not complete.

## D-002: Preserve the scaffold, replace its weak guarantees

Keep topology/program datums, bounded beam/A*, composition contract, quality vector and one canonical entrypoint. Rework their internals; do not revert to `cc210d` and do not add another solver.

## D-003: Correctness proceeds in dependency order

Delete masking/dead paths and fix residual first, then normalize typed contracts, families, allocation, route/partitions, compositions, and finally reporting/legacy includes. Red cases during intermediate slices are valid evidence and must not be hidden.

## D-004: Current CI status is separate from generator acceptance

For HEAD, Windows Build and unit matrices passed, while linter/OpenDream/MapDiffBot checks failed. Those checks are tracked as final verification fallout; they do not prove or disprove spatial correctness.

## D-005: Baseline artifacts must be SHA-bound

Existing July 17-18 reports do not include a commit SHA. Regenerate the seven fixed cases before product-code changes and add/report an exact SHA field rather than relying on timestamps.

## D-006: The main agent performs the plan challenge

No subagents are used because repository and collaboration rules require explicit user authorization for delegation.
