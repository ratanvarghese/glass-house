local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local flood = require("core.flood")
local proxy = require("core.proxy")

local move = {}

function move.walkable(world, pos)
	local terrain_kind = world.terrain[pos].kind
	local good_t = (terrain_kind == enum.terrain.floor) or (terrain_kind == enum.terrain.stair)
	return good_t and not world.denizens[pos]
end

function move.options(world, source_pos, directions_table)
	local options = {}
	for _,pos in grid.destinations(source_pos, directions_table) do
		if move.walkable(world, pos) then
			table.insert(options, pos)
		end
	end
	return options
end

function move.prepare(world, dz, new_pos)
	dz.destination = new_pos
end

function move.reset_paths(system)
	system.world.walk_paths = proxy.memoize(function(target)
		return flood.gradient(target, function(pos)
			return move.walkable(system.world, pos)
		end)
	end)
end

function move.process(system, d, dt)
	local world = system.world
	world.denizens[d.pos] = nil
	world.denizens[d.destination] = d
	d.pos = d.destination
	if d.decide == enum.decidemode.player then
		world.player_pos = d.pos
		if world.terrain[d.pos].kind == enum.terrain.stair then
			world.regen(world, world.num+1)
			return
		end
	end
	world.addEntity(world, d)
end

function move.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("destination", "pos")
	system.process = move.process
	system.preWrap = move.reset_paths --other systems may need walk_paths
	return system
end

return move