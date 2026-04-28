# HALO PORT BACKLOG

Secondary tracking document for the active `PR #94` refresh after HALO `PR #96` was merged into BT master.

## Current Track
- Source repository: `https://github.com/cmss13-devs/cmss13-pve-halo`
- Shared merged master baseline: `upstream/master @ 5d2ad73b68727b88c7b02cf005a4af72f855babd`
- Active branch: `halo_jackal_spartan_wave_apr2026`
- Primary user-facing goal: bring `PR #94` to a playable post-merge state without breaking SS220 modular ownership.

## Historical Inputs
- Original `PR #94` content already carried the base Kig-Yar and Spartan import.
- BT `PR #96` then landed the main HALO sync wave on master.
- The current branch therefore does not re-port main-wave scope. It layers gameplay completion on top of the merged base.

## Upstream Anchors Still Relevant Here
- `PR #97`: Kig-Yar framework plus late Unggoy tail
- `PR #100`: original Spartan import base already present on this branch
- Current upstream master audit: `a4943e1cd28387b86e47ba282a8cd06e7b953c96`

## Delivered On Current Head
- Refreshed the branch from BT master after `PR #96`; only the merge commit itself remains to conclude the refresh.
- Refreshed Kig-Yar/Ruuhtian preset ownership so split-faction behavior survives across:
  - `Create Humans`
  - `HumanAI Spawn`
  - `Squad Spawner Panel`
- Finished Sangheili and Unggoy preset exposure where legacy AI-only paths still hid playable variants or dropped correct subfaction ownership.
- Added modular Spartan HumanAI presets and Spartan squad presets.
- Expanded lore-aligned HALO squads so Kig-Yar, Sangheili, Unggoy, and Spartan groups have practical patrol, marksman, strike, and command variants.
- Extended HALO unit coverage for:
  - split-faction equipment preset contracts;
  - Kig-Yar and Spartan species contracts;
  - HumanAI preset faction wiring;
  - new squad preset path validity.
- Refreshed branch-facing docs and changelog text so `PR #94` no longer describes itself as only a narrow Kig-Yar tail.

## Explicit Non-Goals
- Do not reopen merged `PR #96` scope except where the current master merge requires conflict resolution.
- Do not collapse HALO modular code back into `code/**`.
- Do not reintroduce wholesale upstream layout just to mirror filenames.

## Completion Check
- Merge state is clean after the pending merge commit is written.
- No unresolved conflict markers remain.
- HALO preset and squad surfaces expose playable Kig-Yar, Sangheili, Unggoy, and Spartan content under SS220 modular rules.
- Validation commands pass or any remaining failures are documented as pre-existing.
