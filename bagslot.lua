
-- Bagslots are the special slots where the actual bag item is held.
-- They're not slots within a bag.

local myname, ns = ...


local function GetInventorySlot(self) return self.id end

local function Update(self)
	PaperDollItemSlotButton_Update(self)

	local itemid = GetInventoryItemID("player", self.id)
	if itemid and GetItemFamily(itemid) ~= 0 then
		self.border:Show()
	else
		self.border:Hide()
	end
end

local filters = {
	LE_BAG_FILTER_FLAG_EQUIPMENT,
	LE_BAG_FILTER_FLAG_CONSUMABLES,
	LE_BAG_FILTER_FLAG_TRADE_GOODS,
}
local function OnClick(self, button)
	if self.owned ~= false then
		if button == "LeftButton" then
			PutItemInBag(self.id)
		else
			local parent = self:GetParent()
			local id = parent:GetID()
			local filter
			for _,i in ipairs(filters) do
				if (id > NUM_BAG_SLOTS) then
					if GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i) then filter = i end
				else
					if GetBagSlotFlag(id, i) then filter = i end
				end
			end

			local nextfilter, nextval = filters[1], true
			if filter == filters[#filters] then
				nextfilter, nextval = filters[#filters], false
			elseif filter then
				nextfilter, nextval = filter + 1, true
			end

			if (id > NUM_BAG_SLOTS) then
				SetBankBagSlotFlag(id - NUM_BAG_SLOTS, nextfilter, nextval)
			else
				SetBagSlotFlag(id, nextfilter, nextval)
			end

			if nextval then
				parent.localFlag = nextfilter
				parent.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[nextfilter])
				parent.FilterIcon:Show()
			else
				parent.FilterIcon:Hide()
				parent.localFlag = -1
			end

		end
	else
		StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
	end
end

local function OnLeave()
	GameTooltip:Hide()
	ResetCursor()
end

local function OnEnterBag(self, ...)
	BagSlotButton_OnEnter(self, ...)
	if ns.isWOD then
		GameTooltip:AddLine("Right click to change sort filter")
		GameTooltip:Show()
	end
end

local function OnEnterBank(self, ...)
	BankFrameItemButton_OnEnter(self, ...)
	if ns.isWOD then
		GameTooltip:AddLine("Right click to change sort filter")
		GameTooltip:Show()
	end
end


ns.bagslots = {}
local _, texture = GetInventorySlotInfo("Bag1Slot")
function ns.MakeBagSlotFrame(bag, parent)
	local name = parent:GetName()..'Slot'
	local frame = CreateFrame('CheckButton', name, parent, 'ItemButtonTemplate')
	frame:SetSize(37, 37)
	frame:SetPoint('LEFT', parent)

	frame:RegisterForDrag("LeftButton")
	if ns.isWOD then
		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	end

	frame:SetScript('OnLeave', OnLeave)
	frame:SetScript('OnClick', OnClick)
	frame:SetScript('OnDragStart', BagSlotButton_OnDrag)
	frame:SetScript('OnReceiveDrag', OnClick)
	frame:SetScript('OnShow', PaperDollItemSlotButton_OnShow)
	frame:SetScript('OnHide', PaperDollItemSlotButton_OnHide)

	if bag > NUM_BAG_SLOTS then
		frame.GetInventorySlot = GetInventorySlot
		frame.UpdateTooltip = OnEnterBank
		frame:SetScript('OnEnter', OnEnterBank)
		frame:SetScript('OnEvent', BankFrameBagButton_OnEvent)

		local bagid = bag
		if ns.isWOD then bagid = bag - NUM_BAG_SLOTS end
		frame.id = BankButtonIDToInvSlotID(bagid, 1)
	else
		frame.UpdateTooltip = OnEnterBag
		frame:SetScript('OnEnter', OnEnterBag)
		frame:SetScript('OnEvent', PaperDollItemSlotButton_OnEvent)

		frame.id = GetInventorySlotInfo("Bag"..(bag-1).."Slot")
	end

	frame.isBag = true
	frame:SetID(frame.id)

	frame.icon:SetTexture(texture)
	frame.backgroundTextureName = texture

	frame.Update = Update

	local border = frame:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	border:SetBlendMode("ADD")
	border:SetAlpha(.5)
	border:SetVertexColor(1,0,1)

	border:SetPoint('CENTER', frame, 'CENTER', 0, 1)
	border:SetWidth(frame:GetWidth() * 2 - 5)
	border:SetHeight(frame:GetHeight() * 2 - 5)

	frame.border = border

	ns.bagslots[bag] = frame
	parent.bagslot = frame
end
