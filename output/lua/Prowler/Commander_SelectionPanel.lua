--[[function CommanderUI_GetSelectedIconOffset(entity)
    
    local isaMarine = Client.GetLocalPlayer():isa("MarineCommander")
    
    if entity:isa("Prowler" or "ProwlerEgg") then
        return
    end
    
    return GetPixelCoordsForIcon(entity, isaMarine)

end--]]
