import type { GeneratorCategory, GeneratorEntry } from './types';

type ToolMeta = {
  id: string;
  order: number;
  titleLabel: string;
  pickerLabel: string;
};

const TOOL_META_REGISTRY: Record<string, ToolMeta> = {
  blueprint_stamp: {
    id: 'blueprint_stamp',
    order: 10,
    titleLabel: 'Штамп по шаблону',
    pickerLabel: 'Шаблон',
  },
  building_layout: {
    id: 'building_layout',
    order: 12,
    titleLabel: 'Постройки',
    pickerLabel: 'Постройки',
  },
  fortify_room: {
    id: 'fortify_room',
    order: 15,
    titleLabel: 'Fortify Room',
    pickerLabel: 'Fortify',
  },
  outpost_radius: {
    id: 'outpost_radius',
    order: 20,
    titleLabel: 'Форпост',
    pickerLabel: 'Форпост',
  },
  destruction_pack: {
    id: 'destruction_pack',
    order: 30,
    titleLabel: 'Разрушение зоны',
    pickerLabel: 'Разрушение',
  },
};

const getToolMeta = (generatorId?: string) =>
  generatorId ? TOOL_META_REGISTRY[generatorId] : undefined;

const getToolTitleLabel = (generatorId?: string) =>
  getToolMeta(generatorId)?.titleLabel;

const getToolPickerLabel = (generatorId?: string) =>
  getToolMeta(generatorId)?.pickerLabel;

const getToolOrder = (generatorId?: string) =>
  getToolMeta(generatorId)?.order ?? Number.MAX_SAFE_INTEGER;

const getOrderedToolTabs = (categories: GeneratorCategory[] = []) => {
  const entries: GeneratorEntry[] = [];

  for (const category of categories || []) {
    for (const generator of category.generators || []) {
      entries.push(generator);
    }
  }

  return [...entries].sort((left, right) => {
    const orderDiff = getToolOrder(left.id) - getToolOrder(right.id);
    if (orderDiff !== 0) {
      return orderDiff;
    }
    return `${left.name_ru}`.localeCompare(`${right.name_ru}`);
  });
};

export { getOrderedToolTabs, getToolPickerLabel, getToolTitleLabel };
