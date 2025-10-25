--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

-- increase contamination cooldown significanlty ... because siege is about turtling!
kContaminationCooldown = 30
kContaminationLifeSpan = 60
kContaminationBileSpewCount = 1

--adjustments for NS2.0 for advanced xenocide in siege 
kXenocideFuelDamage = 110
kXenocideFuelRange = 10
kXenocideDamage = 100   --200
kXenocideRange = 9  -- 14

--decrease alien's cost and gestate time
kGorgeCost = 8
kGorgeEggCost = 10
kLerkCost = 18
kLerkEggCost = 20
kFadeCost = 32
kFadeEggCost = 45
kOnosCost = 50
kOnosEggCost = 70

kSkulkUpgradeCost = 0
kGorgeUpgradeCost = 1
kLerkUpgradeCost = 2
kFadeUpgradeCost = 4
kOnosUpgradeCost = 6

kSkulkGestateTime = 1
kGorgeGestateTime = 1
kLerkGestateTime = 1
kFadeGestateTime = 1
kOnosGestateTime = 1

--enhance the umbra ability
kUmbraEnergyCost = 25
kUmbraMaxRange = 20
kUmbraDuration = 5
kUmbraRadius = 5

kUmbraShotgunModifier = 0.6
kUmbraBulletModifier = 0.6
kUmbraMinigunModifier = 0.6
kUmbraRailgunModifier = 0.6

--Enhance the bilebomb
kBileBombDamage = 55 -- per second from 55
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 10
kBileBombDuration = 5
    -- 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 7.5
kBileBombDotInterval = 0.4

--AntiJetpack
kAntiStompNeedFuel=0.4
kDisruptAntiStompJetpackerTime=0.3

--enhance skulk's ability
kLeapEnergyCost = 25    --from 45

-- SPAWN TIMES
kMarineRespawnTime = 9 --from 9

kAlienSpawnTime = 10    --from 10
kEggGenerationRate = 13 --from 13
kAlienEggsPerHive = 2   --from 2

--protolab adjustments
kPrototypeLabBuildTime = 12 --from 20


kMinigunDamage = 6.5 --from 6

kMaxEfficiencyTowers = 40 --same with misc.lua
kMatchMinPlayers = 99

kResourceTowerResourceInterval = 6 --6
kPlayerResPerInterval = 0.125
kTeamResourcePerTick = 1
kPlayingTeamInitialTeamRes = 200   -- from 60
kMarineInitialIndivRes = 25
kAlienInitialIndivRes = 20