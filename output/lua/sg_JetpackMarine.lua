function JetpackMarine:GetHasEnoughFuelAntiStomp()
    local fuel=self:GetFuel()
    if fuel>kAntiStompNeedFuel then
        return true
    else
        return false
    end
end

function JetpackMarine:GetFuelAfterAntiStomp()
    self.jetpackFuelOnChange=self.jetpackFuelOnChange-kAntiStompNeedFuel
end