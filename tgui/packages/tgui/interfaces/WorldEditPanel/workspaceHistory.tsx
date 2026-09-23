import { Box, Button, Collapsible, Flex } from '../../components';
import { EMPTY_LABEL } from './constants';
import {
  getDisplayText,
  getGeneratorDisplayName,
  getHistoryResultText,
  getTranslatedUndoPolicy,
  getTranslatedUndoStatus,
  getUndoTone,
  toneForHistoryResult,
} from './helpers';
import { CompactStatusRow, StatusPill, SurfaceCard } from './primitives';
import type { ActFn, BackendData } from './types';
import { getHistoryMetrics } from './viewModel';

const HistoryWorkspace = (props: {
  readonly data: BackendData;
  readonly act: ActFn;
}) => {
  const { data, act } = props;
  const historyEntries = data.history_entries || [];
  const historyMetrics = getHistoryMetrics(historyEntries);

  return (
    <SurfaceCard
      title="Журнал"
      actions={
        <Flex wrap mx={-0.2}>
          <Flex.Item m={0.2}>
            <Button
              compact
              color="average"
              disabled={!data.can_cleanup_last_owned_effects}
              onClick={() => act('cleanup_last_owned_effects')}
            >
              Очистить эффекты
            </Button>
          </Flex.Item>
          <Flex.Item m={0.2}>
            <Button
              compact
              color="average"
              onClick={() => act('clear_history')}
            >
              Очистить журнал
            </Button>
          </Flex.Item>
        </Flex>
      }
    >
      {!data.last_changeset && !historyEntries.length && (
        <Box color="label">Журнал пуст.</Box>
      )}

      {!!historyEntries.length && (
        <Box mb={0.55}>
          <Flex wrap mx={-0.2}>
            <Flex.Item m={0.2}>
              <StatusPill
                label="Записей"
                value={`${historyMetrics.total}`}
                tone="label"
              />
            </Flex.Item>
            <Flex.Item m={0.2}>
              <StatusPill
                label="Успех"
                value={`${historyMetrics.good}`}
                tone="good"
              />
            </Flex.Item>
            <Flex.Item m={0.2}>
              <StatusPill
                label="Частично"
                value={`${historyMetrics.average}`}
                tone="average"
              />
            </Flex.Item>
            <Flex.Item m={0.2}>
              <StatusPill
                label="Проблемы"
                value={`${historyMetrics.bad}`}
                tone="bad"
              />
            </Flex.Item>
            <Flex.Item m={0.2}>
              <StatusPill
                label="Откат"
                value={
                  data.can_undo_last_operation
                    ? 'Доступен'
                    : data.can_cleanup_last_owned_effects
                      ? 'Очистка'
                      : 'Нет'
                }
                tone={
                  data.can_undo_last_operation
                    ? 'good'
                    : data.can_cleanup_last_owned_effects
                      ? 'average'
                      : 'label'
                }
              />
            </Flex.Item>
          </Flex>
        </Box>
      )}

      {!!data.last_changeset && (
        <Box
          p={0.45}
          mb={historyEntries.length ? 0.55 : 0}
          style={{
            border: '1px solid rgba(70, 107, 150, 0.55)',
            background: 'rgba(70, 107, 150, 0.12)',
            borderRadius: '4px',
          }}
        >
          <Flex align="center" wrap mb={0.35}>
            <Flex.Item grow basis="12rem">
              <Box bold>Последняя операция</Box>
            </Flex.Item>
            <Flex.Item>
              <StatusPill
                label="Статус"
                value={getTranslatedUndoStatus(data.last_changeset.undo_status)}
                tone={getUndoTone(data.last_changeset.undo_status)}
              />
            </Flex.Item>
          </Flex>
          <CompactStatusRow
            basis="32%"
            items={[
              {
                label: 'Инструмент',
                value: getGeneratorDisplayName(
                  data,
                  data.last_changeset.generator_id,
                ),
              },
              {
                label: 'Откат',
                value: getTranslatedUndoPolicy(data.last_changeset.undo_policy),
              },
              {
                label: 'Статус',
                value: getTranslatedUndoStatus(data.last_changeset.undo_status),
              },
              {
                label: 'Время',
                value: getDisplayText(
                  data.last_changeset.created_at,
                  EMPTY_LABEL,
                ),
              },
            ]}
          />
          <Box color="label" mt={0.25}>
            Создано: {data.last_changeset.created_entries} · Перемещено:{' '}
            {data.last_changeset.moved_entries} · Тайлы:{' '}
            {data.last_changeset.changed_turf_entries ?? 0} · Эффекты:{' '}
            {data.last_changeset.owned_effect_entries}
          </Box>
        </Box>
      )}

      {!!historyEntries.length && (
        <Box>
          {historyEntries.map((entry, index) => (
            <Collapsible
              key={`${entry.time}_${entry.generator_id}_${index}`}
              title={`${entry.time} · ${getGeneratorDisplayName(
                data,
                entry.generator_id,
              )} · ${getHistoryResultText(entry.result)}`}
              color={toneForHistoryResult(entry.result)}
              open={index === 0}
            >
              <Flex wrap mx={-0.18} mb={0.35}>
                <Flex.Item m={0.18}>
                  <StatusPill
                    label="Результат"
                    value={getHistoryResultText(entry.result)}
                    tone={toneForHistoryResult(entry.result)}
                  />
                </Flex.Item>
                {!!entry.undo_policy && (
                  <Flex.Item m={0.18}>
                    <StatusPill
                      label="Откат"
                      value={getTranslatedUndoStatus(entry.undo_status)}
                      tone={getUndoTone(entry.undo_status)}
                    />
                  </Flex.Item>
                )}
              </Flex>
              <CompactStatusRow
                basis="32%"
                items={[
                  {
                    label: 'Создано',
                    value: `${entry.created_count}`,
                  },
                  {
                    label: 'Удалено',
                    value: `${entry.deleted_count}`,
                  },
                  {
                    label: 'Центр',
                    value: getDisplayText(entry.center_turf, EMPTY_LABEL),
                  },
                  {
                    label: 'Откат',
                    value: entry.undo_policy
                      ? `${getTranslatedUndoPolicy(entry.undo_policy)} / ${getTranslatedUndoStatus(
                          entry.undo_status,
                        )}`
                      : EMPTY_LABEL,
                  },
                  {
                    label: 'Откат / пропуск',
                    value:
                      entry.reverted_count !== undefined ||
                      entry.skipped_count !== undefined
                        ? `${entry.reverted_count ?? 0} / ${entry.skipped_count ?? 0}`
                        : EMPTY_LABEL,
                  },
                ]}
              />
              <Box color="label" mt={0.45}>
                {entry.message || 'Подробности не сохранены.'}
              </Box>
            </Collapsible>
          ))}
        </Box>
      )}
    </SurfaceCard>
  );
};

export { HistoryWorkspace };
