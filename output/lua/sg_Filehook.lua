--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

ModLoader.SetupFileHook( "lua/GameInfo.lua", "lua/sg_GameInfo.lua" , "post" )
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/sg_NS2Gamerules.lua" , "post" )

-- Sudden death mode disable repair of CommandStation and heal Hive
ModLoader.SetupFileHook( "lua/CommandStation.lua", "lua/sg_CommandStation.lua" , "post" )
ModLoader.SetupFileHook( "lua/CommandStructure.lua", "lua/sg_CommandStructure.lua" , "post" )

-- Special dynamicaly generated obstacles for func_doors
ModLoader.SetupFileHook( "lua/ObstacleMixin.lua", "lua/sg_ObstacleMixin.lua" , "post" )

-- Hook custom gui elements
ModLoader.SetupFileHook( "lua/GUIWorldText.lua", "lua/sg_GUIScriptLoader.lua" , "post" )

ModLoader.SetupFileHook( "lua/GUIInsight_TopBar.lua", "lua/sg_GUIInsight_TopBar.lua" , "replace" )
ModLoader.SetupFileHook( "lua/GUIFirstPersonSpectate.lua", "lua/sg_GUIFirstPersonSpectate.lua" , "replace" )


-- tech tree changes according doors
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/sg_Balance.lua" , "post" )
ModLoader.SetupFileHook( "lua/TechTree_Server.lua", "lua/sg_TechTree_Server.lua" , "post" )

ModLoader.SetupFileHook( "lua/TechData.lua", "lua/sg_TechData.lua" , "post" )

-- fix hive healing
ModLoader.SetupFileHook( "lua/Hive_Server.lua", "lua/sg_Hive_Server.lua" , "replace" )


-- fix concede sequence errors
ModLoader.SetupFileHook( "lua/ConcedeSequence.lua", "lua/sg_ConcedeSequence.lua" , "replace" )

-- enable commander bots
--ModLoader.SetupFileHook( "lua/bots/BotUtils.lua", "lua/bots/sg_BotUtils.lua" , "post" )
--ModLoader.SetupFileHook( "lua/bots/CommonActions.lua", "lua/bots/sg_CommonActions.lua" , "post" )
----ModLoader.SetupFileHook( "lua/bots/CommanderBrain.lua", "lua/bots/sg_CommanderBrain.lua" , "post" )
--
---- bot replacements :(
----ModLoader.SetupFileHook( "lua/bots/AlienCommanderBrain_Data.lua", "lua/bots/sg_AlienCommanderBrain_Data.lua" , "replace" )
----ModLoader.SetupFileHook( "lua/bots/MarineCommanderBrain_Data.lua", "lua/bots/sg_MarineCommanderBrain_Data.lua" , "replace" )
----ModLoader.SetupFileHook( "lua/bots/MarineBrain_Data.lua", "lua/bots/sg_MarineBrain_Data.lua" , "replace" )
----ModLoader.SetupFileHook( "lua/bots/SkulkBrain_Data.lua", "lua/bots/sg_SkulkBrain_Data.lua" , "replace" )
----ModLoader.SetupFileHook( "lua/bots/GorgeBrain_Data.lua", "lua/bots/sg_GorgeBrain_Data.lua" , "replace" )
--ModLoader.SetupFileHook( "lua/bots/BotMotion.lua", "lua/bots/sg_BotMotion.lua" , "replace" )

--updated by cn community:
--alien health value adjustments
ModLoader.SetupFileHook( "lua/BalanceHealth.lua", "lua/sg_BalanceHealth.lua" , "post" )
--remove the function siege's bot's tunnel action
ModLoader.SetupFileHook( "lua/bots/CommonAlienActions.lua", "lua/sg_CommonAlienActions.lua" , "post" )
ModLoader.SetupFileHook( "lua/Drifter.lua", "lua/sg_Drifter.lua" , "post" )

--unlock the Armory's tech branch
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/sg_Armory.lua" , "post" )

--add advanced welder tech
ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/sg_MarineTeam.lua" , "post" )
ModLoader.SetupFileHook( "lua/PlayingTeam.lua", "lua/sg_PlayingTeam.lua" , "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/sg_TechTreeButtons.lua" , "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/sg_TechTreeConstants.lua" , "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/sg_BalanceMisc.lua" , "post" )
--diasblead,unable to load the right animation
--ModLoader.SetupFileHook( "lua/MarineWeaponEffects.lua", "lua/Effects/sg_MarineWeaponEffects.lua" , "post" )

--Modify the judgment of placing tunnels
ModLoader.SetupFileHook( "lua/BuildUtility.lua", "lua/sg_BuildUtility.lua" , "post" )

--antistomp_jetpackers
ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/sg_JetpackMarine.lua" , "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Shockwave.lua","lua/sg_Shockwave.lua","post")

--skulk ability changes
ModLoader.SetupFileHook( "lua/Skulk.lua","lua/sg_Skulk.lua","post")

--observatory changes
ModLoader.SetupFileHook( "lua/Observatory.lua","lua/sg_Observatory.lua","post")

--limit onos numbers
--ModLoader.SetupFileHook( "lua/GUIAlienBuyMenu.lua","lua/sg_GUIAlienBuyMenu.lua","post")

-- changes
ModLoader.SetupFileHook( "lua/RoboticsFactory.lua","lua/sg_RoboticsFactory.lua","post")
-- ModLoader.SetupFileHook( "lua/NS2Utility.lua","lua/sg_NS2Utility.lua","post")

ModLoader.SetupFileHook("lua/Server.lua", "lua/compat_post_Server.lua", "post")

-- fix commander tunnel placement
ModLoader.SetupFileHook("lua/AlienCommander.lua", "lua/sg_AlienCommander.lua", "post")

-- stronger flashlight
ModLoader.SetupFileHook("lua/Marine.lua", "lua/sg_Marine.lua", "post")
ModLoader.SetupFileHook("lua/ExoFlashlight_Client.lua", "lua/sg_ExoFlashlight_Client.lua", "post")