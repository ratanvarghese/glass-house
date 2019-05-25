local grid = require("src.grid")
local base = require("src.base")

local gen = {}

function gen.set_tile(terrain, name, x, y)
	local s = base.symbols[name]
	assert(s, "Invalid tile name: "..name)
	local i = grid.get_idx(x, y)
	terrain[i] = {symbol = s, x = x, y = y}
end

function gen.big_room()
	local terrain = {}
	grid.for_all_points(function(x, y, i)
		if grid.is_edge(x, y) then
			gen.set_tile(terrain, "wall", x, y)
		else
			gen.set_tile(terrain, "floor", x, y)
		end
	end)

	local stair_x, stair_y = grid.rn_xy()
	gen.set_tile(terrain, "stair", stair_x, stair_y)

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

function gen.cave()
	local max_steps = math.floor((grid.MAX_X * grid.MAX_Y * 2) / 4)
	local floors, start_x, start_y, end_x, end_y = boolean_walker(max_steps)
	local terrain = {}
	grid.for_all_points(function(x, y, i)
		if x == start_x and y == start_y then
			gen.set_tile(terrain, "stair", x, y) 
		elseif floors[i] then
			gen.set_tile(terrain, "floor", x, y) 
		else
			gen.set_tile(terrain, "wall", x, y) 
		end

	end)
	return terrain, end_x, end_y
end

return gen
