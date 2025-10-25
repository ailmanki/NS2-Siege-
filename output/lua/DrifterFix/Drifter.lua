if Server then
    function Drifter:OnKill(attacker, doer, point, direction)
        
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        --print("Killed")
        if self.hallucinations then
            for _, entId in ipairs(self.hallucinations) do
                if entId ~= Entity.InvalidId then
                    local ent = Shared.GetEntity(entId)
                    if ent then
                        if HasMixin(ent, "Live") and (ent:GetIsAlive()) and (ent:isa("Hallucination") or ent.isHallucination) then
                            ent:Kill()
                            --print("hit hallu")
                        --else
                            --print("hit random")
                        end
                    end
                end
            end
        end

        self.hallucinations = {}
    end
end
