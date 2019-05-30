local enum = require("src.enum")
local grid = require("src.grid")
local gen = require("src.gen")
local flood = require("src.flood")

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
		return (v.kind == enum.terrain.floor)
	end
}

property "gen.big_room: terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local t = gen.big_room()
		local i = grid.get_idx(x, y)
		local s = t[i].kind
		if s == enum.terrain.stair or s == enum.terrain.floor then
			return not grid.is_edge(x, y)
		elseif s == enum.terrain.wall then
			return grid.is_edge(x, y)
		else
			return false
		end
	end
}

property "gen.cave: connected start and stairs" {
	generators = {},
	check = function()
		local t, x, y = gen.cave()
		local eligible = grid.make_full(function(x, y, i)
			return t[i].kind ~= enum.terrain.wall
		end)
		return flood.search(x, y, eligible, function(x, y, i)
			return t[i].kind == enum.terrain.stair
		end)
	end
}
