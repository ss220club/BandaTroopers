import { useMemo, useState } from 'react';

import { Box, Button, Dropdown, Flex, Image, Input } from '../../components';
import { getDisplayText, translateOptionLabel } from './helpers';
import { SurfaceCard } from './primitives';
import type {
  ActFn,
  ActiveBlueprintPreview,
  BackendData,
  BlueprintEntry,
  BlueprintPreviewCell,
} from './types';
import type { BlueprintFilterMode, BlueprintSortMode } from './viewModel';
import {
  filterAndSortBlueprintEntries,
  getBlueprintActionState,
  getBlueprintFootprintText,
  getBlueprintPreviewMode,
} from './viewModel';

const FILTER_OPTIONS = [
  { value: 'all', displayText: 'Все' },
  { value: 'valid', displayText: 'Валидные' },
  { value: 'invalid', displayText: 'Ошибки' },
  { value: 'active', displayText: 'Активный' },
] as const;

const SORT_OPTIONS = [
  { value: 'recent', displayText: 'Последние' },
  { value: 'status', displayText: 'Статус' },
  { value: 'name_asc', displayText: 'Имя А-Я' },
  { value: 'name_desc', displayText: 'Имя Я-А' },
  { value: 'newest', displayText: 'Новые' },
  { value: 'oldest', displayText: 'Старые' },
  { value: 'size_desc', displayText: 'Размер ↓' },
  { value: 'size_asc', displayText: 'Размер ↑' },
  { value: 'entries_desc', displayText: 'Объекты ↓' },
  { value: 'entries_asc', displayText: 'Объекты ↑' },
] as const;

const PREVIEW_TONE_COLORS: Record<string, string> = {
  barricade: '#82a9c8',
  wire: '#d4bd5f',
  mine: '#d75f55',
  defense: '#b68cff',
  support: '#67bd8b',
  other: '#aeb7c1',
};

const getBlueprintOutpostSummary = (blueprint: BlueprintEntry) => {
  if (!blueprint.has_outpost_recipe) {
    return '';
  }

  const summaryParts = [
    blueprint.outpost_defense_profile
      ? translateOptionLabel(
          'defense_profile',
          '',
          blueprint.outpost_defense_profile,
        )
      : '',
    blueprint.outpost_layout_variant
      ? translateOptionLabel(
          'layout_variant',
          '',
          blueprint.outpost_layout_variant,
        )
      : '',
  ].filter(Boolean);

  return summaryParts.join(' / ');
};

const getBlueprintMetaText = (
  blueprint: BlueprintEntry,
  outpostSummary: string,
  isCompactPreview: boolean,
) => {
  const metaParts = [
    blueprint.valid ? `${blueprint.entry_count || 0} объектов` : 'ошибка',
    isCompactPreview ? 'компактный предпросмотр' : '',
    outpostSummary,
  ].filter(Boolean);

  return metaParts.join(' / ');
};

const getBlueprintPreviewDimension = (
  blueprint: BlueprintEntry,
  axis: 'width' | 'height',
) => {
  const value =
    axis === 'width'
      ? Number(blueprint.footprint_width)
      : Number(blueprint.footprint_height);
  return Math.max(Math.min(Math.floor(value) || 1, 32), 1);
};

const getBlueprintPreviewCells = (blueprint: BlueprintEntry) => {
  const width = getBlueprintPreviewDimension(blueprint, 'width');
  const height = getBlueprintPreviewDimension(blueprint, 'height');
  return (blueprint.preview_cells || []).filter((cell) => {
    const x = Math.floor(Number(cell.x) || 0);
    const y = Math.floor(Number(cell.y) || 0);
    return x >= 1 && x <= width && y >= 1 && y <= height;
  });
};

const getFittedPreviewSize = (
  width: number,
  height: number,
  maxWidthRem: number,
  maxHeightRem: number,
) => {
  const ratio = Math.max(width, 1) / Math.max(height, 1);
  const maxRatio = maxWidthRem / maxHeightRem;
  if (ratio >= maxRatio) {
    return {
      width: `${maxWidthRem}rem`,
      height: `${maxWidthRem / ratio}rem`,
    };
  }

  return {
    width: `${maxHeightRem * ratio}rem`,
    height: `${maxHeightRem}rem`,
  };
};

const getPreviewCellColor = (cell: BlueprintPreviewCell) =>
  PREVIEW_TONE_COLORS[cell.tone] ||
  PREVIEW_TONE_COLORS[cell.category] ||
  PREVIEW_TONE_COLORS.other;

const BlueprintPreviewGrid = (props: {
  readonly blueprint: BlueprintEntry;
  readonly size: 'thumbnail' | 'full';
}) => {
  const { blueprint, size } = props;
  const width = getBlueprintPreviewDimension(blueprint, 'width');
  const height = getBlueprintPreviewDimension(blueprint, 'height');
  const cells = getBlueprintPreviewCells(blueprint);
  const isFull = size === 'full';
  const outerWidth = isFull ? 8.25 : 2.45;
  const outerHeight = isFull ? 8.25 : 1.42;
  const fittedSize = getFittedPreviewSize(
    width,
    height,
    outerWidth,
    outerHeight,
  );

  return (
    <Box
      style={{
        width: `${outerWidth}rem`,
        height: `${outerHeight}rem`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          ...fittedSize,
          display: 'grid',
          gridTemplateColumns: `repeat(${width}, minmax(0, 1fr))`,
          gridTemplateRows: `repeat(${height}, minmax(0, 1fr))`,
          gap: isFull ? '1px' : '0',
          padding: isFull ? '2px' : '1px',
          border: `1px solid ${
            blueprint.valid
              ? 'rgba(70, 107, 150, 0.65)'
              : 'rgba(143, 60, 52, 0.75)'
          }`,
          borderRadius: '3px',
          background: 'rgba(4, 8, 12, 0.55)',
          boxSizing: 'border-box',
        }}
      >
        {cells.map((cell, index) => (
          <Box
            key={`${cell.x}-${cell.y}-${index}`}
            style={{
              gridColumn: `${Math.floor(Number(cell.x) || 1)}`,
              gridRow: `${Math.floor(Number(cell.y) || 1)}`,
              minWidth: '0',
              minHeight: '0',
              borderRadius: isFull ? '1px' : '0',
              background: getPreviewCellColor(cell),
              opacity: blueprint.valid ? '0.95' : '0.6',
            }}
          />
        ))}
      </Box>
    </Box>
  );
};

const canUseSpritePreview = (
  blueprint: BlueprintEntry,
  preview?: ActiveBlueprintPreview,
) =>
  !!blueprint.valid &&
  preview?.mode === 'sprite' &&
  !!preview.image_url &&
  Number(preview.width || 0) > 0 &&
  Number(preview.height || 0) > 0;

const BlueprintSelectedPreview = (props: {
  readonly blueprint: BlueprintEntry;
  readonly preview?: ActiveBlueprintPreview;
}) => {
  const { blueprint, preview } = props;
  const useSpritePreview = canUseSpritePreview(blueprint, preview);
  const imageUrl = preview?.image_url || '';

  if (!useSpritePreview) {
    return <BlueprintPreviewGrid blueprint={blueprint} size="full" />;
  }

  return (
    <Box
      style={{
        width: '8.25rem',
        height: '8.25rem',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
        padding: '0.2rem',
        border: '1px solid rgba(70, 107, 150, 0.65)',
        borderRadius: '3px',
        background: 'rgba(4, 8, 12, 0.55)',
        boxSizing: 'border-box',
      }}
    >
      <Image
        fixErrors
        objectFit="contain"
        src={imageUrl}
        style={{
          width: '100%',
          height: '100%',
          display: 'block',
        }}
      />
    </Box>
  );
};

const BlueprintStampWorkspace = (props: {
  readonly data: BackendData;
  readonly act: ActFn;
}) => {
  const { data, act } = props;
  const [searchQuery, setSearchQuery] = useState('');
  const [filterMode, setFilterMode] = useState<BlueprintFilterMode>('all');
  const [sortMode, setSortMode] = useState<BlueprintSortMode>('recent');

  const filteredBlueprints = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    const queryEntries = !query
      ? data.blueprint_entries || []
      : (data.blueprint_entries || []).filter((entry) => {
          const haystack = [
            entry.name,
            entry.source,
            entry.created_by,
            entry.id,
          ]
            .join(' ')
            .toLowerCase();
          return haystack.includes(query);
        });

    return filterAndSortBlueprintEntries(
      data,
      queryEntries,
      filterMode,
      sortMode,
    );
  }, [data, filterMode, searchQuery, sortMode]);
  const totalBlueprints = data.blueprint_entries?.length || 0;
  const activeBlueprint = (data.blueprint_entries || []).find(
    (entry) => entry.id === data.active_blueprint_id,
  );
  const activeOutpostSummary = activeBlueprint
    ? getBlueprintOutpostSummary(activeBlueprint)
    : '';
  const activeIsCompactPreview = activeBlueprint
    ? getBlueprintPreviewMode(activeBlueprint) === 'compact'
    : false;

  return (
    <SurfaceCard
      title={`Библиотека (${filteredBlueprints.length} из ${totalBlueprints})`}
      actions={
        <Flex>
          <Flex.Item mr={0.3}>
            <Button
              compact
              icon="upload"
              onClick={() => act('import_blueprint')}
            >
              Импорт
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button
              compact
              icon="refresh"
              onClick={() => act('list_blueprints')}
            >
              Обновить
            </Button>
          </Flex.Item>
        </Flex>
      }
      mt={0}
    >
      <Box
        style={{
          display: 'grid',
          gridTemplateColumns:
            'minmax(7rem, 1.35fr) minmax(5.5rem, 0.82fr) minmax(6.25rem, 0.95fr)',
          gap: '0.4rem',
          alignItems: 'center',
        }}
      >
        <Box>
          <Input
            className="WorldEditPanel__compactInput"
            fluid
            value={searchQuery}
            placeholder="Поиск"
            onChange={(_, value) => setSearchQuery(value)}
          />
        </Box>
        <Box>
          <Dropdown
            className="WorldEditPanel__compactDropdown"
            width="100%"
            options={[...FILTER_OPTIONS]}
            selected={filterMode}
            displayText={
              FILTER_OPTIONS.find((option) => option.value === filterMode)
                ?.displayText || 'Все'
            }
            onSelected={(value) => setFilterMode(value as BlueprintFilterMode)}
          />
        </Box>
        <Box>
          <Dropdown
            className="WorldEditPanel__compactDropdown"
            width="100%"
            options={[...SORT_OPTIONS]}
            selected={sortMode}
            displayText={
              SORT_OPTIONS.find((option) => option.value === sortMode)
                ?.displayText || 'Последние'
            }
            onSelected={(value) => setSortMode(value as BlueprintSortMode)}
          />
        </Box>
      </Box>

      {!!activeBlueprint && (
        <Box
          mt={0.45}
          px={0.35}
          py={0.32}
          style={{
            display: 'grid',
            gridTemplateColumns: '8.35rem minmax(0, 1fr)',
            gap: '0.45rem',
            alignItems: 'start',
            borderTop: '1px solid rgba(70, 107, 150, 0.45)',
            borderBottom: '1px solid rgba(70, 107, 150, 0.45)',
            background: 'rgba(17, 20, 24, 0.28)',
          }}
        >
          <BlueprintSelectedPreview
            blueprint={activeBlueprint}
            preview={data.active_blueprint_preview}
          />
          <Box style={{ minWidth: '0' }}>
            <Flex align="center">
              <Flex.Item grow style={{ minWidth: '0' }}>
                <Box
                  bold
                  color={activeBlueprint.valid ? 'good' : 'bad'}
                  style={{
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {getDisplayText(activeBlueprint.name, 'Шаблон без имени')}
                </Box>
              </Flex.Item>
              <Flex.Item ml={0.35}>
                <Button
                  compact
                  icon="download"
                  disabled={!activeBlueprint.valid}
                  tooltip="Экспорт .dmm"
                  onClick={() =>
                    act('export_blueprint', {
                      blueprint_id: activeBlueprint.id,
                    })
                  }
                >
                  Экспорт
                </Button>
              </Flex.Item>
              <Flex.Item ml={0.25}>
                <Button
                  compact
                  icon="edit"
                  disabled={!activeBlueprint.valid}
                  tooltip="Переименовать"
                  onClick={() =>
                    act('rename_blueprint', {
                      blueprint_id: activeBlueprint.id,
                    })
                  }
                >
                  Имя
                </Button>
              </Flex.Item>
              <Flex.Item ml={0.25}>
                <Button
                  compact
                  icon="trash"
                  color="bad"
                  disabled={!activeBlueprint.valid}
                  tooltip="Удалить"
                  onClick={() =>
                    act('delete_blueprint', {
                      blueprint_id: activeBlueprint.id,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
            <Box
              color="label"
              style={{
                fontSize: '0.78rem',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {getBlueprintFootprintText(activeBlueprint)} /{' '}
              {getBlueprintMetaText(
                activeBlueprint,
                activeOutpostSummary,
                activeIsCompactPreview,
              )}
            </Box>
            <Box
              color="label"
              style={{
                fontSize: '0.78rem',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {activeBlueprint.id}
            </Box>
          </Box>
        </Box>
      )}

      {!data.blueprint_entries?.length && (
        <Box color="label" mt={0.55}>
          Нет шаблонов.
        </Box>
      )}

      {!!data.blueprint_entries?.length && !filteredBlueprints.length && (
        <Box color="label" mt={0.55}>
          Ничего не найдено.
        </Box>
      )}

      {!!filteredBlueprints.length && (
        <Box mt={0.55}>
          {filteredBlueprints.map((blueprint) => {
            const actionState = getBlueprintActionState(data, blueprint);
            const outpostSummary = getBlueprintOutpostSummary(blueprint);
            const isCompactPreview =
              getBlueprintPreviewMode(blueprint) === 'compact';
            const metaText = getBlueprintMetaText(
              blueprint,
              outpostSummary,
              isCompactPreview,
            );
            return (
              <Box
                key={blueprint.id}
                p={0.38}
                mb={0.22}
                onClick={() => {
                  if (actionState.canLoad) {
                    act('load_blueprint', {
                      blueprint_id: blueprint.id,
                    });
                  }
                }}
                style={{
                  border: actionState.isActive
                    ? '1px solid #4c9f39'
                    : '1px solid rgba(70, 107, 150, 0.55)',
                  borderLeft: actionState.isActive
                    ? '3px solid #4c9f39'
                    : '3px solid transparent',
                  background: actionState.isActive
                    ? 'rgba(76, 159, 57, 0.16)'
                    : 'rgba(70, 107, 150, 0.10)',
                  borderRadius: '4px',
                  cursor: actionState.canLoad ? 'pointer' : 'default',
                }}
              >
                <Box
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '2.55rem minmax(0, 1fr) auto',
                    gap: '0.38rem',
                    alignItems: 'center',
                  }}
                >
                  <BlueprintPreviewGrid
                    blueprint={blueprint}
                    size="thumbnail"
                  />
                  <Box style={{ minWidth: '0' }}>
                    <Box
                      bold
                      color={actionState.isActive ? 'good' : 'white'}
                      style={{
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {getDisplayText(blueprint.name, 'Шаблон без имени')}
                    </Box>
                    <Box
                      color="label"
                      style={{
                        fontSize: '0.78rem',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {metaText}
                    </Box>
                  </Box>
                  <Box style={{ flex: '0 0 auto' }}>
                    <Box
                      color={blueprint.valid ? 'label' : 'bad'}
                      style={{
                        fontSize: '0.9rem',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {getBlueprintFootprintText(blueprint)}
                    </Box>
                  </Box>
                </Box>
                {!!blueprint.error && !blueprint.valid && (
                  <Box
                    color="bad"
                    style={{
                      fontSize: '0.82rem',
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {blueprint.error}
                  </Box>
                )}
              </Box>
            );
          })}
        </Box>
      )}
    </SurfaceCard>
  );
};

export { BlueprintStampWorkspace };
