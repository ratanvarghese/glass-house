local mock = require("test.mock")
local enum = require("core.enum")
local grid = require("core.grid")
local path = require("core.path")

property "path.walkable: correct result" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		int(1, enum.terrain.MAX-1)
	},
	check = function(x, y, add_dz, terrain_kind)
		local pos = grid.get_pos(x, y)
		local world = {
			terrain = {[pos] = {kind = terrain_kind, pos=pos}},
			denizens = {}
		}
		if add_dz then world.denizens[pos] = {pos = pos} end
		local good_t = (terrain_kind == enum.terrain.floor) or (terrain_kind == enum.terrain.stair)
		return path.walkable(world, pos) == ((not add_dz) and good_t)
	end
}

property "path.reset_all: reasonable values in paths" {
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
		path.reset_all({world = w})
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
