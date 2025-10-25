
local oldInitializeFocusAbilities = InitializeFocusAbilities
function InitializeFocusAbilities()
    oldInitializeFocusAbilities()
    kFocusAbilities[kTechId.Volley] = true
end