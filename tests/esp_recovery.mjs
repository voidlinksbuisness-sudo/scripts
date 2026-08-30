// Run: node tests/esp_recovery.mjs /path/to/luau [/path/to/luau-compile]
// FFTM_TEST_REF=origin/main runs the same regressions against a previous commit.
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

function source(path) {
  if (!process.env.FFTM_TEST_REF) return readFileSync(new URL(`../${path}`, import.meta.url), 'utf8');
  const result = spawnSync('git', ['show', `${process.env.FFTM_TEST_REF}:${path}`], { encoding: 'utf8' });
  if (result.status !== 0) throw new Error(result.stderr);
  return result.stdout;
}
function extract(text, start, end) {
  const first = text.indexOf(start), last = text.indexOf(end, first + start.length);
  if (first < 0 || last < 0) throw new Error(`Missing source boundary: ${start}`);
  return text.slice(first, last);
}
const main = source('fftm_main.lua'), standalone = source('esp.lua');
const test = `
local now = 0
local os = {clock = function() return now end}
local _G = {}
local function warn() end
local vectorMeta = {}
local function vector(x, y, z) return setmetatable({X=x, Y=y, Z=z or 0}, vectorMeta) end
vectorMeta.__add = function(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
local Vector3 = {new = vector}
local Vector2 = {new = vector}
local C = {box = {}, line = {}, health = {}}
local Drawing = {Fonts = {Fortnite = 1}}
function Drawing.new(kind)
    return {Kind = kind, Visible = false, Remove = function(self) self.Removed = true; self.Visible = false end}
end
local Players = {List = {}, Calls = 0}
function Players:GetPlayers()
    self.Calls += 1
    if self.Fail then error('enumeration failed') end
    return self.List
end
local function character(x)
    local char = {}
    char.RootLookups, char.HumanoidLookups = 0, 0
    char.Root = {Parent = char, Position = vector(x, 0, 0)}
    char.Humanoid = {Parent = char, Health = 100}
    function char:FindFirstChild() self.RootLookups += 1; return self.Root end
    function char:FindFirstChildOfClass() self.HumanoidLookups += 1; return self.Humanoid end
    return char
end
local LocalPlayer = {Parent = Players, Character = character(0)}
local player = {Parent = Players, Character = character(10)}
Players.List = {LocalPlayer, player}
local Camera = {ViewportSize = vector(800,600), CFrame = {Position = vector(0,0,0)}}
local workspace = {CurrentCamera = Camera}
local projectionFail = false
local function WorldToScreen(pos)
    if projectionFail then error('projection failed') end
    return vector(200 + pos.X, 200), true
end
local callbacks = {}
local RunService = {RenderStepped = {Connect = function(_, fn) table.insert(callbacks, fn) end}}
local FFTM_RUNNING = true

do
${extract(main, '--// STATE', '--// PLAYER HELPERS')}
${extract(main, 'local VisualRuntime = {', '--==================================================\n-- INS VISUAL CONTROLS')}
function VisualRuntime.PositionAutoParryStatus() error('broken optional status Drawing') end
local function UpdateSelectedMarkers() error('broken optional selection Drawing') end
${extract(main, 'VisualRuntime.UpdateRate =', '\nprint("Free Fortnite')}
local function frame()
    now += 1 / 30
    for _, callback in ipairs(callbacks) do callback(1 / 30) end
end
state.ESP, state.Tracers, state.PlayerHealth = true, true, true
frame()
assert(VisualRuntime.EffectiveUpdateRate == 30)
assert(espBoxes[1] and espBoxes[1].Visible, 'optional overlay errors must not stop ESP')
assert(healthTexts[1].Visible)
local previousX = espBoxes[1].Position.X
local oldRoot = player.Character.Root
player.Character.Root = {Parent = player.Character, Position = vector(20,0,0)}
-- Old part still reports the same parent: a parent-only cache check misses it.
for _ = 1, 8 do frame() end
assert(espBoxes[1].Position.X ~= previousX, 'must reacquire a replaced root on the next visual frame')
assert(VisualRuntime.CharacterCache[player].Root ~= oldRoot)
projectionFail = true
frame()
assert(not espBoxes[1].Visible and not healthTexts[1].Visible, 'failed projection must not leave stale drawings')
projectionFail = false
frame()
assert(espBoxes[1].Visible and healthTexts[1].Visible)
local camera = Camera
Camera, workspace.CurrentCamera = nil, nil
frame()
assert(not espBoxes[1].Visible)
workspace.CurrentCamera = camera
frame()
assert(espBoxes[1].Visible)
Players.Fail = true
VisualRuntime.NextPlayerRefreshAt = 0
frame()
assert(espBoxes[1].Visible, 'failed enumeration must not prevent existing-player updates')
Players.Fail = false
local calls = Players.Calls
for _ = 1, 10 do
    VisualRuntime.ReportPlayerVisualError(player, 'stale proxy')
    frame()
end
assert(Players.Calls == calls, 'one bad player must not trigger GetPlayers every frame')
assert(espBoxes[1].Visible)
player.Parent = nil
frame()
assert(not espBoxes[1].Visible and not healthTexts[1].Visible, 'departed player must hide without waiting for roster refresh')
player.Parent = Players
state.ESP, state.Tracers, state.PlayerHealth = false, false, false
frame()
state.ESP = true
frame()
assert(espBoxes[1].Visible, 're-enable should draw immediately')
local rootLookups, humanoidLookups = player.Character.RootLookups, player.Character.HumanoidLookups
for _ = 1, 120 do frame() end
assert(player.Character.RootLookups - rootLookups <= 25, 'root lookup cache regressed to every visual frame')
assert(player.Character.HumanoidLookups - humanoidLookups <= 25, 'humanoid lookup cache regressed to every visual frame')
local originalPlayers = VisualRuntime.Players
VisualRuntime.Players = table.create(25, player)
VisualRuntime.RefreshUpdateInterval()
assert(VisualRuntime.EffectiveUpdateRate == 15, '24 remote players should reduce base visuals to 15 Hz')
VisualRuntime.Players = table.create(41, player)
VisualRuntime.RefreshUpdateInterval()
assert(VisualRuntime.EffectiveUpdateRate == 12, 'large servers should respect the 12 Hz floor')
_G.FFTMAdaptiveVisuals = false
VisualRuntime.RefreshUpdateInterval()
assert(VisualRuntime.EffectiveUpdateRate == 30, 'adaptive scheduling must support an opt-out')
_G.FFTMAdaptiveVisuals = nil
VisualRuntime.Players = originalPlayers
end

do
local state = {ESP = true, Tracers = true, TracerTransparency = 0}
local UPDATE_RATE, UPDATE_INTERVAL = 30, 1 / 30
local function getEspMaxDistanceSquared() return 500 * 500 end
${extract(standalone, '--// PLAYER CACHE', '--// INPUT')}
updateEspTracers()
assert(drawingsByPlayer[player].Box.Visible)
characterCache[player] = nil
updateEspTracers()
assert(drawingsByPlayer[player].Box.Visible, 'missing data must rebuild without the one-second roster timer')
characterCache[player] = nil
reconcilePlayers()
assert(#playersCache == 1, 'cache invalidation must not duplicate roster entries')
local previousX = drawingsByPlayer[player].Box.Position.X
player.Character.Root = {Parent = player.Character, Position = vector(30,0,0)}
now += 0.25
updateEspTracers()
assert(drawingsByPlayer[player].Box.Position.X ~= previousX)
Players.Fail = true
assert(reconcilePlayers() == false)
updateEspTracers()
assert(drawingsByPlayer[player].Box.Visible)
Players.Fail = false
player.Parent = nil
updateEspTracers()
assert(not drawingsByPlayer[player].Box.Visible)
Players.List = {LocalPlayer}
reconcilePlayers()
assert(#playersCache == 0 and drawingsByPlayer[player] == nil)
end
print('PASS: base + standalone ESP recovery, replaced roots, projection/camera failures, stale players, and bounded roster refresh')
`;
const directory = mkdtempSync(join(tmpdir(), 'fftm-esp-tests-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}
try {
  const path = join(directory, 'esp_recovery.luau');
  writeFileSync(path, test);
  run(process.argv[2] || 'luau', [path]);
  if (process.argv[3]) {
    for (const [name, text] of [['main', main], ['esp', standalone]]) {
      const path = join(directory, name + '.luau');
      writeFileSync(path, 'local print = function(...) end\nlocal warn = function(...) end\n' + text);
      run(process.argv[3], ['--null', path]);
    }
  }
} finally {
  rmSync(directory, {recursive: true, force: true});
}
