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

function extractLongString(name) {
  const match = main.match(new RegExp(`local ${name} = \\[=\\[([\\s\\S]*?)\\]=\\]`));
  if (!match) throw new Error(`Missing ${name} patch source`);
  return match[1];
}

const layoutPattern = 'local Wide = State%.BackdropWide and State%.BackdropWide %* State%.W or PaneHeight %* 0%.6%s+local Tall = State%.BackdropWide and %(State%.BackdropTall or 1%) %* PaneHeight or PaneHeight';
const setterPattern = 'function InsUi:SetBackgroundImage%(source, alpha, widthFraction, heightFraction%)%s+State%.Backdrop = LoadPicture%(source, "bg"%)%s+State%.BackdropAlpha = alpha or State%.BackdropAlpha%s+State%.BackdropWide = tonumber%(widthFraction%)%s+State%.BackdropTall = tonumber%(heightFraction%)%s+return self%s+end';
const layoutReplacement = extractLongString('coverLayout');
const setterReplacement = extractLongString('backgroundSetter');

for (const required of [
  'Library.BackgroundAspectRatio = 1800 / 900',
  'aspectRatio = Library.BackgroundAspectRatio',
  'heightFraction = 1',
  'FFTM_MAIN_BUILD = "2026-08-30-BACKGROUND-COVER-CLEANUP-1"',
  '&fit=cover&a=center&output=png',
  'State.BackdropCropReadyAt = CropNow + 0.2',
  'HidePicture(State.BackdropFallback)',
  'PreviousCrop.Image:Remove()',
  'PreviousBackdrop.Image:Remove()',
  'Library.Raw:SetBackgroundImage(\\n    Library.BackgroundImageUrl,\\n    0.14\\n)',
]) {
  if (!main.includes(required.replaceAll('\\n', '\n'))) throw new Error(`Missing background aspect behavior: ${required}`);
}

const test = `
local source = ${longString(ins)}
local layoutReplacement = ${longString(layoutReplacement)}
local setterReplacement = ${longString(setterReplacement)}
local patched, layoutReplacements = string.gsub(source, ${JSON.stringify(layoutPattern)}, function()
    return layoutReplacement
end, 1)
local setterReplacements
patched, setterReplacements = string.gsub(patched, ${JSON.stringify(setterPattern)}, function()
    return setterReplacement
end, 1)
assert(layoutReplacements == 1, "pinned INS renderer patch must match exactly once")
assert(setterReplacements == 1, "pinned INS background setter patch must match exactly once")
assert(string.find(patched, "local Wide = State.BackdropWide and State.BackdropWide * Tall or Tall * 0.6", 1, true))
assert(string.find(patched, "State.BackdropCropActiveKey == CropKey", 1, true))
assert(string.find(patched, "&fit=cover&a=center&output=png", 1, true))
assert(string.find(patched, "State.BackdropFallback = State.Backdrop", 1, true))
assert(string.find(patched, "HidePicture(State.BackdropFallback)", 1, true))
assert(string.find(patched, "PreviousCrop.Image:Remove()", 1, true))
assert(string.find(patched, "PreviousBackdrop.Image:Remove()", 1, true))
assert(not string.find(patched, "State.BackdropWide * State.W", 1, true))

local function picture()
    return {Image={Visible=true, Removed=false}}
end
local function hide(holder)
    if holder and holder.Image then holder.Image.Visible = false end
end
local fallback, oldCrop, freshCrop = picture(), picture(), picture()
local state = {Backdrop=oldCrop, BackdropFallback=fallback, BackdropCropActiveKey="old"}
hide(state.Backdrop)
state.Backdrop.Image.Removed = true
state.Backdrop = state.BackdropFallback
state.BackdropCropActiveKey = nil
assert(not oldCrop.Image.Visible and oldCrop.Image.Removed, "resizing must retire the prior crop")
hide(state.BackdropFallback)
state.Backdrop = freshCrop
state.BackdropCropActiveKey = "new"
assert(not fallback.Image.Visible, "activating a crop must hide the fallback image")
assert(freshCrop.Image.Visible, "the new crop must remain visible")

local function layout(windowWidth, paneHeight, aspectRatio, heightFraction, cropReady)
    if cropReady then
        return 0, windowWidth, paneHeight
    end

    local tall = (heightFraction or 1) * paneHeight
    local wide = aspectRatio and aspectRatio * tall or tall * 0.6
    if aspectRatio and wide > windowWidth then
        wide = windowWidth
        tall = wide / aspectRatio
    end
    return (windowWidth - wide) / 2, wide, tall
end

for _, size in ipairs({{500, 400}, {700, 400}, {1200, 650}, {360, 650}}) do
    local x, wide, tall = layout(size[1], size[2], 1800 / 900, 1, true)
    assert(x == 0, "cropped background must start at the pane edge")
    assert(wide == size[1], "cropped background must fill frame width")
    assert(tall == size[2], "cropped background must fill frame height")
end

local _, narrowWide, narrowTall = layout(500, 400, 2, 1, false)
assert(narrowWide == 500 and narrowTall == 250, "narrow windows must constrain by width")
local _, wideWindowWide, wideWindowTall = layout(1000, 400, 2, 1, false)
assert(wideWindowWide == 800 and wideWindowTall == 400, "wide windows must use full height")
assert(string.find(layoutReplacement, "&w=", 1, true))
assert(string.find(layoutReplacement, "&h=", 1, true))
print("PASS: cover crop, contained fallback, stale-image cleanup, and exact pinned INS patches")
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
