
local myname, ns = ...

ns.NUM_REAGENT_SLOTS = 14


local bagframe, bankframe, reagentframe
function ns.OnLoad()
	bagframe = ns.MakeContainerFrame("KintamaFrame", UIParent)
	bagframe:SetSize(400, 236)
	bagframe:SetPoint("BOTTOMRIGHT", UIParent, -85, 175)

	bankframe = ns.MakeContainerFrame("KintamaBankFrame", bagframe)
	bankframe:SetSize(400, 342)
	bankframe:SetPoint("BOTTOMRIGHT", bagframe, "TOPRIGHT")

	ns.MakeBagFrame(BACKPACK_CONTAINER, bagframe)
	for bag_id=1,NUM_BAG_SLOTS do ns.MakeBagFrame(bag_id, bagframe) end

	ns.MakeBagFrame(BANK_CONTAINER, bankframe)
	for bag_id=(NUM_BAG_SLOTS+1),(NUM_BAG_SLOTS+NUM_BANKBAGSLOTS) do
		ns.MakeBagFrame(bag_id, bankframe)
	end

	reagentframe = ns.MakeContainerFrame("KintamaReagentBankFrame", bankframe)
	reagentframe:SetSize(400, 300)
	reagentframe:SetPoint("BOTTOMRIGHT", bankframe, "TOPRIGHT")

	reagentframe.isReagentBank = true

	ns.MakeBagFrame(REAGENTBANK_CONTAINER, reagentframe, true)
	for column_id=2,(98/ns.NUM_REAGENT_SLOTS) do
		ns.MakeBagFrame(column_id, reagentframe, true)
	end

	BagItemAutoSortButton:Hide()
	BagItemAutoSortButton.Show = BagItemAutoSortButton.Hide

	ns.MakeCurrencyFrame(bagframe)

	BagItemSearchBox:Hide()
	BagItemSearchBox.Show = BagItemSearchBox.Hide

	ns.MakeContainerFrame = nil
	ns.MakeBagFrame = nil
	ns.MakeBagSlotFrame = nil
	ns.MakeCurrencyFrame = nil
end


function ns.OnLogin()
	local function open() bagframe:Show() end
	local function close() bagframe:Hide() end
	local function toggle()
		if bagframe:IsVisible() then bagframe:Hide() else bagframe:Show() end
	end

	ToggleBag = toggle
	ToggleBackpack = toggle
	ToggleAllBags = toggle
	OpenBag = open
	CloseBag = close

	ns.RegisterEvent("BAG_UPDATE_DELAYED")
	ns.RegisterEvent("BANKFRAME_OPENED")
	ns.RegisterEvent("BANKFRAME_CLOSED")

	ns.RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED", ns.UpdateBankBagslots)
	ns.RegisterEvent("REAGENTBANK_PURCHASED")
	ns.RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED", ns.UpdateReagentBankBagslots)

	ns.RegisterEvent("PLAYER_MONEY")
	ns.RegisterEvent("PLAYER_TRADE_MONEY", ns.UpdateGold)
	ns.RegisterEvent("SEND_MAIL_MONEY_CHANGED", ns.UpdateGold)
	ns.RegisterEvent("SEND_MAIL_COD_CHANGED", ns.UpdateGold)

	ns.RegisterEvent("AUCTION_HOUSE_SHOW", open)
	ns.RegisterEvent("AUCTION_HOUSE_CLOSED", close)
	ns.RegisterEvent("MAIL_SHOW", open)
	ns.RegisterEvent("MAIL_CLOSED", close)
	ns.RegisterEvent("MERCHANT_SHOW", open)
	ns.RegisterEvent("MERCHANT_CLOSED", close)
	ns.RegisterEvent("TRADE_SHOW", open)
	ns.RegisterEvent("TRADE_CLOSED", close)
	ns.RegisterEvent("GUILDBANKFRAME_OPENED", open)
	ns.RegisterEvent("GUILDBANKFRAME_CLOSED", close)

	bagframe:Hide()
	bankframe:Hide()

	bankframe:SetScript("OnHide", CloseBankFrame)

	-- noop the default bank so it doesn't show
	BankFrame:SetScript("OnEvent", function() end)

	-- Special considerations to make the reagent bank work
	reagentframe:SetScript("OnShow", function(self)
		if IsReagentBankUnlocked() then
			ReagentBankFrameUnlockInfo:Hide()
			self.sortButton:Show()
			self.depositButton:Show()
		else
			self.sortButton:Hide()
			self.depositButton:Hide()
		end
		self:ResizeFrame()

		bagframe:SetPoint("BOTTOMRIGHT", UIParent, -50, 0)
	end)
	reagentframe:SetScript("OnHide", function(self)
		bagframe:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
	end)
end


function ns.BANKFRAME_OPENED()
	bagframe:Show()
	bankframe:Show()
	reagentframe:Show()
	ns.BAG_UPDATE_DELAYED()
	ns.UpdateBankBagslots()
end


function ns.BANKFRAME_CLOSED()
	bagframe:Hide()
	bankframe:Hide()
	reagentframe:Hide()
end


local bagstates = {}
function ns.BAG_UPDATE_DELAYED(...)
	for bag,bagslot in pairs(ns.bagslots) do
		local link = GetInventoryItemLink("player", bagslot.id)
		if bagstates[bag] ~= link then
			ns.bags[bag]:Update()
			ns.bags[bag].bagslot:Update()
		end
		bagstates[bag] = link
	end
end


function ns.UpdateBankBagslots()
	local numowned = GetNumBankSlots()
	BankFrame.nextSlotCost = GetBankSlotCost(numSlots)

	for bag,frame in pairs(bankframe.bags) do
		if bag ~= BANK_CONTAINER then
			if (bag-NUM_BAG_SLOTS) <= numowned then
				SetItemButtonTextureVertexColor(frame.bagslot, 1,1,1)
				frame.bagslot.tooltipText = BANK_BAG
				frame.bagslot.owned = true
			else
				SetItemButtonTextureVertexColor(frame.bagslot, 1,0.1,0.1)
				frame.bagslot.tooltipText = BANK_BAG_PURCHASE
				frame.bagslot.owned = false
			end
		end
	end
end

function ns.REAGENTBANK_PURCHASED()
	ReagentBankFrameUnlockInfo:Hide()
	ns.UpdateReagentBankBagslots()
	reagentframe:ResizeFrame()
	reagentframe.sortButton:Show()
	reagentframe.depositButton:Show()
end


function ns.UpdateReagentBankBagslots()
	for _,bag in pairs(reagentframe.bags) do
		bag:Update()
	end
end
