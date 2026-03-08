import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

const altitudeLabel = (altitudeRequirement) =>
  altitudeRequirement === 'high'
    ? 'Требуется открытое небо'
    : 'Любая видимая точка';

const targetLabel = (allowClosedTurf) =>
  allowClosedTurf ? 'Можно по закрытым тайлам' : 'Только открытый тайл';

const ModeBadge = ({ color, text }) => (
  <Box
    backgroundColor={color}
    bold
    mr={0.5}
    p="2px 6px"
    style={{
      borderRadius: '999px',
      display: 'inline-block',
    }}
  >
    {text}
  </Box>
);

const ActionCard = ({ action }) => (
  <Box
    backgroundColor="rgba(255, 255, 255, 0.04)"
    mb={1}
    p={1}
    style={{
      border: '1px solid rgba(255, 255, 255, 0.08)',
      borderRadius: '4px',
    }}
  >
    <Box bold mb={0.5}>
      {action.name}
    </Box>
    <Box color="label" mb={1}>
      {action.description}
    </Box>
    <LabeledList>
      <LabeledList.Item label="Разброс">{action.scatter}</LabeledList.Item>
      <LabeledList.Item label="Общий КД">
        {action.shared_cooldown} сек.
      </LabeledList.Item>
      <LabeledList.Item label="Личный КД">
        {action.personal_cooldown} сек.
      </LabeledList.Item>
      <LabeledList.Item label="Сектор">
        {action.requires_visibility_zone ? 'Требуется' : 'Не требуется'}
      </LabeledList.Item>
      <LabeledList.Item label="Высотное окно">
        {altitudeLabel(action.altitude_requirement)}
      </LabeledList.Item>
      <LabeledList.Item label="Тип цели">
        {targetLabel(action.allow_closed_turf)}
      </LabeledList.Item>
    </LabeledList>
  </Box>
);

const TemplateCard = ({ template }) => {
  const { act, data } = useBackend();

  return (
    <Section
      title={template.name}
      buttons={
        <Button
          color="good"
          disabled={!data.can_select_template}
          icon="crosshairs"
          onClick={() =>
            act('select_template', {
              template_id: template.template_id,
            })
          }
        >
          Выбрать
        </Button>
      }
    >
      <Box mb={1}>{template.description}</Box>
      <Box mb={1}>
        {template.requires_visibility_zone ? (
          <ModeBadge color="rgba(100, 170, 255, 0.25)" text="Через сектор" />
        ) : (
          <ModeBadge color="rgba(110, 190, 120, 0.25)" text="Без сектора" />
        )}
        {template.visibility_altitude_requirement === 'high' && (
          <ModeBadge color="rgba(255, 170, 90, 0.25)" text="Открытое небо" />
        )}
      </Box>
      <NoticeBox mb={1}>
        <Box bold mb={0.5}>
          Роль пакета
        </Box>
        <Box>{template.role_summary}</Box>
      </NoticeBox>
      <NoticeBox info mb={1}>
        <Box bold mb={0.5}>
          Наведение
        </Box>
        <Box>{template.targeting_summary}</Box>
      </NoticeBox>
      {!!template.restriction_summary && (
        <NoticeBox warning mb={1}>
          {template.restriction_summary}
        </NoticeBox>
      )}
      <LabeledList>
        <LabeledList.Item label="Режим">
          {template.requires_visibility_zone
            ? 'Боевой пакет через сектор'
            : 'Прямой логистический сброс'}
        </LabeledList.Item>
        {template.requires_visibility_zone && (
          <>
            <LabeledList.Item label="Сектор">
              {template.visibility_zone_name}
            </LabeledList.Item>
            <LabeledList.Item label="Тип сектора">
              {template.visibility_zone_type}
            </LabeledList.Item>
            <LabeledList.Item label="Радиус">
              {template.visibility_zone_radius}
            </LabeledList.Item>
            <LabeledList.Item label="Длительность">
              {template.visibility_zone_duration} сек.
            </LabeledList.Item>
            <LabeledList.Item label="Кулдаун сектора">
              {template.visibility_zone_cooldown} сек.
            </LabeledList.Item>
          </>
        )}
        {!template.requires_visibility_zone && (
          <LabeledList.Item label="Сектор">Не используется</LabeledList.Item>
        )}
        <LabeledList.Item label="Высотное окно">
          {altitudeLabel(template.visibility_altitude_requirement)}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box bold mb={1}>
        Способности
      </Box>
      {template.actions.map((action) => (
        <ActionCard key={action.action_id} action={action} />
      ))}
    </Section>
  );
};

export const RtoSupportPresetMenu = () => {
  const { data } = useBackend();
  const templates = data.templates || [];

  return (
    <Window width={760} height={800} resizable>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Пакет поддержки">
              <NoticeBox info>
                Выбор выполняется один раз на жизнь текущего персонажа.
              </NoticeBox>
              <NoticeBox mt={1}>
                1. Выберите темплейт. 2. Для боевых пакетов разверните сектор.
                3. Вооружите нужную кнопку. 4. Наведите точку через Ctrl+Click
                во время зума через RTO-бинокль.
              </NoticeBox>
              <NoticeBox mt={1} warning>
                Logistics работает без сектора и вызывает сбросы напрямую через
                бинокль.
              </NoticeBox>
              {!!data.active_template_name && (
                <NoticeBox warning mt={1}>
                  Уже выбран пакет: {data.active_template_name}
                </NoticeBox>
              )}
            </Section>
          </Stack.Item>
          {!!templates.length &&
            templates.map((template) => (
              <Stack.Item key={template.template_id}>
                <TemplateCard template={template} />
              </Stack.Item>
            ))}
          {!templates.length && (
            <Stack.Item>
              <NoticeBox danger>Нет доступных пресетов поддержки.</NoticeBox>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
