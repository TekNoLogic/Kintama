
local myname, ns = ...


local TOP_BORDER = 8
local BOTTOM_BORDER = 24
local RIGHT_BORDER = 5
local LEFT_BORDER = 8
local BACKDROP = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
}


local function hidetextures(region, ...)
	if region and region:IsObjectType("Texture") then region:Hide() end
	if select("#", ...) > 0 then hidetextures(...) end
end


local function ResizeFrame(self)
	if self.isReagentBank and not IsReagentBankUnlocked() then
		self:SetSize(500, 150)

		ReagentBankFrameUnlockInfo:SetParent(self)
		ReagentBankFrameUnlockInfo:SetAllPoints()
		ReagentBankFrameUnlockInfo:Show()

		hidetextures(ReagentBankFrameUnlockInfo:GetRegions())

		MoneyFrame_Update(ReagentBankFrame.UnlockInfo.CostMoneyFrame, GetReagentBankCost())
	else
		if self.isReagentBank then self:SetHeight(300) end

		local widest_column = 0

		for bag,frame in pairs(self.bags) do
			widest_column = math.max(widest_column, frame:GetWidth())
		end

		self:SetWidth(widest_column + LEFT_BORDER + RIGHT_BORDER)
	end
end


function ns.MakeContainerFrame(name, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetFrameStrata('MEDIUM')

	frame:SetBackdrop(BACKDROP)
	frame:SetBackdropColor(0,0,0, 0.80)

	frame.ResizeFrame = ResizeFrame
	frame.bags = {}

	table.insert(UISpecialFrames, frame:GetName())

	return frame
end
