import type { BackendData, BlueprintEntry } from './types';

type BlueprintFilterMode = 'all' | 'valid' | 'invalid' | 'active';
type BlueprintLibraryActionId =
  | 'load_blueprint'
  | 'preview_blueprint'
  | 'apply_blueprint'
  | 'export_blueprint'
  | 'rename_blueprint'
  | 'delete_blueprint';
type BlueprintSortMode =
  | 'recent'
  | 'status'
  | 'name_asc'
  | 'name_desc'
  | 'newest'
  | 'oldest'
  | 'size_desc'
  | 'size_asc'
  | 'entries_desc'
  | 'entries_asc';

const compareBlueprintText = (left: unknown, right: unknown) =>
  `${left || ''}`.localeCompare(`${right || ''}`);

const compareBlueprintNames = (left: BlueprintEntry, right: BlueprintEntry) => {
  const nameDiff = compareBlueprintText(left.name, right.name);
  if (nameDiff !== 0) {
    return nameDiff;
  }
  return compareBlueprintText(left.id, right.id);
};

const getBlueprintFootprintText = (blueprint: BlueprintEntry) => {
  const width = Math.max(Number(blueprint.footprint_width) || 0, 0);
  const height = Math.max(Number(blueprint.footprint_height) || 0, 0);
  if (width > 0 && height > 0) {
    return `${width}x${height}`;
  }

  const fallbackSpan = Math.max((Number(blueprint.radius) || 0) * 2 + 1, 0);
  if (fallbackSpan > 0) {
    return `${fallbackSpan}x${fallbackSpan}`;
  }

  return '0x0';
};

const getBlueprintFootprintArea = (blueprint: BlueprintEntry) => {
  const width = Number(blueprint.footprint_width) || 0;
  const height = Number(blueprint.footprint_height) || 0;
  if (width > 0 && height > 0) {
    return width * height;
  }
  return Number(blueprint.entry_count) || 0;
};

const getBlueprintLastUsedRank = (blueprint: BlueprintEntry) =>
  Math.max(Number(blueprint.last_used_rank) || 0, 0);

const getBlueprintEntryCount = (blueprint: BlueprintEntry) =>
  Math.max(Number(blueprint.entry_count) || 0, 0);

const getBlueprintPreviewMode = (blueprint: BlueprintEntry) =>
  blueprint.preview_mode === 'compact' ? 'compact' : 'detail';

const compareBlueprintStatus = (
  data: BackendData,
  left: BlueprintEntry,
  right: BlueprintEntry,
) => {
  const leftState = getBlueprintActionState(data, left);
  const rightState = getBlueprintActionState(data, right);
  if (leftState.isActive !== rightState.isActive) {
    return leftState.isActive ? -1 : 1;
  }
  if (left.valid !== right.valid) {
    return left.valid ? -1 : 1;
  }
  return compareBlueprintNames(left, right);
};

const compareBlueprintNumber = (
  leftValue: number,
  rightValue: number,
  descending: boolean,
) => (descending ? rightValue - leftValue : leftValue - rightValue);

const getBlueprintActionState = (
  data: BackendData,
  blueprint: BlueprintEntry,
) => {
  const isActive = blueprint.id === data.active_blueprint_id;
  const canLoad = blueprint.valid && !isActive;
  const canPreview = blueprint.valid && !data.click_mode_active;
  const canApply =
    blueprint.valid && isActive && data.preview_valid && data.can_run_apply;

  return {
    isActive,
    canLoad,
    canPreview,
    canApply,
  };
};

const getBlueprintLibraryActions = (
  data: BackendData,
  blueprint: BlueprintEntry,
) => {
  const actionState = getBlueprintActionState(data, blueprint);
  return [
    {
      action: 'load_blueprint',
      disabled: !actionState.canLoad,
    },
    {
      action: 'preview_blueprint',
      disabled: !actionState.canPreview,
    },
    {
      action: 'apply_blueprint',
      disabled: !actionState.canApply,
    },
    {
      action: 'export_blueprint',
      disabled: !blueprint.valid,
    },
    {
      action: 'rename_blueprint',
      disabled: !blueprint.valid,
    },
    {
      action: 'delete_blueprint',
      disabled: !blueprint.valid,
    },
  ] satisfies Array<{ action: BlueprintLibraryActionId; disabled: boolean }>;
};

const filterAndSortBlueprintEntries = (
  data: BackendData,
  entries: BlueprintEntry[],
  filterMode: BlueprintFilterMode,
  sortMode: BlueprintSortMode,
) => {
  const filteredEntries = (entries || []).filter((entry) => {
    if (filterMode === 'valid') {
      return entry.valid;
    }
    if (filterMode === 'invalid') {
      return !entry.valid;
    }
    if (filterMode === 'active') {
      return entry.id === data.active_blueprint_id;
    }
    return true;
  });

  return [...filteredEntries].sort((left, right) => {
    if (sortMode === 'name_asc') {
      return compareBlueprintNames(left, right);
    }
    if (sortMode === 'name_desc') {
      return compareBlueprintNames(right, left);
    }
    if (sortMode === 'newest') {
      const dateDiff = compareBlueprintText(right.created_at, left.created_at);
      return dateDiff || compareBlueprintNames(left, right);
    }
    if (sortMode === 'oldest') {
      const dateDiff = compareBlueprintText(left.created_at, right.created_at);
      return dateDiff || compareBlueprintNames(left, right);
    }
    if (sortMode === 'size_desc' || sortMode === 'size_asc') {
      const leftArea = getBlueprintFootprintArea(left);
      const rightArea = getBlueprintFootprintArea(right);
      const areaDiff = compareBlueprintNumber(
        leftArea,
        rightArea,
        sortMode === 'size_desc',
      );
      if (areaDiff !== 0) {
        return areaDiff;
      }
      return compareBlueprintNames(left, right);
    }
    if (sortMode === 'entries_desc' || sortMode === 'entries_asc') {
      const entryDiff = compareBlueprintNumber(
        getBlueprintEntryCount(left),
        getBlueprintEntryCount(right),
        sortMode === 'entries_desc',
      );
      if (entryDiff !== 0) {
        return entryDiff;
      }
      return compareBlueprintNames(left, right);
    }
    if (sortMode === 'status') {
      return compareBlueprintStatus(data, left, right);
    }

    const rankDiff =
      getBlueprintLastUsedRank(right) - getBlueprintLastUsedRank(left);
    if (rankDiff !== 0) {
      return rankDiff;
    }
    return compareBlueprintStatus(data, left, right);
  });
};

export {
  filterAndSortBlueprintEntries,
  getBlueprintActionState,
  getBlueprintFootprintText,
  getBlueprintLibraryActions,
  getBlueprintPreviewMode,
};
export type {
  BlueprintFilterMode,
  BlueprintLibraryActionId,
  BlueprintSortMode,
};
