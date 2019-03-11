local base = require("src.base")
local level = require("src.level")

local mon = {}

function mon.act(denizen)
	local d = base.rn_direction()
	level.current:move(denizen, denizen.x + d.x, denizen.y + d.y)
end

return mon
