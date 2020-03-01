--- Setup game core
-- @module core.setup

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

--- Makes ordered lists of systems that run during each turn.
-- @tparam tiny.system ui UI system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
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

--- Set up world `w` from state table.
-- @tparam tiny.world w, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
-- @tparam table state
function setup.from_state(w, state)
	w.state = state
	for _,v in pairs(w.state.terrain) do
		w.addEntity(w, v)
	end
	for _,v in pairs(w.state.denizens) do
		w.addEntity(w, v)
	end
end

--- Generate all monsters on a level.
-- @tparam {[grid.pos]={},...} terrain values are terrain entities
-- @tparam grid.pos player_pos
-- @tparam[opt] table player the player entity: if omitted, a new one will be generated
-- @treturn {[grid.pos]={},...} values are monster entities
-- @see summon.summon
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

--- Procedurally generate a level state.
-- @tparam int num the level number
-- @tparam[opt] table player the player entity: if omitted, a new one will be generated
function setup.gen_state(num, player)
	local res = {memory = {}, num = num}
	res.terrain, res.player_pos = gen.cave()
	res.denizens = setup.gen_denizens(res.terrain, res.player_pos, player)
	return res
end

--- Clear all entities from the world, except for those in given set.
-- @tparam tiny.world w see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
-- @tparam {{}=bool} except_set keys are entities to keep in the world, values are `true`
function setup.clear_entities_except(w, except_set)
	for _,v in ipairs(w.entities) do
		if not except_set[v] then
			w.removeEntity(w, v)
		end
	end
end

--- Cleanup before play session ends
-- @tparam tiny.world w see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
-- @tparam bool kill_save truthy if player died.
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

--- Dispose of old level, generate a new level
-- @tparam tiny.world w see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
-- @tparam int num level number for new level
function setup.regen(w, num)
	local player = w.state.denizens[w.state.player_pos]
	setup.clear_entities_except(w, {[player] = true})
	setup.from_state(w, setup.gen_state(num, player))
end

--- Setup the game core
-- @tparam tiny.system ui UI system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/).
-- @tparam func save takes the game state as input, and saves it
-- @tparam int seed seed for the RNG
-- @tparam func raw_exit_f terminates app (does not need to repeat tasks in `ui.shutdown`)
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