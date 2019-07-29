local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local light = require("core.light")
local gen = require("core.gen")
local tool = require("core.tool")
local bestiary = require("core.bestiary")
local decide = require("core.decide")
local health = require("core.health")
local move = require("core.move")

local world = {}

local function basic_setup(ui, n)
	local res = tiny.world(
		light.make_system(),
		ui.make_system(),
		decide.make_system(),
		health.make_system(),
		move.make_system()
	)
	res.num = n
	return res
end

function world.restore(ui, stored)
	local res = basic_setup(ui, stored.num)
	res.player_pos = stored.player_pos
	res.terrain = stored.terrain
	res.denizens = stored.denizens
	for _,v in pairs(res.terrain) do
		res.addEntity(res, v)
	end
	for _,v in pairs(res.denizens) do
		res.addEntity(res, v)
	end
	res.regen = world.regen
	res.refresh(res)
	return res
end

function world.store(w)
	return {
		player_pos = w.player_pos,
		denizens = w.denizens,
		terrain = w.terrain,
		num = w.num,
	}
end

local function add_terrain(w)
	w.terrain = {}
	local terrain, player_pos = gen.cave()
	w.terrain = terrain
	for i,v in pairs(terrain) do
		w.addEntity(w, v)
	end
	return player_pos
end

local function add_monsters(w, player_pos)
	w.denizens = w.denizens or {}
	for k in pairs(bestiary.set) do
		if k ~= enum.monster.player then
			local x = math.random(1, grid.MAX_X)
			local y = math.random(1, grid.MAX_Y)
			local pos = grid.get_pos(x, y)
			if pos ~= player_pos then
				local dz = bestiary.make(k, pos)
				w.denizens[pos] = dz
				w.addEntity(w, dz)
			end
		end
	end
end

local function add_new_player(w, player_pos, player)
	w.denizens = w.denizens or {}
	local player = player or bestiary.make(enum.monster.player, player_pos)
	player.pos = player_pos
	player.destination = player_pos
	--tool.equip(player.inventory[1], player)
	w.player_pos = player_pos
	w.denizens[player_pos] = player
	w.addEntity(w, player)
end

function world.make(ui, n)
	local res = basic_setup(ui, n)
	local player_pos = add_terrain(res)
	add_new_player(res, player_pos)
	add_monsters(res, player_pos)
	res.regen = world.regen
	res.refresh(res)
	return res
end

function world.regen(w, n)
	local player = w.denizens[w.player_pos]
	for pos in grid.points() do
		w.removeEntity(w, w.terrain[pos])
		local dz = w.denizens[pos]
		if dz and dz ~= player then
			w.removeEntity(w, dz)
		end
	end
	w.denizens = {}
	w.terrain = {}
	w.memory = {}
	w.num = n
	local player_pos = add_terrain(w)
	add_new_player(w, player_pos, player)
	add_monsters(w, player_pos)
end

return world
