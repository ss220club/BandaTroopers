# Lobby UI: точки интеграции и fallback

Этот файл описывает единственные разрешённые связи между модулем `modular/lobby_ui` и основным кодом. Он нужен для повторного внесения минимальных точек вызова после синхронизации с upstream.

## Как отключить модуль

Удалите или закомментируйте одну строку в `modular/modular.dme`:

```dm
#include "lobby_ui/_lobby_ui.dme"
```

После этого проект должен собираться, а игроки должны получать стандартное меню лобби, стандартное окно настроек персонажа, стандартную музыку входа и стандартные вспомогательные окна.

## Правило для внешнего кода

Вне `modular/lobby_ui` запрещены ссылки на `/datum/modpack/lobby_ui`, переменные `banda_*`, процедуры `banda_*`, стили и данные конкретной темы. Разрешены только нейтральные вызовы через `SSmodpacks?.lobby_ui_provider` или общие шлюзы `SSmodpacks.lobby_ui_choice()` и `SSmodpacks.lobby_ui_translate()`.

Каждая такая точка помечается комментарием:

```dm
// SS220 DemonicLynx "Lobby UI" - neutral provider hook; upstream behavior is the fallback.
```

Контракт провайдера находится в `modular/_modpack.dm`, регистрация и общие шлюзы — в `modular/_modpacks.dm`, реализация — в `modular/lobby_ui/_lobby_ui.dm`.

## Карта нейтральных точек вызова

| Файл вне модуля | Точка | Что предоставляет модуль | Стандартный fallback |
| --- | --- | --- | --- |
| `code/modules/mob/new_player/new_player.dm` | `new_player_panel()` | Новое меню лобби | Полный классический HTML лобби |
| `code/modules/mob/new_player/new_player.dm` | `Topic()` | Звук нажатия | Без дополнительного звука |
| `code/modules/mob/new_player/new_player.dm` | `ViewManifest()` | CRT-оформление стандартных данных манифеста | Исходное окно `Crew Manifest` |
| `code/modules/mob/new_player/new_player.dm` | `close_spawn_windows()` | Закрытие модульного окна | Закрытие стандартных окон |
| `code/game/sound.dm` | `client/playtitlemusic()` | Зацикленная музыка модуля | `SSticker.login_music` на стандартном канале лобби |
| `code/modules/client/preferences_savefile.dm` | загрузка/сохранение preferences | Настройки темы, цветов, подсветки и превью | Никаких дополнительных полей |
| `code/modules/mob/new_player/preferences_setup.dm` | `update_preview_icon()` | Модульное снаряжение превью | `arm_equipment()` upstream |
| `code/modules/client/preferences.dm` | `ShowChoices()` | Оболочка, содержимое и показ редактора | Полное стандартное окно Preferences |
| `code/modules/client/preferences.dm` | `SetChoices()` | Полная отрисовка терминального окна приоритетов должностей | Полное стандартное Job Preferences |
| `code/modules/client/preferences.dm` | `set_job_slots()` | Полная отрисовка терминального окна назначения слотов | Полное стандартное Job Assignment |
| `code/modules/client/preferences.dm` | `SetRecords()` | Оформление записей | Стандартное Set Records |
| `code/modules/client/preferences.dm` | `open_load_dialog()` | Терминальный каталог слотов | Исходный список `Load Character` |
| `code/modules/client/preferences.dm` | `process_link()` | Модульные действия ссылок | Стандартный switch обработчика |
| `code/modules/client/preferences.dm` | `SSmodpacks.lobby_ui_choice()` | Перевод английских prompt/title и отображаемых вариантов с сохранением канонических значений | Обычный английский `tgui_input_list()` |
| `code/modules/client/preferences.dm` | `SSmodpacks.lobby_ui_translate()` | Перевод отдельных английских prompt/title/labels | Исходный английский текст |
| `code/modules/client/preferences.dm` | `SSmodpacks.lobby_ui_text()` / `lobby_ui_number()` | Локализованные CRT-поля имени, метки слота, возраста, metadata и религии | Обычные `tgui_input_text()` / `tgui_input_number()` |
| `code/modules/tgui_input/text.dm`, `code/modules/tgui/tgui_number_input.dm`, `code/modules/tgui/tgui_input_list.dm` | необязательные `theme` и `presentation` | Передача нейтральных цветов/эффектов окну | `null`, стандартная тема TGUI |
| `tgui/packages/tgui/interfaces/*Input*`, `layouts/Window.tsx`, `styles/interfaces/TerminalInputPresentation.scss` | необязательное поле `presentation` | Применение точных accent/text цветов, glow и intensity без общего hue-фильтра | Стандартное оформление TGUI |
| `code/modules/client/flavor_text_editor.dm` | TGUI presentation/title | Тема и русские подписи редактора описания | Стандартная тема и заголовок |
| `code/modules/admin/tabs/event_tab.dm` | обновление Setup Event Info | Мгновенное обновление текста миссии | Никакого push-обновления классического меню |
| `tgui/packages/tgui/interfaces/FlavorTextEditor.tsx` | `custom_presentation` | Применение необязательного описания внешнего вида | Встроенные классические значения |
| `tgui/packages/tgui/styles/interfaces/FlavorTextEditor.scss` | класс `--custom` | Нейтральный контейнер для необязательной темы | Стандартные стили TGUI |
| `code/modules/client/tgui_macro.dm` | необязательный `lobby_ui_keybind_presentation()` | Тема и локализованный заголовок окна назначения клавиш | Исходный `Keybind Preference` и стандартные данные |
| `tgui/packages/tgui/interfaces/KeyBinds.jsx`, `styles/interfaces/TerminalInputPresentation.scss` | `custom_presentation`, класс `.BandaKeybinds` | Компактные терминальные строки, поиск и фильтр | Исходное окно 400x500 и стандартное оформление |
| `interface/skin.dmf` | `lobbybrowser`, `preferencebrowser`, `preferencewindow`, `mainwindow.split.saved-params` | Нейтральные browser-host поверхности и штатное сохранение ручной ширины | Они скрыты и не меняют классический интерфейс |

## Повторное внесение после upstream

1. Найдите перечисленные процедуры в актуальном upstream.
2. Внесите только короткий вызов провайдера и оставьте исходное тело процедуры полноценным fallback.
3. Не переносите HTML, русские строки, CSS, аудио-пути или состояние Lobby UI в основной код.
4. Добавьте маркер `SS220 DemonicLynx "Lobby UI"` непосредственно над вызовом.
5. Проверьте, что вне модуля отсутствуют прямые имена реализации:

```powershell
rg -n "datum/modpack/lobby_ui|banda_|uses_banda|get_banda|show_banda" code interface tgui
```

Допустимы только нейтральное поле `lobby_ui_provider`, методы контракта `lobby_ui_*`, generic TGUI payload `custom_presentation` и browser-host элементы из таблицы.

Полная терминальная разметка Job Preferences и Job Assignment находится в `modular/lobby_ui/code/shared/auxiliary_preferences.dm`. Таблица русских переводов диалогов персонажа находится в `modular/lobby_ui/code/shared/character_localization.dm`. В `preferences.dm` эти данные дублировать нельзя.

## Проверка отключаемости

Запустите локальный безопасный checker из корня репозитория:

```powershell
powershell -ExecutionPolicy Bypass -File modular/lobby_ui/tools/check_modularity.ps1
```

Он выполняет static audit, DM-сборку с модулем и DM-сборку без него. Перед временным отключением сохраняются точные байты `modular/modular.dme`; восстановление выполняется в `finally` и подтверждается SHA-256. Скрипт отказывается работать, если точная include-строка отсутствует или встречается больше одного раза, и не изменяет include других модулей.

DreamMaker напрямую для этой проверки не используется.

## Готовые фрагменты для повторного внесения

Номера строк ниже соответствуют рабочему дереву `C:\BandaTroopers_LYNX` на **14 октября 2026 года**. После синхронизации с upstream они могут сместиться. Главный ориентир — путь, имя процедуры/элемента и соседний стандартный код. Вставки не должны удалять стандартное тело: оно остаётся fallback при отключённом модуле.

### 1. Подключение и нейтральный контракт

`modular/modular.dme:17`, рядом с include остальных модулей:

```dm
#include "lobby_ui/_lobby_ui.dme"
```

Это единственная строка, включающая реализацию. Нейтральные точки ниже обязаны компилироваться без неё.

`modular/_modpack.dm:19–98`, после стандартных lifecycle-процедур `/datum/modpack`:

```dm
// SS220 DemonicLynx "Lobby UI" - neutral optional provider contract; null/no-op behavior keeps the upstream classic interface.
/datum/modpack/proc/lobby_ui_show_lobby(mob/new_player/player, refresh = FALSE)
	return FALSE

/datum/modpack/proc/lobby_ui_hide(mob/user)
	return

/datum/modpack/proc/lobby_ui_play_click(mob/new_player/player)
	return

/datum/modpack/proc/lobby_ui_play_title_music(client/player_client)
	return FALSE

/datum/modpack/proc/lobby_ui_show_manifest(mob/new_player/player, manifest_html)
	return FALSE

/datum/modpack/proc/lobby_ui_load_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_save_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_refresh_event_panels(datum/custom_event_info/event_info)
	return

/datum/modpack/proc/lobby_ui_equip_character_preview(datum/preferences/preferences, mob/living/carbon/human/preview_dummy, datum/job/job)
	return FALSE

/datum/modpack/proc/lobby_ui_flavor_text_presentation(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_flavor_text_window_title(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_uses_custom_character_editor(datum/preferences/preferences)
	return FALSE

/datum/modpack/proc/lobby_ui_character_header(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_character_footer(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_show_character_editor(datum/preferences/preferences, mob/user, html)
	return FALSE

/datum/modpack/proc/lobby_ui_character_equipment_controls(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_interface_controls(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_show_job_preferences(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_job_slots(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_records(datum/preferences/preferences, mob/user)
	return FALSE

/datum/modpack/proc/lobby_ui_show_load_dialog(datum/preferences/preferences, mob/user)
	return FALSE

/datum/modpack/proc/lobby_ui_handle_preferences_topic(datum/preferences/preferences, mob/user, list/href_list)
	return FALSE

/datum/modpack/proc/lobby_ui_localized_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	return tgui_input_list(user, prompt, title, options)

/datum/modpack/proc/lobby_ui_translate_text(datum/preferences/preferences, text)
	return text

/datum/modpack/proc/lobby_ui_text_input(datum/preferences/preferences, mob/user, prompt, title, default_value, max_length = MAX_MESSAGE_LEN, multiline = FALSE)
	return tgui_input_text(user, prompt, title, default_value, max_length, multiline)

/datum/modpack/proc/lobby_ui_number_input(datum/preferences/preferences, mob/user, prompt, title, default_value, max_value, min_value)
	return tgui_input_number(user, prompt, title, default_value, max_value, min_value)
```

`modular/_modpacks.dm:8–40`, поле добавить внутри `SUBSYSTEM_DEF(modpacks)` после `loaded_modpacks`, процедуры — перед `Initialize()`:

```dm
	// SS220 DemonicLynx "Lobby UI" - neutral optional provider registration; null preserves all standard fallbacks.
	/// Optional provider for lobby and character-preferences presentation.
	var/datum/modpack/lobby_ui_provider

/datum/controller/subsystem/modpacks/proc/register_lobby_ui_provider(datum/modpack/provider)
	if(!provider)
		return "Lobby UI provider is null"
	if(lobby_ui_provider && lobby_ui_provider != provider)
		return "Lobby UI provider is already registered by [lobby_ui_provider.name]"
	lobby_ui_provider = provider
	return null

/datum/controller/subsystem/modpacks/proc/lobby_ui_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	// SS220 DemonicLynx "Lobby UI" - neutral localization gateway; the standard input list is the fallback.
	if(lobby_ui_provider)
		return lobby_ui_provider.lobby_ui_localized_choice(preferences, user, prompt, title, options)
	return tgui_input_list(user, prompt, title, options)

/datum/controller/subsystem/modpacks/proc/lobby_ui_translate(datum/preferences/preferences, text)
	// SS220 DemonicLynx "Lobby UI" - neutral translation gateway; unchanged text is the fallback.
	return lobby_ui_provider?.lobby_ui_translate_text(preferences, text) || text
```

### 2. Меню лобби, музыка и закрытие окон

`code/game/sound.dm:260–267`, якорь `/client/proc/playtitlemusic()`. Вставить в начало, до проверки `SSticker?.login_music`:

```dm
/client/proc/playtitlemusic()
	// SS220 DemonicLynx "Lobby UI" - neutral provider hook; upstream music is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_play_title_music(src))
		return TRUE
	if(!SSticker?.login_music)
		return FALSE
```

`code/modules/mob/new_player/new_player.dm:32–38`, якорь `/mob/new_player/proc/new_player_panel_proc`, сразу после проверки `client`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider hook; complete classic lobby fallback follows.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_lobby(src, refresh))
		return
```

`new_player.dm:78–86`, якорь `/mob/new_player/Topic`, после проверки `client`, до стандартного `switch`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional click-feedback hook; classic fallback is silence.
	if(href_list["lobby_choice"])
		SSmodpacks?.lobby_ui_provider?.lobby_ui_play_click(src)
```

`new_player.dm:407–418`, якорь `/mob/new_player/proc/ViewManifest()`. Сначала получить стандартный HTML один раз, затем перед исходной разметкой окна добавить provider-вызов:

```dm
/mob/new_player/proc/ViewManifest()
	var/manifest_html = GLOB.data_core.get_manifest(FALSE, TRUE)
	// SS220 DemonicLynx "Lobby UI" - optional manifest renderer; the complete classic browser below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_manifest(src, manifest_html))
		return

	var/dat = "<html><body>"
	dat += "<h4><center>Crew Manifest:</center></h4>"
	dat += manifest_html

	show_browser(src, dat, "Crew Manifest", "manifest", width = 450, height = 750)
```

Модуль получает уже сформированный `manifest_html`; `code/datums/datacore.dm` менять не нужно. Это сохраняет единый источник данных и не затрагивает манифесты в других интерфейсах.

`new_player.dm:457–462`, якорь `/mob/proc/close_spawn_windows`, между закрытием стандартных окон и сбросом звука:

```dm
	close_browser(src, "latechoices")
	close_browser(src, "playersetup")
	// SS220 DemonicLynx "Lobby UI" - optional cleanup hook; standard windows are closed above.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_hide(src)
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = SOUND_CHANNEL_LOBBY)
```

### 3. Savefile, превью и Setup Event Info

Добавлен нейтральный метод `/datum/modpack/proc/lobby_ui_character_persisted(datum/preferences/preferences, action)` с пустым fallback. В `preferences_savefile.dm` он вызывается **только на успешном выходе** `load_character()` (action = `"reload"`) и `save_character()` (action = `"save"`, после `S.Unlock()`):

```dm
SSmodpacks?.lobby_ui_provider?.lobby_ui_character_persisted(src, "save")
```

Терминальный провайдер обновляет снимок сохранённого слота/уведомление; для classic сразу возвращается. Исходные записи savefile, валидация, ранние возвраты и конечные return не изменены. Не переносить уведомление до IO или в обработчик кнопки.


`code/modules/client/preferences_savefile.dm:297–298`, в конце загрузки стандартных preference-полей:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider load hook; null keeps classic defaults.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_load_preferences(src, S)
```

`preferences_savefile.dm:512–513`, в конце сохранения стандартных preference-полей:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider save hook; null requires no data.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_save_preferences(src, S)
```

`code/modules/mob/new_player/preferences_setup.dm:206–208`, после `preview_dummy.update_hair()`, вместо безусловного `arm_equipment()`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional preview provider; upstream equipment is the fallback.
	if(!SSmodpacks?.lobby_ui_provider?.lobby_ui_equip_character_preview(src, preview_dummy, J))
		arm_equipment(preview_dummy, J, FALSE, FALSE, owner, show_job_gear)
```

`code/modules/admin/tabs/event_tab.dm:38–39` и `:46–47`, после удаления и после обновления `custom_event_info`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional refresh hook; classic lobby needs no push update.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_refresh_event_panels(CEI)
```

### 4. Редактор персонажа и вспомогательные окна

Все точки находятся в `code/modules/client/preferences.dm`. Стандартная разметка после раннего provider-вызова не удаляется.

`ShowChoices():321–325`, сразу после проверки `user.client`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional character-shell provider; complete upstream header is the fallback.
	var/datum/modpack/lobby_ui_provider = SSmodpacks?.lobby_ui_provider
	var/custom_character_editor = lobby_ui_provider?.lobby_ui_uses_custom_character_editor(src)
	var/dat = lobby_ui_provider?.lobby_ui_character_header(src, user)
	if(isnull(dat))
		// Полный стандартный header/body upstream должен остаться внутри этого if.
```

`ShowChoices():429–431`, перед всем стандартным блоком `Marine Gear`:

```dm
			// SS220 DemonicLynx "Lobby UI" - optional complete equipment renderer; upstream controls are the fallback.
			var/custom_equipment_controls = lobby_ui_provider?.lobby_ui_character_equipment_controls(src, user)
			if(isnull(custom_equipment_controls))
				// Полный стандартный блок Marine Gear upstream остаётся здесь,
				// включая Personal Weapon, Underwear, Undershirt,
				// Backpack Type, Preferred Armor, Show Job Gear,
				// Background и Custom Loadout.
			else
				dat += custom_equipment_controls
```

Terminal provider полностью формирует этот блок. Поэтому он может не показывать отдельные classic-настройки, не удаляя их из стандартного fallback.

`ShowChoices():611–706`, в `MENU_SETTINGS`: провайдер может вернуть полную разметку вкладки. `null` означает, что нужно выполнить неизменённый стандартный блок целиком:

```dm
			// SS220 EDIT - START: optional complete Lobby UI settings renderer; the unchanged upstream block is the fallback.
			var/custom_interface_controls = lobby_ui_provider?.lobby_ui_interface_controls(src)
			if(!isnull(custom_interface_controls))
				dat += custom_interface_controls
			else
				// Полный стандартный Input/UI/Chat/Game/Gameplay блок остаётся здесь.
			// SS220 EDIT - END
```

Terminal provider возвращает только утверждённые группы и canonical href/proccall для каждого сохранённого пункта. Нельзя подменять этот контракт CSS-скрытием: отсутствующие пункты не должны попадать в terminal DOM. Classic provider/отключённый модуль возвращают `null` и получают полный upstream набор.

`ShowChoices():716–721`, вместо стандартного безусловного footer/show-browser хвоста:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional footer/display hooks; upstream browser is the fallback.
	dat += lobby_ui_provider?.lobby_ui_character_footer(src) || "</div></body>"
	if(!lobby_ui_provider?.lobby_ui_show_character_editor(src, user, dat))
		winshow(user, "preferencewindow", TRUE)
		show_browser(user, dat, "Preferences", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
		onclose(user, "preferencewindow", src)
```

`SetChoices():736–741`, после проверки `GLOB.RoleAuthority`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional complete window renderer; the unchanged classic window below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_job_preferences(src, user, limit, splitJobs, width, height))
		return
```

`set_job_slots():865–870`, после проверки `GLOB.RoleAuthority`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional complete window renderer; the unchanged classic window below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_job_slots(src, user, limit, splitJobs, width, height))
		return
```

`SetRecords():938–941`, в начале процедуры:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional records renderer; complete upstream records window is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_records(src, user))
		return
```

`process_link():1105–1109`, перед стандартным `switch(href_list["preference"])`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional action provider; upstream switch is the complete fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_handle_preferences_topic(src, user, href_list))
		return TRUE
```

#### Нейтральные шлюзы локализации

Вызовы `lobby_ui_translate()` сейчас находятся на строках `1708`, `1729`, `1776`, `1830`, `1943–1944`.

Вызовы `lobby_ui_choice()` — на строках `1438`, `1746`, `1751`, `1757`, `1763`, `1769`, `1803`, `1811`, `1821`, `1843`, `1848`, `1853`, `1858`, `1865`, `1897`, `1912`, `1922`, `1934`, `1938`, `1950`, `1970`.

Шаблоны замены стандартных диалогов:

```dm
SSmodpacks.lobby_ui_translate(src, "Original upstream English text")

var/choice = SSmodpacks.lobby_ui_choice(
	src,
	user,
	"Original upstream English prompt",
	"Original upstream English title",
	canonical_options,
)
```

В core передаются только исходные английские строки и канонические значения. Русские подписи и обратное преобразование выбора хранятся в `modular/lobby_ui/code/shared/character_localization.dm`.

#### Нейтральные шлюзы текстового и числового ввода

Контракт расположен в `modular/_modpack.dm:92–98`, общие fallback-шлюзы — в `modular/_modpacks.dm:30–40`. Вызовы в `code/modules/client/preferences.dm` находятся на строках `1343`, `1353`, `1399`, `1406`, `1414`, `1422`, `1430`, `1444`, `1695`, `1701` и `1955`. Они передают только исходные prompt/title/default и при отсутствии провайдера вызывают обычные TGUI-функции.

Для необязательных `theme` и `presentation` используются `code/modules/tgui_input/text.dm:20,89–101,145`, `code/modules/tgui/tgui_number_input.dm:19,104–115,169` и `code/modules/tgui/tgui_input_list.dm:33,125–137,194`. Presentation применяется общим helper-файлом `tgui/packages/tgui/interfaces/common/TerminalInputPresentation.ts`, а `Window.tsx:102` нейтрально принимает `className/style`. Подключение стилей находится в `tgui/packages/tgui/styles/main.scss:66`. Все новые аргументы необязательны: `null` обязан сохранять стандартный TGUI fallback.

Сохранение модульных настроек, включая `banda_show_combat_gear` и `banda_menu_interface`, выполняется только через существующие provider hooks `lobby_ui_load_preferences()` и `lobby_ui_save_preferences()`. Ключ хранится в общем preferences-savefile. Оба обработчика выбора интерфейса используют `set_and_save_banda_menu_interface()`: результат `save_preferences()` проверяется, при ошибке прежнее значение восстанавливается, а явный повторный выбор не пропускает сохранение и обновление лобби.

#### Каталог загрузки слота

`code/modules/client/preferences.dm:2442–2445`, в начале `/datum/preferences/proc/open_load_dialog()`:

```dm
/datum/preferences/proc/open_load_dialog(mob/user)
	// SS220 DemonicLynx "Lobby UI" - optional load-slot renderer; complete upstream slot list is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_load_dialog(src, user))
		return

	// Полное стандартное тело open_load_dialog() остаётся ниже без изменений.
```

Реализация каталога находится в `modular/lobby_ui/code/shared/slot_picker.dm`; она возвращает тот же canonical href `changeslot;num=...`. Если модуль отключён или провайдер вернул `FALSE`, выполняется исходный список `Load Character`.

#### Unicode-лимит имени и точные цветовые образцы

`code/modules/tgui_input/text.dm:160–163` проверяет пользовательский лимит через число символов, а не число байтов:

```dm
if(max_length)
	if(length_char(params["entry"]) > max_length) // SS220 DemonicLynx "Lobby UI" - Unicode character count preserves the advertised input limit.
		return FALSE
```

Это сохраняет все разрешённые `MAX_NAME_LEN` (28) кириллических символов. Последующая HTML-проверка остаётся отдельной и не должна снова ограничивать строку по числу байтов.

Точные RGB-образцы в `code/modules/client/preferences.dm` имеют нейтральный класс `banda-real-color`. Терминальная оболочка не использует общий `hue-rotate`; палитра применяется напрямую. Общее тонирование — отдельный полупрозрачный слой в `assets/terminal.css`, выключаемый классом `banda-glow-off`; образцы расположены выше декоративных слоёв и не требуют обратной компенсации. Класс не имеет эффекта при отключённом модуле. TGUI использует аналогичный слой только внутри `.BandaTerminalInput`, уже управляемый optional `presentation.glow`. Esc редактора и browse-диалогов обрабатывается в module-local `terminal.js` через существующие ссылки закрытия; стандартные TGUI-поля сохраняют собственную отмену по Esc. `FlavorTextEditor.tsx` только при наличии presentation вызывает тот же `backendSuspendStart`, что и штатная кнопка закрытия. Классическая ветка не получает новый обработчик.

### 5. Flavor Text Editor

`code/modules/client/flavor_text_editor.dm:9–12`, внутри `ui_data()` после создания `categories`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional presentation data; TGUI defaults remain classic.
	var/list/custom_presentation = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_presentation(prefs)
	if(custom_presentation)
		.["custom_presentation"] = custom_presentation
```

`flavor_text_editor.dm:24–26`, внутри `tgui_interact()`, вместо жёсткого заголовка:

```dm
		// SS220 DemonicLynx "Lobby UI" - optional title provider; upstream title is the fallback.
		var/window_title = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_window_title(user.client?.prefs) || "Flavor Text Editor"
		ui = new(user, src, "FlavorTextEditor", window_title)
```

`tgui/packages/tgui/interfaces/FlavorTextEditor.tsx:19–30`, добавить в `Data`:

```tsx
  custom_presentation?: {
    theme?: string;
    class_name?: string;
    save_label?: string;
    revert_label?: string;
    editor_title?: string;
    category_labels?: Record<string, string>;
    accent_color?: string;
    text_color?: string;
    glow_enabled?: boolean;
    effect_intensity?: 'full' | 'reduced' | 'off';
  };
```

`FlavorTextEditor.tsx:31–66`, получить payload и вычислить подписи:

```tsx
  // SS220 DemonicLynx "Lobby UI" - generic optional presentation payload; classic labels are the fallback.
  const { general, categories, custom_presentation: presentation } = data;

  const getCategoryLabel = (categoryName: string) =>
    presentation?.category_labels?.[categoryName] ||
    categoryName[0].toUpperCase() + categoryName.slice(1);
  const categoryLabel = getCategoryLabel(category);
  const editorTitle = presentation?.editor_title
    ? presentation.editor_title.replace('{category}', categoryLabel)
    : `Edit ${category} flavor text (Shift+Enter for new line)`;
```

Передать в `Window` тему `presentation?.theme || 'crtblue'`, в `Window.Content` класс `FlavorTextEditor ${presentation?.class_name || ''}`; вкладке — `getCategoryLabel(iterateCategory)`, Section — `editorTitle`, кнопкам — `presentation?.save_label || 'Save'` и `presentation?.revert_label || 'Revert'`.

`tgui/packages/tgui/styles/interfaces/FlavorTextEditor.scss` копируется целиком. Подключение в `tgui/packages/tgui/styles/main.scss:63–64`:

```scss
// SS220 DemonicLynx "Lobby UI" - generic optional FlavorTextEditor presentation styles.
@include meta.load-css('./interfaces/FlavorTextEditor.scss');
```

TGUI-мост остаётся вне DM-модуля, потому что TypeScript/SCSS собираются независимо от include в `modular.dme`. Для терминальной ветки в `custom_presentation` дополнительно передаются необязательные `accent_color`, `text_color`, `glow_enabled` и `effect_intensity`; `TerminalInputPresentation.ts` устанавливает их как CSS-переменные без `hue-rotate` всего окна. Все поля необязательны, поэтому стандартный редактор остаётся fallback.

### 6. Нейтральные BYOND browser-host элементы

Дополнение 16.10.2026: общий необязательный presentation также переносит `font_family` и `font_size`. `TerminalInputPresentation.ts`/SCSS применяют их только внутри `.BandaTerminalInput`; отсутствие payload оставляет классические окна без изменений. Тип `FlavorTextEditor.custom_presentation` содержит те же необязательные поля. Новый `tgui/packages/tgui/interfaces/LobbyTypography.tsx` — отдельное окно настроек с Dropdown и Slider, открываемое только module-local `/datum/banda_terminal_typography` из `code/shared/typography.dm`. Этот DM-файл включён только в `_lobby_ui.dme`; внешние provider hooks/savefile glue не расширены. Сохранение двух новых ключей идёт через существующий account-wide hook.

Главное терминальное меню использует module-local presentation offset `+3 px`, который добавляется после пользовательского масштаба одновременно к `font-size` и пиксельному `line-height`. `get_banda_terminal_styles("lobby")` передаёт один offset как в `lobby.css`, так и в загружаемый следом `terminal.css`; значение входит в ключ кеша. `/*banda-no-lobby-offset*/` оставляет подпись архива на пользовательском базовом масштабе. Для `.dossier-name` и `.data-row` используется `/*banda-no-lobby-offset-cap14*/`: он также ограничивает локальный масштаб значением настройки 14 px, чтобы 15–20 px не вытесняли нижние строки за footer. Базовые размеры информационной зоны уменьшены на 3 px до 13/17 px для имени и 11/13 px для строк; breakpoint `max-width: 900px` использует 11/14 и 9/11 px. Большой пользовательский текст не добавляет `.dossier-data { overflow-y: auto; }`, поэтому все девять строк остаются одновременно видимыми без вложенной прокрутки. Остальные sheet, TGUI payload, сохранённая настройка и Classic получают offset `0`.

Терминальный Settings-renderer заменяет ссылку на `/client/proc/toggle_admin_sound_types` двумя фиксированными module-owned preferences: `banda_admin_atmospheric_sounds` и `banda_admin_meme_sounds`. Provider сопоставляет их только с `SOUND_ADMIN_ATMOSPHERIC`/`SOUND_ADMIN_MEME`, переключает уже существующий `toggles_sound`, сохраняет preferences и повторно открывает текущий редактор. Raw bit из href не принимается. Upstream proc и Classic UI не меняются.

`uses_banda_terminal_decorative_effects()` возвращает true только для `full`, поэтому серверные intro/typewriter/sound callbacks и портретная помеха не запускаются в `reduced`/`off`. CSS режим `reduced` глобально останавливает анимации и переходы на каждой терминальной поверхности, после чего явно возвращает только корневую scan-полосу и переход `.prefs-focus-shade`. Режим `off` также скрывает CRT-overlay и блокирует установку hover-focus в `terminal.js`. Функциональные строки загрузки/манифеста принудительно остаются видимыми при остановленной анимации.

`interface/skin.dmf:239–249`, внутри основного окна:

```dmf
	// SS220 DemonicLynx "Lobby UI" - neutral hidden browser host; the classic lobby remains the fallback.
	elem "lobbybrowser"
		type = BROWSER
		pos = 0,0
		size = 640x480
		anchor1 = 0,0
		anchor2 = 100,100
		is-visible = false
		background-color = #020810
		saved-params = ""
	// SS220 DemonicLynx "Lobby UI" - end neutral lobby browser host.
```

`interface/skin.dmf:450–472`, внутри окна `preferences`, после его корневого `MAIN`:

```dmf
	// SS220 DemonicLynx "Lobby UI" - neutral hidden character-editor browser host; classic Preferences remains the fallback.
	elem "preferencebrowser"
		type = BROWSER
		pos = 0,0
		size = 0x0
		anchor1 = 0,0
		anchor2 = 100,100
		background-color = none
		saved-params = ""
	elem "preview"
		type = MAP
		pos = 0,-10
		size = 0x250
		anchor1 = 0,0
		anchor2 = 100,0
		is-visible = false
	// SS220 DemonicLynx "Lobby UI" - end neutral character-editor browser host.
```

### 7. Проверка после повторного портирования

```powershell
rg -n "lobby_ui_provider|lobby_ui_choice|lobby_ui_translate|custom_presentation|lobbybrowser|preferencebrowser" code modular interface tgui
```

Затем выполнить обе сборки через `BUILD.cmd`: сначала с include модуля, затем временно без него. Успех только первой сборки означает, что во внешнем коде осталась прямая зависимость от реализации или потерян стандартный fallback.
