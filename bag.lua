
local myname, ns = ...


ns.bags = {}


local function ColorSlots(self)
	for i,slot in pairs(self.slots) do slot:ColorBorder() end
end


function ns.MakeBagFrame(bag, parent)
	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetID(bag)

	frame.ColorSlots = ColorSlots

	frame.slots = {}

	ns.bags[bag] = frame

	return frame
end
