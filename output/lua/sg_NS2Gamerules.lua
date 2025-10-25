--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--


NS2Gamerules.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")
NS2Gamerules.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")
NS2Gamerules.kSuddenDeathSound = PrecacheAsset("sound/siegeroom.fev/door/SD")

Script.Load("lua/ConfigFileUtility.lua")

function NS2Gamerules:GetFrontDoorsOpen()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.FrontDoorTime
end

function NS2Gamerules:GetSideDoorsOpen()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.SideDoorTime
end

function NS2Gamerules:GetSiegeDoorsOpen()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.SiegeDoorTime
end

function NS2Gamerules:GetSuddenDeathActivated()
    local gameLength = Shared.GetTime() - self:GetGameStartTime()
    return self:GetGameStarted() and gameLength > self.SuddenDeathTime
end

local defaultSiegeConfig = {
    SiegeRoom = "Siege",
    FrontDoorTime = 3 * 60,   -- 180
    SideDoorTime = 0,
    SiegeDoorTime = 18 * 60,  -- 1080
    SuddenDeathTime = 23 * 60 -- 1380
}

local oldOnInitialized = NS2Gamerules.OnInitialized
function NS2Gamerules:OnInitialized()
    oldOnInitialized(self)
    kMaxRelevancyDistance = self.RelevancyDistance or 60
    kPlayingTeamInitialTeamRes = self.StartingTeamRes or kPlayingTeamInitialTeamRes
    kMarineInitialIndivRes = self.StartingPlayerRes or kMarineInitialIndivRes
    kAlienInitialIndivRes = self.StartingPlayerRes or kAlienInitialIndivRes

    self.SiegeRoom = self.SiegeRoom or defaultSiegeConfig.SiegeRoom
    self.FrontDoorTime = self.FrontDoorTime or defaultSiegeConfig.FrontDoorTime
    self.SideDoorTime = self.SideDoorTime or defaultSiegeConfig.SideDoorTime
    self.SiegeDoorTime = self.SiegeDoorTime or defaultSiegeConfig.SiegeDoorTime
    self.SuddenDeathTime = self.SuddenDeathTime or defaultSiegeConfig.SuddenDeathTime

    defaultSiegeConfig.SiegeRoom = self.SiegeRoom
    defaultSiegeConfig.FrontDoorTime = self.FrontDoorTime
    defaultSiegeConfig.SideDoorTime = self.SideDoorTime
    defaultSiegeConfig.SiegeDoorTime = self.SiegeDoorTime
    defaultSiegeConfig.SuddenDeathTime = self.SuddenDeathTime

    self.frontDoors = false
    self.sideDoors = false
    self.siegeDoors = false
    self.suddenDeath = false

    --Shared.ConsoleCommand("cheats 1")
    --Shared.ConsoleCommand("alltech")
    --Shared.ConsoleCommand("cheats 0")
end

if Server then

    local function TestFrontDoorTime(client)
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local ns2gamerules = GetGamerules()
            ns2gamerules:OpenFuncDoors(kFrontDoorType, NS2Gamerules.kFrontDoorSound)
            ns2gamerules.frontDoors = true
            ns2gamerules.FrontDoorTime = 0
            GetGameInfoEntity().FrontDoorTime = 0
            Shared.Message("= Front Doors =")
        end
    end
    Event.Hook("Console_frontdoor", TestFrontDoorTime)

    local function TestSiegeDoorTime(client)
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local ns2gamerules = GetGamerules()
            ns2gamerules:OpenFuncDoors(kSiegeDoorType, NS2Gamerules.kSiegeDoorSound)
            ns2gamerules.siegeDoors = true
            ns2gamerules.SiegeDoorTime = 1
            GetGameInfoEntity().SiegeDoorTime = 1
            Shared.Message("= Siege Doors =")
        end
    end
    Event.Hook("Console_siegedoor", TestSiegeDoorTime)

    local function TestSuddenDeathTime(client)
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local ns2gamerules = GetGamerules()
            ns2gamerules:ActivateSuddenDeath()
            ns2gamerules.suddenDeath = true
            ns2gamerules.SuddenDeathTime = 2
            GetGameInfoEntity().SuddenDeathTime = 2
            Shared.Message("= Sudden Death =")
        end
    end
    Event.Hook("Console_suddendeath", TestSuddenDeathTime)

    function NS2Gamerules:OpenFuncDoors(doorType, soundEffectType)

        -- update tech tree for playing team to allow forcefully disabled tech
        self.team1:GetTechTree():SetTechChanged()
        self.team2:GetTechTree():SetTechChanged()

        local siegeMessageType = kDoorTypeToSiegeMessage[doorType]
        SendSiegeMessage(self.team1, siegeMessageType)
        SendSiegeMessage(self.team2, siegeMessageType)

        for _, door in ientitylist(Shared.GetEntitiesWithClassname("FuncDoor")) do
            door:BeginOpenDoor(doorType)
        end

        local className = ""
        if doorType == kSiegeDoorType then
            className = "SiegeDoor"
        elseif doorType == "SideDoorType" then
            className = "SideDoor"
        elseif doorType == kFrontDoorType then
            className = "FrontDoor"
        elseif doorType == kSideDoorType then
            className = "SideDoor"
        end

        for _, door in ientitylist(Shared.GetEntitiesWithClassname(className)) do
            door:BeginOpenDoor(doorType)
        end

        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            if player:GetIsOnPlayingTeam() then
                StartSoundEffectForPlayer(soundEffectType, player)
            end
        end

    end

    function NS2Gamerules:ActivateSuddenDeath()
        local siegeMessageType = kSiegeMessageTypes.SuddenDeathActivated
        SendSiegeMessage(self.team1, siegeMessageType)
        SendSiegeMessage(self.team2, siegeMessageType)

        local soundEffectType = NS2Gamerules.kSuddenDeathSound
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            if player:GetIsOnPlayingTeam() then
                StartSoundEffectForPlayer(soundEffectType, player)
            end
        end

    end

    -- Update doors status (techpoints are close enough method)
    local ns2_UpdateTechPoints = NS2Gamerules.UpdateTechPoints
    function NS2Gamerules:UpdateTechPoints()
        ns2_UpdateTechPoints(self)

        if not self.frontDoors and self:GetFrontDoorsOpen() then
            self:OpenFuncDoors(kFrontDoorType, NS2Gamerules.kFrontDoorSound)
            self.frontDoors = true
        end

        if not self.sideDoors and self:GetSideDoorsOpen() then
            self:OpenFuncDoors(kSideDoorType, NS2Gamerules.kFrontDoorSound)
            self.sideDoors = true
        end

        if not self.siegeDoors and self:GetSiegeDoorsOpen() then
            self:OpenFuncDoors(kSiegeDoorType, NS2Gamerules.kSiegeDoorSound)
            self.siegeDoors = true
        end

        if not self.suddenDeath and self:GetSuddenDeathActivated() then
            self:ActivateSuddenDeath()
            self.suddenDeath = true
        end
    end

    -- Reset door status
    local ns2_ResetGame = NS2Gamerules.ResetGame
    function NS2Gamerules:ResetGame()
        ns2_ResetGame(self)

        self.frontDoors = false
        self.sideDoors = false
        self.siegeDoors = false
        self.suddenDeath = false
    end

    function NS2Gamerules:LoadSiegeConfig()

        local mapName = (Shared and Shared.GetMapName and Shared.GetMapName()) or nil
        if not mapName or mapName == "" then
            Shared.Message(string.format("[Siege] Map name not available; cannot load siege config."))
            return nil
        end

        local fileName = string.format("siege/%s.json", mapName)

        -- LoadConfigFile(fileName, defaultConfig, autoCheck)
        -- Using 'true' for autoCheck will add new keys from default config
        -- and save the file if it was updated.
        local siegeConfig = LoadConfigFile(fileName, defaultSiegeConfig, true)

        if siegeConfig then
            local gameInfo = GetGameInfoEntity()
            gameInfo:SetSiegeRoom(siegeConfig.SiegeRoom)
            gameInfo:SetSiegeTimes(
                siegeConfig.FrontDoorTime,
                siegeConfig.SideDoorTime,
                siegeConfig.SiegeDoorTime,
                siegeConfig.SuddenDeathTime
            )

            Shared.Message(string.format("Siege Mod: Loaded config for map '%s': Room='%s', FrontDoor=%d, SideDoor=%d, SiegeDoor=%d, SuddenDeath=%d",
                mapName,
                siegeConfig.SiegeRoom,
                siegeConfig.FrontDoorTime,
                siegeConfig.SideDoorTime,
                siegeConfig.SiegeDoorTime,
                siegeConfig.SuddenDeathTime
            ))

            self.SiegeRoom = siegeConfig.SiegeRoom
            self.FrontDoorTime = siegeConfig.FrontDoorTime
            self.SideDoorTime = siegeConfig.SideDoorTime
            self.SiegeDoorTime = siegeConfig.SiegeDoorTime
            self.SuddenDeathTime = siegeConfig.SuddenDeathTime
        else
            Shared.Message("Siege Mod: ERROR loading config, using defaults.")
        end

    end
    local oldOnMapPostLoad  = NS2Gamerules.OnMapPostLoad
    function NS2Gamerules:OnMapPostLoad()
        oldOnMapPostLoad(self)
        self:LoadSiegeConfig()
    end


    local function warnTimes(gameRules)
        if gameRules.FrontDoorTime >= gameRules.SiegeDoorTime then
            Shared.Message(string.format("[Siege] Warning: Front Door Time (%d) >= Siege Door Time (%d). Adjusting Siege Door Time.",
                gameRules.FrontDoorTime, gameRules.SiegeDoorTime))
            gameRules.SiegeDoorTime = gameRules.FrontDoorTime + 60
        end
        if gameRules.SiegeDoorTime >= gameRules.SuddenDeathTime then
            Shared.Message(string.format("[Siege] Warning: Siege Door Time (%d) >= Sudden Death Time (%d). Adjusting Sudden Death Time.",
                gameRules.SiegeDoorTime, gameRules.SuddenDeathTime))
            gameRules.SuddenDeathTime = gameRules.SiegeDoorTime + 60
        end
    end

    local function updateConfigFile(gameRules)
        local mapName = (Shared and Shared.GetMapName and Shared.GetMapName()) or nil
        if not mapName or mapName == "" then
            Shared.Message(string.format("[Siege] Map name not available; cannot load siege config."))
            return nil
        end

        local fileName = string.format("siege/%s.json", mapName)

        SaveConfigFile(fileName, {
            SiegeRoom = gameRules.SiegeRoom,
            FrontDoorTime =gameRules.FrontDoorTime,
            SideDoorTime = gameRules.SideDoorTime,
            SiegeDoorTime = gameRules.SiegeDoorTime,
            SuddenDeathTime = gameRules.SuddenDeathTime
            }, true)
    end

    Event.Hook("Console_siegeroom", function (_, ...)
            local gameRules = GetGamerules()
            gameRules.SiegeRoom = table.concat({...}, " ")
            updateConfigFile(gameRules)
            GetGameInfoEntity().SiegeRoom = gameRules.SiegeRoom
            Shared.Message(string.format("[Siege] SiegeRoom set to: %s", gameRules.SiegeRoom))
    end)
    Event.Hook("Console_frontdoortime", function (_,value)
            local gameRules = GetGamerules()
            gameRules.FrontDoorTime = tonumber(value)
            updateConfigFile(gameRules)
            GetGameInfoEntity().FrontDoorTime = gameRules.FrontDoorTime
            Shared.Message(string.format("[Siege] FrontDoorTime set to: %d", gameRules.FrontDoorTime))
    end)
    Event.Hook("Console_sidedoortime", function (_,value)
            local gameRules = GetGamerules()
            gameRules.SideDoorTime = tonumber(value)
            updateConfigFile(gameRules)
            GetGameInfoEntity().SideDoorTime = gameRules.SideDoorTime
            Shared.Message(string.format("[Siege] SideDoorTime set to: %d", gameRules.SideDoorTime))
    end)
    Event.Hook("Console_siegedoortime", function (_,value)
            local gameRules = GetGamerules()
            gameRules.SiegeDoorTime = tonumber(value)
            updateConfigFile(gameRules)
            GetGameInfoEntity().SiegeDoorTime = gameRules.SiegeDoorTime
            Shared.Message(string.format("[Siege] SiegeDoorTime set to: %d", gameRules.SiegeDoorTime))
    end)
    Event.Hook("Console_suddendeathtime", function (_,value)
            local gameRules = GetGamerules()
            gameRules.SuddenDeathTime = tonumber(value)
            updateConfigFile(gameRules)
            GetGameInfoEntity().SuddenDeathTime = gameRules.SuddenDeathTime
            Shared.Message(string.format("[Siege] SuddenDeathTime set to: %d", gameRules.SuddenDeathTime))
    end)

end
