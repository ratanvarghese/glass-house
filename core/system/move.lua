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

function move.stick(source, targ)
	targ.relations = targ.relations or {}
	targ.relations[enum.relations.stuck_to] = source
end

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

function move.process(system, d, dt)
	local world = system.world
	local denizens = world.state.denizens

	if denizens[d.pos] == nil then return end

	if move.is_stuck(denizens, d) then
		return
	elseif d.relations then
		d.relations[enum.relations.stuck_to] = nil
	end

	local old_pos = d.pos
	local other_d = denizens[d.destination]
	denizens[d.pos], denizens[d.destination] = other_d, d
	d.pos = d.destination
	if other_d then
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