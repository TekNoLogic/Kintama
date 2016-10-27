
local myname, ns = ...


local SLOT_IDS = {
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


local function GetSlotItemlevel(slot_id)
	local link = GetInventoryItemLink("player", slot_id)
	return link and ns.ilvls[link]
end


local function GetLowestItemlevel(slot_id_1, slot_id_2)
	local lvl_1 = GetSlotItemlevel(slot_id_1)
	local lvl_2 = GetSlotItemlevel(slot_id_2)
	if not lvl_1 or not lvl_2 then return end
	return math.min(lvl_1, lvl_2)
end


local function GetEquippedItemLevel(bag, slot)
	local link = GetContainerItemLink(bag, slot)
	if not link then return end

	local _, _, _, _, _, _, _, _, slot_token = GetItemInfo(link)
	local slot_id = SLOT_IDS[slot_token]
	if not slot_id then return nil, true end

	if type(slot_id) == "table" then
		return GetLowestItemlevel(slot_id[1], slot_id[2])
	else
		return GetSlotItemlevel(slot_id)
	end
end


local function GetBagItemLevel(bag, slot)
	if ns.IsBindOnEquip(bag, slot) then return end

	local link = GetContainerItemLink(bag, slot)
	if not link then return end
	if not IsEquippableItem(link) then return end

	return ns.ilvls[link]
end


function ns.GetItemLevelsForCompare(bag, slot)
	local ilvl = GetBagItemLevel(bag, slot)
	if not ilvl then return end

	local equipped_ilvl, excluded = GetEquippedItemLevel(bag, slot)
	return ilvl, equipped_ilvl, excluded
end
