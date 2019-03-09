local base = require("base")

local gen = {}

function gen.big_room(lvl)
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
	lvl.terrain = terrain
	return player_x, player_y
end

local function boolean_walker(max_steps)
	local floors = {}
	local x = math.random(2, base.MAX_X - 1)
	local y = math.random(2, base.MAX_Y - 1)
	local start_x, start_y = x, y
	local possible_steps = {{dx=0,dy=1},{dx=0,dy=-1},{dx=1,dy=0},{dx=-1,dy=0}}
	local steps = 0
	while steps < max_steps do
		local direction = possible_steps[math.random(1,#possible_steps)]
		local new_x = x + direction.dx
		local new_y = y + direction.dy
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

function gen.cave(lvl)
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
	lvl.terrain = terrain
	return end_x, end_y
end

return gen
