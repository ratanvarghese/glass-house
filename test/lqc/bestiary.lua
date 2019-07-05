local grid = require("src.grid")
local base = require("src.base")
local enum = require("src.enum")
local tool = require("src.tool")
local bestiary = require("src.bestiary")

local test_names = {"centurion", "gladiator"}
local test_kinds = {100, 101}

bestiary.set[test_kinds[1]] = {
	kind = test_kinds[1],
	name = test_names[1],
	hp = 200,
	inventory = {
		"lantern"
	},
	powers = {
		[enum.power.light] = 10
	},
}

bestiary.set[test_kinds[2]] = {
	kind = test_kinds[2],
	hp = 400,
	name = test_names[2]
}


property "bestiary.make: x, y match input" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_names) },
	check = function(x, y, kind_i)
		local res = bestiary.make(test_kinds[kind_i], x, y)
		return res.x == x and res.y == y
	end
}

property "bestiary.make: simple properties match" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, x, y)
		for k,v in pairs(bestiary.set[kind]) do
			if k ~= "inventory" and not base.equals(res[k], v) then
				return false
			end
		end
		return true
	end
}

property "bestiary.make: inventory are tool objects" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_kinds) },
	check = function(x, y, kind_i)
		local kind = test_kinds[kind_i]
		local res = bestiary.make(kind, x, y)
		if bestiary.set[kind].inventory then
			for i,v in ipairs(bestiary.set[kind].inventory) do
				local obj = tool.make(v)
				if not base.equals(res.inventory[i], obj) then
					return false
				end
			end
			return true
		else
			return base.is_empty(res.inventory)
		end
	end
}
