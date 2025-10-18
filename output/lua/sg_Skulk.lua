  local kLeapForce = 25 --from 7.6
  local kLeapVerticalForce = 28 --from 10.8

--   function Skulk:OnLeap()

--     local velocity = self:GetVelocity() * 0.5
--     local forwardVec = self:GetViewAngles():GetCoords().zAxis
--     local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * kLeapForce 
--     newVelocity=newVelocity+13
    
--     -- Add in vertical component.
--     newVelocity.y = kLeapVerticalForce * forwardVec.y + kLeapVerticalForce * 0.5 + ConditionalValue(velocity.y < 0, velocity.y, 0)
    
--     self:SetVelocity(newVelocity)
    
--     self.leaping = true
--     self.wallWalking = false
--     self.jumping = true
--     self:DisableGroundMove(0.2)
    
--     self.timeOfLeap = Shared.GetTime()
    
-- end


function Skulk:GetAirFriction()
  return 0.045 - (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * 0.009 --from 0.055-(...
end 