--- Actions for `enum.power.mundane`
-- @module core.act.mundane

local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")
local move = require("core.system.move")
local say = require("core.system.say")

local msg = require("data.msg")

local mundane = {
	wander = {},
	pursue = {},
	flee = {},
	melee = {},
	MAX_MOVE = 4,
	MAX_MELEE = 5
}

mundane.export = {
	--- Wander action for mundane power
	-- @see act.action
	wander = mundane.wander,

	--- Pursue action for mundane power
	-- @see act.action
	pursue = mundane.pursue,


	--- Flee action for mundane power
	-- @see act.action
	flee = mundane.flee,


	--- Melee action for mundane power
	-- @see act.action
	melee = mundane.melee
}

function mundane.wander.possible(world, source, dummy_i)
	return #(move.options(world, source.pos)) > 0
end

function mundane.wander.utility(world, source, dummy_i)
	return mundane.wander.possible(world, source, dummy_i) and 1 or 0
end

function mundane.wander.attempt(world, source, dummy_i)
	local options = move.options(world, source.pos)
	local can_do = #(options) > 0
	if not can_do then return false end
	move.prepare(world, source, options[math.random(1, #options)])
	return true
end

function mundane.pursue.possible(world, source, target_i)
	return #(move.options(world, source.pos)) > 0
end

function mundane.pursue.utility(world, source, target_i)
	local n_options = #(move.options(world, source.pos))
	local h_ratio = (source.health.now/source.health.max)
	local lit = (world.state.light[target_i] and 1 or 0)
	return n_options * h_ratio * lit
end

local function move_failed(source)
	if source.decide == enum.decidemode.player then
		say.prepare(msg.bump)
	end
	return false
end

function mundane.pursue.attempt(world, source, target_i)
	if source.pos == target_i then
		return true
	end
	local min, min_i = grid.extreme_destination(source.pos, world.walk_paths[target_i])
	if min >= math.huge then
		return move_failed(source)
	end
	if grid.distance(source.pos, target_i) == 1 and min_i ~= target_i then
		return move_failed(source)
	end
	move.prepare(world, source, min_i)
	return true
end

function mundane.flee.possible(world, source, target_i)
	return #(move.options(world, source.pos)) > 0
end

function mundane.flee.utility(world, source, target_i)
	local n_options = #(move.options(world, source.pos))
	local h_ratio = (source.health.now/source.health.max)
	return n_options * (1 - h_ratio)
end

function mundane.flee.attempt(world, source, target_i)
	local max, max_i = grid.extreme_destination(source.pos, world.walk_paths[target_i], true)
	if max <= 0 then
		return false
	end
	move.prepare(world, source, max_i)
	return true
end

function mundane.melee.possible(world, source, target_i)
	if grid.distance(target_i, source.pos) ~= 1 then
		return false
	end
	local target = world.state.denizens[target_i]
	if target and health.is_alive(target.health) then
		return target
	else
		return false
	end
end

function mundane.melee.utility(world, source, target_i)
	local adj = (mundane.melee.possible(world, source, target_i) and 1 or 0)
	local h_ratio = (source.health.now/source.health.max)
	return adj * h_ratio * mundane.MAX_MELEE
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