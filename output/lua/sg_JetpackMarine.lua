function JetpackMarine:GetHasEnoughFuelAntiStomp()
    return self:GetFuel() > kAntiStompNeedFuel
end

function JetpackMarine:GetFuelAfterAntiStomp()
    self.jetpackFuelOnChange=self.jetpackFuelOnChange-kAntiStompNeedFuel
end