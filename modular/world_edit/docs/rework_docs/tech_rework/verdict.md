# Вердикт по PR #99

Предыдущий план действительно был слишком общим. После технического аудита текущего head `050a5790352b0b54f78585e0a54fce4dfacf7ebe` решение однозначное:

**PR нельзя доводить точечными исправлениями. Ветку необходимо перестроить как новый, последовательно собираемый PR.**

Сейчас в одном draft-PR смешаны 286 файлов, 47 коммитов, почти 50 тысяч добавленных строк, blueprint-хранилище, генератор, Workbench, runtime-хуки, Python-инструменты, TGUI и локальные артефакты.

## Что именно необходимо тотально переработать

### 1. Полностью убрать ложную staged-архитектуру

Сейчас присутствуют stage-классы для графа, BSP и room shapes, но они фактически пропускаются, потому что production-код принудительно включает `room_first_layout`. Реальная генерация остаётся внутри старого монолитного solver-пути.

Требование:

* удалить `room_first_layout` и двойной production path;
* удалить пустые или декоративные stages;
* построить один последовательный pipeline;
* каждая стадия должна принимать типизированный результат предыдущей стадии;
* запретить чтение и запись произвольного общего `config`/`metadata`;
* ошибки стадии должны завершать генерацию, а не накапливаться до конца.

Целевой pipeline:

```text
Request normalization
→ Shape resolution
→ Feasibility
→ Program graph
→ Candidate generation
→ Spatial partition
→ Route solving
→ Doors and walls
→ Semantic furnishing
→ Infrastructure
→ Validation
→ Scoring
→ Immutable plan
```

### 2. Полностью заменить текущий алгоритм выбора планировки

Сейчас point-режим реально генерирует только `RECT`, а цикл прекращается на первом валидном кандидате. Поэтому заявленного выбора лучшей планировки по score нет. Также присутствует скрытый fallback с explicit shape на point-generated building.

Новая реализация должна:

* генерировать ограниченный детерминированный набор кандидатов;
* валидировать каждый кандидат;
* оценивать все валидные кандидаты;
* выбирать лучший по стабильному score;
* использовать детерминированный tie-breaker;
* возвращать явную ошибку, если кандидат не найден;
* никогда молча не менять shape, программу или размеры;
* не использовать шум как источник геометрии помещений.

Основой должны стать:

* граф обязательных помещений;
* adjacency constraints;
* privacy constraints;
* BSP/guillotine partition;
* corridor routing;
* room aspect-ratio constraints;
* обязательная связность;
* placement templates только после завершения топологии.

### 3. Сократить shape contract до честно поддерживаемого набора

Генератор рекламирует почти все World Edit shapes, но support-check фактически блокирует часть из них и формирует противоречивые lock-коды.

Для первой merge-ready версии оставить только:

* `point`;
* `rectangle`;
* `filled_rectangle`.

Остальные shapes должны быть либо полноценно реализованы и покрыты матрицей тестов, либо полностью удалены из UI и `get_supported_placement_shapes()`.

Нельзя оставлять состояния «показывается в UI, но пока не реализовано».

### 4. Ввести единый feasibility и validation verdict

Сейчас support-check, preview, quality batch, apply и Workbench используют разные определения успеха. Quality batch считает post-emit ошибки фатальными, а Workbench способен записать `supported` при пяти post-emit ошибках.

Должен существовать один типизированный verdict:

```text
SUPPORTED
UNSUPPORTED
INVALID
INTERNAL_ERROR
```

`SUPPORTED` разрешён только когда одновременно выполнено:

* все обязательные комнаты созданы;
* все обязательные adjacency соблюдены;
* граф помещений связен;
* вход соединён со всеми обязательными помещениями;
* маршруты не перекрыты;
* двери проходимы;
* объекты не блокируют обязательный проход;
* обязательная инфраструктура присутствует;
* emitter создал всё запланированное;
* post-apply validation имеет ноль hard errors.

Один и тот же verdict должен использоваться в:

* preview;
* apply;
* unit tests;
* quality matrix;
* Workbench;
* UI;
* экспортируемом report.

### 5. Полностью переписать apply как транзакцию

Сейчас apply пропускает неудачные turfs и objects, но всё равно возвращает `success = TRUE` с сообщением `applied with warnings`. Это позволяет получить половину здания.

Новая модель:

```text
Preflight snapshot
→ Revalidate target state
→ Apply turfs
→ Apply objects
→ Validate emitted world
→ Commit changeset
```

При любой ошибке:

```text
Rollback objects
→ Rollback turfs
→ Verify restoration
→ Return failure
```

Обязательные условия:

* частичный успех запрещён;
* `success = TRUE` возможен только при нулевом числе skipped operations;
* preview хранит hash целевого состояния;
* apply отказывается работать, если мир изменился после preview;
* rollback автоматически проверяется fault-injection тестами;
* undo восстанавливает предыдущие turfs, baseturfs и созданные объекты.

### 6. Убрать небезопасные значения по умолчанию

Сейчас по умолчанию:

```text
respect_blockers = false
replace_blocked_turfs = true
```

Это опасно для административного инструмента.

Новые defaults:

```text
respect_blockers = true
replace_blocked_turfs = false
```

Принудительная замена допускается только как отдельный явно включённый режим с повторным preview и отображением количества заменяемых объектов и turfs.

### 7. Переработать программы и стили построек

Сейчас faction preset одновременно определяет визуальный стиль и функциональные providers. В Covenant preset кровать, туалет, APC, alarm и другие функционально разные объекты могут подменяться barricade/recharger-path. Это создаёт ложное прохождение capability validation.

Необходимо разделить:

* **Building program** — требуемые помещения и функции;
* **Style** — стены, пол, двери, окна, декоративные варианты;
* **Capability provider** — реальный функциональный объект;
* **Decoration set** — необязательное визуальное наполнение.

Стиль, у которого нет настоящего provider для обязательной функции, не должен быть доступен для этой программы.

На первом этапе следует оставить ограниченную доказанную матрицу программ и стилей. Непроверенные combinations удаляются из UI, а не обозначаются как «экспериментальные».

### 8. Переработать template placement

Существующий прогон способен породить тысячи reject-событий для одного здания. Это означает, что поиск кандидатов выполняется слишком поздно и перебирает заведомо несовместимые anchors.

Новая система должна:

* компилировать DMM templates в runtime descriptors при инициализации;
* заранее вычислять размеры, rotations, slots и wall requirements;
* индексировать templates по capability;
* предварительно фильтровать anchors;
* ограничивать число попыток;
* не использовать reject log как основной механизм поиска;
* считать превышение search budget ошибкой solver-а.

### 9. Перестроить Blueprint Library как транзакционное хранилище

DMM-файл не сохраняет display name и остальные пользовательские метаданные. После перезапуска библиотека восстанавливает `name` из file stem, поэтому человекочитаемое имя теряется. Save пишет сразу в конечный путь, а rename реализован не как атомарная операция.

Новая модель:

```text
data/world_edit/blueprints/
  index.json
  files/
    <id>.dmm
```

`index.json` хранит:

* schema version;
* id;
* display name;
* filename;
* created_at;
* created_by;
* source;
* content hash;
* dimensions;
* entry count.

Операции save/import/rename/delete должны выполняться через:

```text
Validate
→ Write temporary file
→ Read-back validation
→ Atomic rename
→ Update temporary index
→ Atomic index replacement
```

Дополнительно:

* проверка duplicate IDs;
* проверка duplicate filenames;
* hash verification;
* восстановление после оборванной операции;
* unit tests на restart/reload;
* сохранение display name;
* запрет перезаписи существующего blueprint без отдельной операции.

### 10. Убрать текущий polling Workbench

Нужно удалить:

* глобальный Workbench hook из `code/game/world.dm`;
* второй запуск из modpack initialization;
* `enabled.txt`;
* постоянный polling loop;
* fallback на игровой z-level;
* tracked `out/**`;
* tracked PNG/JSON runtime artifacts;
* runtime management как часть обычного server startup.

Вместо этого должен быть **one-shot acceptance runner**:

```text
Start dedicated test runtime
→ Load compiled test canvas
→ Execute supplied cases
→ Enforce expect assertions
→ Write artifacts
→ Return nonzero on mismatch
→ Shut down
```

Поле `expect` должно реально проверяться. Любое несовпадение status, error count, route count, direction или layout hash завершает runner с ошибкой.

### 11. Очистить ветку

Обязательное удаление из PR:

* корневого пустого `plan`;
* `_write.ps1`;
* `fix_stages.py`;
* локальных `_collect_metrics.py` и `_deep_errors.py`;
* `enabled.txt`;
* `tools/world_edit_visual/out/**`;
* сгенерированных PNG;
* runtime reports;
* временных пользовательских cases;
* внутренних task-state и deep-research документов;
* старых JSON seed-файлов после завершения проверяемой миграции.

### 12. Перестроить тестирование

Codex не должен просить пользователя проверять промежуточные сборки.

Автоматическая матрица должна включать:

* все поддерживаемые programs;
* все разрешённые styles;
* все разрешённые shapes;
* минимальный, обычный и максимальный размер;
* несколько фиксированных seeds;
* все четыре направления;
* blocked footprint;
* target mutation после preview;
* emitter fault injection;
* rollback verification;
* undo verification;
* blueprint save/reload/rename/delete;
* deterministic layout hash;
* отсутствие hard errors.

Известные E-WEV-001 и E-WEV-002 должны быть исправлены либо соответствующие возможности полностью удалены из supported matrix. Оставлять их как «известные production issues» нельзя.

## Подготовленные документы

В технической спецификации зафиксированы 20 блокирующих дефектов, обязательные удаления и изменения, целевые datum-контракты, структура файлов, acceptance criteria, commit plan и Definition of Done:

[Техническая спецификация полной переработки PR #99](sandbox:/mnt/data/PR99_TOTAL_REWORK_SPEC.md)

Отдельный документ предназначен непосредственно для Codex. В нём определены зависимости, worktrees, exclusive file ownership и девять субагентов: cleanup, blueprint storage, typed domain, topology solver, furnishing, atomic apply, acceptance runner, TGUI и независимый red-team review:

[Исполнимый план для Codex и субагентов](sandbox:/mnt/data/PR99_CODEX_EXECUTION_PLAN.md)

Пользователь подключается только после зелёной полной матрицы — для одной финальной проверки UX и визуального результата. До этого сборка, DreamDaemon, seeds, rollback, DMM-операции, скриншоты и регрессии полностью находятся в ответственности Codex и субагентов.
