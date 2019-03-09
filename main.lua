local termfx = require("termfx")
local serpent = require("serpent")

local base = require("base")

math.randomseed(os.time())


function move(lvl, old_x, old_y, new_x, new_y)
	local new_id = base.getIdx(new_x, new_y)
	local target = lvl.terrain[new_id]
	if target.symbol == base.symbols.wall then
		return false
	elseif lvl.denizens[new_id] then
		return false
	end

	if target.symbol == base.symbols.stair then
		current_lvl = make_lvl(lvl.lvl_num + 1)
		return true
	end

	local old_id = base.getIdx(old_x, old_y)
	local d = lvl.denizens[old_id]
	d.x = new_x
	d.y = new_y
	lvl.denizens[new_id] = d
	lvl.denizens[old_id] = nil
	reset_light(lvl)
	return true
end

function reset_light(lvl)
	local light = {}
	for _,denizen in pairs(lvl.denizens) do
		if denizen.light_radius then
			local min_x = math.max(denizen.x - denizen.light_radius, 1)
			local max_x = math.min(denizen.x + denizen.light_radius, base.MAX_X)
			local min_y = math.max(denizen.y - denizen.light_radius, 1)
			local max_y = math.min(denizen.y + denizen.light_radius, base.MAX_Y)
			for x = min_x,max_x do
				for y = min_y,max_y do
					light[base.getIdx(x, y)] = true
				end
			end
		end
	end
	lvl.light = light
end

function make_big_room(lvl)
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
	terrain[base.getIdx(stair_x, stair_y)] = {symbol = base.symbols.stair, x = stair_x, y = stair_y}

	local player_x = math.random(2, base.MAX_X - 1)
	local player_y = math.random(2, base.MAX_Y - 1)
	lvl.terrain = terrain
	return player_x, player_y
end

function boolean_walker(max_steps)
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

function make_cave(lvl)
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

function make_lvl(lvl_num)
	local res = {
		light = {},
		terrain = {},
		denizens = {},
		memory = {},
		lvl_num = lvl_num
	}

	--local init_x, init_y = make_big_room(res)
	local init_x, init_y = make_cave(res)
	res.player_id = base.getIdx(init_x, init_y)
	res.denizens[res.player_id] = {
		symbol = base.symbols.player,
		x = init_x,
		y = init_y,
		light_radius = 2
	}

	reset_light(res)
	return res
end

function print_lvl(lvl)
	for y=1,base.MAX_Y do
		for x=1,base.MAX_X do
			local i = base.getIdx(x, y)
			if lvl.light[i] then
				local denizen = lvl.denizens[i]
				if denizen then
					termfx.printat(denizen.x, denizen.y, denizen.symbol)
				else
					local tile = lvl.terrain[i]
					termfx.printat(tile.x, tile.y, tile.symbol)
					if tile.symbol ~= base.symbols.floor then
						lvl.memory[i] = true
					end
				end
			elseif lvl.memory[i] then
				local tile = lvl.terrain[i]
				termfx.printat(tile.x, tile.y, tile.symbol)
			else
				termfx.printat(x, y, base.symbols.dark)
			end
		end
	end
end

function move_player(lvl, dx, dy)
	local p = lvl.denizens[lvl.player_id]
	if move(lvl, p.x, p.y, p.x + dx, p.y + dy) then
		lvl.player_id = base.getIdx(p.x, p.y)
	end
end

function starting_level(filename)
	local f, ferr = io.open(filename, "r")
	if f then
		local s = f:read("*a")
		f:close()
		local dumpfunc = loadstring(s)
		if not dumpfunc then
			print("Bad savefile. Press 's' to start new game, 'q' to quit, then 'Enter'")
			local choice = io.read()
			if choice == "s" then
				return make_lvl(1)
			else
				os.exit()
			end
		end
		return dumpfunc()
	else
		return make_lvl(1)
	end
end

current_lvl = starting_level(base.savefile)

termfx.init()
	local ok, err = pcall(function()

	while true do
		termfx.clear()

		print_lvl(current_lvl)
		termfx.present()

		local evt = termfx.pollevent()
		local dy, dx = 0, 0
		if evt.char == "q" then
			break
		elseif evt.char == "w" then
			dy = -1
		elseif evt.char == "s" then
			dy = 1
		elseif evt.char == "a" then
			dx = -1
		elseif evt.char == "d" then
			dx = 1
		end
		move_player(current_lvl, dx, dy)
	end

end)

termfx.shutdown()

if ok then
	local end_f, end_ferr = io.open(base.savefile, "w")
	if not end_f then error(end_ferr) end
	end_f:write(serpent.dump(current_lvl))
end

if not ok then
	print(err)
end
