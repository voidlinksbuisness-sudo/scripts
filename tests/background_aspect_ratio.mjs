// Run: node tests/background_aspect_ratio.mjs /path/to/luau [/path/to/luau-compile] /path/to/pinned-INS.lua
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
const insPath = process.argv[4];
if (!insPath) throw new Error('A pinned INS source path is required');
const ins = readFileSync(insPath, 'utf8');

function longString(value) {
  for (let level = 1; ; level += 1) {
    const equals = '='.repeat(level);
    if (!value.includes(`]${equals}]`)) return `[${equals}[${value}]${equals}]`;
  }
}

const pattern = 'local Wide = State%.BackdropWide and State%.BackdropWide %* State%.W or PaneHeight %* 0%.6%s+local Tall = State%.BackdropWide and %(State%.BackdropTall or 1%) %* PaneHeight or PaneHeight';
const replacement = 'local Tall = (State.BackdropTall or 1) * PaneHeight\\n      local Wide = State.BackdropWide and State.BackdropWide * Tall or Tall * 0.6\\n      if State.BackdropWide and Wide > State.W then\\n        Wide = State.W\\n        Tall = Wide / State.BackdropWide\\n      end';

for (const required of [
  'Library.BackgroundAspectRatio = 1800 / 900',
  'aspectRatio = Library.BackgroundAspectRatio',
  'heightFraction = 1',
  'Library.Raw:SetBackgroundImage(\\n    Library.BackgroundImageUrl,\\n    0.14\\n)',
]) {
  if (!main.includes(required.replaceAll('\\n', '\n'))) throw new Error(`Missing background aspect behavior: ${required}`);
}

const test = `
local source = ${longString(ins)}
local patched, replacements = string.gsub(source, ${JSON.stringify(pattern)}, ${JSON.stringify(replacement)}, 1)
assert(replacements == 1, "pinned INS renderer patch must match exactly once")
assert(string.find(patched, "local Wide = State.BackdropWide and State.BackdropWide * Tall or Tall * 0.6", 1, true))
assert(string.find(patched, "if State.BackdropWide and Wide > State.W then", 1, true))
assert(not string.find(patched, "State.BackdropWide * State.W", 1, true))

local function layout(windowWidth, paneHeight, aspectRatio, heightFraction)
    local tall = (heightFraction or 1) * paneHeight
    local wide = aspectRatio and aspectRatio * tall or tall * 0.6
    if aspectRatio and wide > windowWidth then
        wide = windowWidth
        tall = wide / aspectRatio
    end
    return (windowWidth - wide) / 2, wide, tall
end

for _, size in ipairs({{500, 400}, {700, 400}, {1200, 650}, {360, 650}}) do
    local x, wide, tall = layout(size[1], size[2], 1800 / 900, 1)
    assert(wide / tall == 2, "background must preserve its 2:1 aspect ratio")
    assert(x == (size[1] - wide) / 2, "background must stay horizontally centered")
    assert(wide <= size[1], "background must not overflow window width")
    assert(tall <= size[2], "background must not overflow pane height")
end

local _, narrowWide, narrowTall = layout(500, 400, 2, 1)
assert(narrowWide == 500 and narrowTall == 250, "narrow windows must constrain by width")
local _, wideWindowWide, wideWindowTall = layout(1000, 400, 2, 1)
assert(wideWindowWide == 800 and wideWindowTall == 400, "wide windows must use full height")
print("PASS: contained 2:1 background layout and exact pinned INS patch")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-background-aspect-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}
try {
  const testPath = join(directory, 'background_aspect_ratio.luau');
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
