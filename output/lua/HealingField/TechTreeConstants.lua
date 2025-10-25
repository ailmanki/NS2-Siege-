

local function AppendToEnum( tbl, key )
	if rawget(tbl,key) ~= nil then
		return
	end
	
	local maxVal = 0
    for k, v in next, tbl do
        if type(v) == "number" and v > maxVal then
            maxVal = v 
        end
    end
	
	rawset( tbl, key, maxVal+1 )
	rawset( tbl, maxVal+1, key )
	
end


-- incrase max...
kTechIdMax = kTechIdMax + 1

AppendToEnum(kTechId, "HealingField")