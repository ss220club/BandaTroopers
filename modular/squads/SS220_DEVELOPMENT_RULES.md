# SS220 Development Rules

This document defines:
- change marking rules for hardcode,
- modularity and upstream maintenance rules,
- AI collaboration rules for coding tasks.

## 1. Change Marking Rules (Hardcode Only)

Scope:
- upstream hardcode (`code/...` and other non-`modular/` paths).

1. Removed lines must not be fully deleted.
2. Old logic should stay nearby as commented lines.
3. If only one line is changed (including minor edits), mark that same line with:
   - `// SS220 EDIT: <what changed / added / removed>`
4. For minor single-line edits (variable replaced, value changed, item added to list, argument added, etc.), use inline marker only; do not wrap a one-line change into START/END block.
5. If several nearby lines are changed, wrap the block with:
   - `// SS220 EDIT - START`
   - `// SS220 EDIT - END`
6. If a line is replaced, keep old line commented directly above the new line.
7. Inline markers must include a short concrete note (for example: `added new arg`, `switched key`, `replaced runtime name with static bucket`).

Example (single line):

```dm
value = new_value // SS220 EDIT: changed value source old_value -> new_value
```

Example (single line, argument added):

```dm
target_proc(arg1, arg2, extra_arg) // SS220 EDIT: added extra_arg for latejoin context
```

Example (block):

```dm
// SS220 EDIT - START
// old_call(arg1, arg2)
new_call(arg1, arg2, arg3)
if(new_condition)
    handle_new_flow()
// SS220 EDIT - END
```

## 2. Modularity + Upstream Rules

1. New feature logic goes to `modular/squads/...` first.
2. Hardcode gets only minimal integration points:
   - module hook calls,
   - safe fallbacks,
   - unavoidable bugfix glue.
3. Do not move large business logic into hardcode if module code can handle it.
4. Keep hardcode diff minimal; avoid unrelated refactors in upstream files.
5. Keep stable upstream contracts and keys unless change is absolutely required.
6. Before hardcode edits, check existing extension points/hooks.
7. Prefer adapters/wrappers over rewriting upstream subsystems.
8. After upstream sync, re-check all `SS220` markers.
9. Do not add `SS220` marking comments inside `modular/squads/...` unless explicitly requested.

Recommended check:

```bash
rg -n "SS220 EDIT" code
```

## 3. Code Quality Rules (OOP + SOLID)

1. Single Responsibility: one unit of code = one clear responsibility.
2. Open/Closed: extend via hooks/modules, avoid invasive base rewrites.
3. Liskov safety: do not break expected behavior of inherited/compatible types.
4. Interface Segregation: small focused APIs over broad catch-all procedures.
5. Dependency Inversion: depend on abstractions/hooks, not concrete internals.
6. Avoid hidden side effects and duplicate logic.
7. Non-trivial decisions must be explainable by code and diff.

## 4. AI Collaboration Rules

1. Do not assume; gather context first (callsites, data flow, side effects).
2. Doubt solution before running: check edge cases and regressions.
3. Define bug cause explicitly before implementing fix.
4. Validate that fix addresses root cause, not only symptom.
5. Verify after edits:
   - touched call paths,
   - behavior integrity (spawn/manifest/prefs/etc),
   - no accidental unrelated changes.
6. Do not use destructive git commands without explicit request.
7. Do not finalize task without at least diff-level verification.

## 5. Finalization Checklist

1. Logic is modular; hardcode is integration-only where possible.
2. `SS220` markers follow the format rules.
3. Removed hardcode lines are preserved as comments.
4. Diff is local and readable.
5. Critical scenarios and fallback paths were checked.
