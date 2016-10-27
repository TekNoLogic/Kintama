
local myname, ns = ...


function ns.IsDowngrade(bag, slot)
	if ns.IsBindOnEquip(bag, slot) then return false end

	local link = GetContainerItemLink(bag, slot)
	if not link then return false end
	if not IsEquippableItem(link) then return false end

	local ilvl = ns.ilvls[link]
	if not ilvl then return end

	local _, _, _, _, _, _, _, _, slot_token = GetItemInfo(link)
	local equipped_ilvl, excluded = ns.GetEquippedItemLevel(slot_token)
	if excluded then return end
	if not equipped_ilvl then return false end

	return ilvl <= (equipped_ilvl - 10)
end
