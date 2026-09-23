import { PLACEMENT_SHAPE_ORDER } from './constants';
import type { BackendData, HistoryEntry, UiField } from './types';
import {
  buildWorldEditViewModel,
  filterAndSortBlueprintEntries,
  getBlueprintActionState,
  getBlueprintLibraryActions,
  getBlueprintPreviewMode,
  getBuildingLayoutCapabilityStatus,
  getDestructionPreviewLegendItems,
  getDestructionWorkspaceViewModel,
  getHistoryMetrics,
  getSharedModeViewModel,
  getToolbarActions,
} from './viewModel';
import { getFortifyWorkspaceViewModel } from './viewModelFortify';
import { getOutpostWorkspaceViewModel } from './viewModelOutpost';

const makeField = (
  overrides: Partial<UiField> & Pick<UiField, 'id'>,
): UiField => ({
  id: overrides.id,
  label: overrides.label || overrides.id,
  kind: overrides.kind || 'boolean',
  value: overrides.value ?? false,
  options: overrides.options,
  min: overrides.min,
  max: overrides.max,
  step: overrides.step,
  description: overrides.description,
  placeholder: overrides.placeholder,
  group: overrides.group,
  visible: overrides.visible,
  disabled: overrides.disabled,
  required: overrides.required,
  validate_hint: overrides.validate_hint,
});

const makeHistoryEntry = (overrides: Partial<HistoryEntry>): HistoryEntry => ({
  time: overrides.time || '12:00',
  generator_id: overrides.generator_id || 'blueprint_stamp',
  result: overrides.result || 'success',
  created_count: overrides.created_count ?? 0,
  deleted_count: overrides.deleted_count ?? 0,
  center_turf: overrides.center_turf || '1,1,1',
  duration_ms: overrides.duration_ms ?? 0,
  params_short: overrides.params_short || '',
  message: overrides.message || '',
  undo_policy: overrides.undo_policy,
  undo_status: overrides.undo_status,
  reverted_count: overrides.reverted_count,
  skipped_count: overrides.skipped_count,
  operation_id: overrides.operation_id,
  source_operation_id: overrides.source_operation_id,
  source_generator_id: overrides.source_generator_id,
});

const BASE_BACKEND_DATA: BackendData = {
  categories: [],
  has_generator: true,
  current_generator_id: 'blueprint_stamp',
  current_generator_supports_preview: true,
  requires_preview_before_apply: false,
  ui_fields: [],
  generator_payload: {},
  placement_supported: true,
  placement_active: false,
  placement_mode: 'single',
  placement_mode_options: [],
  placement_shape_supported: true,
  placement_shape: 'point',
  placement_shape_options: [],
  placement_shape_fields: [],
  placement_shape_uses_anchor_pair: false,
  placement_interaction_kind: '',
  placement_interaction_label: '',
  placement_collector_point_count: 0,
  placement_collector_min_points: 0,
  placement_collector_max_points: 0,
  can_finish_placement_collection: false,
  placement_supports_direction: true,
  placement_dir: 'north',
  placement_dir_uses_facing: false,
  placement_dir_options: [],
  placement_anchor: undefined,
  can_start_placement_mode: true,
  can_manage_presets: false,
  preset_entries: [],
  blueprint_entries: [],
  active_blueprint_id: undefined,
  can_save_blueprint_from_plan: false,
  confirm_before_apply: false,
  last_ui_error: '',
  preview_valid: false,
  preview_success: false,
  preview_message: '',
  preview_meta: {},
  runtime_status: [],
  runtime_trace: [],
  last_apply_success: false,
  last_apply_message: '',
  last_undo_success: false,
  last_undo_message: '',
  last_changeset: undefined,
  click_mode_active: false,
  can_run_preview: true,
  can_run_apply: true,
  can_stop_click_mode: true,
  can_undo_last_operation: true,
  can_cleanup_last_owned_effects: false,
  history_entries: [],
};

const makeData = (overrides: Partial<BackendData> = {}): BackendData => ({
  ...BASE_BACKEND_DATA,
  ...overrides,
});

describe('WorldEditPanel view model', () => {
  it('builds grouped fields and tool tabs for the page entry model', () => {
    const data = makeData({
      categories: [
        {
          category: 'Tools',
          generators: [
            {
              id: 'destruction_pack',
              name_ru: 'Разрушение',
              description_ru: '',
              execution_mode: '',
              required_rights: '',
              supports_preview: true,
            },
          ],
        },
      ],
      ui_fields: [
        makeField({ id: 'a', group: 'First' }),
        makeField({ id: 'b', group: 'Second' }),
      ],
    });

    const model = buildWorldEditViewModel(data);

    expect(model.showPlacementSetup).toBe(true);
    expect(model.groupNames).toEqual(['First', 'Second']);
    expect(model.groupedFields.First.map((field) => field.id)).toEqual(['a']);
    expect(model.toolTabs.map((tab) => tab.id)).toEqual(['destruction_pack']);
  });

  it('orders the fortify tool between blueprint and outpost tabs', () => {
    const model = buildWorldEditViewModel(
      makeData({
        categories: [
          {
            category: 'Tools',
            generators: [
              {
                id: 'outpost_radius',
                name_ru: 'Outpost',
                description_ru: '',
                execution_mode: '',
                required_rights: '',
                supports_preview: true,
              },
              {
                id: 'fortify_room',
                name_ru: 'Fortify Room',
                description_ru: '',
                execution_mode: '',
                required_rights: '',
                supports_preview: true,
              },
              {
                id: 'blueprint_stamp',
                name_ru: 'Blueprint',
                description_ru: '',
                execution_mode: '',
                required_rights: '',
                supports_preview: true,
              },
            ],
          },
        ],
      }),
    );

    expect(model.toolTabs.map((tab) => tab.id)).toEqual([
      'blueprint_stamp',
      'fortify_room',
      'outpost_radius',
    ]);
  });

  it('derives toolbar actions from preview and placement state', () => {
    const actions = getToolbarActions(
      makeData({
        preview_valid: true,
        placement_supported: true,
        placement_shape_supported: true,
        placement_supports_direction: true,
      }),
    );

    expect(actions.previewAction).toMatchObject({
      action: 'clear_preview',
      color: 'good',
    });
    expect(actions.applyAction).toBeUndefined();
    expect(actions.placementAction).toMatchObject({
      action: 'run_apply',
      label: 'Разм.',
    });
  });

  it('keeps locked shapes visible while disabling preview/apply actions', () => {
    const data = makeData({
      placement_shape_supported: true,
      placement_shape: 'line',
      placement_shape_options: [
        {
          value: 'point',
          label: 'point',
          locked: false,
        },
        {
          value: 'line',
          label: 'line',
          locked: true,
          lockReason: 'Building layout does not support line yet.',
        },
      ],
      placement_supported: true,
      placement_supports_direction: true,
    });
    const actions = getToolbarActions(data);
    const shared = getSharedModeViewModel(data, 'editor');

    expect(shared.shapeOptions.map((option) => option.value)).toEqual([
      'point',
      'line',
    ]);
    expect(shared.selectedShape).toBe('line');
    expect(actions.previewAction?.disabled).toBe(true);
    expect(actions.placementAction?.disabled).toBe(true);
  });

  it('disables preview/apply for request-level locks without hiding the shape row', () => {
    const data = makeData({
      placement_shape_supported: true,
      placement_shape: 'point',
      placement_shape_options: [
        {
          value: 'point',
          label: 'point',
          locked: false,
          shape_locked: false,
          request_locked: true,
          can_preview: false,
          can_apply: false,
          lockReason: 'Selected area is too small.',
        },
      ],
      placement_supported: true,
      placement_supports_direction: true,
    });
    const actions = getToolbarActions(data);
    const shared = getSharedModeViewModel(data, 'editor');

    expect(shared.shapeOptions.map((option) => option.value)).toEqual([
      'point',
    ]);
    expect(shared.selectedShape).toBe('point');
    expect(actions.previewAction?.disabled).toBe(true);
    expect(actions.placementAction?.disabled).toBe(true);
  });

  it('uses the building layout capability matrix to block unsupported program/style rows', () => {
    const data = makeData({
      current_generator_id: 'building_layout',
      placement_shape: 'point',
      placement_shape_options: [
        {
          value: 'point',
          label: 'point',
          can_preview: true,
          can_apply: true,
        },
      ],
      generator_payload: {
        building_layout: {
          current_program_id: 'living',
          current_style_id: 'covenant',
          capability_matrix: {
            compatibility: {
              by_key: {
                'living|covenant': {
                  program_id: 'living',
                  style_id: 'covenant',
                  supported: false,
                  lock_code: 'style.missing_capability',
                  missing_capabilities: ['sleep_surface'],
                },
              },
            },
          },
        },
      },
    });

    const actions = getToolbarActions(data);
    const status = getBuildingLayoutCapabilityStatus(data);

    expect(status?.visible).toBe(true);
    expect(status?.message).toContain('обязательные функции');
    expect(status?.items).toContainEqual({
      label: 'Нет функций',
      value: 'sleep_surface',
      color: 'bad',
    });
    expect(actions.previewAction?.disabled).toBe(true);
    expect(actions.placementAction?.disabled).toBe(true);
  });

  it('does not block building layout actions when the capability matrix supports the row', () => {
    const data = makeData({
      current_generator_id: 'building_layout',
      placement_shape: 'point',
      placement_shape_options: [
        {
          value: 'point',
          label: 'point',
          can_preview: true,
          can_apply: true,
        },
      ],
      generator_payload: {
        building_layout: {
          current_program_id: 'living',
          current_style_id: 'colony',
          capability_matrix: {
            compatibility: {
              by_key: {
                'living|colony': {
                  program_id: 'living',
                  style_id: 'colony',
                  supported: true,
                },
              },
            },
          },
        },
      },
    });

    const actions = getToolbarActions(data);

    expect(getBuildingLayoutCapabilityStatus(data)).toBeUndefined();
    expect(actions.previewAction?.disabled).toBe(false);
    expect(actions.placementAction?.disabled).toBe(false);
  });

  it('decorates building layout program and style options with capability locks', () => {
    const model = buildWorldEditViewModel(
      makeData({
        current_generator_id: 'building_layout',
        ui_fields: [
          makeField({
            id: 'archetype_id',
            kind: 'select',
            value: 'living',
            options: [
              { label: 'Living', value: 'living' },
              { label: 'Medical', value: 'medical' },
            ],
          }),
          makeField({
            id: 'faction_preset',
            kind: 'select',
            value: 'covenant',
            options: [
              { label: 'Colony', value: 'colony' },
              { label: 'Covenant', value: 'covenant' },
            ],
          }),
        ],
        generator_payload: {
          building_layout: {
            current_program_id: 'living',
            current_style_id: 'covenant',
            capability_matrix: {
              compatibility: {
                by_key: {
                  'living|colony': {
                    program_id: 'living',
                    style_id: 'colony',
                    supported: true,
                  },
                  'living|covenant': {
                    program_id: 'living',
                    style_id: 'covenant',
                    supported: false,
                    lock_code: 'style.missing_capability',
                    missing_capabilities: ['sleep_surface'],
                  },
                  'medical|covenant': {
                    program_id: 'medical',
                    style_id: 'covenant',
                    supported: true,
                  },
                },
              },
            },
          },
        },
      }),
    );

    const programField = model.groupedFields['Основные'].find(
      (field) => field.id === 'archetype_id',
    );
    const styleField = model.groupedFields['Основные'].find(
      (field) => field.id === 'faction_preset',
    );

    expect(
      programField?.options?.find((option) => option.value === 'medical')
        ?.disabled,
    ).not.toBe(true);
    expect(
      styleField?.options?.find((option) => option.value === 'covenant')
        ?.disabled,
    ).toBe(true);
    expect(
      styleField?.options?.find((option) => option.value === 'covenant')
        ?.lockReason,
    ).toContain('обязательные функции');
  });

  it('normalizes shared mode shell state and keeps blueprint-specific extras', () => {
    const data = makeData({
      current_generator_id: 'blueprint_stamp',
      placement_shape: 'line',
      placement_shape_options: [],
      placement_dir: 'west',
      ui_fields: [
        makeField({ id: 'stamp_spacing', kind: 'number', value: 3 }),
        makeField({ id: 'radius', kind: 'number', value: 5 }),
      ],
      blueprint_entries: [
        {
          id: 'bp-1',
          name: 'Test',
          entry_count: 1,
          radius: 7,
          created_at: '',
          created_by: '',
          source: '',
          valid: true,
          error: '',
        },
      ],
      active_blueprint_id: 'bp-1',
    });

    const model = getSharedModeViewModel(data, 'editor');

    expect(model.shapeOptions).toEqual([{ value: 'line', label: 'line' }]);
    expect(model.selectedDirection).toBe('west');
    expect(model.showRadiusSection).toBe(true);
    expect(model.sharedFields.map((field) => field.id)).toContain(
      'stamp_spacing',
    );
    expect(model.activeBlueprint?.radius).toBe(7);
    expect(model.radiusToggleFields.map((field) => field.id)).toEqual([
      'radius_only_clear_tiles',
      'radius_only_reachable_tiles',
      'radius_windows_blockers',
    ]);
    expect(model.radiusToggleFields.every((field) => field.disabled)).toBe(
      true,
    );
  });

  it('keeps top radius unique and makes shape radius labels explicit', () => {
    const { getTranslatedFieldLabel } = require('./helpers');
    const model = getSharedModeViewModel(
      makeData({
        current_generator_id: 'outpost_radius',
        ui_fields: [
          makeField({
            id: 'radius',
            kind: 'number',
            value: 5,
          }),
        ],
        placement_shape_fields: [
          makeField({
            id: 'radius',
            kind: 'number',
            value: 5,
          }),
          makeField({
            id: 'shape_radius',
            kind: 'number',
            value: 3,
          }),
          makeField({
            id: 'shape_radius_x',
            kind: 'number',
            value: 4,
          }),
          makeField({
            id: 'shape_radius_y',
            kind: 'number',
            value: 2,
          }),
        ],
      }),
      'editor',
    );

    expect(model.showRadiusSection).toBe(true);
    expect(model.sharedFields.map((field) => field.id)).toEqual([
      'shape_radius',
      'shape_radius_x',
      'shape_radius_y',
    ]);
    expect(
      model.sharedFields.map((field) => getTranslatedFieldLabel(field)),
    ).toEqual(['Радиус формы', 'Горизонтальный радиус', 'Вертикальный радиус']);
  });

  it('surfaces radius policy toggles only in the shared radius chrome', () => {
    const model = getSharedModeViewModel(
      makeData({
        current_generator_id: 'destruction_pack',
        ui_fields: [
          makeField({
            id: 'radius',
            kind: 'number',
            value: 3,
            group: 'Area',
          }),
          makeField({
            id: 'radius_only_clear_tiles',
            value: true,
            group: 'Area',
          }),
          makeField({
            id: 'radius_only_reachable_tiles',
            value: false,
            group: 'Area',
          }),
          makeField({
            id: 'radius_windows_blockers',
            value: true,
            group: 'Area',
          }),
        ],
        placement_shape_fields: [
          makeField({
            id: 'shape_radius',
            kind: 'number',
            value: 2,
          }),
        ],
      }),
      'editor',
    );

    expect(model.showRadiusSection).toBe(true);
    expect(model.radiusToggleFields.map((field) => field.id)).toEqual([
      'radius_only_clear_tiles',
      'radius_only_reachable_tiles',
      'radius_windows_blockers',
    ]);
    expect(model.sharedFields.map((field) => field.id)).toEqual([
      'shape_radius',
    ]);
  });

  it('keeps tool-specific radius labels distinct in the shared controller', () => {
    const { getTranslatedFieldLabel } = require('./helpers');

    expect(
      getTranslatedFieldLabel(
        makeField({
          id: 'radius',
          kind: 'number',
          label: 'Perimeter Offset',
          value: 2,
        }),
      ),
    ).toBe('Отступ периметра');

    expect(
      getTranslatedFieldLabel(
        makeField({
          id: 'radius',
          kind: 'number',
          label: 'Impact Radius',
          value: 3,
        }),
      ),
    ).toBe('Радиус воздействия');
  });

  it('exposes the full shared shape catalog for outpost and destruction tools', () => {
    const shapeOptions = PLACEMENT_SHAPE_ORDER.map((shapeId) => ({
      value: shapeId,
      label: shapeId,
    }));

    for (const generatorId of ['outpost_radius', 'destruction_pack']) {
      const shared = getSharedModeViewModel(
        makeData({
          current_generator_id: generatorId,
          placement_shape_supported: true,
          placement_shape: 'sector',
          placement_shape_options: shapeOptions,
          placement_supports_direction: true,
        }),
        'editor',
      );

      expect(shared.showShapeSection).toBe(true);
      expect(shared.shapeOptions.map((option) => `${option.value}`)).toEqual(
        PLACEMENT_SHAPE_ORDER,
      );
      expect(shared.showDirectionSection).toBe(true);
      expect(shared.selectedShape).toBe('sector');
    }
  });

  it('keeps direction chrome visible but disabled-ready for unsupported tools', () => {
    const data = makeData({
      current_generator_id: 'destruction_pack',
      placement_supported: false,
      placement_shape_supported: false,
      placement_supports_direction: false,
    });

    const shared = getSharedModeViewModel(data, 'editor');

    expect(shared.showShapeSection).toBe(false);
    expect(shared.showModeSection).toBe(false);
    expect(shared.showDirectionSection).toBe(true);
    expect(shared.hasTopControls).toBe(true);
  });

  it('falls back to valid placement mode choices when backend sends garbage', () => {
    const shared = getSharedModeViewModel(
      makeData({
        current_generator_id: 'destruction_pack',
        placement_supported: true,
        placement_mode: '0',
        placement_mode_options: [
          {
            value: '0',
            label: '0',
          },
        ],
      }),
      'editor',
    );

    expect(shared.modeOptions).toEqual([
      {
        value: 'single',
        displayText: '1 раз',
        tooltip: 'Один раз',
      },
      {
        value: 'repeat',
        displayText: 'Повт.',
        tooltip: 'Повторять',
      },
    ]);
    expect(shared.selectedMode).toBe('single');
  });

  it('sorts blueprint entries by status and tracks activation state', () => {
    const data = makeData({
      active_blueprint_id: 'bp-2',
      preview_valid: true,
      can_run_apply: true,
      blueprint_entries: [
        {
          id: 'bp-1',
          name: 'Alpha',
          entry_count: 4,
          radius: 3,
          created_at: '2026-04-10',
          created_by: '',
          source: '',
          valid: true,
          error: '',
        },
        {
          id: 'bp-2',
          name: 'Bravo',
          entry_count: 2,
          radius: 2,
          created_at: '2026-04-12',
          created_by: '',
          source: '',
          valid: true,
          error: '',
        },
        {
          id: 'bp-3',
          name: 'Corrupt',
          entry_count: 9,
          radius: 6,
          created_at: '2026-04-11',
          created_by: '',
          source: '',
          valid: false,
          error: 'broken',
        },
      ],
    });

    const sorted = filterAndSortBlueprintEntries(
      data,
      data.blueprint_entries,
      'all',
      'status',
    );
    const activeState = getBlueprintActionState(data, sorted[0]);
    const inactiveState = getBlueprintActionState(data, sorted[1]);
    const invalidState = getBlueprintActionState(data, sorted[2]);

    expect(sorted.map((entry) => entry.id)).toEqual(['bp-2', 'bp-1', 'bp-3']);
    expect(activeState).toMatchObject({
      isActive: true,
      canLoad: false,
      canPreview: true,
      canApply: true,
    });
    expect(inactiveState).toMatchObject({
      isActive: false,
      canLoad: true,
      canPreview: true,
      canApply: false,
    });
    expect(invalidState).toMatchObject({
      canLoad: false,
      canPreview: false,
      canApply: false,
    });
  });

  it('sorts blueprint entries by recent usage, footprint size, and entry count', () => {
    const data = makeData({
      active_blueprint_id: 'bp-small',
      blueprint_entries: [
        {
          id: 'bp-small',
          name: 'Alpha',
          entry_count: 3,
          radius: 1,
          footprint_width: 2,
          footprint_height: 2,
          created_at: '2026-04-10',
          created_by: '',
          source: '',
          valid: true,
          error: '',
          last_used_rank: 2,
          use_count: 1,
        },
        {
          id: 'bp-large',
          name: 'Bravo',
          entry_count: 8,
          radius: 3,
          footprint_width: 6,
          footprint_height: 5,
          created_at: '2026-04-12',
          created_by: '',
          source: '',
          valid: true,
          error: '',
          last_used_rank: 5,
          use_count: 3,
        },
        {
          id: 'bp-unused',
          name: 'Charlie',
          entry_count: 12,
          radius: 4,
          footprint_width: 4,
          footprint_height: 4,
          created_at: '2026-04-11',
          created_by: '',
          source: '',
          valid: true,
          error: '',
          last_used_rank: 0,
          use_count: 0,
        },
      ],
    });

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'recent',
      ).map((entry) => entry.id),
    ).toEqual(['bp-large', 'bp-small', 'bp-unused']);

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'size_desc',
      ).map((entry) => entry.id),
    ).toEqual(['bp-large', 'bp-unused', 'bp-small']);

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'size_asc',
      ).map((entry) => entry.id),
    ).toEqual(['bp-small', 'bp-unused', 'bp-large']);

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'name_desc',
      ).map((entry) => entry.id),
    ).toEqual(['bp-unused', 'bp-large', 'bp-small']);

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'oldest',
      ).map((entry) => entry.id),
    ).toEqual(['bp-small', 'bp-unused', 'bp-large']);

    expect(
      filterAndSortBlueprintEntries(
        data,
        data.blueprint_entries,
        'all',
        'entries_desc',
      ).map((entry) => entry.id),
    ).toEqual(['bp-unused', 'bp-large', 'bp-small']);
  });

  it('exposes DMM blueprint library actions and compact preview state', () => {
    const data = makeData({
      active_blueprint_id: 'bp-1',
      preview_valid: true,
      can_run_apply: true,
    });
    const blueprint = {
      id: 'bp-1',
      name: 'Heavy',
      entry_count: 256,
      radius: 8,
      created_at: '',
      created_by: '',
      source: 'server',
      valid: true,
      error: '',
      preview_mode: 'compact' as const,
    };

    expect(getBlueprintPreviewMode(blueprint)).toBe('compact');
    expect(
      getBlueprintPreviewMode({ ...blueprint, preview_mode: undefined }),
    ).toBe('detail');
    expect(getBlueprintLibraryActions(data, blueprint)).toEqual([
      { action: 'load_blueprint', disabled: true },
      { action: 'preview_blueprint', disabled: false },
      { action: 'apply_blueprint', disabled: false },
      { action: 'export_blueprint', disabled: false },
      { action: 'rename_blueprint', disabled: false },
      { action: 'delete_blueprint', disabled: false },
    ]);
    expect(
      getBlueprintLibraryActions(data, { ...blueprint, valid: false }).filter(
        (entry) =>
          ['export_blueprint', 'rename_blueprint', 'delete_blueprint'].includes(
            entry.action,
          ),
      ),
    ).toEqual([
      { action: 'export_blueprint', disabled: true },
      { action: 'rename_blueprint', disabled: true },
      { action: 'delete_blueprint', disabled: true },
    ]);
  });

  it('uses preview meta to derive destruction legend state', () => {
    const items = getDestructionPreviewLegendItems(
      makeData({
        preview_valid: true,
        preview_meta: {
          moved_count: 2,
          fire_count: 0,
          damage_count: 1,
          blast_count: 3,
        },
        ui_fields: [
          makeField({ id: 'persistent_fire_enabled', value: true }),
          makeField({ id: 'blast_enabled', value: false }),
          makeField({
            id: 'damage_profile',
            kind: 'select',
            value: 'none',
          }),
        ],
      }),
    );

    expect(items.map((item) => item.label)).toEqual([
      'Перемещение',
      'Урон',
      'Взрыв',
    ]);
  });

  it('partitions destruction fields and hides invisible scatter steps', () => {
    const model = getDestructionWorkspaceViewModel(
      makeData({
        ui_fields: [
          makeField({ id: 'radius', kind: 'number', value: 3, group: 'Area' }),
          makeField({
            id: 'radius_only_clear_tiles',
            group: 'Area',
            value: true,
          }),
          makeField({
            id: 'radius_only_reachable_tiles',
            group: 'Area',
            value: false,
          }),
          makeField({
            id: 'radius_windows_blockers',
            group: 'Area',
            value: true,
          }),
          makeField({ id: 'safe', group: 'Area' }),
          makeField({ id: 'shuffle_enabled', value: true }),
          makeField({ id: 'scatter_enabled', value: true }),
          makeField({ id: 'max_atoms', kind: 'number', value: 10 }),
          makeField({
            id: 'scatter_steps',
            kind: 'number',
            value: 2,
            visible: false,
          }),
          makeField({ id: 'persistent_fire_enabled', value: false }),
          makeField({
            id: 'persistent_fire_density',
            kind: 'number',
            value: 10,
          }),
          makeField({ id: 'blast_enabled', value: false }),
          makeField({ id: 'blast_power', kind: 'number', value: 100 }),
          makeField({ id: 'blast_falloff', kind: 'number', value: 200 }),
          makeField({
            id: 'damage_profile',
            kind: 'select',
            value: 'none',
          }),
        ],
      }),
    );

    expect(model.areaFields.map((field) => field.id)).toEqual(['safe']);
    expect(
      model.movementFields.visibleMovementFields.map((field) => field.id),
    ).toEqual(['shuffle_enabled', 'scatter_enabled', 'max_atoms']);
    expect(model.movementFields.scatterStepsField).toBeUndefined();
  });

  it('counts history entries by tone buckets', () => {
    const metrics = getHistoryMetrics([
      makeHistoryEntry({ result: 'success' }),
      makeHistoryEntry({ result: 'warning' }),
      makeHistoryEntry({ result: 'error' }),
      makeHistoryEntry({ result: 'success' }),
    ]);

    expect(metrics).toEqual({
      total: 4,
      good: 2,
      average: 1,
      bad: 1,
    });
  });

  it('surfaces canonical outpost labels without legacy ids', () => {
    const {
      getTranslatedFieldLabel,
      translateOptionLabel,
    } = require('./helpers');

    expect(
      getTranslatedFieldLabel(makeField({ id: 'defense_profile' })),
    ).not.toBe('defense_profile');
    expect(
      getTranslatedFieldLabel(makeField({ id: 'layout_variant' })),
    ).not.toBe('layout_variant');
    expect(
      getTranslatedFieldLabel(makeField({ id: 'primary_material_path' })),
    ).not.toBe('primary_material_path');
    expect(
      getTranslatedFieldLabel(makeField({ id: 'secondary_material_path' })),
    ).not.toBe('secondary_material_path');
    expect(
      getTranslatedFieldLabel(
        makeField({ id: 'primary_material_share_percent', kind: 'number' }),
      ),
    ).not.toBe('primary_material_share_percent');
    expect(
      translateOptionLabel('defense_profile', '', 'fallback_redoubt'),
    ).not.toBe('fallback_redoubt');
    expect(translateOptionLabel('layout_variant', '', 'funnel_front')).not.toBe(
      'funnel_front',
    );
    expect(translateOptionLabel('barricade_pattern', '', 'uniform')).not.toBe(
      'uniform',
    );
    expect(
      translateOptionLabel('barricade_pattern', '', 'unexpected_pattern'),
    ).toBe('unexpected_pattern');
  });

  it('surfaces outpost layer labels and option values', () => {
    const {
      getTranslatedFieldLabel,
      translateOptionLabel,
    } = require('./helpers');

    for (const id of [
      'faction',
      'sentry_layer_profile',
      'sentry_type',
      'extra_defense_layer_profile',
      'extra_defense_type',
      'flag_type',
      'wire_layer_profile',
      'wire_offset',
      'wire_rows',
      'wire_row_step',
      'wire_spacing',
      'wire_concentration_percent',
      'minefield_profile',
      'mine_type',
      'minefield_offset',
      'minefield_depth',
      'minefield_density_percent',
      'minefield_seed',
    ]) {
      expect(getTranslatedFieldLabel(makeField({ id }))).not.toBe(id);
    }

    expect(translateOptionLabel('sentry_layer_profile', '', 'guard')).not.toBe(
      'guard',
    );
    expect(
      translateOptionLabel('wire_layer_profile', '', 'perimeter'),
    ).not.toBe('perimeter');
    expect(translateOptionLabel('minefield_profile', '', 'dense')).not.toBe(
      'dense',
    );
  });

  it('keeps outpost custom defense groups visible in the workspace model', () => {
    const uiFields = [
      makeField({
        id: 'defense_profile',
        group: 'Схема',
        kind: 'select',
      }),
      makeField({
        id: 'layout_variant',
        group: 'Схема',
        kind: 'select',
      }),
      makeField({
        id: 'opening_width',
        group: 'Схема',
        kind: 'select',
      }),
      makeField({
        id: 'primary_material_path',
        group: 'Периметр',
        kind: 'select',
      }),
      makeField({ id: 'faction', group: 'IFF', kind: 'select' }),
      makeField({
        id: 'sentry_layer_profile',
        group: 'Defense',
        kind: 'select',
      }),
      makeField({
        id: 'wire_layer_profile',
        group: 'Wire',
        kind: 'select',
      }),
      makeField({
        id: 'minefield_profile',
        group: 'Minefields',
        kind: 'select',
      }),
    ];

    const viewModel = getOutpostWorkspaceViewModel(uiFields);

    expect(viewModel.tacticalProfileField?.id).toBe('defense_profile');
    expect(viewModel.perimeterMaterialFields.map((field) => field.id)).toEqual([
      'primary_material_path',
    ]);
    expect(viewModel.extraGroupNames).toEqual([
      'IFF',
      'Defense',
      'Wire',
      'Minefields',
    ]);
    expect(viewModel.extraFieldGroups.IFF.map((field) => field.id)).toEqual([
      'faction',
    ]);
    expect(viewModel.extraFieldGroups.Defense.map((field) => field.id)).toEqual(
      ['sentry_layer_profile'],
    );
    expect(viewModel.extraFieldGroups.Wire.map((field) => field.id)).toEqual([
      'wire_layer_profile',
    ]);
    expect(
      viewModel.extraFieldGroups.Minefields.map((field) => field.id),
    ).toEqual(['minefield_profile']);
  });

  it('translates fortify labels and option values through canonical ids', () => {
    const {
      getTranslatedFieldLabel,
      translateOptionLabel,
    } = require('./helpers');

    expect(
      getTranslatedFieldLabel(makeField({ id: 'preset_id', kind: 'select' })),
    ).toBe('Пресет');
    expect(
      getTranslatedFieldLabel(
        makeField({ id: 'door_material_family', kind: 'select' }),
      ),
    ).toBe('Материал дверей');
    expect(translateOptionLabel('preset_id', '', 'legacy_metal_wired')).toBe(
      'Металл + проволока',
    );
    expect(translateOptionLabel('material_family', '', 'plasteel')).toBe(
      'Пласталь',
    );
    expect(translateOptionLabel('door_policy', '', 'custom')).toBe('Вручную');
  });

  it('partitions fortify workspace fields into compact config and bounds groups', () => {
    const viewModel = getFortifyWorkspaceViewModel(
      makeData({
        current_generator_id: 'fortify_room',
        ui_fields: [
          makeField({
            id: 'preset_id',
            kind: 'select',
            value: 'legacy_metal',
          }),
          makeField({
            id: 'material_family',
            kind: 'select',
            value: 'metal',
          }),
          makeField({
            id: 'material_wired',
            kind: 'boolean',
            value: false,
          }),
          makeField({
            id: 'door_policy',
            kind: 'select',
            value: 'custom',
          }),
          makeField({
            id: 'door_material_family',
            kind: 'select',
            value: 'plasteel',
          }),
          makeField({
            id: 'door_wired',
            kind: 'boolean',
            value: true,
          }),
          makeField({
            id: 'room_tile_cap',
            kind: 'number',
            value: 195,
          }),
          makeField({
            id: 'treat_windows_as_boundary',
            kind: 'boolean',
            value: true,
          }),
          makeField({
            id: 'fortify_windows',
            kind: 'boolean',
            value: true,
          }),
          makeField({
            id: 'treat_doors_as_boundary',
            kind: 'boolean',
            value: true,
          }),
        ],
      }),
    );

    expect(viewModel.primaryConfigFields.map((field) => field.id)).toEqual([
      'preset_id',
      'material_family',
      'material_wired',
      'door_policy',
    ]);
    expect(viewModel.extraConfigFields.map((field) => field.id)).toEqual([
      'door_material_family',
      'door_wired',
    ]);
    expect(viewModel.boundsFields.map((field) => field.id)).toEqual([
      'room_tile_cap',
      'treat_windows_as_boundary',
      'fortify_windows',
      'treat_doors_as_boundary',
    ]);
  });
});
