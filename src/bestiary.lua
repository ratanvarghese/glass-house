local base = require("src.base")
local enum = require("src.enum")
local tool = require("src.tool")
local power = require("src.power")

local bestiary = {
	set = {}
}

bestiary.names = {
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

bestiary.set.player = {
	kind = enum.monster.player,
	hp = 1000,
	light_radius = 0,
	inventory = {
		"lantern"
	}
}

function bestiary.make_set()
	local power_set = power.make_all()
	for i,v in ipairs(power_set) do
		local t = base.copy(v)
		local name = bestiary.names[i]
		t.kind = enum.new_item(enum.monster, name)
		t.hp = i * 5
		if t.passive.name == "light" then
			t.light_radius = t.passive.factor
		end
		bestiary.set[name] = t
	end
end

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
