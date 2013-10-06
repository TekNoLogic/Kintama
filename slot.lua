
local myname, ns = ...


function ns.MakeSlotFrame(bag_frame, slot)
	local name = string.format('%sItem%d', bag_frame:GetName(), slot)
	local frame = CreateFrame("Button", name, bag_frame, "ContainerFrameItemButtonTemplate")
	frame:SetID(slot)

	frame:SetFrameLevel(bag_frame:GetParent():GetFrameLevel()+10)
	frame:SetFrameStrata(bag_frame:GetParent():GetFrameStrata())

	bag_frame.slot_frames[slot] = frame

	return frame
end
