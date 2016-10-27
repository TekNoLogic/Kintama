
local myname, ns = ...


if ns.is_7_1 then return end


local slotids = {
	INVTYPE_HEAD = INVSLOT_HEAD,
	INVTYPE_NECK = INVSLOT_NECK,
	INVTYPE_SHOULDER = INVSLOT_SHOULDER,
	INVTYPE_CHEST = INVSLOT_CHEST,
	INVTYPE_CLOAK = INVSLOT_BACK,
	INVTYPE_WAIST = INVSLOT_WAIST,
	INVTYPE_LEGS = INVSLOT_LEGS,
	INVTYPE_FEET = INVSLOT_FEET,
	INVTYPE_WRIST = INVSLOT_WRIST,
	INVTYPE_HAND = INVSLOT_HAND,
	INVTYPE_FINGER = {INVSLOT_FINGER1, INVSLOT_FINGER2},
	INVTYPE_TRINKET = {INVSLOT_TRINKET1, INVSLOT_TRINKET2},
}


local function GetSlotItemlevel(slotid)
	local link = GetInventoryItemLink("player", slotid)
	return link and ns.ilvls[link]
end


local function GetLowestItemlevel(slotid1, slotid2)
	local lvl1 = GetSlotItemlevel(slotid1)
	local lvl2 = GetSlotItemlevel(slotid2)
	if not lvl1 or not lvl2 then return end
	return math.min(lvl1, lvl2)
end


local function GetItemLevel(slottoken)
	local slotid = slotids[slottoken]
	if not slotid then return end

	if type(slotid) == "table" then
		return GetLowestItemlevel(slotid[1], slotid[2])
	else
		return GetSlotItemlevel(slotid)
	end
end


local excludedslots = {
	INVTYPE_BODY = true,
	INVTYPE_ROBE = true,
	INVTYPE_TABARD = true,
}
function ns.IsUpgrade(bag, slot)
	if ns.IsBindOnEquip(bag, slot) then return false end

	local link = GetContainerItemLink(bag, slot)
	if not link then return false end
	if not IsEquippableItem(link) then return false end

	local ilvl = ns.ilvls[link]
	local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(link)
	local equipped = GetItemLevel(equipSlot)
	if not ilvl or excludedslots[equipSlot] then return end
	if not equipped then return true end

	return ilvl > equipped
end
