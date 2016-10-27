
local myname, ns = ...


ns.ilvls = setmetatable({}, {
	__index = function(t,link)
		local ilvl = GetDetailedItemLevelInfo(link)
		if ilvl then
			t[link] = ilvl
			return ilvl
		end
	end
})
