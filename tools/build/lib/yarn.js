// DemonicLynx for BandaMarines
import fs from 'fs';
import path from 'path';
import Juke from '../juke/index.js';

let yarnPath;

export const yarn = (...args) => {
  if (!yarnPath) {
    yarnPath = Juke.glob('./tgui/.yarn/releases/*.cjs')[0]
      .replace('/tgui/', '/');
  }
  const tempPath = path.resolve('tgui/.yarn/tmp');
  fs.mkdirSync(tempPath, { recursive: true });
  return Juke.exec('node', [
    yarnPath,
    ...args.filter((arg) => typeof arg === 'string'),
  ], {
    cwd: './tgui',
    env: {
      ...process.env,
      TEMP: tempPath,
      TMP: tempPath,
    },
  });
};
