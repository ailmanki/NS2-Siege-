ModLoader.SetupFileHook( "lua/Globals.lua", "lua/Prowler/Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/Prowler/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/Prowler/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/Prowler/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/Prowler/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/Shared.lua", "lua/Prowler/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienTeam.lua", "lua/Prowler/AlienTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIAlienBuyMenu.lua", "lua/Prowler/GUIAlienBuyMenu.lua", "post" )

--ModLoader.SetupFileHook( "lua/Drifter.lua", "lua/Prowler/Drifter.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/Prowler/NS2Utility.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2ConsoleCommands_Server.lua", "lua/Prowler/NS2ConsoleCommands_Server.lua", "post" )

ModLoader.SetupFileHook( "lua/Alien.lua", "lua/Prowler/Alien.lua", "post" )
ModLoader.SetupFileHook( "lua/Skulk.lua", "lua/Prowler/Prowler.lua", "post" )
ModLoader.SetupFileHook( "lua/PlayerHallucinationMixin.lua", "lua/Prowler/PlayerHallucinationMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienHallucination.lua", "lua/Prowler/AlienHallucination.lua", "post" )
ModLoader.SetupFileHook( "lua/CommAbilities/Alien/HallucinationCloud.lua", "lua/Prowler/HallucinationCloud.lua", "post" )

ModLoader.SetupFileHook( "lua/AlienWeaponEffects.lua", "lua/Prowler/AlienWeaponEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/PlayerEffects.lua", "lua/Prowler/PlayerEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/DamageEffects.lua", "lua/Prowler/DamageEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/DamageTypes.lua", "lua/Prowler/DamageTypes.lua", "post" )
ModLoader.SetupFileHook( "lua/ShieldableMixin.lua", "lua/Prowler/ShieldableMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/ClientLOSMixin.lua", "lua/Prowler/ClientLOSMixin.lua", "post" )

ModLoader.SetupFileHook( "lua/Scoreboard.lua", "lua/Prowler/Scoreboard.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienBuy_Client.lua", "lua/Prowler/AlienBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/Prowler/TechTreeButtons.lua", "post" )
ModLoader.SetupFileHook( "lua/EvolutionChamber.lua", "lua/Prowler/EvolutionChamber.lua", "post" )
ModLoader.SetupFileHook( "lua/TeamInfo.lua", "lua/Prowler/TeamInfo.lua", "post" )
ModLoader.SetupFileHook( "lua/Embryo.lua", "lua/Prowler/Embryo.lua", "post" )
ModLoader.SetupFileHook( "lua/sg_sClient.lua", "lua/Prowler/Client.lua", "post" )
ModLoader.SetupFileHook( "lua/HitSounds.lua", "lua/Prowler/HitSounds.lua", "post" )
ModLoader.SetupFileHook( "lua/VoiceOver.lua", "lua/Prowler/VoiceOver.lua", "post" )
ModLoader.SetupFileHook( "lua/ServerStats.lua", "lua/Prowler/ServerStats.lua", "post" )
ModLoader.SetupFileHook( "lua/TeleportTrigger.lua", "lua/Prowler/TeleportTrigger.lua", "post" )
--ModLoader.SetupFileHook( "lua/GUIGameEndStats.lua", "lua/Prowler/GUIGameEndStats.lua", "post" ) -- does not work

-- TODO: fix this properly
--ModLoader.SetupFileHook( "lua/Hallucination.lua", "lua/Prowler/Hallucination.lua", "replace" )
--ModLoader.SetupFileHook( "lua/bots/PlayerBot.lua", "lua/Prowler/bots/PlayerBot.lua", "post" )
--ModLoader.SetupFileHook( "lua/bots/SkulkBrain_Data.lua", "lua/Prowler/bots/SkulkBrain_Data.lua", "replace" )

ModLoader.SetupFileHook( "lua/Combat/Globals.lua", "lua/Prowler/CombatGlobals.lua", "post" )

-- Prowler Variants
ModLoader.SetupFileHook( "lua/menu2/PlayerScreen/Customize/CustomizeScene.lua", "lua/Prowler/menu2/PlayerScreen/Customize/CustomizeScene.lua", "replace" )
ModLoader.SetupFileHook( "lua/menu2/PlayerScreen/Customize/CustomizeSceneData.lua", "lua/Prowler/menu2/PlayerScreen/Customize/CustomizeSceneData.lua", "replace" )
ModLoader.SetupFileHook( "lua/menu2/PlayerScreen/Customize/GUIMenuCustomizeScreen.lua", "lua/Prowler/menu2/PlayerScreen/Customize/GUIMenuCustomizeScreen.lua", "replace" )

ModLoader.SetupFileHook( "lua/menu/GUIMainMenu_Customize.lua", "lua/Prowler/menu/GUIMainMenu_Customize.lua", "replace" )
ModLoader.SetupFileHook( "lua/menu/MenuPoses.lua", "lua/Prowler/menu/MenuPoses.lua", "replace" )
ModLoader.SetupFileHook( "lua/NetworkMessages.lua", "lua/Prowler/NetworkMessages.lua", "post" )
