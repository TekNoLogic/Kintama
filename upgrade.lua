
local myname, ns = ...


-- Why isn't there an API for this?
local slotids = {
-- INVSLOT_FINGER1		= 11;
-- INVSLOT_FINGER2		= 12;
-- INVSLOT_TRINKET1	= 13;
-- INVSLOT_TRINKET2	= 14;
-- INVSLOT_MAINHAND	= 16;
-- INVSLOT_OFFHAND		= 17;
-- INVSLOT_RANGED		= 18;
-- INVSLOT_TABARD		= 19;

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
	-- INVTYPE_WEAPON = BLAH,
	-- INVTYPE_SHIELD = BLAH,
	-- INVTYPE_RANGED = BLAH,
	-- INVTYPE_2HWEAPON = BLAH,
	-- INVTYPE_RELIC = BLAH,
	-- INVTYPE_WEAPONMAINHAND = BLAH,
	-- INVTYPE_WEAPONOFFHAND = BLAH,
	-- INVTYPE_HOLDABLE = BLAH,
	-- INVTYPE_THROWN = BLAH,
	-- INVTYPE_RANGEDRIGHT = BLAH,
	-- INVTYPE_FINGER = BLAH,
	-- INVTYPE_TRINKET = BLAH,
}


local function GetItemLevel(slottoken)
	local slotid = slotids[slottoken]
	if not slotid then return end

	local link = GetInventoryItemLink("player", slotid)
	return link and ns.ilvls[link]
end


function ns.IsUpgrade(bag, slot)
	if ns.IsBindOnEquip(bag, slot) then return false end

	local link = GetContainerItemLink(bag, slot)
	if link and IsEquippableItem(link) then
		local ilvl = ns.ilvls[link]
		local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(link)
		local equipped = GetItemLevel(equipSlot)
		if not ilvl or not equipped then return end

		if ilvl == equipped then
			return 0
		else
			return ilvl > equipped
		end
	end
end
