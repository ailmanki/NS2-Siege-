-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienCommander.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Handled Commander movement and actions.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================



if Server then
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

    local kSpicyErrorMessages = {
        "Invalid target: surface normal failed structural sanity.",
        "Denied: terrain says <not today>.",
        "Tunnel zoning violation: paperwork missing.",
        "Permit denied: ceiling too clingy.",
        "Negative: pathing goblins ate the blueprint.",
        "Try again: gravity is watching.",
        "Nope: surface normal not a fan.",
        "Denied: this spot is allergic to tunnels.",
        "Blocked: invisible wall actually visible to me.",
        "Rebuffed: terrain rolled a natural 20 on deny.",
        "Not now: floor signed a no‑dig clause.",
        "Denied: the ground is still buffering.",
        "Rejected: tunnel quota reached by imaginary friends."
    }
    local function getErrorMsg(position)
        return kSpicyErrorMessages[math.random(#kSpicyErrorMessages)]
    end

    local function CalculateTunnelPosition(position, surfaceNormal)

        local xAxis
        local zAxis
        local dot

        local valid = true

        -- if the gorge isn't facing a point on the ground, and we are too far off the ground for the
        -- downward trace to find a surface, we're given a 0 vector and a garbage position for this
        -- function call... just fail.
        if not surfaceNormal or (surfaceNormal.x == 0.0 and surfaceNormal.y == 0.0 and surfaceNormal.z == 0.0) then
            return false, nil
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

    function AlienCommander:ProcessTechTreeAction(techId, pickVec, orientation, worldCoordsSpecified, targetId, shiftDown)
        local success = false

        if techId == kTechId.Cyst then
            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace.fraction ~= 1 then
                local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                    kStructureSnapRadius, self)

                if legalBuildPosition then
                    self:BuildCystChain(position)
                end

                if errorString then
                    local commander = self:isa("Commander") and self or self:GetOwner()
                    if commander then
                        local message = BuildCommanderErrorMessage(errorString, position)
                        Server.SendNetworkMessage(commander, "CommanderError", message, true)
                    end
                end
            end
        elseif techId >= kTechId.BuildTunnelEntryOne and techId <= kTechId.BuildTunnelExitFour then
            local team = self:GetTeam()
            local teamInfo = team:GetInfoEntity()

            local cost = GetCostForTech(techId)
            local teamResources = teamInfo:GetTeamResources()

            if cost > teamResources then
                self:TriggerNotEnoughResourcesAlert()
                return
            end

            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace == nil or trace.fraction >= 1 then
                return
            end

            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                kStructureSnapRadius, self)

            if legalBuildPosition then
                legalBuildPosition = CalculateTunnelPosition(trace.endPoint, trace.normal)
                if not legalBuildPosition then
                    errorString = getErrorMsg(position)
                end
            end

            if not legalBuildPosition then
                local commander = self:isa("Commander") and self or self:GetOwner()
                if commander then
                    local message = BuildCommanderErrorMessage(errorString, position)
                    Server.SendNetworkMessage(commander, "CommanderError", message, true)
                    return
                end
            end

            local tunnelManager = teamInfo:GetTunnelManager()
            tunnelManager:CreateTunnelEntrance(position, techId)

            team:AddTeamResources(-cost)
        elseif techId == kTechId.TunnelExit or techId == kTechId.TunnelRelocate then
            -- Cost is in team resources, energy or individual resources, depending on tech node type
            local cost = GetCostForTech(techId)
            local team = self:GetTeam()
            local teamResources = team:GetTeamResources()

            if cost > teamResources then
                self:TriggerNotEnoughResourcesAlert()
                return
            end

            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace == nil or trace.fraction >= 1 then
                return
            end

            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                kStructureSnapRadius, self)

            if legalBuildPosition then
                legalBuildPosition = CalculateTunnelPosition(trace.endPoint, trace.normal)
                if not legalBuildPosition then
                    errorString = getErrorMsg(position)
                end
            end

            if not legalBuildPosition then
                local commander = self:isa("Commander") and self or self:GetOwner()
                if commander then
                    local message = BuildCommanderErrorMessage(errorString, position)
                    Server.SendNetworkMessage(commander, "CommanderError", message, true)
                    return
                end
            end

            -- Commander must have another tunnel already selected in order to perform this action, figure out which
            -- one it is... because apparently that's not pertinent enough information to include in the damned
            -- message...
            -- If more than one tunnel is selected, cancel the whole damned thing.
            local selectedEntrance
            local selection = self:GetSelection()
            for i = 1, #selection do
                if selection[i]:isa("TunnelEntrance") then
                    if selectedEntrance then
                        return -- more than one selected, abort.
                    else
                        selectedEntrance = selection[i]
                    end
                end
            end

            if not selectedEntrance then
                return
            end

            local otherEntrance
            if techId == kTechId.TunnelRelocate then
                otherEntrance = selectedEntrance:GetOtherEntrance()
                assert(otherEntrance)
            else
                otherEntrance = selectedEntrance
            end

            local teamInfo = team:GetInfoEntity()
            local tunnelManager = teamInfo:GetTunnelManager()
            tunnelManager:CreateTunnelEntrance(position, nil, otherEntrance)

            team:AddTeamResources(-cost)

            if techId == kTechId.TunnelRelocate then
                selectedEntrance:KillWithoutCollapse()
            end
        else
            success = Commander.ProcessTechTreeAction(self, techId, pickVec, orientation, worldCoordsSpecified, targetId,
                shiftDown)
        end

        if success then
            local soundToPlay

            if techId == kTechId.ShiftHatch then
                soundToPlay = AlienCommander.kShiftHatch
            elseif techId == kTechId.BoneWall then
                soundToPlay = AlienCommander.kBoneWallSpawnSound
            elseif techId == kTechId.HealWave then
                soundToPlay = AlienCommander.kHealWaveSound
            elseif techId == kTechId.ShadeInk then
                soundToPlay = AlienCommander.kShadeInkSound
            elseif techId == kTechId.Cyst then
                soundToPlay = AlienCommander.kCreateCystSound
            elseif techId == kTechId.NutrientMist then
                soundToPlay = AlienCommander.kCreateMistSound
            elseif techId == kTechId.Rupture then
                soundToPlay = AlienCommander.kRupterSound
            elseif techId == kTechId.Contamination then
                soundToPlay = AlienCommander.kContaminationSound
            end

            if soundToPlay then
                Shared.PlayPrivateSound(self, soundToPlay, nil, 1.0, self:GetOrigin())
            end
        end
    end
end
