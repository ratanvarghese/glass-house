local base = require("src.base")
local gen = require("src.gen")

local valid_names = {"floor", "stair", "wall"}
local valid_symbols = { ".", "<", "#" }
property "gen.set_tile: valid name" {
	generators = { int(1, #valid_names), int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(i, x, y)
		local name = valid_names[i]
		local s = valid_symbols[i]
		local terrain = {}
		gen.set_tile(terrain, name, x, y)
		local idx = base.get_idx(x, y)

		local tile = terrain[idx]
		return tile and (tile.x == x) and (tile.y == y) and (tile.symbol == s)
	end
}

property "gen.set_tile: invalid name" {
	generators = { str(), int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(name, x, y)
		local terrain = {}
		local ok = pcall(function()
			gen.set_tile(terrain, name, x, y)
		end)
		for k,v in pairs(valid_names) do
			if name == v then
				return ok
			end
		end
		return not ok
	end
}

property "gen.big_room: player x" {
	generators = {},
	check = function()
		local t, x, y = gen.big_room()
		local i = base.get_idx(x, y)
		local v = t[i]
		return (v.x > 1) and (v.x < base.MAX_X)
	end
}

property "gen.big_room: player y" {
	generators = {},
	check = function()
		local t, x, y = gen.big_room()
		local i = base.get_idx(x, y)
		local v = t[i]
		return (v.y > 1) and (v.y < base.MAX_Y)
	end
}

property "gen.big_room: player on floor" {
	generators = {},
	check = function()
		local t, x, y = gen.big_room()
		local i = base.get_idx(x, y)
		local v = t[i]
		return (v.symbol == base.symbols.floor)
	end
}

property "gen.big_room: terrain" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(x, y)
		local t = gen.big_room()
		local i = base.get_idx(x, y)
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
	local i = base.get_idx(x, y)
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
