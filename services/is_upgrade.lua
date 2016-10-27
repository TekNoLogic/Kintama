
local myname, ns = ...


function ns.IsUpgrade(bag, slot)
	local ilvl, equipped_ilvl, excluded = ns.GetItemLevelsForCompare(bag, slot)
	if excluded or not ilvl then return end
	
	if not equipped_ilvl then return true end
	return ilvl > equipped_ilvl
end
