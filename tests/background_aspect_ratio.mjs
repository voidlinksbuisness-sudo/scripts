// Run: node tests/background_aspect_ratio.mjs /path/to/luau [/path/to/luau-compile] /path/to/pinned-INS.lua
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
const bundle = readFileSync(new URL('../assets/fftm-ui-background-variants.bin', import.meta.url));
const insPath = process.argv[4];
if (!insPath) throw new Error('A pinned INS source path is required');
const ins = readFileSync(insPath, 'utf8');

function parseBundle(bytes) {
  if (bytes.subarray(0, 8).toString('ascii') !== 'FFTMBG1\n') throw new Error('Bad crop bundle magic');
  const variants = [];
  let position = 8;

  while (position < bytes.length) {
    const lineEnd = bytes.indexOf(10, position);
    if (lineEnd < 0) throw new Error('Missing crop bundle header newline');
    const match = /^(\d+(?:\.\d+)?)\|(\d+)$/.exec(bytes.subarray(position, lineEnd).toString('ascii'));
    if (!match) throw new Error('Malformed crop bundle entry');
    const aspect = Number(match[1]);
    const size = Number(match[2]);
    const start = lineEnd + 1;
    const data = bytes.subarray(start, start + size);
    if (data.length !== size || data[0] !== 0xff || data[1] !== 0xd8) throw new Error('Invalid JPEG crop');
    variants.push({aspect, size});
    position = start + size;
  }

  return variants;
}

const variants = parseBundle(bundle);
if (variants.length !== 11) throw new Error(`Expected 11 crop variants, got ${variants.length}`);
if (bundle.length > 1024 * 1024) throw new Error('Crop bundle must stay below 1 MiB');
for (let index = 1; index < variants.length; index += 1) {
  if (variants[index - 1].aspect >= variants[index].aspect) throw new Error('Crop ratios must be sorted');
}

for (const required of [
  'FFTM_MAIN_BUILD = "2026-08-31-BACKGROUND-CACHED-CROPS-1"',
  'FFTM_MAIN_VERSION = "2026-08-31-BACKGROUND-CACHED-CROPS-1"',
  'FFTM_BACKGROUND_VARIANTS = {}',
  '/ea7e4bff68dbcf1be14bc9228026e292893230d0/assets/fftm-ui-background-variants.bin',
  'local Distance = math.abs(TargetAspect - Candidate.Aspect)',
  'Wide = State.W\n          Tall = PaneHeight',
  'if State.BackdropVariant then HidePicture(State.BackdropVariant.Holder) end',
  'Library.BackgroundImageSource = variant.Data',
]) {
  if (!main.includes(required.replaceAll('\\n', '\n'))) throw new Error(`Missing cached crop behavior: ${required}`);
}

for (const forbidden of ['wsrv.nl', 'bg_cover_', 'BackdropCropPending', 'BackdropCropReadyAt']) {
  if (main.includes(forbidden)) throw new Error(`Resize path must not contain ${forbidden}`);
}

const replacementStart = main.indexOf('[==[local Tall = (State.BackdropTall or 1) * PaneHeight');
const replacementEnd = main.indexOf(']==],', replacementStart);
if (replacementStart < 0 || replacementEnd < 0) throw new Error('Could not locate INS crop replacement');
const replacement = main.slice(replacementStart + 5, replacementEnd);
if (/HttpGet|httpget|game:Http/.test(replacement)) throw new Error('Resize replacement must perform zero HTTP');

function longString(value) {
  for (let level = 1; ; level += 1) {
    const equals = '='.repeat(level);
    if (!value.includes(`]${equals}]`)) return `[${equals}[${value}]${equals}]`;
  }
}

const pattern = 'local Wide = State%.BackdropWide and State%.BackdropWide %* State%.W or PaneHeight %* 0%.6%s+local Tall = State%.BackdropWide and %(State%.BackdropTall or 1%) %* PaneHeight or PaneHeight';
const test = `
local source = ${longString(ins)}
local replacement = ${longString(replacement)}
local patched, replacements = string.gsub(source, ${JSON.stringify(pattern)}, replacement, 1)
assert(replacements == 1, "pinned INS renderer patch must match exactly once")
local cleaned, hiddenReplacements = string.gsub(
    patched,
    "HidePicture%(State%.Icon%)%s+HidePicture%(State%.Backdrop%)%s+end",
    "HidePicture(State.Icon)\\n    HidePicture(State.Backdrop)\\n    if State.BackdropVariant then HidePicture(State.BackdropVariant.Holder) end\\n  end",
    1
)
assert(hiddenReplacements == 1, "pinned INS cleanup patch must match exactly once")
assert(string.find(cleaned, "HidePicture(State.BackdropVariant.Holder)", 1, true))
assert(string.find(patched, "local Distance = math.abs(TargetAspect - Candidate.Aspect)", 1, true))
assert(string.find(patched, "Wide = State.W", 1, true))
assert(string.find(patched, "Tall = PaneHeight", 1, true))
assert(not string.find(replacement, "HttpGet", 1, true), "resize path must not perform HTTP")

local ratios = { 0.8, 1, 1.2, 1.333333, 1.5, 1.6, 1.777778, 2, 2.333333, 2.666667, 3 }
local function selectRatio(windowWidth, paneHeight)
    local target = windowWidth / paneHeight
    local selected
    local best = math.huge
    for _, ratio in ipairs(ratios) do
        local distance = math.abs(target - ratio)
        if distance < best then selected, best = ratio, distance end
    end
    return selected
end

for _, size in ipairs({ {500, 600}, {760, 500}, {910, 820}, {1200, 600}, {1851, 680} }) do
    local selected = selectRatio(size[1], size[2])
    assert(selected ~= nil)
    local relativeError = math.abs(selected - size[1] / size[2]) / (size[1] / size[2])
    assert(relativeError < 0.16, "nearest crop must stay close to the window ratio")
    local wide, tall = size[1], size[2]
    assert(wide == size[1] and tall == size[2], "selected crop must fill the pane exactly")
end

local first = { Holder = { Image = { Visible = true } } }
local second = { Holder = { Image = { Visible = false } } }
local active = first
if active ~= second then
    active.Holder.Image.Visible = false
    active = second
end
active.Holder.Image.Visible = true
assert(first.Holder.Image.Visible == false, "old crop must be hidden when ratio changes")
assert(second.Holder.Image.Visible == true, "new crop must become visible")
print("PASS: cached center crops fill the pane with zero resize-time HTTP")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-background-cached-crops-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}
try {
  const testPath = join(directory, 'background_cached_crops.luau');
  writeFileSync(testPath, test);
  run(process.argv[2] || 'luau', [testPath]);
  if (process.argv[3]) {
    const compilePath = join(directory, 'loader_prefixed.luau');
    writeFileSync(compilePath, 'local print = function(...) end\nlocal warn = function(...) end\n' + main);
    run(process.argv[3], ['--null', compilePath]);
  }
} finally {
  rmSync(directory, {recursive: true, force: true});
}
