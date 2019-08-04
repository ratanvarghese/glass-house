local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")

local gen = {}

local function tough_or_floor(pos, v)
	if v then
		return {kind=enum.tile.tough_wall, pos = pos}
	else
		return {kind=enum.tile.floor, pos = pos}
	end
end

function gen.big_room()
	local terrain = {}
	for i,x,y in grid.points() do
		terrain[i] = tough_or_floor(i, grid.is_edge(x, y))
	end
	local x_list = base.extend_arr({}, base.rn_distinct(2, grid.MAX_X-1, 2))
	local y_list = base.extend_arr({}, base.rn_distinct(2, grid.MAX_Y-1, 2))
	terrain[grid.get_pos(x_list[1], y_list[1])].kind = enum.tile.stair
	return terrain, grid.get_pos(x_list[2], y_list[2])
end

local function boolean_walker(max_steps, start_i, clipn)
	local i = start_i
	local floors = {[i] = true}
	local steps = 0
	while steps < max_steps do
		i = grid.travel(i, 1, nil, clipn)
		if not floors[i] then
			floors[i] = true
			steps = steps + 1
		end
	end
	return floors, i
end

local function boolean_terrain(pos, x, y, v)
	if grid.is_edge(x, y) then
		return {kind=enum.tile.tough_wall, pos = pos}
	elseif v then
		return {kind=enum.tile.floor, pos = pos}
	else
		return {kind=enum.tile.wall, pos = pos}
	end
end

gen.CAVE_STEPS = math.floor((grid.MAX_X * grid.MAX_Y * 2) / 4)
function gen.cave()
	local clipn = 1
	local x = math.random(1+clipn, grid.MAX_X-clipn)
	local y = math.random(1+clipn, grid.MAX_Y-clipn)
	local start_i = grid.get_pos(x, y)
	local floors, end_i = boolean_walker(gen.CAVE_STEPS, start_i, clipn)
	local terrain = {}
	for i,x,y,v in grid.points(floors) do
		terrain[i] = boolean_terrain(i, x, y, v)
	end
	terrain[start_i].kind = enum.tile.stair
	return terrain, end_i
end

return gen
