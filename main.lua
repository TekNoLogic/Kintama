local _, common = ...

local Kintama = LibStub('AceAddon-3.0'):NewAddon('Kintama', 'AceHook-3.0', 'AceEvent-3.0', 'AceConsole-3.0', 'AceBucket-3.0')
local AceDB3 = LibStub('AceDB-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale('Kintama')

local MAX_COLS = 22

function Kintama:OnInitialize()
	self.db = AceDB3:New('KintamaDB', common:DatabaseDefaults(), true)

	self.column_width = 39
	self.row_height = 39
	self.top_border = 2
	self.bottom_border = 24
	self.right_border = 5
	self.left_border = 8

	self.bag_indexes = {0, 1, 2, 3, 4 }

	self.frame = common.frame:NewMainFrame('KintamaFrame', self)
	self.frame:SetPosition(self.db.profile.position)
	self.frame:CustomizeFrame()
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

	self:RegisterEvent("AUCTION_HOUSE_SHOW", 	open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED", 	close)
	self:RegisterEvent("BANKFRAME_OPENED", 	open)
	self:RegisterEvent("BANKFRAME_CLOSED", 	close)
	self:RegisterEvent("MAIL_SHOW",		open)
	self:RegisterEvent("MAIL_CLOSED", 		close)
	self:RegisterEvent("MERCHANT_SHOW", 	open)
	self:RegisterEvent("MERCHANT_CLOSED", 	close)
	self:RegisterEvent("TRADE_SHOW", 		open)
	self:RegisterEvent("TRADE_CLOSED", 		close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
end

--[[************************************************************************************************
-- Bag methods
**************************************************************************************************]]
local function prepare_bag_slots(self, bag_id)
	local bag_size = GetContainerNumSlots(bag_id)
	local free_slots, bag_type = GetContainerNumFreeSlots(bag_id)

	self.bag_frames[bag_id].size = bag_size
	self.bag_frames[bag_id].free_slots = free_slots

	for slot_id = 1, bag_size do
		local slot_key = ('%s:%s'):format(bag_id, slot_id)
		if not self.slot_frames[slot_key] then
			self.slot_frames[slot_key] = common.frame:MakeSlotFrame(self.bag_frames[bag_id], slot_id, self)
		end
	end
end

function Kintama:PrepareBagSlots(bag_id)
	if not self.bag_frames then
		local bag_frames = {}

		for _, bag_id in pairs(self.bag_indexes) do
			bag_frames[bag_id] = common.frame:MakeBagFrame(bag_id, self.frame, self)
		end

		self.bag_frames = bag_frames
	end

	if not self.slot_frames then
		self.slot_frames = {}
	end

	if bag_id then
		prepare_bag_slots(self, bag_id)
	else
		for _, bag_id in pairs(self.bag_indexes) do
			prepare_bag_slots(self, bag_id)
		end
	end
end

function Kintama:SlotOrder()
	local keys, keys_to_slots, slots, empty_slots = {}, {}, {}, {}
	local count, empty_count = 0, 0

	for slot_key, slot_frame in pairs(self.slot_frames) do
		local item_link = GetContainerItemLink(slot_frame:GetParent():GetID(), slot_frame:GetID())

		if item_link then
			local name, link, quality, ilevel, required_level, class, subclass, max_stack, equipment_slot, texture, vendor_price = GetItemInfo(item_link)
			local key = ('%s%s%d%d%s%s'):format(class, equipment_slot or subclass, quality, 500-(ilevel or 0), name, slot_key)

			table.insert(keys, key)
			keys_to_slots[key] = self.slot_frames[slot_key]

			count = count + 1
		else
			empty_count = empty_count + 1
			empty_slots[empty_count] = slot_frame
		end
	end

	table.sort(keys)

	for _, key in pairs(keys) do
		table.insert(slots, keys_to_slots[key])
	end

	if empty_count > 0 then
		local number_of_empties = math.min(MAX_COLS - math.fmod(count, MAX_COLS), empty_count)

		for i=1, number_of_empties do
			table.insert(slots, empty_slots[i])
		end
	end

	return slots
end

function Kintama:OrganizeBagSlots()
	local current_column, current_row, widest_column, just_incremented_row = 1, 1, 0, false

	for slot_key, slot_frame in pairs(self.slot_frames) do
		slot_frame:Hide()
	end

	for _, slot_frame in pairs(self:SlotOrder()) do
		just_incremented_row = false
		slot_frame:ClearAllPoints()
		slot_frame:SetPoint('TOPLEFT', self.frame:GetName(), 'TOPLEFT', self.left_border + self.column_width * (current_column - 1), 0 - self.top_border - (self.row_height * current_row))
		slot_frame:SetFrameLevel(self.frame:GetFrameLevel()+20)
		slot_frame:Show()

		widest_column = math.max(widest_column, current_column)
		current_column = current_column + 1

		if current_column > MAX_COLS and not just_incremented_row then
			current_column, current_row, just_incremented_row = 1, current_row + 1, true
		end
	end

	if not just_incremented_row then
		current_row = current_row + 1
	end

	local slot_count, free_slot_count = 0, 0
	for _, bag_frame in pairs(self.bag_frames) do
		slot_count = slot_count + bag_frame.size
		free_slot_count = free_slot_count + bag_frame.free_slots
	end

	self.frame.slot_counts:SetFormattedText(L['%d/%d Slots'], slot_count - free_slot_count, slot_count)

	self.frame:SetHeight(current_row * self.row_height + self.bottom_border + self.top_border)
	self.frame:SetWidth(widest_column * self.column_width + self.left_border + self.right_border)
end

local colorCache = {}
local plain = {r = .05, g = .05, b = .05}
function Kintama:ColorSlotBorder(slot_frame, force_color)
	local bag_frame = slot_frame:GetParent()
	local color = force_color or plain

	if not slot_frame.border then
		-- Thanks to oglow for this method
		local border = slot_frame:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		border:SetBlendMode("ADD")
		border:SetAlpha(.5)

		border:SetPoint('CENTER', slot_frame, 'CENTER', 0, 1)
		border:SetWidth(slot_frame:GetWidth() * 2 - 5)
		border:SetHeight(slot_frame:GetHeight() * 2 - 5)
		slot_frame.border = border
	end

	local bcolor --leaving hook for bagcolors

	if not force_color and not bcolor then
		local link = GetContainerItemLink(bag_frame:GetID(), slot_frame:GetID())
		if link then
			local _, _, rarity = GetItemInfo(link)
			if rarity and rarity > 1 then
				color = colorCache[rarity]
				if not color then
					local r, g, b, hex = GetItemQualityColor(rarity)
					color = {r = r, g = g, b = b}
					colorCache[rarity] = color
				end
			end
		end
	end

	local target = slot_frame.border
	target:SetVertexColor(color.r, color.g, color.b)
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

function Kintama:DecorateBagSlots(bag_id)
	if not bag_id then
		for _, slot_frame in pairs(self.slot_frames) do
			if slot_frame:IsVisible() then
				self:ColorSlotBorder(slot_frame)
			end
		end
		return
	end

	local bag_frame = self.bag_frames[bag_id]
	if not bag_frame or not bag_frame.size or bag_frame.size == 0 then
		return
	end

	for slot_id=1, bag_frame.size do
		local slot_frame = self.slot_frames[('%d:%d'):format(bag_id, slot_id)]
		if slot_frame:IsVisible() then
			self:ColorSlotBorder(slot_frame)
		end
	end
end

function Kintama:UpdateAllBags()
	self:PrepareBagSlots()
	self:OrganizeBagSlots()
	self:DecorateBagSlots()

	for _, bag_frame in pairs(self.bag_frames) do
		if bag_frame.size > 0 then
			ContainerFrame_Update(bag_frame)
		end
	end
end

function Kintama:UpdateBags(bag_ids)
	for bag_id, _ in pairs(bag_ids) do
		if self.bag_frames[bag_id] then
			self:PrepareBagSlots(bag_id)
		end
	end

	self:OrganizeBagSlots()
	for bag_id, _ in pairs(bag_ids) do
		local bag_frame = self.bag_frames[bag_id]
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

function Kintama:OnDragStart(frame)
	frame:StartMoving()
	frame.is_moving = true

	for _, slot_frame in pairs(self.slot_frames) do
		slot_frame:EnableMouse(false)
	end
end

function Kintama:OnDragStop(frame)
	frame:StopMovingOrSizing(self)
	if frame.is_moving then
		self.db.profile.position = frame:GetPosition()

		for _, slot_frame in pairs(self.slot_frames) do
			slot_frame:EnableMouse(true)
		end
	end

	self.is_moving = false
end

function Kintama:OnFrameCreate(frame)
	frame.money_frame = common.frame:MakeMoneyFrame('MoneyFrame', frame, 'PLAYER')
	frame.money_frame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)

	frame.slot_counts = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.slot_counts:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 10, 8)
end
