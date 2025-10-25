local kGestationTechIdToEggTechId =
{
    [kTechId.Prowler] = kTechId.ProwlerEgg,
    [kTechId.Gorge] = kTechId.GorgeEgg,
    [kTechId.Lerk] = kTechId.LerkEgg,
    [kTechId.Fade] = kTechId.FadeEgg,
    [kTechId.Onos] = kTechId.OnosEgg,
}

function Embryo:GetEggTypeDisplayName()

    local eggTechId = self.gestationTypeTechId and kGestationTechIdToEggTechId[ self.gestationTypeTechId ]
    return eggTechId and GetDisplayNameForTechId(eggTechId)
    
end