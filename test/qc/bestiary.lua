local grid = require("core.grid")
local base = require("core.base")
local enum = require("core.enum")
local power = require("core.power")
local tool = require("core.tool")
local bestiary = require("core.bestiary")

local test_kinds = {100, 101}

local test_set = {}
test_set[test_kinds[1]] = {
	health = {
		max = 200,
	},
	inventory = {
		enum.tool.lantern
	},
	power = {
		[enum.power.light] = 10,
	},
}

test_set[test_kinds[2]] = {
	health = {
		max = 400
	},
	power = {
	}
}


property "bestiary.make: pos, destination and kind match input" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local old_set = bestiary.set
		bestiary.set = test_set
		local pos = grid.get_pos(x, y)
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, pos)
		bestiary_set = old_set
		return res.pos == pos and res.destination == pos and res.kind == kind
	end
}

property "bestiary.make: simple components match" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local old_set = bestiary.set
		bestiary.set = test_set
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, grid.get_pos(x, y))
		local ignore_k = {inventory = true, health = true, power = true}
		for k,v in pairs(bestiary.set[kind]) do
			if not ignore_k[k] and not base.equals(res[k], v) then
				bestiary_set = old_set
				return false
			end
		end
		bestiary_set = old_set
		return true
	end
}

property "bestiary.make: health component" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local old_set = bestiary.set
		bestiary.set = test_set
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, grid.get_pos(x, y))
		local species = bestiary.set[kind]
		bestiary_set = old_set
		return res.health.now == res.health.max and res.health.max == species.health.max
	end
}

property "bestiary.make: power component" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local old_set = bestiary.set
		bestiary.set = test_set
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, grid.get_pos(x, y))
		local expected_power = base.copy(bestiary.set[kind].power)
		expected_power[enum.power.mundane] = power.DEFAULT
		bestiary_set = old_set
		return base.equals(res.power, expected_power)
	end
}

property "bestiary.make: inventory are tool objects" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local old_set = bestiary.set
		bestiary.set = test_set
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, grid.get_pos(x, y))
		if bestiary.set[kind].inventory then
			for i,v in ipairs(bestiary.set[kind].inventory) do
				local obj = tool.make(v)
				if not base.equals(res.inventory[i], obj) then
					bestiary_set = old_set
					return false
				end
			end
			bestiary_set = old_set
			return true
		else
			bestiary_set = old_set
			return not res.inventory or base.is_empty(res.inventory)
		end
	end
}
