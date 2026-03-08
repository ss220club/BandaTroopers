// SS220 EDIT - START: Game Rule Panel TGUI interface
import { useEffect, useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const PAGES = [
  {
    id: 'rto',
    title: 'RTO Support',
    color: 'blue',
    icon: 'satellite-dish',
  },
  {
    id: 'fire_support',
    title: 'Fire Support',
    color: 'orange',
    icon: 'crosshairs',
  },
];

const sanitizeNumberInputValue = (value, fallback) =>
  typeof value === 'number' && Number.isFinite(value) ? value : fallback;

const FactionBadge = ({ faction }) => (
  <Box
    backgroundColor="rgba(255, 255, 255, 0.08)"
    inline
    mr={0.5}
    p="2px 6px"
    style={{
      borderRadius: '999px',
    }}
  >
    {faction}
  </Box>
);

const FireSupportEntryButton = ({ entry, enabled }) => {
  const { act } = useBackend();

  return (
    <Button
      fluid
      mb={0.5}
      textAlign="left"
      color={enabled ? 'good' : 'average'}
      onClick={() =>
        act('set_fire_support_type_enabled', {
          type_id: entry.type_id,
          enabled: enabled ? 0 : 1,
        })
      }
    >
      <Box bold>{entry.name}</Box>
      <Box color="label">
        <FactionBadge faction={entry.faction} />
        Cost: {entry.cost} | Cooldown: {entry.cooldown_duration}s
        {!!entry.fire_support_firer && ` | Firer: ${entry.fire_support_firer}`}
      </Box>
    </Button>
  );
};

const RtoSupportPage = ({
  data,
  sharedMultiplier,
  personalMultiplier,
  setSharedMultiplier,
  setPersonalMultiplier,
}) => {
  const { act } = useBackend();
  const safeSharedMultiplier = sanitizeNumberInputValue(sharedMultiplier, 1);
  const safePersonalMultiplier = sanitizeNumberInputValue(
    personalMultiplier,
    1,
  );

  return (
    <Section fill title="RTO Support">
      <Section level={2} title="General">
        <Button.Checkbox
          checked={!!data.rto_support_enabled}
          fluid
          onClick={() =>
            act('set_rto_support_enabled', {
              enabled: data.rto_support_enabled ? 0 : 1,
            })
          }
        >
          Enable RTO Support
        </Button.Checkbox>
      </Section>

      <Section level={2} title="Cooldown Modifiers">
        <Stack vertical>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Box bold>Shared cooldown multiplier</Box>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  minValue={0.1}
                  maxValue={10}
                  step={0.1}
                  stepPixelSize={20}
                  value={safeSharedMultiplier}
                  width="6em"
                  onChange={(value) =>
                    setSharedMultiplier(sanitizeNumberInputValue(value, 1))
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="good"
                  onClick={() =>
                    act('set_rto_shared_multiplier', {
                      value: safeSharedMultiplier,
                    })
                  }
                >
                  Apply
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Box bold>Personal cooldown multiplier</Box>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  minValue={0.1}
                  maxValue={10}
                  step={0.1}
                  stepPixelSize={20}
                  value={safePersonalMultiplier}
                  width="6em"
                  onChange={(value) =>
                    setPersonalMultiplier(sanitizeNumberInputValue(value, 1))
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="good"
                  onClick={() =>
                    act('set_rto_personal_multiplier', {
                      value: safePersonalMultiplier,
                    })
                  }
                >
                  Apply
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>

        <NoticeBox mt={1}>Current cooldowns are not recalculated.</NoticeBox>
      </Section>

      <Section level={2} title="Reset">
        <Button
          color="average"
          icon="undo"
          onClick={() => act('reset_rto_rules')}
        >
          Reset to defaults
        </Button>
      </Section>
    </Section>
  );
};

const FireSupportPage = ({ data, grantAmounts, setGrantAmounts }) => {
  const { act } = useBackend();
  const fireSupportPoints = data.fire_support_points || [];
  const enabledEntries = data.fire_support_enabled_entries || [];
  const disabledEntries = data.fire_support_disabled_entries || [];

  return (
    <Section fill title="Fire Support">
      <Section level={2} title="General">
        <Button.Checkbox
          checked={!!data.fire_support_enabled}
          fluid
          onClick={() =>
            act('set_fire_support_enabled', {
              enabled: data.fire_support_enabled ? 0 : 1,
            })
          }
        >
          Enable Fire Support
        </Button.Checkbox>
      </Section>

      <Section level={2} title="Support Points">
        <Stack vertical>
          {fireSupportPoints.map((entry) => {
            const safeGrantAmount = sanitizeNumberInputValue(
              grantAmounts[entry.faction],
              0,
            );

            return (
              <Stack.Item key={entry.faction}>
                <Stack align="center">
                  <Stack.Item grow>
                    <Box bold>{entry.faction}</Box>
                    <Box color="label">Current points: {entry.points}</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <NumberInput
                      minValue={0}
                      maxValue={9999}
                      step={1}
                      stepPixelSize={10}
                      value={safeGrantAmount}
                      width="6em"
                      onChange={(value) =>
                        setGrantAmounts((prev) => ({
                          ...prev,
                          [entry.faction]: sanitizeNumberInputValue(value, 0),
                        }))
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      color="good"
                      onClick={() => {
                        act('grant_fire_support_points', {
                          faction: entry.faction,
                          amount: safeGrantAmount,
                        });
                        setGrantAmounts((prev) => ({
                          ...prev,
                          [entry.faction]: 0,
                        }));
                      }}
                    >
                      Grant
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            );
          })}
        </Stack>
      </Section>

      <Section level={2} title="Support Pool">
        <Stack>
          <Stack.Item grow={1} basis={0}>
            <Section fill title={`Disabled (${disabledEntries.length})`}>
              {disabledEntries.map((entry) => (
                <FireSupportEntryButton
                  key={entry.type_id}
                  entry={entry}
                  enabled={false}
                />
              ))}
              {!disabledEntries.length && (
                <NoticeBox>No disabled entries.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            <Section fill title={`Enabled (${enabledEntries.length})`}>
              {enabledEntries.map((entry) => (
                <FireSupportEntryButton
                  key={entry.type_id}
                  entry={entry}
                  enabled
                />
              ))}
              {!enabledEntries.length && (
                <NoticeBox>No enabled entries.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Section>

      <Section level={2} title="Reset">
        <Button
          color="average"
          icon="undo"
          onClick={() => act('reset_fire_support_rules')}
        >
          Reset to defaults
        </Button>
      </Section>
    </Section>
  );
};

export const GameRulePanel = () => {
  const { data } = useBackend();
  const [page, setPage] = useState('rto');
  const [sharedMultiplier, setSharedMultiplier] = useState(
    sanitizeNumberInputValue(data.rto_shared_cooldown_multiplier, 1),
  );
  const [personalMultiplier, setPersonalMultiplier] = useState(
    sanitizeNumberInputValue(data.rto_personal_cooldown_multiplier, 1),
  );
  const [grantAmounts, setGrantAmounts] = useState({});

  useEffect(() => {
    setSharedMultiplier(
      sanitizeNumberInputValue(data.rto_shared_cooldown_multiplier, 1),
    );
  }, [data.rto_shared_cooldown_multiplier]);

  useEffect(() => {
    setPersonalMultiplier(
      sanitizeNumberInputValue(data.rto_personal_cooldown_multiplier, 1),
    );
  }, [data.rto_personal_cooldown_multiplier]);

  useEffect(() => {
    setGrantAmounts((prev) => {
      const next = {};
      (data.fire_support_points || []).forEach((entry) => {
        next[entry.faction] = sanitizeNumberInputValue(prev[entry.faction], 0);
      });
      return next;
    });
  }, [data.fire_support_points]);

  return (
    <Window title="Game Rule Panel" width={980} height={720} resizable>
      <Window.Content scrollable>
        <Stack grow>
          <Stack.Item>
            <Section fitted>
              <Tabs vertical>
                {PAGES.map((entry) => (
                  <Tabs.Tab
                    key={entry.id}
                    color={entry.color}
                    icon={entry.icon}
                    selected={page === entry.id}
                    onClick={() => setPage(entry.id)}
                  >
                    {entry.title}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1} basis={0} ml={1}>
            {page === 'rto' && (
              <RtoSupportPage
                data={data}
                sharedMultiplier={sharedMultiplier}
                personalMultiplier={personalMultiplier}
                setSharedMultiplier={setSharedMultiplier}
                setPersonalMultiplier={setPersonalMultiplier}
              />
            )}
            {page === 'fire_support' && (
              <FireSupportPage
                data={data}
                grantAmounts={grantAmounts}
                setGrantAmounts={setGrantAmounts}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
// SS220 EDIT - END
