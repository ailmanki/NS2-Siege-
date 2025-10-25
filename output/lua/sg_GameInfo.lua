--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

-- don't delete old network vars, simply replace them if their type has changed or add them if new
local networkVarsExt = {
    SiegeRoom = "string (256)",
    FrontDoorTime = "integer",
    SideDoorTime = "integer",
    SiegeDoorTime = "integer",
    SuddenDeathTime = "integer"
}

if Server then

    local ns2_SetStartTime = GameInfo.SetStartTime
    function GameInfo:SetStartTime(startTime)
        ns2_SetStartTime(self, startTime)

        local gameRules = GetGamerules()
        self.SiegeRoom = gameRules.SiegeRoom
        self.FrontDoorTime = gameRules.FrontDoorTime
        self.SideDoorTime = gameRules.SideDoorTime
        self.SiegeDoorTime = gameRules.SiegeDoorTime
        self.SuddenDeathTime = gameRules.SuddenDeathTime
    end

    function GameInfo:SetSiegeTimes(frontTime, sideTime, siegeTime, suddenDeathTime)
        self.FrontDoorTime = frontTime
        self.SideDoorTime = sideTime
        self.SiegeDoorTime = siegeTime
        self.SuddenDeathTime = suddenDeathTime
    end

    function GameInfo:SetSiegeRoom(roomName)
        self.SiegeRoom = roomName
    end
end

function GameInfo:GetSiegeRoom()
    return self.SiegeRoom
end
function GameInfo:GetSiegeDoorOpen()
    local gameLength = ConditionalValue(self:GetGameStarted(), Shared.GetTime() - self:GetStartTime(), 0)
    return self:GetGameStarted() and gameLength > self.SiegeDoorTime
end
function GameInfo:GetSiegeTimes()
    local gameLength = ConditionalValue(self:GetGameStarted(), Shared.GetTime() - self:GetStartTime(), 0)
    local frontDoorTime = Clamp(self.FrontDoorTime - gameLength, 0, self.FrontDoorTime)
    local sideDoorTime = Clamp(self.SideDoorTime - gameLength, 0, self.SideDoorTime)
    local siegeDoorTime = Clamp(self.SiegeDoorTime - gameLength, 0, self.SiegeDoorTime)
    local suddenDeathTime = Clamp(self.SuddenDeathTime - gameLength, 0, self.SuddenDeathTime)

    return frontDoorTime, sideDoorTime, siegeDoorTime, suddenDeathTime, gameLength
end


Shared.LinkClassToMap("GameInfo", GameInfo.kMapName, networkVarsExt)
