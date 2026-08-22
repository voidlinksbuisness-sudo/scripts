-- Game-specific animation timing/configuration table.
-- Loaded by fftm_main.lua.

local GameConfig = {
    ["KarateAnims"] = {
        ["rbxassetid://137837926745158"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://100981571094705"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://130865087635587"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://86495068205420"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://120393553812903"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
    },
    ["AliAnims"] = {
        ["rbxassetid://137247073345979"] = {
            DisplayName = "1stM1",
            ["ReactionTime"] = 0.12,
        },
        ["rbxassetid://102632933427597"] = {
            DisplayName = "2ndM1",
            ["ReactionTime"] = 0.17,
        },
        ["rbxassetid://119814294807778"] = {
            DisplayName = "3rdM1",
            ["ReactionTime"] = 0.21,
        },
        ["rbxassetid://74315946602284"] = {
            DisplayName = "4thM1",
            ["ReactionTime"] = 0.11,
        },
        ["rbxassetid://128315752013166"] = {
            DisplayName = "M2",
            ReactionTime = 0.27,
        },
        ["rbxassetid://70642098724811"] = {
            DisplayName = "M2Right",
            ReactionTime = 0.27,
        },
    },
    ["BasicAnims"] = {
        ["rbxassetid://83491849294956"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://89420531853362"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://83730275893449"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://106980660082799"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://78888626472394"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://91485623489753"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://73748315742870"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://82903450925391"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://119685134442395"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://107464726433388"] = {
            DisplayName = "3rdM1",
        },
        ["M1Time"] = 0.15,

    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://137034747040618"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://74960202100098"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://104515319350296"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://139911027872047"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
            
        },
        ["rbxassetid://96726284968458"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.1,        
    },
    ["BoxingAnims"] = {
        ["rbxassetid://137980914350618"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.125,
        },
        ["rbxassetid://100408082509740"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.106,
        },
        ["rbxassetid://94803478352691"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.13,
            
        },
        ["rbxassetid://78695517680318"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://132022052139564"] = {
            DisplayName = "M2",
            ParryFunction = function(data)
                if data.RegistryData.Processed == true then return end 
                
                data.RegistryData.Processed = true
                task.spawn(function()
                    local random = math.random(1,10)

                    task.wait(.4)
                    BlockStart(os.clock(), 0.5)
                    task.wait(.3)
                    Dodge()
                --    task.wait(.33)
                --    Dodge()

                   --[[ if random < 5 then  
                        print("Boxing parry 1")
                        task.wait(.3)

                        BlockStart(os.clock())
                    else
                        print("Boxing parry 2")
                        task.wait(.3)
                        Dodge()
                        task.wait(.35)
                        BlockStart(os.clock(), 0.6)
                    end]]
                  
                end)
            end,
        },
    },
    ["HakariAnims"] = {
        ["rbxassetid://102961997518914"] = {
            DisplayName = "MomentumM2",
            ReactionTime = 0.25,
        },
        ["rbxassetid://92865171012109"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://103026596903060"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://86626533783115"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://103100834246116"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://103359839046574"] = {
            DisplayName = "M2",
            ReactionTime = 0.1,
        },
    },
    ["CapoeiraAnims"] = {
        ["rbxassetid://125976167173936"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://134945199381140"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://117877243065533"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://106965238908791"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://131071815103338"] = {
            DisplayName = "Whirlwind",
            ReactionTime = 0.32,
        }
    },
    ["SluggerAnims"] = {
        ["rbxassetid://134829666925953"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.24,
        },
        ["rbxassetid://104867156139010"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://112759168172605"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22
        },
        ["rbxassetid://114647502301740"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.19,
        },
        ["rbxassetid://118943955490014"] = {
            DisplayName = "M2",
            ReactionTime = 0.65,
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://116642061934550"] = { --130748810826267
            DisplayName = "1stM1",
            ReactionTime = 0.2,
        },
        ["rbxassetid://115234849770695"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.18,
        },
        ["rbxassetid://85554794950365"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.05,
        },
        ["rbxassetid://73777821288331"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.05,
        },
        ["rbxassetid://99309341097380"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        }
    },
    ["KureAnims"] = {
        ["rbxassetid://71676634048602"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://102407060635393"] = {
            DisplayName = "Ook",
            ["ReactionTime"] = 0.1,
        },
        ["rbxassetid://82904229252991"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://103732110215321"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://103964436023727"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
        },
    },
    ["WingChun"] = {
        ["rbxassetid://81810173569294"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.49
        },
        ["rbxassetid://82196924299426"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.06,
        },
        ["rbxassetid://71178147313608"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.13
        },
        ["rbxassetid://117898175201201"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.13
        },
        ["rbxassetid://121315597867666"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.13
        },
    },
    ["HakariOtherAnims"] = {
        ["rbxassetid://126612786608030"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://113719263885794"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://136305578634960"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://89039586375625"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://101619248052969"] = {
            DisplayName = "M2"
        },
    },
    ["KickBoxing"] = {
        ["rbxassetid://97063158605646"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.06,
        },
        ["rbxassetid://98742118383189"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.13
        },
        ["rbxassetid://110253681998213"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.13
        },
        ["rbxassetid://101589705199990"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.25
        },
        ["rbxassetid://117387938117515"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.25
        },
    },
    ["Debug"] = {
        ["http://www.roblox.com/asset/?id=125750702"] = {
            DisplayName = "M1",
            ReactionTime = 0.3,
        },
    },
}

return GameConfig
