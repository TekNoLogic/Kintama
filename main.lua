
local myname, ns = ...


local TOP_BORDER = 8
local BOTTOM_BORDER = 24
local RIGHT_BORDER = 5
local LEFT_BORDER = 8


local frame = CreateFrame("Frame", 'KintamaFrame', UIParent)
frame:Hide()
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetSize(400, 236)
frame:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
frame:SetFrameStrata('MEDIUM')


frame:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
})
frame:SetBackdropColor(0,0,0, 0.65)


local function open() frame:Show() end
local function close() frame:Hide() end
local function toggle()
	if frame:IsVisible() then frame:Hide() else frame:Show() end
end


ToggleBag = toggle
ToggleBackpack = toggle
ToggleAllBags = toggle
OpenBag = open
CloseBag = close


table.insert(UISpecialFrames, frame:GetName())


local money = CreateFrame('Frame', frame:GetName()..'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
money:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)
SmallMoneyFrame_OnLoad(money, 'PLAYER')


BagItemSearchBox:Hide()
BagItemSearchBox.Show = BagItemSearchBox.Hide


function ns.OnLoad()
	for bag_id=0,4 do ns.MakeBagFrame(bag_id, frame) end
	ns.MakeBagFrame = nil
end


function ns.OnLogin()
	ns.RegisterEvent("BAG_UPDATE_DELAYED")
	ns.RegisterEvent("AUCTION_HOUSE_SHOW", open)
	ns.RegisterEvent("AUCTION_HOUSE_CLOSED", close)
	ns.RegisterEvent("BANKFRAME_OPENED", open)
	ns.RegisterEvent("BANKFRAME_CLOSED", close)
	ns.RegisterEvent("MAIL_SHOW", open)
	ns.RegisterEvent("MAIL_CLOSED", close)
	ns.RegisterEvent("MERCHANT_SHOW", open)
	ns.RegisterEvent("MERCHANT_CLOSED", close)
	ns.RegisterEvent("TRADE_SHOW", open)
	ns.RegisterEvent("TRADE_CLOSED", close)
	ns.RegisterEvent("GUILDBANKFRAME_OPENED", open)
	ns.RegisterEvent("GUILDBANKFRAME_CLOSED", close)
end


local bagids, bagstates = {}, {}
for bag=1,4 do bagids[bag] = GetInventorySlotInfo("Bag"..(bag-1).."Slot") end
function ns.BAG_UPDATE_DELAYED()
	for bag=1,4 do
		local link = GetInventoryItemLink("player", bagids[bag])
		if bagstates[bag] ~= link then
			ns.bags[bag]:Update()
			ns.bags[bag].bagslot:Update()
		end
		bagstates[bag] = link
	end
end


function ns.ResizeFrame()
	local widest_column = 0

	for bag=0,4 do
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
	end

	frame:SetWidth(widest_column + LEFT_BORDER + RIGHT_BORDER)
end
