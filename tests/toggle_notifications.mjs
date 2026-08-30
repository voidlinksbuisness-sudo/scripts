// Run: node tests/toggle_notifications.mjs /path/to/luau [/path/to/luau-compile]
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const source = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
function extract(start, end) {
  const first = source.indexOf(start), last = source.indexOf(end, first + start.length);
  if (first < 0 || last < 0) throw new Error(`Missing source boundary: ${start}`);
  return source.slice(first, last);
}
const test = `
local notes = {}
local Library = {Raw = {Notify = function(_, title, content, duration, kind)
    notes[#notes + 1] = {Title=title, Content=content, Duration=duration, Kind=kind}
end}}
${extract('function Library:Notify(config)', '\nfunction Library:Minimize()')}
function Library:AdaptRow(row)
    row.SetValue, row.SetState, row.GetValue = row.Set, row.Set, row.Get
    return row
end
local tab = {Section = {}}
function tab.Section:Toggle(_, default, callback)
    local row = {Value = default, Callback = callback}
    function row:Set(value) self.Value = value; self.Callback(value); return self end
    function row:Get() return self.Value end
    return row
end
${extract('        function tab:AddToggle(control)', '\n        function tab:AddSlider(control)')}

local esp = false
local row = tab:AddToggle({Title='ESP', Default=false, Callback=function(value) esp=value end})
row:Set(true)
assert(esp and #notes == 1)
assert(notes[1].Title == 'Feature changed' and notes[1].Content == 'ESP is enabled.')
assert(notes[1].Kind == 'success' and notes[1].Duration == 2.5)
row:Set(false)
assert(not esp and #notes == 2 and notes[2].Content == 'ESP is disabled.' and notes[2].Kind == 'warning')

local UIToggles = {ESP = row}
${extract('local function SyncUIControl(control, value)', '\nlocal function RegisterActionKeybind(')}
${extract('    local function ApplyToggleControl(toggleName, value, setter)', '\n    local function ApplyConfig(config)')}
ApplyToggleControl('ESP', true, function(value) esp=value end)
assert(esp and row:Get() and #notes == 2, 'FFTM config loads must not emit toggle toasts')
Library.LoadingNativeConfig = true
row:Set(false)
Library.LoadingNativeConfig = false
assert(not esp and #notes == 2, 'native INS config loads must not emit toggle toasts')

local KeybindsTab = {Combat={}, Targeting={}, Parry={}, Visuals={}}
local KeybindControls = {}
local captured
local function SafeControl(_, _, config) captured = config; return {GetValue=function() return 'none' end} end
local function SetKeybind() end
${extract('local function AddKeybindControl(spec)', '\nfor _, spec in ipairs(KeybindSpecs)')}

local spec = {Id='esp', Title='ESP', ToggleName='ESP', Get=function() return esp end, Set=function(value) esp=value end}
AddKeybindControl(spec)
captured.Callback()
assert(esp and row:Get() and #notes == 3, 'keybind must use the visible toggle notification path once')
assert(notes[3].Content == 'ESP is enabled.')

local missing = false
spec = {Id='missing_feature', Title='Missing Feature', ToggleName='Missing', Get=function() return missing end, Set=function(value) missing=value end}
AddKeybindControl(spec)
captured.Callback()
assert(missing and #notes == 4 and notes[4].Content == 'Missing Feature is enabled.', 'missing UI controls need a notification fallback')

local actions = 0
spec = {Id='menu_toggle', Title='Open / Close Menu', Action=function() actions += 1 end}
AddKeybindControl(spec)
captured.Callback()
assert(actions == 1 and #notes == 4, 'action keybinds must not claim enabled/disabled state')
print('PASS: click/keybind toasts, enabled/disabled text, tint, deduplication, fallback, and config suppression')
`;
const directory = mkdtempSync(join(tmpdir(), 'fftm-toggle-notifications-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}
try {
  const testPath = join(directory, 'toggle_notifications.luau');
  writeFileSync(testPath, test);
  run(process.argv[2] || 'luau', [testPath]);
  if (process.argv[3]) {
    const compilePath = join(directory, 'loader_prefixed.luau');
    writeFileSync(compilePath, 'local print = function(...) end\nlocal warn = function(...) end\n' + source);
    run(process.argv[3], ['--null', compilePath]);
  }
} finally {
  rmSync(directory, {recursive: true, force: true});
}
