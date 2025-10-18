local oldGetRoboticsFactoryBuildValid = GetRoboticsFactoryBuildValid
function GetRoboticsFactoryBuildValid(techId, origin, normal, player)
    local isValid = oldGetRoboticsFactoryBuildValid(techId, origin, normal, player)
    if isValid then
        local front, siege,_ = GetGameInfoEntity():GetSiegeTimes()
        
        if (front > 0) then
            local ents = GetEntitiesWithinXZRange("FuncDoor", origin, 12)
            return (#ents == 0)
        end
        
        if (siege > 0) then
            local ents = GetEntitiesWithinXZRange("FuncDoor", origin, 12)
            for i = 1, #ents do
                -- if its near a siege door
                if ents[i].type == 1 then
                    return false
                end
            end
        end
    end
    return isValid
end
