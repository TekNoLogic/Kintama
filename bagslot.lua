
-- Bagslots are the special slots where the actual bag item is held.
-- They're not slots within a bag.

local myname, ns = ...


local function Update(self)
	PaperDollItemSlotButton_Update(self)

	local itemid = GetInventoryItemID("player", self.id)
	if itemid and GetItemFamily(itemid) ~= 0 then
		self.border:Show()
	else
		self.border:Hide()
	end
end
local function OnClick(self)
	if self.owned ~= false then
		PutItemInBag(self.id)
	else
		StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
	end
end
local function OnLeave()
	GameTooltip:Hide()
	ResetCursor()
end


ns.bagslots = {}
local _, texture = GetInventorySlotInfo("Bag1Slot")
function ns.MakeBagSlotFrame(bag, parent)
	local name = parent:GetName()..'Slot'
	local frame = CreateFrame('CheckButton', name, parent:GetParent(), 'ItemButtonTemplate')
	frame:SetSize(37, 37)
	frame:SetPoint('LEFT', parent)

	frame:RegisterForDrag("LeftButton")

	frame:SetScript('OnLeave', OnLeave)
	frame:SetScript('OnClick', OnClick)
	frame:SetScript('OnDragStart', BagSlotButton_OnDrag)
	frame:SetScript('OnReceiveDrag', OnClick)
	frame:SetScript('OnShow', PaperDollItemSlotButton_OnShow)
	frame:SetScript('OnHide', PaperDollItemSlotButton_OnHide)

	if bag > NUM_BAG_SLOTS then
		frame.GetInventorySlot = ButtonInventorySlot
		frame.UpdateTooltip = BankFrameItemButton_OnEnter
		frame:SetScript('OnEnter', BankFrameItemButton_OnEnter)
		frame:SetScript('OnEvent', BankFrameBagButton_OnEvent)

		frame.id = BankButtonIDToInvSlotID(bag, 1)
	else
		frame.UpdateTooltip = BagSlotButton_OnEnter
		frame:SetScript('OnEnter', BagSlotButton_OnEnter)
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
