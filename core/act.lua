local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")

local act = {}

local function move_denizen(world, d, new_pos)
	assert(not world.denizens[new_pos], "Attempt to move denizen onto denizen")
	local old_pos = d.pos
	d.pos = new_pos
	world.denizens[old_pos] = nil
	world.denizens[d.pos] = d
	if d.decide == enum.decidemode.player then
		world.player_pos = d.pos
		if world.terrain[d.pos].kind == enum.terrain.stair then
			world.regen(world, world.num+1)
			return
		end
	end
	world.addEntity(world, d)
end

local mundane_wander = {}
function mundane_wander.options(world, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if not world.denizens[pos] and world.terrain[pos].kind == enum.terrain.floor then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane_wander.possible(world, source, dummy_i)
	return #(mundane_wander.options(world, source.pos)) > 0
end

function mundane_wander.utility(world, source, dummy_i)
	return mundane_wander.possible(world, source, dummy_i) and 1 or 0
end

function mundane_wander.attempt(world, source, dummy_i)
	local options = mundane_wander.options(world, source.pos)
	local can_do = #(options) > 0
	if not can_do then return false end
	move_denizen(world, source, options[math.random(1, #options)])
	return true
end

local mundane_pursue = {}
function mundane_pursue.options(paths, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if paths[pos] then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane_pursue.possible(world, source, target_i)
	local options = mundane_pursue.options(world.walk_paths[target_i], source.pos)
	return #options > 0
end

function mundane_pursue.utility(world, source, target_i)
	if mundane_pursue.possible(world, source, target_i) and world.light[target_i] then
		return grid.distance(source.pos, target_i)
	else
		return 0
	end
end

function mundane_pursue.attempt(world, source, target_i)
	if source.pos == target_i then
		return true
	end
	local min, min_i = grid.adjacent_extreme(source.pos, world.walk_paths[target_i])
	if min >= math.huge then
		return false
	end
	if grid.distance(source.pos, target_i) == 1 and min_i ~= target_i then
		return false
	end
	move_denizen(world, source, min_i)
	return true
end

local mundane_flee = {}
function mundane_flee.options(paths, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if paths[pos] then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane_flee.possible(world, source, target_i)
	if not world.light[target_i] then
		return false
	else
		local options = mundane_flee.options(world.walk_paths[target_i], source.pos)
		return #options > 0
	end
end

function mundane_flee.utility(world, source, target_i)
	if mundane_flee.possible(world, source, target_i) then
		return 1--grid.MAX_X + grid.MAX_Y - grid.distance(source.pos, target_i)
	else
		return 0
	end
end

function mundane_flee.attempt(world, source, target_i)
	if not world.light[target_i] then
		return false
	end
	local max, max_i = grid.adjacent_extreme(source.pos, world.walk_paths[target_i], true)
	if max <= 0 then
		return false
	end
	move_denizen(world, source, max_i)
	return true
end

function act.init()
	act[enum.power.mundane] = {
		wander = enum.selectf(enum.actmode, mundane_wander),
		pursue = enum.selectf(enum.actmode, mundane_pursue),
		flee = enum.selectf(enum.actmode, mundane_flee)
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()
