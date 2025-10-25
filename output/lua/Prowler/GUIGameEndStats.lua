local function CHUDSetStatusStats(message)
	
	local kStatusString = {
		[kPlayerStatus.Dead]="Dead",
		[kPlayerStatus.Commander]="Commander",
		[kPlayerStatus.Exo]="Exo",
		[kPlayerStatus.GrenadeLauncher]="Grenade Launcher",
		[kPlayerStatus.Rifle]= "Rifle",
		[kPlayerStatus.Shotgun]="Shotgun",
		[kPlayerStatus.Flamethrower]="Flamethrower",
		[kPlayerStatus.Void]="Other",
		[kPlayerStatus.Spectator]="Spectator",
		[kPlayerStatus.Embryo]="Egg",
		[kPlayerStatus.Skulk]="Skulk",
		[kPlayerStatus.Gorge]="Gorge",
		[kPlayerStatus.Lerk]="Lerk",
		[kPlayerStatus.Fade]="Fade",
		[kPlayerStatus.Onos]="Onos",
        [kPlayerStatus.Changeling]="Changeling",
        [kPlayerStatus.Prowler]="Prowler",
	}
	
	local entry = {}
	entry.className = kStatusString[message.statusId] or "Unknown"
	entry.timeMinutes = message.timeMinutes
	table.insert(statusSummaryTable, entry)
	
	lastStatsMsg = Shared.GetTime()
end

Client.HookNetworkMessage("EndStatsStatus", CHUDSetStatusStats)