local termfx = require("termfx")

local MAX_X, MAX_Y = 70, 20

function getIdx(x, y)
	return (y*MAX_X) + x
end

local symbols = {
	floor = ".",
	wall = "#",
	player = "@",
	stair = ">"
}

local denizens = {}
local terrain = {}

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
denizens[player_id] = {symbol = symbols.player, x = init_x, y = init_y}

termfx.init()

local keepGoing = true
local ok, err = pcall(function()

while keepGoing do
	termfx.clear()

	for _,tile in pairs(terrain) do
		termfx.printat(tile.x, tile.y, tile.symbol)
	end
	for _,denizen in pairs(denizens) do
		termfx.printat(denizen.x, denizen.y, denizen.symbol)
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
