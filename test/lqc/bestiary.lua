local grid = require("src.grid")
local base = require("src.base")
local enum = require("src.enum")
local tool = require("src.tool")
local bestiary = require("src.bestiary")

bestiary.set.centurion = {
	kind = 100,
	hp = 200,
	inventory = {
		"lantern"
	},
	powers = {
		[enum.power.light] = 10
	},
}

bestiary.set.gladiator = {
	kind = 101,
	hp = 400
}

local test_names = {"centurion", "gladiator"}

property "bestiary.make: x, y match input" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_names) },
	check = function(x, y, name_i)
		local name = test_names[name_i] 
		local res = bestiary.make(name, x, y)
		return res.x == x and res.y == y
	end
}

property "bestiary.make: simple properties match" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_names) },
	check = function(x, y, name_i)
		local name = test_names[name_i]
		local res = bestiary.make(name, x, y)
		for k,v in pairs(bestiary.set[name]) do
			if k ~= "inventory" and not base.equals(res[k], v) then
				print(k, res[k], v)
				return false
			end
		end
		return true
	end
}

property "bestiary.make: inventory are tool objects" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, #test_names) },
	check = function(x, y, name_i)
		local name = test_names[name_i]
		local res = bestiary.make(name, x, y)
		if bestiary.set[name].inventory then
			for i,v in ipairs(bestiary.set[name].inventory) do
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
