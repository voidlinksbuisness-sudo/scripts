// Run: node tests/single_cursor_target.mjs /path/to/luau [/path/to/luau-compile]
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');

for (const required of [
  'function CycleEvent(manualCycle, singleTargetOnly)',
  'if manualCycle and singleTargetOnly then',
  'VisualRuntime.FindSingleCursorCandidate(validCharacters)',
  'CycleEvent(true, true)',
  '"select_single_target"',
  '"Select Single Target"',
  '"No target under cursor"',
  'spec.Id == "select_single_target"',
  'Select Single Cursor Target Now',
]) {
  if (!main.includes(required)) throw new Error(`Missing single-target behavior: ${required}`);
}

if (!main.includes('local function TriggerManualCycle()\n    CycleEvent(true)')) {
  throw new Error('Existing multi-target cursor action must remain unchanged');
}

const helperStart = main.indexOf('function VisualRuntime.FindSingleCursorCandidate(validCharacters)');
const helperEnd = main.indexOf('\nfunction CycleEvent(', helperStart);
if (helperStart < 0 || helperEnd < 0) throw new Error('Could not extract cursor candidate helper');
const helper = main.slice(helperStart, helperEnd);

const harness = `
VisualRuntime = {}
_G = {}
${helper}

local offscreen = {
    Character = "offscreen",
    Distance = 1,
    OnScreen = false,
    CursorDistanceSquared = 1,
}
local near = {
    Character = "near",
    Distance = 15,
    OnScreen = true,
    CursorDistanceSquared = 25,
}
local fartherFromCursor = {
    Character = "farther",
    Distance = 5,
    OnScreen = true,
    CursorDistanceSquared = 400,
}

assert(
    VisualRuntime.FindSingleCursorCandidate({offscreen, fartherFromCursor, near}) == "near",
    "the closest on-screen cursor candidate must win"
)
assert(
    VisualRuntime.FindSingleCursorCandidate({offscreen}) == nil,
    "off-screen characters must never be selected"
)

_G.FFTMSingleTargetCursorRadius = 20
assert(
    VisualRuntime.FindSingleCursorCandidate({{
        Character = "outside-radius",
        Distance = 1,
        OnScreen = true,
        CursorDistanceSquared = 401,
    }}) == nil,
    "a press away from a character must leave targeting unchanged"
)
assert(
    VisualRuntime.FindSingleCursorCandidate({{
        Character = "inside-radius",
        Distance = 1,
        OnScreen = true,
        CursorDistanceSquared = 400,
    }}) == "inside-radius",
    "the configured radius boundary must be accepted"
)
print("PASS: single cursor targeting selects exactly one hovered character")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-single-cursor-target-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}

try {
  const harnessPath = join(directory, 'single_cursor_target.luau');
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
