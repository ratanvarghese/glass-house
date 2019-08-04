local tiny = require("lib.tiny")

local base = require("core.base")
local enum = require("core.enum")

local health = {}

function health.clip(t)
	t.now = base.clip(t.now, 0, t.max)
	return t
end

function health.is_alive(t)
	return t.now > 0
end

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

function health.init(exit_f)
	health.exit = exit_f
	return health
end

function health.process(system, e, dt)
	health.clip(e.health)
	if not health.is_alive(e.health) then
		health.kill(system, e)
	end
end

function health.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("health")
	system.process = health.process
	return system
end

return health.init(function() end)
