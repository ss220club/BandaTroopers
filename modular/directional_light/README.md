# Directional lighting

The experimental edge-anchored renderer was parked outside this build in `C:/BandaTroopers_RenderLab` on 2026-10-28. Its source, test code and integration snapshot are preserved there; it is not included or spawnable in a newly compiled build. Ordinary directional lamps continue using `flashlight_60` and the existing native shadow pipeline.

## Correctness pass (2026-10-29)

`accounting.dm` owns turf visibility: independent static state, area base lighting and a set of actual positive hybrid contributors. Native `luminosity` is a boolean output, not a counter. `hybrid_lights_affecting` remains a LOS-limited dependency set, not proof that a directional beam illuminates a cell. Geometry rebuilds retain unchanged contributions and prune only lost cells; rotation, intensity changes, destruction, area changes and turf replacement reconcile the same ledger.

`occlusion.dm` distinguishes solid cells from opaque `ON_BORDER` edges and feeds both into the old shadow compositor. A visible border triggers bounded local geometry collection (normally at most 441 turfs at radius 10), because native `dview` may hide solid walls behind the opaque border cell. These extra geometry subscriptions live in `directional_shadow_watchers`, never in gameplay illumination lists. Scenes without visible borders retain native LOS candidates. There is no global scene cache or per-frame scan. Opacity changes, moving/rotating blockers and turf replacement invalidate the relevant masks, including solid/border changes that retain the same directional opacity bits. Gameplay visibility remains conservatively constrained by native `dview`; this pass does not replace BYOND sight or claim to remove all tile-edge artifacts.

New directional masks start hidden. After final range and aim are assigned, initial shadows are calculated synchronously if lighting is initialized; only a completed calculation publishes the mask. This preserves short muzzle flashes without displaying an initially unshadowed cone. During initialization the native queue completes publication. Later obstacle changes still use the existing queue and its cadence, so zero-latency door updates are not promised.

Both `set_light(0)` and `set_light_on(FALSE)` release the emitter. Gun flashlight mode is assigned before its immediate on/off signal. Cursor direction/cache includes scope-camera offsets; view changes and Vulture/spotter camera changes notify the existing event queue. Armor/floor/HUD aiming rules are unchanged.

Source and diff review only: no compilation, test execution or server restart in this pass. Two existing test expectations were adjusted to boolean visibility and synchronous initial publication, but were not run. Movement/glide and the archived renderer are unchanged; smooth movement and performance sharing remain separate future stages.

## Shadow compositing

Shadows remain overlays of the native filtered lighting mask. Beam rotation compensates their local matrices without rebuilding geometry. The detached stationary-anchor experiment was removed after client visual regression; logical coordinate tests alone cannot validate filter/render-target compositing.

Immediate movement publication: after lighting initialization, a changed source turf synchronously moves the holder without glide and rebuilds shadows in the same call. Completed work is removed from the existing queue; later obstacle changes can enqueue normally. During initialization the queued path remains intact because its consumer can yield. Mouse rotation does not rebuild shadows. This removes queue-wait lag, but moves shadow cost into movement handling and can do more work than coalescing several steps; client acceptance and profiling remain required.

## Shadow correctness and update costs

Moved directional lights are marked for priority in the existing hybrid queue. Before consumption, moving and ordinary masks are stably interleaved, alternating which class leads each mixed batch. This avoids starving ordinary masks even with a small tick budget. The flag clears on shadow calculation; normal initialized movement is calculated synchronously and removed from the queue, while initialization retains the queued path. Cadence and static lighting stages are unchanged. Priority targets backlog delay, not glide/sampling mismatch; an empty queue may show no improvement. Ordering costs one linear pass over the pending queue.

The native hybrid shadow consumer must iterate while its index is less than the queue length. The former reversed comparison skipped queued masks entirely; restoring this work can increase measured server cost while fixing missing occlusion. Never compare that broken baseline as a performance win.

Aim-only notifications now bypass emitter lifecycle/parameter validation; any coalesced full update takes precedence. Unchanged cursor parameters and repeated outside-map notifications are suppressed. Per-angle sine/cosine are reused; each rotation resolves the origin once and evaluates each candidate factor once. Radius, halo and feathering formulas are unchanged.

The shadow queue regression exercises the actual lighting subsystem, an opaque obstacle's closing/opening, cache equivalence and mixed event priority. The isolated benchmark writes `data/directional_light_benchmark.json` during unit tests only; it reports bounded batch timings for 1/10/30 sources, not production CPU savings. Run all directional tests with a temporary focus and remove the focus before shipping. Visual client verification remains required.

The 0.1-second subsystem is a deduplicated event queue, not a permanent list of enabled lamps. Each controller returns `PROCESS_KILL` after reading the latest state. Item light setters, movement, equipment changes and carrier facing/login/logout events wake it. Mouse handlers retain only the latest parameters and notify the current mob; multiple events share one pending entry. Parsed angles are cached per client/parameters/view. Mouse rotations below one degree relative to the rendered direction are suppressed; body/floor facing remains exact.

Native movement records the latest source position and publishes movement shadows independently of the aiming queue. Native shadow invalidation and its deduplicated mask queue remain intact for obstacle changes and other updates. Turning only changes the cone transform and luminosity over cached radial candidates. Radius, intensity, feathering and armor body-only aiming are unchanged.

Off-source wake requests reconcile cleanup without scheduling work. Stored sources release their emitter and leave the processing queue; source movement/equipment events restore them. Directly carried stored sources retain carrier lifecycle/movement notifications (needed when a carrier exits a container), but ignore mouse/facing notifications without an emitter. Old carrier/client subscriptions are removed on transfer, off and destruction.

## Verification

Use `tools/build/build.bat dm` and the focused directional unit tests through `dm-test`. `directional_beam_event_queue` checks batches of 1/10/30 lights: 100 wake events per light produce one pending entry; stationary lights have no persistent processing entries. The previous polling implementation performed approximately 10 controller calls per enabled light per second. These are queue-work counts, not a measured whole-server CPU improvement.

Client acceptance: walk/run with handheld, gun and helmet lights; check armor follows facing only; move cursor across walls/HUD/chat; transfer/store/drop lamps; turn an NPC and a floor lamp; open/close doors inside the beam; switch camera and return. Live CPU/frame-time profiling should compare identical scenes and player counts. No automatic production benchmark or server restart is performed.
