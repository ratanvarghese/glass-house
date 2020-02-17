local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local morph = require("core.system.morph")

local mock = require("test.mock")

property "morph.smashable: correct result" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), bool(), int(1, enum.tile.MAX-1) },
	check = function(pos, add_dz, terrain_kind)
		local terrain = {[pos] = {kind = terrain_kind, pos=pos}}
		local denizens = {}
		if add_dz then denizens[pos] = {pos = pos} end
		local good_t = (terrain_kind == enum.tile.wall)
		return morph.smashable(terrain, denizens, pos) == ((not add_dz) and good_t)
	end
}

property "morph.smash_options: filter destinations by smashability" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int() },
	check = function(source_pos, seed)
		local w = mock.world_from_state(mock.state(seed))
		local expected = base.extend_arr({}, grid.destinations(source_pos))
		local n_expected = #expected
		for i=n_expected,1,-1 do
			if not morph.smashable(w.state.terrain, w.state.denizens, expected[i]) then
				table.remove(expected, i)
			end
		end
		return base.equals(morph.smash_options(w, source_pos), expected)
	end
}

property "morph.prepare, morph.process: morph terrain properly" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(1, enum.tile.MAX-1),
		int(1, enum.tile.MAX-1)
	},
	check = function(seed, pos, old_kind, new_kind)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local system = {world=w}
		local tile = {kind = old_kind, pos=targ_pos}
		w.state.terrain[targ_pos] = tile
		morph.prepare(tile, new_kind)
		morph.process(system, tile)
		return tile.kind == new_kind and tile.new_kind == nil
	end
}