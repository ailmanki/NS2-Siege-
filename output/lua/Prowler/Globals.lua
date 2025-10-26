
debug.appendtoenum(kPlayerStatus, "Prowler")
debug.appendtoenum(kPlayerStatus, "ProwlerEgg")

debug.appendtoenum(kMinimapBlipType, "Prowler")

--debug.appendtoenum(kDeathMessageIcon, "Volley")
--debug.appendtoenum(kDeathMessageIcon, "AcidSpray")
--debug.appendtoenum(kDeathMessageIcon, "Rappel")

if kCombatVersion then
    -- copied from Infested Fixes
    -- The killer name will clear when this is called.
    function GetKillerNameAndWeaponIcon()
        
        local killerName = gKillerName
        gKillerName = nil
        return killerName, gKillerWeaponIconIndex

    end
end
    
    


kProwlerVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric", "widow", "sleuth", "tanith" })
kProwlerVariantsData =
{
    [kProwlerVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kProwlerVariants.shadow] = 
    { 
        itemId = kShadowSkulkItemId, 
        displayName = "Shadow", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/prow_v2.material",
        viewMaterials = 
        {
            "models/prow_v2.material",
        }
    },
    [kProwlerVariants.kodiak] = 
    { 
        itemId = kKodiakSkulkItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_kodiak.material",
        }
    },
    [kProwlerVariants.reaper] = 
    { 
        itemId = kReaperSkulkItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_albino.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_albino.material",
        }
    },
    [kProwlerVariants.abyss] = 
    { 
        itemId = kAbyssSkulkItemId,  
        displayName = "Abyss",  
        modelFilePart = "",  
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_abyss.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_abyss.material",
        }
    },
    [kProwlerVariants.nocturne] = 
    { 
        itemId = kNocturneSkulkItemId,  
        displayName = "Nocturne",  
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_nocturne.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_nocturne.material",
        }
    },
    [kProwlerVariants.toxin] = 
    { 
        itemId = kToxinSkulkItemId, 
        displayName = "Toxin", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_toxin.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_toxin.material",
        }
    },
    [kProwlerVariants.auric] = 
    { 
        itemId = kAuricSkulkItemId, 
        displayName = "Auric", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_auric.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_auric.material",
        }
    },
    [kProwlerVariants.widow] = 
    { 
        itemId = kWidowSkulkItemId, 
        displayName = "Widow", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_widow.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_widow.material",
        }
    },
    [kProwlerVariants.sleuth] = 
    { 
        itemId = kSleuthSkulkItemId, 
        displayName = "Sleuth", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_sleuth.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_sleuth.material",
        }
    },
    [kProwlerVariants.tanith] = 
    { 
        itemId = kTanithSkulkItemId, 
        displayName = "Tanith", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_tanith.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/prow_tanith.material",
        }
    },
}
kDefaultProwlerVariant = kProwlerVariants.normal

if Client then

--Util to determine if the specific variant for a customizable object requires
--material swapping or if it uses a model (thus, baked materials)
function GetIsVariantMaterialSwapped( label, marineType, options )
    assert(label and type(label) == "string" and label ~= "")
    assert(options)

    local objType = string.lower(label)

    if objType == "tunnel" then
        return (
            options.alienTunnelsVariant ~= kAlienTunnelVariants.Default and
            options.alienTunnelsVariant ~= kAlienTunnelVariants.Shadow
        )
    end

    if objType == "skulk" then
        return (
            options.skulkVariant ~= kDefaultSkulkVariant and
            options.skulkVariant ~= kSkulkVariants.shadow
        )
    end

    if objType == "gorge" then
        return (
            options.gorgeVariant ~= kDefaultGorgeVariant and
            options.gorgeVariant ~= kGorgeVariants.shadow
        )
    end

    if objType == "lerk" then
        return (
            options.lerkVariant ~= kDefaultLerkVariant and
            options.lerkVariant ~= kLerkVariants.shadow
        )
    end

    if objType == "fade" then
        return (
            options.fadeVariant ~= kDefaultFadeVariant and
            options.fadeVariant ~= kFadeVariants.shadow
        )
    end

    if objType == "onos" then
        return (
            options.onosVariant ~= kDefaultOnosVariant and
            options.onosVariant ~= kOnosVariants.shadow
        )
    end

    if objType == "prowler" then
        return (
            options.prowlerVariant ~= kDefaultOnosVariant
        )
    end

    if objType == "babbler" then
        return (
            options.babblerVariant ~= kDefaultBabblerVariant and
            options.babblerVariant ~= kBabblerVariants.Shadow
        )
    end

    if objType == "babbler_egg" then
        return (
            options.babblerEggVariant ~= kDefaultBabblerEggVariant and
            options.babblerEggVariant ~= kBabblerEggVariants.Shadow
        )
    end

    if objType == "hydra" then
        return (
            options.hydraVariant ~= kDefaultHydraVariant and
            options.hydraVariant ~= kHydraVariants.Shadow
        )
    end

    return false
end
--General Utility to fetch the materials and their associated model-indices for overridding
--Note: when a given model has multiple indices per skin, matIdx return value is always false
--and the matPath variable is a table with keys (zero indexed) as material indices
function GetCustomizableWorldMaterialData( label, marineType, options )
    assert(label and type(label) == "string" and label ~= "")
    assert(options)

    local matType = string.lower(label)
    local matPath = nil
    local matIdx = -1

--Marines------------------------------
    if matType == "axe" and options.axeVariant ~= kDefaultAxeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Axe", options.axeVariant )
        matIdx = GetVariantWorldMaterialIndex( kAxeVariantsData, options.axeVariant )

    elseif matType == "welder" and options.welderVariant ~= kDefaultWelderVariant then
        matPath = GetPrecachedCosmeticMaterial( "Welder", options.welderVariant )
        matIdx = GetVariantWorldMaterialIndex( kWelderVariantsData, options.welderVariant )

    elseif matType == "pistol" and options.pistolVariant ~= kDefaultPistolVariant then
        matPath = GetPrecachedCosmeticMaterial( "Pistol", options.pistolVariant )
        matIdx = GetVariantWorldMaterialIndex( kPistolVariantsData, options.pistolVariant )

    elseif matType == "rifle" and options.rifleVariant ~= kDefaultRifleVariant then
        matPath = GetPrecachedCosmeticMaterial( "Rifle", options.rifleVariant )
        matIdx = GetVariantWorldMaterialIndex( kRifleVariantsData, options.rifleVariant )

    elseif matType == "shotgun" and options.shotgunVariant ~= kDefaultShotgunVariant then
        matPath = GetPrecachedCosmeticMaterial( "Shotgun", options.shotgunVariant )
        matIdx = GetVariantWorldMaterialIndex( kShotgunVariantsData, options.shotgunVariant )

    elseif matType == "flamethrower" and options.flamethrowerVariant ~= kDefaultFlamethrowerVariant then
        matPath = GetPrecachedCosmeticMaterial( "Flamethrower", options.flamethrowerVariant )
        matIdx = GetVariantWorldMaterialIndex( kFlamethrowerVariantsData, options.flamethrowerVariant )

    elseif matType == "grenadelauncher" and options.grenadeLauncherVariant ~= kDefaultGrenadeLauncherVariant then
        matPath = GetPrecachedCosmeticMaterial( "GrenadeLauncher", options.grenadeLauncherVariant )
        matIdx = GetVariantWorldMaterialIndex( kGrenadeLauncherVariantsData, options.grenadeLauncherVariant )

    elseif matType == "hmg" and options.hmgVariant ~= kDefaultHMGVariant then
        matPath = GetPrecachedCosmeticMaterial( "HeavyMachineGun", options.hmgVariant )
        matIdx = GetVariantWorldMaterialIndex( kHMGVariantsData, options.hmgVariant )

    elseif matType == "exo_mm" and options.exoVariant ~= kDefaultExoVariant then
        matPath = GetPrecachedCosmeticMaterial( "Minigun", options.exoVariant )
        matIdx = false

    elseif matType == "exo_rr" and options.exoVariant ~= kDefaultExoVariant then
        matPath = GetPrecachedCosmeticMaterial( "Railgun", options.exoVariant )
        matIdx = false

    elseif matType == "command_station" and options.marineStructuresVariant ~= kDefaultMarineStructureVariant then
    --CommandStation has multiple overrides per skin, so return table. It's keys are the material indices
        matPath = GetPrecachedCosmeticMaterial( "CommandStation", options.marineStructuresVariant )
        matIdx = false

    elseif matType == "extractor" and options.extractorVariant ~= kDefaultExtractorVariant then
        matPath = GetPrecachedCosmeticMaterial( "Extractor", options.extractorVariant )
        matIdx = GetVariantWorldMaterialIndex( kExtractorVariantsData, options.extractorVariant  )

    elseif matType == "mac" and options.macVariant ~= kDefaultMarineMacVariant then
        matPath = GetPrecachedCosmeticMaterial( "MAC", options.macVariant )
        matIdx = GetVariantWorldMaterialIndex( kMarineMacVariantsData, options.macVariant  )

    elseif matType == "arc" and options.arcVariant ~= kDefaultMarineArcVariant then
        matPath = GetPrecachedCosmeticMaterial( "ARC", options.arcVariant )
        matIdx = GetVariantWorldMaterialIndex( kMarineArcVariantsData, options.arcVariant  )

--Aliens-------------------------------

    elseif matType == "skulk" and options.skulkVariant ~= kDefaultSkulkVariant then
        matPath = GetPrecachedCosmeticMaterial( "Skulk", options.skulkVariant )
        matIdx = GetVariantWorldMaterialIndex( kSkulkVariantsData, options.skulkVariant )

    elseif matType == "gorge" and options.gorgeVariant ~= kDefaultGorgeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Gorge", options.gorgeVariant )
        matIdx = GetVariantWorldMaterialIndex( kGorgeVariantsData, options.gorgeVariant )

    elseif matType == "lerk" and options.lerkVariant ~= kDefaultLerkVariant then
        matPath = GetPrecachedCosmeticMaterial( "Lerk", options.lerkVariant )
        matIdx = GetVariantWorldMaterialIndex( kLerkVariantsData, options.lerkVariant )

    elseif matType == "fade" and options.fadeVariant ~= kDefaultFadeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Fade", options.fadeVariant )
        matIdx = GetVariantWorldMaterialIndex( kFadeVariantsData, options.fadeVariant )

    elseif matType == "onos" and options.onosVariant ~= kDefaultOnosVariant then
        matPath = GetPrecachedCosmeticMaterial( "Onos", options.onosVariant )
        matIdx = GetVariantWorldMaterialIndex( kOnosVariantsData, options.onosVariant )

    elseif matType == "prowler" and options.prowlerVariant ~= kDefaultProwlerVariant then
        matPath = GetPrecachedCosmeticMaterial( "Prowler", options.prowlerVariant )
        matIdx = 0 -- GetVariantWorldMaterialIndex( kProwlerVariantsData, options.prowlerVariant )

    elseif matType == "hive" and options.alienStructuresVariant ~= kDefaultAlienStructureVariant then
        matPath = GetPrecachedCosmeticMaterial( "Hive", options.alienStructuresVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienStructureVariantsData, options.alienStructuresVariant  )

    elseif matType == "harvester" and options.harvesterVariant ~= kDefaultHarvesterVariant then
        matPath = GetPrecachedCosmeticMaterial( "Harvester", options.harvesterVariant )
        matIdx = GetVariantWorldMaterialIndex( kHarvesterVariantsData, options.harvesterVariant  )

    elseif matType == "egg" and options.eggVariant ~= kDefaultEggVariant then
        matPath = GetPrecachedCosmeticMaterial( "Egg", options.eggVariant )
        matIdx = GetVariantWorldMaterialIndex( kEggVariantsData, options.eggVariant  )

    elseif matType == "cyst" and options.cystVariant ~= kDefaultAlienCystVariant then
        matPath = GetPrecachedCosmeticMaterial( "Cyst", options.cystVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienCystVariantsData, options.cystVariant  )

    elseif matType == "drifter" and options.drifterVariant ~= kDefaultAlienDrifterVariant then
        matPath = GetPrecachedCosmeticMaterial( "Drifter", options.drifterVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienDrifterVariantsData, options.drifterVariant  )

    elseif matType == "drifter_egg" and options.drifterVariant ~= kDefaultAlienDrifterVariant then
        matPath = GetPrecachedCosmeticMaterial( "DrifterEgg", options.drifterVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienDrifterVariantsData, options.drifterVariant  )

    elseif matType == "tunnel" and options.alienTunnelsVariant ~= kDefaultAlienTunnelVariant then
        matPath = GetPrecachedCosmeticMaterial( "Tunnel", options.alienTunnelsVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienTunnelVariantsData, options.alienTunnelsVariant  )

    elseif matType == "babbler" and options.babblerVariant ~= kDefaultBabblerVariant then
        matPath = GetPrecachedCosmeticMaterial( "Babbler", options.babblerVariant )
        matIdx = GetVariantWorldMaterialIndex( kBabblerVariantsData, options.babblerVariant  )

    elseif matType == "babbler_egg" and options.babblerEggVariant ~= kDefaultBabblerEggVariant then
        matPath = GetPrecachedCosmeticMaterial( "BabblerEgg", options.babblerEggVariant )
        matIdx = GetVariantWorldMaterialIndex( kBabblerEggVariantsData, options.babblerEggVariant  )

    elseif matType == "hydra" and options.hydraVariant ~= kDefaultHydraVariant then
        matPath = GetPrecachedCosmeticMaterial( "Hydra", options.hydraVariant )
        matIdx = GetVariantWorldMaterialIndex( kHydraVariantsData, options.hydraVariant  )

    end

    return matPath, matIdx
end
end