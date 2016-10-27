
local myname, ns = ...


local plain = {r = .05, g = .05, b = .05}
local function ColorBorder(self)
	local bag_frame = self:GetParent()
	local color = plain

	local link = GetContainerItemLink(bag_frame.id, self.id)
	if link then
		local _, _, rarity = GetItemInfo(link)
		if rarity ~= 1 then
			color = ns.item_colors[rarity] or plain
		end
	end

	local target = self.border
	target:SetVertexColor(color.r, color.g, color.b)
end


local function HighlightBoE(self)
	local bag_frame = self:GetParent()
	if ns.IsBindOnEquip(bag_frame.id, self.id) then
		self.JunkIcon:Show()
	end
end


local function HighlightUpgrade(self)
	local bag_frame = self:GetParent()
	local upgrade = ns.IsUpgrade(bag_frame.id, self.id)
	self.UpgradeIcon:SetShown(upgrade)
end


local children = {}
function Update(self)
	ColorBorder(self)
	HighlightBoE(self)
	for frame in pairs (children[self]) do frame:Update() end
end


function ns.MakeSlotFrame(bag, slot)
	local kids = {}
	local slotid = slot
	local template = "ContainerFrameItemButtonTemplate"
	if bag.id == BANK_CONTAINER then
		template = "BankItemButtonGenericTemplate"
	elseif bag.isReagentBank then
		slotid = (bag.reagentBankColumn - 1) * ns.NUM_REAGENT_SLOTS + slot
		template = "ReagentBankItemButtonGenericTemplate"
	end

	local name = string.format('%sItem%d', bag:GetName(), slotid)
	local frame = CreateFrame("Button", name, bag, template)
	frame.id = slotid
	frame:SetID(slotid)

	frame:ClearAllPoints()
	if slot == 1 then
		frame:SetPoint('LEFT', bag, 42, 0)
	else
		frame:SetPoint('LEFT', bag.slots[slot-1], 'RIGHT', 2, 0)
	end

	local border = frame:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	border:SetBlendMode("ADD")
	border:SetAlpha(.5)

	border:SetPoint('CENTER', frame, 'CENTER', 0, 1)
	border:SetWidth(frame:GetWidth() * 2 - 5)
	border:SetHeight(frame:GetHeight() * 2 - 5)

	frame.border = border
	frame.ColorBorder = ColorBorder
	frame.HighlightBoE = HighlightBoE


	local upgrade = ns.CreateUpgradeIcon(frame, bag.id, slot)
	upgrade:SetPoint("TOPLEFT")
	kids[upgrade] = true


	local downgrade = ns.CreateDowngradeIcon(frame, bag.id, slot)
	downgrade:SetPoint("TOPLEFT")
	kids[downgrade] = true


	frame.Update = Update
	children[frame] = kids

	return frame
end
