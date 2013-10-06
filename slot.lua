
local myname, ns = ...


local colorCache = {}
local plain = {r = .05, g = .05, b = .05}
local function ColorBorder(self)
	local bag_frame = self:GetParent()
	local color = plain

	if not self.border then
		-- Thanks to oglow for this method
		local border = self:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		border:SetBlendMode("ADD")
		border:SetAlpha(.5)

		border:SetPoint('CENTER', self, 'CENTER', 0, 1)
		border:SetWidth(self:GetWidth() * 2 - 5)
		border:SetHeight(self:GetHeight() * 2 - 5)
		self.border = border
	end

	local link = GetContainerItemLink(bag_frame:GetID(), self:GetID())
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

	local target = self.border
	target:SetVertexColor(color.r, color.g, color.b)
end


function ns.MakeSlotFrame(bag, slot)
	local name = string.format('%sItem%d', bag:GetName(), slot)
	local frame = CreateFrame("Button", name, bag, "ContainerFrameItemButtonTemplate")
	frame:SetID(slot)

	frame:ClearAllPoints()
	if slot == 1 then
		frame:SetPoint('LEFT', bag)
	else
		frame:SetPoint('LEFT', bag.slots[slot-1], 'RIGHT', 2, 0)
	end

	frame.ColorBorder = ColorBorder

	return frame
end
