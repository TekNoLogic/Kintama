
local myname, ns = ...

local Kintama = LibStub('AceAddon-3.0'):NewAddon('Kintama', 'AceHook-3.0', 'AceEvent-3.0', 'AceConsole-3.0', 'AceBucket-3.0')

function Kintama:OnInitialize()
	self.column_width = 39
	self.row_height = 39
	self.top_border = 8
	self.bottom_border = 24
	self.right_border = 5
	self.left_border = 8

	self.frame = ns.NewMainFrame('KintamaFrame', self)
	self.frame:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
	self.frame:SetHeight(5 * 39 + self.bottom_border + self.top_border)
	self.frame:SetBackdropColor(0,0,0, 0.65)
	self.frame:SetFrameStrata('MEDIUM')

	for bag_id=0,4 do
		ns.MakeBagFrame(bag_id, self.frame)
	end
	ns.MakeBagFrame = nil

	BagItemSearchBox:Hide()
	BagItemSearchBox.Show = BagItemSearchBox.Hide
end

function Kintama:OnEnable()
	self:SecureHook("IsBagOpen")
	self:RawHook("ToggleBag", true)
	self:RawHook("ToggleBackpack", "ToggleBag", true)
	self:RawHook("ToggleAllBags", "ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:RawHook("CloseBag", true)

	local open = function()
		self.was_opened = self.is_opened
		if not self.is_opened then
			self:OpenBag()
		end
	end

	local close = function(event)
		if (event == "MAIL_CLOSED" and not self.is_reopened) or not self.was_opened then
			self:CloseBag()
		end
	end

	self:RegisterEvent("AUCTION_HOUSE_SHOW",  open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED",  close)
	self:RegisterEvent("BANKFRAME_OPENED",  open)
	self:RegisterEvent("BANKFRAME_CLOSED",  close)
	self:RegisterEvent("MAIL_SHOW",   open)
	self:RegisterEvent("MAIL_CLOSED",     close)
	self:RegisterEvent("MERCHANT_SHOW",   open)
	self:RegisterEvent("MERCHANT_CLOSED",   close)
	self:RegisterEvent("TRADE_SHOW",    open)
	self:RegisterEvent("TRADE_CLOSED",    close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
end

--[[************************************************************************************************
-- Bag methods
**************************************************************************************************]]
local function prepare_bag_slots(self, bag_id)
	local bag_size = GetContainerNumSlots(bag_id)
	local free_slots, bag_type = GetContainerNumFreeSlots(bag_id)

	ns.bags[bag_id].size = bag_size
	ns.bags[bag_id].free_slots = free_slots
end

function Kintama:PrepareBagSlots(bag_id)
	if bag_id then
		prepare_bag_slots(self, bag_id)
	else
		for bag_id=0,4 do
			prepare_bag_slots(self, bag_id)
		end
	end
end

function Kintama:OrganizeBagSlots()
	local widest_column, slot_count, free_slot_count = 0, 0, 0

	for bag=0,4 do
		local f = ns.bags[bag]
		f:Update()
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
		slot_count = slot_count + f.size
		free_slot_count = free_slot_count + f.free_slots
	end

	self.frame.slot_counts:SetFormattedText('%d/%d Slots', slot_count - free_slot_count, slot_count)

	self.frame:SetWidth(widest_column + self.left_border + self.right_border)
end


--[[************************************************************************************************
-- Event Handlers
**************************************************************************************************]]
function Kintama:IsBagOpen(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return
	end

	return self.is_opened and bag_id or nil
end

function Kintama:ToggleBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.ToggleBag(bag_id)
	end

	if self.is_opened then
		self:CloseBag()
	else
		self:OpenBag()
	end
end

function Kintama:OpenBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.OpenBag(bag_id)
	end

	self.frame:Show()
	self.is_reopened = self.is_opened
	self.is_opened = true
end

function Kintama:CloseBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.CloseBag(bag_id)
	end

	self.frame:Hide()
	self.is_opened = false
end

function Kintama:DecorateBagSlots(bag)
	if not bag then
		for i,bag in pairs(ns.bags) do bag:ColorSlots() end
		return
	end

	ns.bags[bag]:ColorSlots()
end

function Kintama:UpdateAllBags()
	self:PrepareBagSlots()
	self:OrganizeBagSlots()
	self:DecorateBagSlots()

	for _,bag in pairs(ns.bags) do
		if bag.size > 0 then
			ContainerFrame_Update(bag)
		end
	end
end

function Kintama:UpdateBags(bag_ids)
	for bag_id, _ in pairs(bag_ids) do
		if ns.bags[bag_id] then
			self:PrepareBagSlots(bag_id)
		end
	end

	self:OrganizeBagSlots()
	for bag_id, _ in pairs(bag_ids) do
		local bag_frame = ns.bags[bag_id]
		if bag_frame and bag_frame.size > 0 then
			self:DecorateBagSlots(bag_id)
			ContainerFrame_Update(bag_frame)
		end
	end
end


--[[************************************************************************************************
-- Frame delegates
**************************************************************************************************]]
function Kintama:OnShow(frame)
	self:UpdateAllBags()

	self.bag_update_bucket = self:RegisterBucketEvent('BAG_UPDATE', .1, 'UpdateBags')

	self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateAllBags')
	self:RegisterEvent('UPDATE_INVENTORY_ALERTS', 'UpdateAllBags')
end

function Kintama:OnHide(frame)
	self:UnregisterBucket(self.bag_update_bucket)

	self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
	self:UnregisterEvent('UPDATE_INVENTORY_ALERTS')

	self:CloseBag() -- internal cleanup
end

function Kintama:OnFrameCreate(frame)
	frame.money_frame = ns.MakeMoneyFrame('MoneyFrame', frame, 'PLAYER')
	frame.money_frame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)

	frame.slot_counts = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.slot_counts:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 10, 8)
end
