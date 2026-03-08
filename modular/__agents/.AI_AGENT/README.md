# .AI_AGENT

Хаб для агентной работы в репозитории BandaTroopers. Эта папка разделяет устойчивые правила, текущее состояние задачи и сырые артефакты.

## Состав
- Stable guidance:
  - [`PROJECT_CONTEXT.md`](./PROJECT_CONTEXT.md)
  - [`CONFIRMED_UNRESOLVED_ERRORS.md`](./CONFIRMED_UNRESOLVED_ERRORS.md)
  - [`WORKFLOW_RULES.md`](./WORKFLOW_RULES.md)
  - [`POLICIES.md`](./POLICIES.md)
  - [`REQUEST_PATTERNS.md`](./REQUEST_PATTERNS.md)
- Active task state:
  - [`PLAN.md`](./PLAN.md)
  - [`TODO.md`](./TODO.md)
  - [`DECISIONS.md`](./DECISIONS.md)
  - [`EVIDENCE.md`](./EVIDENCE.md)
- Raw evidence:
  - `logs/`

## Storage policy
- `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` are tracked task-state for the current task, not a private memory dump.
- `CONFIRMED_UNRESOLVED_ERRORS.md` — долгоживущий реестр из слоя устойчивых правил, а не task-state и не место для сырых логов.
- Эти Markdown-файлы должны оставаться короткими: текущий статус, принятые решения, сводка доказательств и ссылки на сырые логи.
- Raw command output, long logs, dumps, temporary JSON, and other noisy local artifacts belong only in `logs/` or other ignored local folders.
- В `CONFIRMED_UNRESOLVED_ERRORS.md` хранится только краткий реестр подтвержденных, но еще не устраненных проблем; длинные stack traces и сырые runtime-артефакты остаются в `logs/` или в текущем `EVIDENCE.md`.
- Долгоживущий module-specific sync state хранить в `modular/**/__docs/**`, а не в `PLAN/TODO/DECISIONS/EVIDENCE` (пример: [`../../halo/__docs/HALO_PORT_STATE.md`](../../halo/__docs/HALO_PORT_STATE.md)).
- Если какой-то вывод стал долгоживущим правилом проекта, переносить его из task-state в `PROJECT_CONTEXT.md`, `WORKFLOW_RULES.md`, `POLICIES.md` или в [`../../__docs/SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md).

## Lifecycle
- `CONFIRMED_UNRESOLVED_ERRORS.md` живет поперек задач и обновляется инкрементально как стабильный реестр.
- `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` описывают текущую активную задачу.
- При старте новой крупной задачи эти четыре файла перезаписываются под новый scope.
- Если активной задачи нет, эти четыре файла должны оставаться в нейтральном baseline-состоянии, а не хранить завершенную старую задачу.
- В `logs/` хранится только сырой output команд, тестов и проверок. В Markdown-файлах остаются только краткие выводы и ссылки на логи.
- Если решение стало устойчивой нормой репозитория, оно должно переехать в stable docs или в SS220 overlay.
- Migration-specific или архивные заметки не должны оставаться в live task-state после завершения задачи.

## Границы ответственности
- `modular/__agents/.AI_AGENT/` не дублирует продуктовые runbook и архитектурные справочники без необходимости.
- Репозиторные и доменные документы остаются в `modular/__docs/**`, `modular/**/__docs/**`, `.github/guides/**`, `tools/**/README.md`, `tgui/**`.
- [`../../__docs/SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md) содержит BandaTroopers/SS220-specific overlay: правила модульности, сопровождения апстрима и применения `SS220 EDIT`.
- После чтения этой папки открывать только релевантные документы по задаче.
