local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local act = require("core.act")
local tool = require("core.tool")

local mock = require("test.mock")

local function setup(x, y, cave, swap, tool_list, tool_i)
		local tool_list = base.extend_arr({}, pairs(tool_list))
		local tool_i = base.is_empty(tool_list) and tool_i or base.clip(tool_i, 1, #tool_list)
		local w, source = mock.mini_world(cave, swap, x, y)
		local t = base.copy(w.terrain[source.pos])
		return w, source, t, tool_list, tool_i
end

local function attempt_check(w, source, tool_list, tool_i, name)
	local f = act[enum.power.tool][name]
	local res = f(enum.actmode.attempt, w, source, tool_i)
	local targ_t = source.usetool[name]
	if base.is_empty(tool_list) then
		return not res and (not targ_t or base.is_empty(targ_t))
	else
		return res and targ_t and targ_t[1] == tool_i
	end
end

property "act[enum.power.tool] pickup: possible" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		t.inventory = tool_list
		w.terrain[source.pos] = t

		local f = act[enum.power.tool].pickup
		return f(enum.actmode.possible, w, source, tool_i) or base.is_empty(tool_list)
	end
}

property "act[enum.power.tool] pickup: attempt" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		t.inventory = tool_list
		w.terrain[source.pos] = t

		return attempt_check(w, source, tool_list, tool_i, "pickup")
	end
}

property "act[enum.power.tool] drop: possible" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		source.inventory = tool_list
		w.terrain[source.pos] = t

		local f = act[enum.power.tool].drop
		return f(enum.actmode.possible, w, source, tool_i) or base.is_empty(tool_list)
	end
}

property "act[enum.power.tool] drop: attempt" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int(),
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		source.inventory = tool_list
		w.terrain[source.pos] = t

		return attempt_check(w, source, tool_list, tool_i, "drop")
	end
}

property "act[enum.power.tool] equip: possible" {
		generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		source.inventory = tool_list
		w.terrain[source.pos] = t

		local f = act[enum.power.tool].equip
		return f(enum.actmode.possible, w, source, tool_i) or base.is_empty(tool_list)
	end
}

property "act[enum.power.tool] equip: attempt" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		bool(),
		tbl(),
		int(),
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		source.inventory = tool_list
		w.terrain[source.pos] = t

		return attempt_check(w, source, tool_list, tool_i, "equip")
	end
}