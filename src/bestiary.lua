local base = require("src.base")
local tool = require("src.tool")

local bestiary = {
	set = {}
}

bestiary.set.angel = {
	symbol = base.symbols.angel,
	light_radius = 2,
	hp = 10
}

bestiary.set.dragon = {
	symbol = base.symbols.dragon,
	hp = 20
}

bestiary.set.player = {
	symbol = base.symbols.player,
	hp = 1000,
	light_radius = 0,
	inventory = {
		"lantern"
	}
}

function bestiary.make(name, x, y)
	local species = bestiary.set[name]
	local res = {
		symbol = species.symbol,
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
