
local myname, ns = ...


assert(ns.scantip, "Tooltip scanner external not loaded")


local re = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
ns.ilvls = setmetatable({}, {
	__index = function(t,link)
		ns.scantip:SetHyperlink(link)
		for i=2,6 do
			local text = ns.scantip.L[i]
			local lvl = text and tonumber(text:match(re))
			if lvl then
				t[link] = lvl
				return lvl
			end
		end
	end
})
