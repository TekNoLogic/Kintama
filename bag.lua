
local myname, ns = ...


ns.bags = {}


function ns.MakeBagFrame(bag, parent)
	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetID(bag)

	frame.slots = {}

	ns.bags[bag] = frame

	return frame
end
