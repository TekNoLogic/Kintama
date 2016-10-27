
local myname, ns = ...


local EXCLUDED_SLOTS = {
	INVTYPE_BODY = true,
	INVTYPE_ROBE = true,
	INVTYPE_TABARD = true,
}
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


function ns.GetEquippedItemLevel(slot_token)
	if EXCLUDED_SLOTS[slot_token] then return nil, true end

	local slot_id = SLOT_IDS[slot_token]
	if not slot_id then return end

	if type(slot_id) == "table" then
		return GetLowestItemlevel(slot_id[1], slot_id[2])
	else
		return GetSlotItemlevel(slot_id)
	end
end
