
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    table.insert(techData, { [kTechDataId] = kTechId.ProwlerMenu,            [kTechDataDisplayName] = "UPGRADE_PROWLER",  [kTechDataTooltipInfo] = "UPGRADE_PROWLER_TOOLTIP", })
    table.insert(techData, { [kTechDataId] = kTechId.UpgradeProwler,  [kTechDataCostKey] = kUpgradeProwlerResearchCost,  [kTechDataResearchTimeKey] = kUpgradeProwlerResearchTime,   [kTechDataDisplayName] = "UPGRADE_PROWLER", [kTechDataTooltipInfo] = "UPGRADE_PROWLER_TOOLTIP",    [kTechDataMenuPriority] = -1 })
    table.insert(techData, { [kTechDataId] = kTechId.AcidSpray,           [kTechDataCategory] = kTechId.Prowler, [kTechDataDisplayName] = "Acid Spray", [kTechDataDamageType] = kAcidSprayDamageType, [kTechDataTooltipInfo] = "Prowler's basic attack shoots acid projectiles that splash" })
    table.insert(techData, { [kTechDataId] = kTechId.Rappel,           [kTechDataCategory] = kTechId.Prowler, [kTechDataDisplayName] = "Rappel", [kTechDataCostKey] = kRappelResearchCost, [kTechDataResearchTimeKey] = kRappelResearchTime, [kTechDataTooltipInfo] = "Prowlers traverse by rappelling on projectile silk" })
    table.insert(techData, { [kTechDataId] = kTechId.Volley,           [kTechDataCategory] = kTechId.Prowler, [kTechDataMapName] = VolleyRappel.kMapName, [kTechDataDisplayName] = "Volley", [kTechDataCostKey] = kAcidSprayResearchCost, [kTechDataResearchTimeKey] = kAcidSprayResearchTime, [kTechDataTooltipInfo] = "Prowlers can shoot a barrage of corrosive acid" })
    table.insert(techData,  { 
		[kTechDataId] = kTechId.Prowler, 
		[kTechDataUpgradeCost] = kProwlerUpgradeCost, 
		[kTechDataMapName] = Prowler.kMapName, 
		[kTechDataGestateName] = Prowler.kMapName,                      
		[kTechDataGestateTime] = kProwlerGestateTime, 
		[kTechDataDisplayName] = "Prowler",  
		[kTechDataTooltipInfo] = "Ground ranged harrasser. Has a low damage short ranged acid spray attack, rappel, and launch deadly corrosive acid.",        
		[kTechDataModel] = Prowler.kModelName, 
		[kTechDataCostKey] = kProwlerCost, 
		[kTechDataMaxHealth] = Prowler.kHealth, 
		[kTechDataMaxArmor] = Prowler.kArmor, 
		[kTechDataEngagementDistance] = kPlayerEngagementDistance, 
		[kTechDataMaxExtents] = Vector(Prowler.kXExtents, Prowler.kYExtents, Prowler.kZExtents), 
		[kTechDataPointValue] = kProwlerPointValue
	})
	
    table.insert(techData, { [kTechDataId] = kTechId.HallucinateProwler,             
                             [kTechDataMapName] = ProwlerHallucination.kMapName,
                             [kTechDataModel] = Prowler.kModelName,
                             [kTechDataCostKey] = kProwlerCost,
                             [kTechDataMaxHealth] = kProwlerHallucinationHealth,
                             [kTechDataMaxArmor] = Prowler.kArmor,
                             [kTechDataRequiresMature] = true, 
                             [kTechDataDisplayName] = "HALLUCINATE_DRIFTER", 
                             [kTechDataTooltipInfo] = "HALLUCINATE_DRIFTER_TOOLTIP", 
                             [kTechDataCostKey] = kHallucinateLerkEnergyCost })
    return techData

end
