
function MarineCommander:TriggerHealingField(position, trace)

    if not trace or trace.fraction ~= 1 then

        CreateEntity(HealingField.kMapName, position, self:GetTeamNumber())        
        -- create custom sound for marine commander
        --StartSoundEffectForPlayer(Observatory.kCommanderScanSound, self)

        return true
    
    else
        self:TriggerInvalidSound()
        return false
    end

end

local function GetIsDroppack(techId)
    return techId == kTechId.MedPack or techId == kTechId.AmmoPack or techId == kTechId.CatPack
end

local function GetIsEquipment(techId)

    return techId == kTechId.DropWelder or techId == kTechId.DropMines or techId == kTechId.DropShotgun or techId == kTechId.DropHeavyMachineGun or techId == kTechId.DropGrenadeLauncher or
           techId == kTechId.DropFlamethrower or techId == kTechId.DropJetpack or techId == kTechId.DropExosuit

end

local function SelectNearest(self, className )
    
    local nearestEnts = { nil, nil, nil, nil }
    local lowestDistance = { 0, 0, 0, 0 }
    local priority
    
    for _, entity in ipairs(GetEntitiesForTeam(className, self:GetTeamNumber())) do
        
        if entity:GetIsBuilt() then
            if entity:GetIsPowered() then
                if not entity:GetIsRecycling() then
                    priority = 1
                else
                    priority = 2
                end
            else
                priority = 3
            end
        else
            priority = 4
        end
        
        local distance = (entity:GetOrigin() - self:GetOrigin()):GetLengthXZ()
        if not nearestEnts[priority] or distance < lowestDistance[priority] then
            nearestEnts[priority] = entity
            lowestDistance[priority] = distance
        end
    end
    
    local nearestEnt
    for i=1,4 do
        nearestEnt = nearestEnts[i]
        if nearestEnt then
            break
        end
    end
    
    if nearestEnt then
        
        if Client then
            
            DeselectAllUnits(self:GetTeamNumber())
            nearestEnt:SetSelected(self:GetTeamNumber(), true, false, false)
            
            return true
        
        elseif Server then
            
            DeselectAllUnits(self:GetTeamNumber())
            nearestEnt:SetSelected(self:GetTeamNumber(), true, false, false)
            Server.SendNetworkMessage(self, "ComSelect", BuildSelectAndGotoMessage(nearestEnt:GetId()), true)
            
            return true
        
        end
    
    end
    
    return false

end

-- check if a notification should be send for successful actions
function MarineCommander:ProcessTechTreeActionForEntity(techNode, position, normal, pickVec, orientation, entity, trace, targetId)

    local techId = techNode:GetTechId()
    local success = false
    local keepProcessing = false
    
    if techId == kTechId.HealingField then
    
        success = self:TriggerHealingField(position, trace)
        keepProcessing = false
        
    elseif techId == kTechId.Scan then
    
        success = self:TriggerScan(position, trace)
        keepProcessing = false
        
    elseif techId == kTechId.SelectObservatory then
        
        SelectNearest(self, "Observatory")
        
    elseif techId == kTechId.NanoShield then
    
        success = self:TriggerNanoShield(position)
        keepProcessing = false
        
    elseif techId == kTechId.PowerSurge then
    
        success = self:TriggerPowerSurge(position, entity, trace)   
        keepProcessing = false 
     
    elseif GetIsDroppack(techId) then
    
        -- use the client side trace.entity here
        local clientTargetEnt = Shared.GetEntity(targetId)
		if clientTargetEnt and ( clientTargetEnt:isa("Marine") or ( techId == kTechId.CatPack and clientTargetEnt:isa("Exo") ) ) then
            position = clientTargetEnt:GetOrigin() + Vector(0, 0.05, 0)
        end
    
        success = self:TriggerDropPack(position, techId)
        keepProcessing = false
        
    elseif GetIsEquipment(techId) then
    
        success = self:AttemptToBuild(techId, position, normal, orientation, pickVec, false, entity)
    
        if success then
            self:TriggerEffects("spawn_weapon", { effecthostcoords = Coords.GetTranslation(position) })
        end    
            
        keepProcessing = false
    else

        return Commander.ProcessTechTreeActionForEntity(self, techNode, position, normal, pickVec, orientation, entity, trace, targetId)

    end

    if success then

        self:ProcessSuccessAction(techId)

    end
    
    return success, keepProcessing

end