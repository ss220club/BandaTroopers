import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Dropdown, Section, Slider, Stack } from '../components';
import { Window } from '../layouts';
import {
  getTerminalInputWindowProps,
  TerminalInputPresentation,
} from './common/TerminalInputPresentation';

type Data = {
  mode: 'font' | 'size';
  english: boolean;
  font: string;
  size: number;
  fonts: { value: string; displayText: string }[];
  presentation: TerminalInputPresentation;
};

// Optional module-owned settings window; no changes to classic preferences.
export const LobbyTypography = () => {
  const { act, data } = useBackend<Data>();
  const [font, setFont] = useState(data.font);
  const [size, setSize] = useState(data.size);
  const fontMode = data.mode === 'font';
  const english = data.english;
  const previewFont = font === 'default' ? 'monospace' : font;
  return (
    <Window
      width={540}
      height={340}
      theme="crtgreen"
      {...getTerminalInputWindowProps(data.presentation)}
    >
      <Window.Content
        scrollable
        onKeyDown={(event) => {
          if (event.key === 'Escape') {
            event.preventDefault();
            event.stopPropagation();
            act('cancel');
          }
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title={
                fontMode
                  ? english ? 'Font' : 'Шрифт'
                  : english ? 'Text size' : 'Размер текста'
              }
            >
              {fontMode ? (
                <Dropdown
                  width="100%"
                  options={data.fonts}
                  selected={font}
                  displayText={
                    data.fonts.find((option) => option.value === font)?.displayText
                  }
                  onSelected={setFont}
                />
              ) : (
                <Slider
                  minValue={10}
                  maxValue={20}
                  step={1}
                  value={size}
                  onChange={(_, value) => setSize(value)}
                  onDrag={(_, value) => setSize(value)}
                  unit="px"
                />
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title={english ? 'Preview' : 'Предпросмотр'}>
              <Box
                className="BandaTypographyPreview"
                style={{
                  fontFamily: previewFont,
                  fontSize: `${size}px`,
                  lineHeight: '1.5',
                }}
              >
                {english
                  ? 'Personnel terminal — character settings'
                  : 'Терминал персонала — настройки персонажа'}
                <br />
                ABC abc АБВ абв 0123456789
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button onClick={() => act('apply', { font, size })}>
              {english ? 'Apply' : 'Применить'}
            </Button>
            <Button onClick={() => act('cancel')}>
              {english ? 'Cancel' : 'Отмена'}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
