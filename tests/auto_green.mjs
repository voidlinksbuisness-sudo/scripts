// Run: node tests/auto_green.mjs /path/to/luau [/path/to/luau-compile]
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');

for (const required of [
  'BASKETBALL',
  'Title = "Auto Green"',
  'Title = "Release Target"',
  '"auto_green", "Auto Green", "AutoGreen"',
  'Basketball = {',
  'basketball.ReleaseTarget',
  'BasketballShotMeterBar',
  'BasketballShotMeterAttach',
  'VisualRuntime.AutoGreen.Tick',
  'keyrelease(VisualRuntime.AutoGreen.ShootKey)',
  'Basketball release assist is isolated from MainLoop',
]) {
  if (!main.includes(required)) throw new Error(`Missing Auto Green behavior: ${required}`);
}

if (!main.includes('ShootKey = 69')) {
  throw new Error('Auto Green must release E and must never press it for the user');
}
if (main.includes('keypress(VisualRuntime.AutoGreen.ShootKey)')) {
  throw new Error('Release assist must not press the basketball shot key');
}

const runtimeStart = main.indexOf('function VisualRuntime.AutoGreen.Reset');
const runtimeEnd = main.indexOf('\nVisualRuntime.AutoParryStatus =', runtimeStart);
if (runtimeStart < 0 || runtimeEnd < 0) throw new Error('Could not extract Auto Green runtime');
const runtime = main.slice(runtimeStart, runtimeEnd);

const harness = `
VisualRuntime = {
    AutoGreen = {
        Enabled = true,
        ReleaseTarget = 0.65,
        ShootKey = 69,
        PreviousProgress = nil,
        Meter = nil,
        Needle = nil,
        LastScanAt = -1000000,
        LastReleaseAt = -1000000,
        LastErrorAt = -1000000,
        ScanInterval = 0.5,
        MinimumMovement = 0.004,
        ReleaseCooldown = 0.15,
        ShotCount = 0,
        NeedleNames = {"needle", "sweep", "fill", "indicator", "marker"},
    },
}

local releases = 0
function keyrelease(key)
    assert(key == 69, "release assist must release E")
    releases += 1
end

local function makeNode(name)
    local node = {
        Name = name,
        Parent = true,
        AbsoluteSize = { Y = 100 },
        Children = {},
    }

    function node:Add(child)
        child.Parent = self
        self.Children[child.Name] = child
        return child
    end

    function node:FindFirstChild(childName, recursive)
        local direct = self.Children[childName]
        if direct or not recursive then return direct end
        for _, child in pairs(self.Children) do
            local found = child:FindFirstChild(childName, true)
            if found then return found end
        end
        return nil
    end

    function node:GetDescendants()
        local result = {}
        local function append(parent)
            for _, child in pairs(parent.Children) do
                result[#result + 1] = child
                append(child)
            end
        end
        append(self)
        return result
    end

    return node
end

LocalPlayer = { Name = "Tester" }
workspace = makeNode("Workspace")
local players = workspace:Add(makeNode("Players"))
local player = players:Add(makeNode("Tester"))
local bar = player:Add(makeNode("BasketballShotMeterBar"))
local track = bar:Add(makeNode("Track"))
local needle = track:Add(makeNode("Needle"))
track.AbsoluteSize.Y = 100
needle.AbsoluteSize.Y = 40

${runtime}

assert(VisualRuntime.AutoGreen.FindMeter() == track, "named basketball meter must be found")
assert(VisualRuntime.AutoGreen.FindNeedle(track) == needle, "needle must be found")
assert(VisualRuntime.AutoGreen.GetProgress(track, needle) == 0.4, "meter ratio must be measured")

VisualRuntime.AutoGreen.Tick(1)
needle.AbsoluteSize.Y = 70
VisualRuntime.AutoGreen.Tick(1.1)
assert(releases == 1, "crossing upward through 65% must release once")
VisualRuntime.AutoGreen.Tick(1.2)
assert(releases == 1, "stationary progress must not release repeatedly")

needle.AbsoluteSize.Y = 80
VisualRuntime.AutoGreen.Tick(1.3)
needle.AbsoluteSize.Y = 60
VisualRuntime.AutoGreen.Tick(1.5)
assert(releases == 2, "crossing downward through the target must also work")

VisualRuntime.AutoGreen.Meter = nil
VisualRuntime.AutoGreen.Needle = nil
VisualRuntime.AutoGreen.PreviousProgress = nil
player.Children = {}
local root = player:Add(makeNode("HumanoidRootPart"))
local attach = root:Add(makeNode("BasketballShotMeterAttach"))
local billboard = attach:Add(makeNode("BasketballShotBillboard"))
local billboardRoot = billboard:Add(makeNode("Root"))
local legacyMeter = billboardRoot:Add(makeNode("Meter"))
assert(VisualRuntime.AutoGreen.FindMeter() == legacyMeter, "legacy billboard meter must remain supported")

VisualRuntime.AutoGreen.Enabled = false
VisualRuntime.AutoGreen.Tick(2)
assert(releases == 2, "disabled Auto Green must do no input work")
print("PASS: Auto Green meter detection, bidirectional crossing, E release, and isolation")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-auto-green-'));
function run(executable, args) {
  const result = spawnSync(executable, args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}

try {
  const harnessPath = join(directory, 'auto_green.luau');
  writeFileSync(harnessPath, harness);
  run(process.argv[2] || 'luau', [harnessPath]);

  if (process.argv[3]) {
    const compilePath = join(directory, 'loader_prefixed.luau');
    writeFileSync(
      compilePath,
      'local print = function(...) end\nlocal warn = function(...) end\n' + main,
    );
    run(process.argv[3], ['--null', compilePath]);
  }
} finally {
  rmSync(directory, { recursive: true, force: true });
}
