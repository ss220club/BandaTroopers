# Human AI migration

## Scope

The NPC package 06 is adapted to LYNX under `modular/human_ai`.
The previous human AI core, subsystem and component source files were relocated,
not retained as a parallel implementation. Public DM type paths are unchanged.
The project DME retains its existing integrations; the package DME was not copied.
No new difficulty/settings panel is included. Existing AI management UI is retained.

## Ownership at initial migration

- `code/human_ai_interaction.dm`: original LYNX obstacle costs and overcoming
  actions, unchanged apart from source location.
- `code/brain` and `code/action_datums`: scheduling, orders, targeting and actions.
- `code/medical_items.dm` and `code/tool_items.dm`: AI-specific item hooks.
- Shared item classes retain base interfaces and minimal post-delay treatment
  validation. Independent xeno AI, HALO and lobby implementations are untouched.

These `code/` paths describe the initial migration only. The subsequent approved
subsystem refactor removed them. Current locations and obstacle-policy semantics
are documented in [README.md](README.md). Obstacle handlers are now split by
category and use shared action permissions, so baseline byte equality is historical,
not a claim about the current obstacle implementation.

## Safety changes

- Copy action whitelists before filtering; detach old target subscriptions.
- Preserve active action priority and protect committed grenade throws.
- Suspend Hold/Approach restrictions for grenade survival.
- Check timed fuse budget before recovery, rejecting obstructed approaches;
  revalidate throw destinations and faction safety.
- Respect underbarrel grenade restrictions.
- Reject stale navigation callbacks; preserve retries for the same destination.
- Keep original obstacle traversal semantics rather than blanket transit bans.
- Cancel stale medical work using treatment generations and post-delay checks.

These guards reduce unsafe behavior but do not guarantee survival in enclosed
spaces or when no safe grenade release location exists.

## Verification and remaining work

Production compilation uses `tools/build/build.bat --ci dm -DANSICOLORS -Werror`.
Final compilation on 2026-10-20 passed with 0 errors and 0 warnings.
The original obstacle handlers match the target Git baseline after line-ending
normalization. Module includes have no missing or duplicate paths, and the old
core source directory contains no files.

Package tests and migration regressions are included after the unit test macros.
The CIBUILDING compile is blocked by pre-existing undefined test macros/constants
in `modular/lobby_ui/code/shared/terminal_tests.dm`. Tests have not run; imported
expectations may need adaptation to preserved LYNX obstacle policy.
In-game verification remains necessary for grenade emergencies, doors/climbing,
order resumption and interrupted treatment.

The unrelated package ocean/turf async delta was intentionally not imported.
Potential follow-ups: navigation diagnostics, explicit obstacle permission
policies, and a persistent global NPC configuration service applying to both
existing and newly spawned NPCs (panel deferred).
