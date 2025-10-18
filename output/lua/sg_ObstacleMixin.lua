--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

kFuncDoorMapName = "ns2siege_funcdoor"
kFuncCompatSiegeDoorMapName = "siegedoor"
kFuncCompatFrontDoorMapName = "frontdoor"
kFuncCompatSideDoorMapName = "sidedoor"
kFuncCompatBreakableDoorMapName = "breakabledoor"

-- technically it would be most correct to reset all entities in the world
-- but practically, entities which implemented GetResetsPathing are of temporary nature and used for blocking,
-- and unless units travel <range> faster than those temporary entities lifetime, there is no reason to change this
local function InformEntitiesInRange(self, range)
    
    for _, pathEnt in ipairs(GetEntitiesWithMixinWithinRange("Pathing", self:GetOrigin(), range)) do
        pathEnt:OnObstacleChanged()
    end

end

--local ns2_GetPathingInfo = ObstacleMixin._GetPathingInfo
function ObstacleMixin:_GetPathingInfo()
    
    -- front door has it's own function
    if not self._modelCoords then
        return nil, 0, 0
    end
    if not self.GetObstaclePathingInfo then
        
        local position = self:GetOrigin() + Vector(0, -100, 0)
        local radius = LookupTechData(self:GetTechId(), kTechDataObstacleRadius, 1.0)
        local height = 200.0
        
        return position, radius, height
    
    end
    
    return self:GetObstaclePathingInfo()
end



function ObstacleMixin:AddToMesh()

    if GetIsPathingMeshInitialized() then
   
        if self.obstacleId ~= -1 then
            Pathing.RemoveObstacle(self.obstacleId)
            gAllObstacles[self] = nil
        end

        local position, radius, height = self:_GetPathingInfo()   
        if position ~= nil then
            self.obstacleId = Pathing.AddObstacle(position, radius, height) 
        else
            self.obstacleId = -1
        end
      
        if self.obstacleId ~= -1 then
        
            gAllObstacles[self] = true
            if self.GetResetsPathing and self:GetResetsPathing() then
                InformEntitiesInRange(self, 25)
            end
            
        end
    
    end
    
end