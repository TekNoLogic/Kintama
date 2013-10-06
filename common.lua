
local myname, ns = ...


--[[************************************************************************************************
-- Frame related methods
**************************************************************************************************]]

-- exposed API
function ns.NewMainFrame(name, delegate)
	local frame = CreateFrame("Frame", name, UIParent)

	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetSize(400, 200)

	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})

	frame:Hide()

	frame:SetScript("OnShow", function(...)
		delegate:OnShow(frame)
	end)

	frame:SetScript("OnHide", function(...)
		delegate:OnHide(frame)
	end)

	local money = CreateFrame('Frame', frame:GetName()..'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
	money:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)
	SmallMoneyFrame_OnLoad(money, 'PLAYER')

	table.insert(UISpecialFrames, frame:GetName())


	-- local bag_button = CreateFrame("CheckButton", nil, frame)
	-- bag_button:SetNormalTexture([[Interface/Buttons/Button-Backpack-Up]])

	-- bag_button:SetHeight(18)
	-- bag_button:SetWidth(18)
	-- bag_button:ClearAllPoints()

	-- bag_button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)

--    frame:CreateTexture(nil, )

	return frame
end
