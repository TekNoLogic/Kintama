
local myname, ns = ...


local TOP_BORDER = 8
local BOTTOM_BORDER = 24
local RIGHT_BORDER = 5
local LEFT_BORDER = 8


local frame = CreateFrame("Frame", 'KintamaFrame', UIParent)
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetSize(400, 236)
frame:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
frame:SetFrameStrata('MEDIUM')
ns.bagframe = frame


frame:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
})
frame:SetBackdropColor(0,0,0, 0.65)


table.insert(UISpecialFrames, frame:GetName())


local money = CreateFrame('Frame', frame:GetName()..'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
money:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)
SmallMoneyFrame_OnLoad(money, 'PLAYER')


BagItemSearchBox:Hide()
BagItemSearchBox.Show = BagItemSearchBox.Hide


function frame.ResizeFrame()
	local widest_column = 0

	widest_column = math.max(widest_column, ns.bags[BACKPACK_CONTAINER]:GetWidth())
	for bag=1,NUM_BAG_SLOTS do
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
	end

	frame:SetWidth(widest_column + LEFT_BORDER + RIGHT_BORDER)
end
