# Workflow Rules

## Discovery first
- Перед анализом большой зоны кода сначала сузить область через `rg`.
- Базовый порядок:
  1. `rg` по именам типов, proc, define, map/config ключам и комментариям-маркерам.
  2. Проверка entrypoints, include graph, callsites и data flow.
  3. Поиск существующих extension points, signals и modular hooks.
  4. Только после этого план правок и точечное изменение файлов.
- Не читать крупные директории целиком, если задачу можно сузить выборочными запросами.
- Для задач в `modular/**` сначала проверять `colonialmarines.dme`, `modular/modular.dme`, relevant `_*.dme`, затем целевой модуль и его callsites.
- Для HALO port/sync/update задач до анализа кода открыть [`../../halo/__docs/HALO_PORT_STATE.md`](../../halo/__docs/HALO_PORT_STATE.md); pinned upstream commit из него считать каноническим baseline, пока этот документ не обновлен в той же задаче.
- Для правок в upstream сначала проверять, существует ли уже modular hook, adapter или modpack-level abstraction, через которые можно закрыть задачу.

## Read-only и mutating границы
- Read-only действия: поиск, чтение, diff, анализ include/call graph, dry-run проверки без изменения tracked файлов.
- Mutating действия: редактирование файлов, кодоген, formatters с rewrite, любые команды, целенаправленно меняющие репозиторный state.
- Не смешивать exploratory read-only шаги с реализацией без явного понимания границ задачи.

## Правила выполнения задач
- Сначала определить тип задачи: docs, DM-код, maps, tgui, build/CI или смешанный scope.
- Для nontrivial изменений сначала формировать decision-complete plan с рисками, альтернативами и acceptance criteria.
- Перед правками апстрима проверить, нельзя ли закрыть задачу через `modular/**`.
- При изменении upstream и согласованных config surfaces учитывать требования `SS220 EDIT` из [`../../__docs/SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md).
- Existing `SS220 EDIT` в `modular/**` считать legacy markers и не использовать их как precedent для новых правок.

## Минимальные проверки по типам задач
1. Docs-only:
   - проверить ссылки;
   - проверить UTF-8 и отсутствие mojibake;
   - `git diff --check`.
2. DM/code changes:
   - `BUILD.cmd`
   - или `tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror`
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

## Кодировка
- Все правки и новые документы держать в UTF-8.
- Нельзя оставлять mojibake (`Р...`, `�`, `????`) в коде и документации.
- Русскоязычные документы должны оставаться читаемыми в обычном UTF-8 просмотре.
