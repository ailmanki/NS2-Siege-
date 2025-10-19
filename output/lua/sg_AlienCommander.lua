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

            -- Pass the surface normal into GetIsBuildLegal so the tunnel placement checks can run there.
            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                kStructureSnapRadius, self, nil, nil, trace.normal)

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

            -- Pass the surface normal into GetIsBuildLegal so the tunnel placement checks can run there.
            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                kStructureSnapRadius, self, nil, nil, trace.normal)

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
