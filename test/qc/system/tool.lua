local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local toolkit = require("core.toolkit")
local tool = require("core.system.tool")

local mock = require("test.mock")

local function setup(seed, pos, tool_list, tool_i)
	local tool_list = base.extend_arr({}, pairs(tool_list))
	local tool_i = base.is_empty(tool_list) and tool_i or base.clip(tool_i, 1, #tool_list)
	local w, source = mock.mini_world(seed, pos)
	local t = base.copy(w.state.terrain[source.pos])
	return w, source, t, tool_list, tool_i
end

property "tool.process: pickup" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int(), int() },
	check = function(seed, pos, tool_list, tool_i, check_i)
		local w, source, t, tool_list, tool_i = setup(seed, pos, tool_list, tool_i)
		local check_i = (tool_i < 1) and 0 or base.clip(check_i, 0, tool_i-1)
		t.inventory = tool_list
		w.state.terrain[source.pos] = t
		source.usetool.pickup = {tool_i}
		local old_tool, old_next_tool = tool_list[tool_i], tool_list[tool_i+1]
		local old_check_tool = tool_list[check_i]
		tool.process({world=w}, source, 1)

		local good_dz = (source.inventory[1] == old_tool)
		local good_tile = (tool_list[tool_i] == old_next_tool) and (tool_list[check_i] == old_check_tool)
		return good_dz and good_tile
	end
}

property "tool.process: drop" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int(), int() },
	check = function(seed, pos, tool_list, tool_i, check_i)
		local w, source, t, tool_list, tool_i = setup(seed, pos, tool_list, tool_i)
		local check_i = (tool_i < 1) and 0 or base.clip(check_i, 0, tool_i-1)
		source.inventory = tool_list
		t.inventory = {}
		w.state.terrain[source.pos] = t
		source.usetool.drop = {tool_i}
		local old_tool, old_next_tool = tool_list[tool_i], tool_list[tool_i+1]
		local old_check_tool = tool_list[check_i]
		tool.process({world=w}, source, 1)

		local good_tile = (t.inventory[1] == old_tool)
		local good_dz = (tool_list[tool_i] == old_next_tool) and (tool_list[check_i] == old_check_tool)
		return good_dz and good_tile
	end
}

property "tool.process: equip" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), tbl(), int(), int() },
	check = function(seed, pos, tool_list, tool_i, check_i)
		local w, source, t, tool_list, tool_i = setup(seed, pos, tool_list, tool_i)
		source.inventory = tool_list
		w.state.terrain[source.pos] = t
		source.usetool.equip = {tool_i}
		local old_equip = toolkit.equip
		local args = {}
		toolkit.equip = function(...) table.insert(args, {...}) end
		tool.process({world=w}, source, 1)
		toolkit.equip = old_equip

		if base.is_empty(tool_list) then
			return #args == 0
		else
			return base.equals(args, {{source.inventory[tool_i], source}})
		end
	end
}