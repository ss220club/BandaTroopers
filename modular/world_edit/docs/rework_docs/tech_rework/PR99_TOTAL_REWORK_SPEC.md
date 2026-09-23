# PR #99: обязательная полная переработка World Edit DMM Blueprints и генератора построек

**Репозиторий:** `ss220club/BandaTroopers`  
**Pull request:** `#99 — World Edit DMM blueprints and building layout`  
**Аудируемый head:** `050a5790352b0b54f78585e0a54fce4dfacf7ebe`  
**Дата аудита:** 18 июня 2026 года  
**Статус документа:** decision-complete specification для Codex

---

## 0. Итоговое решение

PR #99 в текущем виде **не должен доводиться серией локальных исправлений поверх существующей реализации**. Требуется перестроить ветку в пределах того же PR: удалить экспериментальные и сгенерированные материалы, вернуть глобальный runtime в исходное состояние, заменить фактически монолитный генератор единым проверяемым solver pipeline, сделать применение транзакционным и превратить Workbench из визуализатора в настоящий acceptance-gate.

Требования к процессу:

1. Пользователь не участвует в промежуточном тестировании.
2. Все проверки до финального UAT выполняют Codex и его субагенты.
3. Никакая стадия не считается завершённой по скриншоту или факту компиляции.
4. Для каждой поддерживаемой комбинации должны автоматически проходить preflight, generation, validation, apply, post-apply validation и undo restoration.
5. «Успех с предупреждениями» при частично построенном здании запрещён.
6. Неподдерживаемая возможность не показывается как поддерживаемая.
7. Неизвестные или незакрытые дефекты не переносятся в merge-ready PR как «known issue».

### Что должно остаться результатом PR

PR должен дать три изолированных продукта:

- надёжную DMM-библиотеку blueprint-файлов с сохранением метаданных и транзакционными операциями;
- детерминированный генератор построек на основе графа помещений и ограниченного поиска, а не шума;
- одноразовый headless acceptance runner, который возвращает ненулевой код при любом нарушении контракта.

---

## 1. Почему текущую ветку надо перестроить

На аудируемом head PR содержит 286 изменённых файлов, 47 коммитов, около 49,6 тыс. добавлений и 4,1 тыс. удалений. В одной ветке смешаны:

- миграция JSON blueprint-файлов в DMM;
- parser/serializer и файловые операции библиотеки;
- новый building generator;
- большой набор программ помещений и faction presets;
- DMM template chunks;
- Workbench runtime в DM;
- отдельная карта canvas;
- Python/BAT automation;
- TGUI;
- unit tests;
- локальные отчёты, PNG, semantic JSON и debug-скрипты;
- внутренние исследовательские документы и task-state мусор.

Это создаёт четыре системных проблемы:

1. Невозможно доказать, какая часть реализации является source of truth.
2. Unit, quality batch и Workbench используют разные определения успеха.
3. Review не отделяет продуктовый код от локального экспериментального состояния.
4. Исправление отдельного симптома оставляет противоречащие пути выполнения.

Поэтому базовая стратегия — **controlled branch reconstruction**: сохранить только проверенные контракты, а не текущую организацию кода.

---

## 2. Обязательная очистка ветки до функциональной переработки

### 2.1 Полностью вернуть upstream-файл

Вернуть к базе PR:

- `code/game/world.dm`

Причина: Workbench не должен изменять глобальную загрузку мира, `sleep_offline` и production startup. Сейчас включение определяется наличием tracked-файла `tools/world_edit_visual/enabled.txt`, а запуск дублируется через `code/game/world.dm` и `modular/world_edit/_world_edit.dm`.

После переработки в `code/**` не должно остаться Workbench-логики. Если понадобится точка запуска, она должна жить в модульном test/dev entrypoint и быть активна только через явный параметр запуска либо compile define.

### 2.2 Удалить из PR как мусор или локальное состояние

Удалить:

- `plan`;
- `modular/world_edit/docs/rework_docs/_write.ps1`;
- `modular/world_edit/code/generators/building_layout/pipeline/fix_stages.py`;
- `tools/world_edit_visual/enabled.txt`;
- всё содержимое `tools/world_edit_visual/out/**`;
- `tools/world_edit_visual/cases/user_test.json`;
- `tools/world_edit_visual/menu_test.bat`, если он не превращён в автоматический тест с assertions;
- локальные одноразовые диагностические скрипты:
  - `tools/world_edit_visual/scripts/_collect_metrics.py`;
  - `tools/world_edit_visual/scripts/_deep_errors.py`;
  - `tools/world_edit_visual/scripts/analyze_all.py`;
  - `tools/world_edit_visual/scripts/deep_analyze.py`.

Функции, которые действительно нужны из этих скриптов, должны быть объединены в один поддерживаемый `validate_reports.py` с unit tests и ненулевым exit code при ошибке.

### 2.3 Убрать внутренние task/research документы из продуктового диффа

Не должны входить в merge-ready diff:

- изменение `modular/__agents/.AI_AGENT/CONFIRMED_UNRESOLVED_ERRORS.md`;
- `modular/world_edit/docs/deepsearch/Sub Agent Inspection Report.md`;
- дублирующие документы, описывающие разные версии pipeline;
- внутренние заметки о процессе агента.

Консолидировать документацию в два канонических документа:

- `modular/world_edit/docs/building_layout_architecture.md`;
- `modular/world_edit/docs/building_layout_acceptance.md`.

Изменение behavior должно описываться в документации продукта, а незакрытый дефект должен блокировать merge, а не закрепляться как допустимое состояние.

### 2.4 Удалить tracked runtime artifacts

Следующие файлы всегда остаются локальными/CI artifacts и никогда не коммитятся:

- `tools/world_edit_visual/inbox/**`;
- `tools/world_edit_visual/out/**`;
- `tools/world_edit_visual/enabled.txt`;
- `tools/world_edit_visual/index.md`;
- `tools/world_edit_visual/workflow.log`;
- `tools/world_edit_visual/runtime.log`;
- `.cache/**`;
- generated cases.

После очистки выполнить:

```bash
git ls-files tools/world_edit_visual/out tools/world_edit_visual/enabled.txt tools/world_edit_visual/inbox
```

Команда должна вернуть пустой результат.

---

## 3. Реестр блокирующих дефектов и обязательных исправлений

Ниже каждый пункт является merge blocker. «Обойти», «задокументировать» или понизить severity нельзя.

## PR99-B01. Ложная staged-архитектура

### Текущее состояние

Файлы `stage_layout_graph.dm`, `stage_spatial_partition.dm` и `stage_room_shapes.dm` выглядят как современный pipeline, но основной request принудительно получает `room_first_layout = TRUE`. При этом перечисленные стадии сразу завершаются и не выполняют заявленную работу. Реальная геометрия остаётся в большом imperative solver внутри `building_layout_geometry.dm`.

В `stage_layout_graph.dm` непосредственно оставлен TODO на настоящую генерацию layout graph.

### Риск

- код и документация создают ложную картину архитектуры;
- новые изменения могут добавляться в неисполняемые стадии;
- невозможно изолированно тестировать topology, partition и routing;
- поддерживаются два несовместимых mental model.

### Обязательное изменение

Удалить флаг `room_first_layout` и все bypass-ветки. Выбрать один путь:

1. topology graph;
2. spatial partition;
3. route/opening solver;
4. shell derivation;
5. furnishing;
6. validation;
7. plan emission.

Старый monolithic method не должен оставаться fallback-путём. Допустима временная локальная ветка миграции, но в итоговом PR должен существовать только один production path.

### Acceptance

- поиск `rg -n "room_first_layout|legacy" modular/world_edit/code/generators/building_layout` не находит переключателя между старым и новым solver;
- каждый production stage имеет собственный unit test;
- ни одна стадия не возвращает успех без сформированного typed output.

---

## PR99-B02. Несогласованный список поддерживаемых shape

### Текущее состояние

`get_supported_placement_shapes()` рекламирует point, line, rectangle, filled rectangle, circle, ring, ellipse, diamond, triangle, sector, polygon, polyline, custom mask, brush path и scatter cluster.

Support-check при этом допускает другой список, а line/polyline/brush/scatter попадают в ранний `unknown` return до ветки `not implemented`. Workbench-кейс line ожидает третий reason code. Ожидание не проверяется.

### Риск

- UI показывает функции, которые runtime отвергает;
- shape lock reason нестабилен;
- preview и apply могут принимать разные решения;
- тест создаёт видимость покрытия без assertions.

### Обязательное изменение

Для merge PR поддерживать только:

- `point` — generator-owned footprint;
- `rectangle` — явный прямоугольный footprint, нормализованный в заполненную маску;
- `filled_rectangle` — тот же геометрический контракт без неоднозначности.

Все остальные shape исключить из `get_supported_placement_shapes()` и UI. Для них возвращать единый код:

```text
shape.unsupported_for_building_layout
```

Расширение polygon/custom mask выполняется отдельной задачей после merge, только вместе с отдельной acceptance matrix.

### Acceptance

- server catalog, TGUI options, support report и tests получают список из одного источника;
- для каждого advertised shape существует позитивный preview/apply/undo test;
- для каждого неadvertised shape существует один parameterized negative test с одинаковым reason code.

---

## PR99-B03. Preflight не доказывает возможность генерации

### Текущее состояние

Support estimator суммирует `min_area` обязательных зон и сравнивает его с приблизительным usable area. Он не учитывает:

- стены;
- коридоры;
- вход;
- обязательные adjacency;
- door clearance;
- fixture footprint;
- wall-mounted infrastructure;
- aspect ratio помещений;
- facade requirements.

Из-за этого support-check проходит, а preview позже падает на connectivity/adjacency.

### Обязательное изменение

Preflight и generator должны использовать один объект `building_feasibility_model`.

Нижняя граница площади должна включать:

```text
mandatory_room_area
+ minimum_circulation_area
+ internal_wall_budget
+ entry_clearance
+ mandatory_fixture_clearance
+ program-specific reserve
```

Но одной площади недостаточно. Preflight обязан выполнить ограниченный dry solve topology/partition без furnishing. Результат:

- `SUPPORTED` — есть хотя бы один topology+partition candidate;
- `UNSUPPORTED` — footprint физически не реализует программу;
- `INVALID` — запрос или preset некорректен.

Preview не имеет права падать по причине, которую мог определить preflight.

### Acceptance

- support parity test вызывает preflight и generation на одной матрице;
- `SUPPORTED` всегда приводит к валидному plan;
- `UNSUPPORTED` никогда не меняет canvas;
- E-WEV-001 и E-WEV-002 превращены в regression tests и проходят.

---

## PR99-B04. Скрытый program shedding и «micro» деградация

### Текущее состояние

Если площадь меньше target, generator молча выбирает `compact` или `micro` и может отбрасывать часть программы. Названия тестов и фактические ожидания не совпадают: кейсы, называемые locked, ожидают успешный degraded layout.

### Риск

Пользователь просит жилое помещение, а получает функционально неполную структуру без явного выбора другой программы.

### Обязательное изменение

Удалить автоматический `program_shedding`.

Ввести явные size profiles:

- `compact` — все mandatory rooms, optional rooms выключены;
- `standard` — mandatory rooms и weighted optional rooms;
- `spacious` — полный набор программы.

Если footprint не помещает `compact`, запрос получает `program.insufficient_footprint`.

«Micro» допускается только как отдельный program ID с собственным графом и acceptance, например `living_micro`; он не является скрытой деградацией `living`.

### Acceptance

- один program ID всегда имеет один обязательный topology contract;
- в metadata нет `program_shedding`;
- отсутствуют silently dropped mandatory zones;
- UI явно показывает выбранный profile.

---

## PR99-B05. Candidate search выбирает первый валидный результат

### Текущее состояние

Loop прекращается после первого валидного candidate, хотя metadata и документация говорят о scoring и выборе лучшего результата. Point mode фактически перебирает только `RECT`.

### Обязательное изменение

Использовать bounded deterministic candidate search:

- не менее 8 и не более 16 candidates для point mode;
- все candidate families из фактически поддерживаемого списка программы;
- все валидные candidates проходят один validator;
- scoring применяется ко всем валидным candidates;
- выбирается максимальный score;
- tie-breaker — стабильный hash, зависящий от seed и candidate ID.

Point mode должен поддерживать реализованные family builders:

- `RECT`;
- `L`;
- `T`;
- `U`.

Если отдельная программа не поддерживает family, она не объявляет её в catalog. Нельзя объявлять family и затем всегда использовать RECT.

### Acceptance

- unit test создаёт два валидных candidates и проверяет выбор более высокого score независимо от порядка;
- same request + same seed даёт одинаковый layout hash;
- среди 20 seeds для каждой программы достигается установленная diversity threshold.

---

## PR99-B06. Silent fallback меняет семантику запроса

### Текущее состояние

При ошибке explicit shape generator может переключиться на point/rectangle fallback.

### Обязательное изменение

Удалить все silent geometry fallbacks. Возможны только:

- валидный plan для исходного request;
- structured failure с code, stage и diagnostics.

Fallback разрешён исключительно как явно выбранная пользователем policy, которой в данном PR быть не должно.

### Acceptance

- `unsupported_shape_silent_fallback_count` и аналогичные counters удалены;
- ни один test не принимает изменённый shape как успех.

---

## PR99-B07. Apply допускает частичное здание

### Текущее состояние

Текущий `apply_plan()` сначала изменяет turfs, затем создаёт objects. Ошибки увеличивают `skipped_runtime`, но если создан хотя бы один turf или object, результат становится `success = TRUE` с сообщением «applied with warnings».

### Риск

В мире остаётся полуготовая постройка: без дверей, объектов, части стен или floor tiles. Undo может быть неполным, а Workbench считает операцию успешной.

### Обязательное изменение

Ввести `/datum/world_edit_apply_transaction` с четырьмя фазами:

1. **Resolve:** разрешить все target turfs, paths, dirs и placement dependencies.
2. **Conflict check:** проверить blockers и неизменность мира после preview.
3. **Commit:** применить все placements, записывая rollback snapshot.
4. **Post-apply validate:** проверить реальный мир. При любой ошибке немедленно rollback.

Правила:

- `success = TRUE` только при `skipped = 0`;
- любой invalid path, blocker, ChangeTurf failure или object creation failure отменяет всю операцию;
- rollback является частью той же функции, а не ручным действием администратора;
- changeset публикуется в history только после успешной транзакции.

### Acceptance

- fault-injection test ломает N-й turf и N-й object placement;
- после каждого injected failure карта полностью равна baseline;
- history не получает failed transaction;
- success result всегда содержит zero skips.

---

## PR99-B08. Небезопасные defaults

### Текущее состояние

По умолчанию `respect_blockers = FALSE`, `replace_blocked_turfs = TRUE`.

### Обязательное изменение

Defaults:

```text
respect_blockers = TRUE
replace_blocked_turfs = FALSE
```

Destructive overwrite включается только отдельным UI-toggle. Если plan заменит хотя бы один blocked turf/object, apply требует явного подтверждения по точному preview revision.

### Acceptance

- default request никогда не удаляет/заменяет blocker;
- stale confirmation недействительна после изменения params или мира;
- UI показывает точное количество замен до подтверждения.

---

## PR99-B09. Preview не фиксирует world revision

### Текущее состояние

Request key учитывает params и anchor, но не состояние target area. Между preview и apply карта может измениться.

### Обязательное изменение

Plan сохраняет `target_state_hash`, построенный из:

- turf type и baseturfs каждого target tile;
- blocker refs/types;
- relevant dense objects;
- z/coordinate ordering.

Apply повторно вычисляет hash. Несовпадение возвращает `apply.world_changed_since_preview` без изменений.

### Acceptance

- test изменяет один target turf после preview;
- apply блокируется;
- повторный preview создаёт новый revision и затем успешно применяется.

---

## PR99-B10. Workbench выдаёт ложный supported

### Текущее состояние

Committed report `building_living_point_colony` имеет:

- `status = supported`;
- `post_emit_validation_error_count = 5`;
- route blocking;
- unreachable route points;
- door-cone blocking.

`finish_supported()` не проверяет post-emit verdict.

### Обязательное изменение

Workbench не формирует статус самостоятельно. Он сериализует общий `/datum/world_edit_validation_verdict`.

`SUPPORTED` разрешён только если:

```text
plan_valid = true
apply_success = true
post_apply_hard_error_count = 0
undo_restored = true
expectations_passed = true
```

Любая post-emit ошибка переводит case в `validation_failed` и возвращает ненулевой exit code.

### Acceptance

- невозможен report со `status=supported` и hard error count > 0;
- schema validator проверяет это как invariant;
- committed generated reports отсутствуют.

---

## PR99-B11. Поле `expect` загружается, но не применяется

### Текущее состояние

Case JSON содержит expected status и metrics, но runtime только сохраняет `expect_config`. Workflow считает failure лишь отсутствие artifacts или render failure. Семантически неверный report не делает процесс failed.

### Обязательное изменение

Добавить `validate_case_expectations(case, report)`.

Поддержать assertions:

- exact status;
- exact reason code;
- zero/nonzero hard errors;
- direction honored;
- min/max room, door, object counts;
- post-apply errors;
- canvas changed;
- undo restored;
- optional expected layout hash для regression fixtures.

При mismatch:

- report получает `status = expectation_failed`;
- создаётся machine-readable diff;
- process exit code = 1.

### Acceptance

- намеренно неверное expectation ломает workflow;
- `render_workflow.py` проверяет report semantics, а не только наличие PNG/JSON.

---

## PR99-B12. Post-emit validation берётся из metadata plan

### Текущее состояние

Workbench читает `plan.metadata["post_emit_validation_report"]`. Это не независимая проверка реально изменённого мира.

### Обязательное изменение

Post-apply validator должен заново обследовать world:

- проверить type каждого turf;
- проверить наличие, type и dir каждого объекта;
- проверить, что обязательные двери реально проходимы;
- выполнить flood-fill от внешнего входа;
- проверить доступность обязательных rooms и fixtures;
- проверить route clearance;
- проверить отсутствие незапланированных удалений в footprint;
- после undo проверить baseline restoration.

Plan metadata может быть диагностическим input, но не доказательством корректности.

---

## PR99-B13. Несколько определений успеха

### Текущее состояние

`building_layout_quality.dm` считает post-emit errors фатальными, Workbench — нет, preview использует ещё один набор metadata counters.

### Обязательное изменение

Создать один тип:

```dm
/datum/world_edit_validation_verdict
    var/status
    var/list/hard_errors
    var/list/warnings
    var/list/metrics
    var/stage
```

Его используют:

- support/preflight;
- candidate validation;
- preview;
- apply transaction;
- unit tests;
- quality matrix;
- Workbench;
- TGUI payload.

Не допускается повторно вычислять статус из отдельных counters в разных файлах.

---

## PR99-B14. Giant mutable state и metadata explosion

### Текущее состояние

State одновременно хранит footprint, BSP, room graph, solved regions, corridors, walls, doors, anchors, fixtures, validation counters и множество lookup-списков. Plan metadata содержит сотни диагностических полей.

### Обязательное изменение

Каждый stage возвращает typed immutable-by-convention result:

- `footprint_result`;
- `program_graph_result`;
- `partition_result`;
- `routing_result`;
- `shell_result`;
- `furnishing_result`;
- `validation_verdict`.

Stage получает результаты предыдущих стадий и не изменяет их задним числом. Общий mutable context допускается только для:

- request;
- RNG streams;
- diagnostics sink;
- cancellation/budget.

Production metadata ограничить стабильным набором:

- request/program/style/seed;
- footprint/layout hashes;
- selected family;
- room/door/object counts;
- score;
- validation status;
- warning codes.

Полные reject traces выдаются только при `debug_reports` и имеют установленный cap.

---

## PR99-B15. Hardcoded faction catalog и ложная функциональная эквивалентность

### Текущее состояние

Main generator содержит большие maps type paths. Covenant preset подставляет barricade/recharger в роли кровати, туалета, APC, alarm и других функционально разных объектов.

### Риск

Capability check видит непустой provider и считает программу поддерживаемой, хотя gameplay-функция отсутствует.

### Обязательное изменение

Вынести styles в typed catalog:

```dm
/datum/world_edit_building_style
    id
    shell_materials
    list/providers_by_capability
```

Provider объявляет semantic capabilities, например:

- `sleep_surface`;
- `sanitation`;
- `food_preparation`;
- `power_control`;
- `air_monitoring`;
- `lighting`;
- `storage`.

Required slot удовлетворён только provider с соответствующей capability. Визуально похожий объект не считается функциональным эквивалентом.

До появления корректных providers несовместимая program/style комбинация получает `style.missing_capability` и не показывается в UI.

### Acceptance

- capability matrix автоматически строится для всех programs/styles;
- нет generic fallback, который кредитует неподходящий object;
- Covenant/UNSC поддерживаются только там, где найдены реальные gameplay-equivalent paths.

---

## PR99-B16. Template placement создаёт тысячи reject events

### Текущее состояние

Сохранённые reports показывают тысячи `template_geometry_conflict`, `missing_wall_context` и reservation conflicts. Debug traces обрезаются, а сам поиск выполняет много заведомо невозможных попыток.

### Обязательное изменение

Template system должен работать в два шага:

1. **Compile template:** заранее вычислить rotated variants, bounds, required wall sides, occupied cells и semantic capabilities.
2. **Enumerate valid anchors:** до placement отфильтровать anchors по bounds, zone, wall context и reserved route.

Запрещено перебирать все anchors и регистрировать тысячи одинаковых rejects.

Каждый required fixture/template либо атомарно размещён, либо candidate отклонён. Semantic credit без emitted placement запрещён.

### Acceptance

- reject count ограничен числом уникальных candidate/template причин;
- perf test фиксирует solver expansion budget;
- required template placement не использует single-object fallback без отдельного program rule.

---

## PR99-B17. Blueprint display name теряется

### Текущее состояние

DMM payload не хранит `name`, `created_at`, `created_by` и `source`. Loader назначает `name = file stem`. Unit test закрепляет это поведение. Исходные JSON seeds имели человекочитаемые названия.

### Обязательное изменение

DMM остаётся единственным форматом содержимого blueprint, но библиотека получает отдельный metadata index:

```text
data/world_edit/blueprints/
    <id>.dmm
    library.index.json
```

`library.index.json` хранит только metadata:

- id;
- display name;
- created_at;
- created_by;
- source;
- content hash;
- schema version.

Это не дублирование map payload. При отсутствии или повреждении index библиотека восстанавливает записи из DMM, используя ID как fallback name, и сообщает structured warning.

Curated migration должна сохранить старые display names и provenance.

### Acceptance

- `id` и `name` тестируются раздельно;
- restart/reload сохраняет display name;
- импорт DMM предлагает/принимает display name без изменения file ID;
- rename file ID не меняет display name, если пользователь отдельно не выбрал это.

---

## PR99-B18. Blueprint file operations не транзакционны

### Текущее состояние

Save пишет сразу в конечный путь. Rename использует copy/delete. Отсутствует общий transaction/journal; при сбое index и DMM могут разойтись.

### Обязательное изменение

Ввести `/datum/world_edit_blueprint_file_transaction`.

#### Save/import

1. записать DMM во временный файл в той же директории;
2. прочитать и повторно провалидировать временный файл;
3. вычислить content hash;
4. подготовить временный metadata index;
5. атомарно заменить DMM через `frename`;
6. атомарно заменить index;
7. при ошибке выполнить rollback.

#### Rename

1. проверить source/destination;
2. подготовить index update;
3. `frename(old_path, new_path)`;
4. заменить index;
5. при ошибке index вернуть файл обратно.

#### Delete

1. переместить DMM во временный trash path;
2. заменить index;
3. удалить trash;
4. при ошибке index вернуть файл.

### Acceptance

- fault-injection tests на каждом шаге;
- после сбоя библиотека содержит либо старое, либо новое целостное состояние;
- нет половинчатых copy/delete результатов;
- DMM и metadata hash совпадают.

---

## PR99-B19. Workbench включается наличием файла и запускается дважды

### Текущее состояние

`world_edit_visual_should_start()` проверяет наличие `enabled.txt`. Файл находится в PR. Инициализация вызывается из global world startup и modpack initialization.

### Обязательное изменение

Удалить poller startup из production runtime.

Новый runner запускается только одним из способов:

- `#ifdef UNIT_TESTS` + явный `world.params["world_edit_acceptance"]`;
- отдельная compile target/define;
- существующий unit-test harness.

Runner одноразовый:

1. загружает case set;
2. выполняет cases;
3. пишет artifacts;
4. возвращает aggregate result;
5. завершает test runtime.

Постоянный filesystem polling не нужен ни в CI, ни в production.

### Acceptance

- `rg -n "world_edit_visual_should_start|enabled.txt" code modular/world_edit/code` не находит production startup;
- обычный сервер никогда не поднимает Workbench;
- один test command запускает runner на Linux/Windows-supported CI path без ручного процесса.

---

## PR99-B20. Документация описывает несовместимые системы

### Текущее состояние

Один документ называет текущий подход noise/tile-first, другой описывает 16-stage room-first pipeline, который фактически bypass-ит первые стадии.

### Обязательное изменение

Оставить два канонических документа:

1. `building_layout_architecture.md` — реальный production data flow и типы.
2. `building_layout_acceptance.md` — invariants, matrices, команды и status contract.

Документация должна ссылаться на реальные type/proc names и обновляться в том же commit, где меняется контракт.

---

## 4. Целевая архитектура генератора

## 4.1 Архитектурный принцип

Core generator — **детерминированный graph-constrained solver с bounded search**.

Randomness используется только для:

- seeded tie-breaking;
- выбора optional features;
- декоративной вариативности после выполнения hard constraints.

Randomness не определяет topology и не может исправлять invalid layout.

### Что не используется как core

- Perlin/Simplex/noise — только для необязательного визуального износа/декора;
- WFC — только для локальной фасадной или декоративной укладки, но не для глобальной room connectivity;
- GAN/diffusion/LLM runtime — не входит в PR: требует dataset/model runtime и не даёт необходимой детерминированной доказуемости.

Современные ML-подходы полезны как ориентир: они также моделируют floor plan через boundary, room graph, topology и проверяемые числовые ограничения. В игровом BYOND runtime эти идеи реализуются deterministic solver-ом.

## 4.2 Новый production data flow

### Stage 1. Request normalization

Вход:

- program ID;
- style ID;
- size profile;
- seed;
- placement shape contract;
- direction;
- blocker/overwrite policy.

Выход:

- `/datum/world_edit_building_request`;
- validation verdict.

Request имеет typed fields. Raw `params` list не передаётся дальше normalization boundary.

### Stage 2. Footprint resolution

`/datum/world_edit_building_footprint` содержит:

- ordered cells;
- lookup;
- boundary/interior;
- connected components;
- entry-facing edge candidates;
- dimensions;
- shape/family ID;
- stable hash.

Проверки:

- один z-level;
- cap 32×32;
- один connected component;
- минимальная ширина проходов;
- достаточно interior cells;
- валидная наружная грань для входа.

Point mode генерирует family masks RECT/L/T/U в пределах выбранного size profile. Rectangle modes используют exact user footprint.

### Stage 3. Program graph

`/datum/world_edit_building_program` формирует граф:

Nodes:

- room ID;
- role;
- min/preferred/max area;
- aspect ratio bounds;
- privacy;
- facade requirement;
- mandatory capabilities;
- optional flag/weight.

Edges:

- required adjacency;
- required route connection;
- forbidden adjacency;
- privacy transition;
- door count/width.

Optional nodes добавляются только после доказанного размещения mandatory graph.

### Stage 4. Spatial partition solver

Использовать beam-search по rectilinear partitions.

Рекомендуемые limits:

- beam width: 8;
- max candidates: 16;
- max partition expansions: 2048;
- max routing expansions: 4096;
- cancellation on `TICK_CHECK`/budget boundary согласно существующим repo patterns.

Алгоритм:

1. выбрать наиболее constrained room;
2. сгенерировать допустимые region splits по required area/aspect/facade;
3. выполнить forward-check оставшейся площади и adjacency;
4. сохранить top-K partial states;
5. завершить при назначении всех mandatory rooms;
6. присоединить optional rooms, если они не нарушают mandatory layout.

Для irregular family mask regions split работает с rectilinear cell sets, а не только с bounding boxes.

### Stage 5. Routing and openings

1. Выбрать внешний вход на requested face.
2. Построить route graph между room doors.
3. Проложить corridor skeleton через A* или bounded BFS по свободным cells.
4. Реализовать required graph edges doors/openings.
5. Проверить flood-fill от входа ко всем mandatory rooms.

Door placement является частью topology, а не поздним декоративным исправлением.

### Stage 6. Shell derivation

Из room/corridor ownership вывести:

- external walls;
- internal walls;
- doors;
- windows;
- floor cells.

Запрещено независимо рисовать стены шумом или repair-ить connectivity после shell emission.

### Stage 7. Functional furnishing

Furnishing работает по semantic capabilities и free-space masks.

Порядок:

1. required infrastructure;
2. required program fixtures;
3. optional fixture modules;
4. decorative detail;
5. optional microvariation.

Каждый module имеет:

- occupied cells;
- clearance cells;
- required wall directions;
- provided capabilities;
- allowed room roles;
- rotations;
- priority.

Placement атомарен. Credit выдаётся только за реально запланированный object set.

### Stage 8. Candidate validation

Hard invariants:

- footprint bounds/connectedness;
- room ownership без overlap;
- mandatory room min area;
- mandatory room reachability;
- required adjacency/doors;
- route clearance;
- wall/door consistency;
- facade constraints;
- required fixture capabilities;
- no placement collision;
- all type paths valid;
- no hidden fallback/degradation.

Candidate с одним hard error отбрасывается.

### Stage 9. Candidate scoring

Score применяется только к hard-valid candidates.

Централизованные soft metrics:

- preferred area deviation;
- corridor length/area;
- room aspect quality;
- optional program fulfillment;
- facade/window quality;
- fixture coverage;
- repetition penalty;
- compactness;
- requested direction fidelity.

Weights живут в одном `building_layout_scoring.dm`, а не распределяются по stages.

### Stage 10. Plan emission

Emitter создаёт immutable `/datum/world_edit_plan`:

- ordered turf placements;
- ordered object placements;
- affected turfs;
- selected candidate summary;
- validation verdict;
- target state hash;
- compact diagnostics.

Emitter ничего не исправляет. Invalid input не должен доходить до emitter.

---

## 5. Целевые datums и contracts

```dm
/datum/world_edit_building_request
    var/program_id
    var/style_id
    var/size_profile
    var/seed
    var/direction
    var/overwrite_policy
    var/datum/world_edit_shape_contract/shape

/datum/world_edit_building_footprint
    var/family_id
    var/list/cells
    var/list/boundary
    var/list/interior
    var/hash

/datum/world_edit_building_room_spec
    var/id
    var/required
    var/min_area
    var/preferred_area
    var/max_area
    var/min_aspect
    var/max_aspect
    var/list/required_capabilities

/datum/world_edit_building_connection_spec
    var/from_room
    var/to_room
    var/kind
    var/required

/datum/world_edit_building_candidate
    var/id
    var/datum/world_edit_building_footprint/footprint
    var/list/rooms
    var/list/routes
    var/list/openings
    var/list/placements
    var/datum/world_edit_validation_verdict/verdict
    var/score
    var/layout_hash

/datum/world_edit_validation_verdict
    var/status
    var/stage
    var/list/hard_errors
    var/list/warnings
    var/list/metrics

/datum/world_edit_apply_transaction
    var/datum/world_edit_plan/plan
    var/list/snapshot
    var/list/created_atoms
    var/list/changed_turfs
    var/state
```

### Status contract

Preflight:

- `supported`;
- `unsupported`;
- `invalid_request`.

Generation:

- `valid_plan`;
- `no_solution`;
- `validation_failed`;
- `internal_error`.

Apply:

- `applied`;
- `world_conflict`;
- `rolled_back`;
- `apply_failed`.

Workbench terminal:

- `passed`;
- `expected_rejection`;
- `failed`.

Не использовать одно слово `supported` одновременно для support, generation и post-apply состояния.

---

## 6. Рекомендуемая файловая структура

В итоговом PR не должно быть параллельных `legacy` и `v2` директорий. Перестроить текущую `building_layout` директорию:

```text
modular/world_edit/code/generators/building_layout/
  world_edit_generator_building_layout.dm      # тонкий World Edit adapter

  domain/
    building_request.dm
    building_footprint.dm
    building_program.dm
    building_candidate.dm
    building_validation_verdict.dm

  catalog/
    building_program_catalog.dm
    programs/
      living.dm
      ...
    building_style_catalog.dm
    styles/
      colony.dm
      uscm.dm
      unsc.dm
      neutral.dm
      covenant.dm

  solver/
    building_feasibility_solver.dm
    building_family_masks.dm
    building_partition_solver.dm
    building_route_solver.dm
    building_opening_solver.dm
    building_candidate_search.dm
    building_scoring.dm

  furnishing/
    building_fixture_provider.dm
    building_template_chunk.dm
    building_template_registry.dm
    building_furnishing_solver.dm
    building_infrastructure_solver.dm
    building_decor_solver.dm

  validation/
    building_footprint_validator.dm
    building_topology_validator.dm
    building_furnishing_validator.dm
    building_plan_validator.dm
    building_post_apply_validator.dm

  runtime/
    building_plan_emitter.dm
    building_apply_transaction.dm
    building_undo_adapter.dm

  diagnostics/
    building_diagnostics.dm
    building_report_serializer.dm
```

### Старые файлы: действие

| Текущий файл/группа | Действие |
|---|---|
| `pipeline/stages/*` | удалить и заменить настоящими solver/validation stages |
| `building_layout_geometry.dm` | переписать; монолит не сохранять |
| `building_layout_state.dm` и nested states | заменить typed stage results |
| `building_layout_bsp.dm` | перенести полезные primitives в partition solver, остальное удалить |
| `building_layout_room_graph.dm` | переписать под program/topology graph contract |
| `building_layout_validators.dm` | разделить по invariant ownership |
| `building_layout_fixtures.dm` | переписать как capability-based solver |
| `building_layout_macros.dm` | заменить explicit fixture modules |
| `building_layout_signatures.dm` | удалить credit hacks; оставить только измеримые program goals |
| `building_layout_microvariation.dm` | оставить последней optional стадией после hard validation |
| `building_layout_quality.dm` | заменить общим acceptance matrix runner |
| `world_edit_generator_building_layout.dm` | сократить до adapter/fields/preview/apply orchestration |
| `building_layout_seed.dm` | сохранить после unit tests deterministic streams |
| DMM template chunks | сохранить только после compile-time validation и registry cleanup |

---

## 7. Blueprint subsystem: итоговый контракт

## 7.1 Storage

- DMM — единственный content format.
- Metadata — один versioned library index.
- IDs — file-safe и immutable внутри одной operation.
- Display names — отдельны от IDs.
- Каждый loaded blueprint получает content hash.

## 7.2 Validation

До попадания в library:

- parse DMM;
- single z;
- width/height ≤ 32;
- allowed turf/object allowlists;
- allowed var allowlist;
- cardinal dirs;
- max entries;
- no duplicate conflicting slots;
- serialize/reparse equivalence;
- metadata schema validation.

## 7.3 Cache

Library cache key:

```text
id + content_hash + metadata_revision
```

Переименование ID не требует parse/serialize DMM. Изменение content invalidates parsed definition и preview assets.

## 7.4 UI operations

Разделить действия:

- Rename file ID;
- Rename display name;
- Import;
- Export;
- Delete;
- Duplicate;
- Reload/rescan.

Delete и overwrite требуют подтверждения. Ошибка файловой операции не должна сбрасывать active selection до rollback/refresh.

---

## 8. Workbench/acceptance runner: новая схема

## 8.1 Удалить постоянный poller

Не использовать:

- `enabled.txt`;
- spawn-loop;
- изменение `sleep_offline`;
- fallback на production z=1;
- двойную init-точку.

## 8.2 One-shot execution

Runner принимает:

```text
--case <path>
--case-dir <path>
--out <temp path>
--artifacts <none|semantic|sprites>
```

Внутри DM он вызывает production interfaces, но запускается через test target.

Для каждого case:

1. setup isolated canvas;
2. build request;
3. preflight;
4. preview/generate;
5. validate plan;
6. apply transaction;
7. inspect actual world;
8. undo;
9. inspect restoration;
10. validate expectations;
11. serialize report.

## 8.3 Case schema v2

```json
{
  "schema": "world_edit_building_case/v2",
  "id": "living_point_colony_north",
  "request": {
    "program": "living",
    "style": "colony",
    "shape": "point",
    "size_profile": "standard",
    "direction": "north",
    "seed": 1001
  },
  "expected": {
    "preflight": "supported",
    "generation": "valid_plan",
    "apply": "applied",
    "undo": "restored",
    "hard_error_count": 0,
    "direction_honored": true
  }
}
```

## 8.4 Report schema v2

Минимум:

- schema/version;
- case/request IDs;
- phase statuses;
- verdict errors/warnings;
- hashes;
- counts;
- timings;
- expectation diff;
- artifact paths;
- final pass boolean.

Report invariant:

```text
passed == true
=> all expected phases match
=> hard_error_count == 0
=> apply skipped_count == 0
=> undo restored == true
```

## 8.5 Artifacts

PNG и sprite render являются review artifacts, но не acceptance source. Источником истины служит semantic report и assertions.

Artifacts создаются в temp/CI artifact directory и не коммитятся.

---

## 9. TGUI: обязательные изменения

## 9.1 Поля генератора

Показывать:

- Program;
- Compatible style;
- Size profile;
- Seed;
- Direction;
- Safe blocker policy;
- Detail level.

Не показывать `half_width/half_depth` одновременно с opaque auto sizing. Для point mode размер задаётся понятным profile и, при необходимости, advanced exact dimensions. Explicit rectangle получает размеры из shape selection.

## 9.2 Capability-driven options

Server payload возвращает:

- supported shapes;
- compatible styles для выбранной программы;
- disabled option reason;
- min footprint/profile requirements.

TGUI не дублирует static support knowledge.

## 9.3 Preview status

Preview показывает коротко:

- program/style/profile;
- footprint family and size;
- rooms;
- doors;
- required capabilities satisfied;
- warnings;
- blockers/replacements;
- seed/layout hash.

Большие internal counters не выводятся в основное сообщение.

## 9.4 Apply safety

- Apply disabled без current valid preview revision.
- Любое изменение params invalidates preview.
- Изменение world hash invalidates apply.
- Destructive replacement требует отдельного confirmation modal.

## 9.5 Blueprint names

UI отдельно отображает:

- display name;
- file ID;
- dimensions;
- object count;
- validity;
- source/author/time, если доступны.

Rename ID и rename display name — разные actions.

---

## 10. Автоматическая acceptance matrix

## 10.1 Fast matrix — обязательна для каждого PR push

Dimensions:

- все registered programs;
- все compatible styles;
- directions N/E/S/W;
- shapes point/rectangle/filled_rectangle;
- profiles compact/standard;
- seeds: `0, 1, 2, 3, 5, 8, 13, 21`;
- blocker scenarios:
  - blank;
  - hard blocker;
  - changed after preview;
  - destructive overwrite with/without confirmation.

Не требуется Cartesian product всех измерений в fast matrix. Orchestrator строит pairwise matrix, но каждая программа, style, direction, shape, profile и blocker scenario должна быть покрыта.

## 10.2 Full matrix — перед финальной сдачей

- все supported program/style combinations;
- four directions;
- compact/standard/spacious;
- point families RECT/L/T/U, где declared;
- seeds 0..99;
- exact rectangle sizes на нижней границе, типичном и максимальном размере;
- apply/undo для каждого generated plan;
- blueprint library audit всех curated DMM.

## 10.3 Hard thresholds

Для supported combinations:

- preflight→plan parity: 100%;
- hard validation errors: 0;
- post-apply errors: 0;
- skipped placements: 0;
- partial apply: 0;
- undo restoration failures: 0;
- missing required capabilities: 0;
- stale preview accepted: 0;
- same-seed nondeterminism: 0.

Diversity:

- среди 20 seeds для каждой program/family пары минимум 4 unique layout hashes;
- минимум 3 unique furnishing hashes, если detail level > 0.

Performance budget для 32×32 на acceptance runner:

- generation p95 ≤ 2,0 секунды wall time;
- apply + post-apply validate p95 ≤ 1,0 секунды;
- candidate count ≤ 16;
- partition expansions ≤ 2048;
- route expansions ≤ 4096;
- отсутствие unbounded loops/spawned background tasks.

Если CI hardware требует иной абсолютный threshold, изменение допускается только с committed benchmark evidence и не должно превращать лимит в бесконечный.

---

## 11. Обязательные unit/integration tests

### Domain

- request normalization;
- invalid program/style/profile;
- deterministic RNG stream separation;
- program graph validity;
- capability matrix.

### Footprint

- point families RECT/L/T/U;
- exact rectangle normalization;
- connectedness;
- boundary/interior;
- min width;
- 32×32 cap;
- direction-facing entry candidates.

### Solver

- mandatory room placement;
- min/preferred/max areas;
- aspect constraints;
- required/forbidden adjacency;
- optional room selection;
- best candidate selection, not first candidate;
- deterministic hashes;
- no-solution reason.

### Routing/shell

- entry reachability;
- all mandatory rooms reachable;
- doors connect valid regions;
- windows only on allowed external walls;
- no double wall/diagonal-only accidental contact;
- requested direction honored or request rejected.

### Furnishing

- required capabilities;
- template rotations;
- clearance;
- no route blocking;
- no semantic credit without emitted objects;
- no fake provider equivalence;
- budget and optional detail.

### Apply/undo

- success exact apply;
- turf failure rollback;
- object failure rollback;
- blocker conflict;
- stale preview conflict;
- post-apply mismatch rollback;
- full undo restoration;
- history only after commit.

### Blueprints

- DMM parse and allowlists;
- serialize/reparse equivalence;
- oversize/multi-z/invalid path/invalid var;
- friendly name persists across restart;
- ID rename leaves content and name intact;
- transaction failure rollback;
- 34 curated blueprint files load and validate;
- index rebuild fallback;
- preview cache invalidation.

### Workbench

- expected pass;
- expected rejection;
- expectation mismatch fails process;
- post-apply hard error cannot be supported;
- missing validation fails;
- artifacts optional;
- output not tracked.

### TGUI

- only server-supported shapes;
- compatible style filtering;
- disabled reason rendering;
- preview revision invalidation;
- destructive confirmation;
- display name vs ID;
- blueprint action state.

---

## 12. Build и CI gates

Codex выполняет их самостоятельно.

### Каждый функциональный commit

```bash
git diff --check
```

DM:

```bash
BUILD.cmd
```

или CI-equivalent:

```bash
tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
```

TGUI/lint:

```bash
tools/build/build --ci lint tgui-test
```

Map-sensitive checks, поскольку PR добавляет DMM templates/canvas:

```bash
tools/bootstrap/python -m tools.maplint.source --github
tools/bootstrap/python -m dmi.test
tools/bootstrap/python -m mapmerge2.dmm_test
tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_BASE
tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_EXTRA
```

Unit tests запускать по каноническому пути `.github/workflows/run_unit_tests.yml` и `code/modules/unit_tests/README.md`.

Новый acceptance runner обязан запускаться отдельной командой без ручного DreamDaemon управления и возвращать exit code.

### Merge gate

Все одновременно:

- clean diff;
- DM build 0 errors/0 warnings;
- lint/TGUI pass;
- map checks pass;
- unit tests pass;
- fast matrix pass;
- full matrix pass;
- no unresolved PR review thread по актуальному коду;
- no tracked runtime artifacts;
- docs match production types;
- known-error document не содержит относящихся к PR незакрытых ошибок.

Unrelated pre-existing failures должны быть доказаны запуском на base SHA и задокументированы как delta evidence. Нельзя просто назвать failure «existing» без base comparison.

---

## 13. Commit plan для перестроенного PR

Рекомендуемая линейная история:

1. `chore(world-edit): remove generated artifacts and revert global workbench hooks`
2. `refactor(world-edit-blueprints): transactional DMM library and metadata index`
3. `refactor(building-layout): introduce typed request, program and validation contracts`
4. `refactor(building-layout): replace legacy geometry with graph-constrained candidate solver`
5. `refactor(building-layout): capability-based furnishing and style catalog`
6. `fix(building-layout): atomic apply, rollback and undo validation`
7. `test(world-edit): add one-shot building acceptance runner and matrices`
8. `ui(world-edit): expose supported capabilities and safe apply flow`
9. `docs(world-edit): publish architecture and acceptance contracts`

Каждый commit компилируется и проходит релевантные tests. Не оставлять временно сломанный промежуточный commit в финальной истории.

---

## 14. Definition of Done

PR #99 считается готовым только когда выполнены все пункты:

- [ ] `code/game/world.dm` не содержит Workbench glue.
- [ ] Нет committed enable flag, outputs, PNG, runtime JSON и scratch scripts.
- [ ] Нет `room_first_layout`/legacy production path.
- [ ] Advertised shapes равны реально поддерживаемым.
- [ ] Support и generation используют один feasibility model.
- [ ] Нет silent fallback и hidden program shedding.
- [ ] Все валидные candidates сравниваются score-ом.
- [ ] Required capabilities обеспечены реальными functional providers.
- [ ] Apply атомарен; partial success невозможен.
- [ ] Preview защищён target state hash.
- [ ] Post-apply validator исследует реальный world.
- [ ] Undo restoration автоматически доказан.
- [ ] Workbench expectations реально проверяются.
- [ ] Report с hard errors не может быть passed/supported.
- [ ] Blueprint display names переживают restart.
- [ ] Blueprint save/rename/delete транзакционны.
- [ ] Все curated DMM проходят audit.
- [ ] Fast и full matrices зелёные.
- [ ] Документация едина и соответствует коду.
- [ ] Пользователь получает финальную сборку, артефакты и одну процедуру UAT.

---

## 15. Финальное участие пользователя

До этого шага пользователь не тестирует промежуточные сборки.

Codex предоставляет один финальный пакет:

1. merge-ready PR;
2. CI/acceptance summary;
3. таблицу supported programs/styles/shapes;
4. 12–20 curated semantic/sprite previews;
5. список seed/layout hashes для воспроизводимости;
6. инструкцию UAT на 10–15 минут:
   - открыть World Edit;
   - создать несколько построек;
   - проверить preview/apply;
   - проверить undo;
   - импортировать/переименовать/экспортировать blueprint.

Пользователь оценивает только итоговый UX и визуальное качество. Корректность, целостность, совместимость и регрессии к этому моменту уже должны быть доказаны автоматикой.
