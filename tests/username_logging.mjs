// Run: node tests/username_logging.mjs /path/to/luau [/path/to/luau-compile]
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const main = readFileSync(new URL('../fftm_main.lua', import.meta.url), 'utf8');
const functionStart = main.indexOf('function FFTMSendHeartbeat()');
const functionEnd = main.indexOf('\nfunction FFTMStartBackgroundPolling()', functionStart);
if (functionStart < 0 || functionEnd < 0) throw new Error('Could not extract heartbeat function');
const heartbeatFunction = main.slice(functionStart, functionEnd);

for (const required of [
  'FFTM_USERNAME_LOG_CONFIRMED = false',
  'username = LocalPlayer.Name',
  'display_name = LocalPlayer.DisplayName',
  'data.username_logged == true',
  '[FFTM] Username logging active for ',
]) {
  if (!main.includes(required)) throw new Error(`Missing username logging behavior: ${required}`);
}

const harness = `
local capturedQuery
local response = { ok = true, username_logged = true, shutdown = false }
local messages = {}
local shutdowns = 0

print = function(message)
    table.insert(messages, message)
end
FFTMGetJson = function(path, query)
    assert(path == "/heartbeat")
    capturedQuery = query
    return response
end
FFTMShutdown = function()
    shutdowns += 1
end

FFTM_RUNNING = true
FFTM_SESSION_ID = "session-1"
FFTM_USERNAME_LOG_CONFIRMED = false
FFTM_MAIN_VERSION = "test"
FFTM_SERVER_PLACE_ID = "456"
FFTM_SERVER_JOB_ID = "job-1"
FFTM_SERVER_KEY = "456:job-1"
LocalPlayer = {
    UserId = 123,
    Name = "Builderman",
    DisplayName = "Builder Man",
}

${heartbeatFunction}

FFTMSendHeartbeat()
assert(capturedQuery.username == "Builderman")
assert(capturedQuery.display_name == "Builder Man")
assert(FFTM_USERNAME_LOG_CONFIRMED == true)
assert(#messages == 1)
assert(string.find(messages[1], "Builderman", 1, true))

FFTMSendHeartbeat()
assert(#messages == 1, "confirmation must print only once")

response = { ok = true, shutdown = false }
FFTM_USERNAME_LOG_CONFIRMED = false
FFTMSendHeartbeat()
assert(FFTM_USERNAME_LOG_CONFIRMED == false, "old Worker responses must remain compatible")
assert(#messages == 1)

response = { ok = true, username_logged = true, shutdown = true }
FFTMSendHeartbeat()
assert(shutdowns == 1, "shutdown handling must remain intact")
print("PASS: client sends identity and confirms updated Worker logging once")
`;

const directory = mkdtempSync(join(tmpdir(), 'fftm-username-logging-'));
function run(executable, args) {
  const result = spawnSync(executable, args, {stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${executable} failed (${result.status})`);
}

try {
  const harnessPath = join(directory, 'username_logging.luau');
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
