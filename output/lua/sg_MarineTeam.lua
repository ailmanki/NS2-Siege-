
local baseOnInitialize = MarineTeam.Initialize

function MarineTeam:Initialize(teamName, teamNumber)

    baseOnInitialize(self, teamName, teamNumber)
    
	self.clientOwnedStructures = { }
end

local cancelTechNode
local function DestroyMarineStructure(self,structure)
    if not cancelTechNode then
        cancelTechNode = self:GetTechTree():GetTechNode(kTechId.Cancel)
    end

    if structure:GetIsGhostStructure() then
        structure:PerformAction(cancelTechNode)
    elseif structure:GetCanDie() then
        structure.recycled = true
        structure:Kill()
    else
        DestroyEntity(structure)
    end
end


local preOnResetComplete = MarineTeam.OnResetComplete
function MarineTeam:OnResetComplete()
    preOnResetComplete(self)

    local locations = GetLocations()
    local initialTechPoint = self:GetInitialTechPoint()
    local initialTechPointName = initialTechPoint:GetLocationName()
    local locationGraph = GetLocationGraph()

    local resourcePoints = EntityListToTable(Shared.GetEntitiesWithClassname("ResourcePoint"))
    local resourceLocationNames = {}
    for i=1, #resourcePoints do
        local resourcePoint = resourcePoints[i]
        local location = GetLocationForPoint(resourcePoint:GetOrigin())
        if location then
            local resourcePointName = location:GetName()
            if not table.icontains(resourceLocationNames,resourcePointName) then
                table.insert(resourceLocationNames,resourcePointName)
            end
        end
    end

    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    for i = 1, 100 do math.random() end

    local locationsWithoutTechPoint = {}
    
    for i=1, #locations do
        local locationName = locations[i]:GetName()

        if locationGraph.techPointLocations:Contains(locationName) then
            if locationName == initialTechPointName then
                GetPowerPointForLocation(locationName):SetConstructionComplete()
            else
                DestroyPowerForLocation(locationName, true)
            end
        else
            if not table.icontains(locationsWithoutTechPoint,locationName) then
                table.insert(locationsWithoutTechPoint,locationName)
            end
        end
    end

    local locationsWithoutTechPointCount = table.count(locationsWithoutTechPoint)
    local destroyCount = math.floor(locationsWithoutTechPointCount * 0.3)
    table.shuffle(locationsWithoutTechPoint)
    for i = 1, locationsWithoutTechPointCount do
        local locationName = table.remove(locationsWithoutTechPoint)
        if i <= destroyCount then
            DestroyPowerForLocation(locationName, true)
        elseif not table.icontains(resourceLocationNames,locationName) then
            local powerPoint = GetPowerPointForLocation(locationName)
            if  powerPoint then
                powerPoint:SetConstructionComplete()
            end
        end
    end
end

local function RemoveMarineStructureFromClient(self, techId, clientId)

    local structureTypeTable = self.clientOwnedStructures[clientId]
    
    if structureTypeTable then
    
        if not structureTypeTable[techId] then
        
            structureTypeTable[techId] = { }
            return
            
        end    
        
        local removeIndex = 0
        local structure = nil
        for index, id in ipairs(structureTypeTable[techId])  do
        
            if id then
            
                removeIndex = index
                structure = Shared.GetEntity(id)
                break
                
            end
            
        end
        
        if structure then
        
            -- Shared.Message("remove" .. tostring(structure:GetId()))
            table.remove(structureTypeTable[techId], removeIndex)

            DestroyMarineStructure(self,structure)
        end
        
    end
    
end

function MarineTeam:AddMarineStructure(player, structure)

    if player ~= nil and structure ~= nil then
    
        local clientId = Server.GetOwner(player):GetUserId()
        local structureId = structure:GetId()
        local techId = structure:GetTechId()

        if not self.clientOwnedStructures[clientId] then
            self.clientOwnedStructures[clientId] = { }
        end
        
        local structureTypeTable = self.clientOwnedStructures[clientId]
        
        if not structureTypeTable[techId] then
            structureTypeTable[techId] = { }
        end
        
        -- Shared.Message("insert" .. tostring(structureId))
        table.insertunique(structureTypeTable[techId], structureId)
        
        local numAllowedStructure = LookupTechData(techId, kTechDataMaxAmount, -1) --* self:GetNumHives()
        
        if numAllowedStructure >= 0 and table.count(structureTypeTable[techId]) > numAllowedStructure then
            RemoveMarineStructureFromClient(self, techId, clientId)
        end
        
    end
end

function MarineTeam:ClearMarineStructure(player)

    local clientId = Server.GetOwner(player):GetUserId()
    local clientTypedStructures = self.clientOwnedStructures[clientId]
    
    if not clientTypedStructures then
        return
    end

    for techId, structureList in pairs(clientTypedStructures) do
        local count = table.count(structureList)
        while count > 0 do      -- Why can't I simply use pairs?????????????
            for i, structureId in pairs(structureList) do
            
                table.remove(structureList,structureId)
                count = count-1
                local structure = structureId and Shared.GetEntity(structureId)
                if structure then
                    DestroyMarineStructure(self,structure)
                end
            end
        end
    end
        
    self.clientOwnedStructures[clientId]=nil
end


function MarineTeam:GetDroppedMarineStructures(player, techId)

    local owner = Server.GetOwner(player)

    if owner then
    
        local clientId = owner:GetUserId()
        local structureTypeTable = self.clientOwnedStructures[clientId]
        
        if structureTypeTable then
            return structureTypeTable[techId]
        end
    
    end
    
end

function MarineTeam:GetNumDroppedMarineStructures(player, techId)

    local structureTypeTable = self:GetDroppedMarineStructures(player, techId)
    return (not structureTypeTable and 0) or #structureTypeTable
    
end


function MarineTeam:UpdateClientOwnedStructures(oldEntityId)

    if oldEntityId then
    
        for clientId, structureTypeTable in pairs(self.clientOwnedStructures) do
        
            for techId, structureList in pairs(structureTypeTable) do
            
                for i, structureId in ipairs(structureList) do
                
                    if structureId == oldEntityId then
                    
                        table.remove(structureList, i)
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end

end



function MarineTeam:OnEntityChange(oldEntityId, newEntityId)

    PlayingTeam.OnEntityChange(self, oldEntityId, newEntityId)

    -- Check if the oldEntityId matches any client's built structure and
    -- handle the change.
    
    self:UpdateClientOwnedStructures(oldEntityId)

end