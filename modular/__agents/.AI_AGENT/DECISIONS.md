# DECISIONS

## D-001: Корневой `AGENTS.md` остается каноническим entrypoint
- Решение: добавить routing-only `AGENTS.md` в корне репозитория.
- Почему: это дает Codex стандартную точку входа без дублирования полной agent-базы в корне.

## D-002: Agent hub живет в `modular/__agents/.AI_AGENT/`
- Решение: разместить все stable docs и task-state именно в `modular/__agents/.AI_AGENT/`.
- Почему: это соответствует выбранному layout и держит SS220/BandaTroopers-specific агентную инфраструктуру рядом с модульным слоем.

## D-003: Task-state tracked в git
- Решение: `PLAN.md`, `TODO.md`, `DECISIONS.md`, `EVIDENCE.md` коммитятся в репозиторий, а сырые логи выносятся в ignored `logs/`.
- Почему: это повторяет модель источника и делает текущее состояние задачи явным для следующих сессий.

## D-004: `SS220_DEVELOPMENT_RULES.md` становится overlay
- Решение: [`../../__docs/SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md) больше не является главным документом и описывает только BandaTroopers/SS220-specific правила над общей agent-базой.
- Почему: repo-specific политика по modular/upstream split и `SS220 EDIT` должна жить отдельным overlay, а не дублировать stable guidance.
