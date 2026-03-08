# RTO Support: сопровождение

## 1. Что важно не сломать

При любых изменениях сохранять следующие инварианты:

- RTO HUD остаётся `human_action`-based;
- controller владеет lifecycle action'ов;
- actions скрываются, если бинокль не в руке;
- `Координаты` и `Лазерная отметка` не получают cooldown;
- `Координаты` не рисуют лазер;
- `Лазерная отметка` остаётся live binocular laser, а не timed world marker;
- `visibility_zone_cooldown` и `shared support cooldown` не смешиваются в один UI-state;
- `RTO sling pouch` остаётся жёстко спаренным с одним биноклем.

## 2. Ключевые файлы

Runtime:

- `modular/rto_support/code/controller/controller.dm`
- `modular/rto_support/code/services/validation_service.dm`
- `modular/rto_support/code/services/dispatch_service.dm`

Интерфейс:

- `modular/rto_support/code/actions/rto_actions.dm`
- `modular/rto_support/code/items/rto_binoculars.dm`
- `modular/rto_support/code/ui/preset_menu.dm`

Выдача комплекта:

- `modular/rto_support/code/items/rto_sling_pouch.dm`
- `modular/rto_support/code/job/rto_integration.dm`

## 3. Как безопасно менять HUD

Если меняешь action-кнопки:

- не переводи их на `item_action` без отдельного архитектурного решения;
- не удаляй и не пересоздавай их на каждый hand swap;
- используй `hide_from()` / `unhide_from()`;
- не вычисляй cooldown UI вручную в action datum, если это уже делает controller state builder.

## 4. Как безопасно менять utility-режимы

Если меняется `Координаты` или `Лазерная отметка`:

- логика режима остаётся в controller;
- предмет отвечает только за реальное поведение бинокля и live overlay;
- utility-режимы не должны уходить в cooldown;
- отключение режима обязано снимать live marker без оставшегося мусора.

## 5. Как безопасно менять sling pouch

`RTO sling pouch` — это не generic storage pouch.

Не ломать:

- привязку `paired_pouch <-> paired_binocular`;
- запрет на чужие предметы;
- запрет на ручной unsling;
- возврат бинокля в pouch при drop flow.

Если меняется `drop_retrieval` или storage API, первым делом перепроверять именно этот комплект.

## 6. Как безопасно менять cooldown UI

Support button должен разделять:

- состояние сектора;
- общий cooldown пакета;
- личный cooldown способности.

Не допускается возвращать старое поведение, где:

- секторный recovery выглядит как общий cooldown способности;
- visibility action показывает cooldown support ability.

Если меняется UI-модель, менять сначала controller state builder, а не размазывать условия по action-классам.

## 7. Checklist после правок

1. Взять бинокль в руку: кнопки появились.
2. Убрать бинокль из рук: кнопки скрылись.
3. `Координаты` не создают лазер и не выключаются после одного клика.
4. `Лазерная отметка` не имеет cooldown и держит живой laser overlay.
5. `Logistics` не показывает кнопку сектора.
6. Visibility action не показывает shared cooldown поддержки.
7. Zone-based support actions показывают сектор и cooldown'ы раздельно.
8. Locker и equipped RTO получают `pouch + binocular`, а не loose binocular.
9. Старый tactical binocular не вернулся в locker flow.

## 8. Проверки сборки

Минимум:

1. `tools\build\build.bat dm`

Если были правки фронтенда:

2. `tools\build\build.bat tgui-eslint`
3. `tools\build\build.bat tgui`
