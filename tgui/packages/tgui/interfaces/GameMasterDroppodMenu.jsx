import { useBackend } from '../backend';
import { Button, Collapsible, Divider, Section, Stack } from '../components';
import { Window } from '../layouts';

export const GameMasterDroppodMenu = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Window width={450} height={350}>
      <Window.Content scrollable>
        <Stack direction="column" grow>
          <GameMasterDroppodPanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const GameMasterDroppodPanel = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Section title="Drop Pods" mb={1}>
      <Stack direction="column">
        <Stack.Item>
          <Button
            ml={1}
            selected={data.droppod_click_intercept}
            onClick={() => {
              act('toggle_click_droppod');
            }}
          >
            Click Droppod LZ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="good"
            onClick={() => {
              act('launch_pods');
            }}
          >
            Launch Pods
          </Button>
        </Stack.Item>
        {data.game_master_droppods && (
          <Stack.Item>
            <Collapsible title="Droppod LZ Points">
              <Stack vertical>
                {data.game_master_droppods.map((val, x, y, z) => {
                  if (val) {
                    return (
                      <Stack.Item key={val.droppod_name}>
                        <Divider />
                        <Stack>
                          <Stack.Item align="center">
                            <Button
                              onClick={() => {
                                act('jump_to_droppod', { val });
                              }}
                            >
                              {val.droppod_name}, X:{val.droppod_x}, Y:
                              {val.droppod_y}, Z:{val.droppod_z}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              color="good"
                              onClick={() => {
                                act('set_target', { val });
                              }}
                            >
                              Set Launch Target
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              color="bad"
                              onClick={() => {
                                act('remove_droppod', { val });
                              }}
                            >
                              X
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    );
                  }
                })}
                <Divider />
              </Stack>
            </Collapsible>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
