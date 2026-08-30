// Run: node tests/nonparry_performance.mjs /path/to/luau
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const source = process.env.FFTM_TEST_REF
  ? (() => {
      const result = spawnSync('git', ['show', `${process.env.FFTM_TEST_REF}:fftm_main.lua`], {encoding: 'utf8'});
      if (result.status !== 0) throw new Error(result.stderr);
      return result.stdout;
    })()
  : readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
function extract(start, end) {
  const first = source.indexOf(start), last = source.indexOf(end, first + start.length);
  if (first < 0 || last < 0) throw new Error(`Missing source boundary: ${start}`);
  return source.slice(first, last);
}
const mainLoop = extract('function MainLoop()', '\n-- Register/log this session');
if (mainLoop.includes('FFTMSendHeartbeat') || mainLoop.includes('FFTMRefreshAdminDropdown')) {
  throw new Error('A synchronous network call remains inside MainLoop');
}

const test = `
local current, waits, heartbeats, adminRefreshes = 0, 0, 0, 0
local os = {clock = function() return current end}
local task = {spawn = function(callback) callback() end}
local FFTM_RUNNING = true
local FFTM_BACKGROUND_POLLING_STARTED = false
local FFTM_LAST_HEARTBEAT_AT = -1000
local FFTM_LAST_ADMIN_REFRESH_AT = 0
local FFTM_ADMIN_KEY = 'test-admin'
local function FFTMSendHeartbeat() heartbeats += 1 end
local function FFTMRefreshAdminDropdown() adminRefreshes += 1 end
local function wait(seconds)
    assert(seconds == 10)
    waits += 1
    current += seconds
    if waits == 1 then
        FFTMStartBackgroundPolling()
        assert(FFTM_BACKGROUND_POLLING_STARTED, 'poller must reject duplicate startup')
    elseif waits == 4 then
        FFTM_RUNNING = false
    end
end
${extract('function FFTMStartBackgroundPolling()', '\nfunction FFTMFetchAdminSessions')}
FFTMStartBackgroundPolling()
assert(waits == 4)
assert(heartbeats == 3, 'expected one heartbeat after each completed 10-second yield')
assert(adminRefreshes == 1, 'admin refresh should remain on its 30-second cadence')
assert(FFTM_LAST_HEARTBEAT_AT == 30)
assert(not FFTM_BACKGROUND_POLLING_STARTED)
print('PASS: synchronous HTTP polling yields first, stays off MainLoop, preserves cadence, and starts once')
`;
const directory = mkdtempSync(join(tmpdir(), 'fftm-performance-tests-'));
try {
  const path = join(directory, 'background_polling.luau');
  writeFileSync(path, test);
  const result = spawnSync(process.argv[2] || 'luau', [path], {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`Luau test failed (${result.status})`);
} finally {
  rmSync(directory, {recursive: true, force: true});
}
