local _, common = ...

local _G = getfenv(0)
local CreateFrame, LibStub, UIParent = _G.CreateFrame, _G.LibStub, _G.UIParent
local getglobal, pairs = _G.getglobal, _G.pairs

local L = LibStub("AceLocale-3.0"):GetLocale("OneBag4")


function common:DatabaseDefaults()
	return {
		profile = {
			colors = {
				mouseover = {r = 0, g = .7, b = 1, a = 1},
				profession = {r = 1, g = 0, b = 1, a = 1},
				background = {r = 0, g = 0, b = 0, a = .45},
			},
			show = {
				['*'] = true
			},
			appearance = {
				cols = 10,
				scale = 1,
				alpha = 1,
				glow = false,
				rarity = true,
				whites = false,
                grays = false,
			},
			behavior = {
				strata = 2,
				locked = false,
				clamped = true,
				bagbreak = false,
				valign = 1,
				bagorder = 1,
			},
			position = {
				parent = "UIParent",
				left = 600,
				top = 450,
			},
		},
	}
end

--[[************************************************************************************************
-- Frame related methods
**************************************************************************************************]]

-- Namespace
common.frame = {}

local frame_stratas = {
    "LOW",
    "MEDIUM",
    "HIGH",
    "DIALOG",
    "FULLSCREEN",
    "FULLSCREEN_DIALOG",
    "TOOLTIP",
}

-- Helpers
local function SetSize(frame, width, height)
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function SetPosition(frame, info)
	frame:ClearAllPoints()

	local parent = info.parent and getglobal(info.parent) or UIParent
	local left = info.left or 0
	local top = info.top or 0

	frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", left, top)
end

local function GetPosition(frame)
	return {
		top = frame:GetTop(),
		left = frame:GetLeft(),
		parent = frame:GetParent():GetName()				
	}
end

local function CustomizeFrame(frame, db)
	frame:SetScale(db.appearance.scale)
	frame:SetAlpha(db.appearance.alpha)

	local c = db.colors.background
	frame:SetBackdropColor(c.r, c.g, c.b, c.a)

	frame:SetClampedToScreen(db.behavior.clamped)

	local strata = frame_stratas[db.behavior.strata]
	frame:SetFrameStrata(strata)
end

local function CustomizeFontString(fontstring, color, size)
	fontstring.SetSize = SetSize

    fontstring:SetShadowOffset(.8, -.8)
    fontstring:SetShadowColor(0, 0, 0, .5)
    fontstring:SetTextColor(color.r, color.g, color.b)

    fontstring:SetJustifyH("LEFT")
    fontstring:SetFont("Fonts\\FRIZQT__.TTF", size)
end

local frameHelpers = {
    SetSize = SetSize,
    SetPosition = SetPosition,
    GetPosition = GetPosition,
    CustomizeFrame = CustomizeFrame,
}

-- exposed API
function common.frame:MakeBagFrame(bag_id, parent, delegate)
    local bag_frame = CreateFrame("Frame", ('%sBag%d'):format(parent:GetName(), bag_id), parent)
    bag_frame:SetID(bag_id)

    bag_frame.slot_frames = {}
    bag_frame.delegate = delegate

    return bag_frame
end

function common.frame:MakeSlotFrame(bag_frame, slot_id, delegate)
    local bag_id = bag_frame:GetID()

    local slot_template = "ContainerFrameItemButtonTemplate"
    if bag_id == -1 then
        slot_template = "BankItemButtonGenericTemplate"
    end

    local slot_frame = CreateFrame("Button", ('%sItem%d'):format(bag_frame:GetName(), slot_id), bag_frame, slot_template)
    slot_frame:SetID(slot_id)
    slot_frame:SetFrameLevel(bag_frame:GetParent():GetFrameLevel()+10)

    slot_frame.delegate = delegate
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
    local frame = common.frame:NewFrame(name, UIParent, delegate)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -14)
    frame.title = title

    local searchbox = CreateFrame("EditBox", name.."SearchBox", frame, "SearchBoxTemplate")
    searchbox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -14)
    searchbox:SetWidth(100)
    searchbox:SetHeight(20)
    searchbox:SetAutoFocus(false)

    searchbox:SetScript('OnHide', function(self)
        self.clearButton:Click()
    end)

    searchbox.clearFunc = function(searchbox)
        delegate:OnSearchBoxCleared(searchbox)
    end
    searchbox:SetScript('OnChar', BagSearch_OnChar)
    searchbox:SetScript('OnEnterPressed', EditBox_ClearFocus)
    searchbox:SetScript('OnTextChanged', function(...)
        delegate:OnSearchBoxTextChanged(...)
    end)

    frame.searchbox = searchbox

    title:SetFormattedText(delegate:MainFrameTitle(frame))

    table.insert(UISpecialFrames, frame:GetName())

    frame:SetScript("OnDragStart", function(...)
        delegate:OnDragStart(...)
    end)

    frame:SetScript("OnDragStop", function(...)
        delegate:OnDragStop(...)
    end)


    -- local bag_button = CreateFrame("CheckButton", nil, frame)
    -- bag_button:SetNormalTexture([[Interface/Buttons/Button-Backpack-Up]])

    -- bag_button:SetHeight(18)
    -- bag_button:SetWidth(18)
    -- bag_button:ClearAllPoints()

    -- bag_button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)

--    frame:CreateTexture(nil, )

    return frame
end

function common.frame:NewFrame(name, parent, delegate)
	local frame = CreateFrame("Frame", name, parent)

	frame.delegate = delegate

	for k, v in pairs(frameHelpers) do
		frame[k] = v
	end

	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
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

    return frame
end
