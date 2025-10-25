-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\ConsoleCommands_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- General purpose console commands (not game rules specific).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

function OnCommandSay(client, ...)

    if client == nil then

        local chatMessage = StringConcatArgs(...)
        chatMessage = string.UTF8Sub(chatMessage, 1, kMaxChatLength)
        if string.len(chatMessage) > 0 then

            Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
            Shared.Message("Chat All - Admin: " .. chatMessage)
            Server.AddChatToHistory(chatMessage, "Admin", 0, kTeamReadyRoom, false)

        end

    end

end

function OnCommandKill(client)

    if client ~= nil then

        local player = client:GetControllingPlayer()

        if player ~= nil and (not client.timeLastKillCommand or client.timeLastKillCommand + 1 < Shared.GetTime()) then

            if HasMixin(player, "Live") and player:GetCanDie() then
                player:Kill(player, nil, player:GetOrigin())
            end

            client.timeLastKillCommand = Shared.GetTime()

        end

    end

end

local function OnCommandKillAll(_, className)

    if Shared.GetCheatsEnabled() then

        for _, entity in ientitylist(Shared.GetEntitiesWithClassname(className)) do

            if HasMixin(entity, "Live") and entity:GetCanDie() then
                entity:Kill()
            end

        end

    end

end

local function OnCommandKillNearby(client, className, distance)

    if Shared.GetCheatsEnabled() then

        distance = distance and tonumber(distance) or 15
        local player = client:GetControllingPlayer()
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname(className)) do

            if HasMixin(entity, "Live") and entity:GetCanDie() and player and entity:GetDistance(player) <= distance then
                entity:Kill()
            end

        end

    end

end

function OnCommandClearOrders(client)

    if client ~= nil and Shared.GetCheatsEnabled() then
        local player = client:GetControllingPlayer()
        if player then
            player:ClearOrders()
        end
    end

end

function OnCommandDarwinMode(client)

    if client ~= nil and Shared.GetCheatsEnabled() then

        local player = client:GetControllingPlayer()
        if player then
            player:SetDarwinMode(not player:GetDarwinMode())
            Print("Darwin mode on player now %s", ToString(player:GetDarwinMode()))
        end

    end

end

function OnCommandDarwinOther(client)

    if client ~= nil and Shared.GetCheatsEnabled() then

        local player = client:GetControllingPlayer()
        if player then

            local startPoint = player:GetEyePos()
            local viewAngles = player:GetViewAngles()
            local fowardCoords = viewAngles:GetCoords()
            local trace = Shared.TraceRay(startPoint, startPoint + (fowardCoords.zAxis * 45), CollisionRep.LOS, PhysicsMask.AllButPCs, EntityFilterOne(player))

            if trace.entity then
                trace.entity:SetDarwinMode(not trace.entity:GetDarwinMode())
                Print("Target %s now has darwin mode set to %s!", trace.entity, trace.entity:GetDarwinMode())
            end

        end

    end

end

function OnCommandRoundReset(client)

    if client == nil or Shared.GetCheatsEnabled() then
        GetGamerules():ResetGame()
    end

end

function OnCommandEffectDebug(client, className)

    if Shared.GetDevMode() then

        local player = client:GetControllingPlayer()

        if className and className ~= "" then

            gEffectDebugClass = className
            Server.SendCommand(player, string.format("oneffectdebug %s", className))
            Print("effect_debug enabled for \"%s\" objects.", className)

        elseif gEffectDebugClass ~= nil then

            gEffectDebugClass = nil
            Server.SendCommand(player, "oneffectdebug")
            Print("effect_debug disabled.")

        else

            -- Turn on debug of everything
            gEffectDebugClass = ""
            Server.SendCommand(player, "oneffectdebug")
            Print("effect_debug enabled.")

        end

    else
        Print("effect_debug <class name> (dev mode must be enabled)")
    end

end

local unstickDelay = 5
local unstickInterval = 30
local lastUnstuck = {}

--We don't use ServerAdminPrint here as that would spam the server log
local function NotifyPlayer(player, message)
    Server.SendNetworkMessage(player, "ServerAdminPrint", { message = message }, true)
end

local function Unstick(client, origin)
    local player = client and client:GetControllingPlayer() or nil

    if not (player and origin and client) then return end

    if player:GetOrigin() ~= origin then
        NotifyPlayer(player, "You moved since running unstuck, unstuck aborted!")
        return
    end

    local techId = player:GetTechId()
    local extents = GetExtents(techId)

    if not extents then return end

    local spawn

    -- Helper to try to find a clear spawn around a base origin.
    local function TryFindClearAround(baseOrigin, minRange, maxRange)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
        local pos = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, baseOrigin, minRange, maxRange, EntityFilterAll())
        if pos then
            pos = GetGroundAtPosition(pos, nil, PhysicsMask.AllButPCs, extents)
        end
        return pos
    end

    local teamNumber = player:GetTeamNumber()

    if teamNumber == kTeamReadyRoom then
        -- Ready Room works off the precomputed spawn entity list.
        local spawnPoints = Server.readyRoomSpawnList
        local spawnpoint = GetRandomClearSpawnPoint(player, spawnPoints)
        spawn = spawnpoint and spawnpoint:GetOrigin()
    elseif teamNumber == kTeam1Index then
        -- Marines: mirror real spawns by using active Infantry Portals, fallback to Command Stations.
        local candidates = { }
        for _, ip in ipairs(GetEntitiesForTeam("InfantryPortal", kTeam1Index)) do
            if ip.GetIsAlive and ip:GetIsAlive() and GetIsUnitActive(ip) then
                local spawnOrigin = ip.GetAttachPointOrigin and ip:GetAttachPointOrigin("spawn_point") or ip:GetOrigin()
                table.insert(candidates, { ent = ip, origin = spawnOrigin })
            end
        end
        -- Fallback to Command Stations if no IP available.
        if #candidates == 0 then
            for _, cs in ipairs(GetEntitiesForTeam("CommandStation", kTeam1Index)) do
                if cs.GetIsAlive and cs:GetIsAlive() and cs.GetIsBuilt and cs:GetIsBuilt() then
                    local spawnOrigin = cs:GetOrigin()
                    table.insert(candidates, { ent = cs, origin = spawnOrigin })
                end
            end
        end
        -- Prefer closest to the player.
        table.sort(candidates, function(a, b)
            return (a.origin - origin):GetLengthSquared() < (b.origin - origin):GetLengthSquared()
        end)
        for i = 1, #candidates do
            local pos = TryFindClearAround(candidates[i].origin, 0.5, 2.5)
            if pos then
                spawn = pos
                break
            end
        end
    elseif teamNumber == kTeam2Index then
        -- Aliens: mirror egg/hive spawning by selecting a clear point around a live Hive.
        local candidates = { }
        for _, hive in ipairs(GetEntitiesForTeam("Hive", kTeam2Index)) do
            if hive.GetIsAlive and hive:GetIsAlive() and hive.GetIsBuilt and hive:GetIsBuilt() then
                local spawnOrigin = hive.GetModelOrigin and hive:GetModelOrigin() or hive:GetOrigin()
                table.insert(candidates, { ent = hive, origin = spawnOrigin })
            end
        end
        -- Prefer closest hive to the player.
        table.sort(candidates, function(a, b)
            return (a.origin - origin):GetLengthSquared() < (b.origin - origin):GetLengthSquared()
        end)
        for i = 1, #candidates do
            local pos = TryFindClearAround(candidates[i].origin, 4, 22)
            if pos then
                spawn = pos
                break
            end
        end
    else
        return
    end

    if spawn then
        NotifyPlayer(player, "Successfully unstuck!")
         Log(string.format("Successfully unstuck %s [%s]", player:GetName(), player:GetSteamId()))
         player:SetOrigin(spawn)
        return
    end

    NotifyPlayer(player, "Unstuck failed, please retry or use the kill command!")
    lastUnstuck[client] = nil
end

local function OnCommandUnstuck(client)
    local gamerules = GetGamerules()
    if not gamerules then return end

    local player = client:GetControllingPlayer()
    if not player then return end

    if not player:GetIsAlive() then
        NotifyPlayer(player, "You can only use unstuck if you are alive!")
        return
    end

    if lastUnstuck[client] and lastUnstuck[client] > Shared.GetTime() then
        NotifyPlayer(player, string.format("You can only use unstuck every %s seconds", unstickInterval))
        return
    end

    lastUnstuck[client] = Shared.GetTime() + unstickInterval
    NotifyPlayer(player, string.format("Unsticking you now please do not move the next %s seconds", unstickDelay))

    local origin = player:GetOrigin()
    gamerules:AddTimedCallback(function() Unstick(client, origin) end, unstickDelay )
end

local function OnCommandWarp(client, x, y, z)

    if client ~= nil and z ~= nil and (Shared.GetCheatsEnabled() or Shared.GetTestsEnabled()) then

        local player = client:GetControllingPlayer()
        player:SetOrigin(Vector(tonumber(x), tonumber(y), tonumber(z)))

    end

end

local function OnCommandFindRef(client, className)

    if client == nil or Shared.GetCheatsEnabled() then

        if className ~= nil then
            Debug.FindTypeReferences(className)
        end

    end

end

local function OnCommandDebugPathing(_, param)
    if Shared.GetCheatsEnabled() then
        local enable = param == "true"

        if enable ~= gDebugPathing then
            gDebugPathing = enable
            if enable then
                Print("debug pathing enabled")
            else
                Print("debug pathing disabled")
            end
        end

    end
end

local function OnCommandListPlayers(client)

    if client == nil or Shared.GetCheatsEnabled() then

        Shared.Message("Player List -")

        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do

            local playerClient = Server.GetOwner(player)
            local playerAddressString = IPAddressToString(Server.GetClientAddress(playerClient))
            Shared.Message(player:GetName() .. " : " .. playerClient:GetUserId() .. " : " .. playerAddressString)

        end

    end

end

local function OnCommandKick(client, steamId, ...)

    -- Only allowed from the dedicated server.
    if client == nil then

        local found
        for _, victim in ientitylist(Shared.GetEntitiesWithClassname("Player")) do

            if Server.GetOwner(victim):GetUserId() == tonumber(steamId) and Server.GetOwner(victim):GetIsVirtual() == false then

                found = victim
                break

            end

        end

        if found ~= nil then

            local foundClient = Server.GetOwner(found)
            Shared.Message(string.format("%s kicked from the server", found:GetName()))

            local reason = StringTrim(StringConcatArgs(...) or "")
            Server.DisconnectClient(foundClient,reason)

        else
            Shared.Message("Failed to find client matching Id")
        end

    end

end

local ToWatch

local function ToWatch_Table(value, indent)

    local spaces = string.rep(" ", indent * 4)
    local result = "{\n"
    for k, v in pairs(value) do
        result = result .. string.rep(" ", (indent + 1) * 4) .. k .. " = " .. ToWatch(v, indent + 1) .. "\n"
    end
    return result .. spaces .. "}"
end

function ToWatch(value, indent)

    indent = indent or 0

    local mt = getmetatable(value)
    if mt and type(mt.__towatch) == "function" then
        local class, members = mt.__towatch(value)
        return class .. " " .. ToWatch_Table(members, indent)
    else
        if type(value) == "table" then
            return ToWatch_Table(value, indent)
        else
            return tostring(value)
        end
    end

end

-- Executes a line of script code
local function OnCommandBang(client, ...)
    if client == nil or Shared.GetCheatsEnabled() then
        -- The command line parser tokenizes the command, so glue the pieces
        -- back together
        local command = ""
        for _, p in ipairs({...}) do
            command = command .. " " .. p
        end
        local result, error = loadstring("return " .. command)
        if result then
            local results = { pcall(result) }
            if results[1] == false then
                Shared.Message("error")
            end
            if #results > 1 then
                Shared.Message("! " .. command .. " = ")
                for i = 2, #results do
                    local result = results[i]
                    Shared.Message( ToWatch(result) )
                end
            end
        else
            Shared.Message(error)
        end
    end

end

local function OnRookieMode(client)
    if client and not client:GetIsLocalClient() or not GetGamerules() then return end

    local state = GetGameInfoEntity():GetRookieMode()
    GetGamerules():SetRookieMode(not state)

    Shared.Message(string.format("Rookie Mode has been turned %s", state and "off" or "on"))
end

local function OnBotTraining(client)
    if client and not client:GetIsLocalClient() or not GetGamerules() then return end

    GetGamerules():SetBotTraining(true)

    Server.DisableQuickPlay()
end

local function OnCommandSkillTier(client, skillTierOverride)
    if not Shared.GetTestsEnabled() then
        Shared.Message("Tests are required for this command. Disabled just in case.")
        gSkillTierOverride = nil
        return
    end

    local skillTier = tonumber(skillTierOverride)
    if not skillTier then
        gSkillTierOverride = nil
        Shared.Message("Skill tier override disabled.")
    else
        gSkillTierOverride = Clamp(skillTier, 1, 7)
        Shared.Message(string.format("Server bots skill tier overriden to %d", gSkillTierOverride))
    end

end

-- Generic console commands
Event.Hook("Console_botskilltier", OnCommandSkillTier)
Event.Hook("Console_rookiemode", OnRookieMode)
Event.Hook("Console_bottraining", OnBotTraining)
Event.Hook("Console_say", OnCommandSay)
Event.Hook("Console_kill", OnCommandKill)
Event.Hook("Console_killall", OnCommandKillAll)
Event.Hook("Console_killnearby", OnCommandKillNearby)
Event.Hook("Console_clearorders", OnCommandClearOrders)
Event.Hook("Console_darwinmode", OnCommandDarwinMode)
Event.Hook("Console_darwinother", OnCommandDarwinOther)
Event.Hook("Console_reset", OnCommandRoundReset)
Event.Hook("Console_effect_debug", OnCommandEffectDebug)
Event.Hook("Console_unstuck", OnCommandUnstuck)
Event.Hook("Console_stuck", OnCommandUnstuck)
Event.Hook("Console_warp", OnCommandWarp)
Event.Hook("Console_gotolocation", OnCommandWarp)
Event.Hook("Console_sfindref", OnCommandFindRef)
Event.Hook("Console_debugpath", OnCommandDebugPathing)
Event.Hook("Console_list_players", OnCommandListPlayers)
Event.Hook("Console_status", OnCommandListPlayers)
Event.Hook("Console_kick", OnCommandKick)
Event.Hook("Console_!", OnCommandBang)
