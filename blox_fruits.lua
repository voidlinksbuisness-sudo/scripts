Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat wait(0.1); LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local function notify(...) end

S = {

    autoFarming     = false,
    handledChests   = {},
    fruitEsp        = false,
    chestEsp        = false,
    berryEsp        = false,
    boatEsp         = false,
    flowerEsp       = false,
    chamEsp         = false,
    autoFruits      = false,
    fruitPriorityActive = false,
    autoDinoBone    = false,
    autoFarmNearest = false,
    autoNpcFarm     = false,
    autoFarmLevel   = false,
    autoFish        = false,
    autoRepair      = false,
    dungeonEnabled  = false,
    dungeonAutoDoor = true,
    dungeonDestroyObj = true,
    dungeonUseMoves = true,
    dungeonLocalRadius = 1000,
    sanguineZBoost  = false,
    dragonTalonZBoost = false,
    yamaZBoost      = false,
    tushitaXBoost   = false,
    foxLampXBoost   = false,
    soulGuitarM1Boost = false,
    diamondM1Boost = false,
    flameFBoost     = false,
    rToX            = false,
    rToXThenZ       = false,
    bigHitbox       = false,
    flameRToC       = false,
    pullEnemies     = false,
    autoKen         = false,
    autoHaki        = false,
    freezePos       = false,
    freezePosition  = nil,
    freezeEnemies   = false,
    frozenEnemies   = {},
    teleportEmber   = false,
    tweenEmber      = false,
    teleportKitsune = false,
    buddhaPull      = false,
    autoRaid        = false,
    autoMastery     = false,
    customPull      = false,
    voidPull        = false,
    skyPull         = false,
    boatFlyEnabled  = false,
    boatTweening    = false,
    autoBoatSeat    = false,
    selectedBoatSeat = nil,
    selectedBoatSeatLabel = nil,
    remoteMode      = false,
    weaponSlot      = 1,
    selectedBoss    = "The Gorilla King",
    autoBossFarm    = false,
    selectedMaterial = "Leather + Scrap Metal",
    autoMaterialFarm = false,
    statAmount      = 10,
    autoStatMelee   = false,
    autoStatDefense = false,
    autoStatSword   = false,
    autoStatGun     = false,
    autoStatFruit   = false,
    selectedSeaEvent = "Shark",
    autoSeaEvent    = false,
    mirageEsp       = false,
    mirageEspLabel  = nil,
    autoMirageTween = false,
    autoMirageGear  = false,
    autoRaceAbility = false,
    customPullX    = 0,
    customPullY    = -10,
    customPullZ    = 0,
    boatFlySpeed   = 5,
    FARM_SPEED     = 320,
    CHEST_SPEED    = 320,
    FRUIT_SPEED    = 320,
    NPC_TWEEN_SPEED = 320,
    RAID_TWEEN_SPEED = 320,
    MASTERY_TWEEN_SPEED = 320,
    BOAT_TWEEN_SPEED = 500,
    MIN_SPEED      = 50,
    MAX_SPEED      = 1000,
    SPEED_STEP     = 50,
    customOffset   = false,
    customOffsetX  = 0,
    customOffsetY  = 23,
    customOffsetZ  = 0,
    glitchSettings = {
        sanguine    = {speed=500,delay=0.1,duration=0.3},
        dragonTalon = {speed=500,delay=0.1,duration=0.3},
        yama        = {speed=500,delay=0.1,duration=0.3},
        tushita     = {speed=500,delay=0.4,duration=0.3},
        foxLamp     = {speed=500,delay=0.1,duration=0.3},
        soulGuitar  = {speed=500,delay=0.1,duration=0.3},
        diamond     = {speed=500,delay=0.1,duration=0.3},
        flame       = {speed=300,delay=0.17,duration=0.15},
    },

    chamBoxes      = {},
    espLabels      = {},
    chestEspLabels = {},
    berryEspLabels = {},
    boatEspEntries = {},
    flowerEspEntries = {},
    chestIndex     = 1,
    chestPriority  = {"Diamond","Gold","Silver"},
    selectedIsland = 1,
    espLabelCache  = {},
    chestEspLabelCache = {},
    berryEspLabelCache = {},
    boatEspCache = {},
    flowerEspCache = {},
    chamBoxCache   = {},
    currentBoat    = nil,
    boatTween      = nil,
    raidTweenActive   = false,
    raidDetected      = false,
    raidLastIslandNum = 0,
    raidLastIslandKey = nil,
    raidMapKey        = nil,
    raidMoveGeneration = 0,
    lastRaidIslandCount = 0,
}

function farmPriorityBlocked()
    return S.fruitPriorityActive == true or S.autoDinoBone == true or S.autoBossFarm == true or S.autoMaterialFarm == true
        or S.autoSeaEvent == true
        or S.dungeonEnabled == true
        or S.autoMirageTween == true or S.autoMirageGear == true
end

AFL = {
    tweenSpeed       = 320,
    selectedNpc      = nil,
    currentSea       = 1,
    lastLevel        = 0,
    npcToFarm        = "Sea1First",
    autofarmByLevel  = true,
    autoV3           = false,
    autoV4           = true,
    enableGetQuest   = true,
    usePortalTeleport = true,
    activeTweens     = {},
    lastTween        = os.clock(),
    tween            = nil,
    questData        = nil,
    pos = {
        sea1First              = Vector3.new(-2711.6,24.55,2105.27),
        sea1FirstWait          = Vector3.new(-2834.22,41.8,2152.38),
        jungle                 = Vector3.new(-1602.35,36.91,150.99),
        jungleWait1            = Vector3.new(-1448.19,50.91,64.35),
        jungleWait2            = Vector3.new(-1192.02,7.83,-448.82),
        pirateVillage          = Vector3.new(-1140.03,4.81,3828.47),
        pirateVillageWait1     = Vector3.new(-1233.49,115.64,3985.23),
        pirateVillageWait2     = Vector3.new(-1142.35,84.96,4297.03),
        desert                 = Vector3.new(896.93,6.5,4388.77),
        desertWait1            = Vector3.new(1054.99,52.5,4490.5),
        desertWait2            = Vector3.new(1528.99,14.51,4395.69),
        winter                 = Vector3.new(1382.2,87.34,-1294.29),
        winterWait1            = Vector3.new(1332.85,104.47,-1313.92),
        winterWait2            = Vector3.new(1200.95,144.64,-1550.89),
        marineFortress         = Vector3.new(-5036.22,28.71,4325.45),
        marineFortressWait1    = Vector3.new(-4819.73,20.71,4359.87),
        marineFortressWait2    = Vector3.new(-4950.39,71.41,4166.69),
        sky1                   = Vector3.new(-4841.94,717.73,-2623.45),
        sky1Wait1              = Vector3.new(-4959.59,365.07,-2911.46),
        sky1Wait2              = Vector3.new(-5223.22,449.34,-2397.63),
        prison                 = Vector3.new(5305.62,1.72,474.79),
        prisonWait1            = Vector3.new(5200.82,88.71,481.99),
        prisonWait2            = Vector3.new(5426.98,88.71,988.44),
        colosseum              = Vector3.new(-1578.9,7.5,-2984.3),
        colosseumWait1         = Vector3.new(-1940.03,49.12,-2894.37),
        colosseumWait2         = Vector3.new(-1300.48,7.51,-3243.32),
        magma                  = Vector3.new(-5316.38,11.38,8510.77),
        magmaWait1             = Vector3.new(-5401.39,23.07,8506.53),
        magmaWait2             = Vector3.new(-5775.68,118.91,8802.16),
        underwater             = Vector3.new(61123.74,18.53,1567.43),
        underwaterWait1        = Vector3.new(60952.76,48.74,1532.15),
        underwaterWait2        = Vector3.new(61905.32,108.55,1556.68),
        sky3                   = Vector3.new(-4725.1,845.34,-1956.55),
        sky3Wait               = Vector3.new(-4634.47,866.97,-1938.53),
        sky4                   = Vector3.new(-7861.91,5545.56,-376.38),
        sky4Wait               = Vector3.new(-7688.82,5600.79,-441.55),
        sky5                   = Vector3.new(-7899.52,5636.03,-1409.42),
        sky5Wait1              = Vector3.new(-7638.64,5637.14,-1421.99),
        sky5Wait2              = Vector3.new(-7838.8,5680.52,-1793.07),
        fountain               = Vector3.new(5254.86,38.56,4049.82),
        fountainWait1          = Vector3.new(5633.07,103.08,4059.29),
        fountainWait2          = Vector3.new(5685.56,66.35,4825),
        roseKingdom            = Vector3.new(-424.07,73.14,1835.97),
        roseKingdomWait1       = Vector3.new(-713.92,39.31,2375.86),
        roseKingdomWait2       = Vector3.new(351.33,39.31,2327.74),
        roseKingdomWait3       = Vector3.new(-959.84,80.5,1691.61),
        roseKingdomWait4       = Vector3.new(-1096.17,80.65,1155.03),
        factory                = Vector3.new(634.46,73.29,919.02),
        factoryWait1           = Vector3.new(828.24,140.36,1182.37),
        factoryWait2           = Vector3.new(628.62,73.18,-5.86),
        factoryWait3           = Vector3.new(-45.62,149.66,-301.97),
        greenZone              = Vector3.new(-2442.94,73.24,-3219.45),
        greenZoneWait1         = Vector3.new(-2947.85,111.16,-2979.32),
        greenZoneWait2         = Vector3.new(-1846.47,90.45,-3207.15),
        graveyard              = Vector3.new(-5493.04,48.7,-794.38),
        graveyardWait1         = Vector3.new(-5722.79,126.26,-752.72),
        graveyardWait2         = Vector3.new(-6038.78,6.63,-1297.6),
        snow                   = Vector3.new(605.73,401.65,-5371.18),
        snowWait1              = Vector3.new(536.02,433.39,-5482.01),
        snowWait2              = Vector3.new(1269.49,454.57,-5143.11),
        coldSide               = Vector3.new(-6229.27,82.05,-4851.89),
        coldSideWait1          = Vector3.new(-5867.03,88.63,-4385.88),
        coldSideWait2          = Vector3.new(-6310.69,35.63,-5882.5),
        hotSide                = Vector3.new(-5400.93,29.39,-5376.38),
        hotSideWait1           = Vector3.new(-5700.74,135.59,-5696.33),
        hotSideWait2           = Vector3.new(-5227.32,79.8,-4910.44),
        hauntedShip1           = Vector3.new(1037.82,125.28,32909.95),
        hauntedShip1Wait1      = Vector3.new(1257.26,125.67,33093.13),
        hauntedShip1Wait2      = Vector3.new(612.15,125.28,33049.17),
        hauntedShip1Wait3      = Vector3.new(943.62,40.67,32827.61),
        hauntedShip2           = Vector3.new(971.4,125.28,33248.01),
        hauntedShip2Wait1      = Vector3.new(1212.3,125.8,33078.4),
        hauntedShip2Wait2      = Vector3.new(1201.9,181.2,33296.9),
        hauntedShip2Wait3      = Vector3.new(671.5,181.2,33291.0),
        winterCastle           = Vector3.new(5670.71,28.4,-6479.92),
        winterCastleWait1      = Vector3.new(5924.53,70.64,-6202.01),
        winterCastleWait2      = Vector3.new(5431.28,75.24,-6812.18),
        wano                   = Vector3.new(-3053.98,239.87,-10147.38),
        wanoWait1              = Vector3.new(-3044.49,29.76,-9787.32),
        wanoWait2              = Vector3.new(-3435.25,275.76,-10480.77),
        hydra1                 = Vector3.new(6737.77,127.56,-715.37),
        hydra1Wait             = Vector3.new(6744.37,115.45,-792.37),
        hydra2                 = Vector3.new(6651.94,546.71,260.22),
        hydra2Wait             = Vector3.new(6762.3,565.2,271.6),
        hydra3                 = Vector3.new(5211.85,1004.13,757.35),
        hydra3Wait             = Vector3.new(4563.77,1002.4,824.84),
        port                   = Vector3.new(-449.36,108.63,5946.07),
        portWait1a             = Vector3.new(-128.02,57.04,5759.62),
        portWait1b             = Vector3.new(-646.17,57.04,5583.4),
        portWait2a             = Vector3.new(-778.57,143.02,6048.03),
        portWait2b             = Vector3.new(-232.7,152.3,6283.1),
        greatTree              = Vector3.new(2479.55,74.3,-6786.71),
        greatTreeWait1         = Vector3.new(2613.79,131.61,-7825.64),
        greatTreeWait2         = Vector3.new(3550.92,155.81,-7354.19),
        hauntedCastle1         = Vector3.new(-9484.23,142.17,5563.99),
        hauntedCastle2         = Vector3.new(-9513.78,172.17,6077.79),
        hauntedCastleWait1     = Vector3.new(-8891,223.03,6137.75),
        hauntedCastleWait2     = Vector3.new(-10079.95,237.5,5913.72),
        hauntedCastleWait3     = Vector3.new(-9502.4,172.17,6049.03),
        hauntedCastleWait4     = Vector3.new(-9545.33,60.32,6341.16),
        iceCream               = Vector3.new(-821.24,65.88,-10963.49),
        iceCreamWait           = Vector3.new(-875.19,184.15,-11124.79),
        cakeLand1              = Vector3.new(-2021.32,37.86,-12029.23),
        cakeLand1Wait1         = Vector3.new(-2299.21,112.6,-12210.75),
        cakeLand1Wait2         = Vector3.new(-1649.28,195.72,-12314.08),
        cakeLand2              = Vector3.new(-1927.75,37.86,-12842.92),
        cakeLand2Wait1         = Vector3.new(-1738.96,143.87,-12935.42),
        cakeLand2Wait2         = Vector3.new(-2248.69,53.57,-12849.23),
        chocolate1             = Vector3.new(237.92,24.8,-12201.14),
        chocolate1Wait1        = Vector3.new(80.22,73.51,-12310.81),
        chocolate1Wait2        = Vector3.new(684.82,45.34,-12421.76),
        chocolate2             = Vector3.new(147.05,24.86,-12778.49),
        chocolate2Wait1        = Vector3.new(48.8,75.13,-12763.81),
        northPole              = Vector3.new(-1159.84,61,-14495.45),
        northPoleWait1         = Vector3.new(-1357.6,83.3,-14704.45),
        northPoleWait2         = Vector3.new(-822.36,80.32,-14390.73),
        peanut                 = Vector3.new(-2104.58,38.17,-10191.75),
        peanutWait             = Vector3.new(-2049.21,165.51,-10335.04),
        tiki1                  = Vector3.new(-16543.93,55.75,-173.82),
        tiki1Wait              = Vector3.new(-16228.02,145.37,-231.54),
        tiki1Wait2             = Vector3.new(-16753.20,126.94,-278.50),
        tiki2                  = Vector3.new(-16538.69,55.75,1051.88),
        tiki2Wait              = Vector3.new(-16498.12,131.81,1051.74),
        tiki3                  = Vector3.new(-16665.98,105.31,1576.49),
        tiki3Wait1             = Vector3.new(-16537.67,158.94,1311.88),
        tiki3Wait2             = Vector3.new(-16847.48,122.17,1727.21),
        mansion                = Vector3.new(-13231.25,332.44,-7626.68),
        mansionWait1           = Vector3.new(-13448.1,416.3,-7780.96),
        mansionWait2           = Vector3.new(-13878.98,569.46,-7089.08),
        turtleCenter           = Vector3.new(-12683.65,390.92,-9900.57),
        turtleCenterWait1      = Vector3.new(-12055.72,428.33,-10385.56),
        turtleCenterWait2      = Vector3.new(-13294.97,520.51,-9900.41),
        turtleEntrance         = Vector3.new(-10583.8,331.83,-8757.94),
        turtleEntranceWait     = Vector3.new(-10568.57,477.29,-8832.32),
    },
}

if game.PlaceId == 2753915549 then
    AFL.currentSea = 1; AFL.npcToFarm = "Sea1First"
elseif game.PlaceId == 4442272183 then
    AFL.currentSea = 2; AFL.npcToFarm = "RoseKingdom1"
elseif game.PlaceId == 7449423635 then
    AFL.currentSea = 3; AFL.npcToFarm = "Port1"
end

function afl_pick(a, b) return (math.random(1,2)==1) and a or b end

AFL.islandPositions = {
    Sea1First=AFL.pos.sea1First,
    Jungle1=AFL.pos.jungle, Jungle2=AFL.pos.jungle,
    PirateVillage1=AFL.pos.pirateVillage, PirateVillage2=AFL.pos.pirateVillage,
    DesertIsland1=AFL.pos.desert, DesertIsland2=AFL.pos.desert,
    WinterIsland1=AFL.pos.winter, WinterIsland2=AFL.pos.winter,
    MarineFortress=AFL.pos.marineFortress,
    SkyIsland1=AFL.pos.sky1, SkyIsland2=AFL.pos.sky1,
    PrisonIsland1=AFL.pos.prison, PrisonIsland2=AFL.pos.prison,
    ColosseumIsland1=AFL.pos.colosseum, ColosseumIsland2=AFL.pos.colosseum,
    MagmaIsland1=AFL.pos.magma, MagmaIsland2=AFL.pos.magma,
    UnderWaterIsland1=AFL.pos.underwater, UnderWaterIsland2=AFL.pos.underwater,
    SkyIsland3=AFL.pos.sky3, SkyIsland4=AFL.pos.sky4,
    SkyIsland5=AFL.pos.sky5, SkyIsland6=AFL.pos.sky5,
    FountainIsland1=AFL.pos.fountain, FountainIsland2=AFL.pos.fountain,
    RoseKingdom1=AFL.pos.roseKingdom, RoseKingdom2=AFL.pos.roseKingdom,
    Factory1=AFL.pos.factory, Factory2=AFL.pos.factory,
    GreenZone1=AFL.pos.greenZone, GreenZone2=AFL.pos.greenZone,
    Graveyard1=AFL.pos.graveyard, Graveyard2=AFL.pos.graveyard,
    Snow1=AFL.pos.snow, Snow2=AFL.pos.snow,
    ColdSide1=AFL.pos.coldSide, ColdSide2=AFL.pos.coldSide,
    HotSide1=AFL.pos.hotSide, HotSide2=AFL.pos.hotSide,
    HauntedShip1=AFL.pos.hauntedShip1, HauntedShip2=AFL.pos.hauntedShip1,
    HauntedShip3=AFL.pos.hauntedShip2, HauntedShip4=AFL.pos.hauntedShip2,
    WinterCastle1=AFL.pos.winterCastle, WinterCastle2=AFL.pos.winterCastle,
    Wano1=AFL.pos.wano, Wano2=AFL.pos.wano,
    Hydra1=AFL.pos.hydra1, Hydra2=AFL.pos.hydra2, Hydra3=AFL.pos.hydra3, Hydra4=AFL.pos.hydra3,
    Port1=AFL.pos.port, Port2=AFL.pos.port,
    GreatTree1=AFL.pos.greatTree, GreatTree2=AFL.pos.greatTree,
    HauntedCastle1=AFL.pos.hauntedCastle1, HauntedCastle2=AFL.pos.hauntedCastle1,
    HauntedCastle3=AFL.pos.hauntedCastle2, HauntedCastle4=AFL.pos.hauntedCastle2,
    IceCream1=AFL.pos.iceCream, IceCream2=AFL.pos.iceCream,
    CakeLand1=AFL.pos.cakeLand1, CakeLand2=AFL.pos.cakeLand1,
    CakeLand3=AFL.pos.cakeLand2, CakeLand4=AFL.pos.cakeLand2,
    Chocolate1=AFL.pos.chocolate1, Chocolate2=AFL.pos.chocolate1,
    Chocolate3=AFL.pos.chocolate2, Chocolate4=AFL.pos.chocolate2,
    NorthPole1=AFL.pos.northPole, NorthPole2=AFL.pos.northPole,
    Peanut1=AFL.pos.peanut, Peanut2=AFL.pos.peanut,
    Tiki1Quest1=AFL.pos.tiki1, Tiki1Quest2=AFL.pos.tiki1,
    Tiki2Quest1=AFL.pos.tiki2, Tiki2Quest2=AFL.pos.tiki2,
    Tiki3Quest1=AFL.pos.tiki3, Tiki3Quest2=AFL.pos.tiki3,
    Mansion1=AFL.pos.mansion, Mansion2=AFL.pos.mansion,
    TurtleCenter1=AFL.pos.turtleCenter, TurtleCenter2=AFL.pos.turtleCenter,
    TurtleEntrance1=AFL.pos.turtleEntrance, TurtleEntrance2=AFL.pos.turtleEntrance,
}

AFL.waitPositions = {
    Sea1First=AFL.pos.sea1FirstWait,
    Jungle1=AFL.pos.jungleWait1, Jungle2=AFL.pos.jungleWait2,
    PirateVillage1=AFL.pos.pirateVillageWait1, PirateVillage2=AFL.pos.pirateVillageWait2,
    DesertIsland1=AFL.pos.desertWait1, DesertIsland2=AFL.pos.desertWait2,
    WinterIsland1=AFL.pos.winterWait1, WinterIsland2=AFL.pos.winterWait2,
    MarineFortress=afl_pick(AFL.pos.marineFortressWait1, AFL.pos.marineFortressWait2),
    SkyIsland1=AFL.pos.sky1Wait1, SkyIsland2=AFL.pos.sky1Wait2,
    PrisonIsland1=AFL.pos.prisonWait1, PrisonIsland2=AFL.pos.prisonWait2,
    ColosseumIsland1=AFL.pos.colosseumWait1, ColosseumIsland2=AFL.pos.colosseumWait2,
    MagmaIsland1=AFL.pos.magmaWait1, MagmaIsland2=AFL.pos.magmaWait2,
    UnderWaterIsland1=AFL.pos.underwaterWait1, UnderWaterIsland2=AFL.pos.underwaterWait2,
    SkyIsland3=AFL.pos.sky3Wait, SkyIsland4=AFL.pos.sky4Wait,
    SkyIsland5=AFL.pos.sky5Wait1, SkyIsland6=AFL.pos.sky5Wait2,
    FountainIsland1=AFL.pos.fountainWait1, FountainIsland2=AFL.pos.fountainWait2,
    RoseKingdom1=afl_pick(AFL.pos.roseKingdomWait1, AFL.pos.roseKingdomWait2),
    RoseKingdom2=afl_pick(AFL.pos.roseKingdomWait3, AFL.pos.roseKingdomWait4),
    Factory1=AFL.pos.factoryWait1, Factory2=afl_pick(AFL.pos.factoryWait2, AFL.pos.factoryWait3),
    GreenZone1=AFL.pos.greenZoneWait1, GreenZone2=AFL.pos.greenZoneWait2,
    Graveyard1=AFL.pos.graveyardWait1, Graveyard2=AFL.pos.graveyardWait2,
    Snow1=AFL.pos.snowWait1, Snow2=AFL.pos.snowWait2,
    ColdSide1=AFL.pos.coldSideWait1, ColdSide2=AFL.pos.coldSideWait2,
    HotSide1=AFL.pos.hotSideWait1, HotSide2=AFL.pos.hotSideWait2,
    HauntedShip1=afl_pick(AFL.pos.hauntedShip1Wait1, AFL.pos.hauntedShip1Wait2),
    HauntedShip2=AFL.pos.hauntedShip1Wait3,
    HauntedShip3=AFL.pos.hauntedShip2Wait1,
    HauntedShip4=AFL.pos.hauntedShip2Wait2,
    WinterCastle1=AFL.pos.winterCastleWait1, WinterCastle2=AFL.pos.winterCastleWait2,
    Wano1=AFL.pos.wanoWait1, Wano2=AFL.pos.wanoWait2,
    Hydra1=AFL.pos.hydra1Wait, Hydra2=AFL.pos.hydra2Wait,
    Hydra3=AFL.pos.hydra3Wait, Hydra4=AFL.pos.hydra3Wait,
    Port1=afl_pick(AFL.pos.portWait1a, AFL.pos.portWait1b),
    Port2=afl_pick(AFL.pos.portWait2a, AFL.pos.portWait2b),
    GreatTree1=AFL.pos.greatTreeWait1, GreatTree2=AFL.pos.greatTreeWait2,
    HauntedCastle1=AFL.pos.hauntedCastleWait1, HauntedCastle2=AFL.pos.hauntedCastleWait2,
    HauntedCastle3=AFL.pos.hauntedCastleWait3, HauntedCastle4=AFL.pos.hauntedCastleWait4,
    IceCream1=AFL.pos.iceCreamWait, IceCream2=AFL.pos.iceCreamWait,
    CakeLand1=AFL.pos.cakeLand1Wait1, CakeLand2=AFL.pos.cakeLand1Wait2,
    CakeLand3=AFL.pos.cakeLand2Wait1, CakeLand4=AFL.pos.cakeLand2Wait2,
    Chocolate1=AFL.pos.chocolate1Wait1, Chocolate2=AFL.pos.chocolate1Wait2,
    Chocolate3=AFL.pos.chocolate2Wait1, Chocolate4=AFL.pos.chocolate2Wait1,
    NorthPole1=AFL.pos.northPoleWait1, NorthPole2=AFL.pos.northPoleWait2,
    Peanut1=AFL.pos.peanutWait, Peanut2=AFL.pos.peanutWait,
    Tiki1Quest1=AFL.pos.tiki1Wait, Tiki1Quest2=AFL.pos.tiki1Wait2,
    Tiki2Quest1=AFL.pos.tiki2Wait, Tiki2Quest2=AFL.pos.tiki2Wait,
    Tiki3Quest1=AFL.pos.tiki3Wait1, Tiki3Quest2=AFL.pos.tiki3Wait2,
    Mansion1=AFL.pos.mansionWait1, Mansion2=AFL.pos.mansionWait2,
    TurtleCenter1=AFL.pos.turtleCenterWait1, TurtleCenter2=AFL.pos.turtleCenterWait2,
    TurtleEntrance1=AFL.pos.turtleEntranceWait, TurtleEntrance2=AFL.pos.turtleEntranceWait,
}

AFL.waitRoutes={
    HauntedShip4={AFL.pos.hauntedShip2Wait2,AFL.pos.hauntedShip2Wait3},
}

AFL.waitRouteIndices={}
AFL.farmLoopRunning=false
AFL.nextNpcCache=nil
AFL.nextNpcCacheTime=0

AFL.levelFarmTable = {
    [1]={{1,10,"Sea1First"},{10,15,"Jungle1"},{15,30,"Jungle2"},{30,40,"PirateVillage1"},{40,60,"PirateVillage2"},{60,75,"DesertIsland1"},{75,90,"DesertIsland2"},{90,100,"WinterIsland1"},{100,120,"WinterIsland2"},{120,150,"MarineFortress"},{150,175,"SkyIsland1"},{175,190,"SkyIsland2"},{190,210,"PrisonIsland1"},{210,250,"PrisonIsland2"},{250,275,"ColosseumIsland1"},{275,300,"ColosseumIsland2"},{300,325,"MagmaIsland1"},{325,375,"MagmaIsland2"},{375,400,"UnderWaterIsland1"},{400,450,"UnderWaterIsland2"},{450,475,"SkyIsland3"},{475,525,"SkyIsland4"},{525,550,"SkyIsland5"},{550,625,"SkyIsland6"},{625,650,"FountainIsland1"},{650,700,"FountainIsland2"}},
    [2]={{700,725,"RoseKingdom1"},{725,775,"RoseKingdom2"},{775,800,"Factory1"},{800,875,"Factory2"},{875,900,"GreenZone1"},{900,950,"GreenZone2"},{950,975,"Graveyard1"},{975,1000,"Graveyard2"},{1000,1050,"Snow1"},{1050,1100,"Snow2"},{1100,1125,"ColdSide1"},{1125,1175,"ColdSide2"},{1175,1200,"HotSide1"},{1200,1250,"HotSide2"},{1250,1275,"HauntedShip1"},{1275,1300,"HauntedShip2"},{1300,1325,"HauntedShip3"},{1325,1350,"HauntedShip4"},{1350,1375,"WinterCastle1"},{1375,1425,"WinterCastle2"},{1425,1450,"Wano1"},{1450,1500,"Wano2"}},
    [3]={{1500,1525,"Port1"},{1525,1575,"Port2"},{1575,1600,"Hydra1"},{1600,1625,"Hydra2"},{1625,1650,"Hydra3"},{1650,1700,"Hydra4"},{1700,1725,"GreatTree1"},{1725,1775,"GreatTree2"},{1775,1800,"TurtleEntrance1"},{1800,1825,"TurtleEntrance2"},{1825,1850,"Mansion1"},{1850,1900,"Mansion2"},{1900,1925,"TurtleCenter1"},{1925,1975,"TurtleCenter2"},{1975,2000,"HauntedCastle1"},{2000,2025,"HauntedCastle2"},{2025,2050,"HauntedCastle3"},{2050,2075,"HauntedCastle4"},{2075,2100,"Peanut1"},{2100,2125,"Peanut2"},{2125,2150,"IceCream1"},{2150,2200,"IceCream2"},{2200,2225,"CakeLand1"},{2225,2250,"CakeLand2"},{2250,2275,"CakeLand3"},{2275,2300,"CakeLand4"},{2300,2325,"Chocolate1"},{2325,2350,"Chocolate2"},{2350,2375,"Chocolate3"},{2375,2400,"Chocolate4"},{2400,2425,"NorthPole1"},{2425,2450,"NorthPole2"},{2450,2475,"Tiki1Quest1"},{2475,2500,"Tiki1Quest2"},{2500,2525,"Tiki2Quest1"},{2525,2550,"Tiki2Quest2"},{2550,2575,"Tiki3Quest1"},{2575,2800,"Tiki3Quest2"}}
}

dangerLevels = {
    {name="Level 1", pos=Vector3.new(-22154,37,2735)},
    {name="Level 2", pos=Vector3.new(-26413,37,3671)},
    {name="Level 3", pos=Vector3.new(-30027,37,3921)},
    {name="Level 4", pos=Vector3.new(-33348,37,3704)},
    {name="Level 5", pos=Vector3.new(-38169,37,5121)},
    {name="Level 6", pos=Vector3.new(-43568,37,7018)},
}
dangerLevelNames = {}
for _, d in pairs(dangerLevels) do table.insert(dangerLevelNames, d.name) end

islandList = {
    {name="Tiki2",          pos=Vector3.new(-16577.81,107.2,1226.22)},
    {name="Tiki1",          pos=Vector3.new(-16546.72,55.87,-228.59)},
    {name="Port",           pos=Vector3.new(-706.75,85.98,5775.46)},
    {name="Hydra1",         pos=Vector3.new(6737.77,127.56,-715.37)},
    {name="Hydra2",         pos=Vector3.new(6651.94,546.71,260.22)},
    {name="Hydra3",         pos=Vector3.new(4563.77,1002.40,824.84)},
    {name="GreatTree1",     pos=Vector3.new(2976.45,74.41,-7919.18)},
    {name="GreatTree2",     pos=Vector3.new(3727.85,124.12,-7153.10)},
    {name="HauntedCastle",  pos=Vector3.new(-9558.96,172.28,6139.46)},
    {name="IceCream",       pos=Vector3.new(-836.01,65.99,-10973.16)},
    {name="CakeLand",       pos=Vector3.new(-2115.22,70.16,-12366.38)},
    {name="Chocolate",      pos=Vector3.new(314.05,24.97,-12480.51)},
    {name="Peanut",         pos=Vector3.new(-2093.83,38.28,-10204.63)},
    {name="Mansion",        pos=Vector3.new(-13330.71,450.81,-7441.45)},
    {name="TurtleCenter2",  pos=Vector3.new(-13274.77,391.72,-9791.60)},
    {name="TurtleCenter1",  pos=Vector3.new(-12019.83,331.91,-10562.06)},
    {name="TurtleEntrance", pos=Vector3.new(-10607.67,331.94,-8782.75)},
}

do
    local ok, err = pcall(function()
        local ueSource = game:HttpGet("https://raw.githubusercontent.com/hauntedscripts/Scripts2/refs/heads/main/matcha%20ue")
        local ueChunk, ueError = loadstring(ueSource, "laced.club UE")
        if not ueChunk then error(ueError or "UE compile failed") end
        ueChunk()

        local UE = (_G and (_G.UELibrary or _G.Library)) or UELibrary
        if type(UE) ~= "table" then error("UE did not expose UELibrary") end

        local controls = {}

        local function roundingFor(step, explicit)
            if tonumber(explicit) then return math.max(0, math.floor(tonumber(explicit))) end
            step = tonumber(step) or 1
            if step >= 1 then return 0 end
            local decimals = tostring(step):match("%.(%d+)")
            return decimals and #decimals or 0
        end

        local function enhanceControl(id, control)
            if not control then return control end
            controls[id] = control
            control.Set = control.SetValue
            control.SetOptions = control.SetValues
            return control
        end

        local function makeTab(rawTab)
            local tab = { Raw = rawTab, Groups = {} }

            local function columnOf(info)
                local column = tonumber(info and info.Column) or 1
                return column == 2 and 2 or 1
            end

            local function groupFor(self, info)
                local column = columnOf(info)
                local group = self.Groups[column]
                if not group then
                    if column == 2 then group = self.Raw:AddRightGroupbox("General")
                    else group = self.Raw:AddLeftGroupbox("General") end
                    self.Groups[column] = group
                end
                return group
            end

            function tab:AddSection(name, info)
                local column = columnOf(info)
                local group
                if column == 2 then group = self.Raw:AddRightGroupbox(name)
                else group = self.Raw:AddLeftGroupbox(name) end
                self.Groups[column] = group
                return group
            end

            function tab:AddToggle(id, info)
                info = info or {}
                local group = groupFor(self, info)
                local toggle = group:AddToggle(id, {
                    Text = info.Text or id,
                    Default = info.Default == true,
                    Callback = info.Callback,
                    Tooltip = info.Description,
                    Risky = info.Risky == true,
                })
                enhanceControl(id, toggle)
                if info.Keybind == true then
                    local picker = toggle:AddKeyPicker(id .. "_keybind", {
                        Text = (info.Text or id) .. " key",
                        Default = "None",
                        Mode = "Toggle",
                        SyncToggleState = true,
                    })
                    enhanceControl(id .. "_keybind", picker)
                end
                return toggle
            end

            function tab:AddSlider(id, info)
                info = info or {}
                local step = tonumber(info.Step) or 1
                local minimum = tonumber(info.Min) or 0
                local maximum = tonumber(info.Max) or 100
                local callback = info.Callback
                local slider
                local function changed(value)
                    local snapped = minimum + math.floor(((value - minimum) / step) + 0.5) * step
                    if snapped < minimum then snapped = minimum end
                    if snapped > maximum then snapped = maximum end
                    if slider then slider.Value = snapped end
                    if callback then callback(snapped) end
                end
                slider = groupFor(self, info):AddSlider(id, {
                    Text = info.Text or id,
                    Default = info.Default,
                    Min = minimum,
                    Max = maximum,
                    Rounding = roundingFor(step, info.Decimals),
                    Suffix = info.Suffix or "",
                    Callback = changed,
                    Tooltip = info.Description,
                })
                return enhanceControl(id, slider)
            end

            function tab:AddDropdown(id, info)
                info = info or {}
                local dropdown = groupFor(self, info):AddDropdown(id, {
                    Text = info.Text or id,
                    Default = info.Default,
                    Values = info.Options or info.Values or {},
                    Multi = info.Multi == true,
                    AllowNull = info.AllowNull == true,
                    Callback = info.Callback,
                    Tooltip = info.Description,
                })
                return enhanceControl(id, dropdown)
            end

            function tab:AddButton(id, info)
                info = info or {}
                local button = groupFor(self, info):AddButton({
                    Text = info.Text or id,
                    Func = info.Callback,
                    Tooltip = info.Description,
                    DoubleClick = info.DoubleClick == true,
                })
                return enhanceControl(id, button)
            end

            function tab:AddPriorityList(id, info)
                info = info or {}
                local group = groupFor(self, info)
                local options = info.Options or {}
                local selected = {}
                for index, value in ipairs(info.Default or options) do selected[index] = value end
                local pickers = {}
                local changing = false

                local function emit()
                    if info.Callback then
                        local order = {}
                        for index = 1, #options do order[index] = selected[index] end
                        info.Callback(order)
                    end
                end

                for index = 1, #options do
                    local slot = index
                    local oldValue = selected[slot]
                    local picker
                    picker = group:AddDropdown(id .. "_" .. tostring(slot), {
                        Text = (info.Text or id) .. " " .. tostring(slot),
                        Default = selected[slot],
                        Values = options,
                        Callback = function(value)
                            if changing then return end
                            local previous = selected[slot]
                            local duplicate = nil
                            for other = 1, #selected do
                                if other ~= slot and selected[other] == value then duplicate = other break end
                            end
                            selected[slot] = value
                            if duplicate then
                                selected[duplicate] = previous
                                if pickers[duplicate] then pickers[duplicate].Value = previous end
                            end
                            oldValue = value
                            emit()
                        end,
                        Tooltip = info.Description,
                    })
                    pickers[slot] = picker
                    enhanceControl(id .. "_" .. tostring(slot), picker)
                end

                local list = { Pickers = pickers, Value = selected }
                function list:SetValue(order)
                    if type(order) ~= "table" then return self end
                    changing = true
                    for index = 1, math.min(#order, #pickers) do
                        selected[index] = order[index]
                        pickers[index].Value = order[index]
                    end
                    changing = false
                    emit()
                    return self
                end
                function list:SetValues(values)
                    for _, picker in ipairs(pickers) do picker:SetValues(values or {}) end
                    return self
                end
                list.SetOptions = list.SetValues
                controls[id] = list
                return list
            end

            return tab
        end

        local Adapter = { Raw = UE, Controls = controls, Windows = {} }

        local function makePopup(adapter, info)
            info = info or {}
            local raw = adapter.Raw:CreateWindow({
                Title = info.Title or "Settings",
                Width = info.Width or 520,
                Height = info.Height or 500,
                AutoShow = false,
                Center = true,
            })
            adapter.Raw.Toggled = true
            local page = makeTab(raw:AddTab(info.Title or "Settings"))
            local popup = { Raw = raw }
            function popup:AddSection(...) return page:AddSection(...) end
            function popup:AddToggle(...) return page:AddToggle(...) end
            function popup:AddSlider(...) return page:AddSlider(...) end
            function popup:AddDropdown(...) return page:AddDropdown(...) end
            function popup:AddButton(...) return page:AddButton(...) end
            function popup:AddPriorityList(...) return page:AddPriorityList(...) end
            function popup:Show() raw:Show() return self end
            function popup:Hide() raw:Hide() return self end
            function popup:Set(id, value)
                local control = controls[id]
                if control and control.SetValue then control:SetValue(value)
                elseif control and control.Set then control:Set(value) end
                return self
            end
            return popup
        end

        function Adapter:CreateWindow(info)
            info = info or {}
            local accent = info.Theme and info.Theme.Colors and info.Theme.Colors.Accent
            if accent then self.Raw.AccentColor = accent end
            if info.ConfigFile or info.SettingsFile then
                self.Raw.SettingsFile = (info.ConfigFile or info.SettingsFile) .. ".ui.json"
            end
            local raw = self.Raw:CreateWindow({
                Title = info.Title or "laced.club",
                Width = info.Width or 540,
                Height = info.Height or 430,
                AutoShow = true,
                Center = true,
            })
            local window = {
                Raw = raw,
                Tabs = {},
                Indicator = { SetVisible = function() end },
                Config = { IndicatorEnabled = false },
                _lastMenuDown = false,
            }

            local configFolder = tostring(info.ConfigFolder or "laced_club_configs")
            local selectedConfig = ""
            local function safeConfigName(name)
                name = tostring(name or ""):gsub("[^%w%._%- ]", "_"):gsub("^%s+", ""):gsub("%s+$", "")
                if name == "" then name = "default" end
                return name:sub(1, 64)
            end
            local function ensureConfigFolder()
                pcall(function()
                    if not isfolder(configFolder) then makefolder(configFolder) end
                end)
            end
            local function configPathFor(name)
                return configFolder .. "/" .. safeConfigName(name) .. ".json"
            end
            local function listConfigNames()
                ensureConfigFolder()
                local names = {}
                local ok, files = pcall(listfiles, configFolder)
                if ok and type(files) == "table" then
                    for _, path in ipairs(files) do
                        local fileName = tostring(path):match("([^/\\]+)%.json$")
                        if fileName then table.insert(names, fileName) end
                    end
                end
                table.sort(names)
                return names
            end
            local configPath = configPathFor("default")
            local function configValue(control)
                if not control then return nil end
                local kind = control.Type
                if kind == "Toggle" then return control.Value == true end
                if kind == "Slider" then return tonumber(control.Value) end
                if kind == "KeyPicker" then
                    return type(control.Value) == "string" and control.Value or "None"
                end
                if kind == "Dropdown" then
                    if control.Multi then
                        local out = {}
                        for key, value in pairs(control.Value or {}) do
                            if type(key) == "string" then out[key] = value == true end
                        end
                        return out
                    end
                    return type(control.Value) == "string" and control.Value or nil
                end
                return nil
            end
            local function saveFeatureConfig(name)
                name = safeConfigName(name or selectedConfig)
                ensureConfigFolder()
                local path = configPathFor(name)
                local data = { version = 4, controls = {}, name = name }
                local saved = 0
                for id, control in pairs(controls) do
                    local value = configValue(control)
                    if value ~= nil then data.controls[id] = value; saved = saved + 1 end
                end
                local ok, err = pcall(function()
                    local http = game:GetService("HttpService")
                    writefile(path, http:JSONEncode(data))
                end)
                if ok then
                    selectedConfig = name
                    configPath = path
                    window.Config.File = path
                end
                return ok
            end
            local function loadFeatureConfig(name)
                name = safeConfigName(name or selectedConfig)
                local path = configPathFor(name)
                local wasVisible = raw.Visible
                local wasToggled = self.Raw.Toggled
                local ok, data = pcall(function()
                    local http = game:GetService("HttpService")
                    return http:JSONDecode(readfile(path))
                end)
                if not ok or type(data) ~= "table" or data.version ~= 4 or type(data.controls) ~= "table" then
                    return false
                end
                local loaded = 0
                local toggleStates = {}
                for id, value in pairs(data.controls) do
                    local control = controls[id]
                    if control and control.Type == "Toggle" and type(value) == "boolean" then
                        toggleStates[id] = value
                    elseif control and control.SetValue then
                        local applied = pcall(function() control:SetValue(value) end)
                        if applied then loaded = loaded + 1 end
                    end
                end
                local previous = {}
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control then
                        previous[id] = control.Value == true
                        control.Value = value
                    end
                end
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control and previous[id] ~= value then
                        pcall(function() if control.Callback then control.Callback(value) end end)
                        pcall(function() if control.Changed then control.Changed(value) end end)
                    end
                end
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control then control.Value = value end
                    loaded = loaded + 1
                end
                raw.Visible = wasVisible
                self.Raw.Toggled = wasToggled
                raw._visibilityDirty = true
                selectedConfig = name
                configPath = path
                window.Config.File = path
                return true
            end
            local function refreshConfigList(dropdown)
                local names = listConfigNames()
                if dropdown and dropdown.SetValues then
                    pcall(function() dropdown:SetValues(names) end)
                end
                if selectedConfig == "" and names[1] then selectedConfig = names[1] end
                return names
            end
            window.Config = {
                IndicatorEnabled = false,
                File = configPath,
                Folder = configFolder,
                Save = function(name) return saveFeatureConfig(name) end,
                Load = function(name) return loadFeatureConfig(name) end,
            }

            function window:AddTab(name)
                local tab = makeTab(raw:AddTab(name))
                self.Tabs[name] = tab
                return tab
            end

            function window:Set(id, value)
                local control = controls[id]
                if control and control.SetValue then control:SetValue(value)
                elseif control and control.Set then control:Set(value) end
                return self
            end

            function window:CreatePopup(popupInfo)
                return makePopup(Adapter, popupInfo)
            end

            function window:Show() raw:Show() return self end
            function window:Hide() raw:Hide() return self end
            function window:SetVisible(value) if value then raw:Show() else raw:Hide() end return self end

            function window:Step()
                return self
            end

            table.insert(Adapter.Windows, window)

            if self.Raw.Configs then
                window.Config.Folder = self.Raw.Configs.Folder
                window.Config.Save = self.Raw.Configs.Save
                window.Config.Load = self.Raw.Configs.Load
            end
            return window
        end

        Library = Adapter
    end)
    if not ok or not Library then
        warn("Failed to load UE UI: " .. tostring(err))
        return
    end
end

_pvpAuraEnabled = false
_pvpAuraAltPart = false
_pvpAuraMaxDist = 100

islandNames = {}
for _, isle in pairs(islandList) do table.insert(islandNames, isle.name) end

Window = Library:CreateWindow({
    Title = "laced.club",
    Columns = 2,
    Divider = true,
    ConfigFile = "myth4c_bloxfruits.json",
    BuiltInIndicatorToggle = false,
    Width = 540,
    Height = 570,
    Theme = { Colors = { Accent = Color3.fromRGB(255,111,0) } }
})

local mainTab=Window:AddTab("Main")
local miscTab=Window:AddTab("Misc")
local misc2Tab=Window:AddTab("Misc2")
local otherTab=Window:AddTab("Other")
local pvpTab=Window:AddTab("PvP")
local automationTab=Window:AddTab("Automation")

do
    local MagnetSettings={
        enabled=false,
        targetPlayers=true,
        autoFarm=false,
        autoFarmNearest=false,
        farmMode=nil,
        selectedPlayerName="",
        range=100,
        attackNumber=1,
        m1Delay=0.10
    }

    local MAGNET_FARM_X_OFFSET=10
    local MAGNET_FARM_TWEEN_SPEED=350
    local MAGNET_NEAREST_ATTACK_TIME=1
    local MagnetNearestFarm={
        target=nil,
        attacking=false,
        attackEnds=0,
        holdPosition=nil,
        visited={}
    }

    local function magnetResetNearestFarm()
        MagnetNearestFarm.target=nil
        MagnetNearestFarm.attacking=false
        MagnetNearestFarm.attackEnds=0
        MagnetNearestFarm.holdPosition=nil
        MagnetNearestFarm.visited={}
    end

    local function magnetGetPlayerNames()
        local names={}
        for _,player in pairs(Players:GetChildren()) do
            if player~=LocalPlayer then table.insert(names,player.Name) end
        end
        if #names==0 then table.insert(names,"No players") end
        return names
    end

    local function magnetFindPlayerByName(name)
        if type(name)~="string" or name=="" then return nil end
        for _,player in pairs(Players:GetChildren()) do
            if player~=LocalPlayer and player.Name==name then return player end
        end
        return nil
    end

    misc2Tab:AddSection("Magnet M1 Aura",{Column=1})
    misc2Tab:AddToggle("magnet_m1_aura",{
        Text="Magnet M1 Aura",
        Description="Aims Magnet M1 at the closest enemy or enabled player target",
        Default=false,
        Keybind=true,
        Column=1,
        Callback=function(value)
            MagnetSettings.enabled=value
            notify(value and "Magnet M1 Aura ON!" or "Magnet M1 Aura OFF!","laced.club",2)
        end
    })

    misc2Tab:AddToggle("magnet_target_players",{
        Text="Target Players",
        Description="Allow Magnet M1 Aura to target other players",
        Default=true,
        Column=1,
        Callback=function(value) MagnetSettings.targetPlayers=value end
    })

    misc2Tab:AddSlider("magnet_target_range",{
        Text="Target Range",
        Description="Maximum aura targeting distance in studs",
        Min=10,Max=2000,Step=10,Integer=true,Default=100,Column=1,
        Color=Color3.fromRGB(210,70,255),
        Callback=function(value)
            MagnetSettings.range=math.max(10,tonumber(value) or 100)
        end
    })

    misc2Tab:AddSlider("magnet_m1_delay",{
        Text="Wait Between M1s",
        Description="Seconds to wait between Magnet remote calls",
        Min=0.01,Max=2,Step=0.01,Integer=false,Default=0.10,Column=1,
        Color=Color3.fromRGB(0,220,255),
        Callback=function(value)
            MagnetSettings.m1Delay=math.max(0.01,tonumber(value) or 0.10)
        end
    })

    misc2Tab:AddSlider("magnet_attack_number",{
        Text="Attack Number",
        Description="Selects Magnet M1 attack 1 through 5",
        Min=1,Max=5,Step=1,Integer=true,Default=1,Column=1,
        Color=Color3.fromRGB(255,80,150),
        Callback=function(value)
            MagnetSettings.attackNumber=math.max(1,math.min(5,math.floor(tonumber(value) or 1)))
        end
    })

    misc2Tab:AddSection("Magnet Auto Farm",{Column=2})
    misc2Tab:AddToggle("magnet_auto_farm",{
        Text="Auto Farm Player",
        Description="Tweens 10 studs along X from the selected player and spams Magnet M1",
        Default=false,Keybind=true,Column=2,
        Callback=function(value)
            MagnetSettings.autoFarm=value
            if value then
                MagnetSettings.farmMode="player"
                MagnetSettings.autoFarmNearest=false
                magnetResetNearestFarm()
                pcall(function() Window:Set("magnet_auto_farm_nearest",false) end)
            elseif MagnetSettings.farmMode=="player" then
                MagnetSettings.farmMode=nil
            end
            notify(value and "Magnet Auto Farm Player ON!" or "Magnet Auto Farm Player OFF!","laced.club",2)
        end
    })

    misc2Tab:AddToggle("magnet_auto_farm_nearest",{
        Text="Auto Farm Nearest Enemy",
        Description="Tweens to each nearest enemy, holds still for 1 second, then switches",
        Default=false,Column=2,
        Callback=function(value)
            MagnetSettings.autoFarmNearest=value
            magnetResetNearestFarm()
            if value then
                MagnetSettings.farmMode="enemy"
                MagnetSettings.autoFarm=false
                pcall(function() Window:Set("magnet_auto_farm",false) end)
            elseif MagnetSettings.farmMode=="enemy" then
                MagnetSettings.farmMode=nil
            end
            notify(value and "Magnet Auto Farm Nearest ON!" or "Magnet Auto Farm Nearest OFF!","laced.club",2)
        end
    })

    local initialMagnetPlayerNames=magnetGetPlayerNames()
    if initialMagnetPlayerNames[1]~="No players" then
        MagnetSettings.selectedPlayerName=initialMagnetPlayerNames[1]
    end

    local magnetPlayerDropdown=misc2Tab:AddDropdown("magnet_target_player",{
        Text="Target Player",
        Description="Select the player Magnet Auto Farm follows",
        Options=initialMagnetPlayerNames,
        Default=initialMagnetPlayerNames[1],
        MaxVisible=8,
        Column=2,
        Callback=function(selected)
            if type(selected)=="string" and selected~="No players" then
                MagnetSettings.selectedPlayerName=selected
            end
        end
    })

    misc2Tab:AddButton("magnet_rescan_players",{
        Text="Rescan Players",
        Description="Refreshes the Magnet target player list",
        Column=2,
        Callback=function()
            local names=magnetGetPlayerNames()
            local keptSelection=false
            for _,name in pairs(names) do
                if name==MagnetSettings.selectedPlayerName then keptSelection=true end
            end

            local refreshed=false
            if magnetPlayerDropdown then
                refreshed=pcall(function() magnetPlayerDropdown:SetValues(names) end)
                if not refreshed then
                    refreshed=pcall(function() magnetPlayerDropdown:SetOptions(names) end)
                end
            end

            if not keptSelection then
                MagnetSettings.selectedPlayerName=names[1]~="No players" and names[1] or ""
                if MagnetSettings.selectedPlayerName~="" then
                    pcall(function() magnetPlayerDropdown:SetValue(MagnetSettings.selectedPlayerName) end)
                end
            end
            notify(refreshed and "Player list refreshed" or "Player list refresh failed","laced.club",2)
        end
    })

    local function magnetGetRoot(model)
        if not model then return nil end
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChildWhichIsA("BasePart")
    end

    local function magnetIsAlive(model)
        if not model or not model.Parent then return false end
        local humanoid=model:FindFirstChildOfClass("Humanoid")
        return not humanoid or humanoid.Health>0
    end

    local function magnetDistanceSquared(a,b)
        local dx=a.X-b.X
        local dy=a.Y-b.Y
        local dz=a.Z-b.Z
        return dx*dx+dy*dy+dz*dz
    end

    local function magnetConsiderTarget(origin,model,bestModel,bestRoot,bestDistanceSquared)
        if model and model~=LocalPlayer.Character and magnetIsAlive(model) then
            local root=magnetGetRoot(model)
            if root then
                local currentDistanceSquared=magnetDistanceSquared(origin,root.Position)
                if currentDistanceSquared<bestDistanceSquared then
                    return model,root,currentDistanceSquared
                end
            end
        end
        return bestModel,bestRoot,bestDistanceSquared
    end

    local function magnetFindClosestTarget(playerRoot)
        local bestModel=nil
        local bestRoot=nil
        local bestDistanceSquared=MagnetSettings.range*MagnetSettings.range
        local origin=playerRoot.Position
        local enemies=game.Workspace:FindFirstChild("Enemies")

        if enemies then
            for _,enemy in pairs(enemies:GetChildren()) do
                bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                    origin,enemy,bestModel,bestRoot,bestDistanceSquared
                )
            end
        end

        if MagnetSettings.targetPlayers then
            for _,player in pairs(Players:GetChildren()) do
                if player~=LocalPlayer then
                    bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                        origin,player.Character,bestModel,bestRoot,bestDistanceSquared
                    )
                end
            end
        end
        return bestModel,bestRoot
    end

    local function magnetFindClosestEnemy(playerRoot,excluded)
        local enemies=game.Workspace:FindFirstChild("Enemies")
        if not enemies then return nil,nil end
        local bestModel=nil
        local bestRoot=nil
        local bestDistanceSquared=MagnetSettings.range*MagnetSettings.range
        local origin=playerRoot.Position

        for _,enemy in pairs(enemies:GetChildren()) do
            if not excluded or not excluded[enemy] then
                bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                    origin,enemy,bestModel,bestRoot,bestDistanceSquared
                )
            end
        end
        return bestModel,bestRoot
    end

    local function magnetGetRemote()
        local characters=game.Workspace:FindFirstChild("Characters")
        local character=characters and characters:FindFirstChild(LocalPlayer.Name)
        if not character then character=LocalPlayer.Character end
        local magnet=character and character:FindFirstChild("Magnet-Magnet")
        return magnet and magnet:FindFirstChild("LeftClickRemote")
    end

    local function magnetDirectionTo(origin,target)
        local dx=target.X-origin.X
        local dy=target.Y-origin.Y
        local dz=target.Z-origin.Z
        local length=math.sqrt(dx*dx+dy*dy+dz*dz)
        if length<0.001 then return Vector3.new(0,0,-1) end
        return Vector3.new(dx/length,dy/length,dz/length)
    end

    local function magnetGetSelectedPlayerTarget()
        local player=magnetFindPlayerByName(MagnetSettings.selectedPlayerName)
        local character=player and player.Character
        if not magnetIsAlive(character) then return nil,nil end
        return character,magnetGetRoot(character)
    end

    task.spawn(function()
        local lastStep=os.clock()
        while true do
            local now=os.clock()
            local deltaTime=now-lastStep
            lastStep=now

            if MagnetSettings.farmMode=="player" or MagnetSettings.farmMode=="enemy" then
                local character=LocalPlayer.Character
                local playerRoot=magnetGetRoot(character)
                local targetModel,targetRoot=nil,nil

                if MagnetSettings.farmMode=="enemy" and playerRoot then
                    if MagnetNearestFarm.attacking then
                        targetModel=MagnetNearestFarm.target
                    elseif MagnetNearestFarm.target and not magnetIsAlive(MagnetNearestFarm.target) then
                        MagnetNearestFarm.visited[MagnetNearestFarm.target]=true
                        MagnetNearestFarm.target=nil
                        MagnetNearestFarm.attacking=false
                        MagnetNearestFarm.attackEnds=0
                        MagnetNearestFarm.holdPosition=nil
                    end

                    if not MagnetNearestFarm.attacking and not MagnetNearestFarm.target then
                        targetModel,targetRoot=magnetFindClosestEnemy(playerRoot,MagnetNearestFarm.visited)
                        if not targetModel then
                            MagnetNearestFarm.visited={}
                            targetModel,targetRoot=magnetFindClosestEnemy(playerRoot,MagnetNearestFarm.visited)
                        end
                        MagnetNearestFarm.target=targetModel
                    elseif not MagnetNearestFarm.attacking then
                        targetModel=MagnetNearestFarm.target
                        targetRoot=magnetGetRoot(targetModel)
                    end
                else
                    targetModel,targetRoot=magnetGetSelectedPlayerTarget()
                end

                if MagnetSettings.farmMode=="enemy" and not MagnetNearestFarm.attacking
                    and targetModel and not targetRoot then
                    MagnetNearestFarm.visited[targetModel]=true
                    MagnetNearestFarm.target=nil
                end

                if playerRoot and MagnetSettings.farmMode=="enemy" and MagnetNearestFarm.attacking then
                    if MagnetNearestFarm.holdPosition then
                        playerRoot.Position=MagnetNearestFarm.holdPosition
                    end
                    playerRoot.Velocity=Vector3.new(0,0,0)
                    playerRoot.AssemblyLinearVelocity=Vector3.new(0,0,0)

                    if now>=MagnetNearestFarm.attackEnds then
                        if MagnetNearestFarm.target then
                            MagnetNearestFarm.visited[MagnetNearestFarm.target]=true
                        end
                        MagnetNearestFarm.target=nil
                        MagnetNearestFarm.attacking=false
                        MagnetNearestFarm.attackEnds=0
                        MagnetNearestFarm.holdPosition=nil
                    end
                elseif playerRoot and targetModel and targetRoot then
                    local currentPosition=playerRoot.Position
                    local targetPosition=Vector3.new(
                        targetRoot.Position.X+MAGNET_FARM_X_OFFSET,
                        targetRoot.Position.Y,
                        targetRoot.Position.Z
                    )
                    local dx=targetPosition.X-currentPosition.X
                    local dy=targetPosition.Y-currentPosition.Y
                    local dz=targetPosition.Z-currentPosition.Z
                    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)

                    if distance>0.01 then
                        local maxStep=MAGNET_FARM_TWEEN_SPEED*math.min(deltaTime,0.1)
                        local alpha=math.min(maxStep/distance,1)
                        playerRoot.Position=Vector3.new(
                            currentPosition.X+dx*alpha,
                            currentPosition.Y+dy*alpha,
                            currentPosition.Z+dz*alpha
                        )
                    end

                    if MagnetSettings.farmMode=="enemy" and MagnetNearestFarm.target==targetModel
                        and not MagnetNearestFarm.attacking and distance<=1.5 then
                        playerRoot.Position=targetPosition
                        MagnetNearestFarm.attacking=true
                        MagnetNearestFarm.attackEnds=now+MAGNET_NEAREST_ATTACK_TIME
                        MagnetNearestFarm.holdPosition=targetPosition
                    end
                    playerRoot.Velocity=Vector3.new(0,0,0)
                    playerRoot.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end
            end
            task.wait()
        end
    end)

    task.spawn(function()
        local lastM1=0
        while true do
            if MagnetSettings.enabled or MagnetSettings.farmMode~=nil then
                local character=LocalPlayer.Character
                local playerRoot=magnetGetRoot(character)
                local now=os.clock()

                if playerRoot and now-lastM1>=MagnetSettings.m1Delay then
                    local targetModel,targetRoot=nil,nil
                    if MagnetSettings.farmMode=="enemy" then
                        if MagnetNearestFarm.attacking and magnetIsAlive(MagnetNearestFarm.target) then
                            targetModel=MagnetNearestFarm.target
                            targetRoot=magnetGetRoot(targetModel)
                        end
                    elseif MagnetSettings.farmMode=="player" then
                        targetModel,targetRoot=magnetGetSelectedPlayerTarget()
                    else
                        targetModel,targetRoot=magnetFindClosestTarget(playerRoot)
                    end

                    local remote=magnetGetRemote()
                    if targetModel and targetRoot and remote then
                        local direction=magnetDirectionTo(playerRoot.Position,targetRoot.Position)
                        local ok,err=pcall(function()
                            remote:FireServer(direction,MagnetSettings.attackNumber)
                        end)
                        if not ok then warn("Magnet M1 failed: "..tostring(err)) end
                        lastM1=now
                    end
                end
            end
            task.wait()
        end
    end)
end

misc2Tab:AddSection("Ship Repair",{Column=1})
misc2Tab:AddToggle("auto_ship_repair",{
    Text="Auto Repair",
    Description="Automatically holds and releases the ship repair mini-game in its green zone",
    Default=false,
    Keybind=true,
    Column=1,
    Callback=function(value)
        S.autoRepair=value
        if value then pcall(function() Window:Set("auto_fish",false) end) end
        if not value then pcall(mouse1release) end
        notify(value and "Auto Repair ON!" or "Auto Repair OFF!","laced.club",2)
    end
})

mainTab:AddSection("Dungeon",{Column=2})
mainTab:AddToggle("dungeon_enabled",{
    Text="Enable Dungeon",
    Description="Master switch for the Second Sea dungeon automation",
    Default=false,Keybind=true,Column=2,
    Callback=function(value)
        S.dungeonEnabled=value
        notify(value and "Dungeon Farm ON!" or "Dungeon Farm OFF!","laced.club",2)
    end
})
mainTab:AddToggle("dungeon_auto_door",{
    Text="Smart Door Path",
    Description="Moves to the exit teleporter when the current island is clear",
    Default=true,Column=2,
    Callback=function(value) S.dungeonAutoDoor=value end
})
mainTab:AddToggle("dungeon_destroy_vents",{
    Text="Destroy Vents First",
    Description="Prioritizes vents, shrines, rocks, and dungeon props",
    Default=true,Column=2,
    Callback=function(value) S.dungeonDestroyObj=value end
})
mainTab:AddToggle("dungeon_vent_skills",{
    Text="Skills on Vents Z/X/C/V",
    Description="Uses equipped-tool skills against dungeon objectives",
    Default=true,Column=2,
    Callback=function(value) S.dungeonUseMoves=value end
})

local BOSS_OPTIONS={"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard","Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order","Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
local MATERIAL_OPTIONS={"Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail","Radioactive Material","Ectoplasm","Mystic Droplet","Vampire Fang","Demonic Wisp","Conjured Cocoa","Dragon Scale","Gunpowder","Mini Tusk"}
local SEA_EVENT_OPTIONS={"Shark","Terrorshark","Piranha","Fish Crew Member","Haunted Crew Member"}

automationTab:AddSection("Boss and Materials",{Column=1})
automationTab:AddDropdown("boss_target",{
    Text="Boss",Options=BOSS_OPTIONS,Default=BOSS_OPTIONS[1],MaxVisible=8,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedBoss=v end end
})
automationTab:AddToggle("auto_boss_farm",{
    Text="Auto Farm Boss",Description="Tweens to and farms the selected spawned boss",Default=false,Column=1,
    Callback=function(v)
        S.autoBossFarm=v
        if v then Window:Set("auto_material_farm",false) end
    end
})
automationTab:AddDropdown("material_target",{
    Text="Material",Options=MATERIAL_OPTIONS,Default=MATERIAL_OPTIONS[1],MaxVisible=7,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedMaterial=v end end
})
automationTab:AddToggle("auto_material_farm",{
    Text="Auto Farm Material",Description="Farms enemies that drop the selected material",Default=false,Column=1,
    Callback=function(v)
        S.autoMaterialFarm=v
        if v then Window:Set("auto_boss_farm",false) end
    end
})

automationTab:AddSection("Automatic Stats",{Column=2})
automationTab:AddSlider("stat_amount",{
    Text="Points Per Upgrade",Min=1,Max=1000,Step=1,Default=10,Integer=true,Column=2,
    Callback=function(v) S.statAmount=math.max(1,math.floor(tonumber(v) or 10)) end
})
for _,entry in ipairs({{"stat_melee","Melee","autoStatMelee"},{"stat_defense","Defense","autoStatDefense"},{"stat_sword","Sword","autoStatSword"},{"stat_gun","Gun","autoStatGun"},{"stat_fruit","Blox Fruit","autoStatFruit"}}) do
    local controlId=entry[1]
    local label=entry[2]
    local stateKey=entry[3]
    automationTab:AddToggle(controlId,{
        Text="Auto "..label,Default=false,Column=2,
        Callback=function(v) S[stateKey]=v end
    })
end

automationTab:AddSection("Sea Events",{Column=1})
automationTab:AddDropdown("sea_event_target",{
    Text="Sea Target",Options=SEA_EVENT_OPTIONS,Default=SEA_EVENT_OPTIONS[1],MaxVisible=5,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedSeaEvent=v end end
})
automationTab:AddToggle("auto_sea_event",{
    Text="Auto Farm Sea Target",Description="Tweens to and attacks the selected spawned sea enemy",Default=false,Column=1,
    Callback=function(v) S.autoSeaEvent=v end
})

miscTab:AddSection("Mirage",{Column=2})
miscTab:AddToggle("mirage_esp",{
    Text="Mirage ESP",Description="Shows the Mirage Island location",Default=false,Column=2,
    Callback=function(v) S.mirageEsp=v; if not v then clearMirageEsp() end end
})
miscTab:AddToggle("auto_mirage_tween",{
    Text="Tween to Mirage",Description="Tweens above Mirage Island when it exists",Default=false,Column=2,
    Callback=function(v) S.autoMirageTween=v end
})
miscTab:AddToggle("auto_mirage_gear",{
    Text="Collect Mirage Gear",Description="Finds and tweens to the visible Mirage gear",Default=false,Column=2,
    Callback=function(v) S.autoMirageGear=v end
})

miscTab:AddSection("World Status",{Column=2})
miscTab:AddButton("check_events",{Text="Check Event Islands",Column=2,Callback=function() showEventStatus() end})
miscTab:AddButton("check_bosses",{Text="Check Important Bosses",Column=2,Callback=function() showBossStatus() end})
miscTab:AddButton("check_swords",{Text="Check Legendary Sword Dealer",Column=2,Callback=function() showLegendarySwordStatus() end})

task.spawn(function()
    task.wait(0.2)
    Window.Indicator:SetVisible(false)
    Window.Config.IndicatorEnabled = false
end)

mainTab:AddSection("Farming", { Column = 1 })

mainTab:AddToggle("auto_farm_nearest", {
    Text="Auto Farm Nearest", Description="Farms the nearest enemy (load chests/enemies first!)",
    Default=false, Keybind=true, Column=1,
    Callback=function(v) S.autoFarmNearest=v; notify(v and "Auto Farm Nearest ON!" or "Auto Farm Nearest OFF!","laced.club",2) end
})

mainTab:AddToggle("remote_mode", {
    Text="remotemode(crashable)", Description="Instead of teleporting and clicking, fires RegisterAttack + RegisterHit on all enemies within 60 studs. ONLY WORKS ON MATCHA PRO.",
    Default=false, Column=1,
    Callback=function(v)
        S.remoteMode=v
        notify(v and "Remote Mode ON! (RegisterHit aura)" or "Remote Mode OFF! (back to click farm)","laced.club",2)
    end
})

mainTab:AddToggle("auto_farm_chest", {
    Text="Auto Farm Chest", Description="Automatically farms chests (load them in first!)",
    Default=false, Column=1,
    Callback=function(v) S.autoFarming=v; S.handledChests={}; if v then S.chestIndex=1 end; notify(v and "Auto Farm Chest ON!" or "Auto Farm Chest OFF!","laced.club",2) end
})

otherTab:AddPriorityList("chest_priority", {
    Text="Chest Priority",
    Description="Reorder chest types from highest to lowest priority",
    Options={"Diamond","Gold","Silver"},
    Default={"Diamond","Gold","Silver"},
    MaxVisible=3,
    Column=1,
    Callback=function(order)
        if type(order)~="table" then return end
        local nextOrder={}
        for _,chestType in ipairs(order) do
            if chestType=="Diamond" or chestType=="Gold" or chestType=="Silver" then
                table.insert(nextOrder,chestType)
            end
        end
        if #nextOrder==3 then S.chestPriority=nextOrder end
    end
})

mainTab:AddToggle("auto_farm_fruits", {
    Text="Auto Farm Fruits", Description="Tweens to the nearest fruit and farms it",
    Default=false, Column=1,
    Callback=function(v)
        S.autoFruits=v
        if not v then S.fruitPriorityActive=false end
        notify(v and "Auto Farm Fruits ON! (interrupts only when fruit is found)" or "Auto Farm Fruits OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_dino_bone", {
    Text="Auto DinoBone", Description="Teleports to every Workspace.DinoBone until it disappears",
    Default=false, Column=1,
    Callback=function(v)
        S.autoDinoBone=v
        notify(v and "Auto DinoBone ON!" or "Auto DinoBone OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_race_ability",{
    Text="Auto Race Ability",Description="Keeps sending the race ability activation remote",Default=false,Column=1,
    Callback=function(v) S.autoRaceAbility=v end
})

mainTab:AddSection("NPC Farm", { Column = 1 })

mainTab:AddToggle("auto_npc_farm", {
    Text="Auto NPC Farm", Description="Farms NPCs on the selected island",
    Default=false, Column=1,
    Callback=function(v) S.autoNpcFarm=v; notify(v and "Auto NPC Farm ON!" or "Auto NPC Farm OFF!","laced.club",2) end
})

mainTab:AddDropdown("npc_island", {
    Text="NPC Island", Description="Select which island to farm NPCs on",
    Options=islandNames, Default=islandNames[1], MaxVisible=6, Column=1,
    Callback=function(v)
        for i, isle in pairs(islandList) do
            if isle.name == v then S.selectedIsland=i; break end
        end
        notify("Island: "..v,"laced.club",1)
    end
})

mainTab:AddToggle("auto_farm_level", {
    Text="Auto Farm Level", Description="Farms mobs based on your current level (quest giver must be loaded!)",
    Default=false, Column=1,
    Callback=function(v)
        S.autoFarmLevel=v
        if v then pcall(function() AFL.lastLevel=afl_readLevel() or 0 end) end
        notify(v and "Auto Farm Level ON!" or "Auto Farm Level OFF!","laced.club",2)
    end
})

otherTab:AddSection("Custom NPC Offset", { Column = 2 })

otherTab:AddToggle("custom_offset", {
    Text="Custom NPC Offset", Description="Use custom XYZ offset when positioning on NPCs",
    Default=false, Column=2,
    Callback=function(v)
        S.customOffset=v
        notify(v and "Custom Offset ON!" or "Custom Offset OFF!","laced.club",2)
    end
})

otherTab:AddSlider("offset_x", {
    Text="Offset X", Description="X offset from enemy position",
    Min=-100, Max=100, Default=0, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetX=v end
})

otherTab:AddSlider("offset_y", {
    Text="Offset Y", Description="Y offset from enemy position",
    Min=-100, Max=100, Default=23, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetY=v end
})

otherTab:AddSlider("offset_z", {
    Text="Offset Z", Description="Z offset from enemy position",
    Min=-100, Max=100, Default=0, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetZ=v end
})

mainTab:AddSection("Weapon Selection", { Column = 2 })

local meleeWeaponToggle=nil
local swordWeaponToggle=nil

meleeWeaponToggle=mainTab:AddToggle("weapon_melee", {
    Text="Melee", Description="Use inventory slot 1 for farming",
    Default=true, Column=2,
    Callback=function(v)
        if v then
            S.weaponSlot=1
            if swordWeaponToggle then
                pcall(function() swordWeaponToggle:SetValue(false) end)
            end
        end
    end
})

swordWeaponToggle=mainTab:AddToggle("weapon_sword", {
    Text="Sword", Description="Use inventory slot 3 for farming",
    Default=false, Column=2,
    Callback=function(v)
        if v then
            S.weaponSlot=3
            if meleeWeaponToggle then
                pcall(function() meleeWeaponToggle:SetValue(false) end)
            end
        end
    end
})

miscTab:AddSection("ESP", { Column = 1 })

miscTab:AddToggle("fruit_esp", {
    Text="Fruit ESP", Description="Shows drawing ESP with the fruit name and nearest island",
    Default=false, Column=1,
    Callback=function(v)
        S.fruitEsp=v; S.chamEsp=v
        if v then buildEspLabels(); buildChamBoxes() else clearEspLabels(); clearChamBoxes() end
        notify(v and "Fruit ESP On!" or "Fruit ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("chest_esp", {
    Text="Chest ESP", Description="Shows a text label on every spawned chest",
    Default=false, Column=1,
    Callback=function(v)
        S.chestEsp=v
        if v then buildChestEspLabels() else clearChestEspLabels() end
        notify(v and "Chest ESP On!" or "Chest ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("berry_esp", {
    Text="Berry Esp", Description="Shows map berries at 60 Hz with an optimized one-second rescan",
    Default=false, Column=1,
    Callback=function(v)
        S.berryEsp=v
        if v then buildBerryEspLabels() else clearBerryEspLabels() end
        notify(v and "Berry Esp On!" or "Berry Esp Off!","laced.club",2)
    end
})

miscTab:AddToggle("boat_esp", {
    Text="Boat ESP", Description="Draws a full 3D box around each on-screen boat",
    Default=false, Column=1,
    Callback=function(v)
        S.boatEsp=v
        if v then buildBoatEsp() else clearBoatEsp() end
        notify(v and "Boat ESP On!" or "Boat ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("flower_esp", {
    Text="Flower Esp", Description="Shows a label and a 3d box around all flowers, 2ND SEA",
    Default=false, Column=1,
    Callback=function(v)
        S.flowerEsp=v
        if v then buildFlowerEsp() else clearFlowerEsp() end
        notify(v and "Flower Esp On!" or "Flower Esp Off!","laced.club",2)
    end
})

miscTab:AddSection("Combat", { Column = 1 })

miscTab:AddToggle("big_hitbox", {
    Text="Big Hitbox", Description="Expands enemy HumanoidRootPart size for easier hits",
    Default=false, Column=1,
    Callback=function(v) S.bigHitbox=v; notify(v and "Big Hitbox ON!" or "Big Hitbox OFF!","laced.club",2) end
})

miscTab:AddToggle("pull_enemies", {
    Text="Pull Enemies", Description="Pulls all enemies to one point under you",
    Default=false, Column=1,
    Callback=function(v) S.pullEnemies=v; notify(v and "Pull Enemies ON!" or "Pull Enemies OFF!","laced.club",2) end
})

miscTab:AddToggle("buddha_pull", {
    Text="Buddha Pull", Description="Pulls all enemies to X=40 under you",
    Default=false, Column=1,
    Callback=function(v) S.buddhaPull=v; notify(v and "Buddha Pull ON!" or "Buddha Pull OFF!","laced.club",2) end
})

miscTab:AddToggle("auto_ken", {
    Text="Auto Ken", Description="Automatically keeps Ken (Observation Haki) active",
    Default=false, Keybind=true, Column=1,
    Callback=function(v) S.autoKen=v; notify(v and "Auto Ken ON!" or "Auto Ken OFF!","laced.club",2) end
})

miscTab:AddToggle("auto_haki", {
    Text="Auto Haki", Description="Automatically keeps Armament Haki active",
    Default=false, Column=1,
    Callback=function(v) S.autoHaki=v; notify(v and "Auto Haki ON!" or "Auto Haki OFF!","laced.club",2) end
})

miscTab:AddToggle("freeze_pos", {
    Text="Freeze Position", Description="Locks your character in place",
    Default=false, Column=1,
    Callback=function(v)
        S.freezePos=v
        if v then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then S.freezePosition=hrp.Position end
        else
            S.freezePosition=nil
        end
        notify(v and "Freeze ON!" or "Freeze OFF!","laced.club",2)
    end
})

miscTab:AddToggle("freeze_enemies", {
    Text="Freeze Enemies", Description="Locks all enemies in place (auto-catches new spawns)",
    Default=false, Column=1,
    Callback=function(v)
        S.freezeEnemies=v
        S.frozenEnemies={}
        if v then
            local folder=game.Workspace:FindFirstChild("Enemies")
            if folder then
                for _, model in pairs(folder:GetChildren()) do
                    if model:IsA("Model") then
                        local hrp=model:FindFirstChild("HumanoidRootPart")
                        if hrp then S.frozenEnemies[model]=hrp.Position end
                    end
                end
            end
        end
        notify(v and "Freeze Enemies ON!" or "Freeze Enemies OFF!","laced.club",2)
    end
})

miscTab:AddToggle("tween_ember", {
    Text="Auto Tween Dragon Ember", Description="Quickly tweens to Workspace EmberTemplate objects",
    Default=false, Column=1,
    Callback=function(v) S.tweenEmber=v; notify(v and "Auto Tween Dragon Ember ON!" or "Auto Tween Dragon Ember OFF!","laced.club",2) end
})

miscTab:AddToggle("teleport_ember", {
    Text="Auto Tp Azure Embers", Description="Auto tps to azure embers",
    Default=false, Column=1,
    Callback=function(v) S.teleportEmber=v; notify(v and "Auto Tp Azure Embers ON!" or "Auto Tp Azure Embers OFF!","laced.club",2) end
})

miscTab:AddToggle("teleport_kitsune", {
    Text="Goto Kitsune Island", Description="Tweens to Kitsune Island shrine (2s scan)",
    Default=false, Column=1,
    Callback=function(v) S.teleportKitsune=v; notify(v and "Goto Kitsune Island ON!" or "Goto Kitsune Island OFF!","laced.club",2) end
})

miscTab:AddSection("Sea", { Column = 2 })

local boatSeatOptions={"No boats found"}
local boatSeatByLabel={}
local lastBoatSeatSignature=""

local function findBoatVehicleSeat(boat)
    if not boat then return nil end
    local okDirect,directSeat=pcall(function() return boat:FindFirstChildOfClass("VehicleSeat") end)
    if okDirect and directSeat then return directSeat end
    local okDescendants,descendants=pcall(function() return boat:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okClass,className=pcall(function() return object.ClassName end)
            if okClass and className=="VehicleSeat" then return object end
        end
    end
    return nil
end

local function refreshBoatSeatList()
    local entries={}
    local boats=game.Workspace:FindFirstChild("Boats")
    local okChildren,children=pcall(function() return boats and boats:GetChildren() end)
    if okChildren and children then
        for _,boat in pairs(children) do
            local seat=findBoatVehicleSeat(boat)
            if seat then
                local okName,name=pcall(function() return boat.Name end)
                name=(okName and type(name)=="string" and name~="") and name or "Boat"
                local okAddress,address=pcall(function() return seat.Address end)
                local key=(okAddress and address and address~=0) and tostring(address) or tostring(seat)
                table.insert(entries,{name=name,seat=seat,key=key})
            end
        end
    end

    table.sort(entries,function(a,b)
        if a.name==b.name then return a.key<b.key end
        return a.name<b.name
    end)

    local totals={}
    for _,entry in ipairs(entries) do totals[entry.name]=(totals[entry.name] or 0)+1 end
    local used={}
    local nextLabels={}
    local nextMap={}
    local selectedLabel=nil
    for _,entry in ipairs(entries) do
        used[entry.name]=(used[entry.name] or 0)+1
        local label=entry.name
        if totals[entry.name]>1 then label=label.." #"..tostring(used[entry.name]) end
        table.insert(nextLabels,label)
        nextMap[label]=entry.seat
        if entry.seat==S.selectedBoatSeat then selectedLabel=label end
    end

    if #nextLabels==0 then
        nextLabels={"No boats found"}
        nextMap={}
    end

    boatSeatByLabel=nextMap
    local signature=table.concat(nextLabels,"|")
    if signature~=lastBoatSeatSignature then
        for index=#boatSeatOptions,1,-1 do boatSeatOptions[index]=nil end
        for _,label in ipairs(nextLabels) do table.insert(boatSeatOptions,label) end
        lastBoatSeatSignature=signature
    end

    if not selectedLabel and S.selectedBoatSeatLabel and nextMap[S.selectedBoatSeatLabel] then
        selectedLabel=S.selectedBoatSeatLabel
    end
    if not selectedLabel then selectedLabel=nextLabels[1] end
    local selectedSeat=nextMap[selectedLabel]
    if selectedLabel~=S.selectedBoatSeatLabel or selectedSeat~=S.selectedBoatSeat then
        Window:Set("boat_seat_target",selectedLabel)
    end
end

miscTab:AddDropdown("boat_seat_target", {
    Text="Boat Seat", Description="Select a spawned boat seat to travel to",
    Options=boatSeatOptions, Default=boatSeatOptions[1], MaxVisible=8, Column=2,
    Callback=function(value)
        S.selectedBoatSeatLabel=value
        S.selectedBoatSeat=boatSeatByLabel[value]
    end
})

miscTab:AddToggle("auto_boat_seat", {
    Text="Auto Go To Seat", Description="Teleports to the selected seat until you are sitting in it",
    Default=false, Column=2,
    Callback=function(v)
        S.autoBoatSeat=v
        if v then refreshBoatSeatList() end
        notify(v and "Auto Boat Seat ON!" or "Auto Boat Seat OFF!","laced.club",2)
    end
})

miscTab:AddButton("refresh_boat_seats", {
    Text="Refresh Boat Seats", Description="Rescan Workspace.Boats now", Column=2,
    Callback=function() refreshBoatSeatList() end
})

miscTab:AddToggle("boat_fly", {
    Text="Boat Fly", Description="Fly your boat with WASD, Space, Shift",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.boatFlyEnabled=v
        if not v then S.boatTweening=false end
        notify(v and "Boat Fly ON!" or "Boat Fly OFF!","laced.club",2)
    end
})

miscTab:AddSlider("boat_fly_speed", {
    Text="Fly Speed", Description="Speed of boat fly (default 5)",
    Min=1, Max=20, Step=1, Default=5, Integer=true, Column=2,
    Callback=function(v) S.boatFlySpeed=v end
})

miscTab:AddDropdown("danger_level", {
    Text="Danger Level", Description="Fly boat to selected danger level",
    Options=dangerLevelNames, Default=dangerLevelNames[1], MaxVisible=6, Column=2,
    Callback=function(v)
        for _, d in pairs(dangerLevels) do
            if d.name==v then
                S.boatTweening=false; task.wait(0.05)
                notify("Going to "..d.name.."...","laced.club",2)
                task.spawn(function() boatTweenTo(d.pos) end)
                break
            end
        end
    end
})

miscTab:AddButton("stop_boat", {
    Text="Stop", Description="Stop current boat tween", Column=2,
    Callback=function() S.boatTweening=false; notify("Stopped!","laced.club",2) end
})

local function isUsingSelectedBoatSeat(seat,char,humanoid,hrp)
    local okOccupant,occupant=pcall(function() return seat.Occupant end)
    if okOccupant and occupant then
        if occupant==humanoid then return true end
        local okParent,parent=pcall(function() return occupant.Parent end)
        return okParent and parent==char
    end

    local okSeatPart,seatPart=pcall(function() return humanoid and humanoid.SeatPart end)
    if okSeatPart and seatPart then return seatPart==seat end
    if okOccupant or okSeatPart then return false end

    local okPositions,seatPos,playerPos=pcall(function() return seat.Position,hrp.Position end)
    if not okPositions or not seatPos or not playerPos then return false end
    local dx=seatPos.X-playerPos.X
    local dy=seatPos.Y-playerPos.Y
    local dz=seatPos.Z-playerPos.Z
    return dx*dx+dy*dy+dz*dz<=25
end

task.spawn(function()
    refreshBoatSeatList()
    while true do
        task.wait(1)
        refreshBoatSeatList()
    end
end)

local dinoBoneTarget=nil

local function getDinoBonePart(object)
    if not object or not object.Parent then return nil end
    if object:IsA("BasePart") then return object end
    local part=object:FindFirstChild("HumanoidRootPart")
    if not part and object:IsA("Model") then part=object.PrimaryPart end
    return part or object:FindFirstChildWhichIsA("BasePart")
end

local function findNearestDinoBone(playerRoot)
    local nearest=nil
    local nearestDistance=math.huge
    local playerPos=playerRoot.Position
    for _,object in pairs(game.Workspace:GetChildren()) do
        if object.Name=="DinoBone" then
            local part=getDinoBonePart(object)
            if part then
                local partPos=part.Position
                local dx=partPos.X-playerPos.X
                local dy=partPos.Y-playerPos.Y
                local dz=partPos.Z-playerPos.Z
                local distanceSquared=dx*dx+dy*dy+dz*dz
                if distanceSquared<nearestDistance then
                    nearestDistance=distanceSquared
                    nearest=object
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    while true do
        task.wait()
        if S.autoDinoBone then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bonePart=getDinoBonePart(dinoBoneTarget)
                if not bonePart then
                    dinoBoneTarget=findNearestDinoBone(hrp)
                    bonePart=getDinoBonePart(dinoBoneTarget)
                end
                if bonePart then
                    local bonePos=bonePart.Position
                    hrp.Position=Vector3.new(bonePos.X,bonePos.Y,bonePos.Z)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end
            end
        else
            dinoBoneTarget=nil
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoBoatSeat then
            local seat=S.selectedBoatSeat
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local humanoid=char and char:FindFirstChildOfClass("Humanoid") or nil
            local okSeat,seatParent,seatPos=pcall(function()
                return seat and seat.Parent,seat and seat.Position
            end)
            if seat and char and hrp and humanoid and okSeat and seatParent and seatPos
                and not isUsingSelectedBoatSeat(seat,char,humanoid,hrp) then
                pcall(function()
                    hrp.Position=Vector3.new(seatPos.X,seatPos.Y+2,seatPos.Z)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end
        end
        task.wait()
    end
end)

mainTab:AddSection("Games", { Column = 2 })

mainTab:AddToggle("auto_raid", {
    Text="Auto Raid", Description="Tracks each raid island, travels 100 studs above it, then farms its enemies",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.autoRaid=v
        S.raidTweenActive=false
        S.raidDetected=false
        S.raidLastIslandNum=0
        S.raidLastIslandKey=nil
        S.raidMapKey=nil
        S.raidMoveGeneration=S.raidMoveGeneration+1
        notify(v and "Auto Raid ON!" or "Auto Raid OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_mastery", {
    Text="Auto Mastery", Description="Goto ChocolateIsland And use buddha transformation",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.autoMastery=v
        notify(v and "Auto Mastery ON!" or "Auto Mastery OFF!","laced.club",2)
    end
})

otherTab:AddSection("Custom Pull", { Column = 1 })

otherTab:AddToggle("custom_pull", {
    Text="Custom Pull", Description="Pulls all enemies to a custom XYZ offset relative to you",
    Default=false, Column=1,
    Callback=function(v) S.customPull=v; notify(v and "Custom Pull ON!" or "Custom Pull OFF!","laced.club",2) end
})

otherTab:AddSlider("custom_pull_x", {
    Text="Pull X Offset", Description="X offset from your position",
    Min=-100, Max=100, Step=1, Default=0, Integer=true, Column=1,
    Callback=function(v) S.customPullX=v end
})

otherTab:AddSlider("custom_pull_y", {
    Text="Pull Y Offset", Description="Y offset from your position",
    Min=-100, Max=100, Step=1, Default=-10, Integer=true, Column=1,
    Callback=function(v) S.customPullY=v end
})

otherTab:AddSlider("custom_pull_z", {
    Text="Pull Z Offset", Description="Z offset from your position",
    Min=-100, Max=100, Step=1, Default=0, Integer=true, Column=1,
    Callback=function(v) S.customPullZ=v end
})

otherTab:AddSection("Tween Settings", { Column = 1 })

local tweenSettingsPopup=Window:CreatePopup({
    Title="Tween Slider Settings",
    Width=520,
    Height=500,
    Columns=2,
    Divider=true
})

otherTab:AddButton("open_tween_settings", {
    Text="Tween Sliders", Description="Open every movement tween speed slider",
    Column=1,
    Callback=function() tweenSettingsPopup:Show() end
})

tweenSettingsPopup:AddSection("Farming Tweens",{Column=1})
tweenSettingsPopup:AddSlider("tween_farm_speed",{
    Text="Farm Tween Speed", Min=50, Max=2000, Step=50, Default=S.FARM_SPEED,
    Integer=true, Column=1, Callback=function(v) S.FARM_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_chest_speed",{
    Text="Chest Tween Speed", Min=50, Max=2000, Step=50, Default=S.CHEST_SPEED,
    Integer=true, Column=1, Callback=function(v) S.CHEST_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_fruit_speed",{
    Text="Fruit Tween Speed", Min=50, Max=2000, Step=50, Default=S.FRUIT_SPEED,
    Integer=true, Column=1, Callback=function(v) S.FRUIT_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_npc_speed",{
    Text="NPC Travel Speed", Min=50, Max=2000, Step=50, Default=S.NPC_TWEEN_SPEED,
    Integer=true, Column=1, Callback=function(v) S.NPC_TWEEN_SPEED=v end
})

tweenSettingsPopup:AddSection("World Tweens",{Column=2})
tweenSettingsPopup:AddSlider("tween_level_speed",{
    Text="Level Tween Speed", Min=50, Max=2000, Step=50, Default=AFL.tweenSpeed,
    Integer=true, Column=2, Callback=function(v) AFL.tweenSpeed=v end
})
tweenSettingsPopup:AddSlider("tween_raid_speed",{
    Text="Raid Tween Speed", Min=50, Max=2000, Step=50, Default=S.RAID_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.RAID_TWEEN_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_mastery_speed",{
    Text="Mastery Tween Speed", Min=50, Max=2000, Step=50, Default=S.MASTERY_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.MASTERY_TWEEN_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_boat_speed",{
    Text="Boat Tween Speed", Min=50, Max=2000, Step=50, Default=S.BOAT_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.BOAT_TWEEN_SPEED=v end
})

tweenSettingsPopup:AddButton("close_tween_settings",{
    Text="Close", Column=2, Callback=function() tweenSettingsPopup:Hide() end
})

pvpTab:AddSection("PvP", { Column = 1 })

pvpTab:AddToggle("void_pull", {
    Text="Escape (risky)", Description="Sends you to Y=100000",
    Default=false, Column=1,
    Callback=function(v) S.voidPull=v; notify(v and "Go Up ON!" or "Go Up OFF!","laced.club",2) end
})

pvpTab:AddToggle("sky_pull", {
    Text="Go Back Down (risky)", Description="Brings you back to Y=100",
    Default=false, Column=1,
    Callback=function(v) S.skyPull=v; notify(v and "Go Down ON!" or "Go Down OFF!","laced.club",2) end
})

pvpTab:AddToggle("pvp_aura", {
    Text="PvP Aura", Description="Fires RegisterHit on the nearest player. MATCHA PRO ONLY!",
    Default=false, Keybind=true, Column=1,
    Callback=function(v)
        _pvpAuraEnabled = v
        notify(v and "PvP Aura ON!" or "PvP Aura OFF!", "laced.club", 2)
    end
})
pvpTab:AddToggle("pvp_aura_alt_part", {
    Text="Use ModelHitbox", Description="Toggle between Head and ModelHitbox hit part.",
    Default=false, Column=1,
    Callback=function(v)
        _pvpAuraAltPart = v
        notify("Hit part: " .. (v and "ModelHitbox" or "Head"), "laced.club", 2)
    end
})
pvpTab:AddSlider("pvp_aura_range", {
    Text="PvP Range", Description="Max distance to target players (studs)",
    Min=10, Max=300, Default=100, Integer=true, Column=1,
    Callback=function(v) _pvpAuraMaxDist = v end
})

pvpTab:AddSection("Glitches", { Column = 2 })

pvpTab:AddToggle("sanguine_z_boost", {
    Text="Sanguine Z Boost", Description="Boosts current velocity during Sanguine Art Z",
    Default=false, Column=2,
    Callback=function(v) S.sanguineZBoost=v end
})

pvpTab:AddToggle("dragon_talon_z_boost", {
    Text="Dragon Talon Z Boost", Description="Boosts current velocity after pressing Z",
    Default=false, Column=2,
    Callback=function(v) S.dragonTalonZBoost=v end
})

pvpTab:AddToggle("yama_z_boost", {
    Text="Yama Z Boost", Description="Boosts current velocity after pressing Z",
    Default=false, Column=2,
    Callback=function(v) S.yamaZBoost=v end
})

pvpTab:AddToggle("tushita_x_boost", {
    Text="Tushita X Boost", Description="Boosts current velocity after pressing X",
    Default=false, Column=2,
    Callback=function(v) S.tushitaXBoost=v end
})

pvpTab:AddToggle("fox_lamp_x_boost", {
    Text="Fox Lamp X Boost", Description="Boosts current velocity after pressing X",
    Default=false, Column=2,
    Callback=function(v) S.foxLampXBoost=v end
})

pvpTab:AddToggle("soul_guitar_m1_boost", {
    Text="Soul Guitar M1", Description="Boosts after Q + M1 within 0.5 seconds",
    Default=false, Column=2,
    Callback=function(v) S.soulGuitarM1Boost=v end
})

pvpTab:AddToggle("diamond_m1_boost", {
    Text="Diamond M1", Description="Sanguine-style boost when M1 is released with Diamond-Diamond equipped",
    Default=false, Column=2,
    Callback=function(v) S.diamondM1Boost=v end
})

pvpTab:AddToggle("flame_f_boost", {
    Text="Flame F Boost", Description="Boosts current velocity after pressing F",
    Default=false, Column=2,
    Callback=function(v) S.flameFBoost=v end
})

pvpTab:AddSection("PvP misc", { Column = 1 })

pvpTab:AddToggle("r_to_x", {
    Text="R to X", Description="Automatically taps X when you press R",
    Default=false, Column=1,
    Callback=function(v) S.rToX=v end
})

pvpTab:AddToggle("r_to_x_then_z", {
    Text="R to X then Z", Description="Taps X when you press R, waits 25ms, then taps Z",
    Default=false, Column=1,
    Callback=function(v) S.rToXThenZ=v end
})

pvpTab:AddToggle("flame_r_to_c", {
    Text="Flame R to C", Description="FLAME, When u flashstep = flame C move",
    Default=false, Column=1,
    Callback=function(v) S.flameRToC=v end
})

local glitchSettingsPopup=Window:CreatePopup({
    Title="Glitch Slider Settings",
    Width=520,
    Height=680,
    Columns=2,
    Divider=true
})

pvpTab:AddButton("open_glitch_settings", {
    Text="Adjust Glitch Sliders", Description="Open individual settings for every boost glitch",
    Column=2,
    Callback=function() glitchSettingsPopup:Show() end
})

local glitchSliderProfiles={
    {key="sanguine",label="Sanguine Z",column=1,color=Color3.fromRGB(220,45,65)},
    {key="dragonTalon",label="Dragon Talon Z",column=1,color=Color3.fromRGB(255,125,25)},
    {key="yama",label="Yama Z",column=1,color=Color3.fromRGB(160,75,255)},
    {key="tushita",label="Tushita X",column=1,color=Color3.fromRGB(40,190,255)},
    {key="foxLamp",label="Fox Lamp X",column=2,color=Color3.fromRGB(255,80,190)},
    {key="soulGuitar",label="Soul Guitar M1",column=2,color=Color3.fromRGB(70,220,125)},
    {key="diamond",label="Diamond M1",column=2,color=Color3.fromRGB(70,220,255)},
    {key="flame",label="Flame F",column=2,color=Color3.fromRGB(255,205,40)},
}

for _,entry in ipairs(glitchSliderProfiles) do
    local profileKey=entry.key
    local profile=S.glitchSettings[profileKey]
    local column=entry.column
    glitchSettingsPopup:AddSection(entry.label,{Column=column})
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_speed",{
        Text="Speed", Min=50, Max=1000, Step=50, Default=profile.speed,
        Color=entry.color, Integer=true, Column=column,
        Callback=function(v) profile.speed=v end
    })
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_delay",{
        Text="Start Delay", Min=0.01, Max=1, Step=0.01, Default=profile.delay,
        Color=entry.color, Decimals=2, Integer=false, Column=column,
        Callback=function(v) profile.delay=v end
    })
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_duration",{
        Text="Duration", Min=0.01, Max=1, Step=0.01, Default=profile.duration,
        Color=entry.color, Decimals=2, Integer=false, Column=column,
        Callback=function(v) profile.duration=v end
    })
end

glitchSettingsPopup:AddButton("close_glitch_settings",{
    Text="Close", Column=2,
    Callback=function() glitchSettingsPopup:Hide() end
})

function getBoat()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local boatsFolder=game.Workspace:FindFirstChild("Boats")
    if not boatsFolder then return nil end
    for _, b in pairs(boatsFolder:GetChildren()) do
        if b:IsA("Model") then
            local seat=b:FindFirstChildOfClass("VehicleSeat")
            if seat then
                local dx=seat.Position.X-hrp.Position.X
                local dy=seat.Position.Y-hrp.Position.Y
                local dz=seat.Position.Z-hrp.Position.Z
                if math.sqrt(dx*dx+dy*dy+dz*dz)<20 then return b end
            end
        end
    end
    return nil
end

function getBoatCameraVectors()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0,0,-1), Vector3.new(1,0,0) end
    local cp=game.Workspace.CurrentCamera.Position
    local hp=hrp.Position
    local fx=hp.X-cp.X; local fz=hp.Z-cp.Z
    local fl=math.sqrt(fx*fx+fz*fz)
    if fl>0.001 then fx=fx/fl; fz=fz/fl else fx=0; fz=-1 end
    return Vector3.new(fx,0,fz), Vector3.new(-fz,0,fx)
end

function boatTweenTo(targetPos)
    S.currentBoat = getBoat()
    if not S.currentBoat then notify("No boat found!","Boat Fly",2); return end
    local primary=S.currentBoat.PrimaryPart
    if not primary then return end
    S.boatTweening=true
    primary.Position=Vector3.new(primary.Position.X, primary.Position.Y+50, primary.Position.Z)
    wait(0.1)
    local fixedY=primary.Position.Y
    local startX=primary.Position.X; local startZ=primary.Position.Z
    local dx=targetPos.X-startX; local dz=targetPos.Z-startZ
    local dist=math.sqrt(dx*dx+dz*dz)
    local duration=dist/S.BOAT_TWEEN_SPEED
    local t0=os.clock()
    while S.boatTweening do
        local alpha=math.min((os.clock()-t0)/duration,1)
        primary.Position=Vector3.new(startX+dx*alpha, fixedY, startZ+dz*alpha)
        primary.Velocity=Vector3.new(0,0,0)
        primary.AssemblyLinearVelocity=Vector3.new(0,0,0)
        if alpha>=1 then break end
        wait(0.01)
    end
    S.boatTweening=false; S.currentBoat=nil; S.boatTween=nil
    notify("Arrived!","Boat Fly",2)
end

task.spawn(function()
    while true do
        task.wait()
        if not S.boatFlyEnabled or S.boatTweening then continue end
        local boat=getBoat(); if not boat then continue end
        local primary=boat.PrimaryPart; if not primary then continue end
        local fwd, right=getBoatCameraVectors()
        local mx, my, mz=0,0,0
        if iskeypressed(0x57,0) then mx=mx+fwd.X*S.boatFlySpeed;   mz=mz+fwd.Z*S.boatFlySpeed   end
        if iskeypressed(0x53,0) then mx=mx-fwd.X*S.boatFlySpeed;   mz=mz-fwd.Z*S.boatFlySpeed   end
        if iskeypressed(0x44,0) then mx=mx+right.X*S.boatFlySpeed; mz=mz+right.Z*S.boatFlySpeed end
        if iskeypressed(0x41,0) then mx=mx-right.X*S.boatFlySpeed; mz=mz-right.Z*S.boatFlySpeed end
        if iskeypressed(0x58,0) then my=my+S.boatFlySpeed end
        if iskeypressed(0x10,0) then my=my-S.boatFlySpeed end
        primary.Velocity=Vector3.new(0,0,0)
        primary.AssemblyLinearVelocity=Vector3.new(0,0,0)
        primary.Position=Vector3.new(primary.Position.X+mx, primary.Position.Y+my, primary.Position.Z+mz)
    end
end)

function clearEspLabels()
    for _, entry in pairs(S.espLabels) do entry.label.Visible=false end
    S.espLabels={}
end

function clearChestEspLabels()
    for _,entry in pairs(S.chestEspLabels) do
        if entry and entry.label then entry.label.Visible=false end
    end
    S.chestEspLabels={}
end

function clearBerryEspLabels()
    for _,entry in pairs(S.berryEspLabels) do
        if entry and entry.label then entry.label.Visible=false end
    end
    S.berryEspLabels={}
end

function clearBoatEsp()
    for _,entry in pairs(S.boatEspEntries) do
        if entry and entry.label then entry.label.Visible=false end
        if entry and entry.lines then
            for _,line in pairs(entry.lines) do line.Visible=false end
        end
    end
    S.boatEspEntries={}
end

function clearFlowerEsp()
    for _,entry in pairs(S.flowerEspEntries) do
        if entry and entry.label then entry.label.Visible=false end
        if entry and entry.lines then
            for _,line in pairs(entry.lines) do line.Visible=false end
        end
    end
    S.flowerEspEntries={}
end

function clearChamBoxes()
    for _, entry in pairs(S.chamBoxes) do
        for _, line in pairs(entry.lines) do line.Visible=false end
    end
    S.chamBoxes={}
end

local BERRIES={
    {name="Green Toad Berry",   sphere="Sphere.011"},
    {name="Yellow Star Berry",  sphere="Sphere.022"},
    {name="Orange Berry",       sphere="Sphere.007"},
    {name="Red Cherry Berry",   sphere="Sphere.005"},
    {name="Purple Jelly Berry", sphere="Sphere.004"},
    {name="Pink Pig Berry",     sphere="Sphere.008"},
    {name="Blue Icicle Berry",  sphere="Sphere.018"},
    {name="White Cloud Berry",  sphere="Sphere.035"},
}

local BERRY_SPHERE_NAMES={}
for _,berry in pairs(BERRIES) do
    BERRY_SPHERE_NAMES[berry.sphere]=berry.name
end

function getSafeFruitPosition(candidate)
    if not candidate then return nil end
    local okParent, parent=pcall(function() return candidate.Parent end)
    if not okParent or not parent then return nil end
    local okPos, pos=pcall(function() return candidate.Position end)
    if okPos and pos and pos.X and pos.Y and pos.Z then return pos end
    return nil
end

function resolveFruitPart(root)
    if not root then return nil end

    local okClass, className=pcall(function() return root.ClassName end)
    if okClass and className=="Tool" then
        local okHandle, handle=pcall(function() return root:FindFirstChild("Handle") end)
        if okHandle and handle and getSafeFruitPosition(handle) then return handle end
        local okBasePart, basePart=pcall(function() return root:FindFirstChildOfClass("BasePart") end)
        if okBasePart and basePart and getSafeFruitPosition(basePart) then return basePart end
    end

    if getSafeFruitPosition(root) then return root end
    for _, childName in pairs({"Handle", "Fruit"}) do
        local okChild, child=pcall(function() return root:FindFirstChild(childName) end)
        if okChild and child then
            if getSafeFruitPosition(child) then return child end
            local okInner, inner=pcall(function() return child:FindFirstChild("Fruit") end)
            if okInner and inner and getSafeFruitPosition(inner) then return inner end
        end
    end
    local okDesc, descendants=pcall(function() return root:GetDescendants() end)
    if okDesc and descendants then
        for _, descendant in pairs(descendants) do
            if getSafeFruitPosition(descendant) then return descendant end
        end
    end
    return nil
end

function getFruitInstanceKey(part)
    local okAddress, address=pcall(function() return part.Address end)
    if okAddress and address and address~=0 then return "addr:"..tostring(address) end

    local pos=getSafeFruitPosition(part)
    if pos then
        return tostring(part)..":"..tostring(pos.X)..":"..tostring(pos.Y)..":"..tostring(pos.Z)
    end
    return tostring(part)
end

function getWorkspaceFruits()
    local fruits, seen={}, {}
    local okChildren, children=pcall(function() return game.Workspace:GetChildren() end)
    if not okChildren or not children then return fruits end
    local function addFruit(root, displayName)
        local part=resolveFruitPart(root)
        if not part then return end
        local partPos=getSafeFruitPosition(part)
        if not partPos then return end
        local key=getFruitInstanceKey(part)
        if seen[key] then return end

        for _, existing in pairs(fruits) do
            local existingPos=existing.position or getSafeFruitPosition(existing.part)
            if existingPos then
                local dx=partPos.X-existingPos.X
                local dy=partPos.Y-existingPos.Y
                local dz=partPos.Z-existingPos.Z
                if dx*dx+dy*dy+dz*dz<=9 then return end
            end
        end

        seen[key]=true
        table.insert(fruits, {part=part, position=partPos, name=displayName or "Spawned Fruit"})
    end
    for _, obj in pairs(children) do
        local okName, objName=pcall(function() return obj.Name end)
        objName=okName and objName or ""
        local lowerName=string.lower(objName)
        if string.match(lowerName, "fruit") then
            addFruit(obj, objName)
        end

        local okFolder, fruitFolder=pcall(function() return obj:FindFirstChild("Fruit") end)
        if okFolder and fruitFolder then
            local fruitName=(objName~="" and objName~="Fruit" and objName) or "Spawned Fruit"
            addFruit(fruitFolder, fruitName)
        end
    end
    return fruits
end

function buildChamBoxes()
    for _, entry in pairs(S.chamBoxCache) do
        for _, line in pairs(entry.lines) do line.Visible=false end
    end
    S.chamBoxes={}
    for _, fruit in pairs(getWorkspaceFruits()) do
        local fruitPart=fruit.part
        local key=getFruitInstanceKey(fruitPart)
        if not S.chamBoxCache[key] then
            local lines={}
            for i=1,4 do
                local l=Drawing.new("Line")
                l.Color=Color3.new(1,0.4,0); l.Thickness=2; l.Visible=false; l.ZIndex=9
                table.insert(lines,l)
            end
            S.chamBoxCache[key]={lines=lines, part=fruitPart}
        else
            S.chamBoxCache[key].part=fruitPart
        end
        table.insert(S.chamBoxes, S.chamBoxCache[key])
    end
end

function getFruitIslandName(position)
    if not position or type(islandList)~="table" then return "Unknown" end
    local closestName="Unknown"
    local closestDistanceSq=math.huge
    for _,island in pairs(islandList) do
        local islandPosition=island and island.pos or nil
        if islandPosition then
            local dx=position.X-islandPosition.X
            local dz=position.Z-islandPosition.Z
            local distanceSq=dx*dx+dz*dz
            if distanceSq<closestDistanceSq then
                closestDistanceSq=distanceSq
                closestName=island.name or "Unknown"
            end
        end
    end
    if closestDistanceSq>625000000 then return "Sea" end
    return closestName
end

function buildEspLabels()
    for _, entry in pairs(S.espLabelCache) do entry.label.Visible=false end
    S.espLabels={}
    for _, fruit in pairs(getWorkspaceFruits()) do
        local fruitPart, fruitName=fruit.part, fruit.name
        local fruitPosition=fruit.position or getSafeFruitPosition(fruitPart)
        local displayText=fruitName.." ["..getFruitIslandName(fruitPosition).."]"
        local key=getFruitInstanceKey(fruitPart)
        if not S.espLabelCache[key] then
            local label=Drawing.new("Text")
            label.Text=displayText; label.Position=Vector2.new(0,0)
            label.Color=Color3.new(0,1,0); label.Size=14; label.Outline=true
            label.Visible=false; label.ZIndex=10; label.Font=Drawing.Fonts.Monospace; label.Center=true
            S.espLabelCache[key]={label=label, part=fruitPart}
        else
            S.espLabelCache[key].label.Text=displayText
            S.espLabelCache[key].part=fruitPart
        end
        table.insert(S.espLabels, S.espLabelCache[key])
    end
end

local berryScanRunning=false
local BERRY_SCAN_BATCH=80
local BERRY_DRAW_DISTANCE=10000
local BERRY_DRAW_DISTANCE_SQ=BERRY_DRAW_DISTANCE*BERRY_DRAW_DISTANCE

local function isBerryWorldObject(object)
    local current=object
    for _=1,64 do
        if not current then return false end
        local okInfo,parent,className=pcall(function()
            return current.Parent,current.ClassName
        end)
        if not okInfo then return false end
        if className=="Tool" then return false end
        local okHumanoid,humanoid=pcall(function()
            return current:FindFirstChildOfClass("Humanoid")
        end)
        if okHumanoid and humanoid then return false end
        if parent==game.Workspace then return true end
        current=parent
    end
    return false
end

function buildBerryEspLabels()
    if berryScanRunning then
        return
    end

    berryScanRunning=true
    task.spawn(function()
        local activeEntries={}
        local activeKeys={}
        local publishedKeys={}
        local queue={}
        local queueIndex=1
        local processed=0

        local char=LocalPlayer and LocalPlayer.Character or nil
        local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
        local okPlayer,playerPos=pcall(function() return hrp and hrp.Position end)

        for _,published in pairs(S.berryEspLabels) do
            if published and published.key then publishedKeys[published.key]=true end
        end

        local okRoots,roots=pcall(function() return game.Workspace:GetChildren() end)
        if okRoots and roots then
            for _,root in pairs(roots) do table.insert(queue,root) end
        end

        while S.berryEsp and queueIndex<=#queue do
            local object=queue[queueIndex]
            queueIndex=queueIndex+1

            local okName,objectName=pcall(function() return object.Name end)
            local berryName=okName and BERRY_SPHERE_NAMES[objectName] or nil
            if berryName and isBerryWorldObject(object) then
                local berryPart=object
                local berryPos=getSafeFruitPosition(berryPart)
                if not berryPos then
                    local okPart,part=pcall(function()
                        return object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
                    end)
                    if okPart and part then
                        berryPart=part
                        berryPos=getSafeFruitPosition(berryPart)
                    end
                end
                local inRange=berryPos~=nil
                if inRange and okPlayer and playerPos then
                    local dx=berryPos.X-playerPos.X
                    local dy=berryPos.Y-playerPos.Y
                    local dz=berryPos.Z-playerPos.Z
                    inRange=(dx*dx+dy*dy+dz*dz)<=BERRY_DRAW_DISTANCE_SQ
                end

                if inRange then
                    local key=getFruitInstanceKey(berryPart)
                    local entry=S.berryEspLabelCache[key]
                    if not entry then
                        local label=Drawing.new("Text")
                        label.Text=berryName
                        label.Position=Vector2.new(0,0)
                        label.Color=Color3.new(1,0.35,0.75)
                        label.Size=28
                        label.Outline=true
                        label.Visible=false
                        label.ZIndex=12
                        label.Font=Drawing.Fonts.Monospace
                        label.Center=true
                        entry={label=label,part=berryPart,name=berryName,key=key}
                        S.berryEspLabelCache[key]=entry
                    else
                        entry.part=berryPart
                        entry.name=berryName
                        entry.key=key
                    end
                    activeKeys[key]=true
                    table.insert(activeEntries,entry)
                    if not publishedKeys[key] then
                        publishedKeys[key]=true
                        table.insert(S.berryEspLabels,entry)
                    end
                end
            end

            local okChildren,children=pcall(function() return object:GetChildren() end)
            if okChildren and children then
                for _,child in pairs(children) do table.insert(queue,child) end
            end

            processed=processed+1
            if processed>=BERRY_SCAN_BATCH then
                processed=0
                task.wait()
            end
        end

        if S.berryEsp then
            for key,entry in pairs(S.berryEspLabelCache) do
                if not activeKeys[key] and entry.label then entry.label.Visible=false end
            end
            S.berryEspLabels=activeEntries
        else
            for _,entry in pairs(activeEntries) do
                if entry.label then entry.label.Visible=false end
            end
        end

        berryScanRunning=false
    end)
end

local TWEEN_STEP_TIME=0.01

function tweenTo(hrp, targetPos, speed, checkFn)
    if not hrp or not targetPos then return end
    local okStart,startPos=pcall(function() return hrp.Position end)
    if not okStart or not startPos then return end
    local rotationCF=nil
    pcall(function()
        local rx,ry,rz=hrp.CFrame:ToEulerAnglesXYZ()
        rotationCF=CFrame.Angles(rx,ry,rz)
    end)
    local dx=targetPos.X-startPos.X; local dy=targetPos.Y-startPos.Y; local dz=targetPos.Z-startPos.Z
    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
    if distance<=1 then

        pcall(function()
            local positionCF=CFrame.new(targetPos.X,targetPos.Y,targetPos.Z)
            hrp.CFrame=rotationCF and (positionCF*rotationCF) or positionCF
        end)
        return
    end
    local moveSpeed=tonumber(speed) or 320
    if moveSpeed<=0 then moveSpeed=320 end
    local duration=distance/moveSpeed; local startTime=os.clock()
    while true do
        if checkFn and not checkFn() then return end
        local okParent,parent=pcall(function() return hrp.Parent end)
        if not okParent or not parent then return end
        local alpha=math.min((os.clock()-startTime)/duration,1)
        local newX=startPos.X+dx*alpha
        local newY=startPos.Y+dy*alpha
        local newZ=startPos.Z+dz*alpha
        local okMove=pcall(function()
            local positionCF=CFrame.new(newX,newY,newZ)
            hrp.CFrame=rotationCF and (positionCF*rotationCF) or positionCF
        end)
        if not okMove then return end
        if alpha>=1 then break end
        task.wait(TWEEN_STEP_TIME)
    end
end

local espFolderSnapshots={}

local function trackedInstanceKey(instance)
    local okAddress,address=pcall(function() return instance.Address end)
    if okAddress and address and address~=0 then return tostring(address) end
    return tostring(instance)
end

local function trackedSetChanged(snapshotName,current)
    local previous=espFolderSnapshots[snapshotName]
    espFolderSnapshots[snapshotName]=current
    if not previous then return true end
    for key in pairs(current) do
        if not previous[key] then return true end
    end
    for key in pairs(previous) do
        if not current[key] then return true end
    end
    return false
end

local function trackedFolderChanged(snapshotName,folder)
    local current={}
    if folder then
        current["folder:"..trackedInstanceKey(folder)]=true
        local okChildren,children=pcall(function() return folder:GetChildren() end)
        if okChildren and children then
            for _,child in pairs(children) do
                current["child:"..trackedInstanceKey(child)]=true
            end
        end
    end
    return trackedSetChanged(snapshotName,current)
end

local function trackedFlowersChanged()
    local current={}
    for _,name in ipairs({"Flower1","Flower2"}) do
        local flower=game.Workspace:FindFirstChild(name)
        if flower then current[name..":"..trackedInstanceKey(flower)]=true end
    end
    return trackedSetChanged("flowers",current)
end

function buildChestEspLabels()
    for _,entry in pairs(S.chestEspLabelCache) do
        if entry and entry.label then entry.label.Visible=false end
    end
    S.chestEspLabels={}

    local chestModels=game.Workspace:FindFirstChild("ChestModels")
    if not chestModels then return end
    local okChildren,children=pcall(function() return chestModels:GetChildren() end)
    if not okChildren or not children then return end

    for _,chest in pairs(children) do
        local part=chest and (chest:FindFirstChild("RootPart") or chest:FindFirstChildOfClass("BasePart")) or nil
        local okPos,pos=pcall(function() return part and part.Position end)
        if okPos and pos and pos.X and pos.Y and pos.Z then
            local key=getFruitInstanceKey(part)
            local okName,chestName=pcall(function() return chest.Name end)
            chestName=(okName and chestName and chestName~="") and chestName or "Chest"
            local chestColor=Color3.fromRGB(235,235,235)
            if chestName=="SilverChest" then
                chestColor=Color3.fromRGB(165,165,165)
            elseif chestName=="GoldChest" then
                chestColor=Color3.fromRGB(255,215,55)
            elseif chestName=="DiamondChest" then
                chestColor=Color3.fromRGB(85,205,255)
            end
            if not S.chestEspLabelCache[key] then
                local label=Drawing.new("Text")
                label.Text=chestName
                label.Position=Vector2.new(0,0)
                label.Color=chestColor
                label.Size=14
                label.Outline=true
                label.Visible=false
                label.ZIndex=10
                label.Font=Drawing.Fonts.Monospace
                label.Center=true
                S.chestEspLabelCache[key]={label=label,part=part,name=chestName}
            else
                S.chestEspLabelCache[key].part=part
                S.chestEspLabelCache[key].name=chestName
                S.chestEspLabelCache[key].label.Text=chestName
                S.chestEspLabelCache[key].label.Color=chestColor
            end
            table.insert(S.chestEspLabels,S.chestEspLabelCache[key])
        end
    end
end

local function getBoatEspKey(boat)
    local okAddress,address=pcall(function() return boat.Address end)
    if okAddress and address and address~=0 then return "boat:"..tostring(address) end
    return "boat:"..tostring(boat)
end

local function getBoatEspParts(boat)
    local parts={}
    local okBase,isBase=pcall(function() return boat:IsA("BasePart") end)
    if okBase and isBase==true then table.insert(parts,boat) end
    local okDescendants,descendants=pcall(function() return boat:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okPart,isPart=pcall(function() return object:IsA("BasePart") end)
            if okPart and isPart==true then table.insert(parts,object) end
        end
    end
    return parts
end

local function getBoatEspBounds(parts)
    local minX,minY,minZ=math.huge,math.huge,math.huge
    local maxX,maxY,maxZ=-math.huge,-math.huge,-math.huge
    local found=false
    for _,part in pairs(parts or {}) do
        local okParent,parent=pcall(function() return part.Parent end)
        local okData,pos,size=pcall(function() return part.Position,part.Size end)
        if okParent and parent and okData and pos and size then
            local halfX,halfY,halfZ=size.X/2,size.Y/2,size.Z/2
            if pos.X-halfX<minX then minX=pos.X-halfX end
            if pos.Y-halfY<minY then minY=pos.Y-halfY end
            if pos.Z-halfZ<minZ then minZ=pos.Z-halfZ end
            if pos.X+halfX>maxX then maxX=pos.X+halfX end
            if pos.Y+halfY>maxY then maxY=pos.Y+halfY end
            if pos.Z+halfZ>maxZ then maxZ=pos.Z+halfZ end
            found=true
        end
    end
    if not found then return nil end
    return minX,minY,minZ,maxX,maxY,maxZ
end

function buildBoatEsp()
    for _,entry in pairs(S.boatEspCache) do
        if entry.label then entry.label.Visible=false end
        for _,line in pairs(entry.lines or {}) do line.Visible=false end
    end
    S.boatEspEntries={}

    local boats=game.Workspace:FindFirstChild("Boats")
    if not boats then return end
    local okChildren,children=pcall(function() return boats:GetChildren() end)
    if not okChildren or not children then return end

    for _,boat in pairs(children) do
        local parts=getBoatEspParts(boat)
        if #parts>0 then
            local anchor=nil
            pcall(function() anchor=boat.PrimaryPart end)
            if not anchor then
                for _,part in pairs(parts) do
                    local okClass,className=pcall(function() return part.ClassName end)
                    if okClass and className=="VehicleSeat" then anchor=part; break end
                end
            end
            if not anchor then anchor=parts[1] end

            local minX,minY,minZ,maxX,maxY,maxZ=getBoatEspBounds(parts)
            local okAnchor,anchorPos=pcall(function() return anchor and anchor.Position end)
            if anchor and minX and okAnchor and anchorPos then
            local bounds={
                minX=minX-anchorPos.X,minY=minY-anchorPos.Y,minZ=minZ-anchorPos.Z,
                maxX=maxX-anchorPos.X,maxY=maxY-anchorPos.Y,maxZ=maxZ-anchorPos.Z,
            }
            local key=getBoatEspKey(boat)
            local okName,boatName=pcall(function() return boat.Name end)
            boatName=(okName and type(boatName)=="string" and boatName~="") and boatName or "Boat"
            local entry=S.boatEspCache[key]
            if not entry then
                local lines={}
                for _=1,12 do
                    local line=Drawing.new("Line")
                    line.Color=Color3.fromRGB(40,190,255)
                    line.Thickness=2
                    line.Visible=false
                    line.ZIndex=10
                    table.insert(lines,line)
                end
                local label=Drawing.new("Text")
                label.Text=boatName
                label.Position=Vector2.new(0,0)
                label.Color=Color3.fromRGB(90,215,255)
                label.Size=18
                label.Outline=true
                label.Center=true
                label.Font=Drawing.Fonts.Monospace
                label.Visible=false
                label.ZIndex=11
                entry={boat=boat,anchor=anchor,bounds=bounds,name=boatName,lines=lines,label=label}
                S.boatEspCache[key]=entry
            else
                entry.boat=boat
                entry.anchor=anchor
                entry.bounds=bounds
                entry.name=boatName
                entry.label.Text=boatName
            end
            table.insert(S.boatEspEntries,entry)
            end
        end
    end
end

local FLOWER_ESP_TARGETS={
    {workspaceName="Flower1",label="Blue Flower",color=Color3.fromRGB(55,145,255)},
    {workspaceName="Flower2",label="Red Flower",color=Color3.fromRGB(255,65,65)},
}

local function getFlowerEspKey(flowerName,flower)
    local okAddress,address=pcall(function() return flower.Address end)
    if okAddress and address and address~=0 then
        return "flower:"..flowerName..":"..tostring(address)
    end
    return "flower:"..flowerName..":"..tostring(flower)
end

function buildFlowerEsp()
    for _,entry in pairs(S.flowerEspCache) do
        if entry.label then entry.label.Visible=false end
        for _,line in pairs(entry.lines or {}) do line.Visible=false end
    end
    S.flowerEspEntries={}

    for _,target in ipairs(FLOWER_ESP_TARGETS) do
        local flower=game.Workspace:FindFirstChild(target.workspaceName)
        if flower then
            local parts=getBoatEspParts(flower)
            if #parts>0 then
                local anchor=nil
                local okPrimary,primary=pcall(function() return flower.PrimaryPart end)
                if okPrimary and primary then anchor=primary end
                if not anchor then anchor=parts[1] end

                local minX,minY,minZ,maxX,maxY,maxZ=getBoatEspBounds(parts)
                local okAnchor,anchorPos=pcall(function() return anchor and anchor.Position end)
                if anchor and minX and okAnchor and anchorPos then
                    local bounds={
                        minX=minX-anchorPos.X,minY=minY-anchorPos.Y,minZ=minZ-anchorPos.Z,
                        maxX=maxX-anchorPos.X,maxY=maxY-anchorPos.Y,maxZ=maxZ-anchorPos.Z,
                    }
                    local key=getFlowerEspKey(target.workspaceName,flower)
                    local entry=S.flowerEspCache[key]
                    if not entry then
                        local lines={}
                        for _=1,12 do
                            local line=Drawing.new("Line")
                            line.Color=target.color
                            line.Thickness=2
                            line.Visible=false
                            line.ZIndex=10
                            table.insert(lines,line)
                        end
                        local label=Drawing.new("Text")
                        label.Text=target.label
                        label.Position=Vector2.new(0,0)
                        label.Color=target.color
                        label.Size=18
                        label.Outline=true
                        label.Center=true
                        label.Font=Drawing.Fonts.Monospace
                        label.Visible=false
                        label.ZIndex=11
                        entry={flower=flower,anchor=anchor,bounds=bounds,name=target.label,lines=lines,label=label}
                        S.flowerEspCache[key]=entry
                    else
                        entry.flower=flower
                        entry.anchor=anchor
                        entry.bounds=bounds
                        entry.name=target.label
                        entry.label.Text=target.label
                        entry.label.Color=target.color
                        for _,line in pairs(entry.lines) do line.Color=target.color end
                    end
                    table.insert(S.flowerEspEntries,entry)
                end
            end
        end
    end
end

local ESP_BOX_EDGES={
    {1,2},{2,4},{4,3},{3,1},
    {5,6},{6,8},{8,7},{7,5},
    {1,5},{2,6},{3,7},{4,8},
}

local function updateWorldBoxEntry(entry)
    local visible=false
    local okAnchor,anchorParent,anchorPos=pcall(function()
        return entry.anchor and entry.anchor.Parent,entry.anchor and entry.anchor.Position
    end)
    local bounds=entry.bounds
    if okAnchor and anchorParent and anchorPos and bounds then
        local minX=anchorPos.X+bounds.minX
        local minY=anchorPos.Y+bounds.minY
        local minZ=anchorPos.Z+bounds.minZ
        local maxX=anchorPos.X+bounds.maxX
        local maxY=anchorPos.Y+bounds.maxY
        local maxZ=anchorPos.Z+bounds.maxZ
        local corners=entry.worldCorners or {}
        entry.worldCorners=corners
        corners[1]=Vector3.new(minX,minY,minZ)
        corners[2]=Vector3.new(maxX,minY,minZ)
        corners[3]=Vector3.new(minX,maxY,minZ)
        corners[4]=Vector3.new(maxX,maxY,minZ)
        corners[5]=Vector3.new(minX,minY,maxZ)
        corners[6]=Vector3.new(maxX,minY,maxZ)
        corners[7]=Vector3.new(minX,maxY,maxZ)
        corners[8]=Vector3.new(maxX,maxY,maxZ)

        local screenPoints=entry.screenPoints or {}
        entry.screenPoints=screenPoints
        local screenMinX,screenMinY=math.huge,math.huge
        local screenMaxX=-math.huge
        local projectedCount=0
        for index=1,8 do
            local okScreen,screenPos,onScreen=pcall(function() return WorldToScreen(corners[index]) end)
            if okScreen and screenPos and onScreen==true then
                screenPoints[index]=screenPos
                projectedCount=projectedCount+1
                if screenPos.X<screenMinX then screenMinX=screenPos.X end
                if screenPos.Y<screenMinY then screenMinY=screenPos.Y end
                if screenPos.X>screenMaxX then screenMaxX=screenPos.X end
            else
                break
            end
        end

        if projectedCount==8 then
            for index,edge in ipairs(ESP_BOX_EDGES) do
                entry.lines[index].From=screenPoints[edge[1]]
                entry.lines[index].To=screenPoints[edge[2]]
            end
            entry.label.Position=Vector2.new((screenMinX+screenMaxX)/2,screenMinY-20)
            visible=true
        end
    end

    for _,line in pairs(entry.lines) do line.Visible=visible end
    entry.label.Visible=visible
end

function hardLockNpcCFrame(hrp,targetPos)
    if not hrp or not targetPos then return end
    pcall(function()

        local currentCFrame=hrp.CFrame
        local rx,ry,rz=currentCFrame:ToEulerAnglesXYZ()
        hrp.CFrame=CFrame.new(targetPos.X,targetPos.Y,targetPos.Z)*CFrame.Angles(rx,ry,rz)
    end)

    pcall(function()
        local velocity=hrp.Velocity
        if velocity and velocity.X and velocity.Z then
            hrp.Velocity=Vector3.new(velocity.X,0,velocity.Z)
        end
    end)
    pcall(function()
        local assemblyVelocity=hrp.AssemblyLinearVelocity
        if assemblyVelocity and assemblyVelocity.X and assemblyVelocity.Z then
            hrp.AssemblyLinearVelocity=Vector3.new(assemblyVelocity.X,0,assemblyVelocity.Z)
        end
    end)
end

function getNormalFarmOffsets()
    local sanguine=false
    local backpack=LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Sanguine Art") then sanguine=true end
    local char=LocalPlayer.Character
    if char and char:FindFirstChild("Sanguine Art") then sanguine=true end
    if S.customOffset then
        return tonumber(S.customOffsetX) or 0,
               tonumber(S.customOffsetY) or 23,
               tonumber(S.customOffsetZ) or 0
    end
    if sanguine then return 0,23,10 end
    return 0,23,0
end

function isAlive(model)
    if not model or not model.Parent then return false end
    local hum=model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health<=0 then return false end
    return true
end

function farmAttack(hrp, checkFn, enemyName, useTween, maxDistance, attackFn, attackDelay)
    local attackRange=maxDistance or 500
    local folder=game.Workspace:FindFirstChild("Enemies")
    if not folder then return end
    local nearest, bestDist=nil, math.huge
    for _, model in pairs(folder:GetChildren()) do
        if model:IsA("Model") and isAlive(model) then
            if not enemyName or model.Name==enemyName then
                local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
                if root then
                    local dx=root.Position.X-hrp.Position.X
                    local dy=root.Position.Y-hrp.Position.Y
                    local dz=root.Position.Z-hrp.Position.Z
                    local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                    if d<bestDist and d<=attackRange then bestDist=d; nearest=model end
                end
            end
        end
    end
    if not nearest then return end
    task.spawn(function()
        local expandedHead=nearest:FindFirstChild("Head")
        local originalSize=nil
        local originalCanCollide=nil
        if expandedHead then
            pcall(function()
                originalSize=expandedHead.Size
                originalCanCollide=expandedHead.CanCollide
            end)
        end
        while checkFn() and isAlive(nearest) do
            if not S.remoteMode then
                local size=S.bigHitbox and 200 or 50
                expandedHead=nearest:FindFirstChild("Head") or expandedHead
                if expandedHead then
                    expandedHead.Size=Vector3.new(size,size,size)
                    expandedHead.CanCollide=false
                end
            end
            task.wait()
        end
        if expandedHead and expandedHead.Parent and originalSize then
            pcall(function()
                expandedHead.Size=originalSize
                if originalCanCollide~=nil then expandedHead.CanCollide=originalCanCollide end
            end)
        end
    end)
    local lastClick=0
    local hitDelay=attackDelay or 0.06
    local reachedNpc=false
    while checkFn() and isAlive(nearest) do
        local tr=nearest:FindFirstChild("HumanoidRootPart") or nearest:FindFirstChildOfClass("BasePart")
        if tr then
            local ox,oy,oz=getNormalFarmOffsets()
            local targetPos=Vector3.new(tr.Position.X+ox, tr.Position.Y+oy, tr.Position.Z+oz)
            if useTween and not reachedNpc then
                tweenTo(hrp,targetPos,S.FARM_SPEED,function() return checkFn() and isAlive(nearest) end)
                reachedNpc=true
            else
                hardLockNpcCFrame(hrp,targetPos)
            end
        end
        local now=os.clock()
        if now-lastClick>=hitDelay then
            lastClick=now
            if attackFn then

                task.spawn(attackFn)
            else
                mouse1click()
            end
        end
        task.wait()
    end
end

local REMOTE_SESSION_ID = "32501259"
local REMOTE_MAX_DIST   = 60
local _remoteNet        = nil
local _remoteRegAtk     = nil
local _remoteRegHit     = nil
local _lastRemoteFire   = 0

local function ensureRemotes()
    if _remoteRegAtk and _remoteRegHit then return true end
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
    if net then net = net:FindFirstChild("Net") end
    if not net then return false end
    _remoteNet    = net
    _remoteRegAtk = net:FindFirstChild("RE/RegisterAttack")
    _remoteRegHit = net:FindFirstChild("RE/RegisterHit")
    return _remoteRegAtk ~= nil and _remoteRegHit ~= nil
end

function remoteAttack()
    if not ensureRemotes() then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos  = hrp.Position
    local folder = game.Workspace:FindFirstChild("Enemies")
    if not folder then return end

    local hitTable   = {}
    local primaryPart = nil
    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy and enemy.Parent then
            local hum  = enemy:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health and hum.Health > 0 then

                local part = enemy:FindFirstChild("LeftLowerLeg")
                          or enemy:FindFirstChild("Head")
                          or enemy:FindFirstChild("HumanoidRootPart")
                if not part then
                    for _, c in ipairs(enemy:GetChildren()) do
                        if c:IsA("BasePart") then part = c; break end
                    end
                end
                if part and part.Parent then
                    local ok, pos = pcall(function() return part.Position end)
                    if ok and pos then
                        local dx = pos.X - myPos.X
                        local dy = pos.Y - myPos.Y
                        local dz = pos.Z - myPos.Z
                        local d  = math.sqrt(dx*dx + dy*dy + dz*dz)
                        if d <= REMOTE_MAX_DIST then
                            table.insert(hitTable, {enemy, part})
                            if not primaryPart then primaryPart = part end
                        end
                    end
                end
            end
        end
    end

    if #hitTable == 0 then return end
    pcall(function() _remoteRegAtk:FireServer(0.5) end)
    task.wait()
    pcall(function() _remoteRegHit:FireServer(primaryPart, hitTable, nil, REMOTE_SESSION_ID) end)
    _lastRemoteFire = os.clock()
end

do
    local Dungeon={
        target=nil,
        targetingObjective=false,
        doorWaypoint=nil,
    }

    local function dungeonDistance(a,b)
        local dx=a.X-b.X
        local dy=a.Y-b.Y
        local dz=a.Z-b.Z
        return math.sqrt(dx*dx+dy*dy+dz*dz)
    end

    local function dungeonRoot(object)
        if not object then return nil end
        return object:FindFirstChild("HumanoidRootPart")
            or object:FindFirstChild("UpperTorso")
            or object:FindFirstChild("Head")
            or object:FindFirstChildWhichIsA("BasePart")
    end

    local function dungeonIsSummon(object)
        if not object then return true end
        if object:FindFirstChild("Summoner") or object:FindFirstChild("Creator") or object:FindFirstChild("Owner") then return true end
        local name=string.lower(object.Name or "")
        return string.find(name,"shadow",1,true)~=nil
            or string.find(name,"buddy",1,true)~=nil
            or string.find(name,"blank",1,true)~=nil
            or string.find(name,"clone",1,true)~=nil
            or string.find(name,"summon",1,true)~=nil
            or string.find(name,"decoy",1,true)~=nil
            or string.find(name,"dummy",1,true)~=nil
    end

    local function dungeonIsAlive(object)
        if not object or not object.Parent or dungeonIsSummon(object) then return false end
        local humanoid=object:FindFirstChildOfClass("Humanoid")
        return humanoid~=nil and humanoid.Health>0 and dungeonRoot(object)~=nil
    end

    local function dungeonIsObjective(object)
        if not dungeonIsAlive(object) then return false end
        local name=string.lower(object.Name or "")
        local objective=name=="prophitboxplaceholder"
            or string.find(name,"placeholder",1,true)~=nil
            or string.find(name,"gasvent",1,true)~=nil
            or string.find(name,"vent",1,true)~=nil
            or string.find(name,"shrine",1,true)~=nil
            or string.find(name,"rock",1,true)~=nil
            or string.find(name,"totem",1,true)~=nil
            or (string.find(name,"prop",1,true)~=nil and string.find(name,"knight",1,true)==nil and string.find(name,"boss",1,true)==nil)
        if not objective then return false end
        local humanoid=object:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.MaxHealth<50000
    end

    local function dungeonNearestIsland(position)
        local map=game.Workspace:FindFirstChild("Map")
        local dungeon=map and map:FindFirstChild("Dungeon") or nil
        if not dungeon then return nil end
        local best=nil
        local bestDistance=math.huge
        for _,island in pairs(dungeon:GetChildren()) do
            local root=island:FindFirstChild("Root") or island:FindFirstChildWhichIsA("BasePart")
            if root then
                local dx=position.X-root.Position.X
                local dz=position.Z-root.Position.Z
                local distance=math.sqrt(dx*dx+dz*dz)
                if distance<bestDistance then
                    bestDistance=distance
                    best=island
                end
            end
        end
        return best
    end

    local function dungeonDoorWaypoint(position)
        local island=dungeonNearestIsland(position)
        local exit=island and island:FindFirstChild("ExitTeleporter") or nil
        local door=exit and (exit:FindFirstChild("Root") or exit:FindFirstChildWhichIsA("BasePart")) or nil
        if not door then return nil end
        local doorPosition=door.Position
        local dx=doorPosition.X-position.X
        local dz=doorPosition.Z-position.Z
        local distanceXZ=math.sqrt(dx*dx+dz*dz)
        if distanceXZ>30 then
            local islandRoot=island:FindFirstChild("Root") or island:FindFirstChildWhichIsA("BasePart")
            local islandY=islandRoot and islandRoot.Position.Y or 200
            return Vector3.new(doorPosition.X,math.max(position.Y,doorPosition.Y,islandY)+35,doorPosition.Z)
        end
        return Vector3.new(doorPosition.X,doorPosition.Y+3,doorPosition.Z)
    end

    local function dungeonFindTarget(playerPosition)
        local folder=game.Workspace:FindFirstChild("Enemies")
        if not folder then return nil,false end
        local bestObjective=nil
        local bestObjectiveDistance=math.huge
        local bestEnemy=nil
        local bestEnemyDistance=S.dungeonLocalRadius or 800

        for _,enemy in pairs(folder:GetChildren()) do
            if dungeonIsAlive(enemy) then
                local root=dungeonRoot(enemy)
                if root then
                    local distance=dungeonDistance(playerPosition,root.Position)
                    if S.dungeonDestroyObj and dungeonIsObjective(enemy) then
                        if distance<bestObjectiveDistance then
                            bestObjectiveDistance=distance
                            bestObjective=enemy
                        end
                    elseif distance<bestEnemyDistance then
                        bestEnemyDistance=distance
                        bestEnemy=enemy
                    end
                end
            end
        end
        if bestObjective then return bestObjective,true end
        return bestEnemy,false
    end

    task.spawn(function()
        while true do
            if S.dungeonEnabled then
                local character=LocalPlayer.Character
                local root=character and character:FindFirstChild("HumanoidRootPart") or nil
                local humanoid=character and character:FindFirstChildOfClass("Humanoid") or nil
                if root and humanoid and humanoid.Health>0 then
                    local target,isObjective=dungeonFindTarget(root.Position)
                    Dungeon.target=target
                    Dungeon.targetingObjective=isObjective
                    Dungeon.doorWaypoint=nil
                    local targetRoot=dungeonRoot(target)
                    if targetRoot then
                        local useRemote=S.remoteMode
                        local expandedHead=not useRemote and target:FindFirstChild("Head") or nil
                        local originalHeadSize=nil
                        local originalHeadCanCollide=nil
                        if expandedHead then
                            pcall(function()
                                originalHeadSize=expandedHead.Size
                                originalHeadCanCollide=expandedHead.CanCollide
                            end)
                        end
                        local p=targetRoot.Position
                        local ox,oy,oz=getNormalFarmOffsets()
                        local targetPosition=Vector3.new(p.X+ox,p.Y+oy,p.Z+oz)
                        tweenTo(root,targetPosition,S.FARM_SPEED,function()
                            return S.dungeonEnabled and S.remoteMode==useRemote
                                and Dungeon.target==target and dungeonIsAlive(target)
                        end)

                        local lastAttack=0
                        while S.dungeonEnabled and S.remoteMode==useRemote
                            and Dungeon.target==target and dungeonIsAlive(target) do
                            targetRoot=dungeonRoot(target)
                            if not targetRoot then break end
                            p=targetRoot.Position
                            ox,oy,oz=getNormalFarmOffsets()
                            targetPosition=Vector3.new(p.X+ox,p.Y+oy,p.Z+oz)
                            hardLockNpcCFrame(root,targetPosition)
                            if expandedHead then
                                local size=S.bigHitbox and 200 or 50
                                pcall(function()
                                    expandedHead.Size=Vector3.new(size,size,size)
                                    expandedHead.CanCollide=false
                                end)
                            end

                            local now=os.clock()
                            local attackDelay=useRemote and 0.05 or 0.06
                            if now-lastAttack>=attackDelay then
                                lastAttack=now
                                if useRemote then task.spawn(remoteAttack)
                                else pcall(mouse1click) end
                            end
                            task.wait()
                        end
                        if expandedHead and expandedHead.Parent and originalHeadSize then
                            pcall(function()
                                expandedHead.Size=originalHeadSize
                                if originalHeadCanCollide~=nil then expandedHead.CanCollide=originalHeadCanCollide end
                            end)
                        end
                    elseif S.dungeonAutoDoor then
                        Dungeon.doorWaypoint=dungeonDoorWaypoint(root.Position)
                        if Dungeon.doorWaypoint then
                            tweenTo(root,Dungeon.doorWaypoint,S.FARM_SPEED,function()
                                return S.dungeonEnabled and S.dungeonAutoDoor
                            end)
                        end
                    end
                end
            else
                Dungeon.target=nil
                Dungeon.targetingObjective=false
                Dungeon.doorWaypoint=nil
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        local skillKeys={0x5A,0x58,0x43,0x56}
        while true do
            if S.dungeonEnabled and S.dungeonUseMoves
                and Dungeon.targetingObjective and dungeonIsAlive(Dungeon.target) then
                for _,keyCode in pairs(skillKeys) do
                    if not S.dungeonEnabled or not dungeonIsAlive(Dungeon.target) then break end
                    pcall(function()
                        keypress(keyCode)
                        task.wait(0.04)
                        keyrelease(keyCode)
                    end)
                    task.wait(0.16)
                end
            end
            task.wait(0.3)
        end
    end)

end

local function getChestType(chest)
    local okName,name=pcall(function() return chest and chest.Name end)
    if not okName or type(name)~="string" then return "Other" end
    local lowerName=string.lower(name)
    if string.match(lowerName,"diamond") then return "Diamond" end
    if string.match(lowerName,"gold") then return "Gold" end
    if string.match(lowerName,"silver") then return "Silver" end
    return "Other"
end

local function getChestPriorityRank(chestType)
    for rank,name in ipairs(S.chestPriority) do
        if name==chestType then return rank end
    end
    return #S.chestPriority+1
end

local function getPriorityChest(children,hrp)
    if not children or not hrp then return nil,nil,nil end
    local okPlayer,playerPos=pcall(function() return hrp.Position end)
    if not okPlayer or not playerPos then return nil,nil,nil end

    local activeKeys={}
    for _,chest in pairs(children) do
        activeKeys[trackedInstanceKey(chest)]=true
    end
    for key in pairs(S.handledChests) do
        if not activeKeys[key] then S.handledChests[key]=nil end
    end

    local bestChest,bestPart,bestType=nil,nil,nil
    local bestRank,bestDistance=math.huge,math.huge
    for _,chest in pairs(children) do
        local chestKey=trackedInstanceKey(chest)
        local part=chest and (chest:FindFirstChild("RootPart") or chest:FindFirstChildOfClass("BasePart")) or nil
        local okParent,parent=pcall(function() return chest and chest.Parent end)
        local okPos,pos=pcall(function() return part and part.Position end)
        if not S.handledChests[chestKey] and okParent and parent and okPos and pos then
            local chestType=getChestType(chest)
            local rank=getChestPriorityRank(chestType)
            local dx=pos.X-playerPos.X
            local dy=pos.Y-playerPos.Y
            local dz=pos.Z-playerPos.Z
            local distanceSq=dx*dx+dy*dy+dz*dz
            if rank<bestRank or (rank==bestRank and distanceSq<bestDistance) then
                bestChest,bestPart,bestType=chest,part,chestType
                bestRank,bestDistance=rank,distanceSq
            end
        end
    end
    return bestChest,bestPart,bestType
end

task.spawn(function()
    while true do
        if S.autoFarming and not farmPriorityBlocked() then
            local reachedChest=false
            local ChestModels=game.Workspace:FindFirstChild("ChestModels")
            if ChestModels then
                local okChildren,children=pcall(function() return ChestModels:GetChildren() end)
                local char=LocalPlayer.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
                if okChildren and children and hrp then
                    local chest,part,chestType=getPriorityChest(children,hrp)
                    local okPos,pos=pcall(function() return part and part.Position end)
                    if chest and part and okPos and pos then
                        notify("Going to "..chestType.." chest","laced.club",2)
                        local destination=Vector3.new(pos.X,pos.Y+3,pos.Z)
                        tweenTo(hrp,destination,S.CHEST_SPEED,function()
                            local okChest,chestParent=pcall(function() return chest.Parent end)
                            local okPart,partParent=pcall(function() return part.Parent end)
                            return S.autoFarming and not farmPriorityBlocked()
                                and okChest and chestParent~=nil and okPart and partParent~=nil
                        end)
                        local okArrival,currentPos=pcall(function() return hrp.Position end)
                        if okArrival and currentPos then
                            local dx=currentPos.X-destination.X
                            local dy=currentPos.Y-destination.Y
                            local dz=currentPos.Z-destination.Z
                            if dx*dx+dy*dy+dz*dz<=4 then
                                S.handledChests[trackedInstanceKey(chest)]=true
                                reachedChest=true
                            end
                        end
                    end
                end
            end
            if reachedChest then task.wait() else task.wait(0.25) end
        else task.wait(0.1) end
    end
end)

function getCurrentlyHeldTool()
    local char=LocalPlayer.Character
    if not char then return nil end
    for _,child in pairs(char:GetChildren()) do
        local okClass, className=pcall(function() return child.ClassName end)
        if okClass and className=="Tool" then
            return child
        end
    end
    return nil
end

function pressWeaponSlot(slot)
    local selectedKey=(slot==3) and 0x33 or 0x31
    pcall(function()

        setrobloxinput(true)
        keyrelease(selectedKey)
        task.wait(0.02)
        keypress(selectedKey)
        task.wait(0.1)
        keyrelease(selectedKey)
    end)

    if getCurrentlyHeldTool() then return true end

    local char=LocalPlayer and LocalPlayer.Character or nil
    local backpack=LocalPlayer and LocalPlayer:FindFirstChild("Backpack") or nil
    local hum=char and char:FindFirstChildOfClass("Humanoid") or nil
    if not char or not backpack then return false end

    local tools={}
    local okChildren, children=pcall(function() return backpack:GetChildren() end)
    if okChildren and children then
        for _,candidate in pairs(children) do
            local okTool, className=pcall(function() return candidate.ClassName end)
            if okTool and className=="Tool" then table.insert(tools,candidate) end
        end
    end

    local tool=tools[slot]
    if not tool then return false end

    local equipped=false
    if hum then
        local okEquip=pcall(function() hum:EquipTool(tool) end)
        if okEquip then
            local okParent, parent=pcall(function() return tool.Parent end)
            equipped=okParent and parent==char
        end
    end
    if not equipped then
        pcall(function() tool.Parent=char end)
        local okParent, parent=pcall(function() return tool.Parent end)
        equipped=okParent and parent==char
    end
    return equipped
end

function restoreHeldTool(rememberedTool, toolName)

    local char=LocalPlayer and LocalPlayer.Character or nil
    local backpack=LocalPlayer and LocalPlayer:FindFirstChild("Backpack") or nil
    local hum=char and char:FindFirstChildOfClass("Humanoid") or nil
    local tool=nil

    if rememberedTool then
        local okTool, isTool=pcall(function() return rememberedTool:IsA("Tool") end)
        local okParent, parent=pcall(function() return rememberedTool.Parent end)
        if okTool and isTool and okParent and parent and (parent==char or parent==backpack) then
            tool=rememberedTool
        end
    end

    if not tool and toolName then
        local charTool=char and char:FindFirstChild(toolName) or nil
        local backpackTool=backpack and backpack:FindFirstChild(toolName) or nil
        if charTool and charTool:IsA("Tool") then
            tool=charTool
        elseif backpackTool and backpackTool:IsA("Tool") then
            tool=backpackTool
        end
    end

    if tool and char then
        local equipped=false
        if hum then
            local okEquip=pcall(function() hum:EquipTool(tool) end)
            if okEquip then
                local okParent, parent=pcall(function() return tool.Parent end)
                equipped=okParent and parent==char
            end
        end

        if not equipped then
            pcall(function() tool.Parent=char end)
        end
    end

end

task.spawn(function()
    while true do
        if S.autoFruits then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bestPart, bestDist=nil, math.huge
                local okHrp, hrpPos=pcall(function() return hrp.Position end)
                if okHrp and hrpPos and hrpPos.X and hrpPos.Y and hrpPos.Z then
                    for _, fruit in pairs(getWorkspaceFruits()) do
                        local fp, fpPos=fruit.part, getSafeFruitPosition(fruit.part)
                        if fp and fpPos then
                            local dx=fpPos.X-hrpPos.X
                            local dy=fpPos.Y-hrpPos.Y
                            local dz=fpPos.Z-hrpPos.Z
                            local dist=math.sqrt(dx*dx+dy*dy+dz*dz)
                            if dist<bestDist then bestDist=dist; bestPart=fp end
                        end
                    end
                end
                if bestPart then

                    S.fruitPriorityActive=true

                    notify("Farming fruit...","laced.club",1)
                    local okTarget, fruitPos=pcall(function() return bestPart.Position end)
                    local arrived=false
                    if okTarget and fruitPos and fruitPos.X and fruitPos.Y and fruitPos.Z then
                        tweenTo(hrp, Vector3.new(fruitPos.X,fruitPos.Y+3,fruitPos.Z), S.FRUIT_SPEED, function()
                            return S.autoFruits and bestPart and bestPart.Parent
                        end)
                        arrived=true
                    end

                    if arrived and S.autoFruits then
                        task.wait(1)
                        pressWeaponSlot(S.weaponSlot)
                    end

                    local fruitWaitStart=os.clock()
                    while S.autoFruits and bestPart and bestPart.Parent and os.clock()-fruitWaitStart<3 do
                        task.wait(0.05)
                    end

                    S.fruitPriorityActive=false
                else
                    S.fruitPriorityActive=false
                end
            end
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        local farming=S.autoFarmNearest or S.autoNpcFarm or S.autoFarmLevel or S.autoRaid or S.autoBossFarm or S.autoMaterialFarm or S.autoSeaEvent
        if farming and not getCurrentlyHeldTool() then
            local selectedSlot=S.weaponSlot
            task.spawn(function() pressWeaponSlot(selectedSlot) end)
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while true do
        if S.autoFarmNearest and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then

                local useRemote=S.remoteMode
                farmAttack(
                    hrp,
                    function()
                        return S.autoFarmNearest and S.remoteMode==useRemote and not farmPriorityBlocked()
                    end,
                    nil,
                    true,
                    1000,
                    useRemote and remoteAttack or nil,
                    useRemote and 0.05 or 0.06
                )
            end
            task.wait(0.1)
        else task.wait(0.1) end
    end
end)

task.spawn(function()
    while true do
        if S.autoNpcFarm and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local island=islandList[S.selectedIsland]
                local ip=island.pos
                notify("NPC Farm: going to "..island.name,"laced.club",2)
                tweenTo(hrp, Vector3.new(ip.X,ip.Y,ip.Z), S.NPC_TWEEN_SPEED, function() return S.autoNpcFarm and not farmPriorityBlocked() end)
                task.wait(0.5)
                local char2=LocalPlayer.Character
                if char2 then for _,part in pairs(char2:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end
                while S.autoNpcFarm and not farmPriorityBlocked() do
                    local hrp2=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp2 then task.wait(0.1); break end

                    if S.remoteMode then

                        local folder=game.Workspace:FindFirstChild("Enemies")
                        if folder then
                            local nearest, bestDist=nil, math.huge
                            for _,model in pairs(folder:GetChildren()) do
                                if model:IsA("Model") and isAlive(model) then
                                    local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
                                    if root then
                                        local dx=root.Position.X-hrp2.Position.X
                                        local dy=root.Position.Y-hrp2.Position.Y
                                        local dz=root.Position.Z-hrp2.Position.Z
                                        local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                                        if d<bestDist and d<=1000 then bestDist=d; nearest=model end
                                    end
                                end
                            end
                            if nearest then
                                local reachedNpc=false
                                local lastRemoteAttack=0
                                while S.autoNpcFarm and S.remoteMode and not farmPriorityBlocked() and isAlive(nearest) do
                                    local tr=nearest:FindFirstChild("HumanoidRootPart") or nearest:FindFirstChildOfClass("BasePart")
                                    if not tr then break end
                                    local ox,oy,oz=getNormalFarmOffsets()
                                    local targetPos=Vector3.new(tr.Position.X+ox,tr.Position.Y+oy,tr.Position.Z+oz)
                                    if not reachedNpc then
                                        tweenTo(hrp2,targetPos,S.FARM_SPEED,function()
                                            return S.autoNpcFarm and S.remoteMode and not farmPriorityBlocked() and isAlive(nearest)
                                        end)
                                        reachedNpc=true
                                    else
                                        hardLockNpcCFrame(hrp2,targetPos)
                                    end
                                    local now=os.clock()
                                    if now-lastRemoteAttack>=0.05 then
                                        remoteAttack()
                                        lastRemoteAttack=now
                                    end
                                    task.wait()
                                end
                            end
                        end
                    else
                        farmAttack(hrp2, function()
                            return S.autoNpcFarm and not S.remoteMode and not farmPriorityBlocked()
                        end, nil, true, 1000)
                    end
                    task.wait(0.1)
                end
            end
            task.wait(0.1)
        else task.wait(0.1) end
    end
end)

function afl_loadQuestData()
    AFL.questData={}
    if AFL.currentSea==1 then
        AFL.questData.Sea1First={enemy="Trainee",questButton=1,ammountToKill=5}
        AFL.questData.Jungle1={enemy="Monkey",questButton=1,ammountToKill=6}
        AFL.questData.Jungle2={enemy="Gorilla",questButton=2,ammountToKill=8}
        AFL.questData.PirateVillage1={enemy="Pirate",questButton=1,ammountToKill=8}
        AFL.questData.PirateVillage2={enemy="Brute",questButton=2,ammountToKill=8}
        AFL.questData.DesertIsland1={enemy="Desert Bandit",questButton=1,ammountToKill=8}
        AFL.questData.DesertIsland2={enemy="Desert Officer",questButton=2,ammountToKill=6}
        AFL.questData.WinterIsland1={enemy="Snow Bandit",questButton=1,ammountToKill=7}
        AFL.questData.WinterIsland2={enemy="Snowman",questButton=2,ammountToKill=8}
        AFL.questData.MarineFortress={enemy="Chief Petty Officer",questButton=1,ammountToKill=8}
        AFL.questData.SkyIsland1={enemy="Sky Bandit",questButton=1,ammountToKill=7}
        AFL.questData.SkyIsland2={enemy="Dark Master",questButton=2,ammountToKill=8}
        AFL.questData.PrisonIsland1={enemy="Prisoner",questButton=1,ammountToKill=8}
        AFL.questData.PrisonIsland2={enemy="Dangerous Prisoner",questButton=2,ammountToKill=8}
        AFL.questData.ColosseumIsland1={enemy="Toga Warrior",questButton=1,ammountToKill=7}
        AFL.questData.ColosseumIsland2={enemy="Gladiator",questButton=2,ammountToKill=8}
        AFL.questData.MagmaIsland1={enemy="Military Soldier",questButton=1,ammountToKill=7}
        AFL.questData.MagmaIsland2={enemy="Military Spy",questButton=2,ammountToKill=8}
        AFL.questData.UnderWaterIsland1={enemy="Fishman Warrior",questButton=1,ammountToKill=8}
        AFL.questData.UnderWaterIsland2={enemy="Fishman Commando",questButton=2,ammountToKill=7}
        AFL.questData.SkyIsland3={enemy="God's Guard",questButton=1,ammountToKill=7}
        AFL.questData.SkyIsland4={enemy="Shanda",questButton=2,ammountToKill=9}
        AFL.questData.SkyIsland5={enemy="Royal Squad",questButton=1,ammountToKill=8}
        AFL.questData.SkyIsland6={enemy="Royal Soldier",questButton=2,ammountToKill=8}
        AFL.questData.FountainIsland1={enemy="Galley Pirate",questButton=1,ammountToKill=8}
        AFL.questData.FountainIsland2={enemy="Galley Captain",questButton=2,ammountToKill=9}
    elseif AFL.currentSea==2 then
        AFL.questData.RoseKingdom1={enemy="Raider",questButton=1,ammountToKill=8}
        AFL.questData.RoseKingdom2={enemy="Mercenary",questButton=2,ammountToKill=8}
        AFL.questData.Factory1={enemy="Swan Pirate",questButton=1,ammountToKill=8}
        AFL.questData.Factory2={enemy="Factory Staff",questButton=2,ammountToKill=8}
        AFL.questData.GreenZone1={enemy="Marine Lieutenant",questButton=1,ammountToKill=8}
        AFL.questData.GreenZone2={enemy="Marine Captain",questButton=2,ammountToKill=9}
        AFL.questData.Graveyard1={enemy="Zombie",questButton=1,ammountToKill=8}
        AFL.questData.Graveyard2={enemy="Vampire",questButton=2,ammountToKill=8}
        AFL.questData.Snow1={enemy="Snow Trooper",questButton=1,ammountToKill=8}
        AFL.questData.Snow2={enemy="Winter Warrior",questButton=2,ammountToKill=9}
        AFL.questData.ColdSide1={enemy="Lab Subordinate",questButton=1,ammountToKill=8}
        AFL.questData.ColdSide2={enemy="Horned Warrior",questButton=2,ammountToKill=9}
        AFL.questData.HotSide1={enemy="Magma Ninja",questButton=1,ammountToKill=8}
        AFL.questData.HotSide2={enemy="Lava Pirate",questButton=2,ammountToKill=8}
        AFL.questData.HauntedShip1={enemy="Ship Deckhand",questButton=1,ammountToKill=8}
        AFL.questData.HauntedShip2={enemy="Ship Engineer",questButton=2,ammountToKill=8}
        AFL.questData.HauntedShip3={enemy="Ship Steward",questButton=1,ammountToKill=8}
        AFL.questData.HauntedShip4={enemy="Ship Officer",questButton=2,ammountToKill=8}
        AFL.questData.WinterCastle1={enemy="Arctic Warrior",questButton=1,ammountToKill=8}
        AFL.questData.WinterCastle2={enemy="Snow Lurker",questButton=2,ammountToKill=8}
        AFL.questData.Wano1={enemy="Sea Soldier",questButton=1,ammountToKill=8}
        AFL.questData.Wano2={enemy="Water Fighter",questButton=2,ammountToKill=8}
    elseif AFL.currentSea==3 then
        AFL.questData.Port1={enemy="Pirate Millionaire",questButton=1,ammountToKill=8}
        AFL.questData.Port2={enemy="Pistol Billionaire",questButton=2,ammountToKill=8}
        AFL.questData.Hydra1={enemy="Dragon Crew Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Hydra2={enemy="Dragon Crew Archer",questButton=2,ammountToKill=8}
        AFL.questData.Hydra3={enemy="Hydra Enforcer",questButton=1,ammountToKill=8}
        AFL.questData.Hydra4={enemy="Venomous Assailant",questButton=2,ammountToKill=8}
        AFL.questData.GreatTree1={enemy="Marine Commodore",questButton=1,ammountToKill=8}
        AFL.questData.GreatTree2={enemy="Marine Rear Admiral",questButton=2,ammountToKill=8}
        AFL.questData.TurtleEntrance1={enemy="Fishman Raider",questButton=1,ammountToKill=8}
        AFL.questData.TurtleEntrance2={enemy="Fishman Captain",questButton=2,ammountToKill=8}
        AFL.questData.Mansion1={enemy="Forest Pirate",questButton=1,ammountToKill=8}
        AFL.questData.Mansion2={enemy="Mythological Pirate",questButton=2,ammountToKill=8}
        AFL.questData.TurtleCenter1={enemy="Jungle Pirate",questButton=1,ammountToKill=8}
        AFL.questData.TurtleCenter2={enemy="Musketeer Pirate",questButton=2,ammountToKill=8}
        AFL.questData.HauntedCastle1={enemy="Reborn Skeleton",questButton=1,ammountToKill=8}
        AFL.questData.HauntedCastle2={enemy="Living Zombie",questButton=2,ammountToKill=8}
        AFL.questData.HauntedCastle3={enemy="Demonic Soul",questButton=1,ammountToKill=8}
        AFL.questData.HauntedCastle4={enemy="Posessed Mummy",questButton=2,ammountToKill=8}
        AFL.questData.Peanut1={enemy="Peanut Scout",questButton=1,ammountToKill=8}
        AFL.questData.Peanut2={enemy="Peanut President",questButton=2,ammountToKill=8}
        AFL.questData.IceCream1={enemy="Ice Cream Chef",questButton=1,ammountToKill=8}
        AFL.questData.IceCream2={enemy="Ice Cream Commander",questButton=2,ammountToKill=8}
        AFL.questData.CakeLand1={enemy="Cookie Crafter",questButton=1,ammountToKill=8}
        AFL.questData.CakeLand2={enemy="Cake Guard",questButton=2,ammountToKill=8}
        AFL.questData.CakeLand3={enemy="Baking Staff",questButton=1,ammountToKill=8}
        AFL.questData.CakeLand4={enemy="Head Baker",questButton=2,ammountToKill=8}
        AFL.questData.Chocolate1={enemy="Cocoa Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Chocolate2={enemy="Chocolate Bar Battler",questButton=2,ammountToKill=8}
        AFL.questData.Chocolate3={enemy="Sweet Thief",questButton=1,ammountToKill=8}
        AFL.questData.Chocolate4={enemy="Candy Rebel",questButton=2,ammountToKill=8}
        AFL.questData.NorthPole1={enemy="Candy Pirate",questButton=1,ammountToKill=8}
        AFL.questData.NorthPole2={enemy="Snow Demon",questButton=2,ammountToKill=8}
        AFL.questData.Tiki1Quest1={enemy="Isle Outlaw",questButton=1,ammountToKill=8}
        AFL.questData.Tiki1Quest2={enemy="Island Boy",questButton=2,ammountToKill=8}
        AFL.questData.Tiki2Quest1={enemy="Sun-kissed Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Tiki2Quest2={enemy="Isle Champion",questButton=2,ammountToKill=8}
        AFL.questData.Tiki3Quest1={enemy="Serpent Hunter",questButton=1,ammountToKill=8}
        AFL.questData.Tiki3Quest2={enemy="Skull Slayer",questButton=2,ammountToKill=8}
    end
end
afl_loadQuestData()

function afl_jitterClick(x, y)

    local okMouse, mouse=pcall(function() return LocalPlayer:GetMouse() end)
    if not okMouse or not mouse then return false end

    mousemoveabs(x,y)
    wait(0.05)
    for i=1,12 do
        local okPos,mx,my=pcall(function() return mouse.X,mouse.Y end)
        if not okPos or not mx or not my then return false end
        local dx=x-mx; local dy=y-my
        if math.abs(dx)<=2 and math.abs(dy)<=2 then break end
        mousemoverel(dx,dy)
        wait(0.03)
    end

    mousemoverel(3,0); wait(0.03)
    mousemoverel(-3,3); wait(0.03)
    mousemoverel(0,-3); wait(0.03)

    local okFinal,mx,my=pcall(function() return mouse.X,mouse.Y end)
    if okFinal and mx and my then mousemoverel(x-mx,y-my) end
    wait(0.1)
    return true
end

function afl_getCharacter()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if char and hrp then return char,hrp end
end

function afl_setCanCollide(on)
    local char=afl_getCharacter()
    if not char then return end
    for _,c in pairs(char:GetChildren()) do
        if c:IsA("BasePart") then c.CanCollide=not on end
    end
end

function afl_teleportTo(position)
    local char,hrp=afl_getCharacter()
    if not char then return end
    afl_setCanCollide(false)
    tweenTo(hrp,position,AFL.tweenSpeed,function()
        return char.Parent and not farmPriorityBlocked()
    end)
    afl_setCanCollide(true)
end

function afl_teleportToWait(questKey)
    local position=nil
    if afl_getNextNpc then
        local target=afl_getNextNpc()
        local targetRoot=target and target:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local p=targetRoot.Position
            position=Vector3.new(p.X,p.Y+23,p.Z)
        end
    end
    local route=AFL.waitRoutes and AFL.waitRoutes[questKey] or nil
    if not position and route and #route>0 then
        local index=(AFL.waitRouteIndices[questKey] or 0)+1
        if index>#route then index=1 end
        AFL.waitRouteIndices[questKey]=index
        position=route[index]
    elseif not position then
        position=AFL.waitPositions and AFL.waitPositions[questKey] or nil
    end
    if position then afl_teleportTo(position) end
end

function afl_readLevel()

    local okData,dataLevel=pcall(function() return LocalPlayer.Data.Level.Value end)
    if okData and type(dataLevel)=="number" and dataLevel>0 then return dataLevel end

    local okGui,levelText=pcall(function() return LocalPlayer.PlayerGui.Main.Level.Text end)
    if okGui and type(levelText)=="string" then
        local parsed=tonumber(string.match(levelText,"%d+"))
        if parsed and parsed>0 then return parsed end
    end
    return nil
end

function afl_getLevels()
    if not AFL.autofarmByLevel then return end
    local level=afl_readLevel()
    if not level then return end

    if level>=2800 then
        AFL.currentSea=3
        afl_loadQuestData()
        AFL.npcToFarm="Tiki3Quest2"
        AFL.islandPositions.Tiki3Quest2=Vector3.new(-16665.98,105.31,1576.49)
        AFL.waitPositions.Tiki3Quest2=Vector3.new(-16847.48,122.17,1727.21)
        return
    end
    local seaTable=AFL.levelFarmTable[AFL.currentSea]
    if not seaTable then return end
    for _,data in ipairs(seaTable) do
        if level>=data[1] and level<data[2] and AFL.questData[data[3]] then
            AFL.npcToFarm=data[3]; return
        end
    end
    for i=#seaTable,1,-1 do
        if AFL.questData[seaTable[i][3]] then AFL.npcToFarm=seaTable[i][3]; return end
    end
end

function afl_findDialogueOption(optionNumber)
    local wanted="option"..tostring(optionNumber)
    local okGui,dialogueGui=pcall(function() return LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") end)
    if okGui and dialogueGui then
        local okDesc,descendants=pcall(function() return dialogueGui:GetDescendants() end)
        if okDesc and descendants then
            local function safeName(object)
                local okName,name=pcall(function() return object.Name end)
                return okName and type(name)=="string" and string.lower(name) or ""
            end
            local function ancestorContains(object,fragment)
                local current=object
                for _=1,16 do
                    if not current or current==dialogueGui then break end
                    if string.find(safeName(current),fragment,1,true) then return true end
                    local okParent,parent=pcall(function() return current.Parent end)
                    if not okParent then break end
                    current=parent
                end
                return false
            end
            local fallback=nil
            for _,object in pairs(descendants) do
                local name=safeName(object)
                if name=="textlabel" and ancestorContains(object,"button")
                    and ancestorContains(object,wanted) and ancestorContains(object,"optionslist") then
                    local okBounds,p,s=pcall(function() return object.AbsolutePosition,object.AbsoluteSize end)
                    if okBounds and p and s and type(p.X)=="number" and type(p.Y)=="number"
                        and type(s.X)=="number" and type(s.Y)=="number" and s.X>0 and s.Y>0 then
                        return object,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                    end
                elseif name=="fill" and ancestorContains(object,"word1") and ancestorContains(object,"button")
                    and ancestorContains(object,wanted) and ancestorContains(object,"optionslist") then
                    local okBounds,p,s=pcall(function() return object.AbsolutePosition,object.AbsoluteSize end)
                    if okBounds and p and s and type(p.X)=="number" and type(p.Y)=="number"
                        and type(s.X)=="number" and type(s.Y)=="number" and s.X>0 and s.Y>0 then
                        return object,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                    end
                elseif not fallback and name=="button" and ancestorContains(object,wanted) then
                    fallback=object
                end
            end
            if fallback then
                local okBounds,p,s=pcall(function() return fallback.AbsolutePosition,fallback.AbsoluteSize end)
                if okBounds and p and s and p.X and p.Y and s.X and s.Y then
                    return fallback,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                end
            end
        end
    end

    local okOld,oldDialogue=pcall(function() return LocalPlayer.PlayerGui.Main.Dialogue end)
    local oldButton=okOld and oldDialogue and oldDialogue:FindFirstChild("Option"..tostring(optionNumber)) or nil
    if oldButton then
        local okBounds,p,s=pcall(function() return oldButton.AbsolutePosition,oldButton.AbsoluteSize end)
        if okBounds and p and s and p.X and p.Y and s.X and s.Y then
            return oldButton,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
        end
    end
    return nil,nil
end

function afl_waitDialogueOption(optionNumber,timeout,notAddress)
    local started=os.clock()
    local lastObject,lastCenter=nil,nil
    while os.clock()-started<(timeout or 3) do
        local object,center=afl_findDialogueOption(optionNumber)
        if object and center then
            lastObject,lastCenter=object,center
            local address=nil
            pcall(function() address=object.Address end)
            if not notAddress or not address or address~=notAddress then return object,center end
        end
        wait(0.05)
    end
    return lastObject,lastCenter
end

local AFL_QUEST_OFFSET_X=70
local AFL_QUEST_OFFSET_Y=50

function afl_clickDialogueOption(optionNumber,timeout,notAddress)
    local object,center=afl_waitDialogueOption(optionNumber,timeout,notAddress)
    if not object or not center then return false,nil end
    if not afl_jitterClick(center.X+AFL_QUEST_OFFSET_X,center.Y+AFL_QUEST_OFFSET_Y) then return false,nil end
    mouse1press(); wait(0.1); mouse1release()
    local address=nil
    pcall(function() address=object.Address end)
    return true,address
end

function afl_setQuest()
    if not AFL.enableGetQuest then return false end
    local quest=AFL.questData and AFL.questData[AFL.npcToFarm]
    if not quest then return false end

    wait(0.5)
    mouse1press(); wait(0.08); mouse1release()
    wait(1)

    local originalOption1=nil
    local initialOption1=afl_waitDialogueOption(1,3)
    if initialOption1 then pcall(function() originalOption1=initialOption1.Address end) end

    local selected=afl_clickDialogueOption(quest.questButton,3)
    if not selected then return false end
    wait(0.35)

    local accepted=afl_clickDialogueOption(1,3,originalOption1)
    if not accepted then
        wait(0.4)
        accepted=afl_clickDialogueOption(1,1)
    end
    return accepted==true
end

function afl_getNextNpc()
    local quest=AFL.questData[AFL.npcToFarm]; if not quest then return end
    local _,root=afl_getCharacter(); if not root then return end
    local cur=root.Position; local best,bestD=nil,math.huge
    local wanted=string.lower(quest.enemy)
    local now=os.clock()
    if AFL.nextNpcCache and now-(AFL.nextNpcCacheTime or 0)<0.12 then
        local cached=AFL.nextNpcCache
        local okCached,aliveCached=pcall(function()
            return cached and cached.Parent and cached:FindFirstChildOfClass("Humanoid")
                and cached:FindFirstChildOfClass("Humanoid").Health>0
                and string.find(string.lower(cached.Name),wanted,1,true)
        end)
        if okCached and aliveCached then return cached end
        AFL.nextNpcCache=nil
    end
    local folder=workspace:FindFirstChild("Enemies")
    if not folder then return end
    local ok,enemies=pcall(function() return folder:GetChildren() end)
    if not ok or not enemies then return end
    for _,enemy in pairs(enemies) do
        if enemy and enemy.Parent and enemy:IsA("Model") then
            local hrp=enemy:FindFirstChild("HumanoidRootPart")
            local hum=enemy:FindFirstChildOfClass("Humanoid")
            local enemyName=""
            pcall(function() enemyName=string.lower(enemy.Name) end)
            if hrp and hum and hum.Health>0 and string.find(enemyName,wanted,1,true) then
                local dx=hrp.Position.X-cur.X; local dy=hrp.Position.Y-cur.Y; local dz=hrp.Position.Z-cur.Z
                local d=dx*dx+dy*dy+dz*dz
                if d<bestD then bestD=d; best=enemy end
            end
        end
    end
    AFL.nextNpcCache=best
    AFL.nextNpcCacheTime=now
    return best
end

function afl_farmNpcs()
    local kills=0
    afl_getLevels()
    if not AFL.npcToFarm then wait(1); return end
    local function pressNevermind()
        afl_clickDialogueOption(3,1)
    end
    if farmPriorityBlocked() then return end
    if AFL.islandPositions[AFL.npcToFarm] and AFL.waitPositions[AFL.npcToFarm] then
        if farmPriorityBlocked() then return end
        afl_teleportTo(AFL.islandPositions[AFL.npcToFarm])
        wait(0.5); afl_setQuest(); wait(0.5)
        afl_teleportToWait(AFL.npcToFarm); wait(0.5)
    end
    while S.autoFarmLevel do
        if farmPriorityBlocked() then wait(0.1); continue end
        local curLevel=afl_readLevel()
        if curLevel and curLevel~=AFL.lastLevel then
            AFL.lastLevel=curLevel; local old=AFL.npcToFarm; afl_getLevels()
            if old~=AFL.npcToFarm and AFL.npcToFarm and AFL.islandPositions[AFL.npcToFarm] then
                kills=0; afl_teleportTo(AFL.islandPositions[AFL.npcToFarm])
                wait(0.5); afl_setQuest(); wait(0.5)
                afl_teleportToWait(AFL.npcToFarm); wait(0.5)
                continue
            end
        end
        local quest=AFL.questData[AFL.npcToFarm]
        local maxKills=quest and quest.ammountToKill or 8
        if kills>=maxKills then
            kills=0
            afl_teleportTo(AFL.islandPositions[AFL.npcToFarm]); wait(0.5)
            afl_setQuest(); wait(0.5)
            afl_teleportToWait(AFL.npcToFarm); wait(0.5)
        end
        if AFL.selectedNpc and AFL.questData[AFL.npcToFarm] then
            if not string.find(AFL.selectedNpc.Name,AFL.questData[AFL.npcToFarm].enemy,1,true) then AFL.selectedNpc=nil end
        end
        if not AFL.selectedNpc or not AFL.selectedNpc.Parent then
            local attempts=0
            repeat AFL.selectedNpc=afl_getNextNpc(); attempts=attempts+1; wait(0.05) until AFL.selectedNpc or attempts>15
            if not AFL.selectedNpc then
                if AFL.waitPositions[AFL.npcToFarm] then afl_teleportToWait(AFL.npcToFarm) end
                wait(0.5); continue
            end
        end
        local hrp=AFL.selectedNpc:FindFirstChild("HumanoidRootPart")
        local hum=AFL.selectedNpc:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then AFL.selectedNpc=nil; wait(0.05); continue end
        local fightStart=os.clock()
        local lastClick=0
        local lastRemoteAttack=0
        local reachedNpc=false
        local targetHead=AFL.selectedNpc:FindFirstChild("Head")
        local originalHeadSize=nil
        local originalHeadCanCollide=nil
        if targetHead then
            pcall(function()
                originalHeadSize=targetHead.Size
                originalHeadCanCollide=targetHead.CanCollide
            end)
        end
        while hum and hum.Health>0 and AFL.selectedNpc.Parent and S.autoFarmLevel and not farmPriorityBlocked() do
            if not hrp or not hrp.Parent then break end
            if os.clock()-fightStart>50 then pressNevermind(); AFL.selectedNpc=nil; break end
            local char,playerHrp=afl_getCharacter()
            if not char or not playerHrp then break end

            local okEnemy,enemyPos=pcall(function() return hrp.Position end)
            local okPlayer,playerPos=pcall(function() return playerHrp.Position end)
            if not okEnemy or not okPlayer or not enemyPos or not playerPos then break end
            if not enemyPos.X or not enemyPos.Y or not enemyPos.Z or not playerPos.X or not playerPos.Y or not playerPos.Z then break end

            local head=AFL.selectedNpc:FindFirstChild("Head") or targetHead

            if S.remoteMode then

                local ox,oy,oz=getNormalFarmOffsets()
                local targetPos=Vector3.new(enemyPos.X+ox,enemyPos.Y+oy,enemyPos.Z+oz)
                if not reachedNpc then
                    tweenTo(playerHrp,targetPos,S.FARM_SPEED,function()
                        return S.autoFarmLevel and S.remoteMode and not farmPriorityBlocked() and isAlive(AFL.selectedNpc)
                    end)
                    reachedNpc=true
                else
                    hardLockNpcCFrame(playerHrp,targetPos)
                end
                local now=os.clock()
                if now-lastRemoteAttack>=0.05 then
                    remoteAttack()
                    lastRemoteAttack=now
                end
                wait()
            else

                if head then
                    local size=S.bigHitbox and 200 or 50
                    head.Size=Vector3.new(size,size,size)
                    head.CanCollide=false
                end
                local hasSanguine=false
                local backpack=LocalPlayer:FindFirstChild("Backpack")
                if backpack and backpack:FindFirstChild("Sanguine Art") then hasSanguine=true end
                if char:FindFirstChild("Sanguine Art") then hasSanguine=true end
                local ox,oy,oz
                if S.customOffset then
                    ox,oy,oz=S.customOffsetX,S.customOffsetY,S.customOffsetZ
                elseif hasSanguine then
                    ox,oy,oz=0,23,10
                else
                    ox,oy,oz=0,23,0
                end
                local targetPos=Vector3.new(enemyPos.X+ox,enemyPos.Y+oy,enemyPos.Z+oz)
                if not reachedNpc then
                    tweenTo(playerHrp,targetPos,S.FARM_SPEED,function()
                        return S.autoFarmLevel and not S.remoteMode and not farmPriorityBlocked() and isAlive(AFL.selectedNpc)
                    end)
                    reachedNpc=true
                else
                    hardLockNpcCFrame(playerHrp,targetPos)
                end
                local now=os.clock()
                if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                wait()
            end
            hrp=AFL.selectedNpc:FindFirstChild("HumanoidRootPart")
            hum=AFL.selectedNpc:FindFirstChildOfClass("Humanoid")
        end
        if targetHead and targetHead.Parent and originalHeadSize then
            pcall(function()
                targetHead.Size=originalHeadSize
                if originalHeadCanCollide~=nil then targetHead.CanCollide=originalHeadCanCollide end
            end)
        end
        if hum and hum.Health<=0 then kills=kills+1; AFL.selectedNpc=nil end
    end
end

task.spawn(function()
    while true do
        if S.autoFarmLevel and not farmPriorityBlocked() and not AFL.farmLoopRunning then
            AFL.farmLoopRunning=true
            local ok=pcall(afl_farmNpcs)
            AFL.farmLoopRunning=false
            AFL.selectedNpc=nil
            AFL.nextNpcCache=nil
            if not ok then wait(0.5) end
        end
        wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if S.fruitEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            for _, entry in pairs(S.espLabels) do
                if entry and entry.label and entry.part and hrp then
                    local screenPos, onScreen=WorldToScreen(entry.part.Position)
                    entry.label.Visible=onScreen
                    if onScreen then entry.label.Position=Vector2.new(screenPos.X,screenPos.Y-20) end
                end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.chestEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local okPlayer,playerPos=pcall(function() return hrp and hrp.Position end)
            for _,entry in pairs(S.chestEspLabels) do
                local label=entry and entry.label or nil
                local part=entry and entry.part or nil
                local okParent,parent=pcall(function() return part and part.Parent end)
                local okPos,pos=pcall(function() return part and part.Position end)
                if label and okPlayer and playerPos and okParent and parent and okPos and pos then
                    local dx=pos.X-playerPos.X
                    local dy=pos.Y-playerPos.Y
                    local dz=pos.Z-playerPos.Z
                    local distanceSq=dx*dx+dy*dy+dz*dz
                    if distanceSq<=100000000 then
                        local okScreen,screenPos,onScreen=pcall(function() return WorldToScreen(pos) end)
                        label.Visible=okScreen and onScreen or false
                        if okScreen and onScreen and screenPos then
                            label.Position=Vector2.new(screenPos.X,screenPos.Y-20)
                        end
                    else
                        label.Visible=false
                    end
                elseif label then
                    label.Visible=false
                end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.berryEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local okPlayer,playerPos=pcall(function() return hrp and hrp.Position end)
            for _,entry in pairs(S.berryEspLabels) do
                local label=entry and entry.label or nil
                local part=entry and entry.part or nil
                local okParent,parent=pcall(function() return part and part.Parent end)
                local okPos,pos=pcall(function() return part and part.Position end)
                local visible=false

                if okPlayer and playerPos and okParent and parent and okPos and pos then
                    local dx=pos.X-playerPos.X
                    local dy=pos.Y-playerPos.Y
                    local dz=pos.Z-playerPos.Z
                    local distanceSq=dx*dx+dy*dy+dz*dz
                    if distanceSq<=BERRY_DRAW_DISTANCE_SQ then
                        local okScreen,screenPos,onScreen=pcall(function() return WorldToScreen(pos) end)
                        visible=okScreen and onScreen and screenPos~=nil
                        if visible then
                            if label then label.Position=Vector2.new(screenPos.X,screenPos.Y-18) end
                        end
                    end
                end

                if label then label.Visible=visible end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.boatEsp then
            for _,entry in pairs(S.boatEspEntries) do
                updateWorldBoxEntry(entry)
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.flowerEsp then
            for _,entry in pairs(S.flowerEspEntries) do
                updateWorldBoxEntry(entry)
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.berryEsp then buildBerryEspLabels() end
        if S.flowerEsp and trackedFlowersChanged() then buildFlowerEsp() end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if S.fruitEsp then buildEspLabels(); buildChamBoxes() end
        if S.chestEsp then
            local chestModels=game.Workspace:FindFirstChild("ChestModels")
            if trackedFolderChanged("chests",chestModels) then buildChestEspLabels() end
        end
        if S.boatEsp then
            local boats=game.Workspace:FindFirstChild("Boats")
            if trackedFolderChanged("boats",boats) then buildBoatEsp() end
        end
    end
end)

task.spawn(function()
    while true do
        if S.chamEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            for _, entry in pairs(S.chamBoxes) do
                if entry and entry.part and hrp then
                    local pos=entry.part.Position; local sz=entry.part.Size*0.5
                    local corners={
                        Vector3.new(pos.X-sz.X,pos.Y-sz.Y,pos.Z-sz.Z), Vector3.new(pos.X+sz.X,pos.Y-sz.Y,pos.Z-sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y+sz.Y,pos.Z-sz.Z), Vector3.new(pos.X+sz.X,pos.Y+sz.Y,pos.Z-sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y-sz.Y,pos.Z+sz.Z), Vector3.new(pos.X+sz.X,pos.Y-sz.Y,pos.Z+sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y+sz.Y,pos.Z+sz.Z), Vector3.new(pos.X+sz.X,pos.Y+sz.Y,pos.Z+sz.Z),
                    }
                    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
                    local anyOn=false
                    for _, c in pairs(corners) do
                        local sp,on=WorldToScreen(c)
                        if on then anyOn=true end
                        if sp.X<minX then minX=sp.X end; if sp.Y<minY then minY=sp.Y end
                        if sp.X>maxX then maxX=sp.X end; if sp.Y>maxY then maxY=sp.Y end
                    end
                    if anyOn then
                        entry.lines[1].From=Vector2.new(minX,minY); entry.lines[1].To=Vector2.new(maxX,minY)
                        entry.lines[2].From=Vector2.new(minX,maxY); entry.lines[2].To=Vector2.new(maxX,maxY)
                        entry.lines[3].From=Vector2.new(minX,minY); entry.lines[3].To=Vector2.new(minX,maxY)
                        entry.lines[4].From=Vector2.new(maxX,minY); entry.lines[4].To=Vector2.new(maxX,maxY)
                        for _,l in pairs(entry.lines) do l.Visible=true end
                    else for _,l in pairs(entry.lines) do l.Visible=false end end
                end
            end
        end
        task.wait()
    end
end)

local function doPullLoop(flag, getPoint)
    task.spawn(function()
        while true do
            if flag() then
                local char=LocalPlayer.Character
                local myHrp=char and char:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local pullPoint=getPoint(myHrp)
                    local folder=game.Workspace:FindFirstChild("Enemies")
                    if folder then
                        for _, model in pairs(folder:GetChildren()) do
                            if model:IsA("Model") then
                                task.spawn(function()
                                    local hrp=model:FindFirstChild("HumanoidRootPart")
                                    if hrp then hrp.CanCollide=false; hrp.Position=pullPoint end
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.001)
        end
    end)
end

doPullLoop(function() return S.pullEnemies end,  function(h) return Vector3.new(h.Position.X, h.Position.Y-10, h.Position.Z) end)
doPullLoop(function() return S.buddhaPull end,   function(h) return Vector3.new(h.Position.X+37, h.Position.Y-3, h.Position.Z) end)
doPullLoop(function() return S.customPull end,   function(h) return Vector3.new(h.Position.X+S.customPullX, h.Position.Y+S.customPullY, h.Position.Z+S.customPullZ) end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if S.autoKen then
            if not LocalPlayer:GetAttribute("KenActive") then
                keypress(0x45); task.wait(0.1); keyrelease(0x45)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if S.autoHaki then
            local char=LocalPlayer.Character
            if char and not char:FindFirstChild("HasBuso") then
                pcall(function()
                    setrobloxinput(true)
                    keypress(0x4A)
                    task.wait(0.1)
                    keyrelease(0x4A)
                end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.freezePos and S.freezePosition then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Position=S.freezePosition
                hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.freezeEnemies then
            local folder=game.Workspace:FindFirstChild("Enemies")
            if folder then
                for _, model in pairs(folder:GetChildren()) do
                    if model:IsA("Model") and not S.frozenEnemies[model] then
                        local hrp=model:FindFirstChild("HumanoidRootPart")
                        if hrp then S.frozenEnemies[model]=hrp.Position end
                    end
                end
            end
            for model, frozenPos in pairs(S.frozenEnemies) do
                if model and model.Parent then
                    local hrp=model:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Position=frozenPos
                        hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                    end
                else S.frozenEnemies[model]=nil end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local currentPos=hrp.Position
                local closestModel=nil
                local closestPart=nil
                local closestDistance=math.huge
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj.Name=="EmberTemplate" and obj:IsA("Model") then
                        local part=obj:FindFirstChild("Part") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if part and part:IsA("BasePart") then
                            local emberPos=part.Position
                            local dx=emberPos.X-currentPos.X
                            local dy=emberPos.Y-currentPos.Y
                            local dz=emberPos.Z-currentPos.Z
                            local distance=dx*dx+dy*dy+dz*dz
                            if distance<closestDistance then
                                closestDistance=distance
                                closestModel=obj
                                closestPart=part
                            end
                        end
                    end
                end
                if closestModel and closestPart then
                    local emberPos=closestPart.Position
                    local targetPos=Vector3.new(emberPos.X,emberPos.Y+3,emberPos.Z)
                    tweenTo(hrp,targetPos,1200,function()
                        return S.tweenEmber and closestModel.Parent and closestPart.Parent
                    end)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                    task.wait(0.08)
                else
                    task.wait(0.2)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.teleportEmber and not S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _,obj in pairs(game.Workspace:GetChildren()) do
                    if obj.Name=="EmberTemplate" and obj:IsA("Model") then
                        local part=obj:FindFirstChild("Part")
                        if part and part:IsA("BasePart") then
                            hrp.Position=Vector3.new(part.Position.X,part.Position.Y+3,part.Position.Z)
                            hrp.Velocity=Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.teleportEmber and not S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity=Vector3.new(0,1,0)
                hrp.AssemblyLinearVelocity=Vector3.new(0,1,0)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if S.teleportKitsune then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local map=game.Workspace:FindFirstChild("Map")
                if map then
                    local kitsune=map:FindFirstChild("KitsuneIsland")
                    if kitsune then
                        local lampPost=kitsune:FindFirstChild("LampPost")
                        if lampPost then
                            local part=lampPost:FindFirstChild("Part")
                            if part and part:IsA("BasePart") then
                                local startPos=hrp.Position
                                local endPos=Vector3.new(part.Position.X, part.Position.Y+3, part.Position.Z)
                                local duration=2; local startTime=os.clock()
                                while S.teleportKitsune and os.clock()-startTime<duration do
                                    local progress=(os.clock()-startTime)/duration
                                    hrp.Position=Vector3.new(
                                        startPos.X+(endPos.X-startPos.X)*progress,
                                        startPos.Y+(endPos.Y-startPos.Y)*progress,
                                        startPos.Z+(endPos.Z-startPos.Z)*progress
                                    )
                                    task.wait(0.05)
                                end
                                if S.teleportKitsune then
                                    hrp.Position=endPos
                                    hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.teleportKitsune then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.autoRaid or S.autoBossFarm or S.autoMaterialFarm or S.autoSeaEvent or S.autoMirageTween or S.autoMirageGear or S.fruitPriorityActive then
            S.raidDetected=false
            S.raidTweenActive=false
            S.raidLastIslandNum=0
            S.raidLastIslandKey=nil
            S.raidMapKey=nil
        else
            local map=game.Workspace:FindFirstChild("Map")
            local raidMap=map and map:FindFirstChild("RaidMap")
            local origin=game.Workspace:FindFirstChild("_WorldOrigin")
            local locations=origin and origin:FindFirstChild("Locations")
            local raidContainer=raidMap
            if not raidContainer and locations then
                for index=1,5 do
                    if locations:FindFirstChild("Island "..tostring(index)) then raidContainer=locations; break end
                end
            end
            if not raidContainer then
                S.raidDetected=false
                if S.raidMapKey~=nil or S.raidTweenActive then
                    S.raidMoveGeneration=S.raidMoveGeneration+1
                end
                S.raidTweenActive=false
                S.raidLastIslandNum=0
                S.raidLastIslandKey=nil
                S.raidMapKey=nil
            else
                S.raidDetected=true
                local currentMapKey=trackedInstanceKey(raidContainer)
                if S.raidMapKey~=currentMapKey then
                    if S.raidMapKey~=nil or S.raidTweenActive then
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                    end
                    S.raidTweenActive=false
                    S.raidMapKey=currentMapKey
                    S.raidLastIslandNum=0
                    S.raidLastIslandKey=nil
                end

                local highestIsland=0
                local highestIslandModel=nil
                for _,child in pairs(raidContainer:GetChildren()) do
                    local name=child.Name
                    local num=nil
                    if type(name)=="string" and string.sub(name,1,10)=="RaidIsland" then
                        num=tonumber(string.sub(name,11))
                    elseif type(name)=="string" and string.sub(name,1,7)=="Island " then
                        num=tonumber(string.sub(name,8))
                    end
                    if num and num>highestIsland then
                        highestIsland=num
                        highestIslandModel=child
                    end
                end

                if not highestIslandModel then
                    if S.raidLastIslandKey~=nil or S.raidTweenActive then
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                    end
                    S.raidTweenActive=false
                    S.raidLastIslandNum=0
                    S.raidLastIslandKey=nil
                else
                    local islandKey=trackedInstanceKey(highestIslandModel)
                    if islandKey~=S.raidLastIslandKey then
                        S.raidLastIslandNum=highestIsland
                        S.raidLastIslandKey=islandKey
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                        local moveGeneration=S.raidMoveGeneration
                        S.raidTweenActive=true
                        notify("Raid Island "..highestIsland.." - Going there!","laced.club",2)
                        task.spawn(function()
                            local cpos=nil
                            for _=1,10 do
                                local okParent,islandParent=pcall(function() return highestIslandModel.Parent end)
                                if not okParent or not islandParent then break end
                                local candidates={}
                                local okSelf,isSelfPart=pcall(function() return highestIslandModel:IsA("BasePart") end)
                                if okSelf and isSelfPart then table.insert(candidates,highestIslandModel) end
                                local okPrimary,primaryPart=pcall(function() return highestIslandModel.PrimaryPart end)
                                if okPrimary and primaryPart then table.insert(candidates,primaryPart) end
                                local okParts,parts=pcall(function() return highestIslandModel:GetDescendants() end)
                                if okParts and parts then
                                    for _,part in pairs(parts) do
                                        if part:IsA("BasePart") then table.insert(candidates,part) end
                                    end
                                end
                                for _,part in pairs(candidates) do
                                    local okPos,pos=pcall(function() return part.Position end)
                                    if okPos and pos and pos.X then cpos=pos; break end
                                end
                                if cpos then break end
                                task.wait(0.3)
                            end

                            local myHrp=nil
                            if cpos then
                                for _=1,30 do
                                    local character=LocalPlayer.Character
                                    myHrp=character and character:FindFirstChild("HumanoidRootPart")
                                    if myHrp then break end
                                    task.wait(0.2)
                                end
                            end

                            if cpos and myHrp and S.autoRaid and S.raidMoveGeneration==moveGeneration then
                                local target=Vector3.new(cpos.X,cpos.Y+100,cpos.Z)
                                local startPos=myHrp.Position
                                local dx=target.X-startPos.X
                                local dy=target.Y-startPos.Y
                                local dz=target.Z-startPos.Z
                                local dist=math.sqrt(dx*dx+dy*dy+dz*dz)
                                local speed=math.max(tonumber(S.RAID_TWEEN_SPEED) or 320,1)
                                local duration=math.max(dist/speed,0.01)
                                local startedAt=os.clock()
                                while S.autoRaid and S.raidMoveGeneration==moveGeneration do
                                    local character=LocalPlayer.Character
                                    local hrp=character and character:FindFirstChild("HumanoidRootPart")
                                    if not hrp then task.wait(0.1); continue end
                                    local alpha=math.min((os.clock()-startedAt)/duration,1)
                                    pcall(function()
                                        hrp.CFrame=CFrame.new(
                                            startPos.X+dx*alpha,
                                            startPos.Y+dy*alpha,
                                            startPos.Z+dz*alpha
                                        )
                                        hrp.Velocity=Vector3.new(0,0,0)
                                        hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                    end)
                                    if alpha>=1 then notify("Arrived!","laced.club",2); break end
                                    task.wait(0.01)
                                end
                            end

                            if S.raidMoveGeneration==moveGeneration then S.raidTweenActive=false end
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoRaid and S.raidDetected and not S.raidTweenActive and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local useRemote=S.remoteMode
                farmAttack(
                    hrp,
                    function()
                        return S.autoRaid and S.raidDetected and not S.raidTweenActive and not farmPriorityBlocked() and S.remoteMode==useRemote
                    end,
                    nil,
                    true,
                    1000,
                    useRemote and remoteAttack or nil,
                    useRemote and 0.05 or 0.06
                )
            end
            task.wait(0.1)
        else task.wait(0.1) end
    end
end)

task.spawn(function()
    while true do
        if S.voidPull then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Position=Vector3.new(hrp.Position.X,100000,hrp.Position.Z); hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.skyPull then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Position=Vector3.new(hrp.Position.X,1000,hrp.Position.Z); hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
        task.wait()
    end
end)

function isPvpTargetDead(char)
    if not char or not char.Parent then return true end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return true end
    return false
end

task.spawn(function()
    local pvpTarget=nil
    while true do
        if S.pvpFarmLoop then
            local char=LocalPlayer.Character
            local myHrp=char and char:FindFirstChild("HumanoidRootPart")
            if myHrp then
                if isPvpTargetDead(pvpTarget) then
                    pvpTarget=nil
                    local nearest, bestDist=nil, math.huge
                    local myName=LocalPlayer.Name
                    local myTeamName=(LocalPlayer.Team and LocalPlayer.Team.Name) or ""
                    local charsFolder=game.Workspace:FindFirstChild("Characters")
                    if charsFolder then
                        for _, c in pairs(charsFolder:GetChildren()) do
                            if c:IsA("Model") and c.Name~=myName then
                                local root=c:FindFirstChild("HumanoidRootPart")
                                local hum=c:FindFirstChildOfClass("Humanoid")
                                if root and hum and hum.Health>0 then
                                    local skip=false
                                    if myTeamName=="Marines" then
                                        local tp=Players:FindFirstChild(c.Name)
                                        if tp and tp.Team and tp.Team.Name=="Marines" then skip=true end
                                    end
                                    if not skip then
                                        local dx=root.Position.X-myHrp.Position.X
                                        local dy=root.Position.Y-myHrp.Position.Y
                                        local dz=root.Position.Z-myHrp.Position.Z
                                        local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                                        if d<bestDist then bestDist=d; nearest=c end
                                    end
                                end
                            end
                        end
                    end
                    if nearest then pvpTarget=nearest end
                end
                if pvpTarget and not isPvpTargetDead(pvpTarget) then
                    local enemyRoot=pvpTarget:FindFirstChild("HumanoidRootPart")
                    if enemyRoot then
                        task.spawn(function()
                            while S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                local eh=pvpTarget:FindFirstChild("HumanoidRootPart")
                                local hd=pvpTarget:FindFirstChild("Head")
                                if eh then eh.CanCollide=false end
                                if hd then hd.CanCollide=false end
                                task.wait()
                            end
                        end)
                        local startX=myHrp.Position.X; local startY=myHrp.Position.Y; local startZ=myHrp.Position.Z
                        local tx=enemyRoot.Position.X+20; local ty=enemyRoot.Position.Y; local tz=enemyRoot.Position.Z
                        local dx=tx-startX; local dy=ty-startY; local dz=tz-startZ
                        local duration=math.sqrt(dx*dx+dy*dy+dz*dz)/320; local t0=os.clock()
                        while S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                            local alpha=math.min((os.clock()-t0)/duration,1)
                            myHrp.CFrame=CFrame.new(startX+dx*alpha,startY+dy*alpha,startZ+dz*alpha)
                            if alpha>=1 then break end; task.wait(0.01)
                        end
                        local lastClick=0
                        local attackStart=os.clock()
                        while os.clock()-attackStart<2 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                            local tr=pvpTarget:FindFirstChild("HumanoidRootPart")
                            if tr then
                                myHrp.Position=Vector3.new(tr.Position.X+20, tr.Position.Y, tr.Position.Z)
                                myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            end
                            local now=os.clock()
                            if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                            task.wait()
                        end
                        if S.pvpFarmLoop then
                            local savedX=myHrp.Position.X; local savedZ=myHrp.Position.Z
                            local upStart=os.clock()
                            while os.clock()-upStart<5 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                myHrp.Position=Vector3.new(savedX,10000000,savedZ)
                                myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                task.wait(0.1)
                            end
                            local dHrp=pvpTarget:FindFirstChild("HumanoidRootPart")
                            local groundY=dHrp and dHrp.Position and dHrp.Position.Y or 0
                            myHrp.Position=Vector3.new(savedX,groundY,savedZ)
                            myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            task.wait(0.2)
                            if S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) then
                                local a2=os.clock()
                                while os.clock()-a2<0.5 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                    local tr2=pvpTarget:FindFirstChild("HumanoidRootPart")
                                    if tr2 then
                                        myHrp.Position=Vector3.new(tr2.Position.X+20,tr2.Position.Y,tr2.Position.Z)
                                        myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                    end
                                    local now=os.clock()
                                    if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                                    task.wait()
                                end
                            end
                        end
                    end
                else task.wait(0.5) end
            else task.wait(0.5) end
        else pvpTarget=nil; task.wait(0.5) end
    end
end)

do
    local aura = {
        enabled       = false,
        maxDist       = 100,
        minDist       = 1,
        sessionId     = "32501259",
        targetCount   = 0,
        firstName     = "None",
        regAtk        = nil,
        regHit        = nil,
    }

    local function aura_ensureRemotes()
        if aura.regAtk and aura.regHit then return true end
        local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        if net then net = net:FindFirstChild("Net") end
        if not net then return false end
        aura.regAtk = net:FindFirstChild("RE/RegisterAttack")
        aura.regHit = net:FindFirstChild("RE/RegisterHit")
        return aura.regAtk ~= nil and aura.regHit ~= nil
    end

    local function aura_getTargetPart(enemy)
        if not enemy or not enemy.Parent then return nil end
        local p = enemy:FindFirstChild("LeftLowerLeg")
        if p and p:IsA("BasePart") then return p end
        p = enemy:FindFirstChild("Head")
        if p and p:IsA("BasePart") then return p end
        p = enemy:FindFirstChild("HumanoidRootPart")
        if p and p:IsA("BasePart") then return p end
        for _, c in ipairs(enemy:GetChildren()) do
            if c:IsA("BasePart") then return c end
        end
        return nil
    end

    local function aura_getEnemies()
        local char = LocalPlayer.Character
        if not char then return {} end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {} end
        local myPos = hrp.Position
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return {} end
        local results = {}
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy and enemy.Parent then
                local hum = enemy:FindFirstChild("Humanoid")
                if hum and hum.Health and hum.Health > 0 then
                    local part = aura_getTargetPart(enemy)
                    if part and part.Parent then
                        local ok, pos = pcall(function() return part.Position end)
                        if ok and pos then
                            local dx=pos.X-myPos.X
                            local dy=pos.Y-myPos.Y
                            local dz=pos.Z-myPos.Z
                            local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                            if d <= aura.maxDist and d >= aura.minDist then
                                table.insert(results, {enemy=enemy, part=part, dist=d})
                            end
                        end
                    end
                end
            end
        end
        return results
    end

    local function aura_attack(list)
        if #list == 0 then return end
        local hitTable = {}
        local primary = nil
        for _, entry in ipairs(list) do
            if entry.enemy and entry.enemy.Parent and entry.part and entry.part.Parent then
                table.insert(hitTable, {entry.enemy, entry.part})
                if not primary then primary = entry.part end
            end
        end
        if #hitTable == 0 then return end
        pcall(function() aura.regAtk:FireServer(0.5) end)
        task.wait()
        pcall(function() aura.regHit:FireServer(primary, hitTable, nil, aura.sessionId) end)
    end

    mainTab:AddSection("NPC Aura", { Column = 1 })
    mainTab:AddToggle("npc_aura", {
        Text="NPC Aura", Description="Fires RegisterHit on all NPCs within range. MATCHA PRO ONLY!",
        Default=false, Keybind=true, Column=1,
        Callback=function(v)
            aura.enabled = v
            aura_ensureRemotes()
            notify(v and "NPC Aura ON!" or "NPC Aura OFF!", "laced.club", 2)
        end
    })
    mainTab:AddSlider("npc_aura_range", {
        Text="Aura Range", Description="Max distance to hit NPCs (studs)",
        Min=10, Max=300, Default=100, Integer=true, Column=1,
        Callback=function(v) aura.maxDist = v end
    })

    task.spawn(function()
        while true do
            if aura.enabled then
                if aura_ensureRemotes() then
                    local enemies = aura_getEnemies()
                    aura.targetCount = #enemies
                    if aura.targetCount > 0 then
                        table.sort(enemies, function(a,b) return a.dist < b.dist end)
                        aura.firstName = enemies[1].enemy.Name or "Unknown"
                    else
                        aura.firstName = "None"
                    end
                    aura_attack(enemies)
                end
                task.wait(0.05)
            else
                task.wait(0.1)
            end
        end
    end)
end

do
    local sessionId = "325bb15e"
    local minDist   = 1
    local regAtk, regHit = nil, nil

    local function pvp_ensureRemotes()
        if regAtk and regHit then return true end
        local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        if net then net = net:FindFirstChild("Net") end
        if not net then return false end
        regAtk = net:FindFirstChild("RE/RegisterAttack")
        regHit = net:FindFirstChild("RE/RegisterHit")
        return regAtk ~= nil and regHit ~= nil
    end

    local function pvp_getTarget()
        local char = LocalPlayer.Character
        if not char then return nil, nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil end
        local myPos = hrp.Position
        local closest, closestDist = nil, _pvpAuraMaxDist + 1
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local c = player.Character
            if c then
                local root = c:FindFirstChild("HumanoidRootPart")
                if root then
                    local rootPos=root.Position
                    local dx=rootPos.X-myPos.X
                    local dy=rootPos.Y-myPos.Y
                    local dz=rootPos.Z-myPos.Z
                    local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                    if d < closestDist and d >= minDist then
                        closestDist = d; closest = player
                    end
                end
            end
        end
        if not closest then return nil, nil end
        local tc = closest.Character
        if not tc then return nil, nil end
        local partName = _pvpAuraAltPart and "ModelHitbox" or "Head"
        local part = tc:FindFirstChild(partName) or tc:FindFirstChild("Head")
        if not part or part:IsDescendantOf(LocalPlayer.Character) then return nil, nil end
        return closest, part
    end

    local function pvp_attack(part)
        if not part then return end
        pcall(function() regAtk:FireServer(0.5) end)
        task.wait()
        pcall(function() regHit:FireServer(part, {}, nil, sessionId) end)
    end

    task.spawn(function()
        while true do
            if _pvpAuraEnabled then
                if pvp_ensureRemotes() then
                    local player, part = pvp_getTarget()
                    pvp_attack(part)
                end
                task.wait(0.05)
            else
                task.wait(0.1)
            end
        end
    end)
end

do
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

    local FishConfig = {
        CastTarget     = 0.96,
        WaitBeforeReel = 0.2,
        DeadZone       = 0.35,
        BiteTimeout    = 20,
        ResetDelay     = 2,
    }

    local FishState = {
        Running        = false,
        IsHolding      = false,
        CastComplete   = false,
        FishDetected   = false,
        WaitingForUI   = false,
        ReelingStarted = false,
        WaitStart      = 0,
        Clicks         = 0,
        FishCaught     = 0,
        LastCastTime   = 0,
        BiteClickTime  = 0,
    }

    local function fish_hold()
        if not FishState.IsHolding then FishState.IsHolding=true; pcall(mouse1press); FishState.Clicks=FishState.Clicks+1 end
    end
    local function fish_release()
        if FishState.IsHolding then FishState.IsHolding=false; pcall(mouse1release) end
    end
    local function fish_click()
        pcall(mouse1click); FishState.Clicks=FishState.Clicks+1
    end

    local function fish_fullReset()
        fish_release()
        FishState.CastComplete=false
        FishState.FishDetected=false
        FishState.WaitingForUI=false
        FishState.ReelingStarted=false
        FishState.WaitStart=0
        FishState.LastCastTime=0
        FishState.BiteClickTime=0
        task.wait(FishConfig.ResetDelay)
    end

    local function fish_getCastFrame()
        local char=LocalPlayer.Character; if not char then return nil end
        local part=char:FindFirstChild("Fishing_Cast Meter"); if not part then return nil end
        local meter=part:FindFirstChild("CastMeter"); if not meter then return nil end
        local bar=meter:FindFirstChild("Bar"); if not bar then return nil end
        return bar:FindFirstChild("Frame")
    end

    local function fish_getCastFill()
        local frame=fish_getCastFrame(); if not frame then return 0 end
        local ok1,size=pcall(function() return frame.AbsoluteSize.Y end)
        local ok2,max=pcall(function() return frame.Parent.AbsoluteSize.Y end)
        if ok1 and ok2 and size and max and max>0 then return size/max end
        return 0
    end

    local function fish_getReelUI()
        if not PlayerGui or not PlayerGui.Parent then PlayerGui=LocalPlayer:FindFirstChild("PlayerGui") end
        if not PlayerGui then return nil end
        local ui=PlayerGui:FindFirstChild("Fishing_Reeling"); if not ui then return nil end
        local mini=ui:FindFirstChild("Minigame") or ui:FindFirstChild("MiniGame"); if not mini then return nil end
        local con=mini:FindFirstChild("Container"); if not con then return nil end
        local treasure=con:FindFirstChild("Treasure")
        local treasureIcon=treasure and (treasure:FindFirstChild("UnopenedIcon") or treasure:FindFirstChild("OpenedIcon")) or nil
        return {
            Fish=con:FindFirstChild("Fish"),
            Treasure=treasureIcon,
            Zone=con:FindFirstChild("ReelZone") or con:FindFirstChild("Zone")
        }
    end

    local function fish_isReelOpen()
        if not PlayerGui or not PlayerGui.Parent then PlayerGui=LocalPlayer:FindFirstChild("PlayerGui") end
        return PlayerGui and PlayerGui:FindFirstChild("Fishing_Reeling") ~= nil
    end

    local function fish_getCenter(obj)
        if not obj then return 0 end
        local ok1,x=pcall(function() return obj.AbsolutePosition.X end)
        local ok2,w=pcall(function() return obj.AbsoluteSize.X end)
        if ok1 and ok2 and x and w then return x+w/2 end
        return 0
    end

    local function fish_getFishSound()
        local char=LocalPlayer.Character; if not char then return nil end
        local rod=char:FindFirstChild("Fishing Rod"); if not rod then return nil end
        local part=rod:FindFirstChild("Fishing Rod"); if not part then return nil end
        local metal=part:FindFirstChild("Metal"); if not metal then return nil end
        return metal:FindFirstChild("FishOnLine")
    end

    local function fish_isBiting()
        if fish_getFishSound() then return true end
        local char=LocalPlayer.Character
        if not char then return false end
        local okDesc,descendants=pcall(function() return char:GetDescendants() end)
        if not okDesc or not descendants then return false end
        for _,object in pairs(descendants) do
            local okName,name=pcall(function() return string.lower(object.Name or "") end)
            if okName and (string.find(name,"fishonline",1,true) or string.find(name,"fish on line",1,true)) then
                return true
            end
        end
        return false
    end

    local function fish_isZoneLeft(ui)
        if not ui then return false end
        local fish=fish_getCenter(ui.Treasure or ui.Fish); local zone=fish_getCenter(ui.Zone)
        if fish==0 or zone==0 then return false end
        return zone < fish - FishConfig.DeadZone
    end

    local function fish_mainLoop()
        FishState.WaitStart=0
        local ending=false; local endTimer=0; local wasOpen=false
        while FishState.Running do
            task.wait(0.05)
            if farmPriorityBlocked() then
                fish_release()
                FishState.CastComplete=false
                FishState.FishDetected=false
                FishState.WaitingForUI=false
                FishState.ReelingStarted=false
                FishState.WaitStart=0
                continue
            end
            if not FishState.CastComplete then
                local frame=fish_getCastFrame()
                if frame then
                    fish_hold()
                    if fish_getCastFill()>=FishConfig.CastTarget then
                        fish_release()
                        FishState.CastComplete=true; FishState.FishDetected=false
                        FishState.WaitingForUI=false; FishState.ReelingStarted=false
                        FishState.WaitStart=0; FishState.LastCastTime=os.clock()
                        ending=false; wasOpen=false
                    end
                else
                    if not FishState.IsHolding then fish_click(); task.wait(0.1) end
                end
                continue
            end
            if FishState.CastComplete and not FishState.FishDetected then
                if os.clock()-FishState.LastCastTime>FishConfig.BiteTimeout then
                    fish_fullReset()
                    continue
                end
                if fish_isBiting() then
                    FishState.FishDetected=true
                    FishState.BiteClickTime=os.clock()
                    fish_click(); task.wait(0.14); fish_click(); task.wait(0.14); fish_click()
                end
                continue
            end
            if FishState.FishDetected then
                local open=fish_isReelOpen()
                if open then
                    wasOpen=true
                    local ui=fish_getReelUI()
                    if ui then
                        if not FishState.WaitingForUI then
                            FishState.WaitingForUI=true; FishState.ReelingStarted=false
                            FishState.WaitStart=os.clock(); ending=false
                        end
                        if not FishState.ReelingStarted then
                            if os.clock()-FishState.WaitStart>=FishConfig.WaitBeforeReel then
                                FishState.ReelingStarted=true; fish_click(); task.wait(0.2); fish_click()
                            end
                            continue
                        end
                        if FishState.ReelingStarted then
                            if fish_isZoneLeft(ui) then fish_hold() else fish_release() end
                        end
                    end
                else
                    if not wasOpen and os.clock()-FishState.BiteClickTime>3 then
                        fish_fullReset()
                        continue
                    end
                    if wasOpen and not ending then
                        ending=true; endTimer=os.clock()
                        FishState.FishCaught=FishState.FishCaught+1
                        fish_release()
                        notify("Fish caught! ("..FishState.FishCaught..")", "laced.club", 2)
                    end
                    if ending then
                        local el=os.clock()-endTimer
                        if el>=0 and el<0.05 then fish_click()
                        elseif el>=0.2 and el<0.25 then fish_click()
                        elseif el>=0.4 and el<0.45 then fish_click()
                        elseif el>=0.5 then
                            FishState.CastComplete=false; FishState.FishDetected=false
                            FishState.WaitingForUI=false; FishState.ReelingStarted=false
                            FishState.WaitStart=0; ending=false; wasOpen=false
                        end
                    end
                    FishState.WaitStart=os.clock()
                end
            end
        end
    end

    mainTab:AddToggle("auto_fish", {
        Text="Auto Fish", Description="Automatically casts, detects fish, and reels.",
        Default=false, Keybind=true, Column=2,
        Callback=function(v)
            S.autoFish=v
            if v then
                S.autoRepair=false
                pcall(function() Window:Set("auto_ship_repair",false) end)
                FishState.Running=true; FishState.CastComplete=false; FishState.FishDetected=false
                FishState.WaitingForUI=false; FishState.ReelingStarted=false
                FishState.WaitStart=0; FishState.Clicks=0; FishState.FishCaught=0
                FishState.LastCastTime=0; FishState.BiteClickTime=0
                task.spawn(fish_mainLoop)
                notify("Auto Fish started!", "laced.club", 2)
            else
                FishState.Running=false; fish_release()
                notify("Auto Fish stopped. Fish: "..FishState.FishCaught, "laced.club", 2)
            end
        end
    })
end

do
    local RepairState={holding=false}

    local function repairRelease()
        if RepairState.holding then
            RepairState.holding=false
            pcall(mouse1release)
        end
    end

    local function repairHold()
        if not RepairState.holding then
            RepairState.holding=true
            pcall(mouse1press)
        end
    end

    local function getRepairBarInfo()
        local playerGui=LocalPlayer:FindFirstChild("PlayerGui")
        local main=playerGui and playerGui:FindFirstChild("Main") or nil
        local bottom=main and main:FindFirstChild("BottomHUDList") or nil
        local mini=bottom and bottom:FindFirstChild("RepairMiniGame") or nil
        local progress=mini and mini:FindFirstChild("ProgressBar") or nil
        local fill=progress and progress:FindFirstChild("Fill") or nil
        local goal=progress and progress:FindFirstChild("Goal") or nil
        if not fill or not goal then return nil end

        local ok,fillPosition,fillSize,goalPosition,goalSize=pcall(function()
            return fill.AbsolutePosition,fill.AbsoluteSize,goal.AbsolutePosition,goal.AbsoluteSize
        end)
        if not ok or not fillPosition or not fillSize or not goalPosition or not goalSize then return nil end
        return {
            fillRight=fillPosition.X+fillSize.X,
            goalLeft=goalPosition.X,
            goalRight=goalPosition.X+goalSize.X
        }
    end

    task.spawn(function()
        while true do
            if S.autoRepair then
                local info=getRepairBarInfo()
                if info then
                    if info.fillRight>=info.goalLeft-8 and info.fillRight<=info.goalRight+14 then
                        repairRelease()
                        task.wait(0.35)
                    else
                        repairHold()
                    end
                else
                    repairRelease()
                end
                task.wait(0.02)
            else
                repairRelease()
                task.wait(0.2)
            end
        end
    end)
end

local MASTERY_WAYPOINTS={
    {pos=Vector3.new(109.6,47.5,-12520.8)},
    {pos=Vector3.new(15.1,47.5,-12567.3)},
    {pos=Vector3.new(61.2,47.5,-12670.0)},
    {pos=Vector3.new(-150.7,47.5,-12666.5)},
    {pos=Vector3.new(86.2,47.5,-12849.6)},
    {pos=Vector3.new(233.5,47.5,-12952.1)},
    {pos=Vector3.new(129.1,47.5,-13049.1)},
    {pos=Vector3.new(-31.2,47.5,-12939.9)},
    {pos=Vector3.new(33.5,47.5,-12790.5),waitTime=5},
    {pos=Vector3.new(59.7,47.5,-12874.7),waitTime=3.2},
    {pos=Vector3.new(-108.3,47.5,-12285.8),look=Vector3.new(-0.980,0,-0.197)},
    {pos=Vector3.new(5.9,47.5,-12249.4)},
    {pos=Vector3.new(114.2,47.5,-12225.0)},
    {pos=Vector3.new(-7.4,47.5,-12257.7),waitTime=5},
    {pos=Vector3.new(594.8,47.5,-12426.1),look=Vector3.new(0.591,0,-0.807)},
    {pos=Vector3.new(617.6,47.5,-12557.3)},
    {pos=Vector3.new(707.3,47.5,-12570.6)},
    {pos=Vector3.new(714.0,47.5,-12708.4)},
    {pos=Vector3.new(820.5,47.5,-12679.7)},
    {pos=Vector3.new(803.9,47.5,-12763.1)},
    {pos=Vector3.new(698.0,47.5,-12605.4),waitTime=4},
    {pos=Vector3.new(676.5,47.5,-12570.8),waitTime=10,forceWait=true},
}
local masteryWaypoint=1
local masteryLastRemoteFired=0
local masteryLookVector=Vector3.new(0.040,0,-0.999)

function masteryTweenTo(hrp,targetPos,lookVector,checkFn)
    if not hrp or not targetPos then return end
    if lookVector then masteryLookVector=lookVector end
    local okStart,startPos=pcall(function() return hrp.Position end)
    if not okStart or not startPos then return end
    local dx=targetPos.X-startPos.X
    local dy=targetPos.Y-startPos.Y
    local dz=targetPos.Z-startPos.Z
    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
    local duration=distance/S.MASTERY_TWEEN_SPEED
    local startTime=os.clock()
    local facingCF=nil
    pcall(function() facingCF=CFrame.lookAt(Vector3.new(0,0,0),masteryLookVector) end)
    while true do
        if checkFn and not checkFn() then return end
        local alpha=distance<0.1 and 1 or math.min((os.clock()-startTime)/duration,1)
        local newX=startPos.X+dx*alpha
        local newY=startPos.Y+dy*alpha
        local newZ=startPos.Z+dz*alpha
        local okMove=pcall(function()
            local positionCF=CFrame.new(newX,newY,newZ)
            hrp.CFrame=facingCF and (positionCF*facingCF) or positionCF
        end)
        if not okMove or alpha>=1 then return end
        task.wait(0.01)
    end
end

function masteryGetTargets(hrp)
    local targets={}
    if not hrp then return targets end
    local okMyPos,myPos=pcall(function() return hrp.Position end)
    local enemies=game.Workspace:FindFirstChild("Enemies")
    if not okMyPos or not myPos or not enemies then return targets end
    local okChildren,children=pcall(function() return enemies:GetChildren() end)
    if not okChildren or not children then return targets end
    for _,enemy in pairs(children) do
        local hum=enemy and enemy:FindFirstChildOfClass("Humanoid") or nil
        if hum and hum.Health and hum.Health>0 then
            local part=enemy:FindFirstChild("LeftLowerLeg") or enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildOfClass("BasePart")
            local okPos,pos=pcall(function() return part and part.Position end)
            if okPos and pos then
                local dx=pos.X-myPos.X
                local dy=pos.Y-myPos.Y
                local dz=pos.Z-myPos.Z
                local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
                if distance>=1 and distance<=120 then table.insert(targets,{enemy,part}) end
            end
        end
    end
    return targets
end

function masteryAttackTargets(targets)
    if not targets or #targets==0 or not ensureRemotes() then return end
    local hitTable={}
    local primary=nil
    for _,entry in pairs(targets) do
        local enemy=entry[1]
        local part=entry[2]
        local okEnemy,enemyParent=pcall(function() return enemy and enemy.Parent end)
        local okPart,partParent=pcall(function() return part and part.Parent end)
        if okEnemy and enemyParent and okPart and partParent then
            table.insert(hitTable,{enemy,part})
            if not primary then primary=part end
        end
    end
    if #hitTable==0 or not primary then return end
    pcall(function() _remoteRegAtk:FireServer(0.5) end)
    task.wait()
    pcall(function() _remoteRegHit:FireServer(primary,hitTable,nil,REMOTE_SESSION_ID) end)
    masteryLastRemoteFired=os.clock()
end

task.spawn(function()
    while true do
        if S.autoMastery and not farmPriorityBlocked() then
            local char=LocalPlayer and LocalPlayer.Character or nil
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local waypoint=MASTERY_WAYPOINTS[masteryWaypoint]
            if hrp and waypoint then
                masteryTweenTo(hrp,waypoint.pos,waypoint.look,function()
                    return S.autoMastery and not farmPriorityBlocked()
                end)
                if S.autoMastery and waypoint.waitTime then
                    local deadline=os.clock()+waypoint.waitTime
                    masteryLastRemoteFired=os.clock()
                    while S.autoMastery and not farmPriorityBlocked() and os.clock()<deadline do
                        if not waypoint.forceWait and os.clock()-masteryLastRemoteFired>=1.5 then break end
                        task.wait(0.1)
                    end
                end
                if S.autoMastery and not farmPriorityBlocked() then
                    masteryWaypoint=(masteryWaypoint%#MASTERY_WAYPOINTS)+1
                end
            else
                task.wait(0.1)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMastery and not farmPriorityBlocked() then
            local char=LocalPlayer and LocalPlayer.Character or nil
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            masteryAttackTargets(masteryGetTargets(hrp))
            task.wait(0.05)
        else
            task.wait(0.1)
        end
    end
end)

function runVelocityBoost(settings,enabledFn,horizontalOnly,lockedDirection)
    if not settings then return end
    task.wait(settings.delay)
    if not enabledFn() then return end

    local char=LocalPlayer and LocalPlayer.Character or nil
    local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
    if not hrp then return end

    local direction=lockedDirection
    if not direction then
        pcall(function()
            local velocity=hrp.AssemblyLinearVelocity
            if not velocity then return end
            local dx,dy,dz=velocity.X,velocity.Y,velocity.Z
            if horizontalOnly then dy=0 end
            local magnitude=math.sqrt(dx*dx+dy*dy+dz*dz)
            if magnitude>0.1 then
                direction=Vector3.new(dx/magnitude,dy/magnitude,dz/magnitude)
            end
        end)
    end
    if not direction then return end

    local endTime=os.clock()+settings.duration
    while os.clock()<endTime and enabledFn() do
        local currentChar=LocalPlayer and LocalPlayer.Character or nil
        local currentHrp=currentChar and currentChar:FindFirstChild("HumanoidRootPart") or nil
        if not currentHrp then return end
        pcall(function()
            currentHrp.AssemblyLinearVelocity=Vector3.new(
                direction.X*settings.speed,
                horizontalOnly and 0 or direction.Y*settings.speed,
                direction.Z*settings.speed
            )
        end)
        task.wait()
    end
end

task.spawn(function()
    local wasZFire=false
    local boosting=false
    while true do
        local char=LocalPlayer and LocalPlayer.Character or nil
        local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
        local zFire=hrp and hrp:FindFirstChild("SanguineArtZFire")~=nil or false
        if S.sanguineZBoost and zFire and not wasZFire and not boosting then
            boosting=true
            task.spawn(function()
                runVelocityBoost(S.glitchSettings.sanguine,function() return S.sanguineZBoost end)
                boosting=false
            end)
        end
        wasZFire=zFire
        task.wait()
    end
end)

task.spawn(function()
    local holdingZ=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x5A)
        if S.dragonTalonZBoost and pressed and not holdingZ then
            holdingZ=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Dragon Talon") then
                        runVelocityBoost(S.glitchSettings.dragonTalon,function() return S.dragonTalonZBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingZ=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingZ=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x5A)
        if S.yamaZBoost and pressed and not holdingZ then
            holdingZ=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Yama") then
                        runVelocityBoost(S.glitchSettings.yama,function() return S.yamaZBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingZ=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingX=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x58)
        if S.tushitaXBoost and pressed and not holdingX then
            holdingX=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Tushita") then
                        runVelocityBoost(S.glitchSettings.tushita,function() return S.tushitaXBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingX=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingX=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x58)
        if S.foxLampXBoost and pressed and not holdingX then
            holdingX=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Fox Lamp") then
                        runVelocityBoost(S.glitchSettings.foxLamp,function() return S.foxLampXBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingX=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local wasQPressed=false
    local wasM1Pressed=false
    local lastQPress=nil
    local lastM1Press=nil
    local boosting=false
    while true do
        local qPressed=iskeypressed(0x51)
        local m1Pressed=ismouse1pressed()
        local now=os.clock()

        if S.soulGuitarM1Boost then
            if qPressed and not wasQPressed then lastQPress=now end
            if m1Pressed and not wasM1Pressed then lastM1Press=now end

            if not boosting and lastQPress and lastM1Press and math.abs(lastQPress-lastM1Press)<=0.5 then
                lastQPress=nil
                lastM1Press=nil
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    local hasGuitar=char and (
                        char:FindFirstChild("Skull Guitar") or
                        char:FindFirstChild("Soul Guitar")
                    )
                    if hasGuitar then
                        runVelocityBoost(S.glitchSettings.soulGuitar,function() return S.soulGuitarM1Boost end,true)
                    end
                    boosting=false
                end)
            end
        else
            lastQPress=nil
            lastM1Press=nil
        end

        wasQPressed=qPressed
        wasM1Pressed=m1Pressed
        task.wait()
    end
end)

task.spawn(function()
    local wasM1Pressed=false
    local boosting=false
    while true do
        local m1Pressed=ismouse1pressed()
        if S.diamondM1Boost and not m1Pressed and wasM1Pressed and not boosting then
            boosting=true
            task.spawn(function()
                local char=LocalPlayer and LocalPlayer.Character or nil
                if char and char:FindFirstChild("Diamond-Diamond") then
                    runVelocityBoost(S.glitchSettings.diamond,function()
                        return S.diamondM1Boost
                    end)
                end
                boosting=false
            end)
        end
        wasM1Pressed=m1Pressed
        task.wait()
    end
end)

task.spawn(function()
    local holdingF=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x46)
        if S.flameFBoost and pressed and not holdingF then
            holdingF=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Flame-Flame") then
                        runVelocityBoost(S.glitchSettings.flame,function() return S.flameFBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingF=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=iskeypressed(0x52)
        if S.rToX and rPressed and not holdingR then
            holdingR=true
            local char=LocalPlayer and LocalPlayer.Character or nil
            local portal=char and char:FindFirstChild("Portal-Portal") or nil
            if portal then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x58)
                        task.wait(0.02)
                        keypress(0x58)
                        task.wait(0.08)
                        keyrelease(0x58)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=iskeypressed(0x52)
        if S.rToXThenZ and rPressed and not holdingR then
            holdingR=true
            local char=LocalPlayer and LocalPlayer.Character or nil
            local portal=char and char:FindFirstChild("Portal-Portal") or nil
            if portal then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x58)
                        task.wait(0.02)
                        keypress(0x58)
                        task.wait(0.08)
                        keyrelease(0x58)
                        task.wait(0.025)
                        keyrelease(0x5A)
                        task.wait(0.02)
                        keypress(0x5A)
                        task.wait(0.08)
                        keyrelease(0x5A)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=false
        local okKey, keyState=pcall(function() return iskeypressed(0x52) end)
        if okKey and keyState==true then rPressed=true end

        if S.flameRToC and rPressed and not holdingR then
            holdingR=true

            local char=nil
            local okChar, charValue=pcall(function()
                return LocalPlayer and LocalPlayer.Character or nil
            end)
            if okChar then char=charValue end

            local flame=nil
            if char then
                local okFlame, flameValue=pcall(function()
                    return char:FindFirstChild("Flame-Flame")
                end)
                if okFlame then flame=flameValue end
            end

            local isTool=false
            if flame then
                local okClass, className=pcall(function() return flame.ClassName end)
                isTool=okClass and className=="Tool"
            end

            if isTool then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x43)
                        keypress(0x43)
                        task.wait(0.08)
                        keyrelease(0x43)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)

local MATERIAL_ENEMIES={
    ["Leather + Scrap Metal"]={"Pirate","Brute","Gladiator","Mercenary","Swan Pirate","Marine Captain","Jungle Pirate","Forest Pirate"},
    ["Angel Wings"]={"God's Guard","Shanda","Royal Squad","Royal Soldier"},
    ["Magma Ore"]={"Military Soldier","Military Spy","Magma Ninja","Lava Pirate"},
    ["Fish Tail"]={"Fishman Warrior","Fishman Commando","Fishman Raider","Fishman Captain"},
    ["Radioactive Material"]={"Factory Staff"},
    ["Ectoplasm"]={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Cursed Captain"},
    ["Mystic Droplet"]={"Sea Soldier","Water Fighter"},
    ["Vampire Fang"]={"Vampire"},
    ["Demonic Wisp"]={"Demonic Soul"},
    ["Conjured Cocoa"]={"Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel"},
    ["Dragon Scale"]={"Dragon Crew Warrior","Dragon Crew Archer"},
    ["Gunpowder"]={"Pistol Billionaire"},
    ["Mini Tusk"]={"Mythological Pirate"}
}

local function materialWaitPosition(material)
    local sea=AFL.currentSea
    if material=="Angel Wings" then return AFL.waitPositions.SkyIsland3 end
    if material=="Radioactive Material" then return AFL.waitPositions.Factory2 end
    if material=="Ectoplasm" then return AFL.waitPositions.HauntedShip2 end
    if material=="Mystic Droplet" then return AFL.waitPositions.Wano2 end
    if material=="Vampire Fang" then return AFL.waitPositions.Graveyard2 end
    if material=="Demonic Wisp" then return AFL.waitPositions.HauntedCastle2 end
    if material=="Conjured Cocoa" then return AFL.waitPositions.Chocolate2 end
    if material=="Dragon Scale" then return AFL.waitPositions.Hydra2 end
    if material=="Gunpowder" then return AFL.waitPositions.Port2 end
    if material=="Mini Tusk" then return AFL.waitPositions.TurtleCenter1 end
    if material=="Magma Ore" then return sea==1 and AFL.waitPositions.MagmaIsland2 or AFL.waitPositions.HotSide2 end
    if material=="Fish Tail" then return sea==1 and AFL.waitPositions.UnderWaterIsland2 or AFL.waitPositions.Tiki2Quest1 end
    if material=="Leather + Scrap Metal" then
        if sea==1 then return AFL.waitPositions.PirateVillage2 end
        if sea==2 then return AFL.waitPositions.RoseKingdom2 end
        return AFL.waitPositions.TurtleEntrance2
    end
    return nil
end

local enhancedComm=nil
local function getEnhancedComm()
    if enhancedComm then
        local okParent,parent=pcall(function() return enhancedComm.Parent end)
        if okParent and parent then return enhancedComm end
        enhancedComm=nil
    end
    local storage=game:GetService("ReplicatedStorage")
    local remotes=storage and storage:FindFirstChild("Remotes")
    enhancedComm=remotes and remotes:FindFirstChild("CommF_") or nil
    if not enhancedComm and storage then
        local okDescendants,descendants=pcall(function() return storage:GetDescendants() end)
        if okDescendants and descendants then
            for _,object in pairs(descendants) do
                local okName,name=pcall(function() return object.Name end)
                if okName and name=="CommF_" then enhancedComm=object; break end
            end
        end
    end
    return enhancedComm
end

local function invokeEnhancedComm(first,second,third,fourth)
    local remote=getEnhancedComm()
    if not remote then return false,nil,"CommF_ not found" end
    local ok,result=pcall(function()
        if fourth~=nil then return remote:InvokeServer(first,second,third,fourth) end
        if third~=nil then return remote:InvokeServer(first,second,third) end
        if second~=nil then return remote:InvokeServer(first,second) end
        if first~=nil then return remote:InvokeServer(first) end
        return remote:InvokeServer()
    end)
    if not ok then
        enhancedComm=nil
        warn("[Automation] CommF_ failed: "..tostring(result))
        return false,nil,tostring(result)
    end
    return true,result,nil
end

local function nearestMatchingEnemy(hrp,names)
    local folder=game.Workspace:FindFirstChild("Enemies")
    if not folder or not hrp or not names then return nil end
    local allowed={}
    for _,name in ipairs(names) do allowed[name]=true end
    local okPlayer,playerPos=pcall(function() return hrp.Position end)
    if not okPlayer or not playerPos then return nil end
    local best,bestDistance=nil,math.huge
    for _,enemy in pairs(folder:GetChildren()) do
        local okName,name=pcall(function() return enemy.Name end)
        if okName and allowed[name] and isAlive(enemy) then
            local root=enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildOfClass("BasePart")
            local okPos,pos=pcall(function() return root and root.Position end)
            if okPos and pos then
                local dx=pos.X-playerPos.X
                local dy=pos.Y-playerPos.Y
                local dz=pos.Z-playerPos.Z
                local distance=dx*dx+dy*dy+dz*dz
                if distance<bestDistance then best,bestDistance=name,distance end
            end
        end
    end
    return best
end

function showEventStatus()
    local locations=nil
    pcall(function()
        local origin=game.Workspace:FindFirstChild("_WorldOrigin")
        locations=origin and origin:FindFirstChild("Locations") or nil
    end)
    local map=game.Workspace:FindFirstChild("Map")
    local mirage=locations and locations:FindFirstChild("Mirage Island")
    local prehistoric=locations and locations:FindFirstChild("Prehistoric Island")
    local frozen=locations and locations:FindFirstChild("Frozen Dimension")
    local kitsune=map and map:FindFirstChild("KitsuneIsland")
    local message="Mirage: "..(mirage and "YES" or "NO").." | Kitsune: "..(kitsune and "YES" or "NO").." | Prehistoric: "..(prehistoric and "YES" or "NO").." | Frozen: "..(frozen and "YES" or "NO")
    print("[World Status] "..message)
    notify(message,"World Status",8)
end

function showBossStatus()
    local storage=game:GetService("ReplicatedStorage")
    local enemies=game.Workspace:FindFirstChild("Enemies")
    local function present(name,alternate)
        return (enemies and (enemies:FindFirstChild(name) or (alternate and enemies:FindFirstChild(alternate)))) or storage:FindFirstChild(name) or (alternate and storage:FindFirstChild(alternate))
    end
    local message="Rip Indra: "..(present("rip_indra True Form","rip_indra") and "YES" or "NO").." | Dough King: "..(present("Dough King") and "YES" or "NO").." | Cake Prince: "..(present("Cake Prince") and "YES" or "NO")
    print("[Boss Status] "..message)
    notify(message,"Boss Status",8)
end

function showLegendarySwordStatus()
    local found={}
    for index,name in ipairs({"Shisui","Wando","Saddi"}) do
        local ok,result=invokeEnhancedComm("LegendarySwordDealer",tostring(index))
        if ok and result then table.insert(found,name) end
        task.wait(0.15)
    end
    local message=#found>0 and table.concat(found,", ") or "Not found"
    notify(message,"Legendary Sword Dealer",6)
end

local function safeObjectPosition(object)
    if not object then return nil end
    local okPosition,position=pcall(function() return object.Position end)
    if okPosition and position and position.X and position.Y and position.Z then return position end
    local okPrimary,primary=pcall(function() return object.PrimaryPart end)
    if okPrimary and primary then
        local okPrimaryPosition,primaryPosition=pcall(function() return primary.Position end)
        if okPrimaryPosition and primaryPosition then return primaryPosition end
    end
    local okChildren,children=pcall(function() return object:GetDescendants() end)
    if okChildren and children then
        for _,child in pairs(children) do
            local okClass,className=pcall(function() return child.ClassName end)
            if okClass and (className=="Part" or className=="MeshPart" or className=="VehicleSeat") then
                local okChildPosition,childPosition=pcall(function() return child.Position end)
                if okChildPosition and childPosition then return childPosition end
            end
        end
    end
    return nil
end

local function findMirageObject()
    local origin=game.Workspace:FindFirstChild("_WorldOrigin")
    local locations=origin and origin:FindFirstChild("Locations")
    local location=locations and locations:FindFirstChild("Mirage Island")
    if location then return location end
    local map=game.Workspace:FindFirstChild("Map")
    return map and (map:FindFirstChild("MysticIsland") or map:FindFirstChild("Mirage Island")) or nil
end

function clearMirageEsp()
    if S.mirageEspLabel then S.mirageEspLabel.Visible=false end
end

local function updateMirageEsp()
    if not S.mirageEsp then clearMirageEsp(); return end
    if not S.mirageEspLabel then
        local label=Drawing.new("Text")
        label.Text="Mirage Island"
        label.Position=Vector2.new(0,0)
        label.Color=Color3.fromRGB(100,220,255)
        label.Size=22
        label.Center=true
        label.Outline=true
        label.Font=Drawing.Fonts.Monospace
        label.Visible=false
        label.ZIndex=20
        S.mirageEspLabel=label
    end
    local mirage=findMirageObject()
    local position=safeObjectPosition(mirage)
    if not position then clearMirageEsp(); return end
    local okScreen,screen,onScreen=pcall(function() return WorldToScreen(position) end)
    if not okScreen or not screen or onScreen~=true then clearMirageEsp(); return end
    local distanceText=""
    local character=LocalPlayer.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    local okPlayer,playerPosition=pcall(function() return hrp and hrp.Position end)
    if okPlayer and playerPosition then
        local dx=position.X-playerPosition.X
        local dy=position.Y-playerPosition.Y
        local dz=position.Z-playerPosition.Z
        distanceText=" ["..tostring(math.floor(math.sqrt(dx*dx+dy*dy+dz*dz))).."]"
    end
    S.mirageEspLabel.Text="Mirage Island"..distanceText
    S.mirageEspLabel.Position=screen
    S.mirageEspLabel.Visible=true
end

local function findMirageGear()
    local map=game.Workspace:FindFirstChild("Map")
    local island=map and map:FindFirstChild("MysticIsland")
    if not island then return nil end
    local okChildren,children=pcall(function() return island:GetChildren() end)
    if not okChildren or not children then return nil end
    local character=LocalPlayer.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    local okPlayer,playerPosition=pcall(function() return hrp and hrp.Position end)
    local nearest,nearestDistance=nil,math.huge
    for _,child in pairs(children) do
        local okInfo,name,className,transparency=pcall(function() return child.Name,child.ClassName,child.Transparency end)
        if okInfo and name=="Part" and className=="MeshPart" and (tonumber(transparency) or 0)<1 then
            local position=safeObjectPosition(child)
            if position then
                local distance=0
                if okPlayer and playerPosition then
                    local dx=position.X-playerPosition.X
                    local dy=position.Y-playerPosition.Y
                    local dz=position.Z-playerPosition.Z
                    distance=dx*dx+dy*dy+dz*dz
                end
                if distance<nearestDistance then nearest,nearestDistance=child,distance end
            end
        end
    end
    return nearest
end

local namedRemoteCache={}
local function findReplicatedObject(name)
    local cached=namedRemoteCache[name]
    if cached then
        local okParent,parent=pcall(function() return cached.Parent end)
        if okParent and parent then return cached end
        namedRemoteCache[name]=nil
    end
    local storage=game:GetService("ReplicatedStorage")
    local direct=storage and storage:FindFirstChild(name)
    if direct then namedRemoteCache[name]=direct; return direct end
    local okDescendants,descendants=pcall(function() return storage:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okName,objectName=pcall(function() return object.Name end)
            if okName and objectName==name then namedRemoteCache[name]=object; return object end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        updateMirageEsp()
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if S.autoSeaEvent and not S.fruitPriorityActive and not S.autoMirageTween and not S.autoMirageGear then
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            local target=S.selectedSeaEvent
            local spawned=hrp and nearestMatchingEnemy(hrp,{target}) or nil
            if hrp and spawned then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoSeaEvent and not S.fruitPriorityActive and not S.autoMirageTween and not S.autoMirageGear and S.selectedSeaEvent==target and S.remoteMode==useRemote
                end,target,true,1000000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMirageTween and not S.fruitPriorityActive then
            local mirage=findMirageObject()
            local position=safeObjectPosition(mirage)
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            if position and hrp then
                tweenTo(hrp,Vector3.new(position.X,position.Y+300,position.Z),S.FARM_SPEED,function()
                    return S.autoMirageTween and not S.fruitPriorityActive and findMirageObject()~=nil
                end)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMirageGear and not S.fruitPriorityActive then
            local gear=findMirageGear()
            local position=safeObjectPosition(gear)
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            if gear and position and hrp then
                tweenTo(hrp,Vector3.new(position.X,position.Y+3,position.Z),S.FARM_SPEED,function()
                    return S.autoMirageGear and not S.fruitPriorityActive and gear.Parent~=nil
                end)
                task.wait(0.2)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    local lastAbility=-math.huge
    while true do
        if S.autoRaceAbility and os.clock()-lastAbility>=1 then
            local remote=findReplicatedObject("CommE")
            if remote then pcall(function() remote:FireServer("ActivateAbility") end) end
            lastAbility=os.clock()
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local target=S.selectedBoss
            local spawned=hrp and nearestMatchingEnemy(hrp,{target}) or nil
            if hrp and spawned then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedBoss==target and S.remoteMode==useRemote
                end,target,true,5000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local material=S.selectedMaterial
            local names=MATERIAL_ENEMIES[material]
            local target=hrp and nearestMatchingEnemy(hrp,names) or nil
            if hrp and target then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedMaterial==material and S.remoteMode==useRemote
                end,target,true,5000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            elseif hrp then
                local waitPos=materialWaitPosition(material)
                if waitPos then
                    tweenTo(hrp,waitPos,S.FARM_SPEED,function()
                        return S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedMaterial==material
                    end)
                end
                task.wait(0.35)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    local statEntries={{"autoStatMelee","Melee"},{"autoStatDefense","Defense"},{"autoStatSword","Sword"},{"autoStatGun","Gun"},{"autoStatFruit","Demon Fruit"}}
    while true do
        for _,entry in ipairs(statEntries) do
            if S[entry[1]] then
                invokeEnhancedComm("AddPoint",entry[2],S.statAmount)
                task.wait(0.12)
            end
        end
        task.wait(0.5)
    end
end)

while true do task.wait(1) end
