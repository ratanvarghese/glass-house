local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local move = require("core.system.move")

local mock = require("test.mock")

property "move.walkable: correct result" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), bool(), int(1, enum.tile.MAX-1) },
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
		int()
	},
	check = function(targ_pos, source_pos, dz_pos, seed)
		local w = mock.world_from_state(mock.state(seed))
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
	generators = { int(grid.MIN_POS, grid.MAX_POS), int() },
	check = function(source_pos, seed)
		local w = mock.world_from_state(mock.state(seed))
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
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(1, enum.decidemode.MAX-1),
		int(1, enum.tile.MAX-1)
	},
	check = function(seed, pos, decidemode, terrain_kind)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.decide = decidemode
		w.state.terrain[targ_pos] = {kind = terrain_kind, pos=targ_pos}
		local old_num = w.state.num
		local old_regen = move.regen_f
		local regen_args = {}
		move.regen_f = function(...) table.insert(regen_args, {...}) end
		move.prepare(w, src, targ_pos)
		move.process({world=w}, src)
		move.regen_f = old_regen
		if decidemode == enum.decidemode.player and terrain_kind == enum.tile.stair then
			return base.equals(regen_args, {{w, old_num + 1}})
		elseif decidemode == enum.decidemode.player and w.state.player_pos ~= src.pos then
			return false
		else
			if #regen_args ~= 0 then
				return false
			elseif src.pos ~= targ_pos then
				return false
			elseif src.destination ~= targ_pos then
				return false
			elseif w.state.denizens[src.pos] ~= src then
				return false
			else
				return true
			end
		end
	end
}


local function nearby_setup(seed, x, y, distance, targ_along_x)
	local pos = grid.get_pos(x, y)
	local w, src = mock.mini_world(seed, pos, true)
	local spos_x, spos_y = grid.get_xy(src.pos)
	local targ_pos
	if targ_along_x then
		targ_pos = grid.get_pos(spos_x+distance, spos_y)
	else
		targ_pos = grid.get_pos(spos_x, spos_y+distance)
	end
	local targ = {pos=targ_pos}
	w.state.denizens[targ_pos] = targ
	return w, src, targ	
end

property "move.prepare, move.process: displace" {
	generators = {
		int(),
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		int(-2,2),
		bool(),
		int(1, enum.decidemode.MAX-1),
		int(1, enum.tile.MAX-1)
	},
	check = function(seed, x, y, distance, targ_along_x, targ_decidemode, terrain_kind)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ = nearby_setup(seed, x, y, distance, targ_along_x)
		local old_src_pos = src.pos
		targ.decidemode = targ_decidemode
		w.state.terrain[src.pos] = {kind = terrain_kind, pos=src.pos}

		local old_num = w.state.num
		local old_regen = move.regen_f
		local regen_args = {}
		
		move.regen_f = function(...) table.insert(regen_args, {...}) end
		move.prepare(w, src, targ.pos)
		
		move.process({world=w}, src)
		
		move.regen_f = old_regen
		if decidemode == enum.decidemode.player and terrain_kind == enum.tile.stair then
			return base.equals(regen_args, {{w, old_num + 1}})
		else
			if #regen_args ~= 0 then
				return false
			elseif targ.pos ~= old_src_pos then
				return false
			elseif targ.destination ~= old_src_pos then
				return false
			elseif w.state.denizens[targ.pos] ~= targ then
				return false
			else
				return true
			end
		end
	end
}

property "move.stick, move.is_stuck: expected result for is_stuck" {
	generators = {
		int(),
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		int(-2,2),
		bool()
	},
	check = function(seed, x, y, distance, targ_along_x)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ = nearby_setup(seed, x, y, distance, targ_along_x)
		move.stick(src, targ)
		local res = move.is_stuck(w.state.denizens, targ)		
		if distance == 1 or distance == -1 then
			return res
		else
			return not res
		end
	end
}

property "move.stick, move.is_stuck, move.prepare, move.process: prevent move" {
	generators = {
		int(),
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		int(-2,2),
		bool(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(seed, x, y, distance, targ_along_x, move_targ_pos)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ = nearby_setup(seed, x, y, distance, targ_along_x)
		local old_targ_pos = targ.pos
		move.stick(src, targ)
		move.prepare(w, targ, move_targ_pos)
		local stuck = move.is_stuck(w.state.denizens, targ)

		local regen_args = {}
		move.regen_f = function(...) table.insert(regen_args, {...}) end
		move.process({world=w}, targ)
		move.regen_f = old_regen
		if stuck then
			return #regen_args == 0 and targ.pos == old_targ_pos
		else
			return #regen_args > 0 or targ.pos == move_targ_pos
		end
	end
}
