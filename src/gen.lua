local grid = require("src.grid")
local enum = require("src.enum")

local gen = {}

function gen.big_room()
	local stair_x, stair_y = grid.rn_xy()
	local terrain = grid.make_full(function(x, y)
		local s = enum.terrain.floor
		if x == stair_x and y == stair_y then
			s = enum.terrain.stair
		elseif grid.is_edge(x, y) then
			s = enum.terrain.tough_wall
		end
		return {kind = s}
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
		local s = enum.terrain.wall
		if x == start_x and y == start_y then
			s = enum.terrain.stair
		elseif grid.is_edge(x, y) then
			s = enum.terrain.tough_wall
		elseif floors[i] then
			s = enum.terrain.floor
		end
		return {kind = s}
	end)
	return terrain, end_x, end_y
end

return gen
