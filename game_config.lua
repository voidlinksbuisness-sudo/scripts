-- Game-specific animation timing/configuration table.
-- Loaded by fftm_main.lua.

local function getTravelTime(distance, speed)
	return distance / speed
end

local function showWarningImage()
    local viewport = workspace.CurrentCamera.ViewportSize

    local image = Drawing.new("Image")

    image.Data = game:HttpGet(
        "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/runaway.png"
    )

    local width = 900
    local height = 500

    local centerX = (viewport.X - width) / 2
    local centerY = (viewport.Y - height) / 2

    image.Size = Vector2.new(width, height)
    image.Position = Vector2.new(centerX, -height)
    image.Visible = true
    image.ZIndex = 999

    -- POP INTO CENTER
    local start = tick()
    local popTime = 0.45

    while true do
        local alpha = math.min((tick() - start) / popTime, 1)

        -- Smooth ease-out
        local eased = 1 - (1 - alpha)^3

        image.Position = Vector2.new(
            centerX,
            -height + (centerY + height) * eased
        )

        if alpha >= 1 then
            break
        end

        task.wait()
    end

    -- Stay on screen
    task.wait(2)

    -- DROP OFF THE BOTTOM
    start = tick()
    local slideTime = 0.8

    while true do
        local alpha = math.min((tick() - start) / slideTime, 1)

        -- Accelerates as it falls
        local eased = alpha * alpha

        image.Position = Vector2.new(
            centerX,
            centerY + (viewport.Y + 100 - centerY) * eased
        )

        if alpha >= 1 then
            break
        end

        task.wait()
    end

    image:Remove()
end
local GameConfig = {
    ["KarateAnims"] = {
        ["rbxassetid://136346659171696"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://137514920199894"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://72779501873271"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://127487637547915"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://96466099895892"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
    },
    ["BasicAnims"] = {
        ["rbxassetid://100661797632126"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://117315538657801"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://83771012317903"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://129031831390386"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://80331331149375"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://124808151650835"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://79996486219181"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://115207134396914"] = {
            DisplayName = "3rdM1",
        },
        ["rbxassetid://74020075116139"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://91419261625463"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://135984725924501"] = {
            DisplayName = "M2EHit"
        },
        ["rbxassetid://99774162066012"] = {
            DisplayName = "M2Success"
        },
        ["M1Time"] = 0.15,
    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://110917888708142"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://136830198456192"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://103717575086418"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://90445272780399"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://74462376752922"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.1,        
    },
    ["BoxingAnims"] = {
        ["rbxassetid://132913269853139"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://76033376851583"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://126463147281440"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://75666664304014"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://128921678079615"] = {
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
                end)
            end,
        },
    },
    ["HakariOtherAnims"] = {
        ["rbxassetid://117925051452801"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://122040023429227"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://126306184412990"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://85805632651129"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://106589382211868"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://127394334888645"] = {
            DisplayName = "M2"
        },
    },
    ["CapoeiraAnims"] = {
        ["rbxassetid://91953931348325"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://127465095270110"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://79017113400162"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://98872276178039"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://101740002500802"] = {
            DisplayName = "M2",
            ReactionTime = 0.32,
        }
    },
    ["SluggerAnims"] = {
        ["rbxassetid://78852386182257"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.24,
        },
        ["rbxassetid://89706363973188"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://127941398150401"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22
        },
        ["rbxassetid://97696355281722"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.19,
        },
        ["rbxassetid://86882821333237"] = {
            DisplayName = "M2",
            ReactionTime = 0.65,
        }
    },
    ["KureAnims"] = {
        ["rbxassetid://89598700542051"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://84100769626105"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://75725487794798"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://103586798765773"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://128246407698779"] = {
            DisplayName = "M2"
        },
        ["rbxassetid://104060526539640"] = {
            DisplayName = "M2EHit"
        }
    },
    ["AliAnims"] = {
        ["rbxassetid://103211517133243"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.12,
        },
        ["rbxassetid://88548871262625"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://104356393941647"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://109925400698635"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.11,
        },
        ["rbxassetid://92831721340116"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://81488798354194"] = {
            DisplayName = "M2Right",
            ReactionTime = 0.3,
        },
    },
    ["HakariAnims"] = {
        ["rbxassetid://123215666398014"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://100249628136368"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://101160496635774"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://76458394174684"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://78127273702521"] = {
            DisplayName = "M2",
            ReactionTime = 0.19,
        },
        ["rbxassetid://137954350192006"] = {
            DisplayName = "MomentumM2"
        },
    },
    ["WingChunAnims"] = {
        ["rbxassetid://94976161225956"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://130903067566077"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://139503477666199"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://135699957281468"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.52
        },
        ["rbxassetid://125237241325107"] = {
            DisplayName = "M2",
            ReactionTime = 0.06,
        },
        ["rbxassetid://140240091451745"] = {
            DisplayName = "M2Success"
        },
        ["rbxassetid://138270482936731"] = {
            DisplayName = "M2EHit"
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://79224782278508"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://74337052553355"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://121264916189386"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://125556631043249"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://128600830397859"] = {
            DisplayName = "M2"
        }
    },
    ["KickboxingAnims"] = {
        ["rbxassetid://127679697578124"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://111648334200984"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://109134308246065"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://123237866254734"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://119415047601579"] = {
            DisplayName = "M2"
        },
        ["rbxassetid://140240091451745"] = {
            DisplayName = "M2Success"
        },
        ["rbxassetid://138270482936731"] = {
            DisplayName = "M2EHit"
        }
    },
    ["KyokushinAnims"] = {
        ["rbxassetid://108157433609067"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://139691512657916"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://94267870513016"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://107365196082362"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://128363063231486"] = {
            DisplayName = "M2"
        }
    },
    ["CQCAnims"] = {
        ["rbxassetid://80051878176163"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://112809686330315"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://96690751054332"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://75394567475187"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://136636440521127"] = {
            DisplayName = "M2",
            PreserveHeavyLogic = true,
            ParryFunction = function(data)
                if data.RegistryData.Processed == true then return end
                data.RegistryData.Processed = true
                task.spawn(function()
                    showWarningImage()
                    task.wait(3)
					local PLAYERS = game:GetService("Players")
                    local dis = (PLAYERS.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - data.Mob.HumanoidRootPart.Position).Magnitude
                end)
            end,
        },
    },
    ["MishimaAnims"] = {
        ["rbxassetid://122564675454774"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://124288660244802"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://116344736444569"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://109354190051977"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://113531813891302"] = {
            DisplayName = "M2"
        }
    },
    ["LethweiAnims"] = {
        ["rbxassetid://126845586831338"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://111506889308405"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://93862547414782"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://81747456615347"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://98256190530845"] = {
            DisplayName = "M2"
        }
    },
    ["Debug"] = {
        ["http://www.roblox.com/asset/?id=125750702"] = {
            DisplayName = "M1",
            ReactionTime = 0.3,
        },
    },
}
return GameConfig
