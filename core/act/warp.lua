local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local mundane = require("core.act.mundane")
local move = require("core.system.move")
local health = require("core.system.health")

local warp = {
	wander = {},
	pursue = {},
	flee = {},
	ranged = {}
}

function warp.make_dlist(warp_factor)
	return {
		{x = 0, y = -warp_factor},
		{x = 0, y = warp_factor},
		{x = -warp_factor, y = 0},
		{x = warp_factor, y = 0}
	}
end

local function warp_options(world, source)
	local warp_factor = source.power[enum.power.warp]
	if warp_factor then
		return move.options(world, source.pos, warp.make_dlist(warp_factor))
	else
		return {}
	end
end

local function ranged_calc(world, source, target_pos)
	local warp_factor = source.power[enum.power.warp]
	if not warp_factor then
		return false
	end
	local target = world.state.denizens[target_pos]
	if not target or not health.is_alive(target.health) then
		return false
	end
	local src_x, src_y = grid.get_xy(source.pos)
	local targ_x, targ_y = grid.get_xy(target_pos)
	local diff_x = src_x - targ_x
	local diff_y = src_y - targ_y
	local across_x = (src_y == targ_y) and math.abs(diff_x) < warp_factor
	local across_y = (src_x == targ_x) and math.abs(diff_y) < warp_factor
	if not (across_x or across_y) then
		return false
	end

	local dest_x, dest_y
	if diff_x > 0 then
		dest_x = src_x - warp_factor
		dest_y = src_y
	elseif diff_x < 0 then
		dest_x = src_x + warp_factor
		dest_y = src_y
	elseif diff_y > 0 then
		dest_x = src_x
		dest_y = src_y - warp_factor
	elseif diff_y < 0 then
		dest_x = src_x
		dest_y = src_y + warp_factor
	else
		return false
	end

	if dest_x < 1 or dest_x > grid.MAX_X or dest_y < 1 or dest_y > grid.MAX_Y then
		return false
	end

	local dest = grid.get_pos(dest_x, dest_y)
	return move.walkable(world.state.terrain, world.state.denizens, dest), dest, target
end

function warp.wander.possible(world, source, dummy_i)
	return #(warp_options(world, source)) > 0
end

function warp.wander.utility(world, source, dummy_i)
	if #(warp_options(world, source)) > 0 then
		return mundane.MAX_MOVE + 1
	else
		return 0
	end
end

function warp.wander.attempt(world, source, dummy_i)
	local options = warp_options(world, source)
	if base.is_empty(options) then
		return false
	else
		source.destination = options[math.random(1, #options)]
		return true
	end
end

function warp.pursue.possible(world, source, target_pos)
	return #(warp_options(world, source)) > 0
end

function warp.pursue.utility(world, source, target_pos)
	local n_options = #(warp_options(world, source))
	if n_options <= 0 then
		return 0
	else
		local h_ratio = (source.health.now/source.health.max)
		local lit = (world.state.light[target_pos] and 1 or 0)
		return (mundane.MAX_MOVE + (n_options * h_ratio)) * lit
	end
end

function warp.pursue.attempt(world, source, target_pos)
	local warp_factor = source.power[enum.power.warp]
	if not warp_factor then
		return false
	end
	local dlist = warp.make_dlist(warp_factor)
	local paths = world.walk_paths[target_pos]
	local min, min_pos = grid.extreme_destination(source.pos, paths, false, dlist)
	if min >= math.huge then
		return false
	else
		move.prepare(world, source, min_pos)
		return true
	end
end

function warp.flee.possible(world, source, target_pos)
	return #(warp_options(world, source)) > 0
end

function warp.flee.utility(world, source, target_pos)
	local n_options = #(warp_options(world, source))
	if n_options <= 0 then
		return 0
	else
		local h_ratio = (source.health.now/source.health.max)
		return mundane.MAX_MOVE + (n_options * (1 - h_ratio))
	end
end

function warp.flee.attempt(world, source, target_pos)
	local warp_factor = source.power[enum.power.warp]
	if not warp_factor then
		return false
	end
	local dlist = warp.make_dlist(warp_factor)
	local paths = world.walk_paths[target_pos]
	local max, max_pos = grid.extreme_destination(source.pos, paths, true, dlist)
	if max <= -math.huge then
		return false
	else
		move.prepare(world, source, max_pos)
		return true
	end
end

function warp.ranged.possible(world, source, target_pos)
	return ranged_calc(world, source, target_pos)
end

function warp.ranged.utility(world, source, target_pos)
	local possible = (warp.ranged.possible(world, source, target_pos) and 1 or 0)
	local lit = (world.state.light[target_pos] and 1 or 0)
	local h_ratio = (source.health.now/source.health.max)
	return possible * lit * (h_ratio * mundane.MAX_MELEE + mundane.MAX_MELEE)
end

function warp.ranged.attempt(world, source, target_pos)
	local possible, dest, target = ranged_calc(world, source, target_pos)
	if not possible then
		return false
	end
	move.prepare(world, source, dest)
	target.health.now = target.health.now - 2
	return true
end

return warp