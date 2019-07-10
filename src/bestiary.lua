local base = require("src.base")
local enum = require("src.enum")
local time = require("src.time")
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

bestiary.set[enum.monster.player] = {
	kind = enum.monster.player,
	hp = 1000,
	inventory = {
		"lantern"
	},
	powers = {},
	name = "player",
	clock = time.make_clock(time.scale.PLAYER),
	display = {}
}

function bestiary.make_set()
	local power_set = power.make_all()
	for i,v in ipairs(power_set) do
		local name = bestiary.names[i]
		local t = {}
		t.powers = base.copy(v)
		t.kind = enum.new_item(enum.monster, name)
		t.hp = i * 5
		t.name = name
		t.clock = time.make_clock()
		t.display = {}

		if t.powers[enum.power.kick] then
			t.powers[enum.power.kick_strength] = math.random(1, i*3)
		end

		if t.powers[enum.power.punch] then
			t.powers[enum.power.punch_strength] = math.random(1, i)
		end

		if t.powers[enum.power.cold] then
			t.display[enum.display.cold] = true
		end

		if t.powers[enum.power.hot] then
			t.display[enum.display.hot] = true
			t.powers[enum.power.light] = 1
		end

		bestiary.set[t.kind] = t
	end
end

function bestiary.make(kind, x, y)
	local species = bestiary.set[kind]
	local res = {
		name = species.name,
		kind = species.kind,
		hp = species.hp,
		max_hp = species.hp,
		x = x,
		y = y,
		inventory = {},
		powers = base.copy(species.powers),
		clock = base.copy(species.clock),
		display = base.copy(species.display),
		countdowns = {},
		relations = {}
	}
	if species.inventory then
		for i,v in ipairs(species.inventory) do
			table.insert(res.inventory, tool.make(v))
		end
	end
	return res
end

return bestiary
