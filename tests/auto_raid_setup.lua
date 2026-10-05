-- Run from the repository root: texlua tests/auto_raid_setup.lua
local sourceFile=assert(io.open(arg[1] or "blox_fruits.lua","r"))
local source=sourceFile:read("*a")
sourceFile:close()
local detection=assert(source:match("(function S%.findActiveRaidContainer%(%)\n.-\nend)"))
local setup=assert(source:match("%-%- Raid setup uses.-\ndo\n(.-)\nend\n\nwhile true do task%.wait"))

local function object(class,name,children)
    local obj={ClassName=class,Name=name,children=children or {},Parent=true,Health=100}
    function obj:FindFirstChild(childName) return self.children[childName] end
    function obj:FindFirstChildOfClass(childClass)
        for _,child in pairs(self.children) do
            if child.ClassName==childClass then return child end
        end
    end
    return obj
end

local function scenario(options)
    options=options or {}
    local time=0
    local calls={}
    local notices={}
    local clicks=0
    local mouseClicks=0
    local storedLoads=0
    local raidMap=object("Model","RaidMap")
    local backpack=object("Backpack","Backpack")
    local detector=object("ClickDetector","ClickDetector")
    detector.MaxActivationDistance=32
    local main=object("Part","Main",{ClickDetector=detector})
    main.Position={X=20,Y=10,Z=30}
    local button=object("Model","Button",{Main=main})
    local summon=object("Model","RaidSummon2",{Button=button})
    local castle=object("Model","Boat Castle",{RaidSummon2=summon})
    local map=object("Model","Map",{RaidMap=raidMap,["Boat Castle"]=castle})
    if options.noButton then castle.children.RaidSummon2=nil end
    local workspace=object("Workspace","Workspace",{Map=map})
    local hrp=object("Part","HumanoidRootPart")
    hrp.Position={X=0,Y=0,Z=0}
    local humanoid=object("Humanoid","Humanoid")
    local character=object("Model","Character",{HumanoidRootPart=hrp,Humanoid=humanoid})
    local player=object("Player","Player",{Backpack=backpack})
    player.Character=character
    local function addChip(container)
        container.children["Special Microchip"]=object("Tool","Special Microchip")
    end
    if options.chip then addChip(options.equipped and character or backpack) end
    if options.active then raidMap.children.RaidIsland1=object("Model","RaidIsland1") end
    local state={autoRaid=true,raidUseStoredSpin=not options.noSpin,
        raidSetupGeneration=0,RAID_TWEEN_SPEED=320}
    if options.blocked then state.autoBossFarm=true end
    local worker
    local env={
        S=state,game={Workspace=workspace},LocalPlayer=player,
        ipairs=ipairs,pairs=pairs,type=type,tonumber=tonumber,tostring=tostring,
        pcall=pcall,math=math,os={clock=function() return time end},
        Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end},
        notify=function(message) notices[#notices+1]=message end,warn=function() end,
        tweenTo=function(root,target,speed,ready)
            if options.cancelTravel then state.autoRaid=false end
            if ready() then root.Position=target end
        end,
        task={
            wait=function(seconds) coroutine.yield(seconds or 0.01) end,
            spawn=function(callback) worker=coroutine.create(callback) end
        }
    }
    env.invokeEnhancedComm=function(command,action,raidType)
        calls[#calls+1]={command,action,raidType}
        if options.cancelLoad and command=="LoadFruit" then state.autoRaid=false end
        if options.remoteError then return false,nil,"Unsupported remote" end
        if command=="LoadFruit" then
            storedLoads=storedLoads+1
            if options.chipOnLoad then addChip(backpack)
            elseif not options.noFruit then
                backpack.children["Spin Fruit"]=object("Tool","Spin Fruit")
            end
        elseif command=="RaidsNpc" and action=="Check" and options.chipOnCheck then
            addChip(backpack)
        elseif command=="RaidsNpc" and action=="Select" and not options.purchaseFails then
            addChip(backpack)
            backpack.children["Spin Fruit"]=nil
        end
        return true,nil,nil
    end
    local function startRaid()
        clicks=clicks+1
        backpack.children["Special Microchip"]=nil
        character.children["Special Microchip"]=nil
        raidMap.children.RaidIsland1=object("Model","RaidIsland1")
    end
    if not options.mouse then env.fireclickdetector=startRaid end
    env.isrbxactive=function() return not options.unfocused end
    env.WorldToScreen=function() return {X=100,Y=100},not options.offscreen end
    env.setrobloxinput=function() end
    env.mousemoveabs=function() end
    env.mouse1click=function() mouseClicks=mouseClicks+1; startRaid() end
    assert(load(detection,"raid detection","t",env))()
    assert(load(setup,"raid setup","t",env))()
    local finished=false
    while time<90 do
        if options.finishRaid and not finished and clicks==1 and time>=20 then
            raidMap.children.RaidIsland1=nil
            finished=true
        end
        local ok,delay=coroutine.resume(worker)
        assert(ok,delay)
        assert(state.raidSetupActive~=nil or #calls==0)
        time=time+(delay or 0.01)
    end
    assert(not state.raidSetupActive,"Setup lock must be released")
    return {calls=calls,clicks=clicks,mouseClicks=mouseClicks,loads=storedLoads,notices=notices}
end

local function count(result,command,action)
    local n=0
    for _,call in ipairs(result.calls) do
        if call[1]==command and (not action or call[2]==action) then n=n+1 end
    end
    return n
end

local r=scenario()
assert(r.loads==1 and count(r,"RaidsNpc","Check")==1 and count(r,"RaidsNpc","Select")==1)
assert(r.calls[3][3]=="Flame" and r.clicks==1)
assert(scenario({chip=true}).loads==0)
assert(#scenario({chip=true,equipped=true}).calls==0)
assert(#scenario({active=true}).calls==0)
assert(#scenario({blocked=true}).calls==0)
assert(#scenario({noButton=true}).calls==0)
assert(scenario({cancelLoad=true}).clicks==0)
assert(count(scenario({cancelLoad=true}),"RaidsNpc")==0)
assert(scenario({cancelTravel=true}).clicks==0)
assert(count(scenario({chipOnLoad=true}),"RaidsNpc")==0)
assert(count(scenario({chipOnCheck=true,noSpin=true}),"RaidsNpc","Select")==0)
assert(scenario({finishRaid=true}).clicks==2)
assert(scenario({noSpin=true}).loads==0)
r=scenario({purchaseFails=true})
assert(count(r,"RaidsNpc","Select")<=3 and r.loads==1 and r.clicks==0)
r=scenario({remoteError=true})
assert(#r.calls<=3 and r.clicks==0 and #r.notices>0)
assert(scenario({chip=true,mouse=true}).mouseClicks==1)
assert(scenario({chip=true,mouse=true,unfocused=true}).mouseClicks==0)
assert(scenario({chip=true,mouse=true,offscreen=true}).mouseClicks==0)
print("PASS: raid setup purchase, chip reuse, empty map, cancellation, priorities, retry limits, and mouse fallback")
