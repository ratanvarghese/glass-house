local grid = require("src.grid")
local base = require("src.base")

local gen = {}

function gen.big_room()
	local stair_x, stair_y = grid.rn_xy()
	local terrain = grid.make_full(function(x, y)
		local s = base.symbols.floor
		if x == stair_x and y == stair_y then
			s = base.symbols.stair
		elseif grid.is_edge(x, y) then
			s = base.symbols.wall
		end
		return {symbol = s, x = x, y = y}
	end)
	local player_x, player_y = grid.rn_xy()
	while player_x == stair_x and player_y == stair_y do
		player_x, player_y = grid.rn_xy()
	end
	return terrain, player_x, player_y
end

local function boolean_walker(max_steps)
	local floors = {}
	local x, y = grid.rn_xy()
	local start_x, start_y = x, y
	local steps = 0
	while steps < max_steps do
		local d = grid.rn_direction()
		local new_x = x + d.x
		local new_y = y + d.y
		if grid.is_edge(new_x, new_y) then
			new_x = x
			new_y = y
		end
		x = new_x
		y = new_y
		local id = grid.get_idx(x, y)
		if not floors[id] then
			floors[id] = true
			steps = steps + 1
		end
	end
	local end_x, end_y = x, y
	return floors, start_x, start_y, end_x, end_y
end

gen.CAVE_STEPS = math.floor((grid.MAX_X * grid.MAX_Y * 2) / 4)
function gen.cave()
	local floors, start_x, start_y, end_x, end_y = boolean_walker(gen.CAVE_STEPS)
	local terrain = grid.make_full(function(x, y, i)
		local s = base.symbols.wall
		if x == start_x and y == start_y then
			s = base.symbols.stair
		elseif floors[i] then
			s = base.symbols.floor
		end
		return {symbol = s, x = x, y = y}
	end)
	return terrain, end_x, end_y
end

return gen
