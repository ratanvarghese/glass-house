local termfx = require("termfx")

local MAX_X, MAX_Y = 70, 20

local symbols = {
	floor = ".",
	wall = "#",
	player = "@",
	stair = ">",
	dark = " "
}

function getIdx(x, y)
	return (y*MAX_X) + x
end

function move(lvl, old_x, old_y, new_x, new_y)
	local new_id = getIdx(new_x, new_y)

	if lvl.terrain[new_id] and lvl.terrain[new_id].symbol == symbols.wall then
		return false
	elseif lvl.denizens[new_id] then
		return false
	end

	local old_id = getIdx(old_x, old_y)
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
			local max_x = math.min(denizen.x + denizen.light_radius, MAX_X)
			local min_y = math.max(denizen.y - denizen.light_radius, 1)
			local max_y = math.min(denizen.y + denizen.light_radius, MAX_Y)
			for x = min_x,max_x do
				for y = min_y,max_y do
					light[getIdx(x, y)] = true
				end
			end
		end
	end
	lvl.light = light
end

function make_big_room(lvl)
	local terrain = {}
	for y=1,MAX_Y do
		for x=1,MAX_X do
			local s
			if x == 1 or x == MAX_X or y == 1 or y == MAX_Y then
				s = symbols.wall
			else
				s = symbols.floor
			end
			if terrain[getIdx(x, y)] then
				s = "!"
			end
			terrain[getIdx(x, y)] = {symbol = s, x = x, y = y}
		end
	end
	lvl.terrain = terrain
end

function make_lvl()
	local res = {
		light = {},
		terrain = {},
		denizens = {}
	}

	local init_x, init_y = 10, 10
	res.player_id = getIdx(init_x, init_y)
	res.denizens[res.player_id] = {
		symbol = symbols.player,
		x = init_x,
		y = init_y,
		light_radius = 2
	}

	make_big_room(res)
	reset_light(res)
	return res
end

function print_lvl(lvl)
	for y=1,MAX_Y do
		for x=1,MAX_X do
			local i = getIdx(x, y)
			if lvl.light[i] then
				local denizen = lvl.denizens[i]
				if denizen then
					termfx.printat(denizen.x, denizen.y, denizen.symbol)
				else
					local tile = lvl.terrain[i]
					termfx.printat(tile.x, tile.y, tile.symbol)
				end
			else
				termfx.printat(x, y, symbols.dark)
			end
		end
	end
end

function move_player(lvl, dx, dy)
	local p = lvl.denizens[lvl.player_id]
	if move(lvl, p.x, p.y, p.x + dx, p.y + dy) then
		lvl.player_id = getIdx(p.x, p.y)
	end
end

local current_lvl = make_lvl()

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

if not ok then
	print(err)
end
