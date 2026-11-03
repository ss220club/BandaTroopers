// Hair/facial catalogs share the loadout's readiness-driven command sequence.
document.addEventListener('DOMContentLoaded', function () {
  var root = document.getElementById('bandaAccessory');
  if (!root) return;
  var generation = Number(root.getAttribute('data-generation'));
  var kind = root.getAttribute('data-kind');
  var loader = document.getElementById('accessoryLoader');
  var catalog = document.getElementById('accessoryCatalog');
  var rows = loader.querySelectorAll('.loadout-command');
  var closed = false;
  var busy = false;
  var received = false;
  var sequence = createBandaLoadoutSequence(rows.length, function (count) {
    for (var i = 0; i < count; i++) {
      rows[i].style.display = 'flex';
      rows[i].querySelector('.loadout-command-status').innerText = i < count - 1 ? '[ OK ]' : '[ ... ]';
    }
  }, function () {
    loader.style.display = 'none';
    catalog.style.display = 'block';
    root.querySelector('.picker-subtitle').innerText = root.getAttribute('data-subtitle');
    var selected = catalog.querySelector('.selected');
    if (selected) selected.scrollIntoView(false);
  }, function () {
    document.getElementById('accessoryWait').style.display = 'block';
  }, window.setTimeout, window.clearTimeout);

  window.receiveBandaAccessory = function (raw) {
    if (closed) return;
    var data;
    try { data = JSON.parse(raw); } catch (e) { return; }
    if (Number(data.generation) !== generation) return;
    if (typeof data.html === 'string' && !received) {
      received = true;
      catalog.innerHTML = data.html;
      var images = catalog.getElementsByTagName('img');
      var pending = 0;
      function loaded() {
        this.onload = this.onerror = null;
        if (--pending === 0 && !closed) sequence.ready();
      }
      for (var j = 0; j < images.length; j++) {
        if (!images[j].complete) {
          pending++;
          images[j].onload = loaded;
          images[j].onerror = loaded;
        }
      }
      if (!pending) sequence.ready();
    }
    if (typeof data.selected === 'string') {
      var cards = catalog.querySelectorAll('.picker-card');
      for (var n = 0; n < cards.length; n++) {
        var selected = cards[n].id === data.selected;
        cards[n].className = 'picker-card' + (selected ? ' selected' : '');
        cards[n].setAttribute('aria-pressed', selected ? 'true' : 'false');
      }
      busy = false;
    }
  };
  root.addEventListener('click', function (event) {
    var link = event.target;
    while (link && link !== root && link.tagName !== 'A') link = link.parentNode;
    if (!link || link === root) return;
    if ((link.getAttribute('href') || '').indexOf('preference=select_accessory_style') !== -1) {
      if (busy) { event.preventDefault(); return; }
      busy = true;
    }
  });
  window.addEventListener('unload', function () { closed = true; sequence.stop(); });
  window.setTimeout(function () {
    if (!closed) window.location = 'byond://?_src_=prefs;preference=accessory_ready;kind=' + kind + ';generation=' + generation;
  }, 30);
});
