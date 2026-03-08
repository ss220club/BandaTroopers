# AGENTS.md

Каноническая точка входа для Codex и совместимых AI-агентов в этом репозитории.

## Порядок чтения
1. [`modular/__agents/.AI_AGENT/README.md`](./modular/__agents/.AI_AGENT/README.md)
2. Stable guidance:
   - [`modular/__agents/.AI_AGENT/PROJECT_CONTEXT.md`](./modular/__agents/.AI_AGENT/PROJECT_CONTEXT.md)
   - [`modular/__agents/.AI_AGENT/CONFIRMED_UNRESOLVED_ERRORS.md`](./modular/__agents/.AI_AGENT/CONFIRMED_UNRESOLVED_ERRORS.md)
   - [`modular/__agents/.AI_AGENT/WORKFLOW_RULES.md`](./modular/__agents/.AI_AGENT/WORKFLOW_RULES.md)
   - [`modular/__agents/.AI_AGENT/POLICIES.md`](./modular/__agents/.AI_AGENT/POLICIES.md)
   - [`modular/__agents/.AI_AGENT/REQUEST_PATTERNS.md`](./modular/__agents/.AI_AGENT/REQUEST_PATTERNS.md)
3. Репозиторный overlay:
   - [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md)
4. Активный task-state:
   - [`modular/__agents/.AI_AGENT/PLAN.md`](./modular/__agents/.AI_AGENT/PLAN.md)
   - [`modular/__agents/.AI_AGENT/TODO.md`](./modular/__agents/.AI_AGENT/TODO.md)
   - [`modular/__agents/.AI_AGENT/DECISIONS.md`](./modular/__agents/.AI_AGENT/DECISIONS.md)
   - [`modular/__agents/.AI_AGENT/EVIDENCE.md`](./modular/__agents/.AI_AGENT/EVIDENCE.md)
5. Затем только релевантные продуктовые документы:
   - module-local docs в `modular/**/__docs/**`, если задача привязана к конкретному модулю. Для HALO port/sync/update задач сначала читать [`modular/halo/__docs/HALO_PORT_STATE.md`](./modular/halo/__docs/HALO_PORT_STATE.md)
   - [`.github/guides/STANDARDS.md`](./.github/guides/STANDARDS.md)
   - [`.github/guides/STYLES.md`](./.github/guides/STYLES.md)
   - [`tools/build/README.md`](./tools/build/README.md)
   - [`code/modules/unit_tests/README.md`](./code/modules/unit_tests/README.md)
   - [`tools/maplint/README.md`](./tools/maplint/README.md)
   - [`tgui/README.md`](./tgui/README.md)

Если `PLAN/TODO/DECISIONS/EVIDENCE` не относятся к текущей задаче, их нужно перезаписать перед началом крупной работы. До этого ориентироваться только на stable guidance и SS220 overlay.

## Жесткие правила
- Перед правками собрать контекст: entrypoints, include graph, callsites, data flow, side effects.
- Для поиска использовать `rg` и точечное чтение файлов, а не широкое сканирование дерева.
- Новую бизнес-логику по умолчанию размещать в `modular/**`.
- В `code/**` и других не-`modular/` путях держать только минимальные точки интеграции, fallback и glue-код.
- Маркеры `SS220 EDIT` применяются в upstream и согласованных config surfaces по правилам из [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md).
- Сборку и compile-проверки запускать через `BUILD.cmd` или `tools/build/build`, а не через DreamMaker-only workflow.
- Не использовать деструктивные git-команды без прямого запроса пользователя.

## Маршрутизация
- Агентная база знаний: [`modular/__agents/.AI_AGENT/`](./modular/__agents/.AI_AGENT/README.md)
- SS220/BandaTroopers-specific overlay: [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md)
- Продуктовые документы: `modular/__docs/**`, `modular/**/__docs/**`, `.github/guides/**`, `tools/**/README.md`, `tgui/**`
