
local myname, ns = ...


local gold
function ns.MakeCurrencyFrame(parent)
	gold = parent:CreateFontString(nil, nil, "NumberFontNormal")
	gold:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -10, 7)

	ns.UpdateGold()
end


function ns.UpdateGold()
	local money = GetMoney() - GetCursorMoney() - GetPlayerTradeMoney()
	gold:SetText(ns.GS(money))
end


function ns.PLAYER_MONEY()
	ns.UpdateGold()
	ns.UpdateBankBagslots()
end
