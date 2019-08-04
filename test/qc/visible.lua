local mock = require("test.mock")

local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local visible = require("core.visible")

property "visible.at: just terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), bool() },
	check = function(x, y, make_cave)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		w.terrain[pos].inventory = {}
		local k, e = visible.at(w, pos)
		if w.light[pos] then
			return k == w.terrain[pos].kind and e == enum.tile
		elseif w.memory[pos] and w.terrain[pos].kind ~= enum.tile.floor then
			return k == w.terrain[pos].kind and e == enum.tile
		else
			return not k and not e
		end
	end
}

property "visible.at: player" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), bool(), int() },
	check = function(x, y, make_cave, kind)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		w.player_pos = pos
		w.denizens[pos] = {kind = kind}
		local k, e = visible.at(w, pos)
		return k == kind and e == enum.monster
	end
}

property "visible.at: denizen" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), bool(), int() },
	check = function(x, y, make_cave, kind)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		w.denizens[pos] = {kind = kind}
		local k, e = visible.at(w, pos)
		if w.light[pos] then
			return k == kind and e == enum.monster
		else
			return e ~= enum.monster
		end
	end
}

property "visible.at: tool" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		int(),
		int()
	},
	check = function(x, y, make_cave, kind, dummy1)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		w.terrain[pos].inventory = {
			{kind = dummy1},
			{kind = kind}
		}
		local k, e = visible.at(w, pos)
		if w.light[pos] then
			return k == kind and e == enum.tool
		else
			return e ~= enum.tool
		end
	end
}

property "visible.stats: health" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		int(),
		int()
	},
	check = function(x, y, make_cave, health_now, health_max)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		local health = {now = health_now, max = health_max}
		w.player_pos = pos
		w.denizens[pos] = {
			health = health,
			pos = pos
		}
		local res = visible.stats(w).health
		return res ~= health and res.now == health_now and res.max == health_max
	end
}