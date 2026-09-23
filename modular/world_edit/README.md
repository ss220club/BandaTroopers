# World Edit Modpack

Модуль World Edit предоставляет live-only каркас для админских инструментов редактирования мира и генераторов структур.

## Основные правила
- В модуле нет исторических паспортов и старых контуров настройки.
- Новый код и документация живут только в `modular/world_edit/*`.
- Точка входа TGUI-панели: `tgui/packages/tgui/interfaces/WorldEditPanel/index.tsx`.
- Документация и комментарии в модуле ведутся на русском языке.

## Состав
- `_world_edit.dm`: регистрация модпака.
- `code/core/world_edit_types.dm`: базовые типы, контракты и результаты операций.
- `code/core/world_edit_logging.dm`: единый контракт audit-логов.
- `code/core/world_edit_registry.dm`: реестр live-генераторов и проверок доступа.
- `code/core/manager/lifecycle/*`, `state/*`, `runtime/*`, `session/*`, `ui/*`: менеджер сессии, runtime, интеграции и TGUI разложены по доменам ответственности.
- `code/generators/outpost_radius/*`, `destruction_pack/*`, `blueprint_stamp/*`, `building_layout/*`: live-генераторы сгруппированы по семействам, чтобы planner/runtime/ui split шел внутри своей папки.
- `code/generators/shared/world_edit_generator_shared_helpers.dm`: общие helper-процедуры генераторов.
- `code/effects/world_edit_persistent_fire.dm`: служебные эффекты модуля.

## Документация
- `docs/game_design.md`: live UX, права, guardrails, click-intercept.
- `docs/ui_field_schema.md`: inline UI-контракт генераторов.
- `docs/generator_document_template.md`: шаблон документации для live-генератора.

## Current ready surface
- `outpost_radius`
- `destruction_pack`
- `blueprint_stamp`
- `building_layout`
