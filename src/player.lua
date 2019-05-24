local base = require("src.base")
local level = require("src.level")
local tool = require("src.tool")
local mon = require("src.mon")

local player = {}

function player.climb_stairs(lvl)
	if lvl:denizen_on_terrain(lvl.player_id, base.symbols.stair) then
		level.current = level.make(lvl.num + 1)
	end
end

function player.handle_input(lvl, c)
	local p = lvl.denizens[lvl.player_id]
	assert(p, "ID error for player")

	local n = tonumber(c)
	local d
	if n then
		local target_tool = p.inventory[n]
		if target_tool then
			tool.equip(target_tool, p)
			lvl:reset_light()
		end
	elseif c == base.conf.keys.quit then
		return false
	elseif c == base.conf.keys.drop then
		mon.drop_tool(lvl.tool_piles, p, 1)
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
		local nx = p.x + d.x
		local ny = p.y + d.y
		if lvl:move(p, nx, ny) then
			mon.pickup_all_tools(lvl.tool_piles, p)
			player.climb_stairs(lvl)
		else
			lvl:bump_hit(p, nx, ny, 1)
		end
	end
	return true
end

return player
