local enum = require("src.enum")
local tool = require("src.tool")

local bestiary = {
	set = {}
}

bestiary.set.angel = {
	kind = enum.monster.angel,
	light_radius = 2,
	hp = 10
}

bestiary.set.dragon = {
	kind = enum.monster.dragon,
	hp = 20
}

bestiary.set.player = {
	kind = enum.monster.player,
	hp = 1000,
	light_radius = 0,
	inventory = {
		"lantern"
	}
}

function bestiary.make(name, x, y)
	local species = bestiary.set[name]
	local res = {
		kind = species.kind,
		hp = species.hp,
		light_radius = species.light_radius,
		x = x,
		y = y,
		inventory = {}
	}
	if species.inventory then
		for i,v in ipairs(species.inventory) do
			table.insert(res.inventory, tool.make(v))
		end
	end
	return res
end

return bestiary
