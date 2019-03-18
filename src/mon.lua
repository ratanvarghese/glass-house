local base = require("src.base")
local level = require("src.level")

local mon = {}

function mon.act(denizen)
	--mon.wander(denizen)
	mon.follow_player(denizen)
end

function mon.wander(denizen)
	local d = base.rn_direction()
	level.current:move(denizen, denizen.x + d.x, denizen.y + d.y)
end

function mon.follow_player(denizen)
	local _, x, y = base.adjacent_min(level.current.paths.to_player, denizen.x, denizen.y)
	level.current:move(denizen, x, y)
end

return mon
