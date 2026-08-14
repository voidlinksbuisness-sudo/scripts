-- FFTM tiny loader
-- Change this one URL after uploading the split files to your GitHub repo.
local BASE_URL = "https://raw.githubusercontent.com/YOUR_GITHUB_NAME/YOUR_REPO/main/"

getgenv().FFTM_BASE_URL = BASE_URL

local function Load(fileName)
    local source = game:HttpGet(BASE_URL .. fileName)
    local chunk, err = loadstring(source)

    if not chunk then
        error("[FFTM Loader] Compile error in " .. fileName .. ": " .. tostring(err))
    end

    return chunk()
end

Load("fftm_main.lua")
