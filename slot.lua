
local myname, ns = ...


function ns.MakeSlotFrame(bag, slot)
	local name = string.format('%sItem%d', bag:GetName(), slot)
	local frame = CreateFrame("Button", name, bag, "ContainerFrameItemButtonTemplate")
	frame:SetID(slot)

	bag.slots[slot] = frame

	return frame
end
