import { getField } from './helpers';
import type {
  BackendData,
  BuildingLayoutCapabilityMatrix,
  BuildingLayoutCompatibilityRow,
  SummaryTile,
  SurfaceTone,
  UiField,
  UiFieldOption,
} from './types';

type BuildingLayoutCapabilityStatus = {
  visible: boolean;
  locked: boolean;
  tone: SurfaceTone;
  title: string;
  message: string;
  items: SummaryTile[];
  row?: BuildingLayoutCompatibilityRow;
};

const normalizeText = (value?: unknown) => `${value ?? ''}`.trim();

const normalizeList = (values?: string[]) =>
  (Array.isArray(values) ? values : [])
    .map((value) => normalizeText(value))
    .filter((value) => value.length > 0);

const joinList = (values?: string[]) => {
  const normalized = normalizeList(values);
  return normalized.length ? normalized.join(', ') : '-';
};

const getMatrixCompatibilityRow = (
  matrix: BuildingLayoutCapabilityMatrix | undefined,
  programId: string,
  styleId: string,
): BuildingLayoutCompatibilityRow | undefined => {
  if (!matrix || !programId || !styleId) {
    return undefined;
  }

  const key = `${programId}|${styleId}`;
  const keyedRow = matrix.compatibility?.by_key?.[key];
  if (keyedRow) {
    return keyedRow;
  }

  return (matrix.compatibility?.rows || []).find(
    (row) => row.program_id === programId && row.style_id === styleId,
  );
};

const getBuildingLayoutIds = (data: BackendData) => {
  const payload = data.generator_payload?.building_layout;
  const programId =
    normalizeText(payload?.current_program_id) ||
    normalizeText(getField(data.ui_fields, 'archetype_id')?.value);
  const styleId =
    normalizeText(payload?.current_style_id) ||
    normalizeText(getField(data.ui_fields, 'faction_preset')?.value);

  return { programId, styleId };
};

const getBuildingLayoutCompatibilityRow = (
  data: BackendData,
): BuildingLayoutCompatibilityRow | undefined => {
  if (data.current_generator_id !== 'building_layout') {
    return undefined;
  }

  const matrix = data.generator_payload?.building_layout?.capability_matrix;
  if (!matrix) {
    return undefined;
  }

  const { programId, styleId } = getBuildingLayoutIds(data);
  if (!programId || !styleId) {
    return undefined;
  }

  return getMatrixCompatibilityRow(matrix, programId, styleId);
};

const getUnsupportedMessage = (
  row: BuildingLayoutCompatibilityRow | undefined,
  currentError?: string,
) => {
  const errorText = normalizeText(currentError);
  if (errorText) {
    return errorText;
  }

  if (!row) {
    return 'Матрица возможностей не содержит выбранное сочетание программы и стиля.';
  }

  if (row.lock_code === 'style.missing_capability') {
    return 'Выбранный стиль не закрывает обязательные функции программы.';
  }

  return 'Выбранное сочетание программы и стиля недоступно.';
};

const getBuildingLayoutCapabilityStatus = (
  data: BackendData,
): BuildingLayoutCapabilityStatus | undefined => {
  if (data.current_generator_id !== 'building_layout') {
    return undefined;
  }

  const payload = data.generator_payload?.building_layout;
  const matrix = payload?.capability_matrix;
  const { programId, styleId } = getBuildingLayoutIds(data);
  if (!matrix || !programId || !styleId) {
    return undefined;
  }

  const row = getBuildingLayoutCompatibilityRow(data);
  const locked = !row || row.supported === false;
  if (!locked) {
    return undefined;
  }

  const lockCode = normalizeText(row?.lock_code) || 'matrix.missing_row';
  const items: SummaryTile[] = [
    { label: 'Программа', value: programId },
    { label: 'Стиль', value: styleId },
    { label: 'Код', value: lockCode, color: 'bad' },
  ];
  const missingCapabilities = normalizeList(row?.missing_capabilities);
  const missingSlots = normalizeList(row?.missing_slots);

  if (missingCapabilities.length) {
    items.push({
      label: 'Нет функций',
      value: joinList(missingCapabilities),
      color: 'bad',
    });
  }

  if (missingSlots.length) {
    items.push({
      label: 'Нет слотов',
      value: joinList(missingSlots),
      color: 'bad',
    });
  }

  return {
    visible: true,
    locked,
    tone: 'bad',
    title: 'Конфигурация постройки заблокирована',
    message: getUnsupportedMessage(row, payload?.current_error),
    items,
    row,
  };
};

const getOptionLockReason = (row: BuildingLayoutCompatibilityRow | undefined) =>
  getUnsupportedMessage(row);

const decorateBuildingLayoutOption = (
  option: UiFieldOption,
  row: BuildingLayoutCompatibilityRow | undefined,
): UiFieldOption => {
  if (row?.supported) {
    return option;
  }

  const lockReason = getOptionLockReason(row);
  const description = normalizeText(option.description);
  return {
    ...option,
    disabled: true,
    locked: true,
    lockReason,
    description: description ? `${description} ${lockReason}` : lockReason,
  };
};

const decorateBuildingLayoutCapabilityFields = (
  data: BackendData,
): UiField[] => {
  const fields = data.ui_fields || [];
  if (data.current_generator_id !== 'building_layout') {
    return fields;
  }

  const matrix = data.generator_payload?.building_layout?.capability_matrix;
  if (!matrix) {
    return fields;
  }

  const { programId, styleId } = getBuildingLayoutIds(data);
  if (!programId || !styleId) {
    return fields;
  }

  return fields.map((field) => {
    if (
      field.id !== 'archetype_id' &&
      field.id !== 'faction_preset' &&
      field.id !== 'style_id'
    ) {
      return field;
    }

    const options = field.options || [];
    if (!options.length) {
      return field;
    }

    return {
      ...field,
      options: options.map((option) => {
        const optionValue = normalizeText(option.value);
        const row =
          field.id === 'archetype_id'
            ? getMatrixCompatibilityRow(matrix, optionValue, styleId)
            : getMatrixCompatibilityRow(matrix, programId, optionValue);
        return decorateBuildingLayoutOption(option, row);
      }),
    };
  });
};

export {
  decorateBuildingLayoutCapabilityFields,
  getBuildingLayoutCapabilityStatus,
  getBuildingLayoutCompatibilityRow,
};
export type { BuildingLayoutCapabilityStatus };
