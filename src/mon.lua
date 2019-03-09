local base = require("src.base")
local level = require("src.level")

local mon = {}

function mon.act(denizen)
	local d = {1, 0, -1}
	local dx = d[math.random(#d)]
	local dy = d[math.random(#d)]
	level.current:move(denizen, denizen.x + dx, denizen.y + dy)
end

return mon
