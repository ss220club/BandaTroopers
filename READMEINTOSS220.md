# Colonial Marines Cryo Wake-up Intro System
## Система интро пробуждения из крио-капсулы для Space Station 13

Это полнофункциональная система показа кинематографичной заставки пробуждения из крио-капсулы при присоединении игрока к раунду в стиле **Colonial Marines**.

---

## 📋 Содержимое

Этот пакет включает:
1. **index.html** - Основной файл интро с веб-предпросмотром
2. **colonial_marine_intro.html** - Файл интро для интеграции в SS13
3. **preview.html** - Файл предпросмотра (идентичный index.html)
4. **colonial_marine_intro.dm** - DM-код для интеграции в SS13
5. **README.md** - это файл с инструкциями

---

## 🔧 Установка

### Шаг 1: Копирование файлов

#### DM-файл:
Скопируйте **colonial_marine_intro.dm** в один из этих каталогов:
```
code/modules/colonial_marines/colonial_marine_intro.dm
```

или, если вы не используете колониальные морпехи, в:
```
code/modules/intros/colonial_marine_intro.dm
```

или просто в:
```
code/__DEFINES/colonial_marine_intro.dm
```

#### HTML-файл:
Скопируйте **colonial_marine_intro.html** в:
```
html/colonial_marine_intro.html
```

**ВАЖНО:** Убедитесь, что путь `html/colonial_marine_intro.html` существует на вашем сервере. Если папка `html/` не существует, создайте её в корне вашего SS13-сервера.

### Шаг 2: Обновление файла `__DEFINES.dm`

Добавьте эти строки в файл:
```dml
code/__DEFINES/modes.dm
// или любой другой главный файл с определениями

#define SHOW_CRYO_INTRO 1  // Включить показ интро при входе
```

### Шаг 3: Интеграция с системой Login

Откройте файл с системой `Login()` (обычно `code/mob/login.dm` или похожий) и добавьте вызов интро:

```dml
/mob/living/carbon/human/Login()
	. = ..()
	
	// Показываем интро при входе
	if(SHOW_CRYO_INTRO)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, src), 1 SECOND)
```

### Шаг 4: Проверка путей

Убедитесь, что в файле `colonial_marine_intro.dm` путь к HTML-файлу совпадает с расположением файла:

```dml
var/html = file("html/colonial_marine_intro.html")
```

Если вы поместили файл в другое место, измените путь здесь.

---

## 📝 Настройка данных персонажа

### Автоматическая подстановка данных

По умолчанию система автоматически получает:
- **Звание** из переменной `military_rank`
- **Имя** из переменной `real_name`
- **Профессию/Роль** из переменной `job`

Если вы используете другие переменные, отредактируйте функцию `show_cryo_intro()` в `colonial_marine_intro.dm`:

```dml
/proc/show_cryo_intro(mob/living/carbon/human/player)
	if(!player || !player.client)
		return
	
	// Измените эти строки на свои переменные:
	var/rank = player.military_rank ? player.military_rank : "РЯДОВОЙ"
	var/name = player.real_name ? player.real_name : "НЕИЗВЕСТНО"
	var/squad = "АЛЬФА"  // Можно сделать динамическим
	var/role = player.job ? player.job : "БОЕЦ"
```

### Получение списка отряда

Функция автоматически собирает список всех активных игроков онлайн:

```dml
for(var/mob/living/carbon/human/other in world)
	if(other != player && other.client && other.stat != DEAD)
		// Добавляет товарищей в список
```

Если вы хотите получать товарищей из определённой команды/отряда, измените условие:

```dml
// Пример: получить только боевых товарищей
if(other != player && other.client && other.stat != DEAD && other.team == player.team)
```

---

## 🎮 Управление в интро

- **ESC** - перезагрузить заставку (для тестирования)
- **Ожидание** - заставка автоматически закроется через ~12 секунд

---

## 🔊 Звуки

Все звуки генерируются с помощью **Web Audio API**. Никакие внешние файлы звуков не требуются.

Доступные звуковые эффекты:
- **Boot Sound** - звук включения системы
- **Typing Sound** - звук печатания текста
- **Transition Sound** - звук переходов между экранами
- **Shutdown Sound** - звук выключения

Все звуки находятся в функциях в `<script>` секции HTML-файла.

---

## 🎨 Визуальная настройка

### Изменение цвета дисплея

Откройте `colonial_marine_intro.html` и найдите переменную в `<style>`:

```css
:root {
    --primary-color: #00ff41;  /* Основной цвет (зелёный) */
    --primary-rgb: 0, 255, 65; /* RGB компоненты */
    --monitor-glow: rgba(0, 255, 65, 0.2); /* Свечение */
}
```

Измените на нужный вам цвет, например:
- **Синий (Weyland)**: `#0099ff` с RGB `0, 153, 255`
- **Красный (Alert)**: `#ff0033` с RGB `255, 0, 51`
- **Жёлтый**: `#ffff00` с RGB `255, 255, 0`

### Изменение текста логотипа

Найдите элемент `.uscm-logo-ascii` и измените содержимое на свой ASCII-арт:

```html
<div class="uscm-logo-ascii" id="logo">
    ВАШ ЛОГОТИП ЗДЕСЬ
</div>
```

### Изменение скоростей печати

В функции `typeText()` измените параметр `speed`:

```javascript
// Быстрая печать (20ms между символами)
await typeText(element, text, 20);

// Медленная печать (60ms между символами)
await typeText(element, text, 60);
```

---

## 🐛 Решение проблем

### Проблема: Интро не показывается

**Решение:**
1. Проверьте, что файл `colonial_marine_intro.html` находится в папке `html/`
2. Убедитесь, что путь в `colonial_marine_intro.dm` совпадает с реальным расположением файла
3. Проверьте логи сервера на ошибки: `show_browser()` или `file()`

### Проблема: Данные персонажа не заполняются

**Решение:**
1. Проверьте имена переменных в функции `show_cryo_intro()`
2. Убедитесь, что переменные `military_rank`, `real_name`, `job` существуют в вашей версии SS13
3. Добавьте отладку:
```dml
to_chat(src, "Звание: [player.military_rank], Имя: [player.real_name], Роль: [player.job]")
```

### Проблема: Звуки не воспроизводятся

**Решение:**
1. Проверьте, что браузер поддерживает Web Audio API
2. Убедитесь, что у клиента не отключен звук в браузере
3. Проверьте консоль браузера (F12) на ошибки JavaScript

### Проблема: Интро не закрывается

**Решение:**
1. Убедитесь, что функция `closeIntro()` определена в SS13 коде или удалите вызов:
```javascript
// Закомментируйте эту строку, если функции нет:
// if(typeof closeIntro === 'function') { closeIntro(); }
```

---

## 📚 Структура файлов

```
SS13 Server Root/
├── code/
│   ├── modules/
│   │   ├── colonial_marines/
│   │   │   └── colonial_marine_intro.dm  ← Положить сюда
│   │   └── ...
│   └── ...
├── html/
│   └── colonial_marine_intro.html  ← Положить сюда
└── ...
```

---

## 🎯 Функции DM-кода

### `show_cryo_intro(mob/living/carbon/human/player)`
Основная функция, которая:
- Получает данные персонажа
- Собирает список отряда
- Отправляет интро окно клиенту

### `send_intro_window(json_data)` (клиентская функция)
Отправляет HTML интро браузеру игрока

### `location_is_cryopod(mob/living/M)`
Проверяет, находится ли моб в крио-капсуле

---

## 🔗 Дополнительные кастомизации

### Для рас/подвидов:

Если вы хотите показывать разные интро для разных рас, добавьте:

```dml
/proc/show_cryo_intro(mob/living/carbon/human/player)
	if(!player || !player.client)
		return
	
	// Выбираем интро по расе
	var/html_file = "html/colonial_marine_intro.html"
	if(player.species == NEOMORPH)
		html_file = "html/xeno_intro.html"
	
	var/html = file(html_file)
	if(!html)
		to_chat(player, "Ошибка: файл интро не найден!")
		return
	
	player.client.show_browser(player, html, "window=cryo_intro;border=0;can-close=false", "Cryo Wake-up")
```

### Для кастомных профессий:

Добавьте маппинг профессии → специальности:

```dml
var/list/job_to_specialty = list(
	"Marine Rifleman" = "СТРЕЛОК",
	"Marine Squad Leader" = "КОМАНДИР ОТРЯДА",
	"Marine Medic" = "ПОЛЕВОЙ САНИТАР",
	"Marine Engineer" = "ИНЖЕНЕР",
	// ... и так далее
)

var/role = job_to_specialty[player.job] ? job_to_specialty[player.job] : "БОЕЦ"
```

---

## 📞 Поддержка

Если у вас возникли проблемы:
1. Проверьте логи сервера
2. Прочитайте раздел "Решение проблем" выше
3. Убедитесь, что все пути файлов правильные
4. Проверьте консоль браузера (F12 → Console)

---

## 📄 Лицензия

Этот код предоставляется как есть для использования в пользовательских билдах Space Station 13.

**Версия:** 1.0  
**Последнее обновление:** 2026  
**Совместимость:** SS13 (TGMC, Paradise, TG fork и т.д.)
**Автор: Fifso**

---

## ✨ Благодарности

Создано в стиле оригинальной вселенной **Aliens/Colonial Marines** и современных интерпретаций.

Наслаждайтесь вашим билдом Colonial Marines!
