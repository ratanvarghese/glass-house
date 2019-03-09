local base = require("src.base")
local level = require("src.level")

local player = {}

function player.handle_input(c)
	local dy, dx = 0, 0
	if c == "q" then
		return false
	elseif c == "w" then
		dy = -1
	elseif c == "s" then
		dy = 1
	elseif c == "a" then
		dx = -1
	elseif c == "d" then
		dx = 1
	end
	level.current:move_player(dx, dy)
	if level.current:denizen_on_terrain(level.current.player_id, base.symbols.stair) then
		level.current = level.make(level.current.num + 1)
	end
	return true
end

return player
