# RTO Support: карта документации

## Назначение

`RTO Support` больше не является проектной заготовкой. Модуль реализован и описывается набором отдельных документов по разным зонам ответственности.

Документация разделена, чтобы:

- не смешивать архитектуру, продуктовые правила, интерфейс и сопровождение;
- держать в явном виде реальные ограничения текущей реализации;
- соблюдать `SS220_DEVELOPMENT_RULES`, OOP и SOLID при дальнейшем развитии модуля.

## Текущий статус

На текущем этапе в модуле уже реализованы:

- runtime-контур контроллера RTO;
- выбор одного пресета через TGUI;
- action-кнопки для сектора наведения и способностей пакета;
- наведение только через отдельный `RTO binoculars`;
- серверная валидация сектора, LOS, потолков и кулдаунов;
- dispatch через свежие экземпляры `datum/fire_support`;
- модульная интеграция с loadout и шкафчиком RTO;
- документация по архитектуре, UI, балансу, player-flow и сопровождению.

Не реализованы:

- круговой world-overlay радиуса сектора;
- отдельные UI-экраны для расширенной аналитики кулдаунов;
- межфракционные вариации dispatch-слоя;
- автоматическое восстановление контроллера при экзотических сменах роли вне стандартного loadout-flow.

## Что читать

1. [RTO_SUPPORT_GAME_DESIGN.md](RTO_SUPPORT_GAME_DESIGN.md)
   Продуктовая модель роли и назначение стартовых пакетов.
2. [RTO_SUPPORT_PLAYER_GUIDE.md](RTO_SUPPORT_PLAYER_GUIDE.md)
   Короткая памятка для игрока: как реально пользоваться системой в раунде.
3. [RTO_SUPPORT_BALANCE.md](RTO_SUPPORT_BALANCE.md)
   Численные параметры пакетов, приоритеты тюнинга и балансные риски.
4. [RTO_SUPPORT_TECHNICAL_DESIGN.md](RTO_SUPPORT_TECHNICAL_DESIGN.md)
   Архитектура модуля, runtime-flow, контракты datums и точки интеграции.
5. [RTO_SUPPORT_INTERFACE_DESIGN.md](RTO_SUPPORT_INTERFACE_DESIGN.md)
   Реализованный интерфейс выбора пресета, состояние action-кнопок и binocular-flow.
6. [RTO_SUPPORT_MAINTENANCE.md](RTO_SUPPORT_MAINTENANCE.md)
   Правила расширения, анти-паттерны, checklist сопровождения и команды проверки.

## Краткий словарь

`RTO`
: `Radio Telephone Operator`.

`Пресет`
: один выбранный на жизнь моба набор поддержки.

`Сектор наведения`
: активная временная зона, внутри которой разрешены вызовы способностей.

`Armed mode`
: состояние контроллера, когда следующая цель должна быть получена через бинокль.

`Shared cooldown`
: общий кулдаун всех ударных способностей оператора.

`Personal cooldown`
: длинный кулдаун конкретной способности.

## Основные файлы реализации

- `modular/rto_support/code/controller/controller.dm`
- `modular/rto_support/code/actions/rto_actions.dm`
- `modular/rto_support/code/items/rto_binoculars.dm`
- `modular/rto_support/code/services/validation_service.dm`
- `modular/rto_support/code/services/dispatch_service.dm`
- `modular/rto_support/code/job/rto_integration.dm`
- `modular/rto_support/code/ui/preset_menu.dm`
- `tgui/packages/tgui/interfaces/RtoSupportPresetMenu.jsx`

## Базовые ограничения модуля

- Основная логика остаётся в `modular/rto_support/...`.
- Модуль не зависит от `GLOB.fire_support_points` и GM fire support menu.
- Текущий backend использует существующие `datum/fire_support` только как исполнительный слой.
- Один RTO имеет один контроллер, один выбранный пресет и один активный сектор одновременно.
