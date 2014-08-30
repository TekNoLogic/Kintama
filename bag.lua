
local myname, ns = ...


ns.bags = {}


local function ColorSlots(self)
	for i,slot in pairs(self.slots) do slot:ColorBorder() end
end


local function Update(self)
	local num_slots = GetContainerNumSlots(self.id)
	if self.isReagentBank then
		num_slots = ns.NUM_REAGENT_SLOTS
	end
	self.size = num_slots

	if num_slots == 0 or self.isReagentBank and not IsReagentBankUnlocked() then
		self:SetWidth(1)
		for i,slot in pairs(self.slots) do slot:Hide() end
		return
	end

	self:SetWidth(num_slots * 39 + 42)

	local f = self.slots[num_slots] -- Touch to ensure slot frames exist

	for i,slot in pairs(self.slots) do
		if i <= num_slots then
			slot:Show()
		else
			slot:Hide()
		end
	end

	self:ColorSlots()
	if self.isReagentBank then
		for _,slot in pairs(self.slots) do
			BankFrameItemButton_Update(slot)
		end
	else
		ContainerFrame_Update(self)
	end
end


local function OnEnter(self)
	GameTooltip:SetOwner(self)
	GameTooltip:SetText(self.tooltipText)
	GameTooltip:Show()
end
local function OnClick(self)
	PlaySound("UI_BagSorting_01")
	self.sortFunction()
end
local function MakeSortButton(parent, tooltiptext, sortfunc)
	if not ns.isWOD then return end
	local butt = CreateFrame("Button", nil, parent, "BankAutoSortButtonTemplate")
	butt:SetPoint("TOPLEFT")
	butt.tooltipText = tooltiptext
	butt.sortFunction = sortfunc
	butt:SetScript("OnEnter", OnEnter)
	butt:SetScript("OnClick", OnClick)
end


local function OnHide(self) self:UnregisterAllEvents() end
local function OnShow(self)
	self:Update()
	self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('BAG_UPDATE_COOLDOWN')
	self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
	self:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
end
local function OnEvent(self, event, bag, ...)
	if event == 'BAG_UPDATE' and bag ~= self.id then return end
	if event == "PLAYERBANKSLOTS_CHANGED" and
		 (self.id ~= BANK_CONTAINER or bag > NUM_BANKGENERIC_SLOTS) then return end
	self:Update()
end


function ns.MakeBagFrame(bag, parent, reagentbank)
	local bagid = bag
	local bagindex = bag
	if reagentbank then
		bagid = REAGENTBANK_CONTAINER
		if bag > 0 then
			bagindex = bag + NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
		end
	end

	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	if reagentbank then
		frame.isReagentBank = true
		frame.reagentBankColumn = bag == REAGENTBANK_CONTAINER and 1 or bag
	end
	frame.id = bagid
	frame:SetID(bagid)

	frame:SetSize(1, 39)
	if reagentbank and bag == REAGENTBANK_CONTAINER
	   or bag == BACKPACK_CONTAINER
		 or bag == BANK_CONTAINER then
		frame:SetPoint('TOPLEFT', parent, 8, -8)
	else
		local anchor
		if reagentbank and bag == 2 then
			anchor = ns.bags[REAGENTBANK_CONTAINER]
		elseif bag == (NUM_BAG_SLOTS + 1) and not reagentbank then
			anchor = ns.bags[BANK_CONTAINER]
		else
		  anchor = ns.bags[bagindex-1]
		end
		frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -2)
	end

	frame:SetScript('OnShow', OnShow)
	frame:SetScript('OnHide', OnHide)
	frame:SetScript('OnEvent', OnEvent)
	frame:SetScript('OnSizeChanged', function() parent:ResizeFrame() end)

	frame.Update = Update
	frame.ColorSlots = ColorSlots

	frame.slots = setmetatable({}, {
		__index = function(t,i)
			local f = ns.MakeSlotFrame(frame, i)
			t[i] = f
			return f
		end
	})

	if bag == BACKPACK_CONTAINER then
		MakeSortButton(frame, BAG_CLEANUP_BAGS, SortBags)
	elseif bag == BANK_CONTAINER then
		MakeSortButton(frame, BAG_CLEANUP_BANK, SortBankBags)
	elseif bag == REAGENTBANK_CONTAINER then
		MakeSortButton(frame, BAG_CLEANUP_REAGENT_BANK, SortReagentBankBags)
	elseif not reagentbank then
		ns.MakeBagSlotFrame(bag, frame)
	end

	frame.FilterIcon = CreateFrame("Button", nil, frame)

	ns.bags[bagindex] = frame
	parent.bags[bagindex] = frame

	return frame
end
