# Human AI settings panel

Battle controls include directional weapon scatter (0–3, fractional values allowed, default1; client-controlled shooters and intrinsic pellet patterns unchanged) and ally combat spacing (default OFF in all presets). Spacing gates both local separation and cover crowding rejection, independently of retreat and grenade escape. Save format v6 imports v1–5, preserving existing values and adding missing controls.

## Преследование

Separate category and module directory `../pursuit/`: visual memory/reporting, bounded search, and replacement chase action. The master switch controls lost-contact search, not visible combat. Search uses only last observed position/heading/time, at most eight extra points within six tiles; blocked goals have a four-second no-progress limit. Native navigation handles doors and directed barricades, without forced movement.

| Difficulty | Time | Radius | Extra points | Heading | Reports | Squad roles |
|---|---|---|---|---|---|---|
| Easy | 3 s | 2 | 1 | off | off | off |
| Medium | 7 s | 3 | 3 | on | on | off |
| Hard | 12 s | 5 | 5 | on | on | on |

All presets enable pursuit, cautious movement (0.5-second pause), and return. Local one-hop reports require the same squad/faction and level, default range7; scan at most16 squad entries once per second. Reports never assign a shooting target or relay hidden coordinates. Squad roles are scout, stationary covering observer, and lateral approach followed by the last seen point; a flank is an attempted physical route, not guaranteed encirclement. Door/corner pauses occur once per tile during search and do not delay grenade escape. Completion releases combat state for the retained order; without an order, return to the search origin is capped at10 seconds. Master off or Hold cancels search; changing the order supersedes it. Defaults for new controls are applied to legacy saves; existing chase_time is retained.

Open **Game Master → HumanAI → Human AI Settings** (R_DEBUG required).

This directory owns the panel: `settings_panel.dm`, `HumanAISettings.tsx` and its local SWC configuration. TGUI contains only the interface export and dependency bridge. Runtime policy and persistence are in `../configuration`; combat, medicine, navigation and equipment consume the policy in their own subsystems.

## Application

NPC setting edits are drafts. Difficulty and slot loading never apply automatically. Settings are global only: no individual NPC selection, override API or reset-exceptions action exists. Applying displays a confirmation and rechecks authorization and global revision after the dialog. Application affects living current and future NPCs. Dead NPCs keep their snapshots; revival adopts the latest globals on the first living process tick.

«Применить настройки» confirms and applies the draft. «Показать текущие настройки с сервера» replaces the draft with the active global profile without changing NPC behavior. Its question-mark tooltip explains draft loss. Every numeric control has a question-mark tooltip with semantics, units and valid bounds. Personal slots store full global profiles, never NPC references.

## Диагностика нагрузки

Подробная инструкция, поля CSV и ограничения замеров: [PERFORMANCE_DIAGNOSTICS.md](../__docs/PERFORMANCE_DIAGNOSTICS.md).

Во вкладке «Диагностика» кнопка «Диагностика нагрузки: Вкл/Выкл» сразу переключает сбор для всего сервера; «Применить настройки» не требуется. Доступ проверяется по владельцу панели и R_DEBUG, во время другого подтверждения кнопка заблокирована. Переключение не меняет черновик, ревизию профиля или поведение NPC. Фактические изменения состояния записываются в административный журнал и сообщаются администраторам.

По умолчанию сбор выключен после каждого запуска. Он не входит в пресеты сложности, личные слоты и сохранённые настройки сервера. При включении начинается новый сеанс; путь к отдельному CSV и возможная ошибка записи показываются здесь же. Раз в 10 секунд сохраняются агрегированные измерения, при выключении — остаток окна. Подробные условия нагрузочного прогона: [PERFORMANCE_AUDIT.md](../__docs/PERFORMANCE_AUDIT.md).

Измеряется только синхронное выполнение; стоимость включает вложенные вызовы, поэтому пересекающиеся строки нельзя складывать или трактовать как проценты общего CPU. Продолжения лечения и бросков после ожиданий, а также общая обработка снарядов сюда не входят. Сама диагностика добавляет некоторую нагрузку, поэтому включать её следует на время измерения.

## Persistence

Each admin ckey has exactly three slots in `data/player_saves/<initial>/<ckey>/human_ai_settings.sav`. Names accept Cyrillic/Latin letters, digits and spaces, up to 40 characters. Save/overwrite, rename and delete require confirmation. Schema version 2 introduced grenade_chance and stealth_enabled; version 3 adds the controls below. Older profiles retain existing values and acquire defaults for newly introduced fields; arbitrary partial or malformed profiles are rejected.

Global changes normally last for this server process. «Сохранить для сервера после перезапуска» persists the currently applied global profile to `data/human_ai_settings.sav`; it does not apply/save a draft. Built-in profiles do not occupy personal slots. Version 3 adds health_percent (100), grenade_safety and throwback_safety (both on) to older profiles without losing their values.

## Safety and semantics

«Шанс броска гранаты, %»: 0–100, default 100 to preserve prior behavior. Uses the existing single cached roll per combat encounter for hand grenades/underbarrel launcher. Changes do not reroll a decided encounter. Emergency throwback is separate and all safety gates remain.

«Стелс для ИИ» defaults on: initial acquisition ignores three rear-facing directions. Switching off removes only this rear blind spot; normal view range, walls and faction checks remain. Already acquired targets and explicit aggression responses are unchanged.

| Preset | Reaction | Accuracy multiplier | Burst cap / pause | Lost-target chase | Grenades / launcher / throwback | Ally treatment / drugs |
|---|---|---|---|---|---|---|
| Easy | 1.2 s | 0.65 | 3 / 2 s | 3 s | off / off / off | off / off |
| Medium | 0.7 s | 0.85 | 6 / 1 s | 7 s | on / on / off | on / on |
| Hard | 0.3 s | 1.0 | 8 / 0.5 s | 12 s | on / on / on | on / on |

All presets allow self-care, self synthetic repair, doors, prying and climbing. Easy forbids destruction, ally synthetic repair, tactical weapon switching and proactive reload. All retain escape from live grenades, protected objects and low-health retreat. Medium is the initial profile when no valid server default exists.

Settings do not give an unequipped NPC medical supplies or tools. Protected destruction, physics, firearm friendly-fire checks, overdose checks and live grenade escape remain mandatory. Grenade friendly safety can be disabled independently for offensive throws (including launcher) and throwbacks. Self-distance, trajectory/range and fuse checks remain. Disabling throwback still permits escape. A committed throw is allowed to finish.

Health is 10–300% of species base capacity, default100, without modifying the shared species or healing existing injuries. Lowering capacity can kill an injured NPC. It does not scale limb integrity or prevent organ-loss death. Accuracy supports 0.3–3 times the weapon's accuracy, not a guaranteed hit probability.

Live grenades are picked up only within two tiles with sufficient fuse time. Otherwise NPCs seek a reachable position at least five tiles away. Offensive landing targets must be on or within one tile of the hostile; an out-of-range enemy no longer causes a wasted short throw. Combat spacing seeks two-tile separation from allied NPCs with local physical steps; tight terrain and hold boundaries can prevent full spacing.

Medical dose checks include patient-wide pending oral ingestion vessels as well as bloodstream levels. This covers multiple NPC medics and pills fed by players while absorption is delayed. It cannot prevent a player deliberately administering an unsafe later dose.

Reaction is a minimum firing delay after acquiring a new target, quantized by AI processing. Accuracy scales projectile accuracy rather than guaranteeing a hit percentage. Weapon-specific burst limits still apply. Easy cover prefers the nearest positively scored safe tile; medium uses the existing score; hard rescores when hit inside cover. Tactical range adds spacing against a visible human without a firearm in their active hand. Low-health spacing, not teleportation, implements retreat. Follow distance adds to the existing squad formation distance. Hold radius adds a restriction to the issued boundary; live grenade escape can temporarily leave it. Path retry threshold increases the existing failure backoff rather than forcing a path through scenery.

Medicine always retains threat and patient-safety checks. The out-of-combat option adds a stricter requirement. Proactive reload requires no combat, a detachable magazine below 25%, and a better compatible carried replacement. Runtime settings changes and server saves are logged in the admin log.
# Направленный поиск

Подход к последней позиции имеет отдельный предел 10 секунд. Время из настройки осмотра отсчитывается после фактического прибытия; общий предел — 10 секунд плюс настройка. Укрытие без текущей цели не блокирует допустимый поиск. Временная неудача шага сохраняет цель, но отсутствие продвижения 4 секунды завершает попытку (длительное штатное действие ожидается лишь в пределах общего срока). Прикрывающий NPC по-прежнему может оставаться на месте.

После последней замеченной позиции поиск продвигается по направлению движения цели (при выключенном прогнозировании — по направлению подхода NPC). Следующие точки выбираются с шагом до двух клеток, с боковыми вариантами под 45 градусов, в пределах заданного радиуса. Это не полный обыск комнат: NPC замечает доступных наблюдению врагов по пути. Несколько дверей подряд обрабатываются обычной навигацией и требуют доступного прохода. Недоступный маршрут пропускается; время и число точек ограничены. Прикрывающий участник группы сохраняет свою роль.
