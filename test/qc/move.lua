local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local move = require("core.move")

local mock = require("test.mock")

property "move.walkable: correct result" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		int(1, enum.terrain.MAX-1)
	},
	check = function(x, y, add_dz, terrain_kind)
		local pos = grid.get_pos(x, y)
		local terrain = {[pos] = {kind = terrain_kind, pos=pos}}
		local denizens = {}
		if add_dz then denizens[pos] = {pos = pos} end
		local good_t = (terrain_kind == enum.terrain.floor) or (terrain_kind == enum.terrain.stair)
		return move.walkable(terrain, denizens, pos) == ((not add_dz) and good_t)
	end
}

property "move.reset_paths: reasonable values in paths" {
	generators = { 
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool()
	},
	check = function(targ_x, targ_y, source_x, source_y, dz_x, dz_y, make_cave)
		local targ_pos = grid.get_pos(targ_x, targ_y)
		local source_pos = grid.get_pos(source_x, source_y)
		local dz_pos = grid.get_pos(dz_x, dz_y)
		local w = mock.world(make_cave)
		w.denizens[dz_pos] = {pos=dz_pos}
		move.reset_paths({world = w})
		local res = w.walk_paths[targ_pos][source_pos]
		if res then
			return res >= grid.distance(targ_pos, source_pos)
		elseif targ_pos == dz_pos or source_pos == dz_pos then
			return true
		elseif w.terrain[targ_pos].kind ~= enum.terrain.floor then
			return true
		elseif w.terrain[source_pos].kind ~= enum.terrain.floor then
			return true
		else
			return false
		end
	end
}

property "move.options: filter destinations by walkability" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool()
	},
	check = function(x, y, make_cave)
		local w = mock.world(make_cave)
		local source_pos = grid.get_pos(x, y)
		local expected = base.extend_arr({}, grid.destinations(source_pos))
		local n_expected = #expected
		for i=n_expected,1,-1 do
			if not move.walkable(w.terrain, w.denizens, expected[i]) then
				table.remove(expected, i)
			end
		end
		return base.equals(move.options(w, source_pos), expected)
	end
}

property "move.prepare, move.process: move denizen properly" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 4),
		int(1, enum.decidemode.MAX-1),
		int(1, enum.terrain.MAX-1)
	},
	check = function(x, y, targ_x, targ_y, opt_i, decidemode, terrain_kind)
		local w, source = mock.mini_world(false, true, x, y)
		source.decide = decidemode
		local targ_pos = grid.get_pos(targ_x, targ_y)
		w.terrain[targ_pos] = {kind = terrain_kind, pos=targ_pos}
		local old_num = w.num
		local old_regen = move.regen_f
		local regen_args = {}
		move.regen_f = function(...) table.insert(regen_args, {...}) end
		move.prepare(w, source, targ_pos)
		move.process({world = w}, source)
		move.regen_f = old_regen
		if decidemode == enum.decidemode.player and terrain_kind == enum.terrain.stair then
			return base.equals(regen_args, {{w, old_num + 1}})
		else
			return #regen_args == 0 and source.pos == targ_pos
		end
	end
}