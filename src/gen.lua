local base = require("src.base")

local gen = {}

function gen.big_room()
	local terrain = {}
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local s
			if x == 1 or x == base.MAX_X or y == 1 or y == base.MAX_Y then
				s = base.symbols.wall
			else
				s = base.symbols.floor
			end
			terrain[base.getIdx(x, y)] = {symbol = s, x = x, y = y}
		end
	end

	local stair_x = math.random(2, base.MAX_X - 1)
	local stair_y = math.random(2, base.MAX_Y - 1)
	local stair_id = base.getIdx(stair_x, stair_y)
	terrain[stair_id] = {symbol = base.symbols.stair, x = stair_x, y = stair_y}

	local player_x = math.random(2, base.MAX_X - 1)
	local player_y = math.random(2, base.MAX_Y - 1)
	return terrain, player_x, player_y
end

local function boolean_walker(max_steps)
	local floors = {}
	local x = math.random(2, base.MAX_X - 1)
	local y = math.random(2, base.MAX_Y - 1)
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
		local id = base.getIdx(x, y)
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
			local s
			local id = base.getIdx(x, y)
			if x == start_x and y == start_y then
				s = base.symbols.stair
			elseif floors[id] then
				s = base.symbols.floor
			else
				s = base.symbols.wall
			end
			terrain[id] = {symbol = s, x = x, y = y}
		end
	end
	return terrain, end_x, end_y
end

return gen
