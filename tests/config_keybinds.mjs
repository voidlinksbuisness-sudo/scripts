// Run: node tests/config_keybinds.mjs /path/to/luau [/path/to/luau-compile] [/path/to/pinned-INS.lua]
// Executes the real config loader and UI adapter with file/UI mocks, not Roblox.
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const source = process.env.FFTM_TEST_REF
  ? (() => {
      const result = spawnSync('git', ['show', `${process.env.FFTM_TEST_REF}:fftm_main.lua`], { encoding: 'utf8' });
      if (result.status !== 0) throw new Error(result.stderr);
      return result.stdout;
    })()
  : readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
function extract(start, end) {
  return extractFrom(source, start, end);
}
function extractFrom(text, start, end) {
  const first = text.indexOf(start);
  const last = text.indexOf(end, first + start.length);
  if (first < 0 || last < 0) throw new Error(`Missing source boundary: ${start}`);
  return text.slice(first, last);
}
const nativeApplyRow = process.argv[4]
  ? extractFrom(readFileSync(process.argv[4], 'utf8'), '  local function ApplyRow(', '\n\n  local SettingsMirror')
  : `local function ApplyRow(row, saved, bind)
       if saved ~= row.Value then row.Value = saved; row.Callback(saved) end
       if bind and row.Bind then row.Bind.Value, row.Bind.Mode = bind[1], bind[2] end
     end`;

const test = `
local report = print
local function print() end
local KeybindSpecs = {}
local KeybindSpecsById = {}
local KeybindControls = {}
local Library = { Themes = {}, Raw = {} }
${nativeApplyRow}
function Library.Raw:LoadConfig(profile)
    for id, value in pairs(profile.flags or {}) do
        local row = KeybindControls[id]
        if row then ApplyRow(row, value, (profile.keybinds or {})[id]) end
    end
    if profile.Throw then error('simulated native load failure') end
    return self
end
local actions = 0
local tab = { Section = {} }
function tab.Section:Keybind(_, default, callback)
    return { Kind = 'Keybind', Value = string.lower(default), Input = callback, Callback = callback, Active = false }
end
${extract('        function tab:AddKeybind(control)', '\n        function tab:AddSection')}
${extract('local function SetKeybind(', '\nlocal function AddKeybindControl(')}
${extract('local function CaptureKeybindConfig()', '\nfunction SetupPresetConfigUI()')}

for id, initial in pairs({menu_toggle = 'M', cycle_target = 'None', esp = 'Q', animation_id_esp = 'None'}) do
    local spec = { Id = id }
    SetKeybind(spec, initial)
    table.insert(KeybindSpecs, spec)
    KeybindSpecsById[id] = spec
    KeybindControls[id] = tab:AddKeybind({
        Title = id, Default = spec.KeyName, Mode = 'Toggle',
        Callback = function() actions += 1 end,
        ChangedCallback = function(value) SetKeybind(spec, value) end,
    })
end

-- Run the real Load button callback through the actual profile setup function.
local disk = { Version = 2, Configs = {} }
local buttons = {}
local lastNotice
local ConfigTab = { Appearance = {}, Utilities = {} }
local game = { GetService = function()
    return { JSONDecode = function() return disk end }
end }
local function writefile() error('Loading must not write profiles') end
local function readfile() return 'mock JSON' end
local function isfile(path) return path == 'FFTM/configs.json' end
local function Notify(_, message) lastNotice = message end
local function SafeAddDropdown() end
local function SafeAddButton(_, control) buttons[control.Title] = control.Callback end
local function ApplyWhitelist() end
${extract('function SetupPresetConfigUI()', '\nSetupPresetConfigUI()')}
SetupPresetConfigUI()

local function load(config)
    disk.Configs['Config 1'] = config
    buttons.Load()
end
local function expect(id, expected)
    local actual = KeybindSpecsById[id].KeyName
    assert(actual == expected, id .. ' runtime: expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    assert(KeybindControls[id]:GetValue() == (expected and string.lower(expected) or 'none'), id .. ' UI out of sync')
end
local function reset()
    KeybindControls.menu_toggle:SetValue('P')
    KeybindControls.cycle_target:SetValue('X')
    KeybindControls.esp:SetValue('Q')
end
local function preserved()
    expect('menu_toggle', 'p')
    expect('cycle_target', 'x')
end

expect('menu_toggle', 'M')
expect('cycle_target', nil) -- No new targeting default.
reset()
load(nil)
assert(lastNotice == 'Config 1 is empty.')
preserved()
load({})
assert(lastNotice == 'Config 1 is empty.')
preserved()
for _, config in ipairs({{Keybinds = {}}, {Keybinds = false}, {Keybinds = 'bad'}, {Visuals = {}}}) do
    load(config)
    preserved()
end
for _, value in ipairs({'', ' ', '\\t\\n', 'None', 'none', 'NONE', ' NoNe ', false, 0, {}}) do
    load({Keybinds = {menu_toggle = value, cycle_target = value}})
    preserved()
    expect('esp', 'q')
end

load({Keybinds = {menu_toggle = ' M ', cycle_target = 'E'}})
expect('menu_toggle', 'm')
expect('cycle_target', 'e')
assert(CaptureKeybindConfig().cycle_target == 'e')
load({Keybinds = {menu_toggle = 'None', cycle_target = 'C', esp = 'None'}})
expect('menu_toggle', 'm')
expect('cycle_target', 'c')
expect('esp', 'q')
assert(CaptureKeybindConfig().esp == 'q')
for _, value in ipairs({'', ' ', 'None', 'none', 'NONE'}) do
    KeybindControls.esp:SetValue('Q')
    load({Keybinds = {esp = value}})
    expect('esp', 'q') -- Empty profiles now preserve every shortcut.
end
load({Keybinds = {esp = 'V'}})
expect('menu_toggle', 'm')
expect('cycle_target', 'c')
expect('esp', 'v')
load({Keybinds = {auto_parry_esp = 'H', unknown = 'J'}})
expect('animation_id_esp', 'h') -- Preserve legacy ID migration.
for _, id in ipairs({'menu_toggle', 'cycle_target'}) do
    KeybindControls[id].Input('Delete')
    expect(id, nil) -- Intentional manual clearing still works.
end
load({Keybinds = {menu_toggle = 'None', cycle_target = 'none'}})
expect('menu_toggle', nil)
expect('cycle_target', nil)
load({Keybinds = {menu_toggle = 'M', cycle_target = 'X'}})
expect('menu_toggle', 'm')
expect('cycle_target', 'x')
local saved = CaptureKeybindConfig()
reset()
load({Keybinds = saved})
expect('menu_toggle', 'm')
expect('cycle_target', 'x')
expect('esp', 'v')
-- Native INS applies flags, callbacks, and attached binds in that order.
reset()
Library.Raw:LoadConfig({})
preserved()
for _, value in ipairs({'', ' ', 'none', 'None', 'NONE', false}) do
    Library.Raw:LoadConfig({
        flags = {menu_toggle = value, cycle_target = value, esp = value},
        keybinds = {menu_toggle = {value, 'Hold'}, cycle_target = {value, 'Hold'}, esp = {value, 'Hold'}},
    })
    preserved()
    expect('esp', 'q')
end
Library.Raw:LoadConfig({flags = {menu_toggle = 'L'}, keybinds = {menu_toggle = {'K', 'Toggle'}}})
expect('menu_toggle', 'k')
expect('cycle_target', 'x')
assert(CaptureKeybindConfig().menu_toggle == 'k')
local ok = pcall(Library.Raw.LoadConfig, Library.Raw, {flags = {menu_toggle = 'Z'}, Throw = true})
assert(not ok)
assert(not Library.LoadingNativeConfig, 'Native load guard must clear after errors')
expect('menu_toggle', 'k')
KeybindControls.cycle_target.Value = 'j'
assert(CaptureKeybindConfig().cycle_target == 'j', 'Save must read the live INS row')
KeybindControls.menu_toggle.Input('Delete')
expect('menu_toggle', nil)
assert(actions == 0, 'Loading/rebinding must never trigger an action')
report('PASS: both config paths, all protected binds, UI sync, saved keys, load failures, manual clearing, and legacy IDs')
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-keybind-tests-'));
function run(executable, args) {
  const result = spawnSync(executable, args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}
try {
  const testPath = join(directory, 'config_keybinds.luau');
  writeFileSync(testPath, test);
  run(process.argv[2] || 'luau', [testPath]);
  if (process.argv[3]) {
    const compilePath = join(directory, 'loader_prefixed.luau');
    writeFileSync(compilePath, 'local print = function(...) end\nlocal warn = function(...) end\n' + source);
    run(process.argv[3], ['--null', compilePath]);
    console.log('PASS: full loader-prefixed Luau compilation');
  }
} finally {
  rmSync(directory, { recursive: true, force: true });
}
