import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');

for (const required of [
  '"Animation Logger"',
  'Title = "Add Unknowns to Ignore"',
  'Title = "Copy Logged IDs"',
  'Title = "Clear Animation Cache"',
  'Logged IDs: 0',
  'Ignored IDs: ',
  'local function LogAnimation(assetId, trackInfo)',
  'local showAnimationText = VisualRuntime.AnimationIdEspEnabled',
]) {
  if (!main.includes(required)) throw new Error(`Missing animation logger behavior: ${required}`);
}

const ignoreStart = main.indexOf('local IgnoreIds = {');
const ignoreEnd = main.indexOf('--IgnoreIds = {}', ignoreStart);
if (ignoreStart < 0 || ignoreEnd < 0) throw new Error('Ignore list is missing');
const ignoreIds = main.slice(ignoreStart, ignoreEnd).match(/\d{8,}/g) || [];
if (ignoreIds.length !== 49) throw new Error(`Expected 49 built-in ignored IDs, found ${ignoreIds.length}`);

const loggerStart = main.indexOf('local function ProcessEspAndLogging()');
const loggerEnd = main.indexOf('\nfunction VisualRuntime.ClearParryTargetTrackers()', loggerStart);
if (loggerStart < 0 || loggerEnd < 0) throw new Error('Could not extract logger loop');
const logger = main.slice(loggerStart, loggerEnd);
if (/if not VisualRuntime\.AnimationIdEspEnabled then\s+continue/.test(logger)) {
  throw new Error('Unknown animation logging must keep working while its overhead text is hidden');
}

if (process.argv[2]) {
  const directory = mkdtempSync(join(tmpdir(), 'fftm-animation-logger-'));
  try {
    const compilePath = join(directory, 'loader-prefixed.luau');
    writeFileSync(compilePath, 'local print = function(...) end\nlocal warn = function(...) end\n' + main);
    const result = spawnSync(process.argv[2], ['--null', compilePath], { stdio: 'inherit' });
    if (result.error) throw result.error;
    if (result.status !== 0) throw new Error(`Luau compilation failed (${result.status})`);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

console.log('PASS: animation logger UI, ignore list, hidden-overlay logging, and compilation');
