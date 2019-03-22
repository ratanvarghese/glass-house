local base = require("src.base")
local gen = require("src.gen")

property "gen.big_room: player x, y" {
	generators = {},
	check = function()
		local t, x, y = gen.big_room()
		local i = base.getIdx(x, y)
		local v = t[i]
		local good_x = v.x > 1 and v.x < base.MAX_X
		local good_y = v.y > 1 and v.y < base.MAX_Y
		local good_s = v.symbol == base.symbols.floor
		return good_x and good_y and good_s
	end
}

property "gen.big_room: terrain" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(x, y)
		local t = gen.big_room()
		local i = base.getIdx(x, y)
		local s = t[i].symbol
		local wall_x = (x == 1 or x == base.MAX_X)
		local wall_y = (y == 1 or y == base.MAX_Y)
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
	local i = base.getIdx(x, y)
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
