import { type ReactNode } from 'react';

export type GeneratorEntry = {
  id: string;
  name_ru: string;
  description_ru: string;
  execution_mode: string;
  required_rights: string;
  supports_preview: boolean;
};

export type GeneratorCategory = {
  category: string;
  generators: GeneratorEntry[];
};

export type UiFieldOption = {
  label: string;
  value: unknown;
  description?: string;
  disabled?: boolean;
  locked?: boolean;
  lockReason?: string;
};

export type UiField = {
  id: string;
  label: string;
  kind: 'select' | 'number' | 'boolean' | 'text';
  value: unknown;
  options?: UiFieldOption[];
  min?: number;
  max?: number;
  step?: number;
  description?: string;
  placeholder?: string;
  group?: string;
  visible?: boolean;
  disabled?: boolean;
  required?: boolean;
  validate_hint?: string;
};

export type RuntimeStatusEntry = {
  label: string;
  value: string;
};

export type HistoryEntry = {
  time: string;
  generator_id: string;
  result: string;
  created_count: number;
  deleted_count: number;
  center_turf: string;
  duration_ms: number;
  params_short: string;
  message: string;
  undo_policy?: string;
  undo_status?: string;
  reverted_count?: number;
  skipped_count?: number;
  operation_id?: string;
  source_operation_id?: string;
  source_generator_id?: string;
};

export type ChangesetSummary = {
  operation_id: string;
  generator_id: string;
  undo_policy: string;
  created_entries: number;
  moved_entries: number;
  changed_turf_entries?: number;
  owned_effect_entries: number;
  created_at: string;
  can_undo: boolean;
  can_cleanup: boolean;
  undo_status: string;
};

export type PlacementOption = {
  label: string;
  value: string;
  description?: string;
  locked?: boolean;
  shape_locked?: boolean;
  request_locked?: boolean;
  lockReason?: string;
  lock_code?: string;
  status?: string;
  can_preview?: boolean;
  can_apply?: boolean;
};

export type BuildingLayoutCapabilityProgram = {
  id: string;
  label?: string;
  suggested_style_id?: string;
  required_slots?: string[];
  required_capabilities?: string[];
};

export type BuildingLayoutCapabilityProvider = {
  id: string;
  label?: string;
  slot_id?: string;
  object_path?: string;
  capabilities?: string[];
};

export type BuildingLayoutCapabilityStyle = {
  id: string;
  label?: string;
  capabilities?: string[];
  providers_by_capability?: Record<string, BuildingLayoutCapabilityProvider[]>;
};

export type BuildingLayoutCompatibilityRow = {
  program_id: string;
  style_id: string;
  supported: boolean;
  lock_code?: string;
  missing_slots?: string[];
  missing_capabilities?: string[];
};

export type BuildingLayoutCapabilityMatrix = {
  programs?: Record<string, BuildingLayoutCapabilityProgram>;
  styles?: Record<string, BuildingLayoutCapabilityStyle>;
  compatibility?: {
    rows?: BuildingLayoutCompatibilityRow[];
    by_key?: Record<string, BuildingLayoutCompatibilityRow>;
  };
};

export type BuildingLayoutGeneratorPayload = {
  schema_version?: number;
  current_program_id?: string;
  current_style_id?: string;
  current_error?: string;
  current_error_code?: string;
  capability_matrix?: BuildingLayoutCapabilityMatrix;
};

export type GeneratorPayload = {
  building_layout?: BuildingLayoutGeneratorPayload;
  [generatorId: string]: unknown;
};

export type PresetEntry = {
  id: string;
  name: string;
  generator_id: string;
  params_short: string;
  created_at: string;
};

export type BlueprintEntry = {
  id: string;
  name: string;
  entry_count: number;
  radius: number;
  footprint_width?: number;
  footprint_height?: number;
  created_at: string;
  created_by: string;
  source: string;
  valid: boolean;
  error: string;
  active?: boolean;
  last_used_rank?: number;
  last_used_at?: string;
  use_count?: number;
  has_outpost_recipe?: boolean;
  outpost_defense_profile?: string;
  outpost_layout_variant?: string;
  preview_mode?: 'detail' | 'compact';
  preview_cells?: BlueprintPreviewCell[];
};

export type ActiveBlueprintPreview = {
  mode?: 'sprite' | 'schematic';
  image_url?: string;
  width?: number;
  height?: number;
  entry_count?: number;
  reason?: string;
};

export type BlueprintPreviewCell = {
  x: number;
  y: number;
  category: string;
  tone: string;
};

export type BackendData = {
  categories: GeneratorCategory[];
  has_generator: boolean;
  current_generator_id?: string;
  current_generator_supports_preview: boolean;
  requires_preview_before_apply: boolean;
  ui_fields: UiField[];
  generator_payload?: GeneratorPayload;
  placement_supported: boolean;
  placement_active: boolean;
  placement_mode: string;
  placement_mode_options: PlacementOption[];
  placement_shape_supported: boolean;
  placement_shape: string;
  placement_shape_options: PlacementOption[];
  placement_shape_fields: UiField[];
  placement_shape_uses_anchor_pair: boolean;
  placement_interaction_kind: string;
  placement_interaction_label: string;
  placement_collector_point_count: number;
  placement_collector_min_points: number;
  placement_collector_max_points: number;
  can_finish_placement_collection: boolean;
  placement_supports_direction: boolean;
  placement_dir: string;
  placement_dir_uses_facing: boolean;
  placement_dir_options: PlacementOption[];
  placement_anchor?: string;
  can_start_placement_mode: boolean;
  can_manage_presets: boolean;
  preset_entries: PresetEntry[];
  blueprint_entries: BlueprintEntry[];
  active_blueprint_id?: string;
  active_blueprint_preview?: ActiveBlueprintPreview;
  can_save_blueprint_from_plan: boolean;
  confirm_before_apply: boolean;
  last_ui_error: string;
  preview_valid: boolean;
  preview_success: boolean;
  preview_message: string;
  preview_meta: Record<string, unknown>;
  runtime_status: RuntimeStatusEntry[];
  runtime_trace: string[];
  last_apply_success: boolean;
  last_apply_message: string;
  last_undo_success: boolean;
  last_undo_message: string;
  last_changeset?: ChangesetSummary;
  click_mode_active: boolean;
  can_run_preview: boolean;
  can_run_apply: boolean;
  can_stop_click_mode: boolean;
  can_undo_last_operation: boolean;
  can_cleanup_last_owned_effects: boolean;
  history_entries: HistoryEntry[];
};

export type SummaryTile = {
  label: string;
  value: ReactNode;
  color?: string;
};

export type PreviewLegendItem = {
  label: string;
  color: string;
};

export type SurfaceTone = 'default' | 'good' | 'average' | 'bad';

export type ChoiceOption = {
  value: string;
  displayText: string;
  tooltip?: string;
  disabled?: boolean;
};

export type ShapeGlyphSpec = {
  glyph: string;
};

export type WorkspaceTabKey = 'editor' | 'history';
export type ToneKey = SurfaceTone | 'label';

export type ToolbarAction = {
  label: string;
  tooltip?: string;
  action: string;
  color?: 'good' | 'average' | 'bad';
  disabled?: boolean;
  payload?: Record<string, unknown>;
};

export type ToolbarActions = {
  previewAction?: ToolbarAction;
  applyAction?: ToolbarAction;
  placementAction?: ToolbarAction;
  collectorAction?: ToolbarAction;
  undoAction?: ToolbarAction;
};

export type ActFn = (action: string, payload?: Record<string, unknown>) => void;

export type ToolWorkspaceProps = {
  data: BackendData;
  act: ActFn;
  groupedFields: Record<string, UiField[]>;
  groupNames: string[];
  showPlacementSetup: boolean;
};
