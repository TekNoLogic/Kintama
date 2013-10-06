
local myname, ns = ...

local Kintama = LibStub('AceAddon-3.0'):NewAddon('Kintama', 'AceEvent-3.0', 'AceConsole-3.0', 'AceBucket-3.0')


function Kintama:OnInitialize()
	self.column_width = 39
	self.row_height = 39
	self.top_border = 8
	self.bottom_border = 24
	self.right_border = 5
	self.left_border = 8

	local frame = CreateFrame("Frame", 'KintamaFrame', UIParent)
	frame:Hide()
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetSize(400, 200)
	frame:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
	frame:SetHeight(5 * 39 + self.bottom_border + self.top_border)
	frame:SetFrameStrata('MEDIUM')

	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	frame:SetBackdropColor(0,0,0, 0.65)

	frame:SetScript("OnShow", function(...)
		self:OnShow(frame)
	end)

	frame:SetScript("OnHide", function(...)
		self:OnHide(frame)
	end)

	table.insert(UISpecialFrames, frame:GetName())

	self.frame = frame

	for bag_id=0,4 do
		ns.MakeBagFrame(bag_id, self.frame)
	end
	ns.MakeBagFrame = nil

	local money = CreateFrame('Frame', frame:GetName()..'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
	money:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, 7)
	SmallMoneyFrame_OnLoad(money, 'PLAYER')

	BagItemSearchBox:Hide()
	BagItemSearchBox.Show = BagItemSearchBox.Hide
end


function Kintama:OnEnable()
	local function open()
		Kintama.frame:Show()
	end

	local function close()
		Kintama.frame:Hide()
	end

	local function toggle()
		if Kintama.frame:IsVisible() then
			Kintama.frame:Hide()
		else
			Kintama.frame:Show()
		end
	end

	ToggleBag = toggle
	ToggleBackpack = toggle
	ToggleAllBags = toggle
	OpenBag = open
	CloseBag = close

	self:RegisterEvent("AUCTION_HOUSE_SHOW",  open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED",  close)
	self:RegisterEvent("BANKFRAME_OPENED",  open)
	self:RegisterEvent("BANKFRAME_CLOSED",  close)
	self:RegisterEvent("MAIL_SHOW",   open)
	self:RegisterEvent("MAIL_CLOSED",     close)
	self:RegisterEvent("MERCHANT_SHOW",   open)
	self:RegisterEvent("MERCHANT_CLOSED",   close)
	self:RegisterEvent("TRADE_SHOW",    open)
	self:RegisterEvent("TRADE_CLOSED",    close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
end


function Kintama:UpdateBags()
	local widest_column = 0

	for bag=0,4 do
		local f = ns.bags[bag]
		f:Update()
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
	end

	self.frame:SetWidth(widest_column + self.left_border + self.right_border)
end


function Kintama:OnShow(frame)
	self:UpdateBags()

	self.bag_update_bucket = self:RegisterBucketEvent('BAG_UPDATE', .1, 'UpdateBags')

	self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateBags')
	self:RegisterEvent('UPDATE_INVENTORY_ALERTS', 'UpdateBags')
end


function Kintama:OnHide(frame)
	self:UnregisterBucket(self.bag_update_bucket)

	self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
	self:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
end
