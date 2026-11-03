// Run with: node --test modular/lobby_ui/tools/terminal.test.cjs
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.join(__dirname, '..');
const { createBandaLoadoutSequence } = require('../assets/loadout.js');

function clock() {
  let now = 0, next = 0;
  const tasks = new Map();
  return {
    schedule(fn, ms) { const id = ++next; tasks.set(id, { fn, time: now + ms }); return id; },
    cancel(id) { tasks.delete(id); },
    advance(ms) {
      const end = now + ms;
      for (;;) {
        const due = [...tasks].filter(([, v]) => v.time <= end).sort((a, b) => a[1].time - b[1].time)[0];
        if (!due) break;
        tasks.delete(due[0]); now = due[1].time; due[1].fn();
      }
      now = end;
    },
  };
}
function sequence() {
  const timer = clock(), rows = [1];
  let finished = 0, waiting = 0;
  const controller = createBandaLoadoutSequence(9, n => rows.push(n), () => finished++, () => waiting++, timer.schedule, timer.cancel);
  return { timer, rows, controller, get finished() { return finished; }, get waiting() { return waiting; } };
}
test('early data accelerates every remaining row, without skipping rows', () => {
  const s = sequence();
  s.controller.ready();
  s.timer.advance(404);
  assert.equal(s.finished, 0);
  s.timer.advance(1);
  assert.equal(s.finished, 1);
  assert.deepEqual(s.rows, [1,2,3,4,5,6,7,8,9]);
});
test('slow data waits after all nine rows; a late ready opens exactly once', () => {
  const s = sequence();
  s.timer.advance(10000);
  assert.equal(s.waiting, 1);
  assert.equal(s.finished, 0);
  s.controller.ready(); s.controller.ready();
  s.timer.advance(45);
  assert.equal(s.finished, 1);
});
test('closing the document cancels its sequence and ignores stale ready', () => {
  const s = sequence();
  s.timer.advance(480);
  s.controller.stop(); s.controller.ready(); s.timer.advance(10000);
  assert.equal(s.finished, 0);
  assert.deepEqual(s.rows, [1,2,3]);
});
function element(tagName, children = [], attrs = {}) {
  const node = { tagName, nodeType: 1, className: attrs.class || '', getAttribute: key => attrs[key] || '', setAttribute: (key, value) => { attrs[key] = value; } };
  node.firstChild = children[0];
  children.forEach((child, i) => { child.parentNode = node; child.nextSibling = children[i + 1]; });
  return node;
}
const text = value => ({ nodeType: 3, nodeValue: value });
test('actual translation walker preserves textarea, names and protected user content', () => {
  const dm = fs.readFileSync(path.join(root, 'code/shared/character_localization.dm'), 'utf8');
  let script = dm.substring(dm.indexOf('<script type=', dm.indexOf('var/script ='))).split('</script>')[0].replace(/^.*?>/, '');
  script = script.replace('[translations_json]', JSON.stringify({ Medical: 'Медицинская', Name: 'Имя' }))
    .replace('[phrase_translations_json]', JSON.stringify([['Medical', 'Медицинская']]))
    .replaceAll('[interface_language]', 'ru').replace(/\\([\[\]])/g, '$1');
  const label = text(' Medical: '), record = text('Medical'), name = text('Medical'), protectedText = text('Medical');
  const nameLink = element('A', [name], { href: 'byond://?_src_=prefs;preference=name;task=input' });
  let run;
  const document = {
    title: 'Medical',
    documentElement: element('HTML'),
    body: element('BODY', [element('DIV', [label]), element('TEXTAREA', [record]), nameLink, element('SPAN', [protectedText], { class: 'prefs-no-translate' })]),
    getElementsByTagName: () => [nameLink],
    addEventListener: (_, fn) => { run = fn; },
  };
  vm.runInNewContext(script, { document, window: {} });
  run();
  assert.equal(label.nodeValue, ' Медицинская: ');
  for (const unchanged of [record, name, protectedText]) assert.equal(unchanged.nodeValue, 'Medical');
});
test('notice expires at five seconds independently of effects', () => {
  const timer = clock(), state = { style: {} };
  let run;
  const window = { setTimeout: timer.schedule, clearTimeout: timer.cancel };
  const document = {
    querySelector: selector => selector === '.prefs-save-state' ? state : null,
    addEventListener: (_, fn) => { run = fn; },
  };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  run();
  timer.advance(4999);
  assert.equal(state.style.visibility, 'visible');
  timer.advance(1);
  assert.equal(state.style.visibility, 'hidden');
});
test('additional settings expand and collapse without navigation', () => {
  const attributes = { 'aria-expanded': 'false' };
  const bodyAttributes = { 'aria-hidden': 'true' };
  const marker = { innerText: '+' };
  const body = { setAttribute: (name, value) => { bodyAttributes[name] = value; } };
  const section = { className: 'prefs-settings-collapsible', querySelector: selector => selector === '.prefs-settings-collapsible-body' ? body : null };
  const toggle = {
    parentNode: { parentNode: section },
    getAttribute: name => attributes[name],
    setAttribute: (name, value) => { attributes[name] = value; },
    querySelector: selector => selector === '.prefs-settings-toggle-marker' ? marker : null,
  };
  const window = { clearTimeout() {}, setTimeout() {} };
  const document = { addEventListener() {}, querySelector() { return null; } };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  assert.equal(window.toggleBandaAdditional(toggle), false);
  assert.equal(attributes['aria-expanded'], 'true');
  assert.equal(bodyAttributes['aria-hidden'], 'false');
  assert.match(section.className, /\bopen\b/);
  assert.equal(marker.innerText, '−');
  window.toggleBandaAdditional(toggle);
  assert.equal(attributes['aria-expanded'], 'false');
  assert.equal(bodyAttributes['aria-hidden'], 'true');
  assert.doesNotMatch(section.className, /\bopen\b/);
  assert.equal(marker.innerText, '+');
});
test('terminal settings renderer keeps the approved action inventory only', () => {
  const source = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const start = source.indexOf('/datum/preferences/proc/get_banda_terminal_settings_controls()');
  const end = source.indexOf('/datum/preferences/proc/toggle_banda_lobby_character_highlight()', start);
  assert.ok(start >= 0 && end > start);
  const renderer = source.slice(start, end);
  for (const action of [
    'preference=hotkeys', 'preference=viewmacros', 'preference=ui', 'preference=UIcolor', 'preference=UIalpha',
    'preference=customcursors', 'preference=ghost_ears', 'preference=ghost_sight', 'preference=ghost_radio',
    'preference=ghost_spyradio', 'preference=ghost_hivemind', 'preference=lang_chat_disabled',
    'preference=langchat_emotes', 'preference=hear_faxes', 'preference=ghost_vision_pref', 'preference=lobby_music',
    'preference=sound_vox', 'preference=hear_admin_sounds', 'preference=banda_admin_atmospheric_sounds',
    'preference=banda_admin_meme_sounds', 'preference=ambientocclusion',
    'preference=auto_fit_viewport', 'preference=adaptive_zoom', 'preference=tgui_fancy', 'preference=tgui_lock',
    'preference=window_scale', 'preference=mouse_button_activation', 'switch_item_animations', 'toggle_dualwield',
    'set_eye_blur_type', 'set_flash_type', 'set_crit_type', 'preference=inputcolor', 'preference=hide_statusbar',
    'preference=no_radials_preference', 'preference=no_radial_labels_preference',
    'preference=hear_observer_announcements', 'preference=tooltips',
  ]) assert.match(renderer, new RegExp(action.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  for (const removed of ['toggle_admin_sound_types', 'preference=inputstyle', 'preference=stylesheet', 'preference=ooc_flag', 'preference=ViewMC', 'preference=publicity', 'receive_random_tip', 'preference=metadata']) {
    assert.doesNotMatch(renderer, new RegExp(removed));
  }
  const subgroup = renderer.indexOf("prefs-settings-subgroup-label'>Toggle Meme or Atmospheric Sounds:");
  const atmospheric = renderer.indexOf('preference=banda_admin_atmospheric_sounds');
  const meme = renderer.indexOf('preference=banda_admin_meme_sounds');
  assert.ok(subgroup >= 0 && atmospheric > subgroup && meme > atmospheric);
  assert.match(renderer, /SOUND_ADMIN_ATMOSPHERIC/);
  assert.match(renderer, /SOUND_ADMIN_MEME/);

  const provider = fs.readFileSync(path.join(root, '_lobby_ui.dm'), 'utf8');
  assert.match(provider, /if\("banda_admin_atmospheric_sounds", "banda_admin_meme_sounds"\)/);
  assert.match(provider, /preference == "banda_admin_atmospheric_sounds" \? SOUND_ADMIN_ATMOSPHERIC : SOUND_ADMIN_MEME/);
  assert.match(provider, /preferences\.toggle_banda_admin_sound_type\(sound_flag\)/);
  assert.match(source, /sound_flag in list\(SOUND_ADMIN_ATMOSPHERIC, SOUND_ADMIN_MEME\)/);
  assert.match(source, /toggles_sound \^= sound_flag[\s\S]*?save_preferences\(\)/);

  const localization = fs.readFileSync(path.join(root, 'code/shared/character_localization.dm'), 'utf8');
  assert.match(localization, /"Atmospheric Sounds" = "Атмосферные звуки"/);
  assert.match(localization, /"Meme Sounds" = "Мемные звуки"/);
});
test('terminal tabs contain long labels at every configured text size', () => {
  const css = fs.readFileSync(path.join(root, 'assets/character.css'), 'utf8');
  const match = css.match(/a\.prefs-tab, a\.prefs-tab:link, a\.prefs-tab:visited \{([^}]+)\}/);
  assert.ok(match);
  const rule = match[1];
  assert.match(rule, /display:\s*flex/);
  assert.match(rule, /overflow:\s*hidden/);
  assert.match(rule, /white-space:\s*normal/);
  assert.match(rule, /overflow-wrap:\s*break-word/);
  assert.match(rule, /word-wrap:\s*break-word/);
  assert.doesNotMatch(rule, /white-space:\s*nowrap/);

  const renderer = fs.readFileSync(path.join(root, 'code/themes/terminal_character.dm'), 'utf8');
  assert.match(renderer, /for\(var\/list\/tab as anything in get_banda_character_menu_tabs\(\)\)/);
  assert.match(renderer, /preference=change_menu;menu=\[menu_id\]/);
});
test('main lobby carries an exact three-pixel typography boost into both generated sheets', () => {
  const typography = fs.readFileSync(path.join(root, 'code/shared/typography.dm'), 'utf8');
  assert.match(typography, /return sheet == "lobby" \? 3 : 0/);
  assert.match(typography, /var\/declaration_font_size = sizes\.group\[3\] && findtext\(sizes\.group\[3\], "-cap14"\) \? min\(banda_terminal_font_size, 14\) : banda_terminal_font_size/);
  assert.match(typography, /var\/declaration_offset = sizes\.group\[3\] \? 0 : pixel_offset/);
  assert.match(typography, /text2num\(sizes\.group\[2\]\) \* declaration_font_size \/ 14 \+ declaration_offset/);
  assert.match(typography, /var\/effective_base_size = banda_terminal_font_size \+ pixel_offset/);

  const assets = fs.readFileSync(path.join(root, 'code/shared/terminal_assets.dm'), 'utf8');
  assert.match(assets, /var\/font_size_offset = get_banda_terminal_font_size_offset\(sheet\)/);
  assert.match(assets, /get_banda_terminal_stylesheet_key\(sheet, font_size_offset\)/);
  assert.match(assets, /get_banda_terminal_stylesheet_key\("terminal", font_size_offset\)/);
  assert.match(assets, /\[banda_terminal_font_size\]\|\[font_size_offset\]/);
});
test('dossier information is three pixels smaller, capped, and remains inside the footer boundary', () => {
  const css = fs.readFileSync(path.join(root, 'assets/lobby.css'), 'utf8');
  for (const selector of ['.dossier-name', '.data-row']) {
    const rules = [...css.matchAll(new RegExp(`\\${selector} \\{([^}]+)\\}`, 'g'))];
    assert.ok(rules.length >= 2, selector);
    assert.match(rules[0][1], /font-size:\s*[0-9.]+px\/\*banda-no-lobby-offset-cap14\*\//);
    assert.match(rules[0][1], /line-height:\s*[0-9.]+px\/\*banda-no-lobby-offset-cap14\*\//);
    const fluidRule = rules.find(rule => /font-size:\s*clamp\(/.test(rule[1]));
    assert.ok(fluidRule, `${selector} fluid rule`);
    assert.match(fluidRule[1], /font-size:\s*clamp\([^}]+\)\s*!important/);
    assert.match(fluidRule[1], /line-height:\s*clamp\([^}]+\)\s*!important/);
  }
  const nameRule = css.match(/\.dossier-name \{([^}]+)\}/);
  const rowRule = css.match(/\.data-row \{([^}]+)\}/);
  assert.ok(nameRule);
  assert.ok(rowRule);
  assert.match(nameRule[1], /font-size:\s*13px\/\*banda-no-lobby-offset-cap14\*\/[^}]*line-height:\s*17px\/\*banda-no-lobby-offset-cap14\*\//);
  assert.match(rowRule[1], /font-size:\s*11px\/\*banda-no-lobby-offset-cap14\*\/[^}]*line-height:\s*13px\/\*banda-no-lobby-offset-cap14\*\/[^}]*margin:\s*1px 0/);
  const footerRule = css.match(/\.footer-copy \{([^}]+)\}/);
  assert.ok(footerRule);
  assert.match(footerRule[1], /banda-no-lobby-offset/);
  assert.doesNotMatch(footerRule[1], /banda-no-lobby-offset-cap14/);
  for (const selector of ['.dossier-title', '.character-fallback']) {
    const rule = css.match(new RegExp(`\\${selector} \\{([^}]+)\\}`));
    assert.ok(rule, selector);
    assert.doesNotMatch(rule[1], /banda-no-lobby-offset/);
  }
  const fluid = css.match(/@media \(max-width: 1200px\) \{([\s\S]*?)\n\}/);
  assert.ok(fluid);
  assert.match(fluid[1], /\.dossier-name \{[^}]*font-size:\s*clamp\(10px,\s*1\.08vw,\s*var\(--banda-dossier-name-size, 13px\)\)\s*!important[^}]*line-height:\s*clamp\(12px,\s*1\.42vw,\s*var\(--banda-dossier-name-line-height, 17px\)\)\s*!important/);
  assert.match(fluid[1], /\.data-row \{[^}]*font-size:\s*clamp\(8px,\s*\.92vw,\s*var\(--banda-dossier-row-size, 11px\)\)\s*!important[^}]*line-height:\s*clamp\(10px,\s*1\.08vw,\s*var\(--banda-dossier-row-line-height, 13px\)\)\s*!important[^}]*margin:\s*0/);
  const dossierData = css.match(/\.dossier-data \{([^}]+)\}/);
  assert.ok(dossierData);
  assert.match(dossierData[1], /justify-content:\s*flex-start/);
  assert.match(dossierData[1], /overflow:\s*visible/);
  assert.doesNotMatch(dossierData[1], /overflow-y:\s*(?:auto|scroll)/);
  const typography = fs.readFileSync(path.join(root, 'code/shared/typography.dm'), 'utf8');
  assert.match(typography, /banda-no-lobby-offset\(\?:-cap14\)\?/);
  assert.match(typography, /min\(banda_terminal_font_size, 14\)/);
  assert.doesNotMatch(typography, /\.dossier-data[^\n]*overflow-y:\s*(?:auto|scroll)/);
});
test('narrow lobby fluidly compacts without adding a scroll surface', () => {
  const css = fs.readFileSync(path.join(root, 'assets/lobby.css'), 'utf8');
  const fluidStart = css.indexOf('@media (max-width: 1200px)');
  const intermediateStart = css.indexOf('@media (max-width: 900px)');
  const narrowStart = css.indexOf('@media (max-width: 760px)');
  assert.ok(fluidStart >= 0);
  assert.ok(intermediateStart >= 0);
  assert.ok(narrowStart >= 0);
  const fluid = css.slice(fluidStart, intermediateStart);
  const intermediate = css.slice(intermediateStart, narrowStart);
  const narrow = css.slice(narrowStart, css.indexOf('\n.crt-shell a.menu-item.primary', narrowStart));
  assert.match(intermediate, /\.menu \{[^}]*flex-basis:\s*40%[^}]*width:\s*40%[^}]*min-width:\s*280px/);
  assert.match(intermediate, /\.portrait \{[^}]*flex-basis:\s*34%[^}]*min-width:\s*130px/);
  assert.match(intermediate, /\.dossier-data \{[^}]*padding-top:\s*2px/);
  assert.match(intermediate, /\.data-label \{[^}]*flex-basis:\s*38%/);
  assert.doesNotMatch(intermediate, /\.(?:dossier-name|data-row) \{[^}]*font-size:\s*clamp\([^}]*%/);
  assert.match(narrow, /\.terminal \{[^}]*padding:\s*clamp\(/);
  assert.match(narrow, /\.menu \{[^}]*flex-basis:\s*37%[^}]*width:\s*37%[^}]*min-width:\s*0[^}]*--banda-terminal-effective-size/);
  assert.match(narrow, /\.portrait \{[^}]*flex-basis:\s*32%[^}]*min-width:\s*clamp\(/);
  assert.match(narrow, /\.dossier-data \{[^}]*padding-top:\s*clamp\(/);
  assert.match(narrow, /\.data-label \{[^}]*flex-basis:\s*36%/);
  assert.match(narrow, /\.data-value \{[^}]*overflow-wrap:\s*anywhere[^}]*word-break:\s*normal/);
  assert.doesNotMatch(narrow, /\.(?:dossier-name|data-row) \{[^}]*font-size:\s*clamp\([^}]*%/);
  assert.doesNotMatch(fluid, /\.(?:dossier-name|data-row) \{[^}]*font-size:\s*clamp\([^}]*%/);
  assert.doesNotMatch(intermediate, /overflow-(?:x|y):\s*(?:auto|scroll)/);
  assert.doesNotMatch(narrow, /overflow-(?:x|y):\s*(?:auto|scroll)/);

  const typography = fs.readFileSync(path.join(root, 'code/shared/typography.dm'), 'utf8');
  assert.match(typography, /--banda-terminal-base-size: \[banda_terminal_font_size\]px/);
  assert.match(typography, /--banda-terminal-effective-size: \[effective_base_size\]px/);
  assert.match(typography, /var\/capped_font_size = min\(banda_terminal_font_size, 14\)/);
  assert.match(typography, /--banda-dossier-name-size: \[dossier_name_size\]px/);
  assert.match(typography, /--banda-dossier-name-line-height: \[dossier_name_line_height\]px/);
  assert.match(typography, /--banda-dossier-row-size: \[dossier_row_size\]px/);
  assert.match(typography, /--banda-dossier-row-line-height: \[dossier_row_line_height\]px/);
});
test('main dossier shows build before body type without swapping values', () => {
  const source = fs.readFileSync(path.join(root, 'code/themes/terminal_lobby.dm'), 'utf8');
  const build = "<span class='data-label'>КОМПЛЕКЦИЯ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_size]</span>";
  const type = "<span class='data-label'>ТЕЛОСЛОЖЕНИЕ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_type]</span>";
  assert.ok(source.indexOf(build) >= 0);
  assert.ok(source.indexOf(type) > source.indexOf(build));
  assert.doesNotMatch(source, /data-label'>КОМПЛЕКЦИЯ<\/span><span class='data-separator'>:<\/span><span class='data-value'>\[character_body_type\]/);
  assert.doesNotMatch(source, /data-label'>ТЕЛОСЛОЖЕНИЕ<\/span><span class='data-separator'>:<\/span><span class='data-value'>\[character_body_size\]/);
});
test('terminal settings keep labels left and controls right in scoped grids', () => {
  const css = fs.readFileSync(path.join(root, 'assets/character.css'), 'utf8');
  assert.match(css, /\.prefs-settings-section, \.prefs-settings-collapsible\.open \.prefs-settings-collapsible-body[^\{]*\{[^}]*display:\s*grid[^}]*grid-template-columns:\s*minmax\(0, 1fr\) minmax\(54px, 46%\)/);
  assert.match(css, /\.prefs-settings-section > a:not\(\.prefs-settings-action\)[^\{]*\{[^}]*grid-column:\s*2[^}]*justify-self:\s*end/);
  assert.match(css, /\.prefs-settings-collapsible\.open \.prefs-settings-collapsible-body[^\{]*\{[^}]*display:\s*grid/);
  assert.match(css, /\.prefs-settings-section > br[^\{]*\{[^}]*display:\s*none/);
  assert.match(css, /\.prefs-setting-separator \{[^}]*display:\s*block[^}]*grid-column:\s*1 \/ -1[^}]*border-top:\s*1px dashed rgba\(var\(--banda-accent-rgb\), 0\.2\)/);
  assert.match(css, /\.prefs-settings-section > h2 \{[^}]*border-left:\s*3px solid rgba\(var\(--banda-accent-rgb\), 0\.72\)[^}]*background:\s*rgba\(0, 0, 0, 0\.46\)/);
  assert.doesNotMatch(css, /> b \+ a \+ br[^\{]*\{/);

  const script = fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8');
  assert.match(script, /function installSettingSeparators\(root\)/);
  assert.match(script, /separator\.className = 'prefs-setting-separator'/);
  assert.match(script, /lineBreak\.parentNode\.insertBefore\(separator, lineBreak\)/);
  assert.match(script, /installSettingSeparators\(root\);/);
  assert.match(script, /var settingsSections = workspace\.querySelectorAll\('\.prefs-settings-section'\)/);
  assert.match(script, /var blocks = settingsSections\.length \? settingsSections :/);

  const source = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const start = source.indexOf('/datum/preferences/proc/get_banda_interface_preferences_controls()');
  const end = source.indexOf('/datum/preferences/proc/toggle_banda_lobby_character_highlight()', start);
  assert.ok(start >= 0 && end > start);
  const settings = source.slice(start, end);
  assert.equal((settings.match(/class='prefs-settings-column'/g) || []).length, 3);
  assert.equal((settings.match(/class='prefs-settings-section(?: |')/g) || []).length, 8);
  assert.equal((settings.match(/class='prefs-settings-action'/g) || []).length, 3);
  for (const action of ['preference=banda_terminal_settings_reset', 'switch_item_animations', 'toggle_dualwield']) {
    const line = settings.split('\n').find(candidate => candidate.includes(action));
    assert.ok(line && line.includes("class='prefs-settings-action'"), action);
  }
});
test('effect modes keep only the approved reduced exceptions and remove all off overlays', () => {
  const controller = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const helper = controller.slice(controller.indexOf('/datum/preferences/proc/uses_banda_terminal_decorative_effects()'), controller.indexOf('/datum/preferences/proc/set_banda_terminal_interface_color'));
  assert.match(helper, /return banda_terminal_effect_intensity == BANDA_TERMINAL_EFFECTS_FULL/);

  const lobby = fs.readFileSync(path.join(root, 'assets/lobby.css'), 'utf8');
  assert.match(lobby, /\.crt-shell\.banda-effects-reduced[^\{]+\{[^}]*animation:\s*none !important;[^}]*transition:\s*none !important/);
  assert.match(lobby, /\.crt-shell\.banda-effects-reduced:after \{ animation: crt-roll 8s linear infinite !important; \}/);
  assert.doesNotMatch(lobby, /banda-effects-reduced\.booting \.terminal/);
  assert.doesNotMatch(lobby, /banda-effects-reduced \.globe-orbit/);
  assert.match(lobby, /\.crt-shell\.banda-effects-off:before, \.crt-shell\.banda-effects-off:after/);

  const character = fs.readFileSync(path.join(root, 'assets/character.css'), 'utf8');
  assert.match(character, /\.prefs-crt\.banda-effects-reduced:after \{ animation: prefs-crt-roll 9s linear infinite !important; \}/);
  assert.match(character, /\.prefs-crt\.banda-effects-reduced \.prefs-focus-shade \{ transition: opacity \.14s linear !important; \}/);
  assert.match(character, /\.prefs-crt\.banda-effects-off[^\{]+\.prefs-focus-shade \{ display: none; \}/);

  for (const file of ['auxiliary.css', 'picker.css']) {
    const css = fs.readFileSync(path.join(root, 'assets', file), 'utf8');
    assert.match(css, /banda-effects-reduced[^\{]+\{[^}]*animation:\s*none !important;[^}]*transition:\s*none !important/);
  }
  const tgui = fs.readFileSync(path.join(root, '..', '..', 'tgui/packages/tgui/styles/interfaces/TerminalInputPresentation.scss'), 'utf8');
  assert.match(tgui, /\.BandaTerminalInput--reduced,\s*\.BandaTerminalInput--reduced \*/);

  const script = fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8');
  assert.match(script, /className\.indexOf\('banda-effects-reduced'\) !== -1 \|\| root\.className\.indexOf\('banda-effects-off'\) !== -1/);
  assert.match(script, /classList\.contains\('banda-glow-off'\) \|\| root\.classList\.contains\('banda-effects-off'\)/);
});
test('interface selection uses checked persistence and always refreshes explicit choices', () => {
  const controller = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const helperStart = controller.indexOf('/datum/preferences/proc/set_and_save_banda_menu_interface(new_interface)');
  const helperEnd = controller.indexOf('/datum/preferences/proc/get_banda_interface_preferences_controls()', helperStart);
  assert.ok(helperStart >= 0 && helperEnd > helperStart);
  const helper = controller.slice(helperStart, helperEnd);
  assert.match(helper, /if\(save_preferences\(\)\)/);
  assert.match(helper, /set_banda_menu_interface\(previous_interface\)/);

  const verbStart = controller.indexOf('/client/verb/select_banda_menu_interface()');
  const verbEnd = controller.indexOf('/datum/custom_event_info/proc/refresh_banda_lobby_panels()', verbStart);
  assert.ok(verbStart >= 0 && verbEnd > verbStart);
  const verb = controller.slice(verbStart, verbEnd);
  assert.match(verb, /if\(!prefs\.set_and_save_banda_menu_interface\(new_interface\)\)/);
  assert.match(verb, /player\.new_player_panel_proc\(TRUE\)/);
  assert.doesNotMatch(verb, /new_interface == prefs\.banda_menu_interface/);

  const provider = fs.readFileSync(path.join(root, '_lobby_ui.dm'), 'utf8');
  assert.match(provider, /if\(!preferences\.set_and_save_banda_menu_interface\("classic"\)\)/);
  assert.doesNotMatch(provider, /preferences\.set_banda_menu_interface\("classic"\)\s*\n\s*preferences\.save_preferences\(\)/);
});
test('keybind editor opts into compact terminal presentation without changing actions', () => {
  const core = fs.readFileSync(path.join(root, '..', '..', 'code/modules/client/tgui_macro.dm'), 'utf8');
  assert.match(core, /lobby_ui_keybind_presentation\(prefs\)/);
  assert.match(core, /\.\["custom_presentation"\] = custom_presentation/);
  assert.match(core, /var\/window_title = "Keybind Preference"/);
  for (const action of ['set_keybind', 'clear_keybind', 'clear_all_keybinds']) {
    assert.match(core, new RegExp(`if\\("${action}"\\)`));
  }

  const contract = fs.readFileSync(path.join(root, '..', '_modpack.dm'), 'utf8');
  assert.match(contract, /proc\/lobby_ui_keybind_presentation\(datum\/preferences\/preferences\)\s*\n\s*return null/);

  const provider = fs.readFileSync(path.join(root, '_lobby_ui.dm'), 'utf8');
  const hookStart = provider.indexOf('/datum/modpack/lobby_ui/lobby_ui_keybind_presentation');
  const hookEnd = provider.indexOf('/datum/modpack/lobby_ui/lobby_ui_uses_custom_character_editor', hookStart);
  assert.ok(hookStart >= 0 && hookEnd > hookStart);
  const hook = provider.slice(hookStart, hookEnd);
  assert.match(hook, /if\(!preferences\?\.uses_banda_terminal_interface\(\)\)\s*\n\s*return null/);
  assert.match(hook, /preferences\.get_banda_tgui_input_presentation\(\)/);
  assert.match(hook, /"window_title"/);
  assert.match(hook, /"clear"/);
  assert.match(hook, /"expand"/);
  assert.match(hook, /"collapse"/);

  const frontend = fs.readFileSync(path.join(root, '..', '..', 'tgui/packages/tgui/interfaces/KeyBinds.jsx'), 'utf8');
  assert.match(frontend, /getTerminalInputWindowProps/);
  assert.match(frontend, /custom_presentation: presentation/);
  assert.match(frontend, /presentation \? 520 : 400/);
  assert.match(frontend, /presentation \? 600 : 500/);
  assert.match(frontend, /BandaKeybinds__row/);
  assert.match(frontend, /const KeybindQuickNavigation/);
  assert.match(frontend, /presentation \? \(\s*<KeybindQuickNavigation/);
  assert.match(frontend, /width="360px"\s*menuWidth="360px"/);
  assert.match(frontend, /const \[collapsedCategories, setCollapsedCategories\] = useState\(\(\) => \{/);
  assert.match(frontend, /Object\.keys\(glob_keybinds\)\.forEach\(\(category\) => \{\s*initialState\[category\] = true/);
  assert.match(frontend, /\[category\]: false/);
  assert.match(frontend, /scrollToCategory\(category\)/);
  assert.match(frontend, /container_id=\{`keybind-category-\$\{category\}`\}/);
  assert.match(frontend, /icon=\{collapsed \? 'chevron-down' : 'chevron-up'\}/);
  assert.match(frontend, /!collapsed && \(/);
  const quickNavigation = frontend.slice(frontend.indexOf('const KeybindQuickNavigation'), frontend.indexOf('const KeybindsDropdown'));
  assert.doesNotMatch(quickNavigation, /onJump\('ALL'\)|labels\.all|icon="list"/);
  assert.match(frontend, /\{ displayText: labels\.all \|\| 'ALL', value: 'ALL' \}/);
  assert.match(frontend, /BandaKeybinds__legacySeparator/);
  assert.match(frontend, /fontSize=\{compact \? undefined : '115%'\}/);
  assert.match(frontend, /labels\.clear \|\| 'Clear'/);
  for (const action of ["act\('set_keybind'", "act\('clear_keybind'", "act\('clear_all_keybinds'"]) {
    assert.match(frontend, new RegExp(action.replace('(', '\\(')));
  }

  const styles = fs.readFileSync(path.join(root, '..', '..', 'tgui/packages/tgui/styles/interfaces/TerminalInputPresentation.scss'), 'utf8');
  assert.match(styles, /\.BandaTerminalInput\.BandaKeybinds/);
  assert.match(styles, /\.BandaKeybinds__controls[\s\S]*position:\s*sticky/);
  assert.match(styles, /\.BandaKeybinds__quickNav/);
  assert.match(styles, /\.BandaKeybinds__category[\s\S]*scroll-margin-top:\s*176px/);
  assert.match(styles, /\.BandaKeybinds__category--collapsed[\s\S]*display:\s*none/);
  assert.match(styles, /\.BandaKeybinds__row[\s\S]*repeating-linear-gradient/);
  assert.match(styles, /\.BandaKeybinds__legacySeparator[\s\S]*display:\s*none/);
  assert.match(styles, /\.BandaTerminalInput--effectsOff\.BandaKeybinds/);
});
test('classic renderers remain isolated from terminal resources and state', () => {
  for (const file of ['classic_character.dm', 'classic_lobby.dm']) {
    const source = fs.readFileSync(path.join(root, 'code/themes', file), 'utf8');
    assert.doesNotMatch(source, /get_banda_terminal_styles|banda_saved_character_signature|ensure_banda_character_preview/);
  }
});

test('settings rows receive real dashed separator elements', () => {
  const label = { tagName: 'B' };
  const action = { tagName: 'A', className: '', previousElementSibling: label };
  let inserted;
  const lineBreak = {
    previousElementSibling: action,
    parentNode: { insertBefore(node, reference) { inserted = { node, reference }; } },
  };
  const root = {
    className: '',
    classList: { contains() { return false; }, add() {}, remove() {} },
    appendChild() {},
    getAttribute() { return null; },
    getElementsByTagName() { return []; },
    querySelector() { return null; },
    querySelectorAll(selector) {
      return selector === '.prefs-settings-section > br, .prefs-settings-collapsible-body > br' ? [lineBreak] : [];
    },
  };
  let loaded;
  const document = {
    querySelector: selector => selector === '.prefs-crt' || selector === '.prefs-crt, .crt-shell, .picker-crt, .banda-aux-crt' ? root : null,
    createElement: tagName => ({ tagName: tagName.toUpperCase(), className: '', setAttribute(name, value) { this[name] = value; } }),
    addEventListener: (_, handler) => { loaded = handler; },
  };
  const window = { clearTimeout() {}, setTimeout() {}, addEventListener() {} };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '..', 'assets/terminal.js'), 'utf8'), { window, document });
  loaded();
  assert.equal(inserted.reference, lineBreak);
  assert.equal(inserted.node.tagName, 'SPAN');
  assert.equal(inserted.node.className, 'prefs-setting-separator');
  assert.equal(inserted.node['aria-hidden'], 'true');
});

test('editor block focus follows glow and clears on exit or window blur', () => {
  function element() {
    const classes = new Set(), attributes = {};
    return {
      className: '', events: {}, children: [],
      classList: { add: name => classes.add(name), remove: name => classes.delete(name), contains: name => classes.has(name) },
      getAttribute: name => attributes[name] || null,
      setAttribute: (name, value) => { attributes[name] = value; },
      appendChild(child) { this.children.push(child); },
      addEventListener(name, handler) { this.events[name] = handler; },
    };
  }
  const blocks = Array.from({ length: 5 }, element), workspace = element(), editor = element();
  workspace.querySelectorAll = () => blocks;
  editor.querySelector = selector => selector === '.prefs-workspace' ? workspace : null;
  editor.querySelectorAll = () => [];
  let loaded;
  const document = {
    querySelector: selector => selector === '.prefs-crt' ? editor : null,
    createElement: element,
    addEventListener: (_, handler) => { loaded = handler; },
  };
  const window = { events: {}, clearTimeout() {}, setTimeout() {}, addEventListener(name, handler) { this.events[name] = handler; } };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  loaded();
  assert.ok(blocks.every(block => block.children.length === 1 && block.children[0].getAttribute('aria-hidden') === 'true'));
  blocks[0].events.mouseenter.call(blocks[0]);
  assert.ok(workspace.classList.contains('prefs-focus-active'));
  blocks[1].events.mouseenter.call(blocks[1]);
  assert.equal(blocks.filter(block => block.classList.contains('prefs-focus-current')).length, 1);
  assert.ok(blocks[1].classList.contains('prefs-focus-current'));
  blocks[1].events.mouseleave();
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  blocks[2].events.mouseenter.call(blocks[2]);
  window.events.blur();
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  editor.classList.add('banda-glow-off');
  blocks[3].events.mouseenter.call(blocks[3]);
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  editor.classList.remove('banda-glow-off');
  blocks[3].events.mouseenter.call(blocks[3]);
  assert.ok(workspace.classList.contains('prefs-focus-active'));
  blocks[3].events.mouseleave();
  editor.classList.add('banda-effects-off');
  blocks[4].events.mouseenter.call(blocks[4]);
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
});
