
local myname, ns = ...


local gold
local currencies = {}
function ns.MakeCurrencyFrame(parent)
	gold = parent:CreateFontString(nil, nil, "NumberFontNormal")
	gold:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -10, 7)

	local anchor = gold
	for i=1,MAX_WATCHED_TOKENS do
		local f = parent:CreateFontString(nil, nil, "NumberFontNormal")
		f:SetPoint("RIGHT", anchor, "LEFT", -30, 0)
		f:SetText("123")

		currencies[i] = f
		anchor = f
	end

	ns.UpdateGold()
end


function ns.UpdateGold()
	local money = GetMoney() - GetCursorMoney() - GetPlayerTradeMoney()
	gold:SetText(ns.GS(money).. "|cffffd700g")
end


function ns.UpdateCurrency()
	for i=1,MAX_WATCHED_TOKENS do
		local frame = currencies[i]
		local name, count, icon, currency_id = GetBackpackCurrencyInfo(i)
		if name then
			local _, _, _, _, _, max = GetCurrencyInfo(currency_id)
			if max > 0 then count = count.."/"..max end
			frame:SetText(count.. "|T".. icon.. ":12:12:0:0:64:64:4:60:4:60|t")
			frame:Show()
		else
			frame:Hide()
		end
	end
end
hooksecurefunc("BackpackTokenFrame_Update", ns.UpdateCurrency)


function ns.PLAYER_MONEY()
	ns.UpdateGold()
	ns.UpdateBankBagslots()
end
