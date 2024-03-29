local tiny = require("lib.tiny")

local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local gen = require("core.gen")
local bestiary = require("core.bestiary")

local light = require("core.system.light")
local decide = require("core.system.decide")
local health = require("core.system.health")
local move = require("core.system.move")

local setup = require("core.setup")

property "setup.make_system_list: use passed in ui" {
	generators = { tbl() },
	check = function(ui_sys)
		local res = setup.make_system_list({make_system = function() return ui_sys end})
		for _,v in ipairs(res) do
			if v == ui_sys then
				return true
			end
		end
		return false
	end
}

property "setup.from_state: add entities" {
	generators = { any(), tbl(), tbl(), any(), any(), int(), int() },
	check = function(player_pos, raw_terrain, raw_denizens, memory, num, terrain_i, denizens_i)
		local terrain = {}
		for _,v in pairs(raw_terrain) do
			if type(v) == "table" then table.insert(terrain, v) end
		end
		local denizens = {}
		for _,v in pairs(raw_denizens) do
			if type(v) == "table" then table.insert(denizens, v) end
		end
		
		local terrain_i = base.clip(terrain_i, 0, #terrain)
		local denizens_i = base.clip(denizens_i, 0, #denizens)
		local p = {
			player_pos = player_pos,
			terrain = terrain,
			denizens = denizens,
			memory = memory,
			num = num
		}
		local w = tiny.world()
		setup.from_state(w, p)
		w.refresh(w)
		local t_res = w.entities[terrain[terrain_i]] or terrain_i == 0
		local d_res = w.entities[denizens[denizens_i]] or denizens_i == 0
		return t_res and d_res and ((#w.entities) == (#terrain + #denizens))
	end
}


property "setup.from_state: simple fields" {
	generators = { any(), tbl(), tbl(), any(), any(), int() },
	check = function(player_pos, terrain, denizens, memory, num, i)
		local k_list = {"terrain", "denizens", "player_pos", "memory", "num"}
		local i = base.clip(i, 1, #k_list)
		local k = k_list[i]
		local p = {
			player_pos = player_pos,
			terrain = terrain,
			denizens = denizens,
			memory = memory,
			num = num
		}
		local w = tiny.world()
		setup.from_state(w, p)
		return base.equals(w.state[k], p[k])
	end
}

property "setup.gen_denizens: player at player_pos" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), bool(), tbl() },
	check = function(player_pos, use_player_tbl, player_tbl)
		local player_tbl = player_tbl
		if not use_player_tbl then
			player_tbl = nil
		end
		local terrain = gen.cave()
		bestiary.make_set()
		local res = setup.gen_denizens(terrain, player_pos, player_tbl)
		local res_player = res[player_pos]
		if use_player_tbl then
			return res_player == player_tbl
		else
			return res_player.decide == enum.decidemode.player
		end
	end
}

property "setup.gen_denizens: all on walkable spaces" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int() },
	check = function(player_pos, i)
		local terrain = gen.cave()
		bestiary.make_set()
		local res = setup.gen_denizens(terrain, player_pos)
		local res_list = base.extend_arr({}, pairs(res))
		local i = base.clip(i, 1, #res_list)
		local dz = res_list[i]
		if dz.pos == player_pos then
			--Must respect player_pos, no matter what
			return res[dz.pos] == dz
		else
			--ignore denizens in move.walkable, 
			--because otherwise dz itself will be detected by move.walkable
			return move.walkable(terrain, {}, dz.pos) and res[dz.pos] == dz
		end
	end
}

property "setup.gen_state: simple fields" {
	generators = { int(), bool(), tbl() },
	check = function(num, use_player_tbl, player_tbl)
		local player_tbl = player_tbl
		if not use_player_tbl then
			player_tbl = nil
		end
		local res = setup.gen_state(num, player_tbl)
		return res.num == num and base.is_empty(res.memory)
	end 
}

property "setup.gen_state: terrain" {
	generators = { int(), bool(), tbl(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(num, use_player_tbl, player_tbl, pos)
		local player_tbl = player_tbl
		if not use_player_tbl then
			player_tbl = nil
		end
		local res = setup.gen_state(num, player_tbl)
		local k = res.terrain[pos].kind
		return k >= 1 and k < enum.tile.MAX and res.terrain[pos].pos == pos
	end 
}

property "setup.gen_state: player" {
	generators = { int(), bool(), tbl() },
	check = function(num, use_player_tbl, player_tbl)
		local player_tbl = player_tbl
		if not use_player_tbl then
			player_tbl = nil
		end
		local res = setup.gen_state(num, player_tbl)
		local res_player = res.denizens[res.player_pos]
		if use_player_tbl and res_player ~= player_tbl then
			return false
		elseif not use_player_tbl and res_player.decide ~= enum.decidemode.player then
			return false
		end
		return res_player.pos == res.player_pos
	end 
}

property "setup.clear_entities_except" {
	generators = { tbl(), tbl(), int(), int() },
	check = function(raw_exceptions, raw_others, except_i, others_i)
		local w = tiny.world()
		local exceptions = {}
		local except_set = {}
		for _,v in pairs(raw_exceptions) do
			if type(v) == "table" then
				table.insert(exceptions, v)
				except_set[v] = true
				w.addEntity(w, v)
			end
		end
		local except_i = base.clip(except_i, 0, #exceptions)
		local others = {}
		local others_set = {}
		for _,v in pairs(raw_others) do
			if type(v) == "table" then
				table.insert(others, v)
				others_set[v] = true
				w.addEntity(w, v)
			end
		end
		local others_i = base.clip(others_i, 0, #others)
		w.refresh(w)
		setup.clear_entities_except(w, except_set)
		w.refresh(w)
		if w.getEntityCount(w) ~= #exceptions then
			return false
		elseif except_i > 0 and not w.entities[exceptions[except_i]] then
			return false
		elseif others_i > 0 and w.entities[others[others_i]] then
			return false
		else
			return true
		end
	end
}

property "setup.exit_f: call ui.shutdown and raw_exit_f in that order" {
	generators = { tbl(), tbl(), bool() },
	check = function(w, state, kill_save) 
		w.state = state
		local old_ui, old_save, old_f = setup.ui, setup.save, setup.raw_exit_f

		local shutdown_called = false
		local shutdown_before_exit

		setup.save = {remove = function() end, save = function() end}
		setup.ui = {shutdown = function() shutdown_called = true end}
		setup.raw_exit_f = function() shutdown_before_exit = shutdown_called end
		setup.exit_f(w, kill_save)

		setup.ui, setup.save, setup.raw_exit_f = old_ui, old_save, old_f

		return shutdown_called and shutdown_before_exit
	end
}

property "setup.exit_f: call remove only if kill_save, call save otherwise" {
	generators = { tbl(), tbl(), bool() },
	check = function(w, state, kill_save)
		w.state = state
		local old_ui, old_save, old_f = setup.ui, setup.save, setup.raw_exit_f

		local remove_called = false
		local save_args = {}
		setup.save = {
			remove = function() remove_called = true end,
			save = function(...) table.insert(save_args, {...}) end
		}
		setup.ui = {shutdown = function() end}
		setup.raw_exit_f = function() end
		setup.exit_f(w, kill_save)

		setup.ui, setup.save, setup.raw_exit_f = old_ui, old_save, old_f

		if kill_save then
			return remove_called and #save_args == 0
		else
			return not remove_called and base.equals(save_args, {{{
					enum_inverted = enum.inverted,
					bestiary_set = bestiary.set,
					state = w.state
			}}})
		end
	end
}

property "setup.regen: expected calls" {
	generators = { tbl(), tbl(), int(), int(grid.MIN_POS, grid.MAX_POS), tbl() },
	check = function(w, player, num, player_pos, pickle_t)
		w.state = {}
		w.state.player_pos = player_pos
		w.state.denizens = {[w.state.player_pos] = player}

		local old_except = setup.clear_entities_except
		local old_unpickle = setup.from_state
		local old_gen_pickle = setup.gen_state

		local clear_args = {}
		setup.clear_entities_except = function(...) table.insert(clear_args, {...}) end

		local unpickle_args = {}
		setup.from_state = function(...) table.insert(unpickle_args, {...}) end

		local gen_pickle_args = {}
		setup.gen_state = function(...)
			table.insert(gen_pickle_args, {...})
			return pickle_t
		end

		setup.regen(w, num)

		setup.clear_entities_except = old_except
		setup.from_state = old_unpickle
		setup.gen_state = old_gen_pickle

		local clear_res = base.equals(clear_args, {{w, {[player] = true}}})
		local gen_pickle_res = base.equals(gen_pickle_args, {{num, player}})
		local unpickle_res = base.equals(unpickle_args, {{w, pickle_t}})
		return clear_res and gen_pickle_res and unpickle_res
	end
}