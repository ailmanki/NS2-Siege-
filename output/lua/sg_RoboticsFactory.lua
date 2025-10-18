local oldGetRoboticsFactoryBuildValid = GetRoboticsFactoryBuildValid
function GetRoboticsFactoryBuildValid(techId, origin, normal, player)
    local isValid = oldGetRoboticsFactoryBuildValid(techId, origin, normal, player)
    if isValid then
        local front, siege,_ = GetGameInfoEntity():GetSiegeTimes()
        
        if (front > 0) then
            local ents = GetEntitiesWithinXZRange("FuncDoor", origin, 12)
            isValid = #ents == 0
            if isValid then
                ents = GetEntitiesWithinXZRange("FrontDoor", origin, 12)
                isValid = #ents == 0
            end
            if isValid then
                ents = GetEntitiesWithinXZRange("SideDoor", origin, 12)
                isValid = #ents == 0
            end
        end
        
        if isValid and siege > 0 then
            local ents = GetEntitiesWithinXZRange("FuncDoor", origin, 12)
            for i = 1, #ents do
                -- if its near a siege door
                if ents[i].type == 1 then
                    return false
                end
            end
            
            ents = GetEntitiesWithinXZRange("SiegeDoor", origin, 12)
            isValid = #ents == 0
        end
        
    end
    return isValid
end
