import { Component, useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, Input, Section } from '../components';
import { globalEvents } from '../events';
import { Window } from '../layouts';
import { getTerminalInputWindowProps } from './common/TerminalInputPresentation';

const KEY_MODS = {
  SHIFT: true,
  ALT: true,
  CONTROL: true,
};

const KEY_CODE_TO_BYOND = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  ' ': 'Space',
  UP: 'North',
};

const getAllKeybinds = (glob_keybinds) => {
  const all_keybinds = new Array();
  Object.keys(glob_keybinds).map((x) => all_keybinds.push(...glob_keybinds[x]));
  return all_keybinds;
};

export const KeyBinds = (props) => {
  const { act, data } = useBackend();
  const {
    player_keybinds,
    glob_keybinds,
    byond_keymap,
    custom_presentation: presentation,
  } = data;
  const labels = presentation?.labels || {};
  const terminalWindowProps = getTerminalInputWindowProps(presentation);
  const windowClassName = presentation
    ? `${terminalWindowProps.className} BandaKeybinds`
    : terminalWindowProps.className;

  const [selectedTab, setSelectedTab] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');
  const [collapsedCategories, setCollapsedCategories] = useState(() => {
    const initialState = {};
    Object.keys(glob_keybinds).forEach((category) => {
      initialState[category] = true;
    });
    return initialState;
  });
  const [activeCategory, setActiveCategory] = useState(null);
  const categories = Object.keys(glob_keybinds);

  const keybinds_to_use =
    searchTerm.length || selectedTab === 'ALL'
      ? getAllKeybinds(glob_keybinds)
      : glob_keybinds[selectedTab];

  const filteredKeybinds = keybinds_to_use.filter((val) =>
    val.full_name.toLowerCase().match(searchTerm),
  );

  const scrollToCategory = (category) => {
    setTimeout(() => {
      document
        .getElementById(`keybind-category-${category}`)
        ?.scrollIntoView({ block: 'start' });
    }, 0);
  };

  const jumpToCategory = (category) => {
    setSearchTerm('');
    setCollapsedCategories((current) => ({
      ...current,
      [category]: false,
    }));
    setActiveCategory(category);
    scrollToCategory(category);
  };

  const toggleCategory = (category) => {
    setCollapsedCategories((current) => ({
      ...current,
      [category]: !current[category],
    }));
  };

  const revealKeybind = (keybindName) => {
    if (presentation) {
      const category = categories.find((categoryName) =>
        glob_keybinds[categoryName].some(
          (keybind) => keybind.name === keybindName,
        ),
      );
      if (category) {
        setSearchTerm('');
        setCollapsedCategories((current) => ({
          ...current,
          [category]: false,
        }));
        setActiveCategory(category);
      }
    }
    setTimeout(() => {
      document
        .getElementById(keybindName)
        ?.scrollIntoView({ block: 'center' });
    }, 0);
  };

  return (
    <Window
      width={presentation ? 520 : 400}
      height={presentation ? 600 : 500}
      resizable
      {...terminalWindowProps}
      className={windowClassName}
    >
      <Window.Content scrollable>
        <Flex direction="column">
          <Flex.Item>
            <Section
              className="BandaKeybinds__controls"
              title={labels.settings || 'Settings'}
              buttons={
                <Flex.Item>
                  <Button
                    color="red"
                    icon="undo"
                    onClick={() => act('clear_all_keybinds')}
                  >
                    {labels.reset || 'Reset to Default'}
                  </Button>
                </Flex.Item>
              }
            >
              <Flex direction="column">
                <Flex.Item>
                  <Flex
                    className={presentation ? 'BandaKeybinds__search' : undefined}
                    align={presentation ? 'center' : 'baseline'}
                    mt={presentation ? undefined : '5px'}
                  >
                    <Flex.Item grow>
                      <Input
                        value={searchTerm}
                        onInput={(_, value) =>
                          setSearchTerm(value.toLowerCase())
                        }
                        placeholder={labels.search || 'Search...'}
                        fluid
                      />
                    </Flex.Item>
                    <Flex.Item>
                      <ButtonKeybind
                        tooltip={labels.search_by_key || 'Search by key'}
                        tooltipPosition="bottom-start"
                        icon="keyboard"
                        onFinish={(keysDown) => {
                          // The key(s) pressed by the user, byond-ified.
                          const targetKey = keysDown
                            .map((k) => byond_keymap[k] || k)
                            .join('+');
                          // targetKey's entry in player_keybinds.
                          const targetEntry = player_keybinds[targetKey];
                          if (!targetEntry) {
                            return;
                          }
                          // If a keybind was found, scroll to the first match currently rendered.
                          for (let i = 0; i < targetEntry.length; i++) {
                            const element = document.getElementById(
                              targetEntry[i],
                            );
                            if (element || presentation) {
                              revealKeybind(targetEntry[i]);
                              break;
                            }
                          }
                        }}
                      />
                    </Flex.Item>
                  </Flex>
                </Flex.Item>
                <Flex.Item>
                  {presentation ? (
                    <KeybindQuickNavigation
                      categories={categories}
                      activeCategory={activeCategory}
                      onJump={jumpToCategory}
                    />
                  ) : (
                    <>
                      <Box height="5px" />
                      <KeybindsDropdown
                        selectedTab={selectedTab}
                        setSelectedTab={setSelectedTab}
                        searchTerm={searchTerm}
                        labels={labels}
                      />
                    </>
                  )}
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex direction="column">
            {presentation ? (
              searchTerm.length ? (
                filteredKeybinds.map((keybind) => (
                  <Flex.Item key={keybind.full_name}>
                    <KeybindElement
                      keybind={keybind}
                      labels={labels}
                      compact
                    />
                    <Box
                      className="BandaKeybinds__legacySeparator"
                      backgroundColor="rgba(40, 40, 40, 255)"
                      width="100%"
                      height="2px"
                      mt="2px"
                    />
                  </Flex.Item>
                ))
              ) : (
                categories.map((category) => {
                  const collapsed = !!collapsedCategories[category];
                  return (
                    <Flex.Item key={category}>
                      <Section
                        container_id={`keybind-category-${category}`}
                        className={`BandaKeybinds__category${
                          collapsed ? ' BandaKeybinds__category--collapsed' : ''
                        }`}
                        title={category}
                        buttons={
                          <Button
                            className="BandaKeybinds__collapse"
                            icon={collapsed ? 'chevron-down' : 'chevron-up'}
                            tooltip={
                              collapsed
                                ? labels.expand || 'Expand category'
                                : labels.collapse || 'Collapse category'
                            }
                            onClick={() => toggleCategory(category)}
                          />
                        }
                      >
                        {!collapsed && (
                          <Flex direction="column">
                            {glob_keybinds[category].map((keybind) => (
                              <Flex.Item key={keybind.name}>
                                <KeybindElement
                                  keybind={keybind}
                                  labels={labels}
                                  compact
                                />
                                <Box
                                  className="BandaKeybinds__legacySeparator"
                                  backgroundColor="rgba(40, 40, 40, 255)"
                                  width="100%"
                                  height="2px"
                                  mt="2px"
                                />
                              </Flex.Item>
                            ))}
                          </Flex>
                        )}
                      </Section>
                    </Flex.Item>
                  );
                })
              )
            ) : selectedTab === 'ALL' && !searchTerm.length ? (
              Object.keys(glob_keybinds).map((category) => (
                <Flex.Item key={category}>
                  <Section title={category}>
                    <Flex direction="column">
                      {glob_keybinds[category].map((keybind) => (
                        <Flex.Item key={keybind.name}>
                          <KeybindElement
                            keybind={keybind}
                            labels={labels}
                            compact={!!presentation}
                          />
                          <Box
                            className="BandaKeybinds__legacySeparator"
                            backgroundColor="rgba(40, 40, 40, 255)"
                            width="100%"
                            height="2px"
                            mt="2px"
                          />
                        </Flex.Item>
                      ))}
                    </Flex>
                  </Section>
                </Flex.Item>
              ))
            ) : (
              filteredKeybinds.map((keybind) => (
                <Flex.Item key={keybind.full_name}>
                  <KeybindElement
                    keybind={keybind}
                    labels={labels}
                    compact={!!presentation}
                  />
                  <Box
                    className="BandaKeybinds__legacySeparator"
                    backgroundColor="rgba(40, 40, 40, 255)"
                    width="100%"
                    height="2px"
                    mt="2px"
                  />
                </Flex.Item>
              ))
            )}
          </Flex>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const KeybindQuickNavigation = (props) => {
  const { categories, activeCategory, onJump } = props;

  return (
    <Box className="BandaKeybinds__quickNav">
      <Flex wrap="wrap">
        {categories.map((category) => (
          <Flex.Item key={category}>
            <Button
              selected={activeCategory === category}
              onClick={() => onJump(category)}
            >
              {category}
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Box>
  );
};

const KeybindsDropdown = (props) => {
  const { data } = useBackend();
  const { glob_keybinds } = data;
  const { selectedTab, setSelectedTab, searchTerm, labels } = props;

  const dropdownOptions = [
    { displayText: labels.all || 'ALL', value: 'ALL' },
    ...Object.keys(glob_keybinds),
  ];

  return (
    <Dropdown
      width="360px"
      menuWidth="360px"
      selected={selectedTab}
      displayText={selectedTab === 'ALL' ? labels.all || 'ALL' : selectedTab}
      options={dropdownOptions}
      disabled={searchTerm.length}
      onSelected={(value) => setSelectedTab(value)}
    />
  );
};

export const KeybindElement = (props) => {
  const { act, data } = useBackend();
  const { keybind, labels = {}, compact } = props;
  const { player_keybinds } = data;

  const currentBoundKeys = [];

  for (const [key, value] of Object.entries(player_keybinds)) {
    for (let i = 0; i < value.length; i++) {
      if (value[i] === keybind.name) {
        currentBoundKeys.push(key);
        break;
      }
    }
  }

  return (
    <Flex
      id={keybind.name}
      className={compact ? 'BandaKeybinds__row' : undefined}
      align={compact ? 'center' : undefined}
      mt={compact ? undefined : 1}
    >
      <Flex.Item
        className={compact ? 'BandaKeybinds__name' : undefined}
        basis={compact ? '44%' : '30%'}
      >
        <Box
          fontSize={compact ? undefined : '115%'}
          color="label"
          textAlign={compact ? undefined : 'center'}
        >
          {keybind.full_name}
        </Box>
      </Flex.Item>
      <Flex.Item
        className={compact ? 'BandaKeybinds__bindings' : undefined}
        grow={1}
      >
        <Flex
          direction={compact ? undefined : 'column'}
          wrap={compact ? 'wrap' : undefined}
        >
          {currentBoundKeys.length ? (
            currentBoundKeys.map((val) => (
              <Flex.Item key={val}>
                <ButtonKeybind
                  color="transparent"
                  content={val}
                  onFinish={(keysDown) => {
                    const mods = keysDown.filter((k) => KEY_MODS[k]);
                    const keys = keysDown.filter((k) => !KEY_MODS[k]);
                    if (keys.length === 0) {
                      if (mods.length >= 0) {
                        keys.push(mods.pop());
                      }
                    }
                    act('set_keybind', {
                      keybind_name: keybind.name,
                      old_key: val,
                      key_mods: mods,
                      key: keys.length === 0 ? false : keys[0],
                    });
                  }}
                />
              </Flex.Item>
            ))
          ) : compact ? (
            <Box className="BandaKeybinds__unbound">—</Box>
          ) : null}
        </Flex>
      </Flex.Item>
      <Flex.Item className={compact ? 'BandaKeybinds__actions' : undefined}>
        <ButtonKeybind
          icon="plus"
          color="transparent"
          tooltip={compact ? labels.add || 'Add key' : undefined}
          onFinish={(keysDown) => {
            const mods = keysDown.filter((k) => KEY_MODS[k]);
            const keys = keysDown.filter((k) => !KEY_MODS[k]);
            if (keys.length === 0) {
              if (mods.length >= 0) {
                keys.push(mods.pop());
              } else return;
            }
            act('set_keybind', {
              keybind_name: keybind.name,
              key_mods: mods,
              key: keys[0],
            });
          }}
        />
        <Button
          onClick={() =>
            act('clear_keybind', {
              keybinding: keybind.name,
              key: currentBoundKeys,
            })
          }
        >
          {labels.clear || 'Clear'}
        </Button>
      </Flex.Item>
    </Flex>
  );
};

export class ButtonKeybind extends Component {
  constructor() {
    super();
    this.state = {
      focused: false,
      keysDown: {},
    };
  }

  preventPassthrough(key) {
    key.event.preventDefault();
  }

  doFinish() {
    const { onFinish } = this.props;
    const { keysDown } = this.state;

    const listOfKeys = Object.keys(keysDown).filter(
      (isTrue) => keysDown[isTrue],
    );

    onFinish(listOfKeys);
    document.activeElement.blur();
    clearInterval(this.timer);
  }

  handleKeyPress(e) {
    const { keysDown } = this.state;

    e.preventDefault();

    let pressedKey = e.key.toUpperCase();

    this.finishTimerStart(600);

    // Prevents repeating
    if (keysDown[pressedKey] && e.type === 'keydown') {
      return;
    }

    if (KEY_CODE_TO_BYOND[pressedKey]) {
      pressedKey = KEY_CODE_TO_BYOND[pressedKey];
    }

    if (e.keyCode >= 96 && e.keyCode <= 105) {
      pressedKey = 'Numpad' + pressedKey;
    }

    keysDown[pressedKey] = e.type === 'keydown';
    this.setState({
      keysDown: keysDown,
    });
  }

  finishTimerStart(time) {
    clearInterval(this.timer);
    this.timer = setInterval(() => this.doFinish(), time);
  }

  doFocus() {
    this.setState({
      focused: true,
      keysDown: {},
    });
    this.finishTimerStart(2000);
    globalEvents.on('keydown', this.preventPassthrough);
    globalEvents.on('key', this.preventPassthrough);
    globalEvents.on('keyup', this.preventPassthrough);
  }

  doBlur() {
    this.setState({
      focused: false,
      keysDown: {},
    });
    globalEvents.off('keydown', this.preventPassthrough);
    globalEvents.off('key', this.preventPassthrough);
    globalEvents.off('keyup', this.preventPassthrough);
  }

  render() {
    const { focused, keysDown } = this.state;
    const { content, ...rest } = this.props;

    return (
      <Button
        {...rest}
        selected={focused}
        inline
        onClick={(e) => {
          if (focused && Object.keys(keysDown).length) {
            this.doFinish();
            e.preventDefault();
          }
        }}
        onFocus={() => this.doFocus()}
        onBlur={() => this.doBlur()}
        onKeyDown={(e) => this.handleKeyPress(e)}
      >
        {focused
          ? Object.keys(keysDown)
              .filter((isTrue) => keysDown[isTrue])
              .join('+') || content
          : content}
      </Button>
    );
  }
}
