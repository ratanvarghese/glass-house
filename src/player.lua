local enum = require("src.enum")
local grid = require("src.grid")
local level = require("src.level")
local tool = require("src.tool")
local mon = require("src.mon")

local player = {}

function player.climb_stairs(lvl)
	if lvl:denizen_on_terrain(lvl.player_id, enum.terrain.stair) then
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

function player.handle_input(lvl, c, n)
	local p = lvl.denizens[lvl.player_id]
	assert(p, "ID error for player")

	local d
	if c == enum.cmd.equip then
		player.equip(lvl, p, n)
	elseif c == enum.cmd.quit then
		return false
	elseif c == enum.cmd.drop then
		mon.drop_tool(lvl.tool_piles, p, 1)
	elseif c == enum.cmd.north then
		d = grid.direction.north
	elseif c == enum.cmd.south then
		d = grid.direction.south
	elseif c == enum.cmd.west then
		d = grid.direction.west
	elseif c == enum.cmd.east then
		d = grid.direction.east
	end

	player.try_move(lvl, p, d)
	return true
end

return player
