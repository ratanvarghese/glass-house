local base = require("src.base")
local level = require("src.level")

local player = {}

function player.climb_stairs()
	if level.current:denizen_on_terrain(level.current.player_id, base.symbols.stair) then
		level.current = level.make(level.current.num + 1)
	end
end

function player.handle_input(c)
	local d
	if c == base.conf.keys.quit then
		return false
	elseif c == base.conf.keys.north then
		d = base.direction.north
	elseif c == base.conf.keys.south then
		d = base.direction.south
	elseif c == base.conf.keys.west then
		d = base.direction.west
	elseif c == base.conf.keys.east then
		d = base.direction.east
	end

	if d then
		level.current:move_player(d.x, d.y)
		player.climb_stairs()
	end
	return true
end

return player
