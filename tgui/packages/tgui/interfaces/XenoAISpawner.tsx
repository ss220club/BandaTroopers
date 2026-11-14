import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Category = {
  name: string;
  castes: string[];
};

type Hive = {
  id: string;
  name: string;
  color: string | null;
};

type SquadEntry = {
  caste: string;
  category: string;
  count: number;
};

type BackendContext = {
  categories: Category[];
  hives: Hive[];
  behaviors: string[];
  max_count: number;
  max_squad_size: number;
  max_squad_radius: number;
  category: string;
  mode: 'single' | 'squad';
  selected_hive: string;
  spawn_ai: BooleanLike;
  selected_caste: string;
  spawn_count: number;
  squad: SquadEntry[];
  squad_radius: number;
  selected_behavior: string;
  spawn_click_intercept: BooleanLike;
  behavior_click_intercept: BooleanLike;
};

const squadSize = (squad: SquadEntry[]) =>
  squad.reduce((total, entry) => total + entry.count, 0);

export const XenoAISpawner = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { categories, category, mode } = data;

  return (
    <Window title="Xeno Spawner" width={620} height={640}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Tabs>
                  {categories.map((entry) => (
                    <Tabs.Tab
                      key={entry.name}
                      selected={entry.name === category}
                      onClick={() =>
                        act('set_category', { category: entry.name })
                      }
                    >
                      {entry.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Stack.Item>
              <Stack.Item>
                <Button
                  selected={mode === 'single'}
                  tooltip="A click spawns a number of the selected caste"
                  onClick={() => act('set_mode', { mode: 'single' })}
                >
                  Single
                </Button>
                <Button
                  selected={mode === 'squad'}
                  tooltip="A click spawns the whole squad around the clicked turf"
                  onClick={() => act('set_mode', { mode: 'squad' })}
                >
                  Squad
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <CasteList />
              </Stack.Item>
              <Divider vertical />
              <Stack.Item width="45%">
                <Stack fill vertical>
                  <Stack.Item grow>
                    <SpawnOptions />
                  </Stack.Item>
                  <Stack.Item>
                    <BehaviorOptions />
                  </Stack.Item>
                  <Stack.Item>
                    <CleanupOptions />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CasteList = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { categories, category, mode, selected_caste, squad, max_count } = data;

  const castes =
    categories.find((entry) => entry.name === category)?.castes || [];

  return (
    <Section fill scrollable title="Castes">
      {castes.map((caste) => {
        if (mode === 'single') {
          return (
            <Box pb={1} key={caste}>
              <Button
                fluid
                fontSize="15px"
                textAlign="center"
                selected={caste === selected_caste}
                onClick={() => act('set_selected_caste', { caste })}
              >
                {caste}
              </Button>
            </Box>
          );
        }

        const count = squad.find((entry) => entry.caste === caste)?.count || 0;
        return (
          <Stack pb={1} key={caste} align="center">
            <Stack.Item grow>
              <Button
                fluid
                fontSize="15px"
                textAlign="center"
                selected={count > 0}
                tooltip="Add one to the squad"
                onClick={() =>
                  act('set_squad_count', { caste, count: count + 1 })
                }
              >
                {caste}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="minus"
                disabled={count <= 0}
                onClick={() =>
                  act('set_squad_count', { caste, count: count - 1 })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                width="3em"
                minValue={0}
                maxValue={max_count}
                step={1}
                value={count}
                onChange={(value) =>
                  act('set_squad_count', { caste, count: value })
                }
              />
            </Stack.Item>
          </Stack>
        );
      })}
    </Section>
  );
};

const SpawnOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    hives,
    mode,
    selected_hive,
    spawn_ai,
    selected_caste,
    spawn_count,
    squad,
    squad_radius,
    spawn_click_intercept,
    max_count,
    max_squad_size,
    max_squad_radius,
  } = data;

  const hive = hives.find((entry) => entry.id === selected_hive);

  return (
    <Section
      fill
      scrollable
      title={mode === 'single' ? selected_caste : 'Squad'}
    >
      <Stack vertical>
        <Stack.Item>
          <Button
            fluid
            fontSize="15px"
            textAlign="center"
            selected={spawn_click_intercept}
            tooltip="LMB to spawn, MMB on a xeno to delete it, MMB on a human, vent or tunnel to open its control menu"
            onClick={() => act('toggle_click_spawn')}
          >
            Click Spawn
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            width="100%"
            options={hives.map((entry) => ({
              value: entry.id,
              displayText: entry.name,
            }))}
            selected={selected_hive}
            displayText={
              <span>
                {!!hive?.color && <ColorBox color={hive.color} mr={1} />}
                {hive?.name || selected_hive}
              </span>
            }
            onSelected={(value) => act('set_selected_hive', { hive: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={spawn_ai}
            onClick={() => act('toggle_spawn_ai')}
          >
            AI
          </Button.Checkbox>
        </Stack.Item>
        {mode === 'single' ? (
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Amount">
                <NumberInput
                  width="4em"
                  minValue={1}
                  maxValue={max_count}
                  step={1}
                  value={spawn_count}
                  onChange={(value) => act('set_spawn_count', { count: value })}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        ) : (
          <>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Radius">
                  <NumberInput
                    width="4em"
                    minValue={0}
                    maxValue={max_squad_radius}
                    step={1}
                    unit="tiles"
                    value={squad_radius}
                    onChange={(value) =>
                      act('set_squad_radius', { radius: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Size">
                  {squadSize(squad)} / {max_squad_size}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Divider />
              {squad.length ? (
                squad.map((entry) => (
                  <Stack key={entry.caste} align="center" pb={0.5}>
                    <Stack.Item grow>
                      {entry.count}x {entry.caste}
                    </Stack.Item>
                    <Stack.Item color="label">{entry.category}</Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        color="bad"
                        onClick={() =>
                          act('set_squad_count', {
                            caste: entry.caste,
                            count: 0,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                ))
              ) : (
                <Box textAlign="center" italic color="label">
                  Pick castes on the left to build a squad
                </Box>
              )}
            </Stack.Item>
            {!!squad.length && (
              <Stack.Item>
                <Button
                  fluid
                  textAlign="center"
                  onClick={() => act('clear_squad')}
                >
                  Clear Squad
                </Button>
              </Stack.Item>
            )}
          </>
        )}
      </Stack>
    </Section>
  );
};

const BehaviorOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { behaviors, selected_behavior, behavior_click_intercept } = data;

  return (
    <Section title="Special Behaviors">
      <Stack vertical>
        <Stack.Item>
          <Dropdown
            width="100%"
            options={behaviors}
            selected={selected_behavior}
            onSelected={(value) =>
              act('set_selected_behavior', { behavior: value })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            textAlign="center"
            selected={behavior_click_intercept}
            tooltip="LMB to place a marker, MMB to remove it"
            onClick={() => act('toggle_click_behavior')}
          >
            Click Behavior
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CleanupOptions = (props) => {
  const { act } = useBackend<BackendContext>();

  return (
    <Section title="Cleanup">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            onClick={() => act('delete_xenos_in_view')}
          >
            Delete viewed
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            color="bad"
            onClick={() => act('delete_all_xenos')}
          >
            Delete all
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
