import {
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  NumberInput,
  Slider,
} from '../../components';
import {
  PLACEMENT_SHAPE_GLYPHS,
  SMALL_CHOICE_DROPDOWN_THRESHOLD,
} from './constants';
import {
  getFieldOptionLabel,
  getOrderedShapeValues,
  getPlacementOptionValueSet,
  getTranslatedShapeLabel,
  translateOptionLabel,
} from './helpers';
import type { ActFn, ChoiceOption, PlacementOption, UiField } from './types';

type FieldChoiceOption = {
  value: string;
  displayText: string;
  rawValue: unknown;
  disabled?: boolean;
  tooltip?: string;
};

type FieldControlOptions = {
  readonly forceChoiceStrip?: boolean;
  readonly choiceStripBasis?: string;
};

const ChoiceStrip = (props: {
  readonly options: ChoiceOption[];
  readonly selected: string;
  readonly disabled?: boolean;
  readonly basis?: string;
  readonly onSelected: (value: string) => void;
}) => {
  const { options, selected, disabled, basis, onSelected } = props;
  const itemBasis = basis || (options.length <= 2 ? '45%' : '22%');

  if (!options.length) {
    return <Box color="label">Нет вариантов.</Box>;
  }

  return (
    <Flex wrap mx={-0.15}>
      {options.map((option) => {
        const isSelected = `${option.value}` === `${selected}`;
        const isOptionDisabled = disabled || !!option.disabled;
        return (
          <Flex.Item key={option.value} grow basis={itemBasis} m={0.15}>
            <Button
              compact
              fluid
              selected={isSelected}
              disabled={isOptionDisabled}
              tooltip={option.tooltip}
              onClick={() => onSelected(option.value)}
            >
              {option.displayText}
            </Button>
          </Flex.Item>
        );
      })}
    </Flex>
  );
};

const SmartSelect = (props: {
  readonly options: ChoiceOption[];
  readonly selected: string;
  readonly displayText: string;
  readonly disabled?: boolean;
  readonly placeholder?: string;
  readonly forceDropdown?: boolean;
  readonly onSelected: (value: string) => void;
}) => {
  const {
    options,
    selected,
    displayText,
    disabled,
    placeholder,
    forceDropdown,
    onSelected,
  } = props;

  if (forceDropdown || options.length >= SMALL_CHOICE_DROPDOWN_THRESHOLD) {
    return (
      <Dropdown
        width="100%"
        options={options}
        selected={selected}
        displayText={displayText}
        disabled={disabled || !options.length}
        placeholder={placeholder}
        onSelected={(value) => onSelected(`${value}`)}
      />
    );
  }

  return (
    <ChoiceStrip
      options={options}
      selected={selected}
      disabled={disabled || !options.length}
      onSelected={onSelected}
    />
  );
};

const getFieldChoiceOptions = (field?: UiField): FieldChoiceOption[] =>
  (field?.options || []).map((option) => ({
    value: `${option.value}`,
    displayText: translateOptionLabel(
      field?.id || '',
      option.label,
      option.value,
    ),
    rawValue: option.value,
    disabled: !!(option.disabled || option.locked),
    tooltip: option.lockReason || option.description,
  }));

const getSelectedFieldChoiceValue = (field?: UiField) =>
  `${field?.value ?? ''}`;

const ShapeOptionStrip = (props: {
  readonly options: PlacementOption[];
  readonly selected: string;
  readonly disabled?: boolean;
  readonly onSelected: (value: string) => void;
  readonly buttonMinWidth?: string;
  readonly columns?: number;
  readonly buttonSize?: string;
}) => {
  const {
    options,
    selected,
    disabled,
    onSelected,
    buttonMinWidth = '2rem',
    columns = 5,
    buttonSize = '2rem',
  } = props;
  const availableValues = getPlacementOptionValueSet(options);
  const orderedValues = getOrderedShapeValues(options);

  return (
    <Box
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))`,
        gap: '0.25rem',
      }}
    >
      {orderedValues.map((value) => {
        const option = options.find((entry) => `${entry.value}` === value);
        const label = getTranslatedShapeLabel(value);
        const glyph = PLACEMENT_SHAPE_GLYPHS[value]?.glyph || '•';
        const isAvailable = availableValues.has(value);
        const isLocked = !!(option?.locked || option?.shape_locked);
        const isSelected = isAvailable && value === selected;
        const lockReason = `${option?.lockReason || option?.description || ''}`;
        const tooltip =
          isLocked && lockReason ? `${label}: ${lockReason}` : label;

        return (
          <Button
            key={value}
            compact
            verticalAlignContent="middle"
            selected={isSelected}
            color={isSelected ? 'good' : undefined}
            disabled={disabled || !isAvailable || isLocked}
            tooltip={tooltip}
            onClick={() => onSelected(value)}
            style={{
              width: '100%',
              minWidth: buttonMinWidth,
              height: buttonSize,
              justifyContent: 'center',
            }}
          >
            <Box
              as="span"
              style={{
                display: 'flex',
                width: '100%',
                height: '100%',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '1.05rem',
                lineHeight: '1',
                minWidth: '1rem',
                textAlign: 'center',
              }}
            >
              {glyph}
            </Box>
          </Button>
        );
      })}
    </Box>
  );
};

const CompactChoiceStrip = (props: {
  readonly options: ChoiceOption[];
  readonly selected: string;
  readonly disabled?: boolean;
  readonly onSelected: (value: string) => void;
  readonly buttonMinWidth?: string;
}) => {
  const {
    options,
    selected,
    disabled,
    onSelected,
    buttonMinWidth = '6rem',
  } = props;

  if (!options.length) {
    return <Box color="label">Нет вариантов.</Box>;
  }

  return (
    <Flex wrap mx={-0.12}>
      {options.map((option) => {
        const isSelected = `${option.value}` === `${selected}`;
        const isOptionDisabled = disabled || !!option.disabled;
        return (
          <Flex.Item key={option.value} m={0.12}>
            <Button
              compact
              verticalAlignContent="middle"
              selected={isSelected}
              color={isSelected ? 'good' : undefined}
              disabled={isOptionDisabled}
              tooltip={option.tooltip}
              onClick={() => onSelected(option.value)}
              style={{
                minWidth: buttonMinWidth,
              }}
            >
              {option.displayText}
            </Button>
          </Flex.Item>
        );
      })}
    </Flex>
  );
};

const renderFieldControl = (
  field: UiField,
  act: ActFn,
  options?: FieldControlOptions,
) => {
  const { forceChoiceStrip, choiceStripBasis } = options || {};
  const isDisabled = !!field.disabled;

  const emitValue = (value: unknown) => {
    act('set_param', {
      param_id: field.id,
      value,
    });
  };

  if (field.kind === 'boolean') {
    return (
      <Button.Checkbox
        checked={!!field.value}
        disabled={isDisabled}
        onClick={() => emitValue(!field.value)}
      >
        {field.value ? 'Да' : 'Нет'}
      </Button.Checkbox>
    );
  }

  if (field.kind === 'number') {
    const minValue = Number(field.min);
    const maxValue = Number(field.max);
    const hasBoundedRange =
      Number.isFinite(minValue) &&
      Number.isFinite(maxValue) &&
      maxValue > minValue;
    const rawValue = Number(field.value);
    const numericValue = Number.isFinite(rawValue) ? rawValue : minValue;

    if (hasBoundedRange) {
      const boundedValue = Math.min(Math.max(numericValue, minValue), maxValue);
      return (
        <Slider
          key={`${field.id}_${String(field.label ?? '')}_${String(field.min ?? '')}_${String(field.max ?? '')}`}
          value={boundedValue}
          minValue={minValue}
          maxValue={maxValue}
          step={field.step || 1}
          stepPixelSize={5}
          onChange={
            isDisabled ? undefined : (_event, value) => emitValue(value)
          }
        />
      );
    }

    return (
      <NumberInput
        key={`${field.id}_${String(field.label ?? '')}_${String(field.min ?? '')}_${String(field.max ?? '')}`}
        value={Number(field.value) || 0}
        minValue={field.min ?? -1000000}
        maxValue={field.max ?? 1000000}
        step={field.step || 1}
        width="100%"
        disabled={isDisabled}
        onChange={(value) => emitValue(value)}
      />
    );
  }

  if (field.kind === 'text') {
    return (
      <Input
        key={`${field.id}_${String(field.value ?? '')}`}
        value={`${field.value ?? ''}`}
        disabled={isDisabled}
        placeholder={field.placeholder || ''}
        onChange={(_, value) => emitValue(value)}
      />
    );
  }

  if (field.kind === 'select') {
    const choiceOptions = getFieldChoiceOptions(field);
    const selected = getSelectedFieldChoiceValue(field);
    const hasLockedOptions = choiceOptions.some((option) => option.disabled);
    const handleSelected = (selectedOptionValue: string) => {
      const selectedOption = choiceOptions.find(
        (option) => option.value === `${selectedOptionValue}`,
      );
      emitValue(selectedOption?.rawValue);
    };

    return forceChoiceStrip || hasLockedOptions ? (
      <ChoiceStrip
        options={choiceOptions}
        selected={selected}
        basis={choiceStripBasis}
        disabled={isDisabled || !choiceOptions.length}
        onSelected={handleSelected}
      />
    ) : (
      <SmartSelect
        options={choiceOptions}
        selected={selected}
        displayText={getFieldOptionLabel(field)}
        disabled={isDisabled || !choiceOptions.length}
        placeholder="Выберите значение"
        onSelected={handleSelected}
      />
    );
  }

  return <Box color="bad">Неподдерживаемый тип поля.</Box>;
};

export {
  ChoiceStrip,
  CompactChoiceStrip,
  renderFieldControl,
  ShapeOptionStrip,
  SmartSelect,
};

export type { FieldControlOptions };
