
--kSg_TechDataResearchTimeKey = kTechDataResearchTimeKey * 0.4
local safeCommandStuctureRadius = 25

function CanCommandStructureBeBuilt(techId, origin, normal, commander)
	local front,  side, siege, suddendeath, gameLength = GetGameInfoEntity():GetSiegeTimes()
    
    if front > 0 then
    
        local cs = GetEntitiesForTeamWithinRange("CommandStructure", GetEnemyTeamNumber(commander:GetTeamNumber()), origin, safeCommandStuctureRadius)
        if cs and #cs > 0 then
            return false
        end
    end
    
    return suddendeath > 0
end

local oldBuildTechData = BuildTechData
function BuildTechData()

    local techData = oldBuildTechData()

    for index,record in ipairs(techData) do 
        local currentField = record[kTechDataId]

        if(currentField == kTechId.CommandStation) or (currentField == kTechId.Hive) then

          -- patch the tech data to prevent building if sudden death
            record[kTechDataBuildRequiresMethod] = CanCommandStructureBeBuilt
            record[kTechDataBuildMethodFailedMessage] = "Can't build command structure!"
        end

    end
--    
--    table.insert(techData,{
--        [kTechDataId] = kTechId.AdvancedWelding,
--        [kTechDataCostKey] = kAdvancedWeldingResearchCost,
--        [kTechDataResearchTimeKey] = kAdvancedWeldingResearchTime,
--        [kTechDataDisplayName] = "RESEARCH_ADVANCEDWELDING",
--        [kTechDataTooltipInfo] = "RESEARCH_ADVANCEDWELDING_TOOLTIP", 
--    } )
--    
--    table.insert(techData, {
--        [kTechDataId] = kTechId.AntiStompJetpackTech,
--        [kTechDataCostKey] = kAntiStompJetpackTechResearchCost,
--        [kTechDataResearchTimeKey] = kAntiStompJetpackTechResearchTime,
--        [kTechDataDisplayName] = "RESEARCH_ANTISTOMPJETPACK",
--        [kTechDataTooltipInfo] = "RESEARCH_ANTISTOMPJETPACK_TOOLTIP",
--        [kTechDataResearchName] = "RESEARCH_ANTISTOMPJETPACK",
--    })
--
--    table.insert(techData, {
--        [kTechDataId] = kTechId.InfantryPortal,
--        [kTechDataHint] = "INFANTRY_PORTAL_HINT",
--        [kTechDataSupply] = kInfantryPortalSupply,
--        [kTechDataGhostModelClass] = "MarineGhostModel",
--        [kTechDataRequiresPower] = true,
--        [kTechDataGhostGuidesMethod] = GetInfantryPortalGhostGuides,
--        [kTechDataBuildRequiresMethod] = GetCommandStationIsBuilt,
--        [kTechDataMapName] = InfantryPortal.kMapName,
--        [kTechDataDisplayName] = "INFANTRY_PORTAL",
--        [kTechDataCostKey] = kInfantryPortalCost,
--        [kTechDataPointValue] = kInfantryPortalPointValue,
--        [kTechDataBuildTime] = kInfantryPortalBuildTime,
--        [kTechDataMaxHealth] = kInfantryPortalHealth,
--        [kTechDataMaxArmor] = kInfantryPortalArmor,
--        [kTechDataModel] = InfantryPortal.kModelName,
--        [kStructureBuildNearClass] = "CommandStation",
--        [kStructureAttachId] = {kTechId.CommandStation,kTechId.StandardStation,kTechId.ArmorStation,kTechId.ExplosiveStation},
--        [kStructureAttachRange] = kInfantryPortalAttachRange,
--        [kTechDataEngagementDistance] = kInfantryPortalEngagementDistance,
--        [kTechDataHotkey] = Move.P,
--        [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,
--        [kTechDataTooltipInfo] = "INFANTRY_PORTAL_TOOLTIP",
--        [kTechDataObstacleRadius] = 1.125,
--        [kTechDataPersonalResOnKillKey] = kInfantryPortalPersonalResOnKill,
--        [kTechDataTeamResOnKillKey] = kInfantryPortalTeamResOnKill,
--    })
    return techData
end
