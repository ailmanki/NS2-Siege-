local oldCreateExoFlashlight = CreateExoFlashlight
function CreateExoFlashlight()
    
    local flashlight = oldCreateExoFlashlight()

    -- Default 10
    flashlight:SetIntensity(5)
    -- Default 30
    flashlight:SetRadius(60)
    
    return flashlight
    
end