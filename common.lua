
local myname, ns = ...


--[[************************************************************************************************
-- Frame related methods
**************************************************************************************************]]

-- Namespace
ns.frame = {}

-- exposed API
function ns.frame:MakeBagFrame(bag_id, parent)
	local bag_frame = CreateFrame("Frame", ('%sBag%d'):format(parent:GetName(), bag_id), parent)
	bag_frame:SetID(bag_id)

	bag_frame.slot_frames = {}

	return bag_frame
end

function ns.frame:MakeMoneyFrame(frame_name, parent, type)
	local money_frame = CreateFrame('Frame', parent:GetName()..frame_name, parent, 'SmallMoneyFrameTemplate')
	SmallMoneyFrame_OnLoad(money_frame, type)
	return money_frame
end

function ns.frame:NewMainFrame(name, delegate)
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

	delegate:OnFrameCreate(frame)

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
