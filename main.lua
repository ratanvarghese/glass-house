local termfx = require("termfx")

local MAX_X, MAX_Y = 70, 20

function getIdx(x, y)
	return (y*MAX_X) + x
end

local symbols = {
	floor = ".",
	wall = "#",
	player = "@",
	stair = ">",
	dark = " "
}

local denizens = {}
local terrain = {}
local light = {}

function move(old_x, old_y, new_x, new_y)
	local new_id = getIdx(new_x, new_y)

	if terrain[new_id] and terrain[new_id].symbol == symbols.wall then
		return false
	elseif denizens[new_id] then
		return false
	end

	local old_id = getIdx(old_x, old_y)
	local d = denizens[old_id]
	d.x = new_x
	d.y = new_y
	denizens[new_id] = d
	denizens[old_id] = nil
	return true
end

function reset_light()
	light = {}
	for _,denizen in pairs(denizens) do
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
end

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

local init_x, init_y = 10, 10
local player_id = getIdx(init_x, init_y)
denizens[player_id] = {
	symbol = symbols.player,
	x = init_x,
	y = init_y,
	light_radius = 2
}

termfx.init()

local keepGoing = true
local ok, err = pcall(function()

while keepGoing do
	termfx.clear()
	reset_light()

	for y=1,MAX_Y do
		for x=1,MAX_X do
			local i = getIdx(x, y)
			if light[i] then
				local denizen = denizens[i]
				if denizen then
					termfx.printat(denizen.x, denizen.y, denizen.symbol)
				else
					local tile = terrain[i]
					termfx.printat(tile.x, tile.y, tile.symbol)
				end
			else
				termfx.printat(x, y, symbols.dark)
			end
		end
	end

	termfx.present()

	local evt = termfx.pollevent()
	local dy, dx = 0, 0
	if evt.char == "q" then
		keepGoing = false
	elseif evt.char == "w" then
		dy = -1
	elseif evt.char == "s" then
		dy = 1
	elseif evt.char == "a" then
		dx = -1
	elseif evt.char == "d" then
		dx = 1
	end

	local p = denizens[player_id]
	if move(p.x, p.y, p.x + dx, p.y + dy) then
		player_id = getIdx(p.x, p.y)
	end
end

end)

termfx.shutdown()

if not ok then
	print(err)
end
