
local myname, ns = ...


local bagframe, bankframe
function ns.OnLoad()
	bagframe = ns.MakeContainerFrame("KintamaFrame", UIParent)
	bagframe:SetSize(400, 236)
	bagframe:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)

	bankframe = ns.MakeContainerFrame("KintamaBankFrame", bagframe)
	bankframe:SetSize(400, 342)
	bankframe:SetPoint("BOTTOMRIGHT", bagframe, "TOPRIGHT")

	ns.MakeBagFrame(BACKPACK_CONTAINER, bagframe)
	for bag_id=1,NUM_BAG_SLOTS do ns.MakeBagFrame(bag_id, bagframe) end

	ns.MakeBagFrame(BANK_CONTAINER, bankframe)
	for bag_id=(NUM_BAG_SLOTS+1),(NUM_BAG_SLOTS+NUM_BANKBAGSLOTS) do
		ns.MakeBagFrame(bag_id, bankframe)
	end

	local money = CreateFrame("Frame", "KintamaFrameMoneyFrame", bagframe, 'SmallMoneyFrameTemplate')
	money:SetPoint('BOTTOMRIGHT', bagframe, 'BOTTOMRIGHT', 5, 7)
	SmallMoneyFrame_OnLoad(money, 'PLAYER')

	BagItemSearchBox:Hide()
	BagItemSearchBox.Show = BagItemSearchBox.Hide

	ns.MakeContainerFrame = nil
	ns.MakeBagFrame = nil
	ns.MakeBagSlotFrame = nil
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

	-- noop the default bank so it doesn't show
	BankFrame:SetScript("OnEvent", function() end)
end


function ns.BANKFRAME_OPENED()
	bagframe:Show()
	bankframe:Show()
end


function ns.BANKFRAME_CLOSED()
	bagframe:Hide()
	bankframe:Hide()
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
