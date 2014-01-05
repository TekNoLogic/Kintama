
local myname, ns = ...


ns.bags = {}


local function ColorSlots(self)
	for i,slot in pairs(self.slots) do slot:ColorBorder() end
end


local function Update(self)
	local num_slots = GetContainerNumSlots(self.id)
	self.size = num_slots

	if num_slots == 0 then
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
	ContainerFrame_Update(self)
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


function ns.MakeBagFrame(bag, parent)
	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	frame.id = bag
	frame:SetID(bag)

	frame:SetHeight(39)
	if bag == BACKPACK_CONTAINER or bag == BANK_CONTAINER then
		frame:SetPoint('TOPLEFT', parent, 8, -8)
	elseif bag == (NUM_BAG_SLOTS + 1) then
		frame:SetPoint('TOPLEFT', ns.bags[BANK_CONTAINER], 'BOTTOMLEFT', 0, -2)
	else
		frame:SetPoint('TOPLEFT', ns.bags[bag-1], 'BOTTOMLEFT', 0, -2)
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

	if bag ~= BACKPACK_CONTAINER and bag ~= BANK_CONTAINER then
		ns.MakeBagSlotFrame(bag, frame)
	end

	ns.bags[bag] = frame
	parent.bags[bag] = frame

	return frame
end
