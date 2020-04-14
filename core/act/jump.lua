--- Actions for `enum.power.jump`
-- @module core.act.jump

local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local mundane = require("core.act.mundane")
local move = require("core.system.move")
local health = require("core.system.health")
local say = require("core.system.say")

local msg = require("data.msg")

local jump = {
	wander = {},
	pursue = {},
	flee = {},
	ranged = {},
	dlist = {
		{x = 1, y = -2},
		{x = 1, y = 2},
		{x = -1, y = -2},
		{x = -1, y = 2},
		{x = 2, y = -1},
		{x = 2, y = 1},
		{x = -2, y = -1},
		{x = -2, y = 1},
	}
}

jump.export = {
	--- Wander action for jump power
	-- @see act.action
	wander = jump.wander,

	--- Pursue action for jump power
	-- @see act.action
	pursue = jump.pursue,


	--- Flee action for jump power
	-- @see act.action
	flee = jump.flee,


	--- Ranged action for jump power
	-- @see act.action
	ranged = jump.ranged
}

local function jump_options(world, source)
	return move.options(world, source.pos, jump.dlist)
end

local function ranged_destination(world, source, target_pos)
	local target = world.state.denizens[target_pos]
	local options = jump_options(world, source)
	local src_distance = grid.distance(source.pos, target_pos)
	if not target or not health.is_alive(target.health) then
		return false
	elseif #options <= 0 then
		return false
	elseif src_distance ~= 1 and src_distance ~= 2 then
		return false
	end
	for _,dest in pairs(options) do
		local dest_distance = grid.distance(dest, target_pos)
		if dest_distance == 1 or dest_distance == 2 then
			return true, dest, target
		end
	end
	return false
end

function jump.wander.possible(world, source, dummy_pos)
	return #(jump_options(world, source)) > 0
end

function jump.wander.utility(world, source, dummy_pos)
	if #(jump_options(world, source)) > 0 then
		return mundane.MAX_MOVE + 1
	else
		return 0
	end
end

function jump.wander.attempt(world, source, dummy_pos)
	local options = jump_options(world, source)
	if #options > 0 then
		move.prepare(world, source, options[math.random(1, #options)])
		return true
	else
		return false
	end
end

function jump.pursue.possible(world, source, target_pos)
	return #(jump_options(world, source)) > 0
end

function jump.pursue.utility(world, source, target_pos)
	local n_options = #(jump_options(world, source))
	if n_options <= 0 then
		return 0
	else
		local h_ratio = (source.health.now/source.health.max)
		local lit = (world.state.light[target_pos] and 1 or 0)
		return (mundane.MAX_MOVE + (n_options * h_ratio)) * lit
	end
end

function jump.pursue.attempt(world, source, target_pos)
	local paths = world.walk_paths[target_pos]
	local min, min_pos = grid.extreme_destination(source.pos, paths, false, jump.dlist)
	if min >= math.huge then
		return false
	else
		move.prepare(world, source, min_pos)
		return true
	end
end

function jump.flee.possible(world, source, target_pos)
	return #(jump_options(world, source)) > 0
end

function jump.flee.utility(world, source, target_pos)
	local n_options = #(jump_options(world, source))
	if n_options <= 0 then
		return 0
	else
		local h_ratio = (source.health.now/source.health.max)
		return mundane.MAX_MOVE + (n_options * (1 - h_ratio))
	end
end

function jump.flee.attempt(world, source, target_pos)
	local paths = world.walk_paths[target_pos]
	local max, max_pos = grid.extreme_destination(source.pos, paths, true, jump.dlist)
	if max <= -math.huge then
		return false
	else
		move.prepare(world, source, max_pos)
		return true
	end
end

function jump.ranged.possible(world, source, target_pos)
	return ranged_destination(world, source, target_pos)
end

function jump.ranged.utility(world, source, target_pos)
	local possible = (jump.ranged.possible(world, source, target_pos) and 1 or 0)
	local h_ratio = (source.health.now/source.health.max)
	local lit = (world.state.light[target_pos] and 1 or 0)
	return (mundane.MAX_MELEE + (8 * h_ratio)) * lit * possible
end

function jump.ranged.attempt(world, source, target_pos)
	--[[
		Long ago, when I was a small child, I visited a friend's house
		and we played chess. His knight jumped over one of my pieces, and he
		took the piece off the board. I don't remember the exact words of the
		conversation that followed, but it went something like this...

		"Knights don't kill pieces they jump over," I said.
		"Yes they do," my friend responded.
		"No they don't," I said.
		"My dad says they do. Do you want to ask my dad about it?" he said.

		As it happened, I did not want to ask his dad about it, so I didn't inquire
		further. I tried to move my pieces around the board with this "house rule"
		in mind until I needed my knight to jump over one of my own pieces.

		"If I jump over my own piece, will it die?" I said.
		"It can, but only if you want it to," my friend responded.

		As it happened, I didn't want it to.
	--]]
	local possible, dest, target = ranged_destination(world, source, target_pos)
	if not possible then
		return false
	end
	move.prepare(world, source, dest)
	target.health.now = target.health.now - 2
	say.prepare(msg.jump_over, {target.pos})
	return true
end

return jump