# Анализ проблем PR #99: послойная генерация зданий и интерьеров

ПР: [https://github.com/ss220club/BandaTroopers/pull/99](https://github.com/ss220club/BandaTroopers/pull/99)

Контекст:
По описанию и результатам визуализатора проблема не в «рандомности», а в архитектуре самого генератора. Сейчас система пытается строить помещения через локальные правила размещения тайлов/стен, но не имеет:

* топологии помещений;
* semantic layer (тип комнаты, назначение);
* структурного графа;
* правил интерьера;
* фаз генерации;
* post-processing проходов;
* constraints validation.

Из-за этого генерация создает:

* рваные стены;
* внутренние перегородки вместо комнат;
* "кишки" и лабиринты;
* пустые помещения;
* случайный мусор у стен;
* отсутствие композиции;
* отсутствие функциональных зон.

Текущая проблема не косметическая. Это фундаментальная ошибка уровня pipeline генерации.

---

# Главная проблема текущего подхода

Сейчас генератор, судя по результатам, работает примерно так:

1. Генерируется шум / маска.
2. Алгоритм пытается локально определить:

   * где пол;
   * где стены;
   * где пустота.
3. Затем идет попытка расставить объекты.

Это подход tile-first.

Но для генерации помещений нужен room-first.

Это критическая разница.

---

# Почему текущий подход ломается

## 1. Генератор не знает, что такое "комната"

Сейчас система видит:

* клетки;
* соседей;
* шум;
* вероятности.

Но она НЕ видит:

* границы помещения;
* объем комнаты;
* центр;
* проходы;
* назначение;
* связность.

Поэтому она строит:

* случайные стены;
* обрывы;
* "внутренние карманы";
* мусорные перегородки.

Пока генератор мыслит тайлами — нормальных помещений не будет.

---

## 2. Нет separation of concerns между этапами

Судя по результатам:

* геометрия;
* стены;
* двери;
* интерьер;
* декор;
* навигация;
* заполнение;

всё генерируется вперемешку.

Это приводит к каскадной деградации.

Например:

* интерьер ставится до финализации формы;
* стены меняются после размещения;
* проходы режут мебель;
* объект ставится у стены, которая потом исчезает.

В нормальном PCG pipeline этапы строго разделяются.

---

# Как это делается в нормальных procedural generation системах

Ни DRG, ни Rimworld, ни Dwarf Fortress, ни современные dungeon generators НЕ генерируют здания через "случайно ставим стены".

Они используют:

* graph-based generation;
* BSP;
* shape grammars;
* room graphs;
* cellular automata только как secondary pass;
* wave-function-collapse локально;
* semantic placement.

---

# Что конкретно сломано в вашей генерации

## Проблема №1: стены строятся из локальных правил

Сейчас, вероятно:

* если рядом пустота → ставим стену;
* если рядом пол → убираем стену.

Это НЕ создает комнаты.

Это создает noise contour.

Именно поэтому визуализатор показывает:

* рваные формы;
* псевдокоридоры;
* внутренние наросты;
* хаотичные выступы.

Такой подход годится:

* для cave generation;
* organic terrain;
* пещер;

но не для архитектуры.

---

# Почему DRG работает, а здесь нет

Deep Rock Galactic использует layered generation.

Но важно:

ОНИ НЕ СТРОЯТ КОМНАТЫ СРАЗУ ИЗ ШУМА.

У них:

1. Сначала:

   * крупные объемы;
   * primary caverns;
   * навигационный граф.

2. Потом:

   * corridors;
   * erosion;
   * smoothing.

3. Потом:

   * semantic tagging.

4. Потом:

   * biome decorators.

5. Потом:

   * gameplay passes.

6. Потом:

   * art passes.

У вас же сейчас:

noise -> стены -> мебель.

Это фундаментально недостаточно.

---

# Как должны строиться комнаты

# Правильная архитектура

## ЭТАП 1 — Layout Graph

Сначала генерируется НЕ карта.

Сначала генерируется GRAPH.

Например:

* Hub
* Storage
* Bedroom
* Technical
* Reactor
* Hallway
* Security

Каждая нода:

* тип;
* размер;
* shape profile;
* connection rules;
* density;
* interior preset.

Это основа.

Без graph layer procedural architecture почти всегда выглядит плохо.

---

## ЭТАП 2 — Room Shapes

Только теперь строятся формы комнат.

Причем:

НЕ через шум.

А через controlled generators.

Например:

### BSP

Классика.

Хорошо:

* для станций;
* баз;
* техногенных структур;
* SS13-like layouts.

Плюсы:

* прямые стены;
* контролируемые размеры;
* хорошие коридоры;
* легко валидировать.

Минусы:

* слишком прямоугольное.

---

### Voronoi partitioning

Хорошо:

* для органических комплексов;
* пещерных баз;
* alien structures.

---

### Shape Grammar

Лучший вариант для архитектуры.

Комната описывается правилами:

* вход;
* рабочая зона;
* perimeter;
* obstacle rules;
* center reserve.

Тогда помещение выглядит "спроектированным".

---

### Hybrid BSP + Shape Grammar

Это вероятно лучший вариант для проекта.

Сначала:

* BSP разбивает объем.

Потом:

* grammar deform pass.

В итоге:

* структура остается читаемой;
* комнаты не квадратные;
* архитектура остается логичной.

---

# Как строить стены правильно

# Главная ошибка текущего алгоритма

Сейчас стены, вероятно, являются primary object.

Но:

СТЕНЫ НЕ ДОЛЖНЫ ГЕНЕРИРОВАТЬСЯ.

ОНИ ДОЛЖНЫ ВЫВОДИТЬСЯ.

Это ключевая идея.

---

# Правильный подход

## Сначала строится:

* volume;
* floor mask;
* room region.

## Потом:

стена = граница между:

* walkable;
* non-walkable.

То есть:

wall(x,y) = floor рядом + empty рядом.

Но:

после того как shape finalized.

Не во время.

---

# Что это решает

Тогда исчезают:

* внутренние мусорные стены;
* случайные выступы;
* broken corners;
* wall acne;
* микро-карманы.

Потому что стена — derivative geometry.

А не primary geometry.

---

# Необходимые post-process passes

Без них procedural architecture всегда выглядит ужасно.

Нужны:

---

## 1. Dead-end cleanup

Удаляет:

* тупики;
* микро-карманы;
* одиночные клетки;
* wall spikes.

---

## 2. Room simplification

Убирает:

* зубчатость;
* диагональные мусорные переходы;
* лишние углы.

---

## 3. Corridor normalization

Коридоры должны:

* иметь минимальную ширину;
* не ломаться;
* не иметь случайных стен.

---

## 4. Connectivity validation

ВСЕ комнаты должны быть:

* достижимы;
* связаны;
* валидированы flood-fill.

---

## 5. Shape scoring

Комната оценивается:

* convexity;
* perimeter complexity;
* usable area;
* navigation quality.

Плохие комнаты:

* перегенерируются.

Это очень важный момент.

Большинство хороших PCG систем:

НЕ ПРИНИМАЮТ ПЕРВЫЙ РЕЗУЛЬТАТ.

Они:

* оценивают;
* отбрасывают;
* пересобирают.

---

# Почему интерьеры сейчас ужасны

Потому что генератор НЕ ПОНИМАЕТ комнату.

Он понимает только:

* свободный тайл;
* вероятность.

Поэтому:

* объект у стены;
* иногда второй объект;
* пустота.

Это не интерьерный генератор.

Это random prop scatter.

---

# Как делается нормальное наполнение

# Главное правило

Интерьер НЕ генерируется из случайных объектов.

Он генерируется из:

* room archetype;
* functional zones;
* anchor points.

---

# Правильный pipeline интерьера

## ЭТАП 1 — semantic room type

Комната должна знать:

* storage;
* bedroom;
* armory;
* office;
* kitchen;
* laboratory;
* maintenance.

Без semantic type нормального наполнения НЕ БУДЕТ.

---

## ЭТАП 2 — room analysis

Комната анализируется:

* центр;
* perimeter;
* choke points;
* doors;
* свободные области;
* wall segments.

---

## ЭТАП 3 — anchor generation

Создаются:

* wall anchors;
* center anchors;
* corner anchors;
* utility anchors.

---

## ЭТАП 4 — furniture groups

Размещается НЕ объект.

А prefab group.

Например:

Storage:

* стеллаж;
* коробки;
* проход;
* декаль;
* свет.

Bedroom:

* кровать;
* шкаф;
* лампа;
* столик.

Lab:

* стол;
* консоль;
* кабели;
* equipment cluster.

---

# Главная ошибка текущего наполнения

Сейчас:

object spawn probability.

Нужно:

semantic composition.

Это принципиально разные системы.

---

# Что необходимо внедрить

# Минимально обязательные системы

## 1. Room graph

Критично.

Без этого дальше нет смысла.

---

## 2. Region ownership

Каждый тайл должен знать:

* room_id;
* region type;
* corridor / room / utility.

---

## 3. Semantic tags

Комнаты:

* тип;
* уровень clutter;
* faction;
* danger;
* biome.

---

## 4. Multi-pass generation

Минимум:

1. graph;
2. shapes;
3. walls;
4. doors;
5. navigation;
6. semantic tagging;
7. furniture;
8. clutter;
9. decals;
10. lighting.

---

## 5. Validation passes

Иначе генератор будет производить мусор.

---

## 6. Scoring system

Нужна оценка качества.

Иначе:

* генератор не знает, что результат плохой.

---

# Что использовать вместо текущего подхода

# Лучший practical вариант для SS13-like проекта

## Рекомендуемый стек

### Layout

BSP + graph.

---

### Room shaping

Grammar modifiers.

---

### Organic deformation

Localized cellular automata.

Но ТОЛЬКО:

* как secondary pass;
* не как core architecture.

---

### Connectivity

Flood-fill + path validation.

---

### Interior

Anchor-based prefab placement.

---

### Detailing

Weighted clutter layers.

---

# Что НЕ надо делать

## НЕ использовать:

### pure noise generation

Дает:

* кашу;
* стены-мусор;
* плохую навигацию.

---

### fully random furniture placement

Дает:

* пустые комнаты;
* отсутствие композиции;
* нефункциональные помещения.

---

### tile-by-tile architecture

Это главная проблема.

---

# Как реально должна выглядеть система

# Правильная иерархия

## Уровень 1

Macro layout.

"Что существует"

---

## Уровень 2

Spatial topology.

"Как связано"

---

## Уровень 3

Room geometry.

"Какой формы"

---

## Уровень 4

Navigation.

"Как двигаться"

---

## Уровень 5

Semantic meaning.

"Что это за место"

---

## Уровень 6

Interior composition.

"Как это используется"

---

## Уровень 7

Detailing.

"Как это выглядит"

---

# Почему текущий генератор никогда не даст хороший результат

Потому что он пытается:

из tile noise вывести архитектуру.

А должно быть наоборот:

из архитектуры выводить tile geometry.

Это фундаментальный architectural inversion.

---

# Что стоит сделать прямо сейчас

# План полной переработки

## Этап 1

Выкинуть current wall-first generation.

---

## Этап 2

Сделать:

* room graph;
* room ownership;
* region system.

---

## Этап 3

Переписать geometry generation:

* BSP;
* grammar;
* corridor planner.

---

## Этап 4

Стены делать derivation pass.

---

## Этап 5

Добавить validation.

---

## Этап 6

Сделать semantic room system.

---

## Этап 7

Переделать интерьеры:

* anchors;
* prefabs;
* furniture groups.

---

# Какой результат получится

Тогда генерация начнет:

* создавать реальные помещения;
* иметь читаемую архитектуру;
* делать логичные интерьеры;
* поддерживать тематические зоны;
* выглядеть как handcrafted map;
* сохранять procedural variation.

А не:

* случайный шум со стенами.

---

# Финальный вывод

Проблема PR #99 не в "неудачных параметрах".

Проблема:

* в неправильной архитектуре procedural pipeline;
* в tile-first подходе;
* в отсутствии room graph;
* в отсутствии semantic generation;
* в отсутствии validation;
* в попытке генерировать интерьер случайным scatter placement;
* в генерации стен как primary geometry.

Пока генератор не перейдет:

от tile/noise generation

к

room/graph/semantic generation

результат всегда будет выглядеть как:

* шум;
* рваные стены;
* пустые комнаты;
* бессмысленный clutter.

Именно это сейчас видно в визуализаторе и в игре.

Дополнительно:

Для SS13-подобного проекта лучший practical путь:

* BSP + room graph;
* grammar-based room shaping;
* derived walls;
* semantic room archetypes;
* anchor-based furniture generation;
* validation/scoring passes.

Это даст:

* контролируемость;
* хорошие layouts;
* понятную навигацию;
* качественные интерьеры;
* расширяемость;
* возможность делать разные биомы/фракции/архитектуры.



Я подробно разобрал фундаментальные проблемы текущего procedural pipeline PR #99 и почему генерация сейчас производит не архитектуру, а шум со стенами и случайным наполнением.

Разбор включает:

* почему wall-first подход принципиально ломает комнаты;
* почему DRG pipeline работает иначе;
* почему tile/noise generation не подходит для архитектуры;
* как должны строиться стены;
* почему интерьер сейчас выглядит как random scatter;
* какие системы отсутствуют;
* какие алгоритмы реально нужны;
* какой pipeline должен быть у нормальной генерации;
* какие post-process/validation passes обязательны;
* какой стек лучше всего подойдет для SS13/BandaTroopers.

Также расписан practical-план полной переработки генерации:

* room graph;
* BSP + grammar;
* derived walls;
* semantic rooms;
* anchor-based interiors;
* scoring/validation.

Проблема там действительно архитектурная, а не «плохие параметры».


_______________
План:

# План реализации полной переработки procedural generation для BandaTroopers

## Для оркестратора + системы суб-агентов

Цель:
Перевести текущую генерацию из:

* tile/noise-first;
* wall-first;
* random scatter placement;

в:

* graph-driven;
* room-centric;
* semantic procedural architecture.

---

# Глобальная стратегия

Работа должна идти НЕ как «переписать всё сразу».

А как:

1. Выделение pipeline.
2. Замена слоев поэтапно.
3. Сохранение совместимости.
4. Постепенная замена legacy generation.
5. Введение validation/scoring.

---

# Архитектурная цель

Новая генерация должна иметь pipeline:

```text
Seed
→ Macro Layout Graph
→ Room Topology
→ Room Shapes
→ Corridor Planning
→ Geometry Bake
→ Wall Derivation
→ Connectivity Validation
→ Semantic Tagging
→ Interior Anchors
→ Furniture Groups
→ Clutter Pass
→ Decals/Lighting
→ Final Validation
```

---

# Главная организационная задача

Сейчас генерация, вероятно:

* монолитная;
* смешивает стадии;
* tightly coupled.

Первый этап — декомпозиция.

---

# ОБЩИЙ ПЛАН РАБОТ

# PHASE 0 — DISCOVERY & REVERSE ENGINEERING

## Sub-agent: Architecture Discovery

### Задачи

1. Найти:

   * entrypoint генерации;
   * pipeline;
   * world bake;
   * wall placement;
   * room generation;
   * furniture generation.

2. Построить:

   * call graph;
   * dependency graph;
   * data flow.

3. Определить:

   * какие системы legacy;
   * какие можно переиспользовать;
   * какие невозможно спасти.

---

## Что найти

### Критичные сущности

* region
* chunk
* room
* tile mask
* wall placement
* noise
* floodfill
* nav
* furniture
* decorator
* generator stage
* biome
* prefab

---

## Результат

Документ:

```text
CURRENT_GENERATION_PIPELINE.md
```

С:

* стадиями;
* data ownership;
* mutability;
* проблемными зонами;
* coupling map.

---

# PHASE 1 — GENERATION PIPELINE REFACTOR

# Цель

Разделить генерацию на стадии.

---

## Sub-agent: Pipeline Refactor

### Нужно сделать

Ввести explicit generation stages.

---

# Новый pipeline contract

```text
Stage 1: Layout Graph
Stage 2: Spatial Partition
Stage 3: Room Shapes
Stage 4: Corridor Pass
Stage 5: Geometry Bake
Stage 6: Wall Derivation
Stage 7: Connectivity Validation
Stage 8: Semantic Pass
Stage 9: Interior Placement
Stage 10: Detail Pass
Stage 11: Final Cleanup
```

---

## Требования

Каждая стадия:

* immutable input;
* deterministic output;
* isolated responsibility.

---

## НЕЛЬЗЯ

Смешивать:

* geometry;
* walls;
* interiors;
* clutter.

---

## Результат

Создание:

```text
generation_context
generation_stage
generation_region
room_descriptor
```

---

# PHASE 2 — ROOM GRAPH SYSTEM

# Главная цель

Перестать генерировать карту из тайлов.

Начать генерировать:

* topology;
* structure;
* semantics.

---

## Sub-agent: Graph Generation

# Нужно реализовать

## Room Graph

Комнаты = nodes.

Связи = edges.

---

# Каждая комната должна иметь:

```text
id
type
size class
importance
connections
shape profile
tags
interior preset
```

---

# Типы комнат

Минимум:

* corridor
* hub
* storage
* utility
* dorm
* office
* engineering
* maintenance
* reactor
* security

---

# Требования

## Graph validation

Проверки:

* reachable;
* no isolated nodes;
* degree constraints;
* corridor sanity;
* critical path existence.

---

## Алгоритмы

Рекомендуется:

### Для topology:

* weighted graph generation;
* MST + optional loops;
* hierarchical layout.

---

## НЕ использовать

* random tile expansion;
* wall-driven growth.

---

# PHASE 3 — SPATIAL PARTITION

# Цель

Превратить graph в physical layout.

---

## Sub-agent: Spatial Layout

# Рекомендуемый алгоритм

## BSP

Это лучший baseline для:

* станции;
* базы;
* техногенной архитектуры.

---

# Нужно реализовать

## BSP partitioning

С:

* min room size;
* aspect ratio limits;
* reserved corridor channels;
* adjacency constraints.

---

## Затем

Room assignment.

---

# Требования

Комнаты:

* не должны пересекаться;
* должны иметь readable layout;
* должны иметь usable space.

---

# PHASE 4 — ROOM SHAPE GENERATION

# Цель

Уйти от квадратных коробок,
но сохранить читаемость.

---

## Sub-agent: Shape Grammar

# Реализовать

## Grammar-based deformation

---

# Room profiles

Пример:

```text
Storage:
- more clutter
- asymmetric
- edge-heavy

Office:
- rectangular
- structured

Maintenance:
- narrow
- utility-heavy
```

---

# Допустимые деформации

* corner cuts;
* alcoves;
* support columns;
* utility recesses;
* controlled asymmetry.

---

# НЕ ДОПУСКАТЬ

* noise blobs;
* chaotic edges;
* random spikes;
* diagonal garbage.

---

# PHASE 5 — WALL SYSTEM REWRITE

# КРИТИЧЕСКИЙ ЭТАП

---

## Главная идея

Стены НЕ генерируются.

Они ВЫВОДЯТСЯ.

---

## Sub-agent: Wall Derivation

# Новый принцип

```text
wall =
boundary(walkable, non-walkable)
```

---

# Pipeline

1. Finalize room geometry.
2. Finalize corridors.
3. Finalize floor mask.
4. Derive walls.
5. Cleanup pass.

---

# Нужно реализовать

## Wall masks

Типы:

* outer wall
* room wall
* reinforced wall
* utility wall

---

## Cleanup

Удалять:

* single-tile walls;
* spikes;
* acne;
* broken corners;
* tiny pockets.

---

# PHASE 6 — CONNECTIVITY & VALIDATION

# Цель

Генератор должен уметь понимать,
что результат плохой.

---

## Sub-agent: Validation System

# Реализовать

## Flood-fill validation

Проверять:

* connectivity;
* accessibility;
* navigation.

---

## Room scoring

Метрики:

```text
usable area
wall complexity
navigation quality
convexity
anchor availability
dead-end count
```

---

## Bad room rejection

Плохие комнаты:

* удаляются;
* пересобираются.

---

# КРИТИЧНО

НЕ принимать первый результат.

---

# PHASE 7 — SEMANTIC ROOM SYSTEM

# Цель

Комнаты должны иметь смысл.

---

## Sub-agent: Semantic Layer

# Нужно реализовать

## Room archetypes

Комната должна знать:

```text
purpose
faction
wealth
danger
cleanliness
clutter density
lighting profile
```

---

# Это используется для:

* мебели;
* декора;
* освещения;
* повреждений;
* атмосферы.

---

# PHASE 8 — INTERIOR GENERATION REWRITE

# САМЫЙ ВАЖНЫЙ ЭТАП ПОСЛЕ WALLS

---

# Главная проблема сейчас

Random object placement.

---

# Нужно перейти на:

semantic composition.

---

## Sub-agent: Interior System

# Pipeline

## Stage 1 — room analysis

Определить:

* center;
* perimeter;
* entrances;
* traffic zones;
* free zones.

---

## Stage 2 — anchors

Создать:

* wall anchors;
* corner anchors;
* center anchors;
* utility anchors.

---

## Stage 3 — furniture groups

Ставить НЕ объекты.

Ставить:

* prefab compositions.

---

# Пример

## Storage

Не:

* один шкаф.

А:

* shelf cluster;
* boxes;
* проход;
* utility clutter;
* decals.

---

## Dorm

* bed;
* locker;
* lamp;
* table;
* personal clutter.

---

# PHASE 9 — CLUTTER & DETAILING

# Цель

Сделать помещения живыми.

---

## Sub-agent: Decoration Layer

# Реализовать

## Multi-layer clutter

Слои:

* functional;
* decorative;
* damage;
* faction;
* environmental.

---

# Принцип

Clutter НЕ должен:

* блокировать навигацию;
* ломать anchors;
* перекрывать critical paths.

---

# PHASE 10 — LIGHTING & ATMOSPHERE

## Sub-agent: Atmosphere

# Нужно сделать

Освещение зависит от:

* room type;
* danger;
* biome;
* faction;
* condition.

---

# Добавить

* flickering;
* emergency lighting;
* dark zones;
* maintenance ambience.

---

# PHASE 11 — VISUALIZATION & DEBUGGING

# КРИТИЧЕСКИ ВАЖНО

---

## Sub-agent: Debug Tools

# Нужно сделать visualization overlays

## Отдельные режимы:

### topology graph

### room ownership

### connectivity

### semantic tags

### navigation

### anchors

### clutter density

### scoring heatmap

---

# Иначе генерацию невозможно дебажить.

---

# PHASE 12 — PERFORMANCE & DETERMINISM

## Sub-agent: Optimization

# Проверить

* seed determinism;
* stage reproducibility;
* cacheability;
* incremental rebuilds.

---

# КРИТИЧНО

Одинаковый seed
→ одинаковый результат.

---

# PHASE 13 — CONTENT AUTHORING PIPELINE

# Цель

Чтобы генерацию могли расширять мапперы.

---

## Sub-agent: Authoring System

# Нужно сделать data-driven систему

---

# Room presets

```json
{
  \"type\": \"storage\",
  \"anchors\": [...],
  \"groups\": [...],
  \"clutter\": [...],
  \"lighting\": [...]
}
```

---

# Тогда можно:

* быстро добавлять комнаты;
* делать фракции;
* делать биомы;
* делать тематические станции.

---

# PHASE 14 — MIGRATION STRATEGY

# НЕЛЬЗЯ

Удалять старый генератор сразу.

---

# Нужно

## Dual-mode generation

```text
legacy
new_pipeline
hybrid
```

---

# Это позволит:

* сравнивать;
* тестировать;
* делать A/B;
* откатываться.

---

# КРИТИЧЕСКИЕ ПРАВИЛА ДЛЯ ВСЕХ SUB-AGENTS

# НЕЛЬЗЯ

## 1. Tile-first generation

---

## 2. Wall-first generation

---

## 3. Random furniture scatter

---

## 4. Noise-based architecture

---

## 5. Single-pass generation

---

## 6. Mutable global state between stages

---

# ОБЯЗАТЕЛЬНО

## 1. Stage isolation

---

## 2. Semantic generation

---

## 3. Validation passes

---

## 4. Deterministic seeds

---

## 5. Room ownership

---

## 6. Derived walls

---

## 7. Anchor-based interiors

---

# Рекомендуемые алгоритмы

# Использовать

## Layout

* BSP
* graph layout
* MST

---

## Shapes

* grammar systems
* constrained deformation

---

## Validation

* flood-fill
* nav scoring

---

## Decoration

* prefab groups
* weighted semantic placement

---

# Использовать ограниченно

## Cellular automata

Только:

* caves;
* erosion;
* deformation;
* detail pass.

НЕ как core architecture.

---

# НЕ использовать как основу

## Perlin/simplex-only generation

---

## Pure WFC для всей карты

WFC подходит:

* локально;
* для pattern decoration;
* microstructure.

Но не как core topology generator.

---

# Acceptance Criteria

# Генерация считается успешной если:

## Архитектура

* комнаты читаемы;
* layout логичен;
* нет wall garbage;
* нет micro pockets;
* нет broken navigation.

---

## Интерьеры

* комнаты узнаваемы;
* есть semantic identity;
* нет пустых коробок;
* нет случайного мусора.

---

## Навигация

* понятные коридоры;
* readable flow;
* no dead chaos.

---

## Визуально

Карта должна выглядеть:

* handcrafted;
* но variative.

---

# Финальная цель

Система должна генерировать НЕ:

* шум;
* набор тайлов;
* хаотичные стены;

а:

* архитектуру;
* функциональные помещения;
* semantic environments;
* believable interiors;
* readable navigation;
* gameplay-oriented spaces.
