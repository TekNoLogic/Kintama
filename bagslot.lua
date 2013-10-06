
local myname, ns = ...


function ns.MakeBagSlotFrame(bag, parent)
	local frame = CreateFrame('CheckButton', parent:GetName()..'Slot', parent:GetParent(), 'BagSlotButtonTemplate')
	frame:SetSize(37, 37)
	frame:SetPoint('LEFT', parent)
	frame.id = GetInventorySlotInfo("Bag"..(bag-1).."Slot")
	frame:SetID(frame.id)
end

