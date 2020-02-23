local tiny = require("lib.tiny")

local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local bestiary = require("core.bestiary")
local summon = require("core.summon")
local light = require("core.system.light")
local decide = require("core.system.decide")
local health = require("core.system.health")
local move = require("core.system.move")
local tool = require("core.system.tool")
local morph = require("core.system.morph")
local gen = require("core.gen")

local act = require("core.act")

local setup = {}

function setup.make_system_list(ui)
	return {
		light.make_system(),
		ui.make_system(),
		decide.make_system(),
		health.make_system(),
		move.make_system(),
		tool.make_system(),
		morph.make_system()
	}
end

function setup.from_state(w, state)
	w.state = state
	for _,v in pairs(w.state.terrain) do
		w.addEntity(w, v)
	end
	for _,v in pairs(w.state.denizens) do
		w.addEntity(w, v)
	end
end

function setup.gen_denizens(terrain, player_pos, player)
	local player = player or bestiary.make(enum.monster.player, player_pos)
	local res = {[player_pos] = player}
	player.pos = player_pos
	player.destination = player_pos
	local mock_world = {state={terrain=terrain, denizens=res}}
	for k in pairs(bestiary.set) do
		if k ~= enum.monster.player then
			summon.summon(mock_world, k)
		end
	end
	return res
end

function setup.gen_state(num, player)
	local res = {memory = {}, num = num}
	res.terrain, res.player_pos = gen.cave()
	res.denizens = setup.gen_denizens(res.terrain, res.player_pos, player)
	return res
end

function setup.clear_entities_except(w, except_set)
	for _,v in ipairs(w.entities) do
		if not except_set[v] then
			w.removeEntity(w, v)
		end
	end
end

function setup.exit_f(w, kill_save)
	setup.ui.shutdown(kill_save)
	if kill_save then
		setup.save.remove()
	else
		setup.save.save({
			enum_inverted = enum.inverted,
			bestiary_set = bestiary.set,
			state = w.state
		})
	end
	setup.raw_exit_f()
end

function setup.regen(w, num)
	local player = w.state.denizens[w.state.player_pos]
	setup.clear_entities_except(w, {[player] = true})
	setup.from_state(w, setup.gen_state(num, player))
end

function setup.world(ui, save, seed, raw_exit_f)
	setup.ui = ui
	setup.save = save
	setup.raw_exit_f = raw_exit_f

	math.randomseed(seed)
	decide.init(setup.exit_f, ui.get_input)
	health.init(setup.exit_f)
	move.init(setup.regen)


	local saved_data = save.load()
	
	local state
	if saved_data then
		enum.init(saved_data.enum_inverted)
		act.init()

		bestiary.set = saved_data.bestiary_set
		state = saved_data.state
	else
		bestiary.make_set()
		state = setup.gen_state(1)
	end

	local res = tiny.world(unpack(setup.make_system_list(ui)))
	setup.from_state(res, state)
	return res
end

return setup