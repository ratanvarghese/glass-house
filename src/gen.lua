local base = require("src.base")

local gen = {}

function gen.set_tile(terrain, name, x, y)
	local s = base.symbols[name]
	assert(s, "Invalid tile name: "..name)
	local i = base.get_idx(x, y)
	terrain[i] = {symbol = s, x = x, y = y}
end

function gen.big_room()
	local terrain = {}
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			if x == 1 or x == base.MAX_X or y == 1 or y == base.MAX_Y then
				gen.set_tile(terrain, "wall", x, y)
			else
				gen.set_tile(terrain, "floor", x, y)
			end
		end
	end

	local stair_x, stair_y = base.rn_xy()
	gen.set_tile(terrain, "stair", stair_x, stair_y)

	local player_x, player_y = base.rn_xy()
	while player_x == stair_x and player_y == stair_y do
		player_x, player_y = base.rn_xy()
	end
	return terrain, player_x, player_y
end

local function boolean_walker(max_steps)
	local floors = {}
	local x, y = base.rn_xy()
	local start_x, start_y = x, y
	local steps = 0
	while steps < max_steps do
		local d = base.rn_direction()
		local new_x = x + d.x
		local new_y = y + d.y
		if new_x < 2 or new_x > (base.MAX_X - 1) then new_x = x end
		if new_y < 2 or new_y > (base.MAX_Y - 1) then new_y = y end
		x = new_x
		y = new_y
		local id = base.get_idx(x, y)
		if not floors[id] then
			floors[id] = true
			steps = steps + 1
		end
	end
	local end_x, end_y = x, y
	return floors, start_x, start_y, end_x, end_y
end

function gen.cave()
	local max_steps = math.floor((base.MAX_X * base.MAX_Y * 2) / 4)
	local floors, start_x, start_y, end_x, end_y = boolean_walker(max_steps)
	local terrain = {}

	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			if x == start_x and y == start_y then
				gen.set_tile(terrain, "stair", x, y) 
			elseif floors[base.get_idx(x, y)] then
				gen.set_tile(terrain, "floor", x, y) 
			else
				gen.set_tile(terrain, "wall", x, y) 
			end
		end
	end
	return terrain, end_x, end_y
end

return gen
