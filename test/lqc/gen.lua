local base = require("src.base")
local grid = require("src.grid")
local gen = require("src.gen")

property "gen.big_room: player x" {
	generators = {},
	check = function()
		local _, x, y = gen.big_room()
		return (x > 1) and (x < grid.MAX_X)
	end
}

property "gen.big_room: player y" {
	generators = {},
	check = function()
		local _, x, y = gen.big_room()
		return (y > 1) and (y < grid.MAX_Y)
	end
}

property "gen.big_room: player on floor" {
	generators = {},
	check = function()
		local t, x, y = gen.big_room()
		local i = grid.get_idx(x, y)
		local v = t[i]
		return (v.symbol == base.symbols.floor)
	end
}

property "gen.big_room: terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local t = gen.big_room()
		local i = grid.get_idx(x, y)
		local s = t[i].symbol
		local wall_x = (x == 1 or x == grid.MAX_X)
		local wall_y = (y == 1 or y == grid.MAX_Y)
		if s == base.symbols.stair or s == base.symbols.floor then
			return not (wall_x or wall_y)
		elseif s == base.symbols.wall then
			return wall_x or wall_y
		else
			return false
		end
	end
}

local function find_stairs(t, x, y, finished)
	local i = grid.get_idx(x, y)
	local tile = t[i]
	if finished[i] then
		return false
	else
		finished[i] = true
	end

	if tile then
		if tile.symbol == base.symbols.stair then
			return true
		elseif tile.symbol == base.symbols.floor then
			if find_stairs(t, x, y-1, finished) then
				return true
			elseif find_stairs(t, x, y+1, finished) then
				return true
			elseif find_stairs(t, x+1, y, finished) then
				return true
			else
				return find_stairs(t, x-1, y, finished)
			end
		else
			return false
		end
	else
		return false
	end
end

property "gen.cave: connected start and stairs" {
	generators = {},
	check = function()
		local t, x, y = gen.cave()
		return find_stairs(t, x, y, {})
	end
}
