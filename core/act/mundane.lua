local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.health")

local act_common = require("core.act.common")

local mundane = {wander = {}, pursue = {}, flee = {}, melee = {}}

function mundane.wander.options(world, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if not world.denizens[pos] and world.terrain[pos].kind == enum.terrain.floor then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane.wander.possible(world, source, dummy_i)
	return #(mundane.wander.options(world, source.pos)) > 0
end

function mundane.wander.utility(world, source, dummy_i)
	return mundane.wander.possible(world, source, dummy_i) and 1 or 0
end

function mundane.wander.attempt(world, source, dummy_i)
	local options = mundane.wander.options(world, source.pos)
	local can_do = #(options) > 0
	if not can_do then return false end
	act_common.move_denizen(world, source, options[math.random(1, #options)])
	return true
end

function mundane.pursue.options(paths, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if paths[pos] then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane.pursue.possible(world, source, target_i)
	local options = mundane.pursue.options(world.walk_paths[target_i], source.pos)
	return #options > 0
end

function mundane.pursue.utility(world, source, target_i)
	if mundane.pursue.possible(world, source, target_i) and world.light[target_i] then
		return grid.distance(source.pos, target_i)
	else
		return 0
	end
end

function mundane.pursue.attempt(world, source, target_i)
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
	act_common.move_denizen(world, source, min_i)
	return true
end

function mundane.flee.options(paths, source_pos)
	local options = {}
	for _,pos in grid.destinations(source_pos) do
		if paths[pos] then
			table.insert(options, pos)
		end
	end
	return options
end

function mundane.flee.possible(world, source, target_i)
	if not world.light[target_i] then
		return false
	else
		local options = mundane.flee.options(world.walk_paths[target_i], source.pos)
		return #options > 0
	end
end

function mundane.flee.utility(world, source, target_i)
	if mundane.flee.possible(world, source, target_i) then
		return 1--grid.MAX_X + grid.MAX_Y - grid.distance(source.pos, target_i)
	else
		return 0
	end
end

function mundane.flee.attempt(world, source, target_i)
	if not world.light[target_i] then
		return false
	end
	local max, max_i = grid.adjacent_extreme(source.pos, world.walk_paths[target_i], true)
	if max <= 0 then
		return false
	end
	act_common.move_denizen(world, source, max_i)
	return true
end

function mundane.melee.possible(world, source, target_i)
	if grid.distance(target_i, source.pos) ~= 1 then
		return false
	else
		local target = world.denizens[target_i]
		if target and health.is_alive(target.health) then
			return target
		else
			return false
		end
	end
end

function mundane.melee.utility(world, source, target_i)
	local target = mundane.melee.possible(world, source, target_i)
	return target and 2 or 0
end

function mundane.melee.attempt(world, source, target_i)
	local target = mundane.melee.possible(world, source, target_i)
	if target then
		target.health.now = target.health.now - 1
		return true
	else
		return false
	end
end

return mundane