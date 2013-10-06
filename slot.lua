
local myname, ns = ...


function ns.MakeSlotFrame(bag, slot)
	local name = string.format('%sItem%d', bag:GetName(), slot)
	local frame = CreateFrame("Button", name, bag, "ContainerFrameItemButtonTemplate")
	frame:SetID(slot)

	frame:SetFrameLevel(bag:GetParent():GetFrameLevel()+10)
	frame:SetFrameStrata(bag:GetParent():GetFrameStrata())

	bag.slots[slot] = frame

	return frame
end
