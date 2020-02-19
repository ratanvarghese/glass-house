local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local act = require("core.act")

local mock = require("test.mock")

local function setup(seed, pos, tool_list, tool_i)
	local tool_list = base.extend_arr({}, pairs(tool_list))
	local tool_i = base.is_empty(tool_list) and tool_i or base.clip(tool_i, 1, #tool_list)
	local w, source = mock.mini_world(seed, pos)
	local t = base.copy(w.state.terrain[source.pos])
	return w, source, t, tool_list, tool_i
end

local function attempt_check(w, source, tool_list, tool_i, name)
	local t = act[enum.power.tool][name]
	local res = t.attempt(w, source, tool_i)
	local targ_t = source.usetool[name]
	if base.is_empty(tool_list) then
		return not res and (not targ_t or base.is_empty(targ_t))
	else
		return res and targ_t and targ_t[1] == tool_i
	end
end

local function basic_possible(tbl, use_tile_inventory)
	return function(seed, pos, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(seed, pos, tool_list, tool_i)
		if use_tile_inventory then
			t.inventory = tool_list
		else
			source.inventory = tool_list
		end
		w.state.terrain[source.pos] = t
		return tbl.possible(w, source, tool_i) or base.is_empty(tool_list)
	end
end

local function basic_attempt(name, use_tile_inventory)
	return function(seed, pos, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(seed, pos, tool_list, tool_i)
		if use_tile_inventory then
			t.inventory = tool_list
		else
			source.inventory = tool_list
		end
		w.state.terrain[source.pos] = t
		return attempt_check(w, source, tool_list, tool_i, name)
	end
end

property "act[enum.power.tool] pickup: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_possible(act[enum.power.tool].pickup, true)
}

property "act[enum.power.tool] pickup: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_attempt("pickup", true)
}

property "act[enum.power.tool] drop: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_possible(act[enum.power.tool].drop, false)
}

property "act[enum.power.tool] drop: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_attempt("drop", false)
}

property "act[enum.power.tool] equip: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_possible(act[enum.power.tool].equip, false)
}

property "act[enum.power.tool] equip: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int() },
	check = basic_attempt("equip", false)
}