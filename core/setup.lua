local tiny = require("lib.tiny")

local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local bestiary = require("core.bestiary")
local light = require("core.light")
local decide = require("core.decide")
local health = require("core.health")
local move = require("core.move")
local gen = require("core.gen")

local setup = {}

function setup.make_system_list(ui)
	return {
		light.make_system(),
		ui.make_system(),
		decide.make_system(),
		health.make_system(),
		move.make_system()
	}
end

function setup.pickle_world(w)
	return {
		player_pos = w.player_pos,
		denizens = w.denizens,
		terrain = w.terrain,
		memory = w.memory,
		num = w.num,
	}
end

function setup.unpickle_world(w, pickle_t)
	w.player_pos = pickle_t.player_pos
	w.terrain = pickle_t.terrain
	w.denizens = pickle_t.denizens
	w.memory = pickle_t.memory
	w.num = pickle_t.num
	for _,v in pairs(w.terrain) do
		w.addEntity(w, v)
	end
	for _,v in pairs(w.denizens) do
		w.addEntity(w, v)
	end
end

function setup.gen_denizens(terrain, player_pos, player)
	local player = player or bestiary.make(enum.monster.player, player_pos)
	local res = {[player_pos] = player}
	player.pos = player_pos
	player.destination = player_pos
	for k in pairs(bestiary.set) do
		if k ~= enum.monster.player then
			local pos
			repeat
				local x = math.random(1, grid.MAX_X)
				local y = math.random(1, grid.MAX_Y)
				pos = grid.get_pos(x, y)
			until (move.walkable(terrain, res, pos))
			res[pos] = bestiary.make(k, pos)
		end
	end
	return res
end

function setup.gen_pickle_t(num, player)
	local terrain, player_pos = gen.cave()
	local denizens = setup.gen_denizens(terrain, player_pos, player)
	return {
		player_pos = player_pos,
		denizens = denizens,
		terrain = terrain,
		memory = {},
		num = num
	}
end

function setup.clear_entities_except(w, except_set)
	for _,v in ipairs(w.entities) do
		if not except_set[v] then
			w.removeEntity(w, v)
		end
	end
end

function setup.exit_f(w, kill_save)
	setup.ui.shutdown()
	if kill_save then
		setup.save.remove()
	else
		setup.save.save({
			enum_inverted = enum.inverted,
			bestiary_set = bestiary.set,
			world = setup.pickle_world(w)
		})
	end
	setup.raw_exit_f()
end

function setup.regen(w, num)
	local player = w.denizens[w.player_pos]
	setup.clear_entities_except(w, {[player] = true})
	setup.unpickle_world(w, setup.gen_pickle_t(num, player))
end

function setup.world(ui, save, seed, raw_exit_f)
	setup.ui = ui
	setup.save = save
	setup.raw_exit_f = raw_exit_f

	math.randomseed(seed)
	decide.init(setup.exit_f, ui.get_input)
	health.init(setup.exit_f)
	move.init(setup.regen)

	local state = save.load()
	local pickle_t
	if state then
		enum.init(state.enum_inverted)
		bestiary.set = state.bestiary_set
		pickle_t = state.world
	else
		bestiary.make_set()
		pickle_t = setup.gen_pickle_t(1)
	end

	local res = tiny.world(unpack(setup.make_system_list(ui)))
	setup.unpickle_world(res, pickle_t)
	return res
end

return setup