
local myname, ns = ...


function ns.MakeBagFrame(bag, parent)
	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetID(bag)

	frame.slots = {}

	return frame
end
