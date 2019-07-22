local base = require("core.base")
local enum = require("core.enum")
local tool = require("core.tool")

property "tool.make: copies template" {
	generators = { tbl() },
	check = function(t)
		local old_set = tool.set
		t.kind = 100
		tool.set[t.kind] = {
			template = t,
			equip = function() end
		}

		local obj = tool.make(t.kind)
		tool.set = old_set
		return base.equals(t, obj) and t ~= obj
	end
}

property "tool.equip: calls tool's equip function" {
	generators = { int() },
	check = function(kind)
		local old_set = tool.set
		local called_equip = false
		tool.set[kind] = {
			template = {kind = kind},
			equip = function() called_equip = true end
		}
		local obj = tool.make(kind)
		tool.equip(obj)
		tool.set = old_set
		return called_equip
	end
}

property "tool.equip: does not call wrong equip function" {
	generators = { int(), int() },
	check = function(kind1, kind2)
		local old_set = tool.set
		if kind2 == kind1 then
			kind2 = kind2 + 1
		end
		local called_equip = false
		tool.set[kind1] = {
			template = {kind = kind1},
			equip = function() end
		}
		tool.set[kind2] = {
			template = {kind = kind2},
			equip = function() called_equip = true end
		}
		local obj = tool.make(kind1)
		tool.equip(obj)
		tool.set = old_set
		return not called_equip
	end
}

property "tool.inventory_power: return max" {
	generators = {
		int(1, enum.power.MAX),
		int(1, enum.power.MAX),
		int(),
		int(),
		int(),
		int(),
		int(),
		int(),
		int(1, 5)
	},
	check = function(targ_power, dummy_power, v1, v2, v3, v4, v5, default, dummy_idx)
		local list = {
			{power={[targ_power] = v1}},
			{power={[targ_power] = v2}},
			{power={[targ_power] = v3}},
			{power={[targ_power] = v4}},
			{power={[targ_power] = v5}}
		}
		local vlist = {v1, v2, v3, v4, v5}
		local dummy_t = list[dummy_idx].power
		dummy_t[dummy_power] = dummy_t[targ_power]
		dummy_t[targ_power] = nil
		table.remove(vlist, dummy_idx)
		local res = tool.inventory_power(targ_power, list, default)
		return res == math.max(default, unpack(vlist))
	end
}

property "tool.inventory_power: use default on nil list" {
	generators = { 
		int(1, enum.power.MAX),
		int()
	},
	check = function(targ_power, n)
		return tool.inventory_power(targ_power, nil, n) == n
	end
}

property "tool.inventory_power: nil if default and list nil" {
	generators = { 
		int(1, enum.power.MAX),
	},
	numtests = 1,
	check = function(targ_power)
		return tool.inventory_power(targ_power) == nil
	end
}
