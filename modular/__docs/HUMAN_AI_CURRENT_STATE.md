# Human AI Current State

Updated: 2026-09-21

This document records the current Human AI implementation shape in the `AI_DEV` branch. It is a current-state map, not a migration plan.

## Source Layout

- Primary include graph: `colonialmarines.dme`.
- Human AI is currently included directly from `code/modules/mob/living/carbon/human/ai/**`.
- Direct integration includes also exist in:
  - `code/__DEFINES/human_ai.dm`
  - `code/controllers/subsystem/human_ai.dm`
  - `code/datums/components/human_ai.dm`
- No `modular/npc_ai_v2` or `modular/human_ai` source tree exists in this checkout.

This means future Human AI work has an explicit architectural choice:

- keep a narrowly scoped upstream edit in `code/**` when touching the existing core is unavoidable;
- or introduce a new modular extension point under `modular/**` when adding new business logic.

Do not claim a modular Human AI migration is complete until the production include path and callsites prove it.

## Runtime Core

The runtime owner is `/datum/human_ai_brain` in `code/modules/mob/living/carbon/human/ai/brain/ai_brain.dm`.

The brain owns:

- the tied-human controller facade;
- module config and module lifecycle;
- ordered process lists before and after posture handling;
- event subscriber dispatch;
- lifecycle admission for active, dead, incapacitated, hardcrit, player-controlled, and invalid states.

The normal active tick is:

1. `process(delta_time)` checks lifecycle.
2. `process_active_ai(delta_time)` runs `process_modules_before_posture`.
3. Posture and buckle cleanup run on the tied controller.
4. `process_modules_after_posture` runs the remaining modules.

Signal-driven behavior should enter through brain event procs, not by bypassing module lifecycle checks.
Modules that perform delayed or signal/timer-driven side effects now keep local continuation helpers where useful:

- inventory: `can_continue_inventory_work()`
- combat: `can_continue_combat_work()`
- targeting: `can_continue_targeting_work()`
- cover: `can_continue_cover_work()`
- health: `can_continue_health_work()`

These helpers delegate to the brain runtime predicate and make module-local delayed callbacks, signal handlers, and process loops easier to audit.

## Context And Events

`/datum/human_ai_context` is the lightweight read/control object for module and action code.

It carries:

- `brain`
- `controller`

Actions and modules should use `context.can_continue()` or `brain.can_continue_runtime_work()` before delayed or ongoing side effects.

`/datum/human_ai_event` is the event payload wrapper. The brain emits events through `emit_ai_event()`, and module config registers event subscribers with `register_module_list_for_event()`.

Current important events include:

- initialization;
- reset before and after wake clear;
- lifecycle suspension and resume;
- target changed;
- projectile threat;
- combat entered and exit phases;
- handcuffed, species changed, body position changed, and moved.

Projectile threat events carry the perceived threat data as payload:

- `bullet`
- `from_direct_hit`
- `threat_source`
- `threat_turf`
- `threat_angle`

Combat, targeting, cover, and faction modules consume these payload fields instead of re-querying perception directly.

## Modules

The module base is `/datum/human_ai_module` in `brain/modules/human_ai_module.dm`.

Modules are created and owned by `/datum/human_ai_module_config`. Lookup is by type and optional `module_id`.

Current supported modules include:

- faction
- profile
- perception
- targeting
- cover
- grenade
- health
- communication
- guns
- navigation
- squad
- action_runtime
- combat
- conversation
- orders
- emplacement
- admin
- inventory
- melee

Module dependency expansion is handled by `brain/module_config/module_resolver.dm`. Action-required modules come from each action datum's `required_ai_modules`. The resolver uses an effective action list that subtracts blacklisted actions before adding action-required modules.

## Actions And Action Sets

Action definitions are `/datum/ai_action` subtypes under `action_datums/**`.

`GLOB.AI_actions` stores one global prototype per action type. Runtime instances are created by `/datum/human_ai_module/action_runtime`.

The action runtime:

- copies the configured whitelist before filtering and tolerates null optional lists;
- subtracts blacklist entries without mutating preset lists;
- removes already-running action types;
- skips hand-using actions while grenade throws are in async flight;
- scores candidates through `get_context_weight(context)`;
- starts non-conflicting actions;
- ticks ongoing actions through `trigger_action()` using snapshot scans so actions can delete or cancel themselves safely.

Action sets live in `brain/action_sets/action_set.dm`. They provide reusable whitelist/blacklist policy objects for presets. Include resolution is shared between whitelist and blacklist paths, detects include cycles, reports invalid includes, and treats missing local whitelist/blacklist lists as empty. Current action sets cover movement, combat, survival, grenade, melee, emplacement, and default behavior.

## Targeting, Perception, And Fire Safety

Target API is split by responsibility:

- `brain/api/targeting_api.dm` is the public brain facade.
- `/datum/human_ai_module/targeting` owns current target state, explicit target turfs, last-known target memory, and target signals.
- `/datum/human_ai_module/perception` owns sensing, target validity, visible candidates, line checks, and friendly-fire safety.

Combat-facing modules consume targeting/perception information through brain APIs and event payloads. `combat`, `cover`, and `targeting` no longer require direct local perception-module lookups for projectile threat handling.

Lost-target memory is stored in targeting:

- `last_known_target_turf`
- `last_known_target_time`
- `last_known_target_memory_duration`

`/datum/ai_action/investigate_lost_target` consumes this memory and clears it after investigation finishes.

Fire-line safety is owned by perception:

- `get_fire_line_safety()`
- `has_clear_target_line()`
- `get_friendly_fire_line_safety()`
- direct-fire friendly blockers

Ranged fire actions and weapon APIs should consume the brain facade instead of duplicating safety checks.

## Runtime Guard Surfaces

The current branch has explicit guard work in these module groups:

- inventory guards nearby-item scans, hand/equip/store side effects, weapon holster/unholster helpers, melee draw/holster helpers, and delayed grenade cleanup through `can_continue_inventory_work()`;
- combat and targeting guard combat enter/exit, target mutation, target signals, movement/body-position events, and projectile threat handling through local runtime helpers;
- cover guards event dispatch, incoming-fire reactions, cover scans, cover processing, squad cover propagation, and delayed debug cleanup;
- health guards treatment continuation callbacks, post-sleep treatment item use, injured-ally signals, and treatment-stack timers;
- conversations re-check participant continuation and context validity before delayed speaker/listener side effects;
- action runtime and module facades snapshot mutable ongoing-action scans where qdel or cancellation can mutate the live list.

## Recent Behavior Surfaces

Recent Human AI work in this branch touches these regression-sensitive areas:

- fire-line safety and friendly-fire blocking;
- lost-target memory and `investigate_lost_target`;
- target API split between targeting and perception;
- projectile threat event payloads for combat, cover, targeting, and faction responses;
- cover/fire interaction, cover search forwarding, and iterative cover scan traversal;
- adjacent point-blank diagonal aiming helpers in weapon API;
- lifecycle and delayed-action guards around invalid or suspended brains;
- inventory, combat, cover, health, conversation, and action-runtime continuation guards.

When changing any of these surfaces, collect read-only evidence first and run at least `.\tools\build\build.bat dm` after implementation changes.

## Working Rules For Future Changes

- Prefer `rg` and targeted reads for discovery.
- Treat current dirty Human AI files as user/current-task work unless proven otherwise.
- Keep new business logic in `modular/**` by default, but do not silently pretend the existing Human AI core has already moved there.
- If a future plan requires rewrite, remove, replace, or migration, update `.AI_AGENT` task-state first and include an old-path audit.
- Do not commit `.AI_AGENT/PLAN.md`, `TODO.md`, `DECISIONS.md`, or `EVIDENCE.md`.
- For docs-only updates, `git diff --check` is sufficient verification. For product-code changes, run `.\tools\build\build.bat dm`.
