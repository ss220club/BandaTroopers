import { useState } from 'react';
// SS220 DemonicLynx "Lobby UI" - reuse the standard close action for terminal Esc.
import { backendSuspendStart, globalStore, useBackend } from 'tgui/backend';
import { Button, Section, Stack, Tabs, TextArea } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { getTerminalInputWindowProps } from './common/TerminalInputPresentation';

type Data = {
  general: string;
  head: string;
  face: string;
  eyes: string;
  torso: string;
  arms: string;
  hands: string;
  legs: string;
  feet: string;
  helmet: string;
  armor: string;
  categories: Array<string>;
  custom_presentation?: {
    accent_color?: string;
    theme?: string;
    class_name?: string;
    save_label?: string;
    revert_label?: string;
    editor_title?: string;
    category_labels?: Record<string, string>;
    effect_intensity?: 'full' | 'reduced' | 'off';
    glow?: boolean;
    hue_rotation?: number;
    text_color?: string;
    // SS220 EDIT: optional terminal account typography.
    font_family?: string;
    font_size?: number;
  };
};

export const FlavorTextEditor = (props) => {
  const { act, data } = useBackend<Data>();
  // SS220 DemonicLynx "Lobby UI" - generic optional presentation payload; classic labels are the fallback.
  const { general, categories, custom_presentation: presentation } = data;
  const [category, setCategory] = useState('general');
  const [flavorText, setFlavorText] = useState(general);
  const [buffer, setBuffer] = useState(general);

  const changeCategory = (nextCategory: string, text: string) => {
    setCategory(nextCategory);
    setFlavorText(text);
    setBuffer(text);
  };

  const save = (text: string, selectedCategory: string) => {
    setFlavorText(text);
    act('set_flavor_text', {
      category: selectedCategory,
      text,
    });
  };

  const getCategoryLabel = (categoryName: string) =>
    presentation?.category_labels?.[categoryName] ||
    categoryName[0].toUpperCase() + categoryName.slice(1);
  const categoryLabel = getCategoryLabel(category);
  const editorTitle = presentation?.editor_title
    ? presentation.editor_title.replace('{category}', categoryLabel)
    : `Edit ${category} flavor text (Shift+Enter for new line)`;

  return (
    <Window
      width={800}
      height={500}
      theme={presentation?.theme || 'crtblue'}
      {...getTerminalInputWindowProps(presentation)}
    >
      <Window.Content
        className={`FlavorTextEditor ${presentation?.class_name || ''}`}
        // SS220 DemonicLynx "Lobby UI" - classic keyboard behavior is unchanged.
        onKeyDown={
          presentation
            ? (event) => {
                if (event.key === 'Escape' && !event.defaultPrevented) {
                  event.preventDefault();
                  event.stopPropagation();
                  globalStore.dispatch(backendSuspendStart());
                }
              }
            : undefined
        }
      >
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid pr="0" pl="0" mb="0" fontSize="16px">
              {categories.map((iterateCategory, index) => (
                <Tabs.Tab
                  key={index}
                  selected={category === iterateCategory}
                  onClick={() =>
                    changeCategory(iterateCategory, data[iterateCategory])
                  }
                >
                  {getCategoryLabel(iterateCategory)}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Section
            fill
            title={editorTitle}
            buttons={
              <>
                <Button
                  icon="floppy-disk"
                  onClick={() => save(buffer, category)}
                >
                  {presentation?.save_label || 'Save'}
                </Button>
                <Button icon="undo" onClick={() => setBuffer(flavorText)}>
                  {presentation?.revert_label || 'Revert'}
                </Button>
              </>
            }
          >
            <TextArea
              scrollbar
              height="100%"
              fontSize={presentation ? '14px' : '13px'}
              value={buffer}
              onChange={(e, value) => setBuffer(value)}
            />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
