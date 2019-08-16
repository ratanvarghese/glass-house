local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local move = require("core.system.move")

local mock = require("test.mock")

property "move.walkable: correct result" {
	generators = {
		int(grid.MIN_POS, grid.MAX_POS),
		bool(),
		int(1, enum.tile.MAX-1)
	},
	check = function(pos, add_dz, terrain_kind)
		local terrain = {[pos] = {kind = terrain_kind, pos=pos}}
		local denizens = {}
		if add_dz then denizens[pos] = {pos = pos} end
		local good_t = (terrain_kind == enum.tile.floor) or (terrain_kind == enum.tile.stair)
		return move.walkable(terrain, denizens, pos) == ((not add_dz) and good_t)
	end
}

property "move.reset_paths: reasonable values in paths" {
	generators = { 
		int(grid.MIN_POS, grid.MAX_POS),
		int(grid.MIN_POS, grid.MAX_POS),
		int(grid.MIN_POS, grid.MAX_POS),
		bool()
	},
	check = function(targ_pos, source_pos, dz_pos, make_cave)
		local w = mock.world(make_cave)
		w.state.denizens[dz_pos] = {pos=dz_pos}
		move.reset_paths({world = w})
		local res = w.walk_paths[targ_pos][source_pos]
		if res then
			return res >= grid.distance(targ_pos, source_pos)
		elseif targ_pos == dz_pos or source_pos == dz_pos then
			return true
		elseif w.state.terrain[targ_pos].kind ~= enum.tile.floor then
			return true
		elseif w.state.terrain[source_pos].kind ~= enum.tile.floor then
			return true
		else
			return false
		end
	end
}

property "move.options: filter destinations by walkability" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), bool() },
	check = function(source_pos, make_cave)
		local w = mock.world(make_cave)
		local expected = base.extend_arr({}, grid.destinations(source_pos))
		local n_expected = #expected
		for i=n_expected,1,-1 do
			if not move.walkable(w.state.terrain, w.state.denizens, expected[i]) then
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
		int(grid.MIN_POS, grid.MAX_POS),
		int(1, 4),
		int(1, enum.decidemode.MAX-1),
		int(1, enum.tile.MAX-1)
	},
	check = function(x, y, targ_pos, opt_i, decidemode, terrain_kind)
		local w, source = mock.mini_world(false, true, x, y)
		source.decide = decidemode
		w.state.terrain[targ_pos] = {kind = terrain_kind, pos=targ_pos}
		local old_num = w.state.num
		local old_regen = move.regen_f
		local regen_args = {}
		move.regen_f = function(...) table.insert(regen_args, {...}) end
		move.prepare(w, source, targ_pos)
		move.process({world = w}, source)
		move.regen_f = old_regen
		if decidemode == enum.decidemode.player and terrain_kind == enum.tile.stair then
			return base.equals(regen_args, {{w, old_num + 1}})
		else
			return #regen_args == 0 and source.pos == targ_pos
		end
	end
}