-- force update


local kSetPlayerVariantMessage =
{
    isMale = "boolean",
    marineVariant = "enum kMarineVariants",
    skulkVariant = "enum kSkulkVariants",
    gorgeVariant = "enum kGorgeVariants",
    lerkVariant = "enum kLerkVariants",
    fadeVariant = "enum kFadeVariants",
    onosVariant = "enum kOnosVariants",
    prowlerVariant = "enum kProwlerVariants",

    shoulderPadIndex = string.format("integer (0 to %d)", #kShoulderPad2ItemId),
    exoVariant = "enum kExoVariants",
    rifleVariant = "enum kRifleVariants",
    pistolVariant = "enum kPistolVariants",
    axeVariant = "enum kAxeVariants",
    shotgunVariant = "enum kShotgunVariants",
    flamethrowerVariant = "enum kFlamethrowerVariants",
    grenadeLauncherVariant = "enum kGrenadeLauncherVariants",
    welderVariant = "enum kWelderVariants",
    hmgVariant = "enum kHMGVariants",
    macVariant = "enum kMarineMacVariants",
    arcVariant = "enum kMarineArcVariants",
    marineStructuresVariant = "enum kMarineStructureVariants",
    extractorVariant = "enum kExtractorVariants",

    alienStructuresVariant = "enum kAlienStructureVariants",
    harvesterVariant = "enum kHarvesterVariants",
    eggVariant = "enum kEggVariants",
    cystVariant = "enum kAlienCystVariants",
    drifterVariant = "enum kAlienDrifterVariants",
    alienTunnelsVariant = "enum kAlienTunnelVariants",
    clogVariant = "enum kClogVariants",
    hydraVariant = "enum kHydraVariants",
    babblerVariant = "enum kBabblerVariants",
    babblerEggVariant = "enum kBabblerEggVariants",
}
Shared.RegisterNetworkMessage("SetPlayerVariant", kSetPlayerVariantMessage)