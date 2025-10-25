-- Increase Marine flashlight distance by adjusting the render light radius after the flashlight is created.
if Client then
    local oldMarineOnCreate = Marine and Marine.OnCreate
    if oldMarineOnCreate then
        function Marine:OnCreate()
            oldMarineOnCreate(self)
            if self.flashlight then
                -- Default is 28;
                self.flashlight:SetRadius(56)
                -- Default is 8;
                self.flashlight:SetIntensity(4)
            end
        end
    end
end

