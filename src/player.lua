local base = require("src.base")
local grid = require("src.grid")
local level = require("src.level")
local tool = require("src.tool")
local mon = require("src.mon")

local player = {}

function player.climb_stairs(lvl)
	if lvl:denizen_on_terrain(lvl.player_id, base.symbols.stair) then
		level.current = level.make(lvl.num + 1)
	end
end

function player.try_move(lvl, p, d)
	if not d then
		return
	end
	local nx = p.x + d.x
	local ny = p.y + d.y
	if lvl:move(p, nx, ny) then
		mon.pickup_all_tools(lvl.tool_piles, p)
		player.climb_stairs(lvl)
	else
		lvl:bump_hit(p, nx, ny, 1)
	end
end

function player.equip(lvl, p, tool_idx)
	local target_tool = p.inventory[tool_idx]
	if target_tool then
		tool.equip(target_tool, p)
		lvl:reset_light()
	end
end

function player.handle_input(lvl, c)
	local p = lvl.denizens[lvl.player_id]
	assert(p, "ID error for player")

	local n = tonumber(c)
	local d
	if n then
		player.equip(lvl, p, n)
	elseif c == base.conf.keys.quit then
		return false
	elseif c == base.conf.keys.drop then
		mon.drop_tool(lvl.tool_piles, p, 1)
	elseif c == base.conf.keys.north then
		d = grid.direction.north
	elseif c == base.conf.keys.south then
		d = grid.direction.south
	elseif c == base.conf.keys.west then
		d = grid.direction.west
	elseif c == base.conf.keys.east then
		d = grid.direction.east
	end

	player.try_move(lvl, p, d)
	return true
end

return player
