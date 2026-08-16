-- Dueling Grounds animation configuration
-- NO learning/database is used.
--
-- Each discovered attack goes inside its weapon table.
--
-- Standard single parry:
-- ["rbxassetid://123"] = {
--     DisplayName = "1stM1",
--     ReactionTime = 0.15,
-- },
--
-- Double-hit / double-parry attack:
-- ["rbxassetid://456"] = {
--     DisplayName = "DoubleHit",
--     ReactionTime = 0.18,
--     ParryCount = 2,
--     ParryGap = 0.12,   -- seconds AFTER first RMB release before second RMB
--     ParryHold = 0.05,  -- how long each RMB parry is held
-- },
--
-- Heavy that should dodge with Q instead:
-- ["rbxassetid://789"] = {
--     DisplayName = "M2",
--     ReactionTime = 0.30,
--     Heavy = true,
-- },
--
-- Fields:
--   DisplayName  = label shown in logs/UI
--   ReactionTime = seconds after animation start before defense
--   ParryCount   = 1 normally, 2 for double-hit moves (or more if needed)
--   ParryGap     = delay between RMB parries
--   ParryHold    = duration of each RMB hold
--   Heavy        = true to use Q dodge logic
--   Jump         = true to use jump defense logic

local GameConfig = {
    ["Katana"] = {
    },

    ["DualDaggers"] = {
        -- Double-hit moves can be configured like:
        -- ["rbxassetid://ANIMATION_ID"] = {
        --     DisplayName = "DoubleHit",
        --     ReactionTime = 0.15,
        --     ParryCount = 2,
        --     ParryGap = 0.12,
        --     ParryHold = 0.05,
        -- },
    },

    ["Naginata"] = {
    },

    ["Gauntlets"] = {
        -- Put multi-punch/double-hit animations here with ParryCount = 2.
    },

    ["Kusarigama"] = {
        -- Put multi-hit chain animations here with ParryCount = 2 when needed.
    },

    ["Warhammer"] = {
    },

    ["CurvedSwords"] = {
        -- Put double-slash animations here with ParryCount = 2 when needed.
    },

    ["BoStaff"] = {
        -- Put multi-hit animations here with ParryCount = 2 when needed.
    },
}

return GameConfig
