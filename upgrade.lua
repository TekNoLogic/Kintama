
local myname, ns = ...


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

	INVTYPE_WEAPON = INVSLOT_MAINHAND,
	INVTYPE_2HWEAPON = INVSLOT_MAINHAND,
	INVTYPE_RANGED = INVSLOT_MAINHAND,
	INVTYPE_RANGEDRIGHT = INVSLOT_MAINHAND, -- So wands are "ranged right" and equip in main hand...
	-- INVTYPE_SHIELD = BLAH,
	-- INVTYPE_WEAPONMAINHAND = BLAH,
	-- INVTYPE_WEAPONOFFHAND = BLAH,
	-- INVTYPE_HOLDABLE = BLAH,
}
-- INVSLOT_MAINHAND	= 16;
-- INVSLOT_OFFHAND		= 17;
-- INVSLOT_RANGED		= 18;


local function GetItemLevel(slottoken)
	local slotid = slotids[slottoken]
	if not slotid then return end

	if type(slotid) == "table" then
		local link1 = GetInventoryItemLink("player", slotid[1])
		local link2 = GetInventoryItemLink("player", slotid[2])
		local lvl1 = link1 and ns.ilvls[link1]
		local lvl2 = link2 and ns.ilvls[link2]
		if not lvl1 or not lvl2 then return end
		return math.max(lvl1, lvl2)
	else
		local link = GetInventoryItemLink("player", slotid)
		return link and ns.ilvls[link]
	end
end


function ns.IsUpgrade(bag, slot)
	if ns.IsBindOnEquip(bag, slot) then return false end

	local link = GetContainerItemLink(bag, slot)
	if link and IsEquippableItem(link) then
		local ilvl = ns.ilvls[link]
		local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(link)
		local equipped = GetItemLevel(equipSlot)
		if not ilvl or equipSlot == "INVTYPE_TABARD" then return end
		if not equipped then return true end

		if ilvl == equipped then
			return 0
		else
			return ilvl > equipped
		end
	end
end
