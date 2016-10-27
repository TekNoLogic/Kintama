
local myname, ns = ...


local bags, slots = {}, {}
local function Update(self)
	self:SetShown(ns.IsDowngrade(bags[self], slots[self]))
end


function ns.CreateDowngradeIcon(parent, bag, slot)
	local downgrade = parent:CreateTexture(nil, "OVERLAY")
	downgrade:SetAtlas("bags-greenarrow", true)
	downgrade:SetTexCoord(0, 1, 1, 0)
	downgrade:SetDesaturated(true)
	downgrade:Hide()

	downgrade.Update = Update

	bags[downgrade] = bag
	slots[downgrade] = slot

	return downgrade
end
