local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local flood = require("core.flood")
local proxy = require("core.proxy")

local move = {}

function move.walkable(terrain, denizens, pos)
	local terrain_kind = terrain[pos].kind
	local good_t = (terrain_kind == enum.tile.floor) or (terrain_kind == enum.tile.stair)
	return good_t and not denizens[pos]
end

function move.options(world, source_pos, directions_table)
	local options = {}
	for _,pos in grid.destinations(source_pos, directions_table) do
		if move.walkable(world.state.terrain, world.state.denizens, pos) then
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
			return move.walkable(system.world.state.terrain, system.world.state.denizens, pos)
		end)
	end)
end

function move.process(system, d, dt)
	local world = system.world

	if world.state.denizens[d.pos] == nil then return end

	world.state.denizens[d.pos] = nil
	world.state.denizens[d.destination] = d
	d.pos = d.destination
	if d.decide == enum.decidemode.player then
		world.state.player_pos = d.pos
		if world.state.terrain[d.pos].kind == enum.tile.stair then
			move.regen_f(world, world.state.num+1)
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

function move.init(regen_f)
	move.regen_f = regen_f
	return move
end

return move.init(function() end)