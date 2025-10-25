
debug.appendtoenum(kPlayerStatus, "Prowler")
debug.appendtoenum(kPlayerStatus, "ProwlerEgg")

debug.appendtoenum(kMinimapBlipType, "Prowler")

--debug.appendtoenum(kDeathMessageIcon, "Volley")
--debug.appendtoenum(kDeathMessageIcon, "AcidSpray")
--debug.appendtoenum(kDeathMessageIcon, "Rappel")

if kCombatVersion then
    -- copied from Infested Fixes
    -- The killer name will clear when this is called.
    function GetKillerNameAndWeaponIcon()
        
        local killerName = gKillerName
        gKillerName = nil
        return killerName, gKillerWeaponIconIndex

    end
end