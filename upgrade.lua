
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
}


local weapon_slotids = {
	INVTYPE_WEAPON = INVSLOT_MAINHAND,
	INVTYPE_2HWEAPON = INVSLOT_MAINHAND,

	INVTYPE_WEAPONMAINHAND = INVSLOT_MAINHAND,
	INVTYPE_WEAPONOFFHAND = INVSLOT_OFFHAND,
	INVTYPE_HOLDABLE = INVSLOT_OFFHAND,
	INVTYPE_SHIELD = INVSLOT_OFFHAND,
	INVTYPE_RANGED = INVSLOT_MAINHAND,
	INVTYPE_RANGEDRIGHT = INVSLOT_MAINHAND, -- So wands are "ranged right" and equip in main hand...
}
local mainhand_types = {
	INVTYPE_WEAPONMAINHAND = true,
	-- INVTYPE_RANGED = true, -- Hunter weapons are effectively 2H
	INVTYPE_RANGEDRIGHT = true,
}
local offhand_types = {
	INVTYPE_WEAPONOFFHAND = true,
	INVTYPE_HOLDABLE = true,
	INVTYPE_SHIELD = true,
}
local dual1Hspecs = {
	[72]  = true, -- Fury warriors
	[263] = true, -- Enhancement shaman
	[268] = true, -- Brewmaster monk
	[269] = true, -- Windwalker monk
}


local function GetCurrentSpecID()
	local specIndex = GetSpecialization()
	if not specIndex then return end
	return GetSpecializationInfo(specIndex)
end


local function GetEquippedInvType(slotid)
	local link = GetInventoryItemLink("player", slotid)
	if not link then return end
	local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(link)
	return equipSlot
end


local _, myclass = UnitClass("player")
local function IsDualWield1H()
	-- Rogue and Rogue 2.0 can **only** dual-wield 1H weapons
	if myclass == "ROGUE" then return true end
	if myclass == "DEMONHUNTER" then return true end

	-- Check for current class/spec that in dual-wield capable
	local specID = GetCurrentSpecID()
	if not (myclass == "DEATHKNIGHT" or specid and dual1Hspecs[specid]) then
		return false
	end

	-- Look at equipment to see if we are currently in dual mode
	local slot = GetEquippedInvType(INVSLOT_MAINHAND)
	if not (slot == "INVTYPE_WEAPON" or slot == "INVTYPE_WEAPONMAINHAND") then
		-- We don't have a 1H weapon in mainhand
		return false
	end

	local slot = GetEquippedInvType(INVSLOT_OFFHAND)
	if not (slot == "INVTYPE_WEAPON" or slot == "INVTYPE_WEAPONOFFHAND") then
		-- We don't have a 1H weapon in offhand
		return false
	end

	return true
end


local function IsDualWield2H()
	-- Arms warriors only
	return GetCurrentSpecID() == 71
end


local function IsMonoWield1H()
	-- Check what is equipped
	local slot = GetEquippedInvType(INVSLOT_MAINHAND)
	return not not (mainhand_types[slot] or slot == "INVTYPE_WEAPON")
end


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


local function GetAverageItemlevel(slotid1, slotid2)
	local lvl1 = GetSlotItemlevel(slotid1)
	local lvl2 = GetSlotItemlevel(slotid2)
	if not lvl1 or not lvl2 then return end
	return (lvl1 + lvl2) / 2
end


local function GetWeaponItemLevel(slottoken)
	if not weapon_slotids[slottoken] then return end

	if IsDualWield2H() then
		if slottoken == "INVTYPE_2HWEAPON" then
			-- If item is 2H, return lowest ilvl
			return GetLowestItemlevel(INVSLOT_MAINHAND, INVSLOT_OFFHAND)
		end

		-- Ignore all other items (why would they spec 2H-dual and not use it?)

	elseif IsDualWield1H() then
		if mainhand_types[slottoken] then
			-- If item is specific-hand, return that slot's ilvl
			return GetSlotItemlevel(INVSLOT_MAINHAND)

		elseif offhand_types[slottoken] then
			-- If item is specific-hand, return that slot's ilvl
			return GetSlotItemlevel(INVSLOT_OFFHAND)

		elseif slottoken == "INVTYPE_WEAPON" then
			-- If item is abidexterous 1H, return lowest ilvl
			return GetLowestItemlevel(INVSLOT_MAINHAND, INVSLOT_OFFHAND)

		elseif slottoken == "INVTYPE_2HWEAPON" then
			-- If item is 2H, return average ilvl
			return GetAverageItemlevel(INVSLOT_MAINHAND, INVSLOT_OFFHAND)
		end

	elseif IsMonoWield1H() then
		if mainhand_types[slottoken] or slottoken == "INVTYPE_WEAPON" then
			-- If item is 1H, return main hand ilvl
			return GetSlotItemlevel(INVSLOT_MAINHAND)

		elseif offhand_types[slottoken] then
			-- If item is frill or shield, return off-hand ilvl
			return GetSlotItemlevel(INVSLOT_OFFHAND)

		elseif slottoken == "INVTYPE_2HWEAPON" then
			-- If item is 2H, return avg ilvl
			return GetAverageItemlevel(INVSLOT_MAINHAND, INVSLOT_OFFHAND)
		end

	else -- mono-wield 2H
		-- Any item will replace this, so just return main hand ilvl
		return GetSlotItemlevel(INVSLOT_MAINHAND)
	end
end


local function GetItemLevel(slottoken)
	local slotid = slotids[slottoken]
	if not slotid then return GetWeaponItemLevel(slottoken) end

	if type(slotid) == "table" then
		return GetLowestItemlevel(slotid[1], slotid[2])
	else
		return GetSlotItemlevel(slotid)
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
