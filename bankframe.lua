
local myname, ns = ...


local TOP_BORDER = 8
local BOTTOM_BORDER = 24
local RIGHT_BORDER = 5
local LEFT_BORDER = 8


local frame = CreateFrame("Frame", 'KintamaBankFrame', ns.bagframe)
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetSize(400, 342)
frame:SetPoint("BOTTOMRIGHT", ns.bagframe, "TOPRIGHT")
frame:SetFrameStrata('MEDIUM')
ns.bankframe = frame


frame:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
})
frame:SetBackdropColor(0,0,0, 0.65)


function frame.ResizeFrame()
	local widest_column = 0

	widest_column = math.max(widest_column, ns.bags[BANK_CONTAINER]:GetWidth())
	for bag=5,11 do
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
	end

	frame:SetWidth(widest_column + LEFT_BORDER + RIGHT_BORDER)
end
