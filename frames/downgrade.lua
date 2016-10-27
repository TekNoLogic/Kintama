
local myname, ns = ...


local function SetValue(self, bag, slot)
	if ns.IsDowngrade(bag, slot) then
		self:Show()
	else
		self:Hide()
	end
end


function ns.CreateDowngradeIcon(parent)
	local downgrade = parent:CreateTexture(nil, "OVERLAY")
	downgrade:SetAtlas("bags-greenarrow", true)
	downgrade:SetTexCoord(0, 1, 1, 0)
	downgrade:SetDesaturated(true)

	downgrade:Hide()

	downgrade.SetValue = SetValue

	return downgrade
end
