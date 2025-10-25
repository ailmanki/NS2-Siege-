
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
