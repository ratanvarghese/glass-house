local base = require("src.base")
local enum = require("src.enum")
local grid = require("src.grid")
local tool = require("src.tool")

property "tool.make: copies template" {
	generators = { tbl() },
	check = function(t)
		t.name = "test"
		tool.set.test = {
			template = t,
			equip = function() end
		}

		local obj = tool.make("test")
		return base.equals(t, obj) and t ~= obj
	end
}

property "tool.equip: calls tool's equip function" {
	generators = { str() },
	check = function(name)
		local called_equip = false
		tool.set[name] = {
			template = {name = name},
			equip = function() called_equip = true end
		}
		local obj = tool.make(name)
		tool.equip(obj)
		return called_equip
	end
}

property "tool.equip: does not call wrong equip function" {
	generators = { str(), str() },
	check = function(name1, name2)
		local called_equip = false
		tool.set[name1] = {
			template = {name = name1},
			equip = function() end
		}
		tool.set.name2 = {
			template = {name = name2},
			equip = function() called_equip = true end
		}
		local obj = tool.make(name1)
		tool.equip(obj)
		return not called_equip
	end
}

property "tool.pile_from_array: respect make_missing" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), bool() },
	check = function(x, y, make_missing)
		local pile_array = {}
		local pile = tool.pile_from_array(pile_array, x, y, make_missing)
		if make_missing then
			return pile and base.is_empty(pile)
		else
			return not pile
		end
	end
}

property "tool.pile_from_array: find the pile, without removing it" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), bool() },
	check = function(x, y, make_missing)
		local pile = {{}, {}, {}}
		local i = grid.get_idx(x, y)
		local pile_array = {[i] = pile}
		local out = tool.pile_from_array(pile_array, x, y, make_missing)
		return out == pile and pile_array[i] == pile
	end
}

property "tool.pickup_from_array: pickup correct tool" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, 5) },
	check = function(x, y, tool_idx)
		local items = {{}, {}, {}, {}, {}}
		local pile = {}
		for i,v in ipairs(items) do pile[i] = v end --Cannot use base.copy... changes pointers
		local i = grid.get_idx(x, y)
		local pile_array = {[i] = pile}
		local out = tool.pickup_from_array(pile_array, tool_idx, x, y)
		local pile_inverted = base.invert(pile) --Must be after pickup
		if out ~= items[tool_idx] then
			print(#items)
		end
		return out == items[tool_idx] and not pile_inverted[out] and #pile == 4
	end
}

property "tool.pickup_all_from_array: pickup entire pile" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local pile = {{}, {}, {}, {}, {}}
		local i = grid.get_idx(x, y)
		local pile_array = {[i] = pile}
		local out = tool.pickup_all_from_array(pile_array, x, y)
		return base.equals(pile, out) and (not pile_array[i] or base.is_empty(pile_array[i]))
	end
}

property "tool.drop_onto_array: add to top of existing pile" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), tbl() },
	check = function(x, y, tool_to_drop)
		local pile = {{}, {}, {}, {}, {}}
		local i = grid.get_idx(x, y)
		local pile_array = {[i] = pile}
		tool.drop_onto_array(pile_array, tool_to_drop, x, y)
		return pile[#pile] == tool_to_drop
	end
}

property "tool.drop_onto_array: add to top of new pile" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), tbl() },
	check = function(x, y, tool_to_drop)
		local pile_array = {}
		tool.drop_onto_array(pile_array, tool_to_drop, x, y)
		local i = grid.get_idx(x, y)
		return pile_array[i][1] == tool_to_drop
	end
}

property "tool.light_from_list: return max" {
	generators = { int(), int(), int(), int(), int(), int() },
	check = function(r1, r2, r3, r4, r5, r_default)
		local list = {
			{powers={[enum.power.light] = r1}},
			{powers={[enum.power.light] = r2}},
			{powers={[enum.power.light] = r3}},
			{powers={[enum.power.light] = r4}},
			{powers={[enum.power.light] = r5}}
		}
		local res = tool.light_from_list(list, r_default)
		return res == math.max(r1, r2, r3, r4, r5, r_default)
	end
}

property "tool.light_from_list: use default on nil list" {
	generators = { int() },
	check = function(r)
		return tool.light_from_list(nil, r) == r
	end
}

property "tool.light_from_list: use default on list without light_radius" {
	generators = { int() },
	check = function(r)
		local list = {{powers={}}, {powers={}}, {powers={}}, {powers={}}, {powers={}}}
		return tool.light_from_list(list, r) == r
	end
}

property "tool.light_from_list: nil if all inputs nil" {
	generators = {},
	numtests = 1,
	check = function()
		return tool.light_from_list() == nil
	end
}
