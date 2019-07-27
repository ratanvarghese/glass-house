local enum = require("core.enum")
local base = require("core.base")
local grid = require("core.grid")
local gen = require("core.gen")
local flood = require("core.flood")

property "gen.big_room: player x" {
	generators = {},
	check = function()
		local _, i = gen.big_room()
		local x = grid.get_xy(i)
		return (x > 1) and (x < grid.MAX_X)
	end
}

property "gen.big_room: player y" {
	generators = {},
	check = function()
		local _, i = gen.big_room()
		local _, y = grid.get_xy(i)
		return (y > 1) and (y < grid.MAX_Y)
	end
}

property "gen.big_room: player on floor" {
	generators = {},
	check = function()
		local t, i = gen.big_room()
		local v = t[i]
		return (v.kind == enum.terrain.floor)
	end
}

property "gen.big_room: terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local t = gen.big_room()
		local i = grid.get_pos(x, y)
		local s = t[i].kind
		local has_pos = t[i].pos == i
		if s == enum.terrain.stair or s == enum.terrain.floor then
			return not grid.is_edge(x, y) and has_pos
		elseif s == enum.terrain.tough_wall then
			return grid.is_edge(x, y) and has_pos
		else
			return false
		end
	end
}

property "gen.cave: tiles have pos" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local t = gen.cave()
		local i = grid.get_pos(x, y)
		return t[i].pos == i
	end
}

property "gen.cave: connected start and stairs" {
	generators = {},
	check = function()
		local t, start_i = gen.cave()
		local function eligible(i)
			return t[i].kind ~= enum.terrain.wall
		end
		return flood.search(start_i, eligible, function(i)
			return t[i].kind == enum.terrain.stair
		end)
	end
}

property "gen.cave: correct number of floor tiles" {
	generators = {},
	check = function()
		local t = gen.cave()
		local n = 0
		for _,x,y,v in grid.points(t) do
			if v.kind == enum.terrain.floor then
				n = n + 1
			end
		end
		return n == gen.CAVE_STEPS
	end
}
