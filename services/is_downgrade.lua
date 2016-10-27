
local myname, ns = ...


function ns.IsDowngrade(bag, slot)
	local ilvl, equipped_ilvl, excluded = ns.GetItemLevelsForCompare(bag, slot)
	if excluded or not ilvl or not equipped_ilvl then return end

	return ilvl <= (equipped_ilvl - 10)
end
