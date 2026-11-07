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
   - [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md)
3. Активный task-state:
   - [`modular/__agents/.AI_AGENT/PLAN.md`](./modular/__agents/.AI_AGENT/PLAN.md)
   - [`modular/__agents/.AI_AGENT/TODO.md`](./modular/__agents/.AI_AGENT/TODO.md)
   - [`modular/__agents/.AI_AGENT/DECISIONS.md`](./modular/__agents/.AI_AGENT/DECISIONS.md)
   - [`modular/__agents/.AI_AGENT/EVIDENCE.md`](./modular/__agents/.AI_AGENT/EVIDENCE.md)
5. Затем только релевантные продуктовые документы:
   - [`.github/guides/STANDARDS.md`](./.github/guides/STANDARDS.md)
   - [`.github/guides/STYLES.md`](./.github/guides/STYLES.md)
   - [`tools/build/README.md`](./tools/build/README.md)
   - [`code/modules/unit_tests/README.md`](./code/modules/unit_tests/README.md)
   - [`tools/maplint/README.md`](./tools/maplint/README.md)
   - [`tgui/README.md`](./tgui/README.md)

После чтения stable guidance выполнить только read-only discovery, достаточный чтобы понять scope и актуальность task-state. Если `PLAN/TODO/DECISIONS/EVIDENCE` не относятся к текущей задаче, их нужно перезаписать до любых implementation-правок. Обновление этих четырех файлов считается planning-mutation: оно разрешено после read-only discovery и до изменения продуктового кода, тестов, карт, tgui или stable docs.

Если пользователь дал или утвердил конкретный план, эти файлы нужно обновить или явно подтвердить как актуальный контракт задачи независимо от размера изменения. До появления такого контракта запрещены implementation-правки; ориентироваться только на stable guidance, SS220 overlay и read-only evidence.

## Жесткие правила
- Перед implementation-правками собрать read-only контекст: entrypoints, include graph, callsites, data flow, side effects.
- Если пользователь дал или утвердил план реализации, главным критерием является следование плану, а не объем тестов. До implementation-правок нужно превратить `PLAN.md`, `TODO.md`, `DECISIONS.md` и `EVIDENCE.md` в контракт задачи с явными MUST/KEEP/REJECT/CHECK пунктами, forbidden substitutions и old path audit. Нельзя заменять требование переписать/удалить/заменить ядро частичной оберткой, hotfix, fallback или compatibility patch без явного согласия пользователя.
- Для утвержденных планов с rewrite/remove/replace/core-behavior scope нужен read-only plan-mapping challenge до реализации. Subagent/reviewer используется только если пользователь явно попросил или разрешил subagents и это не запрещено текущими инструкциями; иначе основной агент обязан выполнить challenge-pass сам и записать результат в `EVIDENCE.md`.
- Для поиска использовать `rg` и точечное чтение файлов, а не широкое сканирование дерева.
- Новую бизнес-логику по умолчанию размещать в `modular/**`; если утвержденный план явно требует другой путь, отклонение фиксировать в `DECISIONS.md` или согласовывать с пользователем.
- В `code/**` и других не-`modular/` путях держать только минимальные точки интеграции, разрешенный fallback и glue-код; это правило не разрешает оставлять старое ядро reachable/callable вопреки утвержденному rewrite/remove/replace плану.
- Маркеры `SS220 EDIT` применяются в upstream и согласованных config surfaces по правилам из [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md).
- Сборку и compile-проверки запускать через `BUILD.cmd` или `tools/build/build`, а не через DreamMaker-only workflow.
- Для локальной итерации не гонять полный `dm-test` на каждую правку: сначала compile/targeted checks. Verification-статус не заменяет Plan Fidelity; если пользователь явно приоритизировал реализацию плана над тестами, фиксировать непройденные проверки как остаточный риск по правилам из [`modular/__agents/.AI_AGENT/WORKFLOW_RULES.md`](./modular/__agents/.AI_AGENT/WORKFLOW_RULES.md).
- Не использовать деструктивные git-команды без прямого запроса пользователя.
- `modular/__agents/.AI_AGENT/PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` не должны попадать в коммиты и PR. Перед коммитом или открытием PR их нужно вернуть к baseline-состоянию, если задача явно не требует отдельного согласованного обновления этих файлов.

## Маршрутизация
- Агентная база знаний: [`modular/__agents/.AI_AGENT/`](./modular/__agents/.AI_AGENT/README.md)
- SS220/BandaTroopers-specific overlay: [`modular/__docs/SS220_DEVELOPMENT_RULES.md`](./modular/__docs/SS220_DEVELOPMENT_RULES.md)
- Продуктовые документы: `modular/__docs/**`, `.github/guides/**`, `tools/**/README.md`, `tgui/**`
