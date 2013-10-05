local _, common = ...

local L = LibStub("AceLocale-3.0"):NewLocale("Kintama", "enUS", true, true)
local L = LibStub("AceLocale-3.0"):GetLocale("Kintama")


--[[************************************************************************************************
-- Frame related methods
**************************************************************************************************]]

-- Namespace
common.frame = {}

-- Helpers
local function CustomizeFrame(frame)
	frame:SetBackdropColor(0,0,0, 0.65)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata('MEDIUM')
end

local function CustomizeFontString(fontstring, color, size)
	fontstring:SetShadowOffset(.8, -.8)
	fontstring:SetShadowColor(0, 0, 0, .5)
	fontstring:SetTextColor(color.r, color.g, color.b)

	fontstring:SetJustifyH("LEFT")
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size)
end

local frameHelpers = {
	CustomizeFrame = CustomizeFrame,
}

-- exposed API
function common.frame:MakeBagFrame(bag_id, parent)
	local bag_frame = CreateFrame("Frame", ('%sBag%d'):format(parent:GetName(), bag_id), parent)
	bag_frame:SetID(bag_id)

	bag_frame.slot_frames = {}

	return bag_frame
end

function common.frame:MakeSlotFrame(bag_frame, slot_id)
	local bag_id = bag_frame:GetID()

	local slot_template = "ContainerFrameItemButtonTemplate"
	if bag_id == -1 then
			slot_template = "BankItemButtonGenericTemplate"
	end

	local slot_frame = CreateFrame("Button", ('%sItem%d'):format(bag_frame:GetName(), slot_id), bag_frame, slot_template)
	slot_frame:SetID(slot_id)
	slot_frame:SetFrameLevel(bag_frame:GetParent():GetFrameLevel()+10)

	slot_frame:SetFrameStrata(bag_frame:GetParent():GetFrameStrata())

	bag_frame.slot_frames[slot_id] = slot_frame

	return slot_frame
end

function common.frame:MakeMoneyFrame(frame_name, parent, type)
	local money_frame = CreateFrame('Frame', parent:GetName()..frame_name, parent, 'SmallMoneyFrameTemplate')
	SmallMoneyFrame_OnLoad(money_frame, type)
	return money_frame
end

function common.frame:NewMainFrame(name, delegate)
	local frame = CreateFrame("Frame", name, UIParent)

	for k, v in pairs(frameHelpers) do
		frame[k] = v
	end

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
