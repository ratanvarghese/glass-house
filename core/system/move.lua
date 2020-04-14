--- System to manage entity movement
-- @module core.system.move

local tiny = require("lib.tiny")

local enum = require("core.enum")
local grid = require("core.grid")
local flood = require("core.flood")
local proxy = require("core.proxy")
local say = require("core.system.say")

local msg = require("data.msg")

local move = {}

--- Check if terrain at a given position can be walked upon
-- @tparam {[grid.pos]=table,...} terrain
-- @tparam {[grid.pos]=table,...} denizens
-- @tparam grid.pos pos
-- @treturn bool  
function move.walkable(terrain, denizens, pos)
	local terrain_kind = terrain[pos].kind
	local good_t = (terrain_kind == enum.tile.floor) or (terrain_kind == enum.tile.stair)
	return good_t and not denizens[pos]
end

--- Return list of nearby points with walkable terrain
-- @tparam tiny.world world
-- @tparam grid.pos source_pos
-- @tparam[opt] {[any]=grid.vector,...} directions_table (passed to `grid.destinations`)
function move.options(world, source_pos, directions_table)
	local options = {}
	for _,pos in grid.destinations(source_pos, directions_table) do
		if move.walkable(world.state.terrain, world.state.denizens, pos) then
			table.insert(options, pos)
		end
	end
	return options
end

--- Prepare an entity for an upcoming move
-- @tparam tiny.world world see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
-- @tparam table dz monster entity
-- @tparam grid.pos new_pos new position for entity
function move.prepare(world, dz, new_pos)
	dz.destination = new_pos
end

--- Reset cached walking paths table
-- @tparam tiny.system system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function move.reset_paths(system)
	system.world.walk_paths = proxy.memoize(function(target)
		return flood.gradient(target, function(pos)
			return move.walkable(system.world.state.terrain, system.world.state.denizens, pos)
		end)
	end)
end

--- Stick the target entity to the source
-- @tparam table source sticky source entity
-- @tparam table targ stuck target entity
function move.stick(source, targ)
	targ.relations = targ.relations or {}
	targ.relations[enum.relations.stuck_to] = source
end

--- Check if monster is (still) stuck
-- @tparam {[grid.pos]=table,...} denizens
-- @tparam table stuck_dz
-- @treturn bool
function move.is_stuck(denizens, stuck_dz)
	local relations = stuck_dz.relations or {}
	local sticky_dz = relations[enum.relations.stuck_to]
	if not sticky_dz then
		return false
	elseif denizens[sticky_dz.pos] ~= sticky_dz then
		return false
	elseif grid.distance(stuck_dz.pos, sticky_dz.pos) > 1 then
		return false
	else
		return true
	end
end

local function player_check(world, d)
	if d.decide == enum.decidemode.player then
		world.state.player_pos = d.pos
		if world.state.terrain[d.pos].kind == enum.tile.stair then
			move.regen_f(world, world.state.num+1)
			return true
		end
	end
	return false
end

--- Process system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function move.process(system, d, dt)
	local world = system.world
	local denizens = world.state.denizens

	if denizens[d.pos] == nil then return end

	if move.is_stuck(denizens, d) then
		say.prepare(msg.stuck, {d.pos})
		return
	elseif d.relations then
		d.relations[enum.relations.stuck_to] = nil
	end

	local old_pos = d.pos
	local other_d = denizens[d.destination]
	denizens[d.pos], denizens[d.destination] = other_d, d
	d.pos = d.destination
	if other_d and old_pos ~= d.pos then
		say.prepare(msg.displace, {other_d.destination})
		other_d.pos = old_pos
		other_d.destination = old_pos
		if player_check(world, other_d) then
			return
		end
	end
	if player_check(world, d) then
		return
	end
	
	world.addEntity(world, d)
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function move.make_system()
	local system = tiny.processingSystem()
	system.filter = tiny.requireAll("destination", "pos")
	system.process = move.process
	system.preWrap = move.reset_paths --other systems may need walk_paths
	return system
end


--- Initialize callbacks for `core.system.move` module
-- @tparam func regen_f new level callback
-- @treturn table `core.system.move` module
function move.init(regen_f)
	move.regen_f = regen_f
	return move
end

return move.init(function() end)