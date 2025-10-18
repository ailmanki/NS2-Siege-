
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()
    ClassToGrid["EtherealGate"] = { 3, 1 } -- Door
    return ClassToGrid
end
