local tiny = require("lib.tiny")
local grid = require("core.grid")
local enum = require("core.enum")

local morph = {}

function morph.smashable(terrain, denizens, pos)
	return (terrain[pos].kind == enum.tile.wall) and not denizens[pos]
end

function morph.smash_options(world, source_pos, directions_table)
	local options = {}
	for _,pos in grid.destinations(source_pos, directions_table) do
		if morph.smashable(world.state.terrain, world.state.denizens, pos) then
			table.insert(options, pos)
		end
	end
	return options
end

function morph.prepare(e, new_kind)
	e.new_kind = new_kind
end

function morph.process(system, e, dt)
	if e.new_kind then
		e.kind = e.new_kind
		e.new_kind = nil
		system.world.addEntity(system.world, e)
	end
end

function morph.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("kind")
	system.process = morph.process
	return system
end

return morph