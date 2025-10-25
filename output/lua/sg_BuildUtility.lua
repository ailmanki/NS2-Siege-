-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\BuildUtility.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local gDebugBuildUtility = false

local function CheckBuildTechAvailable(techId, teamNumber)

    local techTree = GetTechTree(teamNumber)
    local techNode = techTree:GetTechNode(techId)
    assert(techNode)
    return techNode:GetAvailable()
    
end

local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end

local function GetBuildAttachRequirementsMet(techId, position, teamNumber, snapRadius)

    local legalBuild = true
    local attachEntity

    local legalPosition = Vector(position)
    
    -- Make sure we're within range of something that's required (ie, an infantry portal near a command station)
    local attachRange = LookupTechData(techId, kStructureAttachRange, 0)
    
    -- Use a special power-aware filter if power is required
    local attachRequiresPower = LookupTechData(techId, kStructureAttachRequiresPower, false)
    local filterFunction = GetEntitiesForTeamWithinRange
    if attachRequiresPower then
        filterFunction = FindPoweredAttachEntities
    end
    
    local buildNearClass = LookupTechData(techId, kStructureBuildNearClass)
    if buildNearClass then
        
        local ents = {}
        
        -- Handle table of class names
        if type(buildNearClass) == "table" then
            for _, className in ipairs(buildNearClass) do
                table.copy(filterFunction(className, teamNumber, position, attachRange), ents, true)
            end
        else
            ents = filterFunction(buildNearClass, teamNumber, position, attachRange)
        end
        
        legalBuild = (table.icount(ents) > 0)
        
    end
    
    local attachId = LookupTechData(techId, kStructureAttachId)
    -- prevent creation if this techId requires another techId in range
    if attachId then
    
        local supportingTechIds = {}
        
        if type(attachId) == "table" then        
            for _, currentAttachId in ipairs(attachId) do
                table.insert(supportingTechIds, currentAttachId)
            end
        else
            table.insert(supportingTechIds, attachId)
        end
        
        local ents = GetEntsWithTechIdIsActive(supportingTechIds, attachRange, position)           
        legalBuild = (table.icount(ents) > 0)
    
    end
    

    -- For build tech that must be attached, find free attachment nearby. Snap position to it.
    local attachClass = LookupTechData(techId, kStructureAttachClass)    
    if legalBuild and attachClass then

        -- If attach range specified, then we must be within that range of this entity
        -- If not specified, but attach class specified, we attach to entity of that type
        -- so one must be very close by (.5)
        
        legalBuild = LookupTechData(techId, kTechDataAttachOptional, false)
        
        attachEntity = GetNearestFreeAttachEntity(techId, position, snapRadius)
        if attachEntity then
        
            if not attachRequiresPower or (attachEntity:GetIsBuilt() and attachEntity:GetIsPowered()) then
            
                legalBuild = true
                
                VectorCopy(attachEntity:GetOrigin(), legalPosition)
                
            end
            
        end
    
    end
    
    return legalBuild, legalPosition, attachEntity
    
end

local function CheckBuildEntityRequirements(techId, position, player, ignoreEntity)

    local legalBuild = true
    local errorString = ""
    
    local techTree
    if Client then
        techTree = GetTechTree()
    else
        techTree = player:GetTechTree()
    end
    
    local techNode = techTree:GetTechNode(techId)
    local attachClass = LookupTechData(techId, kStructureAttachClass)                
    
    -- Build tech can't be built on top of non-attachment entities.
    if techNode and techNode:GetIsBuild() then
    
        local trace = Shared.TraceBox(GetExtents(techId), position + Vector(0, 1, 0), position - Vector(0, 3, 0), CollisionRep.Default, PhysicsMask.AllButPCs, EntityFilterOne(ignoreEntity))
        
        -- $AS - We special case Drop Packs you should not be able to build on top of them.
        if trace.entity and HasMixin(trace.entity, "Pathing") then
            legalBuild = false
        end
        
        -- Now make sure we're not building on top of something that is used for another purpose (ie, armory blocking use of tech point)
        if trace.entity then
        
            local hitClassName = trace.entity:GetClassName()
            if GetIsAttachment(hitClassName) and (hitClassName ~= attachClass) then
                legalBuild = false
            end
            
        end
        
        if not legalBuild then
            errorString = "COMMANDERERROR_CANT_BUILD_ON_TOP" 
        end
        
    end
    
    if techNode and (techNode:GetIsBuild() or techNode:GetIsBuy() or techNode:GetIsEnergyBuild()) and legalBuild then
        
        -- Now check nearby entities to make sure we're not building on top of something that is used for another purpose (ie, armory blocking use of tech point)
        for _, currentEnt in ipairs( GetEntitiesWithinRange( "ScriptActor", position, 1.5) ) do
        
            local nearbyClassName = currentEnt:GetClassName()
            if GetIsAttachment(nearbyClassName) and (nearbyClassName ~= attachClass) or nearbyClassName == "Door" then          
                legalBuild = false    
                errorString = "COMMANDERERROR_CANT_BUILD_TOO_CLOSE"            
            end
            
        end
        
    end
    
    return legalBuild, errorString
    
end

local function CheckClearForStacking(position, extents, attachEntity, ignoreEntity)

    local filter = CreateFilter(ignoreEntity, attachEntity)
    local trace = Shared.TraceBox(extents, position + Vector(0, 1.5, 0), position - Vector(0, 3, 0), CollisionRep.Default, PhysicsMask.CommanderStack, filter)
    
    return trace.entity == nil
    
end

local function GetTeamNumber(player, ignoreEntity)

    local teamNumber = -1
    
    if player then
        teamNumber = player:GetTeamNumber()
    elseif ignoreEntity then
        teamNumber = ignoreEntity:GetTeamNumber()
    end
    
    return teamNumber
    
end

local function BuildUtility_Print(formatString, ...)

    if gDebugBuildUtility then
        Print(formatString, ...)
    end
    
end


local function GetIsStructureExitValid(origin, direction, range)
 
    -- capsule radius should be "about-is" half the width of the widest thing produced
    -- the effective height is 2xradius + height = 1.5m
    local capsuleRadius = 0.5
    local capsuleHeight = 0.5
    -- offset it so the capsule is 0.1m off the ground
    local groundOffset = Vector(0, 0.1 + capsuleHeight/2 + capsuleRadius, 0)
    local startPoint = origin + groundOffset
    local endPoint = startPoint + direction * range
    local trace = Shared.TraceCapsule(startPoint, endPoint, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AIMovement, nil)
    -- DebugCapsule(endPoint, endPoint, capsuleRadius, capsuleHeight, 5)
    return trace.fraction == 1
    
end


local function CheckValidExit(techId, position, angle)

    local directionVec = GetNormalizedVector(Vector(math.sin(angle), 0, math.cos(angle)))
    -- TODO: Add something to tech data for "ExitDistance".
    local validExit = true
    if techId == kTechId.RoboticsFactory then
        validExit = GetIsStructureExitValid(position, directionVec, 5)
    elseif techId == kTechId.PhaseGate then
        validExit = GetIsStructureExitValid(position, directionVec, 1.5)
    end
    
    BuildUtility_Print("validExit legal: %s", ToString(validExit))
    
    return validExit, not validExit and "COMMANDERERROR_NO_EXIT" or nil
    
end

local function CheckValidIPPlacement(position, extents)

    local trace = Shared.TraceBox(extents, position - Vector(0, 0.3, 0), position - Vector(0, 3, 0), CollisionRep.Default, PhysicsMask.AllButPCs, EntityFilterAll())
    local valid = true
    if trace.fraction == 1 then
        local traceStart = position + Vector(0, 0.3, 0)
        local traceSurface = Shared.TraceRay(traceStart, traceStart - Vector(0, 0.4, 0), CollisionRep.Default, PhysicsMask.AllButPCs, EntityFilterAll())
        valid = traceSurface.surface ~= "no_ip"
    end

    return valid
    
end

local function GetIsTunnelTech(techId)
    return techId >= kTechId.BuildTunnelEntryOne and techId <= kTechId.BuildTunnelExitFour or techId == kTechId.Tunnel or techId == kTechId.TunnelExit or techId == kTechId.TunnelRelocate
end

-- CalculateTunnelPosition moved here from sg_AlienCommander.lua so both client and server can use it.
local function CalculateTunnelPosition(position, surfaceNormal)

    local kUpVector = Vector(0, 1, 0)
    local kCheckDistance = 0.8 -- bigger than onos
    local kVerticalOffset = 0.3
    local kVerticalSpace = 1.75
    local kBoxSweepOutset = 0.2
    local kBoxSweepHeight = 0.5
    local kGroundCheckDistance = 2.0

    -- maximum distance the centroid of the trace end points can be from original position before being
    -- considered too bent.
    local kBentThreshold = 0.235
    local kBentThresholdSq = kBentThreshold * kBentThreshold

    local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels

    local function IsPathable(position)
        local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
        local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
        return not noBuild and walk
    end

    local xAxis
    local zAxis
    local dot

    local valid = true

    -- if the gorge isn't facing a point on the ground, and we are too far off the ground for the
    -- downward trace to find a surface, we're given a 0 vector and a garbage position for this
    -- function call... just fail.
    if not surfaceNormal or (surfaceNormal.x == 0.0 and surfaceNormal.y == 0.0 and surfaceNormal.z == 0.0) then
        return false
    end

    dot = surfaceNormal:DotProduct(kUpVector)
    if dot < 0.86603 then -- 30 degrees off vertical
        valid = false     -- keep processing so we get a better visualization.
    end

    if math.abs(kUpVector:DotProduct(surfaceNormal)) >= 0.9999 then
        xAxis = Vector(1, 0, 0)
    else
        xAxis = kUpVector:CrossProduct(surfaceNormal):GetUnit()
    end

    zAxis = xAxis:CrossProduct(surfaceNormal)

    local pts =
    {
        xAxis * -kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * -kCheckDistance * 0.707 + zAxis * -kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        zAxis * -kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * kCheckDistance * 0.707 + zAxis * -kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        xAxis * kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * kCheckDistance * 0.707 + zAxis * kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        zAxis * kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * -kCheckDistance * 0.707 + zAxis * kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
    }

    local groundHits = {}
    for i = 1, #pts do
        local traceStart = pts[i] + position
        local traceEnd = pts[i] + position - (surfaceNormal * kGroundCheckDistance * 1.5)
        local trace = Shared.TraceRay(traceStart, traceEnd, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls,
            EntityFilterAll())


        -- can never place on top of entities.
        if trace.entity ~= nil then
            valid = false
        end

        -- all points of the gorge tunnel must either be on pathable ground, or on "tunnel_allowed" ground.
        if not IsPathable(trace.endPoint) and trace.surface ~= "tunnel_allowed" then
            valid = false
        end

        -- trace never touches anything... don't want gorge tunnels hanging off cliffs!
        if trace.fraction == 1 then
            valid = false
        else
            groundHits[#groundHits + 1] = trace.endPoint
        end
    end

    -- If we didn't hit any ground points then fail.
    if #groundHits == 0 then
        return false
    end

    -- smooth out the tunnel's orientation based on the 8 ground surface points we found.
    local centroid = Vector(0, 0, 0)
    for i = 1, #groundHits do
        centroid = centroid + groundHits[i]
    end
    centroid = centroid / #groundHits

    -- ensure the "disc" of trace points isn't too bent.  Slopes are fine, but we don't want
    -- tunnels being placed on too uneven ground.  Measure how bent it is by how far the
    -- centroid is from the initial trace point.
    if (centroid - position):GetLengthSquared() > kBentThresholdSq then
        -- too bent!  Not a good tunnel placement.
        valid = false
    end

    for i = 1, #groundHits do
        groundHits[i] = groundHits[i] - centroid
    end

    local avgNorm = Vector(0, 0, 0)
    for i = 1, #groundHits do
        local p0 = groundHits[i]
        local p1 = groundHits[(i % #groundHits) + 1]
        avgNorm = avgNorm + p1:CrossProduct(p0):GetUnit()
    end
    avgNorm = avgNorm:GetUnit()

    local traceStart
    local traceEnd
    local extents
    if valid then
        -- check also if there is enough space above
        local xDot = math.abs(xAxis:DotProduct(kUpVector))
        local zDot = math.abs(zAxis:DotProduct(kUpVector))

        -- so the corners of the box don't dig into the ground at more extreme angles.
        local yOffset = dot * kVerticalOffset + xDot * kCheckDistance + zDot * kCheckDistance

        extents = Vector(kCheckDistance, kBoxSweepHeight, kCheckDistance)
        traceStart = position + Vector(0, yOffset, 0) + avgNorm * kBoxSweepOutset
        traceEnd = traceStart + avgNorm * (kVerticalSpace / dot)

        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Move, PhysicsMask.Movement,
            EntityFilterAll())

        if trace.fraction ~= 1 then
            -- ceiling clearance is too low!
            valid = false
        end
    end

    if valid then
        -- trace backwards, to check for obstacles inside the gorge tunnel.  Don't go as close to the ground though, otherwise
        -- we always intersect the terrain, and use half extents, otherwise it's a bit too wide.
        local startPoint2 = traceEnd
        local endPoint2 = traceStart
        endPoint2 = (endPoint2 - startPoint2) * 0.667 + startPoint2
        local trace2 = Shared.TraceBox(extents * 0.5, startPoint2, endPoint2, CollisionRep.Move, PhysicsMask
            .Movement, EntityFilterAll())


        if trace2.fraction ~= 1 then
            -- something is protruding out of the middle of the tunnel!
            valid = false
        end
    end

    return valid
end

--
--Returns true or false if build attachments are fulfilled, as well as possible attach entity
--to be hooked up to. If snap radius passed, then snap build origin to it when nearby. Otherwise
--use only a small tolerance to see if entity is close enough to an attach class.
--
function GetIsBuildLegal(techId, position, angle, snapRadius, player, ignoreEntity, ignoreChecks, surfaceNormal)

    local extents = GetExtents(techId)

    local errorString
    local ignoreEntities = LookupTechData(techId, kTechDataCollideWithWorldOnly, false)
    local ignorePathing = LookupTechData(techId, kTechDataIgnorePathingMesh, false)
    
    BuildUtility_Print("------------- GetIsBuildLegal(%s) ---------------", EnumToString(kTechId, techId))
    
    local filter = CreateFilter(ignoreEntity)
    
    if ignoreEntities then
        filter = EntityFilterAll()
    end

    -- Snap to ground
    local legalPosition = GetGroundAtPointWithCapsule(position, extents, PhysicsMask.CommanderBuild, CreateFilter(ignoreEntity))
    
    -- Check attach points
    local teamNumber = GetTeamNumber(player, ignoreEntity)
    local legalBuild, legalPosition, attachEntity = GetBuildAttachRequirementsMet(techId, legalPosition, teamNumber, snapRadius)
    
    if not legalBuild then
        errorString = "COMMANDERERROR_OUT_OF_RANGE"
    end

    BuildUtility_Print("GetBuildAttachRequirementsMet legal: %s", ToString(legalBuild))
        
    local spawnBlock = LookupTechData(techId, kTechDataSpawnBlock, false)
    if spawnBlock and legalBuild then    
        legalBuild = #GetEntitiesForTeamWithinRange("SpawnBlocker", player:GetTeamNumber(), position, kSpawnBlockRange) == 0
        errorString = "COMMANDERERROR_MUST_WAIT"
    end

    BuildUtility_Print("spawnBlock, legal: %s", ToString(legalBuild))
    
    -- Check collision and make sure there aren't too many entities nearby
    if legalBuild and player and not ignoreEntities then
        legalBuild, errorString = CheckBuildEntityRequirements(techId, legalPosition, player, ignoreEntity)
    end

    BuildUtility_Print("CheckBuildEntityRequirements legal: %s", ToString(legalBuild))
    
    if legalBuild then
    
        legalBuild = legalBuild and CheckBuildTechAvailable(techId, teamNumber)
        
        if not legalBuild then
            errorString = "COMMANDERERROR_TECH_NOT_AVAILABLE"
        end
        
    end

    --BuildUtility_Print("CheckBuildTechAvailable legal: %s", ToString(legalBuild))
    
    -- Ignore entities means ignore pathing as well.
    -- if not ignorePathing and legalBuild then
    
    --     legalBuild = GetPathingRequirementsMet(legalPosition, extents)
    --     if not legalBuild then
    --         errorString = "COMMANDERERROR_INVALID_PLACEMENT"
    --     end
        
    -- end
    
    BuildUtility_Print("GetPathingRequirementsMet legal: %s", ToString(legalBuild))
    
    -- Check infestation requirements
    if legalBuild then
    
        legalBuild = legalBuild and GetInfestationRequirementsMet(techId, legalPosition)
        if not legalBuild then
            errorString = "COMMANDERERROR_INFESTATION_REQUIRED"
        end
        
    end

    if legalBuild then
    
        -- dont allow dropping on infestation
        if LookupTechData(techId, kTechDataNotOnInfestation, false) and GetIsPointOnInfestation(legalPosition) then
            legalBuild = false
        end
        
        if not legalBuild then
            errorString = "COMMANDERERROR_NOT_ALLOWED_ON_INFESTATION"
        end
    
    end
    
    BuildUtility_Print("GetInfestationRequirementsMet legal: %s", ToString(legalBuild))
    
    if legalBuild then
    
        if not LookupTechData(techId, kTechDataAllowStacking, false) then
        
            legalBuild = CheckClearForStacking(legalPosition, extents, attachEntity, ignoreEntity)
            if not legalBuild then
                errorString = "COMMANDERERROR_CANT_BUILD_ON_TOP"
            end
            
        end
        
    end
    
    BuildUtility_Print("CheckClearForStacking legal: %s", ToString(legalBuild))
    
    -- Check special build requirements. We do it here because we have the trace from the building available to find out the normal
    if legalBuild then
    
        local method = LookupTechData(techId, kTechDataBuildRequiresMethod, nil)
        if method then

            local errorMessageOverride
            -- DL: As the normal passed in here isn't used to orient the building - don't bother working it out exactly. Up should be good enough.
            legalBuild, errorMessageOverride = method(techId, legalPosition, Vector(0, 1, 0), player)

            if not legalBuild then
            
                local customMessage = LookupTechData(techId, kTechDataBuildMethodFailedMessage, nil)

                if errorMessageOverride then
                    errorString = errorMessageOverride
                elseif customMessage then
                    errorString = customMessage
                else
                    errorString = "COMMANDERERROR_BUILD_FAILED"
                end
                
            end
            
            BuildUtility_Print("customMethod legal: %s", ToString(legalBuild))
            
        end
        
    end
    
    if legalBuild and (not ignoreChecks or ignoreChecks["ValidExit"] ~= true) then
        legalBuild, errorString = CheckValidExit(techId, legalPosition, angle)
    end
    
    if legalBuild and techId == kTechId.InfantryPortal then
    
        legalBuild = CheckValidIPPlacement(legalPosition, extents)
        if not legalBuild then
            errorString = "COMMANDERERROR_INVALID_PLACEMENT"
        end
        
    end

    if legalBuild then
        local location = GetLocationForPoint(legalPosition)
        local locationName = location and location:GetName() or nil
        local gameInfo = GetGameInfoEntity()
        if not gameInfo:GetSiegeDoorOpen() and gameInfo:GetSiegeRoom() == locationName then
            legalBuild = false
            errorString = "Siege is off-limits until doors are open"
        end
    end

    if legalBuild and GetIsTunnelTech(techId) then
        -- Sanity check to ensure user cannot click down several tunnels really fast -- between
        -- tech tree updates...
        if techId ~= kTechId.TunnelRelocate then
            local teamInfo = GetTeamInfoEntity(teamNumber)

            local hiveCount = teamInfo:GetNumCapturedTechPoints()
            local tunnelCount = Tunnel.GetLivingTunnelCount(teamNumber)
            if tunnelCount >= hiveCount then
                legalBuild = false
                errorString = "TUNNEL_LIMIT_ONE_PER_HIVE_CAPS"

            end
        end

        -- Perform the more detailed tunnel placement checks that were previously in AlienCommander.CalculateTunnelPosition
        if legalBuild then
            -- If a surfaceNormal wasn't provided, try to obtain one with a short downward trace.
            if not surfaceNormal then
                local traceStart = position + Vector(0, 0.5, 0)
                local traceEnd = position - Vector(0, 2.0, 0)
                local trace = Shared.TraceRay(traceStart, traceEnd, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterAll())
                surfaceNormal = trace.normal
            end

            local tunnelOk = CalculateTunnelPosition(position, surfaceNormal)
            if not tunnelOk then
                legalBuild = false
                errorString = "COMMANDERERROR_INVALID_PLACEMENT"
            end
        end
    end

    BuildUtility_Print("GetIsBuildLegal returning: %s", ToString(legalBuild))

    return legalBuild, legalPosition, attachEntity, errorString
end

local function FlipDebug()

    gDebugBuildUtility = not gDebugBuildUtility
    Print("Set commander debug to " .. ToString(gDebugBuildUtility))
    
end

function BuildUtility_SetDebug(vm)

    if not vm then
        Print("use: debugcommander client, server or all")
    end
    
    if Shared.GetCheatsEnabled() then
    
        if Client and vm == "client" then
            FlipDebug()
        elseif Server and vm == "server" then
            FlipDebug()
        elseif vm == "all" then
            FlipDebug()
        end
        
    end
    
end
