local serpent = require("serpent")

local savefile = arg[1]
local t = dofile(savefile)

for i,v in pairs(arg) do
	if i > 1 then
		local v_num = tonumber(v)
		if v_num then
			t = t[v_num]
		else
			t = t[v]
		end
	end
end

print(serpent.block(t))
