// Pure sequence controller, also exercised by the focused Node regression test.
function createBandaLoadoutSequence(count, show, finish, wait, schedule, cancel) {
  var index = 1;
  var ready = false;
  var stopped = false;
  var timer;
  function tick() {
    if (stopped) return;
    if (index < count) {
      index++;
      show(index);
      timer = schedule(tick, ready ? 45 : 240);
    } else if (ready) {
      stopped = true;
      finish();
    } else {
      wait();
    }
  }
  timer = schedule(tick, 240);
  return {
    ready: function () {
      if (stopped || ready) return;
      ready = true;
      cancel(timer);
      timer = schedule(tick, 45);
    },
    stop: function () { stopped = true; cancel(timer); },
  };
}

if (typeof module !== 'undefined') module.exports = { createBandaLoadoutSequence: createBandaLoadoutSequence };

if (typeof window !== 'undefined') {
  window.toggleLoadoutCategory = function (id, link) {
    var panel = document.getElementById(id);
    var opening = panel.style.display === 'none';
    panel.style.display = opening ? 'flex' : 'none';
    link.querySelector('.loadout-category-marker').innerText = opening ? '[-]' : '[+]';
  };
  document.addEventListener('DOMContentLoaded', function () {
    var root = document.getElementById('bandaLoadout');
    if (!root) return;
    var generation = Number(root.getAttribute('data-generation'));
    var loader = document.getElementById('loadoutLoader');
    var catalog = document.getElementById('loadoutCatalog');
    var rows = loader.querySelectorAll('.loadout-command');
    var busy = false;
    var closed = false;
    var sequence = createBandaLoadoutSequence(rows.length, function (count) {
      for (var i = 0; i < count; i++) {
        rows[i].style.display = 'flex';
        rows[i].querySelector('.loadout-command-status').innerText = i < count - 1 ? '[ OK ]' : '[ ... ]';
      }
    }, function () {
      loader.style.display = 'none';
      catalog.style.display = 'block';
      document.getElementById('loadoutReset').style.display = 'block';
      root.querySelector('.picker-subtitle').innerText = root.getAttribute('data-equipped') === 'EQUIPPED' ? 'EXPAND A CATEGORY AND SELECT EQUIPMENT' : 'РАСКРОЙТЕ КАТЕГОРИЮ И ВЫБЕРИТЕ ПРЕДМЕТ';
    }, function () {
      document.getElementById('loadoutWait').style.display = 'block';
    }, window.setTimeout, window.clearTimeout);

    window.receiveBandaLoadout = function (raw) {
      if (closed) return;
      var data;
      try { data = JSON.parse(raw); } catch (e) { return; }
      if (Number(data.generation) !== generation) return;
      if (data.error) {
        sequence.stop();
        document.getElementById('loadoutWait').innerText = data.error;
        document.getElementById('loadoutWait').style.display = 'block';
        return;
      }
      if (typeof data.html === 'string') {
        catalog.innerHTML = data.html;
        var images = catalog.getElementsByTagName('img');
        var pending = 0;
        function loaded() { if (--pending === 0 && !closed) sequence.ready(); }
        for (var j = 0; j < images.length; j++) {
          if (!images[j].complete) {
            pending++;
            images[j].onload = loaded;
            images[j].onerror = loaded;
          }
        }
        if (!pending) sequence.ready();
      }
      if (data.equipped) {
        var selected = {};
        for (var k = 0; k < data.equipped.length; k++) selected[data.equipped[k]] = true;
        var cards = catalog.querySelectorAll('.loadout-card');
        for (var n = 0; n < cards.length; n++) {
          var card = cards[n];
          var equipped = !!selected[card.id];
          card.className = 'loadout-card' + (equipped ? ' equipped' : '');
          card.querySelector('.loadout-card-state').innerText = equipped ? root.getAttribute('data-equipped') : '';
        }
        document.getElementById('loadoutSummary').innerText = data.summary;
        busy = false;
      }
      if (data.error_feedback) {
        var frame = root.querySelector('.picker-terminal');
        frame.className = 'picker-terminal banda-error-feedback';
        window.setTimeout(function () { frame.className = 'picker-terminal'; }, 250);
      }
    };
    root.addEventListener('click', function (event) {
      var link = event.target;
      while (link && link !== root && link.tagName !== 'A') link = link.parentNode;
      if (!link || link === root) return;
      var href = link.getAttribute('href') || '';
      if (href.indexOf('task=toggle') !== -1 || href.indexOf('task=reset_picker') !== -1) {
        if (busy) { event.preventDefault(); return; }
        busy = true;
      }
    });
    window.addEventListener('unload', function () { closed = true; sequence.stop(); });
    // Let the first already-visible row paint before requesting expensive data.
    window.setTimeout(function () {
      if (!closed) window.location = 'byond://?_src_=prefs;preference=loadout;task=ready;generation=' + generation;
    }, 30);
  });
}
