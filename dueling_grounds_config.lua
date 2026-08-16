-- Dueling Grounds animation configuration
-- Add animation IDs discovered by the logger into the matching weapon table.
--
-- Supported entry fields:
--   DisplayName = "1stM1" / "2ndM1" / "M2" / etc.
--   ReactionTime = seconds after animation start to press F
--   Heavy = true  -> uses the existing dodge logic (Q) instead of parry
--   Jump = true   -> uses the existing jump-defense logic
--
-- Example:
-- ["rbxassetid://123456789"] = {
--     DisplayName = "1stM1",
--     ReactionTime = 0.15,
-- },

local GameConfig = {
    ["Katana"] = {
    },

    ["DualDaggers"] = {
    },

    ["Naginata"] = {
    },

    ["Gauntlets"] = {
    },

    ["Kusarigama"] = {
    },

    ["Warhammer"] = {
    },

    ["CurvedSwords"] = {
    },

    ["BoStaff"] = {
    },
}

return GameConfig
