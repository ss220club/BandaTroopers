import {
  DEFAULT_DIRECTION_OPTIONS,
  DEFAULT_POINT_SHAPE_OPTION,
  RADIUS_POLICY_FIELD_IDS,
} from './constants';
import {
  getField,
  getFieldsById,
  getSelectedBlueprint,
  getTranslatedDirection,
  getTranslatedPlacementMode,
  getTranslatedPlacementModeTooltip,
  isBlueprintToolBlocked,
} from './helpers';
import type {
  BackendData,
  ChoiceOption,
  PlacementOption,
  ToolbarAction,
  ToolbarActions,
  UiField,
  WorkspaceTabKey,
} from './types';
import { getBuildingLayoutCapabilityStatus } from './viewModelBuildingLayout';

type EditorChromeViewModel = {
  toolbar: ToolbarActions;
  actionsDisabled: boolean;
  chromeError: string;
  showSharedModeShell: boolean;
  leadingAction?: ToolbarAction;
  centerAction?: ToolbarAction;
  trailingAction?: ToolbarAction;
};

type SharedModeViewModel = {
  sharedFields: UiField[];
  shapeOptions: PlacementOption[];
  modeOptions: ChoiceOption[];
  directionOptions: ChoiceOption[];
  selectedShape: string;
  selectedMode: string;
  selectedDirection: string;
  radiusField?: UiField;
  radiusToggleFields: UiField[];
  activeBlueprint?: ReturnType<typeof getSelectedBlueprint>;
  showRadiusSection: boolean;
  showShapeSection: boolean;
  showModeSection: boolean;
  showDirectionSection: boolean;
  hasTopControls: boolean;
};

const getDisabledBlueprintRadiusToggleFields = (): UiField[] => [
  {
    id: 'radius_only_clear_tiles',
    label: 'Только чистые клетки',
    kind: 'boolean',
    value: true,
    description: 'Недоступно для шаблонов.',
    disabled: true,
  },
  {
    id: 'radius_only_reachable_tiles',
    label: 'Только достижимые клетки',
    kind: 'boolean',
    value: false,
    description: 'Недоступно для шаблонов.',
    disabled: true,
  },
  {
    id: 'radius_windows_blockers',
    label: 'Окна как блокираторы',
    kind: 'boolean',
    value: true,
    description: 'Недоступно для шаблонов.',
    disabled: true,
  },
];

const getToolbarActions = (data: BackendData): ToolbarActions => {
  if (!data.has_generator) {
    return {};
  }

  const isToolBlocked = isBlueprintToolBlocked(data);
  const selectedShapeOption = (data.placement_shape_options || []).find(
    (option) => `${option.value}` === `${data.placement_shape || ''}`,
  );
  const selectedShapeLocked = !!(
    selectedShapeOption?.locked || selectedShapeOption?.shape_locked
  );
  const selectedRequestLocked = !!selectedShapeOption?.request_locked;
  const selectedCanPreview = selectedShapeOption?.can_preview !== false;
  const selectedCanApply = selectedShapeOption?.can_apply !== false;
  const buildingCapabilityStatus = getBuildingLayoutCapabilityStatus(data);
  const generatorRequestLocked = !!buildingCapabilityStatus?.locked;
  const generatorRequestLockReason = buildingCapabilityStatus?.message;
  const hasPlacementControls =
    data.placement_supported ||
    data.placement_shape_supported ||
    data.placement_supports_direction;
  const hasVisiblePreview = !!data.preview_valid;
  const canPreview =
    data.can_run_preview &&
    !data.click_mode_active &&
    !isToolBlocked &&
    !selectedShapeLocked &&
    !selectedRequestLocked &&
    !generatorRequestLocked &&
    selectedCanPreview;
  const canApply =
    data.can_run_apply &&
    !data.click_mode_active &&
    !isToolBlocked &&
    !selectedShapeLocked &&
    !selectedRequestLocked &&
    !generatorRequestLocked &&
    selectedCanApply;
  const canStartPlacement =
    data.can_start_placement_mode &&
    !data.click_mode_active &&
    !isToolBlocked &&
    !selectedShapeLocked &&
    !selectedRequestLocked &&
    !generatorRequestLocked &&
    selectedCanPreview;
  const requestLockTooltip = generatorRequestLocked
    ? generatorRequestLockReason || 'Конфигурация постройки заблокирована'
    : undefined;

  const previewAction: ToolbarAction | undefined =
    data.current_generator_supports_preview
      ? {
          label: 'Просм.',
          tooltip: requestLockTooltip || 'Показать предпросмотр',
          action: 'run_preview',
          color: 'average',
          disabled: !canPreview,
        }
      : undefined;

  if (previewAction) {
    previewAction.action = hasVisiblePreview ? 'clear_preview' : 'run_preview';
    previewAction.color = hasVisiblePreview ? 'good' : 'average';
    previewAction.disabled = hasVisiblePreview ? false : !canPreview;
    previewAction.tooltip = hasVisiblePreview
      ? 'Скрыть предпросмотр'
      : requestLockTooltip || 'Показать предпросмотр';
  }

  const applyAction: ToolbarAction = {
    label: 'Прим.',
    tooltip: requestLockTooltip || 'Применить сразу',
    action: 'run_apply',
    color: 'good',
    disabled: !canApply,
  };

  const effectiveApplyAction = hasPlacementControls ? undefined : applyAction;

  const startPlacementAction: ToolbarAction | undefined = hasPlacementControls
    ? {
        label: 'Разм.',
        tooltip: requestLockTooltip || 'Запустить размещение',
        action: 'start_placement_mode',
        color: 'good',
        disabled: !canStartPlacement,
      }
    : undefined;

  const placePreviewAction: ToolbarAction | undefined =
    hasPlacementControls && hasVisiblePreview
      ? {
          label: 'Разм.',
          tooltip: requestLockTooltip || 'Применить текущее превью',
          action: 'run_apply',
          color: 'good',
          disabled: !canApply,
        }
      : undefined;

  const stopPlacementAction: ToolbarAction = {
    label: 'Стоп',
    tooltip: 'Остановить режим размещения',
    action: 'stop_click_mode',
    color: 'average',
    disabled: !data.can_stop_click_mode,
  };

  const collectorAction: ToolbarAction | undefined =
    data.placement_active && data.placement_interaction_kind === 'collector'
      ? {
          label: 'Готово',
          tooltip: 'Завершить сбор точек',
          action: 'finish_placement_collection',
          color: 'good',
          disabled: !data.can_finish_placement_collection,
        }
      : undefined;

  const undoAction: ToolbarAction = {
    label: 'Откат',
    tooltip: 'Откатить последнее действие',
    action: 'undo_last_operation',
    color: 'average',
    disabled: !data.can_undo_last_operation,
  };

  return {
    previewAction,
    applyAction: effectiveApplyAction,
    placementAction: data.placement_active
      ? stopPlacementAction
      : placePreviewAction || startPlacementAction,
    collectorAction,
    undoAction,
  };
};

const getSharedChromeFields = (data: BackendData) => {
  const shapeFields = (data.placement_shape_fields || []).filter(
    (field) =>
      field.visible !== false &&
      field.id !== 'radius' &&
      !RADIUS_POLICY_FIELD_IDS.includes(field.id),
  );

  if (data.current_generator_id === 'blueprint_stamp') {
    return [
      ...getFieldsById(data.ui_fields, ['stamp_spacing']),
      ...shapeFields,
    ];
  }

  return shapeFields;
};

const getPlacementModeChoices = (data: BackendData): ChoiceOption[] => {
  const options: ChoiceOption[] = [];
  const seenValues = new Set<string>();

  for (const option of data.placement_mode_options || []) {
    const normalizedValue = `${option.value || option.label || ''}`
      .trim()
      .toLowerCase();

    if (!['single', 'repeat'].includes(normalizedValue)) {
      continue;
    }

    if (seenValues.has(normalizedValue)) {
      continue;
    }

    seenValues.add(normalizedValue);
    options.push({
      value: normalizedValue,
      displayText: getTranslatedPlacementMode(normalizedValue),
      tooltip: getTranslatedPlacementModeTooltip(normalizedValue),
    });
  }

  return options.length
    ? options
    : [
        {
          value: 'single',
          displayText: getTranslatedPlacementMode('single'),
          tooltip: getTranslatedPlacementModeTooltip('single'),
        },
        {
          value: 'repeat',
          displayText: getTranslatedPlacementMode('repeat'),
          tooltip: getTranslatedPlacementModeTooltip('repeat'),
        },
      ];
};

const getPlacementShapeOptionsForShell = (
  data: BackendData,
): PlacementOption[] => {
  if (data.placement_shape_options?.length) {
    return data.placement_shape_options;
  }

  if (data.placement_shape) {
    return [
      {
        value: data.placement_shape,
        label: data.placement_shape,
      },
    ];
  }

  return DEFAULT_POINT_SHAPE_OPTION;
};

const getPlacementDirectionChoices = (data: BackendData): ChoiceOption[] => {
  const options = (data.placement_dir_options || []).map((option) => ({
    value: `${option.value || option.label || ''}`.trim().toLowerCase(),
    displayText: getTranslatedDirection(option.value || option.label),
  }));
  return options.length ? options : DEFAULT_DIRECTION_OPTIONS;
};

const hasSharedModeContent = (
  data: BackendData,
  workspaceTab: WorkspaceTabKey,
) => workspaceTab !== 'history' && !!data.has_generator;

const getEditorChromeViewModel = (
  data: BackendData,
  workspaceTab: WorkspaceTabKey,
): EditorChromeViewModel => {
  const toolbar = getToolbarActions(data);
  const centerAction =
    toolbar.placementAction || toolbar.applyAction || toolbar.collectorAction;

  return {
    toolbar,
    actionsDisabled: !data.has_generator,
    chromeError: `${data.last_ui_error || ''}`.trim(),
    showSharedModeShell: hasSharedModeContent(data, workspaceTab),
    leadingAction: toolbar.previewAction,
    centerAction,
    trailingAction:
      toolbar.collectorAction &&
      toolbar.collectorAction.action !== centerAction?.action
        ? toolbar.collectorAction
        : undefined,
  };
};

const getSharedModeViewModel = (
  data: BackendData,
  workspaceTab: WorkspaceTabKey,
): SharedModeViewModel => {
  const isHistoryTab = workspaceTab === 'history';
  const hasGenerator = !!data.has_generator;
  const shapeOptions = getPlacementShapeOptionsForShell(data);
  const modeOptions = getPlacementModeChoices(data);
  const directionOptions = getPlacementDirectionChoices(data);
  const sharedFields = getSharedChromeFields(data).filter(
    (field) => field.visible !== false,
  );
  const radiusField = getField(data.ui_fields, 'radius');
  const radiusToggleFields =
    data.current_generator_id === 'blueprint_stamp'
      ? getDisabledBlueprintRadiusToggleFields()
      : getFieldsById(data.ui_fields, RADIUS_POLICY_FIELD_IDS).filter(
          (field) => field.visible !== false,
        );
  const activeBlueprint =
    data.current_generator_id === 'blueprint_stamp'
      ? getSelectedBlueprint(data)
      : undefined;

  const showRadiusSection =
    !isHistoryTab &&
    hasGenerator &&
    (data.current_generator_id === 'blueprint_stamp' ||
      (!!radiusField && radiusField.visible !== false) ||
      !!radiusToggleFields.length);
  const showShapeSection =
    !isHistoryTab &&
    hasGenerator &&
    data.placement_shape_supported &&
    !!shapeOptions.length;
  const showModeSection =
    !isHistoryTab && hasGenerator && data.placement_supported;
  const showDirectionSection =
    !isHistoryTab && hasGenerator && !!directionOptions.length;
  const hasTopControls =
    showShapeSection ||
    showModeSection ||
    showDirectionSection ||
    showRadiusSection;
  const selectedMode =
    modeOptions.find(
      (option) =>
        option.value === `${data.placement_mode || ''}`.trim().toLowerCase(),
    )?.value ||
    modeOptions[0]?.value ||
    'single';

  return {
    sharedFields,
    shapeOptions,
    modeOptions,
    directionOptions,
    selectedShape: `${data.placement_shape || shapeOptions[0]?.value || 'point'}`,
    selectedMode,
    selectedDirection:
      `${data.placement_dir || directionOptions[0]?.value || 'north'}`
        .trim()
        .toLowerCase(),
    radiusField,
    radiusToggleFields,
    activeBlueprint,
    showRadiusSection,
    showShapeSection,
    showModeSection,
    showDirectionSection,
    hasTopControls,
  };
};

export {
  getEditorChromeViewModel,
  getPlacementDirectionChoices,
  getPlacementModeChoices,
  getPlacementShapeOptionsForShell,
  getSharedChromeFields,
  getSharedModeViewModel,
  getToolbarActions,
  hasSharedModeContent,
};
export type { EditorChromeViewModel, SharedModeViewModel };
