if Server then
    local kAllowedLOSWeapon = debug.getupvaluex(IsAllowedWeaponToMarkEnemy, "kAllowedLOSWeapon")
    local kAllowedOtherWeapon = debug.getupvaluex(IsAllowedWeaponToMarkEnemy, "kAllowedOtherWeapon")
    
    kAllowedLOSWeapon[kTechId.Volley] = true
    kAllowedOtherWeapon[kTechId.AcidSpray] = true
    
    function IsAllowedWeaponToMarkEnemy( weapon )
        return kAllowedOtherWeapon[weapon] or kAllowedLOSWeapon[weapon]
    end
end

--[[if Server then
    local addProwlerWeapons = true
    local kAllowedLOSWeapon = debug.getupvaluex(IsAllowedWeaponToMarkEnemy, "kAllowedLOSWeapon")
    local kAllowedOtherWeapon = debug.getupvaluex(IsAllowedWeaponToMarkEnemy, "kAllowedOtherWeapon")
       
    function IsAllowedWeaponToMarkEnemy( weapon )
        if addProwlerWeapons then
            kAllowedLOSWeapon:Add(kTechId.Volley)
            kAllowedOtherWeapon:Add(kTechId.AcidMissile)
            addProwlerWeapons = false
        end
        return kAllowedOtherWeapon[weapon] or kAllowedLOSWeapon[weapon]
    end    
end--]]