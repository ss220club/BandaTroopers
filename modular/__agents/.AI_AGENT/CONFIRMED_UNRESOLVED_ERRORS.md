# Подтвержденные нерешенные проблемы

Обновлено: 2026-05-13
Область: подтвержденные нерешенные проблемы, которые сохраняют диагностическую ценность для будущих сессий Codex в этом репозитории.

## Зачем нужен этот файл
- Долгоживущий реестр подтвержденных проблем, для которых корневая причина еще не устранена.
- Не заменяет `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` и сырые артефакты в `logs/`.

## Правила статусов
- `confirmed`: проблема наблюдалась и воспроизводится достаточно надежно для трекинга.
- `mitigated_only`: защита или обходной путь есть или был, но корневая причина все еще не исправлена.
- `unresolved`: валидированное исправление корневой причины еще не смержено.

## Правила включения
- Добавлять только проблемы с конкретным симптомом и понятной затронутой поверхностью.
- Сырые stack trace, длинные логи и временные артефакты расследования держать вне этого файла.
- Не добавлять спекулятивные или неподтвержденные гипотезы.

## Список проблем
### E-WEV-001
`симптом`: World Edit `building_layout` explicit `rectangle` cases can pass support check but fail during preview validation, for example `Required zone 'sleep_privacy' is not connected to the circulation graph.`
`статус`: `unresolved`
`поверхность`: `modular/world_edit/code/generators/building_layout`; observed through `tools/world_edit_visual/cases/building_living_rectangle_colony.json`.
`заметки`: Workbench correctly reports the failure as `status=error`, `stage=preview`; do not hide this with a visualizer fallback or alternate generator path.
`доказательства`: DreamDaemon Visual Workbench run on 2026-05-13 produced `data/world_edit_visual/out/building_living_rectangle_colony/report.json` with the above structured error after support accepted the request.
`следующий_шаг`: Fix or retune the production `building_layout` room/route validation for explicit rectangle footprints.

### E-WEV-002
`симптом`: World Edit `building_layout` point smoke cases for multiple archetypes can fail preview validation in the headless workbench before apply, for example living fails with `Required zone 'sanitation' is not connected to the circulation graph.`
`статус`: `unresolved`
`поверхность`: `modular/world_edit/code/generators/building_layout`; observed through generated point probe cases in the Visual Workbench runtime.
`заметки`: This blocks a green apply sample for the current Visual Workbench run, but the tool still exposes locked/error states, semantic exports, profiler stages, and renderer/index artifacts. Do not solve it in `tools/world_edit_visual` or by simulating generation.
`доказательства`: DreamDaemon Visual Workbench probe run on 2026-05-13 produced repeated preview-stage structured errors for point contexts, including living/sanitation and other archetype mandatory adjacency/pattern failures.
`следующий_шаг`: Investigate production `building_layout` candidate selection/validation and compare against existing unit-test assumptions.

### Шаблон записи
1. `E-###`
   `симптом`: `...`
   `статус`: `confirmed`, `unresolved`
   `поверхность`: `...`
   `заметки`: `...`
   `доказательства`: `logs/...` или ссылка на документ (опционально)
   `следующий_шаг`: `...` (опционально)

## Правила обновления
- Обновлять `Обновлено:` при каждом существенном изменении.
- Держать файл коротким и ориентированным на слой устойчивых правил, а не на task-state.
- После валидации исправления переносить запись в будущий раздел `Решенные проблемы`, когда такой раздел будет введен.
