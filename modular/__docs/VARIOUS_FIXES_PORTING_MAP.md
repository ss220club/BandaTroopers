# halo_followup_apr2026: карта портов и split между main wave и PR94 update

Назначение документа:
- зафиксировать source-of-truth и commit anchors для текущей HALO follow-up волны;
- не смешать new main HALO wave с update существующего `ss220club/BandaTroopers#94`;
- дать короткую карту для повторной пересборки веток без blind cherry-pick смешанных upstream PR.

## База пересборки

- source-of-truth upstream repo: `https://github.com/cmss13-devs/cmss13-pve-halo`
- latest verification fetch: `cm-pve-halo/master` at `2ec6b82a5b` on 2026-04-27; requested PR heads below were rechecked against their live heads, then the current upstream master audit added PR `#113/#118/#129/#132/#138/#142/#144`.
- merged BT baseline перед этой волной: `ss220club/BandaTroopers#93`
- base main-wave ветки: `ss220club/master` на `66bf244f0ecf925736d9081053d35abb59fb6c6e`
- original source upstream head для этой волны: `cm-pve-halo/master` на `33a011138b2529982de18896616a7cfa9d38f376`
- current full-master source-of-truth: `cm-pve-halo/master` на `2ec6b82a5bbcb7bc386d14a60c890b408bb0bead`
- base ветки обновления `PR #94`: `origin/halo_jackal_spartan_wave_apr2026` на `d7a830c7dfdde8a8f849792ce01a7205a976cb4e`
- принцип пересборки:
  - сохранять authored non-merge commits или их semantic equivalent;
  - не переносить merge commits как source-of-truth;
  - mixed PR разбивать вручную по смыслу и по модульным границам BT.

## Что входит в main-wave ветку

1. [`cmss13-pve-halo#46`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/46)
   - брать только residual scope после `15f2cc13bc`
   - tracked head for final verification: `8c4697c6f0` (previous anchor `5d6398ae32`; fresh Mackay lighting tail ported)
   - Mackay/ONI Digsite shuttle IDs are covered in current BT glue: `code/__DEFINES/bandamarines/halo_map_support.dm`; map item contracts are covered via JSON `map_item_type` resolution and direct fallback creation
2. [`cmss13-pve-halo#126`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/126)
   - брать delta после `1bac3e1d51`
   - текущий tracked head: `94cce6a541`
   - targeted follow-up: `r_wall/bunker/hull` is anchored in shared `code/game/turfs/walls/r_wall.dm` as minimal `SS220 EDIT` compatibility glue; New Irvine `irvine_grass` auto-turf definitions stay in `modular/halo/code/mixed/turfs/halo_new_irvine_auto_turfs.dm`; New Irvine forest flora definitions stay in `modular/halo/code/mixed/structures/halo_new_irvine_flora.dm`; missing New Irvine DMI assets are imported from `94cce6a541`
3. [`cmss13-pve-halo#134`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/134)
   - `ONI Shield Base`
4. [`cmss13-pve-halo#135`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/135)
   - `Valorous Chant`
5. [`cmss13-pve-halo#136`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/136)
   - `686 Regretful Flame`
6. [`cmss13-pve-halo#139`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/139)
   - landmine wave поверх уже существующего BT landmine framework
7. [`cmss13-pve-halo#140`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/140)
   - weapon sprite/state wave
8. [`cmss13-pve-halo#141`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/141)
   - shrapnel/projectile follow-up
9. [`cmss13-pve-halo#143`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/143)
   - BR55 recoil follow-up
10. [`cmss13-pve-halo#145`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/145)
   - `Bumblebee` escape pod; tracked head `6d1c763440d1`
11. [`cmss13-pve-halo#146`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/146)
   - UNSC helmet motion sensor HUD; tracked head `7a0bd462fe86`
12. [`cmss13-pve-halo#137`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/137)
   - audit-only modularization source; current reviewed head: `b8067cc367`
13. [`cmss13-pve-halo#113`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/113)
   - removes prime rolling; applied through modular HALO job overrides, no base job file edit
14. [`cmss13-pve-halo#118`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/118)
   - flavor fixes; ported as modular HALO flavor overrides instead of importing upstream `modular_pve_halo/**`
15. [`cmss13-pve-halo#129`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/129)
   - Covenant HAI/faction split and stealth armor; ported only missing semantic contracts into `modular/halo/**`
16. [`cmss13-pve-halo#132`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/132)
   - Covenant AI rate-of-fire limits; AI hook equivalent is modular, remaining ammo speed tail is ported
17. [`cmss13-pve-halo#138`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/138)
   - Covenant gear update; DMI assets, storage, gear, loadouts and SpecOps/Honor Guard contracts are ported modular-first
18. [`cmss13-pve-halo#142`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/142)
   - Pelican roof fix; audited covered by current `maps/shuttles/dropship_pelican.dmm`
19. [`cmss13-pve-halo#144`](https://github.com/cmss13-devs/cmss13-pve-halo/pull/144)
   - CODEOWNERS/changelog only; no runtime port needed because BT already carries the PhantornRU section
20. supporting BT packaging
   - `HALO_PORT_STATE.md`
   - `HALO_PORT_BACKLOG.md`
   - `CODEOWNERS`
   - filled changelog snippet for the new PR

## Что входит в update ветки PR94

Ветка `halo_jackal_spartan_wave_apr2026` после refresh от `upstream/master` содержит Kig-Yar/Unggoy хвост из `PR #97`, исходный Spartan base из `#100` и branch-local gameplay completion по preset/HumanAI/squad coverage:

1. semantic equivalent `21fe2b79f4` `Update standard.dm`
   - переносится в текущие `ruuhtian` armor contracts
2. semantic equivalent `4424f96051` `gawfwsdfsad`
   - shield typepath/item state/onmob icons + preset wiring
3. semantic equivalent `4996ca9d10` `Delete standard.dm`
   - stale upstream `standard.dm` layout is intentionally absent in BT; scope remains in modular Ruuhtian files
4. semantic equivalent `437039a158` `gaaa`
   - Ruuhtian emote/species access and shield block values; emote access was already covered, shield values are ported in modular shield type
5. semantic equivalent `f9c7909f44` `mega pr stuff`
   - modular Ruuhtian loadout variants, AI preset registry, job defines, and minimal Human AI creator glue
   - Unggoy harness accessory slots, heavy blast armor, deterministic weapon preset variants, and Human AI machinegunner exposure
6. semantic equivalent `7e34c9db50` `Update colonialmarines.dme`
   - переносится только если реально нужен текущему BT include graph; иначе фиксируется как audited no-op
4. filled changelog snippet для обновления `PR #94`

## Ручные split-решения

### 1. `PR #46` после `15f2cc1`

Почему не cherry-pick:
- ветка содержит большой mixed tail, который уже пересекается с ранее влитым BT HALO scope;
- blind import почти гарантирует дублирование map/support/runtime diffs.

Что сохраняем:
- только missing map/pelican/LZ/armory/support изменения, которых нет в текущем BT `master`.

### 2. `PR #97` свежий tail

Почему не переносится file-to-file:
- upstream свежие изменения приходят в `code/modules/clothing/suits/marine_armor/covenant/standard.dm`;
- в BT этот scope уже разложен по `modular/halo/**`, включая `ruuhtian.dm`, `unggoy.dm` и modular shield/loadout wiring.

Что сохраняем:
- armor stat/default fixes;
- Kig-Yar shield runtime/preset wiring;
- modular Ruuhtian weapon variants and Human AI preset exposure from `f9c7909f44`;
- modular Unggoy harness slots, heavy armor value, weapon preset variants and Human AI preset exposure from `f9c7909f44`;
- include-coverage только там, где current BT graph действительно этого требует.
- follow-up preset coverage cleanup for Ruuhtian/Kig-Yar belongs to the dedicated PR94 update branch; the main wave keeps Sangheili/Unggoy and human-faction preset coverage only.
- UNSC/ODST leader equipped presets and UNSC Frigate Squad Leader job lockers intentionally use M392 DMRs; non-leader rifleman/medic/RTO/pilot weapons stay unchanged.

### 3. `PR #137`

Статус:
- audit-only source.
- current reviewed head: `b8067cc367`
- sunglasses and UNSC grenade runtime additions are already covered in current BT modular HALO files.
- fresh delta from previous anchor is legacy-layout `colonialmarines.dme` include ordering only; current BT `modular/halo/_halo.dme` does not require a runtime/code port.

Что считаем no-op:
- любую чистую modularization, уже перекрытую текущим `modular/halo/**`.

Что переносим:
- только missing runtime objects/type contracts, если они реально отсутствуют в BT tree.

## Основные hotspots этой волны

Если ветки придется пересобрать заново, сначала проверять:

1. `modular/halo/code/modules/projectiles/guns/halo/unsc_guns.dm`
2. `modular/halo/code/game/objects/items/weapons/halo_shields.dm`
3. `modular/halo/code/modules/gear_presets/Halo/ruuhtian.dm`
4. `modular/halo/code/modules/gear_presets/Halo/unggoy.dm`
5. `modular/halo/code/modules/clothing/suits/marine_armor/covenant/unggoy.dm`
6. `code/game/objects/items/explosives/mine.dm`
7. `code/datums/ammo/shrapnel.dm`
8. `code/modules/projectiles/projectile.dm`
9. `code/modules/mob/living/carbon/human/ai/defense_creator.dm`
10. `maps/map_files/halo_new_irvine_covenant/halo_new_irvine_covenant.dmm`
11. `maps/map_files/{oni_shield_base,valorous_chant,686_regretful_flame}/`
12. `maps/map_files/unsc_dark_was_the_night/unsc_dark_was_the_night.dmm`
13. `maps/shuttles/bumblebee_west.dmm`
14. `modular/halo/code/modules/shuttle/halo/bumblebee.dm`
15. `code/_onclick/hud/human.dm`
16. `modular/halo/code/mixed/components/halo_motion_sensor.dm`
17. `modular/halo/code/mixed/clothing/unsc_helmets.dm`
18. `modular/halo/code/modules/clothing/covenant_gear_master_sync.dm`
19. `modular/halo/code/modules/gear_presets/Halo/covenant_master_sync.dm`
20. `modular/halo/code/mixed/flavor/halo_master_flavor.dm`
21. `modular/halo/code/mixed/jobs/halo_master_job_overrides.dm`

Причина:
- именно здесь пересекаются modular/upstream split, shared runtime glue, map compile risks и fresh HALO asset contracts.

## Практический итог split

Main PR:
- ветка: `halo_sync_followup_apr2026`
- scope:
  - main HALO follow-up wave
  - карты `#126/#134/#135/#136`
  - mines/shrapnel/weapons `#139/#140/#141/#143`
  - Bumblebee escape pod `#145`
  - UNSC helmet motion sensor HUD `#146`
  - Covenant current-master sync `#129/#132/#138`
  - HALO preset coverage cleanup for Covenant Sangheili/Unggoy, UNSC/ODST, ONI, Police and Insurrectionist HumanAI/squad exposure
  - full-master flavor/job audit `#113/#118`
  - audited no-op `#142/#144`
  - audit `#137`
  - docs/changelog/CODEOWNERS

PR94 update:
- ветка: `halo_jackal_spartan_wave_apr2026`
- scope:
  - обновление от вмерженного `upstream/master` на `5d2ad73b68` после BT `#96`
  - сохранение Kig-Yar/Unggoy tail из `#97` и ранее заведенного Spartan base из `#100`
  - branch-local gameplay completion для Kig-Yar, Sangheili, Unggoy и Spartan preset/HumanAI/squad coverage по modular rules SS220
