
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
    ClassToGrid["Prowler"] = { 6, 3 }
    
    return ClassToGrid
    
end

local loadProwler = true
local oldGetTexCoordsForTechId = GetTexCoordsForTechId
function GetTexCoordsForTechId(techId)
	if loadProwler and gTechIdPosition then
		gTechIdPosition[kTechId.Volley] = kDeathMessageIcon.Spikes
        gTechIdPosition[kTechId.AcidSpray] = kDeathMessageIcon.Spray
        gTechIdPosition[kTechId.Rappel] = kDeathMessageIcon.Claw
		loadProwler = false
	end
	return oldGetTexCoordsForTechId(techId)
end



function GetAndSetVariantOptions()

    local variants = {}

    variants.sexType = Client.GetOptionString("sexType", "Male")

    ValidateShoulderPad(variants)

    ValidateVariant(variants, "marineVariant",              kMarineVariants,             kMarineVariantsData)
    ValidateVariant(variants, "skulkVariant",               kSkulkVariants,              kSkulkVariantsData)
    ValidateVariant(variants, "gorgeVariant",               kGorgeVariants,              kGorgeVariantsData)
    ValidateVariant(variants, "lerkVariant",                kLerkVariants,               kLerkVariantsData)
    ValidateVariant(variants, "fadeVariant",                kFadeVariants,               kFadeVariantsData)
    ValidateVariant(variants, "onosVariant",                kOnosVariants,               kOnosVariantsData)
    ValidateVariant(variants, "prowlerVariant",             kProwlerVariants,            kProwlerVariantsData)
    ValidateVariant(variants, "exoVariant",                 kExoVariants,                kExoVariantsData)
    ValidateVariant(variants, "rifleVariant",               kRifleVariants,              kRifleVariantsData)
    ValidateVariant(variants, "pistolVariant",              kPistolVariants,             kPistolVariantsData)
    ValidateVariant(variants, "axeVariant",                 kAxeVariants,                kAxeVariantsData)
    ValidateVariant(variants, "shotgunVariant",             kShotgunVariants,            kShotgunVariantsData)
    ValidateVariant(variants, "flamethrowerVariant",        kFlamethrowerVariants,       kFlamethrowerVariantsData)
    ValidateVariant(variants, "grenadeLauncherVariant",     kGrenadeLauncherVariants,    kGrenadeLauncherVariantsData)
    ValidateVariant(variants, "welderVariant",              kWelderVariants,             kWelderVariantsData)
    ValidateVariant(variants, "hmgVariant",                 kHMGVariants,                kHMGVariantsData)
    ValidateVariant(variants, "macVariant",                 kMarineMacVariants,          kMarineMacVariantsData)
    ValidateVariant(variants, "arcVariant",                 kMarineArcVariants,          kMarineArcVariantsData)
    ValidateVariant(variants, "marineStructuresVariant",    kMarineStructureVariants,    kMarineStructureVariantsData)
    ValidateVariant(variants, "extractorVariant",           kExtractorVariants,          kExtractorVariantsData)

    ValidateVariant(variants, "alienStructuresVariant",     kAlienStructureVariants,     kAlienStructureVariantsData)
    ValidateVariant(variants, "harvesterVariant",           kHarvesterVariants,          kHarvesterVariantsData)
    ValidateVariant(variants, "eggVariant",                 kEggVariants,                kEggVariantsData)
    ValidateVariant(variants, "alienTunnelsVariant",        kAlienTunnelVariants,        kAlienTunnelVariantsData)
    ValidateVariant(variants, "cystVariant",                kAlienCystVariants,          kAlienCystVariantsData)
    ValidateVariant(variants, "drifterVariant",             kAlienDrifterVariants,       kAlienDrifterVariantsData)

    ValidateVariant(variants, "clogVariant",                kClogVariants,               kClogVariantsData)
    ValidateVariant(variants, "hydraVariant",               kHydraVariants,              kHydraVariantsData)
    ValidateVariant(variants, "babblerVariant",             kBabblerVariants,            kBabblerVariantsData)
    ValidateVariant(variants, "babblerEggVariant",          kBabblerEggVariants,         kBabblerEggVariantsData)

    return variants

end


function SendPlayerVariantUpdate()

    if Client.GetIsConnected() then

        local options = GetAndSetVariantOptions()

        Client.SendNetworkMessage("SetPlayerVariant",
            {
                marineVariant = options.marineVariant,
                skulkVariant = options.skulkVariant,
                gorgeVariant = options.gorgeVariant,
                lerkVariant = options.lerkVariant,
                fadeVariant = options.fadeVariant,
                onosVariant = options.onosVariant,
                prowlerVariant = options.prowlerVariant,
                isMale = string.lower(options.sexType) == "male",
                shoulderPadIndex = options.shoulderPadIndex,
                exoVariant = options.exoVariant,
                rifleVariant = options.rifleVariant,
                pistolVariant = options.pistolVariant,
                axeVariant = options.axeVariant,
                shotgunVariant = options.shotgunVariant,
                flamethrowerVariant = options.flamethrowerVariant,
                grenadeLauncherVariant = options.grenadeLauncherVariant,
                welderVariant = options.welderVariant,
                hmgVariant = options.hmgVariant,
                macVariant = options.macVariant,
                arcVariant = options.arcVariant,
                marineStructuresVariant = options.marineStructuresVariant,
                extractorVariant = options.extractorVariant,

                alienStructuresVariant = options.alienStructuresVariant,
                harvesterVariant = options.harvesterVariant,
                eggVariant = options.eggVariant,
                cystVariant = options.cystVariant,
                drifterVariant = options.drifterVariant,
                alienTunnelsVariant = options.alienTunnelsVariant,

                clogVariant = options.clogVariant,
                hydraVariant = options.hydraVariant,
                babblerVariant = options.babblerVariant,
                babblerEggVariant = options.babblerEggVariant,
            },
            true)
    end
end
