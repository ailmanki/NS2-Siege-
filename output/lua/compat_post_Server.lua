--[[
Seems to be used to create additional bot pathing?
editor_setup.xml
```xml
<class name="nav_point">
    <pathing>
        <include/>
        <file>models/misc/tech_point/tech_point.model</file>
    </pathing>
    <model>
        <file>models/system/editor/gamerules.model</file>
    </model>
</class>
```
]]

-- Called as the map is being loaded to create the entities.
function OnMapLoadEntityNavPoint(mapName, groupName, values)
    if mapName == "nav_point" then -- Siege
        Pathing.AddFillPoint(values.origin)
    end
end
Event.Hook("MapLoadEntity", OnMapLoadEntityNavPoint)