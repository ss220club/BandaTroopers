# World Edit live design

## Цель
World Edit дает администраторам один in-game интерфейс для выбора live-генератора, редактирования inline-параметров, preview, apply и просмотра истории сессии. Точка входа TGUI-панели: `tgui/packages/tgui/interfaces/WorldEditPanel/index.tsx`.

## Current live surface
Панель показывает только ready-генераторы:
- `outpost_radius`
- `destruction_pack`
- `blueprint_stamp`
- `building_layout`

## Workflow
1. `Select` - выбор генератора из каталога.
2. `Parameters` - редактирование inline-полей через `get_ui_fields` и `set_ui_param`.
3. `Preview` - dry-run без мутаций карты.
4. `Apply` - применение подтвержденного плана.
5. `History` - session history с операциями и undo/cleanup-метаданными.

## UI contract
1. Живой UI строится только из `ui_fields`.
2. Поддерживаемые `kind`: `select`, `number`, `boolean`, `text`.
3. Метаданные поля: `description`, `validate_hint`, `group`, `placeholder`, `visible`, `disabled`, `required`, `min`, `max`, `step`, `options`.
4. Невалидные, скрытые или неподдерживаемые поля backend отбрасывает.
5. Для динамических каталогов используется `refresh_ui_state`.
6. Отдельного альтернативного пути настройки нет.

## Rights and safety
1. Открытие панели требует `R_DEBUG`.
2. Доступ к генератору определяется `required_rights` из registry.
3. Preview/apply и placement controls дополнительно блокируются backend-флагами, если генератор или состояние сессии не готовы.
4. Click-intercept должен освобождаться при остановке режима, сбросе генератора и закрытии панели.

## Logging and errors
1. Каждое `apply` пишет административный лог и `message_admins`.
2. `last_ui_error` показывает ошибки валидации или недоступные действия.
3. `preview_meta` и `last_changeset` используются как структурированный след для UI и history.

## Integration notes
1. Реестр live-генераторов должен оставаться компактным и явно ready-only для панели.
2. `outpost_radius`, `blueprint_stamp` и `building_layout` используют placement-aware flow.
3. `destruction_pack` остается destructive-профилем с явными ограничениями по безопасности и cleanup.
