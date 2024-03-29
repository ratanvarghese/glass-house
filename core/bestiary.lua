--- Create monsters and manage monster species.
-- The actual procedural generation of monster species is handled by `core.power`.
-- @module core.bestiary

local base = require("core.base")
local enum = require("core.enum")
local clock = require("core.clock")
local toolkit = require("core.toolkit")
local power = require("core.power")

local bestiary = {}

--- Table of species.
-- Keys are from `enum.monster`. Values are species tables.
-- This table is populated by `bestiary.make_set`.
bestiary.set = {}

bestiary.set[enum.monster.player] = {
	inventory = {
		enum.tool.lantern
	},
	health = {
		max = 128
	},
	power = {
		[enum.power.tool] = power.DEFAULT
	},
	clock = clock.make(clock.scale.PLAYER),
	decide = enum.decidemode.player
}

local labels = {
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

local function make_species(i, power)
	local t = {}
	t.power = base.copy(power)
	t.clock = clock.make(math.random(1, clock.scale.MAX))
	t.health = {max = i*5}
	t.decide = enum.decidemode.monster
	if t.power[enum.power.cold] then
		t.display = t.display or {}
		t.display[enum.display.cold] = true
	end
	if t.power[enum.power.hot] then
		t.display = t.display or {}
		t.display[enum.display.hot] = true
		t.power[enum.power.light] = 1
	end
	if t.power[enum.power.tool] or t.power[enum.power.steal] then
		t.inventory = {}
	end
	return t
end

--- Procedurally generate species.
-- Run at the start of a new game.
-- @see core.power.make_all
function bestiary.make_set()
	for k=enum.monster.MAX_STATIC,enum.monster.MAX do
		bestiary.set[k] = nil
	end
	local n_enum_inverted = base.copy(enum.inverted)
	n_enum_inverted.monster = base.copy(enum.default_inverted.monster)
	enum.init(n_enum_inverted)

	local power_set = power.make_all()
	for i,v in ipairs(power_set) do
		local k = enum.new_item(enum.monster, labels[i])
		bestiary.set[k] = make_species(i, v)
	end
end

--- Create an individual monster
-- @tparam enum.monster kind
-- @tparam grid.pos pos
function bestiary.make(kind, pos)
	local species = bestiary.set[kind]
	local res = base.copy(species)
	assert(species, "Species not found")
	res.kind = kind
	res.pos = pos
	res.destination = pos
	res.health.now = res.health.max
	res.power[enum.power.mundane] = power.DEFAULT
	res.inventory = res.inventory and {} or nil
	if species.inventory then
		for i,v in ipairs(species.inventory) do
			table.insert(res.inventory, toolkit.make(v))
		end
		res.usetool = {}
	end
	return res
end

return bestiary
