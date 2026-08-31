// Run: node tests/auto_ali_cqc.mjs /path/to/luau [/path/to/luau-compile]
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
const config = readFileSync(new URL('../game_config.lua', import.meta.url), 'utf8');

const cqcStart = config.indexOf('["CQC"] = {');
const cqcEnd = config.indexOf('["Debug"] = {', cqcStart);
if (cqcStart < 0 || cqcEnd < 0) throw new Error('CQC config section is missing');
const cqc = config.slice(cqcStart, cqcEnd);

for (const required of [
  '["rbxassetid://72310116631906"] = {',
  'DisplayName = "M2"',
  'PreserveHeavyLogic = true',
  'ParryFunction = function(data)',
]) {
  if (!cqc.includes(required)) throw new Error(`CQC M2 is missing: ${required}`);
}

if ((config.match(/PreserveHeavyLogic\s*=\s*true/g) || []).length !== 1) {
  throw new Error('Only CQC M2 should preserve its native heavy logic');
}

for (const required of [
  'function VisualRuntime.ShouldAutoAliCounter(attackConfig)',
  'and attackConfig.PreserveHeavyLogic ~= true',
  'local useAutoAliCounter = AutoAliCounterToggle.Get()',
  'if useAutoAliCounter then',
  'and not (isHeavy and AutoCounterToggle.Get())',
  'and not useAutoAliCounter',
]) {
  if (!main.includes(required)) throw new Error(`Auto Ali guard is missing: ${required}`);
}

const helperStart = main.indexOf('function VisualRuntime.IsHeavyAttack(attackConfig)');
const helperEnd = main.indexOf('\nfunction Counter(', helperStart);
if (helperStart < 0 || helperEnd < 0) throw new Error('Could not extract heavy decision helpers');
const helpers = main.slice(helperStart, helperEnd);

const harness = `
VisualRuntime = {}
${helpers}

local cqcM2 = {
    Style = "CQC",
    DisplayName = "M2",
    PreserveHeavyLogic = true,
    ParryFunction = function() end,
}
local boxingM2 = { Style = "BoxingAnims", DisplayName = "M2" }
local aliM2 = { Style = "AliAnims", DisplayName = "M2" }
local normalM1 = { Style = "CQC", DisplayName = "1stM1" }

assert(VisualRuntime.IsHeavyAttack(cqcM2), "CQC M2 must remain classified as heavy")
assert(not VisualRuntime.ShouldAutoAliCounter(cqcM2), "Auto Ali must not claim CQC M2")
assert(VisualRuntime.ShouldAutoAliCounter(boxingM2), "Boxing M2 must retain Auto Ali handling")
assert(VisualRuntime.ShouldAutoAliCounter(aliM2), "Ali M2 must retain Auto Ali handling")
assert(not VisualRuntime.ShouldAutoAliCounter(normalM1), "Auto Ali must not claim normal M1s")
print("PASS: Auto Ali preserves CQC M2 heavy logic and still handles other M2s")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-auto-ali-cqc-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}

try {
  const harnessPath = join(directory, 'auto_ali_cqc.luau');
  writeFileSync(harnessPath, harness);
  run(process.argv[2] || 'luau', [harnessPath]);

  if (process.argv[3]) {
    const compilePath = join(directory, 'loader_prefixed.luau');
    writeFileSync(compilePath, 'local print = function(...) end\nlocal warn = function(...) end\n' + main);
    run(process.argv[3], ['--null', compilePath]);
  }
} finally {
  rmSync(directory, {recursive: true, force: true});
}
