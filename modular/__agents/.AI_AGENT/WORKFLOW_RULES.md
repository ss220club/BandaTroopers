# Workflow Rules

## Discovery first
- Перед анализом большой зоны кода сначала сузить область через `rg`.
- Базовый порядок:
  1. `rg` по именам типов, proc, define, map/config ключам и комментариям-маркерам.
  2. Проверка entrypoints, include graph, callsites и data flow.
  3. Поиск существующих extension points, signals и modular hooks.
  4. Только после этого planning-mutation в task-state; implementation-правки начинаются только после актуального контракта задачи.
- Не читать крупные директории целиком, если задачу можно сузить выборочными запросами.
- Для задач в `modular/**` сначала проверять `colonialmarines.dme`, `modular/modular.dme`, relevant `_*.dme`, затем целевой модуль и его callsites.
- Для правок в upstream сначала проверять, существует ли уже modular hook, adapter или modpack-level abstraction, через которые можно закрыть задачу.
- Для runtime/performance/freeze задач перед планом правок обязательно выполнить `Runtime freeze / MC / CPU spike triage`.
- Для BYOND/DM planner/list-heavy задач перед планом правок обязательно выполнить `BYOND/DM list mutation safety` audit.

## Runtime freeze / MC / CPU spike triage
Если задача описывает MC death, CPU spike, зависание сервера, зависание preview/apply, бесконечную обработку, резкий рост нагрузки или подозрение на утечку памяти, сначала считать это runtime-runaway проблемой.

Перед архитектурными гипотезами и full rewrite обязательно выполнить минимальный runaway-аудит:

1. Определить точный синхронный entrypoint пользовательского действия:
   - UI action;
   - preview;
   - apply;
   - click handler;
   - hover handler;
   - subsystem tick;
   - unit test path.

2. Сузить модуль через targeted search:
   ```bash
   rg -n "while\(" <target_module>
   rg -n "for\(" <target_module>
   rg -n "\-=|\+=|Cut\(|Remove|Add" <target_module>
   rg -n "spawn\(|sleep\(|CHECK_TICK|stoplag" <target_module>
   ```

3. Для каждого `while` в затронутом call path доказать progress invariant:
   - что меняется на каждой итерации;
   - какой список, индекс или счетчик гарантированно уменьшается/растет;
   - что происходит, если удаление/фильтрация не сработала;
   - есть ли safety cap или понятный выход.

4. Для циклов по спискам проверить:
   - удаление элемента во время итерации;
   - повторное добавление того же элемента;
   - mutation outer-list через nested-list;
   - отсутствие duplicate guard;
   - отсутствие лимита на candidate/result size.

5. Для preview/apply/planner/pathfinding/flood-fill задач проверить:
   - максимальное число turfs/candidates/placements;
   - отсутствие `area * footprint` алгоритмов без бюджета;
   - отсутствие полного rebuild на hover;
   - отсутствие повторного full-plan build на confirm/apply;
   - кэш инвалидируется при смене generator/params/shape/mode.

6. Только после этого переходить к архитектурным гипотезам:
   - stale cache;
   - preview ownership;
   - deferred execution;
   - shape routing;
   - endpoint clamp;
   - full planner rewrite.

## BYOND/DM list mutation safety
Для BYOND/DM кода отдельно проверять небезопасные операции со списками.
Дополнительные DM-specific правила живут в [`DM_RULES.md`](DM_RULES.md).

Опасные паттерны:

```dm
outer_list -= nested_list
outer_list -= assoc_list
while(length(items))
	...
	items -= selected_item
```

Если элемент списка сам является `list` или assoc-list, нельзя полагаться на `outer -= selected_item` как на безопасное удаление выбранного элемента из outer-list.

Предпочтительный паттерн:

```dm
var/best_index = null

for(var/i in 1 to length(candidates))
	var/list/candidate = candidates[i]
	if(is_best_candidate(candidate))
		best_index = i

if(!isnull(best_index))
	ordered += list(candidates[best_index])
	candidates.Cut(best_index, best_index + 1)
```

Правила:

1. Для nested-list/assoc-list candidates удалять выбранный элемент через индекс и `Cut(index, index + 1)`.
2. В сортировках и best-candidate loops хранить `best_index`, а не только `best_candidate`.
3. Любой `while(length(list))` должен иметь гарантированное потребление элемента или safety guard.
4. Если цикл строит preview/apply/runtime plan, добавить focused test на:
   - список уменьшается;
   - один candidate не возвращается повторно;
   - длина результата не превышает длину входного списка, если это ожидаемый контракт.

## Read-only, planning-mutation и implementation-mutation границы
- Read-only действия: поиск, чтение, diff, анализ include/call graph, dry-run проверки без изменения tracked файлов.
- Planning-mutation: правки только `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md`, нужные чтобы создать или подтвердить контракт текущей задачи. Они разрешены после read-only discovery и до реализации.
- Implementation-mutation: правки продуктового кода, тестов, карт, tgui, stable docs, кодоген, formatters с rewrite и любые команды, целенаправленно меняющие репозиторный state вне active task-state.
- Не смешивать exploratory read-only шаги, planning-mutation и implementation-mutation. Если контракт задачи еще не создан, implementation-mutation запрещена.

## Regression before rewrite
Если задача является regression или пользователь говорит, что "раньше работало":

1. Не начинать с full rewrite.
2. Сначала найти максимально узкое окно:
   - last known good commit;
   - first known bad commit;
   - или минимальный commit range.
3. Просмотреть diff first-bad range по затронутому модулю.
4. В first-bad diff сначала искать:
   - новые `while`;
   - новые nested-list mutations;
   - новые caches;
   - новые deferred paths;
   - новые full-plan builders;
   - удаленные тестовые assertions.
5. Full rewrite разрешен только после короткого отчета:
   - почему минимальный fix/rollback невозможен;
   - какой invariant сломан;
   - какие tests/acceptance criteria доказывают новую реализацию.

## Правила выполнения задач
- Сначала определить тип задачи: docs, DM-код, maps, tgui, build/CI или смешанный scope.
- Для nontrivial изменений без готового пользовательского плана сначала формировать decision-complete plan с рисками, альтернативами и acceptance criteria.
- Если пользователь дал готовый план, утвердил план или попросил `IMPLEMENT THIS PLAN`, этот план становится контрактом задачи. Цель агента - максимально точное приближение к плану; тесты и compile-проверки подтверждают результат, но не заменяют соответствие плану.
- Для утвержденного плана действует один порядок:
  1. read-only discovery по scope, entrypoints, include graph, callsites, data flow и side effects;
  2. planning-mutation: обновить или явно подтвердить `PLAN/TODO/DECISIONS/EVIDENCE` как контракт;
  3. read-only plan-mapping challenge;
  4. implementation-mutation только по утвержденному контракту;
  5. old-path audit, diff-level evidence и синхронизация task-state;
  6. verification checks и финальный ответ.
- Контракт задачи обязателен до implementation-правок любого размера, даже если изменение кажется маленьким hotfix:
  - `PLAN.md`: цель, границы, entrypoints, expected new paths, forbidden old paths.
  - `TODO.md`: compact contract table с `MUST`, `KEEP`, `REJECT`, `CHECK`; каждый пункт связан с файлами/proc/контрактом или помечен как blocked.
  - `DECISIONS.md`: только реальные отклонения/tradeoff, которые меняют исходный план; нельзя молча заменять rewrite на patch.
  - `EVIDENCE.md`: evidence по соответствию плану, включая entrypoint/call path, old path audit, `rg`-проверки и незакрытые пункты.
- `Plan mapping challenge` обязателен перед реализацией утвержденного плана:
  - основной агент сначала раскладывает план на `MUST/KEEP/REJECT/CHECK`, expected new paths, forbidden old paths и forbidden substitutions.
  - read-only subagent/reviewer используется только если пользователь явно попросил или разрешил subagents и это не запрещено текущими инструкциями; он независимо проверяет маппинг через `rg`, entrypoints, include graph, callsites и data flow.
  - если subagent/reviewer недоступен или не разрешен, основной агент обязан выполнить отдельный self-challenge pass и записать его как evidence.
  - challenge ищет пропущенные пункты плана, старые production-reachable/callable paths, несогласованные compatibility/fallback/hotfix решения и случаи, где patch/wrapper подменяет rewrite/remove/replace.
  - результат challenge записывается в `EVIDENCE.md` до реализации: `PASS`, `PASS WITH RISKS`, или `BLOCKED`.
  - `PASS WITH RISKS` разрешает реализацию только если риски не меняют `MUST/KEEP/REJECT` и не требуют отклонения от утвержденного плана; иначе это `BLOCKED`.
  - при `BLOCKED` нельзя начинать альтернативную реализацию без исправления контракта или явного согласия пользователя.
- `Forbidden substitutions` должны быть явно перечислены в `TODO.md`. Они не закрывают rewrite/remove/replace без явного согласия пользователя:
  - wrapper вокруг старого ядра вместо переписи;
  - budget/guard/validation вокруг старой логики вместо удаления опасного пути;
  - fallback/compat/config-gated path, который оставляет старое ядро production-reachable или callable;
  - test-only closure без diff-level evidence;
  - перенос логики в путь, не утвержденный планом;
  - мелкий hotfix вместо требуемой архитектурной замены.
- `Old path audit` обязателен для rewrite/remove/replace/core-behavior планов. В `TODO.md` нужно перечислить старые proc/type/include/callsites, ожидаемый статус (`removed`, `not production-reachable`, `not callable`, `compat only with user approval`, `blocked`) и команду/evidence для проверки. В `EVIDENCE.md` нужно записать итоговый результат аудита.
- Rewrite/remove/replace триггеры включают русские и английские формулировки: `переписать`, `заменить`, `удалить`, `полностью`, `ядро`, `rewrite`, `replace`, `remove`, `delete`, `fully`, `migrate`, `move`, `drop`, `retire`, `replace all usages`, `bounded pipeline`. Для таких пунктов старое ядро считается недоверенным, пока не доказано обратное через old path audit.
- `Blocked` не является разрешением на fallback. Если `MUST`, `KEEP` или `REJECT` заблокирован, финальный статус задачи не может быть `DONE`; если блокер меняет утвержденный план, нужно остановиться, записать evidence, предложить варианты и получить явное согласие пользователя перед alternate path.
- Нельзя закрывать `MUST`, `KEEP` или `REJECT` только тестом. Нужен diff-level evidence: удаленный proc/type/include, новый call path, измененный entrypoint, сохраненный API/metadata contract, `rg`-проверка forbidden path или явная blocked reason. `CHECK` закрывает verification, но не заменяет Plan Fidelity.
- Перед финальным ответом нужно синхронизировать `TODO.md`, `DECISIONS.md` и `EVIDENCE.md`, затем обновить в `EVIDENCE.md` финальную `Plan fidelity matrix`:

| ID | Type | Requirement | Evidence | Status |
| --- | --- | --- | --- | --- |
| M1 | MUST | ... | diff/rg/check или blocked reason | DONE/PARTIAL/BLOCKED/DEVIATED |

- Для nontrivial изменений сначала формировать decision-complete plan с рисками, альтернативами и acceptance criteria.
- Финальный ответ для задач по готовому плану обязан содержать `Plan fidelity` и совпадать с matrix из `EVIDENCE.md`. Перечислить все `PARTIAL`, `BLOCKED`, `DEVIATED`; нельзя писать `done/implemented`, если хотя бы один `MUST`, `KEEP` или `REJECT` не имеет статуса `DONE`.
- Перед правками апстрима проверить, нельзя ли закрыть задачу через `modular/**`. Эта проверка не отменяет явно утвержденный пользователем путь; если modular-first противоречит плану, записать это в `DECISIONS.md` и запросить согласие перед отклонением.
- При выборе между вариантами реализации предпочитать минимальное вмешательство: сначала искать modular injector, hook, adapter или другую точку инъекции, а не переписывать существующий upstream proc.
- В `code/**` и других upstream-путях по возможности добавлять только минимальные proc/entrypoint для модульной инъекции; переписывание существующих proc допустимо только когда иначе задача не закрывается без еще более инвазивного diff.
- При изменении upstream и согласованных config surfaces учитывать требования `SS220 EDIT` из [`../../__docs/SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md).
- Existing `SS220 EDIT` в `modular/**` считать legacy markers и не использовать их как precedent для новых правок.
- `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` считать локальным task-state. Они могут обновляться во время работы, но перед коммитом и PR должны быть возвращены к baseline и не входить в публикуемый diff, если пользователь отдельно не запросил иное.

## Минимальные проверки по типам задач
Проверки не должны съедать усилия, если пользователь явно просит приоритет на реализации плана. В таких задачах сначала закрыть `MUST/KEEP/REJECT` контракт и только потом выполнять минимально достаточные проверки. Verification status ведется отдельно от Plan Fidelity: непройденная или незапущенная проверка не превращает незакрытый пункт плана в `DONE` и не отменяет diff-level evidence.

1. Docs-only:
   - проверить ссылки;
   - проверить UTF-8 и отсутствие mojibake;
   - `git diff --check`.
2. DM/code changes:
   - `BUILD.cmd`
   - или `tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror`
2a. Runtime/performance-sensitive DM changes:
   - выполнить обычную DM-сборку;
   - добавить или обновить focused unit/runtime test, если баг связан с циклом, preview, planner, pathfinding, flood-fill, cache или apply;
   - compile-only не считается достаточной проверкой для runtime freeze;
   - для fixed runaway bugs тест должен проверять bounded behavior, а не только отсутствие compile errors.
3. Lint/CI-equivalent checks:
   - `tools/build/build --ci lint tgui-test`
   - `tools/bootstrap/python -m tools.maplint.source --github`
   - `tools/bootstrap/python -m dmi.test`
   - `tools/bootstrap/python -m mapmerge2.dmm_test`
4. Map-sensitive work:
   - `tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_BASE`
   - `tools/build/build --ci dm -DCIBUILDING -DCITESTING -DALL_MAPS -DALL_MAPS_STAGE_EXTRA`
5. Unit-test behavior:
   - сверяться с `code/modules/unit_tests/README.md`
   - при необходимости использовать CI-путь из `.github/workflows/run_unit_tests.yml`
   - не запускать полный `tools/build/build --ci dm-test` на каждую локальную итерацию; для быстрого цикла сначала использовать `tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror` и только релевантные дополнительные проверки
   - для точечной локальной отладки unit tests допустим временный `TEST_FOCUS(...)` или эквивалентный локальный focus-only подход, но он не должен оставаться в коммите или финальном diff
   - полный `dm-test` ожидается для runtime behavior, покрываемого unit tests, когда это укладывается в приоритет задачи и локально исполнимо; если пользователь явно просит не тратить усилия на тесты, runner заблокирован или targeted checks достаточно закрывают риск, явно фиксировать Verification status и причину без подмены Plan Fidelity
   - если `dm-test` был прерван или aborted, нельзя считать его результат валидным; в отчете нужно явно помечать прогон как незавершенный и при необходимости проверять/останавливать оставшиеся `DreamDaemon` процессы

## Кодировка
- Все правки и новые документы держать в UTF-8.
- Нельзя оставлять mojibake (`Р...`, `�`, `????`) в коде и документации.
- Русскоязычные документы должны оставаться читаемыми в обычном UTF-8 просмотре.
