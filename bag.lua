
local myname, ns = ...


ns.bags = {}


local function ColorSlots(self)
	for i,slot in pairs(self.slots) do slot:ColorBorder() end
end


local function Update(self)
	local num_slots = GetContainerNumSlots(self:GetID())
	self.size = num_slots

	self:SetWidth(num_slots * 39)

	local f = self.slots[num_slots] -- Touch to ensure slot frames exist

	for i,slot in pairs(self.slots) do
		if i <= num_slots then
			slot:Show()
		else
			slot:Hide()
		end
	end
end


function ns.MakeBagFrame(bag, parent)
	local name = string.format('%sBag%d', parent:GetName(), bag)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetID(bag)

	frame:SetHeight(39)
	if bag == 0 then
		frame:SetPoint('TOPLEFT', parent, 8, -8)
	else
		frame:SetPoint('TOPLEFT', ns.bags[bag-1], 'BOTTOMLEFT', 0, 2)
	end

	frame.Update = Update
	frame.ColorSlots = ColorSlots

	frame.slots = setmetatable({}, {
		__index = function(t,i)
			local f = ns.MakeSlotFrame(frame, i)
			t[i] = f
			return f
		end
	})

	ns.bags[bag] = frame

	return frame
end
