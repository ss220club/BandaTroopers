// DemonicLynx for BandaMarines
import assert from "node:assert/strict";
import fs from "fs";
import os from "os";
import path from "path";
import test from "node:test";

import {
  FACTION_MUSIC_MANIFEST,
  generateFactionMusicManifest,
} from "./faction_music.js";

const makeFile = (root, relativePath) => {
  const filePath = path.join(root, ...relativePath.split("/"));
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, "test");
};

test("generates deterministic recursive faction music resources", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "faction-music-"));
  try {
    makeFile(root, "sound/factions music/USCM Marines/zeta.mp3");
    makeFile(root, "sound/factions music/USCM Marines/alpha.OGG");
    makeFile(root, "sound/factions music/UNSC/nested/theme.mp3");
    makeFile(root, "sound/factions music/UPP/nested/track.wav");
    makeFile(root, "sound/factions music/UPP/readme.txt");

    const first = generateFactionMusicManifest(root);
    const second = generateFactionMusicManifest(root);
    const manifest = fs.readFileSync(
      path.join(root, FACTION_MUSIC_MANIFEST),
      "utf8"
    );

    assert.equal(first.changed, true);
    assert.equal(first.trackCount, 4);
    assert.equal(second.changed, false);
    assert.match(manifest, /DemonicLynx for BandaMarines/);
    assert.match(
      manifest,
      /'sound\/factions music\/UPP\/nested\/track\.wav'/
    );
    assert.match(
      manifest,
      /'sound\/factions music\/UNSC\/nested\/theme\.mp3'/
    );
    assert.ok(manifest.indexOf("alpha.OGG") < manifest.indexOf("zeta.mp3"));
    assert.doesNotMatch(manifest, /readme\.txt/);
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("rejects filenames that cannot be represented as DM resources", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "faction-music-"));
  try {
    makeFile(root, "sound/factions music/PMC/bad'track.mp3");
    assert.throws(
      () => generateFactionMusicManifest(root),
      /cannot contain apostrophes or newlines/
    );
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("discovers a copied track even when it predates the manifest", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "faction-music-"));
  try {
    makeFile(root, "sound/factions music/USCM Marines/current.mp3");
    generateFactionMusicManifest(root);

    const manifestPath = path.join(root, FACTION_MUSIC_MANIFEST);
    const futureTime = new Date("2030-01-01T00:00:00Z");
    fs.utimesSync(manifestPath, futureTime, futureTime);

    const copiedTrack = path.join(
      root,
      "sound",
      "factions music",
      "UPP",
      "copied.mp3"
    );
    makeFile(root, "sound/factions music/UPP/copied.mp3");
    const oldTime = new Date("2020-01-01T00:00:00Z");
    fs.utimesSync(copiedTrack, oldTime, oldTime);

    const result = generateFactionMusicManifest(root);
    const manifest = fs.readFileSync(manifestPath, "utf8");

    assert.equal(result.changed, true);
    assert.equal(result.trackCount, 2);
    assert.match(manifest, /'sound\/factions music\/UPP\/copied\.mp3'/);
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});
