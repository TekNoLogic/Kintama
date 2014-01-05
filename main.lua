
local myname, ns = ...


function ns.OnLoad()
	ns.MakeBagFrame(BACKPACK_CONTAINER, ns.bagframe)
	for bag_id=1,NUM_BAG_SLOTS do ns.MakeBagFrame(bag_id, ns.bagframe) end

	ns.MakeBagFrame(BANK_CONTAINER, ns.bankframe)
	for bag_id=(NUM_BAG_SLOTS+1),(NUM_BAG_SLOTS+NUM_BANKBAGSLOTS) do
		ns.MakeBagFrame(bag_id, ns.bankframe)
	end

	ns.MakeBagFrame = nil
	ns.MakeBagSlotFrame = nil
end


function ns.OnLogin()
	ns.bagframe:Hide()
	ns.bankframe:Hide()

	ns.RegisterEvent("BAG_UPDATE_DELAYED")
	ns.RegisterEvent("BANKFRAME_OPENED")
	ns.RegisterEvent("BANKFRAME_CLOSED")

	ns.RegisterEvent("AUCTION_HOUSE_SHOW", ns.open)
	ns.RegisterEvent("AUCTION_HOUSE_CLOSED", ns.close)
	ns.RegisterEvent("MAIL_SHOW", ns.open)
	ns.RegisterEvent("MAIL_CLOSED", ns.close)
	ns.RegisterEvent("MERCHANT_SHOW", ns.open)
	ns.RegisterEvent("MERCHANT_CLOSED", ns.close)
	ns.RegisterEvent("TRADE_SHOW", ns.open)
	ns.RegisterEvent("TRADE_CLOSED", ns.close)
	ns.RegisterEvent("GUILDBANKFRAME_OPENED", ns.open)
	ns.RegisterEvent("GUILDBANKFRAME_CLOSED", ns.close)

	-- noop the default bank so it doesn't show
	BankFrame:SetScript("OnEvent", function() end)
end


function ns.BANKFRAME_OPENED()
	ns.bagframe:Show()
	ns.bankframe:Show()
end


function ns.BANKFRAME_CLOSED()
	ns.bagframe:Hide()
	ns.bankframe:Hide()
end


function ns.open() ns.bagframe:Show() end
function ns.close() ns.bagframe:Hide() end
function ns.toggle()
	if ns.bagframe:IsVisible() then ns.bagframe:Hide() else ns.bagframe:Show() end
end


ToggleBag = ns.toggle
ToggleBackpack = ns.toggle
ToggleAllBags = ns.toggle
OpenBag = ns.open
CloseBag = ns.close


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
