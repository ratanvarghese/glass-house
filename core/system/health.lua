--- System to check if monsters and player are alive
-- @module core.system.health

local tiny = require("lib.tiny")

local base = require("core.base")
local enum = require("core.enum")

local health = {}

--- Table containing entity's health data
-- @typedef health.data

--- Ensures current health is between zero and a maximum.
-- `t` is altered internally, and also returned
-- @tparam health.data t
-- @treturn health.data 
function health.clip(t)
	t.now = base.clip(t.now, 0, t.max)
	return t
end

--- Check if entity is alive
-- @tparam health.data t
-- @treturn bool
function health.is_alive(t)
	return t.now > 0
end


--- Kill entity
-- @tparam tiny.system system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @tparam table e entity
function health.kill(system, e)
	local world = system.world
	if e.decide == enum.decidemode.player then
		health.exit(world, true)
	else
		if e.inventory and #(e.inventory) > 0 and e.pos then
			local tile = world.state.terrain[e.pos]
			tile.inventory = tile.inventory or {}
			base.extend_arr(tile.inventory, ipairs(e.inventory))
		end
		system.world.removeEntity(system.world, e)
		system.world.state.denizens[e.pos] = nil
	end
end

--- Initialize callbacks for `core.system.health` module
-- @tparam func exit_f exit callback
-- @treturn table `core.system.health` module
function health.init(exit_f)
	health.exit = exit_f
	return health
end

--- Process system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function health.process(system, e, dt)
	health.clip(e.health)
	if not health.is_alive(e.health) then
		health.kill(system, e)
	end
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function health.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("health")
	system.process = health.process
	return system
end

return health.init(function() end)
