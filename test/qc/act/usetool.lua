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
		int(),
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i, check_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		local check_i = (tool_i < 1) and 0 or base.clip(check_i, 0, tool_i-1)
		t.inventory = tool_list
		w.terrain[source.pos] = t

		local old_tool, old_next_tool = tool_list[tool_i], tool_list[tool_i+1]
		local old_check_tool = tool_list[check_i]
		local f = act[enum.power.tool].pickup
		local res = f(enum.actmode.attempt, w, source, tool_i)

		local good_res = res or base.is_empty(tool_list)
		local good_dz = (source.inventory[1] == old_tool)
		local good_tile = (tool_list[tool_i] == old_next_tool) and (tool_list[check_i] == old_check_tool)
		return good_res and good_dz and good_tile
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
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i, check_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		local check_i = (tool_i < 1) and 0 or base.clip(check_i, 0, tool_i-1)
		source.inventory = tool_list
		t.inventory = {}
		w.terrain[source.pos] = t

		local old_tool, old_next_tool = tool_list[tool_i], tool_list[tool_i+1]
		local old_check_tool = tool_list[check_i]
		local f = act[enum.power.tool].drop
		local res = f(enum.actmode.attempt, w, source, tool_i)

		local good_res = res or base.is_empty(tool_list)
		local good_tile = (t.inventory[1] == old_tool)
		local good_dz = (tool_list[tool_i] == old_next_tool) and (tool_list[check_i] == old_check_tool)
		return good_res and good_dz and good_tile
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
		int()
	},
	check = function(x, y, cave, swap, tool_list, tool_i)
		local w, source, t, tool_list, tool_i = setup(x, y, cave, swap, tool_list, tool_i)
		source.inventory = tool_list
		w.terrain[source.pos] = t

		local old_equip = tool.equip
		local args = {}
		tool.equip = function(...) table.insert(args, {...}) end
		local f = act[enum.power.tool].equip
		local res = f(enum.actmode.attempt, w, source, tool_i)
		tool.equip = old_equip

		if base.is_empty(tool_list) then
			return (not res) and #args == 0
		else
			return res and base.equals(args, {{source.inventory[tool_i], source}})
		end
	end
}