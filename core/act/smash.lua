--- Actions for `enum.power.smash`
-- @module core.act.smash

local grid = require("core.grid")
local enum = require("core.enum")
local morph = require("core.system.morph")
local mundane = require("core.act.mundane")

local smash = {
	--- Wander action for smash power
	-- @see act.action
	wander = {},


	--- Pursue action for smash power
	-- @see act.action
	pursue = {}
}

local function next_step(source_i, target_i)
	local line = grid.line(source_i, target_i)
	return line[2]
end

function smash.wander.possible(world, source, target_i)
	return #(morph.smash_options(world, source.pos)) > 0
end

function smash.wander.utility(world, source, target_i)
	return smash.wander.possible(world, source, target_i) and 2 or 0
end

function smash.wander.attempt(world, source, target_i)
	local options = morph.smash_options(world, source.pos)
	local can_do = #(options) > 0
	if not can_do then return false end
	morph.prepare(world.state.terrain[options[math.random(1, #options)]], enum.tile.floor)
	return true
end


function smash.pursue.possible(world, source, target_i)
	local step = next_step(source.pos, target_i)
	if step and morph.smashable(world.state.terrain, world.state.denizens, step) then
		return step
	else
		return false
	end
end

function smash.pursue.utility(world, source, target_i)
	local step = (smash.pursue.possible(world, source, target_i) and 1 or 0)
	local lit = (world.state.light[target_i] and 1 or 0)
	local h_ratio = (source.health.now/source.health.max)
	return step * lit * h_ratio * mundane.MAX_MOVE
end

function smash.pursue.attempt(world, source, target_i)
	local step = smash.pursue.possible(world, source, target_i)
	if step then
		morph.prepare(world.state.terrain[step], enum.tile.floor)
		return true
	else
		return false
	end
end

return smash