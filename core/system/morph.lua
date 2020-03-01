--- System to manage entities transforming into other entities
-- @module core.system.morph

local tiny = require("lib.tiny")
local grid = require("core.grid")
local enum = require("core.enum")

local morph = {}

--- Check if terrain at a given position can be smashed
-- @tparam {[grid.pos]=table,...} terrain
-- @tparam {[grid.pos]=table,...} denizens
-- @tparam grid.pos pos
-- @treturn bool  
function morph.smashable(terrain, denizens, pos)
	return (terrain[pos].kind == enum.tile.wall) and not denizens[pos]
end

--- Return list of nearby points with smashable terrain
-- @tparam tiny.world world
-- @tparam grid.pos source_pos
-- @tparam[opt] {[any]=grid.vector,...} directions_table (passed to `grid.destinations`)
function morph.smash_options(world, source_pos, directions_table)
	local options = {}
	for _,pos in grid.destinations(source_pos, directions_table) do
		if morph.smashable(world.state.terrain, world.state.denizens, pos) then
			table.insert(options, pos)
		end
	end
	return options
end

--- Prepare an entity for an upcoming transformation
-- @tparam table e
-- @tparam enum.monster new_kind
function morph.prepare(e, new_kind)
	e.new_kind = new_kind
end

--- Process system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function morph.process(system, e, dt)
	if e.new_kind then
		e.kind = e.new_kind
		e.new_kind = nil
		system.world.addEntity(system.world, e)
	end
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function morph.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("kind")
	system.process = morph.process
	return system
end

return morph