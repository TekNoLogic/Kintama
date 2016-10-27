
local myname, ns = ...


local bags, slots = {}, {}
local function Update(self)
	self:SetShown(ns.IsUpgrade(bags[self], slots[self]))
end


function ns.CreateUpgradeIcon(parent, bag, slot)
	local upgrade = parent:CreateTexture(nil, "OVERLAY")
	upgrade:SetAtlas("bags-greenarrow", true)
	upgrade:Hide()

	upgrade.Update = Update

	bags[upgrade] = bag
	slots[upgrade] = slot

	return upgrade
end
