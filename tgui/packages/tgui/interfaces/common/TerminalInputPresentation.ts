export type TerminalInputPresentation = {
  accent_color?: string;
  effect_intensity?: 'full' | 'reduced' | 'off';
  glow?: boolean;
  text_color?: string;
  font_family?: string;
  font_size?: number;
};

export const getTerminalInputWindowProps = (
  presentation?: TerminalInputPresentation,
) => {
  if (!presentation) {
    return {};
  }

  const classNames = ['BandaTerminalInput'];
  // SS220 EDIT: typography is optional; standard windows keep their fonts.
  if (presentation.font_family) {
    classNames.push('BandaTerminalInput--fontOverride');
  }
  if (presentation.text_color) {
    classNames.push('BandaTerminalInput--textOverride');
  }
  if (presentation.glow === false) {
    classNames.push('BandaTerminalInput--noGlow');
  }
  if (presentation.effect_intensity === 'reduced') {
    classNames.push('BandaTerminalInput--reduced');
  } else if (presentation.effect_intensity === 'off') {
    classNames.push('BandaTerminalInput--effectsOff');
  }

  return {
    className: classNames.join(' '),
    style: {
      '--banda-accent-color': presentation.accent_color || '#CCFF66',
      '--banda-text-color': presentation.text_color || '#FFFFFF',
      '--banda-font-family': presentation.font_family || 'inherit',
      '--banda-font-size': `${presentation.font_size || 14}px`,
    } as Partial<CSSStyleDeclaration>,
  };
};
