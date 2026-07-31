# CURRENT GENERATION PIPELINE -- Building Layout Generator

> **Phase 0 - Discovery and Reverse Engineering**
> Date: 2026-05-29
> Based on: procedural_generation.md - PR #99 analysis

---

## 1. Entrypoints

Main generator: `/datum/world_edit_generator/building_layout`
File: `world_edit_generator_building_layout.dm` (2415 lines)

### Key methods in call order:

| # | Method | Line | Purpose |
|---|-------|------|---------|
| 1 | build_plan(params) | 2012 | Entry point: gets anchor_turf, builds shape, calls build_placement_plan |
| 2 | build_placement_plan(...) | 1986 | Wraps placement_context into shape_contract |
| 3 | build_plan_from_shape_contract(...) | 1897 | Main orchestrator: request, candidate families, best selection |
| 4 | build_building_layout_candidate_state(...) | 1453 | **Central pipeline**: 16 generation stages |
| 5 | emit_building_layout_plan(...) | emitter.dm:440 | Final emitter: state -> plan |
| 6 | apply_plan(user, params, plan) | 2250 | Runtime: ChangeTurf + new obj_path |

### Manager lifecycle:

`/datum/world_edit_manager` (world_edit_manager_core.dm:3) manages:
- current_generator - active generator instance
- placement_anchor_turf - anchor turf
- get_effective_placement_shape() - shape (POINT, RECTANGLE, CIRCLE...)
- get_effective_placement_dir() - direction (NORTH default)
## 2. Pipeline Stages (16 stages) 

---

## 2. Pipeline Stages (16 stages)

All stages called sequentially inside build_building_layout_candidate_state() (line 1453):

STAGE 0: Request and Config
  build_building_request() -> normalize_building_params()
  File: building_layout_request.dm:11
  Output: /datum/world_edit_building_request
  5 independent PRNGs (program, geometry, fixtures, facade, microvariation)

STAGE 1: Footprint Resolution
  resolve_shape_footprint() -> validate_footprint()
  Output: validated footprint, boundary, interior, bounds, footprint_lookup
  BFS flood-fill connectivity check, blocker check

STAGE 2: State Initialization
  build_building_layout_state()
  File: building_layout_geometry.dm:24
  Output: /datum/world_edit_building_layout_state
  Stage seeds, semantic_plan from archetype, mandatory counts

STAGE 3: Door Placement
  build_building_doors(state)
  File: geometry.dm (called at :86)
  Output: door_turfs, door_dirs, front_door_turf
  Front door toward placement_dir, optional back exit

STAGE 4: Room-First Layout (Room Packing)
  build_building_room_first_layout(state)
  File: geometry.dm (called at :97)
  Output: solved_rooms, room_by_turf, corridor_turfs, primary_route_turfs
  Decomposes footprint into rooms BEFORE walls and furniture
  KEY: this IS room-first approach

STAGE 5: Window Placement
  build_building_windows(state)
  File: building_layout_facade.dm:1
  Output: window_turfs
  Weighted random on boundary, excludes doors/corners, respects facade_rules

STAGE 6: Wall and Floor Derivation
  build_building_walls_and_floors(state)
  File: geometry.dm (called at :114)
  Output: wall_lookup, floor_turfs, floor_lookup
  WALLS DERIVED from boundary, FLOORS DERIVED from interior
  This is DERIVED GEOMETRY, not primary

STAGE 7: Anchor Extraction
  extract_building_anchors(state)
  File: building_layout_anchors.dm:1
  Output: anchor_turfs, anchor_lookup
  zone/wall/corner/primary_lane/focus/door_cone/window_band/signature anchors

STAGE 8: Semantic Slot Preflight
  run_building_semantic_slot_preflight(state)
  File: generator line 1467
  Checks anchor capacity vs mandatory requirements

STAGE 9: Infrastructure Placement
  place_building_infrastructure(state)
  File: building_layout_infrastructure.dm
  light, apc, air_alarm, light_switch, fire_alarm on wall_anchors

STAGE 10: Fixture Placement (Major + Secondary + Detail)
  place_building_fixtures(state)
  File: building_layout_fixtures.dm:1
  Phase 1: major clusters (mandatory). Phase 2: secondary. Phase 3: detail
  cluster_spec -> template_chunk -> cells -> placement via semantic anchors

STAGE 11: Facade Rules
  apply_building_facade_rules(state)
  File: facade.dm (called at :1486)
  Privacy rules, service/secure wall restrictions
  File: building_layout_validators.dm:1
  Privacy/window/fixture/empty_space repairs, up to MAX_REPAIR_ATTEMPTS

STAGE 13: Microvariation
  apply_building_microvariation_if_available(state)
  File: emitter.dm:13
  Small details (decals, clutter)

STAGE 14: Macro Overlays
  apply_building_layout_macro_overlays(state)
  File: generator line 1496
  DMM template overlays for special zones

STAGE 15: Style Metrics and Scoring
  calculate_building_style_metrics(state) + score_building_layout_candidate(state)
  File: generator lines 1517, 1690
  category_coverage, repeat_index, connectivity, fixture_density, privacy scores
  40+ hard counters (mandatory_room_missing, double_wall_error...)

STAGE 16: Plan Emission
  emit_building_layout_plan(state, shape_contract, placement_context)
  File: building_layout_emitter.dm:440
  state -> plan placements (wall/floor/door/window/interior)
  validate_building_plan_post_emit() - final cross-check
  200+ metadata fields

---

## 3. Data Ownership and Mutability

### Central State Object

/datum/world_edit_building_layout_state (building_layout_state.dm:1) is the **sole owner** of all data throughout the pipeline. Contains ~185 fields.

### Key Data Structures

| Structure | Type | File | Purpose |
|-----------|------|------|---------|
| footprint | list of /turf | state.dm:8 | All building turfs |
| boundary | list of /turf | state.dm:9 | Outer perimeter |
| interior | list of /turf | state.dm:10 | Inner cells |
| wall_lookup | assoc list | state.dm:14 | O(1) is this a wall? |
| floor_turfs / floor_lookup | list + assoc | state.dm:15-16 | Floor cells |
| door_turfs / door_dirs | list + assoc | state.dm:17-18 | Doors and their directions |
| window_turfs | list | state.dm:19 | Windows |
| object_placements | list of assoc | state.dm:20 | All interior placements |
| fixture_lookup | assoc | state.dm:21 | O(1) cell occupancy check |
| category_counts | assoc | state.dm:23 | Objects per category |
| signature_counts | assoc | state.dm:25 | Objects per signature |
| zone_by_turf / zone_turfs | assoc | state.dm:30-31 | turf -> zone_id mapping |
| anchor_turfs / anchor_lookup | assoc | state.dm:33-34 | Placement anchors by type |
| solved_rooms | list of /datum/world_edit_building_room | state.dm:37 | Solved rooms |
| room_by_turf | assoc | state.dm:38 | Reverse index: turf -> room |
| corridor_turfs / corridor_lookup | list + assoc | state.dm:39-40 | Corridor cells |
| primary_route_turfs | list | state.dm:42 | Main route (reserved) |
| internal_wall_turfs | list | state.dm:45 | Internal walls |
| divider_plans | list of /datum/world_edit_building_divider_plan | state.dm:41 | Divider plans |
| semantic_slot_reservation_by_turf | assoc | state.dm:60 | Cell reservation for requirements |

### Request (Immutable Input)

/datum/world_edit_building_request (building_layout_request.dm:1):
- config - all parameters (archetype_id, faction_preset, half_width, seed...)
- archetype - reference to /datum/world_edit_building_archetype
- 5 independent PRNGs: program_rng, geometry_rng, fixture_rng, facade_rng, microvariation_rng
- **Does not mutate** after creation (only config is extended)

### Plan (Immutable Output)

/datum/world_edit_plan (world_edit_types.dm):
- placements - list of all placements (turf + object)
- affected_turfs - affected turfs
- metadata - 200+ metadata fields

---

## 4. Critical Entities

### Archetype System

/datum/world_edit_building_archetype (building_layout_archetypes.dm):
- Defines the building program (living, medbay, storage, office...)
- Contains zone_specs (functional zones needed)
- Contains cluster_specs (furniture clusters to place)
- Contains object_budgets (category limits)
- Method build_semantic_plan() creates /datum/world_edit_building_semantic_plan

### Zone System

/datum/world_edit_building_zone_spec (archetypes.dm:1):
- id, label, role - identification
- privacy_class - public / semi_private / private / secure
- min_area - minimum area
- required / optional - mandatory flag
- must_touch_route - must touch corridor
- privacy_sensitive - requires protection from door cone
- window_allowed - can have windows
- divider_mode - none / room (needs divider room)
- anchor_tags - tags for anchor extraction

### Room System

/datum/world_edit_building_room (archetypes.dm:100):
- id, zone_id, role - identification
- turfs - list of room turfs
- focus_turf - center point
- area, x1/y1/x2/y2 - bounds
- route_access - has corridor access

### Region System

/datum/world_edit_building_region_spec (archetypes.dm:61):
- Spatial constraints: front_min/max, lateral_min/max
- priority - assignment priority
- /datum/world_edit_building_solved_region (archetypes.dm:83) - solved result

### Cluster / Fixture System

/datum/world_edit_building_cluster_spec (building_layout_fixtures.dm):
- id, slot, category, phase (major/secondary/detail)
- pattern - placement pattern (single, line, cluster...)
- macro_id - reference to template chunk
- signature_id - semantic signature
- required - mandatory flag

### Template Chunk System

/datum/world_edit_building_template_chunk (building_layout_templates.dm):
- DMM-like templates for furniture groups
- Contains cells - list of /datum/world_edit_building_template_cell
- Each cell: slot, obj_path, dir, wall_mounted, anchor_preference

### Footprint Mask System

/datum/world_edit_building_footprint_mask (building_layout_footprints.dm:1):
- Bitmask for non-standard footprints
- add_rect(), sub_rect() - mask construction
- to_turfs(center_turf, placement_dir) - world projection

### PRNG System

/datum/world_edit_building_prng (building_layout_seed.dm):
- Deterministic RNG seeded from seed
- 5 independent instances per request (program, geometry, fixtures, facade, microvariation)
- build_stage_seed(base_seed, stage_name) - hierarchical seeding

---

## 5. Call Graph (Simplified)

```text
build_plan(params)
  └─ build_placement_plan(user, params, placement_context)
       └─ build_plan_from_shape_contract(user, shape_contract, params, placement_context)
            ├─ build_building_request(params, shape_contract, placement_context)
            │    └─ normalize_building_params(params)
            │         ├─ get_building_archetype()
            │         ├─ get_building_faction_catalog()
            │         ├─ merge_building_preset_overrides()
            │         └─ validate_building_preset_capabilities()
            ├─ build_building_context_support_result(shape_id, config, placement_context)
            ├─ [loop: size_candidates x candidate_families]
            │    ├─ build_building_candidate_request(request, family, attempt)
            │    └─ build_building_layout_candidate_state(candidate_request, ...)
            │         ├─ resolve_shape_footprint(shape_contract, config, ...)
            │         │    ├─ build_explicit_shape_footprint()
            │         │    └─ build_point_building_footprint()
            │         ├─ validate_footprint(footprint, config)
            │         ├─ build_building_layout_state(request, ...)
            │         │    ├─ build_building_doors(state)
            │         │    ├─ build_building_room_first_layout(state)
            │         │    ├─ build_building_windows(state)
            │         │    └─ build_building_walls_and_floors(state)
            │         ├─ extract_building_anchors(state)
            │         ├─ run_building_semantic_slot_preflight(state)
            │         ├─ place_building_infrastructure(state)
            │         ├─ place_building_fixtures(state)
            │         │    └─ place_building_cluster_spec(state, cluster_spec, major)
            │         │         └─ [template chunk resolution]
            │         ├─ apply_building_facade_rules(state)
            │         ├─ validate_and_repair_building_layout_state(state)
            │         │    ├─ validate_building_layout_state(state)
            │         │    ├─ repair_building_privacy_conflicts(state)
            │         │    ├─ repair_building_window_conflicts(state)
            │         │    ├─ repair_building_fixture_conflicts(state)
            │         │    ├─ repair_building_missing_major_clusters(state)
            │         │    └─ repair_building_empty_space(state)
            │         ├─ apply_building_microvariation_if_available(state)
            │         ├─ apply_building_layout_macro_overlays(state)
            │         ├─ calculate_building_style_metrics(state)
            │         └─ score_building_layout_candidate(state)
            └─ emit_building_layout_plan(best_state, ...)
                 ├─ [wall/floor/door/window/interior placement emission]
                 └─ validate_building_plan_post_emit(plan, state)
```

---

## 6. Dependency Graph

```text
┌──────────────┐     ┌──────────────────┐     ┌────────────────────┐
│   Manager    │────>│ Generator        │────>│ Request            │
│ (core.dm)    │     │ (building_layout)│     │ (request.dm)       │
└──────────────┘     └──────────────────┘     └────────────────────┘
                            │                          │
                            ▼                          ▼
                     ┌──────────────────┐     ┌────────────────────┐
                     │ Shape Contract   │     │ Archetype Catalog  │
                     │ (placement_      │     │ (archetypes.dm)    │
                     │  shapes.dm)      │     └────────────────────┘
                     └──────────────────┘              │
                            │                          ▼
                            ▼                 ┌────────────────────┐
                     ┌──────────────────┐     │ Semantic Plan      │
                     │ Footprint        │     │ (archetypes.dm)    │
                     │ (footprints.dm)  │     └────────────────────┘
                     └──────────────────┘              │
                            │                          ▼
                            ▼                 ┌────────────────────┐
              ┌──────────────────────┐       │ Zone Specs         │
              │ Layout State         │<──────│ Region Specs       │
              │ (state.dm)           │       │ Cluster Specs      │
              │ ~185 fields          │       │ (archetypes.dm)    │
              └──────────────────────┘       └────────────────────┘
                   │          │
        ┌──────────┘          └──────────┐
        ▼                                ▼
┌───────────────┐                ┌────────────────┐
│ Geometry      │                │ Fixtures       │
│ (geometry.dm) │                │ (fixtures.dm)  │
│ - doors       │                │ - clusters     │
│ - rooms       │                │ - templates    │
│ - walls       │                │ - signatures   │
│ - floors      │                │ - requirements │
│ - corridors   │                └────────────────┘
└───────────────┘                         │
        │                                 ▼
        ▼                        ┌────────────────┐
┌───────────────┐                │ Anchors        │
│ Facade        │                │ (anchors.dm)   │
│ (facade.dm)   │                │ - zone anchors │
│ - windows     │                │ - wall anchors │
│ - rules       │                │ - corner       │
└───────────────┘                │ - door_cone    │
        │                        └────────────────┘
        ▼                                 │
┌───────────────┐                         ▼
│ Validators    │                ┌────────────────┐
│ (validators.  │                │ Infrastructure │
│  dm)          │                │ (infra.dm)     │
│ - validate    │                │ - light, apc   │
│ - repair      │                │ - alarms       │
└───────────────┘                └────────────────┘
        │                                 │
        └────────────┬────────────────────┘
                     ▼
              ┌──────────────┐
              │ Emitter      │
              │ (emitter.dm) │
              │ - plan       │
              │ - post-emit  │
              │   validation │
              └──────────────┘
                     │
                     ▼
              ┌──────────────┐
              │ Apply        │
              │ (generator   │
              │  _building   │
              │  _layout.dm) │
              │ - ChangeTurf │
              │ - new obj    │
              └──────────────┘
```

---

## 7. Problem Zones and Coupling Map

### 7.1. Strengths of Current Architecture

| Aspect | Rating | Comment |
|--------|--------|---------|
| Room-first layout | GOOD | Rooms extracted BEFORE walls - correct approach |
| Derived walls | GOOD | Walls derived from boundary, not generated |
| Stage separation | GOOD | 16 explicit stages with stage_reports |
| Deterministic seeds | GOOD | 5 independent PRNGs with hierarchical seeding |
| Scoring system | GOOD | Multiple candidates, best-by-score selection |
| Validation and repair | GOOD | Multi-level validation with repair attempts |
| Semantic plan | GOOD | Archetype -> zone_specs -> cluster_specs |
| Hard counters | GOOD | 40+ counters for problem detection |
| Post-emit validation | GOOD | Cross-check emitted plan vs planned state |

### 7.2. Problem Zones

| # | Problem | Severity | Files | Description |
|---|---------|----------|-------|-------------|
| 1 | Monolithic state | HIGH | state.dm | 185+ fields in one datum. No layer separation (geometry vs fixture vs validation). Hinders refactoring. |
| 2 | Giant generator file | HIGH | world_edit_generator_building_layout.dm | 2415 lines. Mixed: UI, validation, footprint, candidate selection, scoring, preview, apply. |
| 3 | Implicit inter-stage dependencies | MEDIUM | geometry.dm:97 | build_building_room_first_layout depends on build_building_doors (needs front_door_turf), not expressed in types. |
| 4 | Config mutability | MEDIUM | request.dm | request.config mutates throughout pipeline (fields like footprint_source, size_degrade_level added). |
| 5 | No formal stage contract | MEDIUM | All files | Stages lack explicit interface (input type -> output type). Everything via state mutation. |
| 6 | Fixture placement depends on anchor extraction | MEDIUM | fixtures.dm -> anchors.dm | If anchors not extracted or stale, fixture placement silently fails. |
| 7 | Limited footprint mask system | LOW | footprints.dm | Only rectangular masks. No BSP, no voronoi, no grammar-based shapes. |
| 8 | No graph-based room connectivity | MEDIUM | geometry.dm | Rooms connected via corridor, but no explicit room graph (nodes + edges). room_graph_hash is a hash, not a data structure. |
| 9 | No semantic room types at generation level | LOW | archetypes.dm | Zone specs have role, but no full room archetype system (storage, bedroom, armory...). Done via cluster_specs. |
| 10 | Static template chunks | LOW | templates.dm | Templates loaded from DMM-like files, no procedural furniture group generation. |

### 7.3. Coupling Map

**Strong coupling (requires refactoring):**

- state.dm <-> geometry.dm (room packing <-> wall derivation)
- state.dm <-> fixtures.dm (fixture placement <-> anchor extraction)
- state.dm <-> validators.dm (validation <-> repair <-> anchors)
- generator.dm -> state.dm (candidate orchestration)

**Medium coupling (tolerable):**

- archetypes.dm -> fixtures.dm (cluster_specs -> placement)
- anchors.dm -> fixtures.dm (anchors -> template positioning)
- facade.dm -> validators.dm (window rules -> repair)
- emitter.dm -> state.dm (state -> plan conversion)

**Weak coupling (good):**

- request.dm (isolated)
- footprints.dm (isolated mask operations)
- seed.dm (isolated PRNG)
- templates.dm (isolated chunk loading)
- infrastructure.dm (isolated placement)

### 7.4. Legacy Assessment

**Systems that can be reused in new pipeline:**

| System | Reusability | Reason |
|--------|-------------|--------|
| Archetype / Zone / Cluster specs | HIGH | Data-driven, well-structured, semantic-ready |
| PRNG system | HIGH | Deterministic, hierarchical, isolated |
| Anchor extraction | HIGH | Generic spatial analysis, reusable for any layout |
| Scoring system | HIGH | Multi-metric, extensible, already has hard counters |
| Validation and repair | HIGH | Multi-pass, already handles many edge cases |
| Template chunks | MEDIUM | DMM-based, but could be extended for procedural groups |
| Footprint mask | MEDIUM | Basic but functional, needs BSP/voronoi extension |
| Facade rules | MEDIUM | Privacy/window logic is sound, needs generalization |
| Emitter (state->plan) | MEDIUM | Works but tightly coupled to current state shape |

**Systems that need full rewrite:**

| System | Reason |
|--------|--------|
| Room packing (room_first_layout) | Currently footprint-decomposition based. Needs true graph-driven room placement with BSP/voronoi. |
| Corridor planning | Currently derived from room packing. Needs explicit corridor graph with width constraints. |
| Wall derivation | Works but tied to current boundary concept. Needs generalization for non-rectangular shapes. |
| Fixture placement | Currently anchor-scatter. Needs anchor-based prefab composition with furniture groups. |
| Monolithic state | Needs decomposition into layered state objects (GeometryState, FixtureState, ValidationState). |
| Giant generator file | Needs split into separate stage files with explicit contracts. |

---

## 8. Summary for Phase 1

### What already exists and works well:
- Room-first approach (rooms before walls)
- Derived walls (walls from boundary, not generated)
- 16-stage pipeline with stage_reports
- Deterministic multi-seed PRNG
- Multi-candidate scoring and selection
- Semantic plan (archetype -> zones -> clusters)
- Anchor-based fixture positioning
- Multi-pass validation with repair
- Post-emit cross-validation
- 40+ hard counters for quality metrics

### What is missing for room/graph-driven architecture:
- Explicit room graph data structure (nodes + edges)
- BSP / Voronoi / grammar-based spatial partitioning
- Graph-driven room placement (not footprint decomposition)
- Explicit corridor graph with width constraints
- Room archetype system (semantic room types)
- Furniture group prefabs (not single-object scatter)
- Layered state (GeometryState, FixtureState, ValidationState)
- Formal stage contracts (input type -> output type)
- Non-rectangular footprint generation (BSP masks)

### Recommended Phase 1 approach:
1. Keep: archetype system, PRNG, anchors, scoring, validation, emitter
2. Refactor: split monolithic state into layers
3. Rewrite: room packing -> graph-driven BSP placement
4. Add: explicit room graph, corridor graph, stage contracts
5. Extend: footprint masks with BSP/voronoi support
