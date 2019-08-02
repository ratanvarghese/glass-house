local base = require("core.base")
local enum = require("core.enum")
local toolkit = require("core.toolkit")

property "toolkit.make: copies template" {
	generators = { tbl() },
	check = function(t)
		local old_set = toolkit.set
		t.kind = 100
		toolkit.set[t.kind] = {
			template = t,
			equip = function() end
		}

		local obj = toolkit.make(t.kind)
		toolkit.set = old_set
		return base.equals(t, obj) and t ~= obj
	end
}

property "toolkit.equip: calls tool's equip function" {
	generators = { int() },
	check = function(kind)
		local old_set = toolkit.set
		local called_equip = false
		toolkit.set[kind] = {
			template = {kind = kind},
			equip = function() called_equip = true end
		}
		local obj = toolkit.make(kind)
		toolkit.equip(obj)
		toolkit.set = old_set
		return called_equip
	end
}

property "toolkit.equip: does not call wrong equip function" {
	generators = { int(), int() },
	check = function(kind1, kind2)
		local old_set = toolkit.set
		if kind2 == kind1 then
			kind2 = kind2 + 1
		end
		local called_equip = false
		toolkit.set[kind1] = {
			template = {kind = kind1},
			equip = function() end
		}
		toolkit.set[kind2] = {
			template = {kind = kind2},
			equip = function() called_equip = true end
		}
		local obj = toolkit.make(kind1)
		toolkit.equip(obj)
		toolkit.set = old_set
		return not called_equip
	end
}

property "toolkit.inventory_power: return max" {
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
		local res = toolkit.inventory_power(targ_power, list, default)
		return res == math.max(default, unpack(vlist))
	end
}

property "toolkit.inventory_power: use default on nil list" {
	generators = { 
		int(1, enum.power.MAX),
		int()
	},
	check = function(targ_power, n)
		return toolkit.inventory_power(targ_power, nil, n) == n
	end
}

property "toolkit.inventory_power: nil if default and list nil" {
	generators = { 
		int(1, enum.power.MAX),
	},
	numtests = 1,
	check = function(targ_power)
		return toolkit.inventory_power(targ_power) == nil
	end
}
