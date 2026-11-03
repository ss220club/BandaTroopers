// Shared terminal-only behavior. Multiple style resources may include this file.
(function () {
  if (window.bandaTerminalInstalled) return;
  window.bandaTerminalInstalled = true;
  var noticeTimer;
  window.expireBandaNotice = function () {
    window.clearTimeout(noticeTimer);
    var state = document.querySelector('.prefs-save-state');
    if (!state) return;
    state.style.visibility = 'visible';
    noticeTimer = window.setTimeout(function () { state.style.visibility = 'hidden'; }, 5000);
  };
  window.terminalActionFeedback = function (kind) {
    var state = document.querySelector('.prefs-save-state');
    if (!state) return;
    var english = document.documentElement.getAttribute('data-banda-language') === 'en';
    state.innerText = kind === 'save' ? (english ? 'SYNCHRONIZING...' : 'СИНХРОНИЗАЦИЯ ДАННЫХ...') : (english ? 'RELOADING...' : 'ВОССТАНОВЛЕНИЕ СВЯЗИ...');
    window.expireBandaNotice();
  };
  window.toggleBandaAdditional = function (toggle) {
    if (!toggle || !toggle.parentNode || !toggle.parentNode.parentNode) return false;
    var section = toggle.parentNode.parentNode;
    var body = section.querySelector('.prefs-settings-collapsible-body');
    if (!body) return false;
    var expanded = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', expanded ? 'false' : 'true');
    body.setAttribute('aria-hidden', expanded ? 'true' : 'false');
    section.className = section.className.replace(/\s*open\b/g, '');
    if (!expanded) section.className += ' open';
    var marker = toggle.querySelector('.prefs-settings-toggle-marker');
    if (marker) marker.innerText = expanded ? '+' : '\u2212';
    return false;
  };
  function installEscape(root) {
    var close = root.querySelector('.prefs-back-button');
    if (!close) {
      var links = root.getElementsByTagName('a');
      for (var i = 0; i < links.length; i++) {
        var href = links[i].getAttribute('href') || '';
        if (/(?:[?;&])(?:task=(?:close|close_picker|cancel)(?:[;&]|$)|records=-1(?:[;&]|$)|preference=close_[^;&]+)/.test(href)) {
          close = links[i];
          break;
        }
      }
    }
    if (!close) return;
    var closing = false;
    // Document-local: a focused child window cancels itself, never its editor.
    document.addEventListener('keydown', function (event) {
      if (event.defaultPrevented || event.isComposing || event.repeat || event.altKey || event.ctrlKey || event.metaKey) return;
      if (event.key !== 'Escape' && event.key !== 'Esc' && event.keyCode !== 27) return;
      event.preventDefault();
      event.stopPropagation();
      if (closing) return;
      closing = true;
      close.click();
    });
  }
  function arrangeHumanEditor(root) {
    var workspace = root.querySelector('.prefs-workspace.human');
    if (!workspace || workspace.getAttribute('data-arranged') === '1') return;
    var identity = workspace.querySelector('.prefs-identity');
    var first = workspace.querySelector('#column1');
    var second = workspace.querySelector('#column2');
    if (!identity || !first || !second) return;

    // Locate boundaries by actions, not translated headings or their indices.
    function headingBefore(column, preference) {
      var node = column.querySelector('a[href*="preference=' + preference + ';"]');
      if (!node) return null;
      while (node.parentNode !== column) node = node.parentNode;
      for (; node; node = node.previousSibling) {
        if (node.nodeType === 1 && node.tagName === 'H2') return node;
      }
      return null;
    }
    var occupation = headingBefore(first, 'job');
    var equipment = headingBefore(second, 'personalweapon');
    if (!occupation || !equipment) return;

    // Move each existing node once; preserve hrefs, optional fields and handlers.
    function movePrefix(column, boundary, destination) {
      var node = column.firstChild;
      while (node && node !== boundary) {
        var next = node.nextSibling;
        destination.appendChild(node);
        node = next;
      }
    }
    movePrefix(first, occupation, identity);
    var hair = document.createDocumentFragment();
    movePrefix(second, equipment, hair);
    first.insertBefore(hair, occupation);
    // The shared/classic markup adds a BR after H2; terminal headings have spacing.
    var occupationBreak = occupation.nextElementSibling;
    if (occupationBreak && occupationBreak.tagName === 'BR') {
      first.removeChild(occupationBreak);
    }
    workspace.setAttribute('data-arranged', '1');
  }
  function arrangeCategoryCards(root) {
    if (root.getAttribute('data-category-blocks') !== '1') return;
    var workspace = root.querySelector('.prefs-workspace.human');
    if (!workspace || workspace.getAttribute('data-arranged') !== '1') return;
    var identity = workspace.querySelector('.prefs-identity');
    var first = workspace.querySelector('#column1');
    var second = workspace.querySelector('#column2');
    var third = workspace.querySelector('#column3');
    var content = workspace.querySelector('.prefs-content');
    if (!identity || !first || !second || !third || !content) return;
    var occupation = first.querySelector('a[href*="preference=job;"]');
    if (!occupation) return;
    while (occupation.parentNode !== first) occupation = occupation.parentNode;
    while (occupation && occupation.tagName !== 'H2') occupation = occupation.previousSibling;
    var background = third.querySelector('h2');
    var dossier = background && background.nextSibling;
    while (dossier && dossier.tagName !== 'H2') dossier = dossier.nextSibling;
    // Validate every boundary before moving any original control.
    if (!occupation || !background || !dossier) return;
    var english = root.getAttribute('data-category-language') === 'en';
    var grid = document.createElement('div');
    grid.className = 'prefs-category-grid';
    function card(source, boundary, title, wide) {
      var panel = document.createElement('section');
      panel.className = 'prefs-category-card' + (wide ? ' prefs-category-wide' : '');
      var heading = document.createElement('h2');
      heading.className = 'prefs-category-heading';
      heading.textContent = title;
      panel.appendChild(heading);
      var body = document.createElement('div');
      body.className = 'prefs-category-body';
      panel.appendChild(body);
      var row = document.createElement('div');
      function flush() {
        if (!row.firstChild) return;
        if (!/\S/.test(row.textContent || '') && !row.querySelector('a, input, img')) {
          row = document.createElement('div');
          return;
        }
        row.className = 'prefs-category-row';
        var label = row.firstElementChild;
        if (label && /^(B|U)$/.test(label.tagName) && !label.querySelector('a')) {
          label.classList.add('prefs-category-label');
          row.removeChild(label);
        } else label = null;
        var value = document.createElement('div');
        value.className = 'prefs-category-value';
        while (row.firstChild) value.appendChild(row.firstChild);
        var styleLink = value.querySelector('a[href*="preference=h_style;"], a[href*="preference=f_style;"], a[href*="preference=grad_style;"]');
        var sample = value.querySelector('.banda-real-color');
        if (styleLink && sample && sample.parentNode.parentNode === value) {
          value.classList.add('prefs-category-color-pair');
          styleLink.classList.add('prefs-category-style-choice');
          sample.parentNode.classList.add('prefs-category-color-choice');
          // Only presentation separators; never replace controls or their contents.
          for (var separator = value.firstChild; separator;) {
            var nextSeparator = separator.nextSibling;
            if (separator.nodeType === 3 && /^[\s|]*$/.test(separator.nodeValue)) value.removeChild(separator);
            separator = nextSeparator;
          }
        }
        if (label) row.appendChild(label);
        row.appendChild(value);
        body.appendChild(row);
        row = document.createElement('div');
      }
      var skippedHeading = false;
      while (source.firstChild && source.firstChild !== boundary) {
        var node = source.removeChild(source.firstChild);
        if (node.tagName === 'BR') { flush(); continue; }
        if (node.tagName === 'H2') {
          flush();
          if (!skippedHeading) { skippedHeading = true; continue; }
          body.appendChild(node); // Preserve optional TTS and future subheadings.
        } else if (node.tagName === 'H1') {
          flush();
          while (node.firstChild) row.appendChild(node.firstChild);
          flush();
        } else row.appendChild(node);
      }
      flush();
      grid.appendChild(panel);
      return panel;
    }
    var personalCard = card(identity, null, english ? 'Personal data' : 'Личные данные');
    personalCard.classList.add('prefs-fields');
    identity.parentNode.insertBefore(personalCard, identity);
    card(first, occupation, english ? 'Appearance' : 'Внешность');
    card(second, null, english ? 'Equipment' : 'Экипировка');
    card(third, dossier, english ? 'Origin' : 'Происхождение');
    card(third, null, english ? 'Dossier' : 'Досье', true);
    card(first, null, english ? 'Occupation choices' : 'Выбор должности', true);
    identity.parentNode.removeChild(identity);
    first.parentNode.removeChild(first);
    second.parentNode.removeChild(second);
    third.parentNode.removeChild(third);
    content.appendChild(grid);
    root.classList.add('prefs-category-mode');
  }
  function installSettingSeparators(root) {
    var breaks = root.querySelectorAll('.prefs-settings-section > br, .prefs-settings-collapsible-body > br');
    for (var i = 0; i < breaks.length; i++) {
      var lineBreak = breaks[i];
      var action = lineBreak.previousElementSibling;
      var label = action && action.previousElementSibling;
      if (!action || action.tagName !== 'A' || /(?:^|\s)prefs-settings-action(?:\s|$)/.test(action.className || '')) continue;
      if (!label || label.tagName !== 'B') continue;
      var separator = document.createElement('span');
      separator.className = 'prefs-setting-separator';
      separator.setAttribute('aria-hidden', 'true');
      lineBreak.parentNode.insertBefore(separator, lineBreak);
    }
  }
  function installBlockFocus(root) {
    var workspace = root.querySelector('.prefs-workspace');
    if (!workspace || workspace.getAttribute('data-focus-installed') === '1') return;
    var settingsSections = workspace.querySelectorAll('.prefs-settings-section');
    var blocks = settingsSections.length ? settingsSections : workspace.querySelectorAll(root.classList.contains('prefs-category-mode') ? '.prefs-category-card' : '.prefs-identity, #column1, #column2, #column3');
    if (blocks.length < 2) return;
    var active = null;
    function clearFocus() {
      if (active) active.classList.remove('prefs-focus-current');
      active = null;
      workspace.classList.remove('prefs-focus-active');
    }
    function focusBlock() {
      clearFocus();
      if (root.classList.contains('banda-glow-off') || root.classList.contains('banda-effects-off')) return;
      active = this;
      active.classList.add('prefs-focus-current');
      workspace.classList.add('prefs-focus-active');
    }
    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i];
      block.classList.add('prefs-focus-block');
      // A shade leaves true-color samples above it; ancestor opacity would not.
      var shade = document.createElement('div');
      shade.className = 'prefs-focus-shade';
      shade.setAttribute('aria-hidden', 'true');
      block.appendChild(shade);
      block.addEventListener('mouseenter', focusBlock);
      block.addEventListener('mouseleave', clearFocus);
    }
    window.addEventListener('blur', clearFocus);
    workspace.setAttribute('data-focus-installed', '1');
  }
  function playPortraitStatic(root) {
    var panel = root.querySelector('.prefs-preview-panel');
    if (!panel || root.className.indexOf('banda-effects-reduced') !== -1 || root.className.indexOf('banda-effects-off') !== -1) return;
    var duration = Math.min(250, Number(panel.getAttribute('data-static-duration')) || 0);
    if (duration <= 0) return;
    var canvas = document.createElement('canvas');
    if (!canvas.getContext) return;
    var context = canvas.getContext('2d');
    if (!context) return;
    canvas.className = 'prefs-preview-static';
    canvas.setAttribute('aria-hidden', 'true');
    canvas.width = Math.max(1, Math.min(900, panel.clientWidth));
    canvas.height = Math.max(1, Math.min(1200, panel.clientHeight));
    var until = Date.now() + duration;
    var timer;
    function stop() {
      window.clearTimeout(timer);
      if (canvas.parentNode) canvas.parentNode.removeChild(canvas);
    }
    function draw() {
      var remaining = until - Date.now();
      if (remaining <= 0 || document.hidden) { stop(); return; }
      // Opaque low-luminance signal loss: irregular streaks, never square pixels.
      context.fillStyle = '#070907';
      context.fillRect(0, 0, canvas.width, canvas.height);
      for (var y = 0; y < canvas.height; y += 2) {
        var shade = Math.floor(13 + Math.random() * 26);
        context.fillStyle = 'rgb(' + shade + ',' + shade + ',' + shade + ')';
        for (var segment = 0; segment < 3; segment++) {
          var x = Math.floor(Math.random() * canvas.width);
          var width = Math.floor(canvas.width * (0.06 + Math.random() * 0.55));
          context.fillRect(x, y + Math.floor(Math.random() * 2), width, 1);
        }
      }
      // Stay opaque until removal, so the changed portrait cannot show through.
      timer = window.setTimeout(draw, Math.min(remaining, 40));
    }
    panel.appendChild(canvas);
    window.addEventListener('unload', stop);
    draw();
  }
  document.addEventListener('DOMContentLoaded', function () {
    window.expireBandaNotice();
    var surface = document.querySelector('.prefs-crt, .crt-shell, .picker-crt, .banda-aux-crt');
    if (surface) {
      var tone = document.createElement('div');
      tone.className = 'banda-terminal-tone';
      tone.setAttribute('aria-hidden', 'true');
      surface.appendChild(tone);
      installEscape(surface);
    }
    var root = document.querySelector('.prefs-crt');
    if (!root) return;
    arrangeHumanEditor(root);
    arrangeCategoryCards(root);
    installSettingSeparators(root);
    installBlockFocus(root);
    playPortraitStatic(root);
    // End the workspace's temporary stacking context after its tab transition.
    window.setTimeout(function () { root.className = root.className.replace(/\btab-switching\b/g, ''); }, 180);
    window.setTimeout(function () {
    var title = document.querySelector('.prefs-brand-title');
    if (title && title.getAttribute('data-terminal-decode') === '1' && root.className.indexOf('banda-effects-reduced') === -1 && root.className.indexOf('banda-effects-off') === -1) {
      var finalText = title.innerText;
      var finalHtml = title.innerHTML;
      var alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/';
      var frame = 0;
      var timer = window.setInterval(function () {
        var resolved = Math.floor(frame / 2);
        var output = '';
        for (var i = 0; i < finalText.length; i++) output += i < resolved || finalText.charAt(i) === ' ' ? finalText.charAt(i) : alphabet.charAt(Math.floor(Math.random() * alphabet.length));
        title.innerText = output;
        if (++frame > finalText.length * 2) { window.clearInterval(timer); title.innerHTML = finalHtml; }
      }, 24);
    }
    }, 0);
    var preference = root.getAttribute('data-highlight');
    if (!preference) return;
    var links = root.getElementsByTagName('a');
    for (var n = 0; n < links.length; n++) {
      var href = links[n].getAttribute('href') || '';
      var match = /(?:[?;&])preference=([^;&]+)/.exec(href);
      if (match && match[1] === preference) links[n].className += ' banda-value-updated';
    }
  });
})();
