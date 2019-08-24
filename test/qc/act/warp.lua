local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")
local health = require("core.system.health")

local mock = require("test.mock")

local function set_warp_unwalkable(w, src, pos, targ_pos, warp_factor)
	local dlist = act.make_warp_dlist(warp_factor)
	for _,v in grid.destinations(pos, dlist) do
		w.state.terrain[v] = {kind = enum.tile.tough_wall, pos=v}
	end
	w._setup_walk_paths(w, src.pos, targ_pos)
end

local function attempt_if_impossible(f)
	return function(seed, pos, warp_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.warp] = warp_factor}
		set_warp_unwalkable(w, src, pos, targ_pos, warp_factor)
		local success = f(enum.actmode.attempt, w, src, targ_pos)
		return not success and grid.distance(src.pos, src.destination) == 0 and src.pos == pos
	end
end

local function attempt_if_possible(f)
	return function(seed, x, y, warp_factor)
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local res = f(enum.actmode.attempt, w, src, targ_pos)
		local distance = grid.distance(src.pos, src.destination)
		return res and distance == warp_factor and src.pos == pos
	end
end

local function simple_possible(f)
	return function(seed, pos, warp_factor)
		local dlist = act.make_warp_dlist(warp_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.warp] = warp_factor}
		local res = f(enum.actmode.possible, w, src, targ_pos)
		for _,v in grid.destinations(pos, dlist) do
			if w.walk_paths[targ_pos][v] then
				return res
			end
		end
		return not res
	end
end

local function ranged_setup(seed, pos, warp_factor, force_line)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	if force_line then
		local targ_x, targ_y = grid.get_xy(targ_pos)
		local src_x, src_y = grid.get_xy(src.pos)
		if math.random(1, 2) == 1 then
			targ_pos = grid.get_pos(targ_x, src_y)
		else
			targ_pos = grid.get_pos(src_x, targ_y)
		end
	end
	src.power = {[enum.power.warp] = warp_factor}
	local targ_max = math.random(1, 10)
	local targ_now = math.random(1, targ_max) - 1  --Sometimes dead
	local targ = {pos = targ_pos, health=health.clip({now=targ_now, max=targ_max})}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.warp].wander: ignore target" {
	generators = {
		int(1, enum.actmode.MAX-1),
		any(),
		any(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(m, targ_1, targ_2, seed, pos)
		local f = act[enum.power.warp].wander
		local w_1, src_1 = mock.mini_world(seed, pos)
		local w_2, src_2 = mock.mini_world(seed, pos)
		math.randomseed(seed)
		local res_1 = f(m, w_1, src_1, targ_1)
		math.randomseed(seed)
		local res_2 = f(m, w_2, src_2, targ_2)
		return res_1 == res_2 and base.equals(w_1.state, w_2.state)
	end
}

property "act.make_warp_dlist: length" {
	generators = { int(2, 10) },
	check = function(warp_factor)
		local dlist = act.make_warp_dlist(warp_factor)
		return #dlist == 4
	end
}

property "act.make_warp_dlist: absolute x or y equals warp factor" {
	generators = { int(2, 10), int(1, 4) },
	check = function(warp_factor, i)
		local dlist = act.make_warp_dlist(warp_factor)
		local d = dlist[i]
		return math.abs(d.x) == warp_factor or math.abs(d.y) == warp_factor
	end
}

property "act.make_warp_dlist: x or y equals 0" {
	generators = { int(2, 10), int(1, 4) },
	check = function(warp_factor, i)
		local dlist = act.make_warp_dlist(warp_factor)
		local d = dlist[i]
		return d.x == 0 or d.y == 0
	end
}

property "act.make_warp_dlist: distinct values" {
	generators = { int(2, 10), int(1, 4), int(1, 4) },
	check = function(warp_factor, i1, i2)
		if i1 == i2 then
			return true
		else
			local dlist = act.make_warp_dlist(warp_factor)
			local d1, d2 = dlist[i1], dlist[i2]
			return d1.x ~= d2.x or d1.y ~= d2.y
		end
	end
}

property "act[enum.power.warp].wander: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1), int(2, 10) },
	check = function(check_utility, seed, x, y, warp_factor)
		local m = check_utility and enum.actmode.utility or enum.actmode.possible
		local pos = grid.get_pos(x, y)
		local w, src = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local res = act[enum.power.warp].wander(m, w, src)
		if check_utility then
			return res > act.MAX_MUNDANE_MOVE
		else
			return res
		end
	end
}

property "act[enum.power.warp].wander: attempt if obviously possible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1), int(2, 10) },
	check = function(seed, x, y, warp_factor)
		local pos = grid.get_pos(x, y)
		local w, src = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local success = act[enum.power.warp].wander(enum.actmode.attempt, w, src)
		local distance = grid.distance(src.destination, src.pos)
		return success and distance == warp_factor and src.pos == pos
	end
}

property "act[enum.power.warp].wander: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = attempt_if_impossible(act[enum.power.warp].wander)
}

property "act[enum.power.warp].pursue: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = simple_possible(act[enum.power.warp].pursue)
}

property "act[enum.power.warp].pursue: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local res = act[enum.power.warp].pursue(enum.actmode.utility, w, src, targ_pos)
		if w.state.light[targ_pos] then
			return res > act.MAX_MUNDANE_MOVE
		else
			return res <= 0
		end
	end
}

property "act[enum.power.warp].pursue: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2), int(2, 10) },
	check = attempt_if_possible(act[enum.power.warp].pursue)
}

property "act[enum.power.warp].pursue: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = attempt_if_impossible(act[enum.power.warp].pursue)
}

property "act[enum.power.warp].flee: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = simple_possible(act[enum.power.warp].flee)
}

property "act[enum.power.warp].flee: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local res = act[enum.power.warp].flee(enum.actmode.utility, w, src, targ_pos)
		return res > act.MAX_MUNDANE_MOVE
	end
}

property "act[enum.power.warp].flee: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2), int(2, 10) },
	check = attempt_if_possible(act[enum.power.warp].flee)
}

property "act[enum.power.warp].flee: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = attempt_if_impossible(act[enum.power.warp].flee)
}

property "act[enum.power.warp].ranged: possible, bounds check" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(1, 10) },
	check = function(seed, pos, warp_factor_multiplier)
		local warp_factor = math.max(grid.MAX_X, grid.MAX_Y) * warp_factor_multiplier
		local w, src, targ = ranged_setup(seed, pos, warp_factor, true)
		return not act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
	end
}

property "act[enum.power.warp].ranged: possible, only if pursue possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, true)
		if act[enum.power.warp].pursue(enum.actmode.possible, w, src, targ.pos) then
			return true
		else
			return not act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.warp].ranged: possible, only if correct distance" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, true)
		if (grid.distance(src.pos, targ.pos) < warp_factor) then
			return true
		else
			return not act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.warp].ranged: possible, only if straight line to target" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10), bool() },
	check = function(seed, pos, warp_factor, force_line)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, force_line)
		local src_x, src_y = grid.get_xy(src.pos)
		local targ_x, targ_y = grid.get_xy(targ.pos)
		if (src_x == targ_x) or (src_y == targ_y) then
			return true
		else
			return not act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.warp].ranged: possible, only if target is alive" {
	numtests = 1000, --Hard to catch this one
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, true)
		if health.is_alive(targ.health) then
			return true
		else
			return not act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.warp].ranged: obviously possible" {
	generators = { int(), int(2, 10), bool(), bool() },
	check = function(seed, warp_factor, far_edge, across_x)
		local pos
		if far_edge then
			pos = grid.get_pos(grid.MAX_X - 1, grid.MAX_Y - 1)
		else
			pos = grid.get_pos(2, 2)
		end
		local w, src = mock.mini_world(seed, pos, true)
		src.power = {[enum.power.warp] = warp_factor}
		local targ_x, targ_y
		if far_edge then
			if across_x then
				targ_x = math.random(grid.MAX_X - warp_factor, grid.MAX_X - 2)
				targ_y = grid.MAX_Y - 1
			else
				targ_x = grid.MAX_X - 1
				targ_y = math.random(grid.MAX_Y - warp_factor, grid.MAX_Y - 2)
			end
		else
			if across_x then
				targ_x = math.random(3, warp_factor)
				targ_y = 2
			else
				targ_x = 2
				targ_y = math.random(3, warp_factor)
			end
		end
		local targ_pos = grid.get_pos(targ_x, targ_y)
		w.state.denizens[targ_pos] = {pos = targ_pos, health=health.clip({now=2, max=2})}
		return act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ_pos)
	end
}

property "act[enum.power.warp].ranged: utility" {
	numtests = 2000, --Reliably catch failure to notice non-adjacent targets
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10), bool() },
	check = function(seed, pos, warp_factor, force_line)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, force_line)
		local res = act[enum.power.warp].ranged(enum.actmode.utility, w, src, targ.pos)
		local possible = act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		local pursue_u = act[enum.power.warp].pursue(enum.actmode.utility, w, src, targ.pos)
		if possible and pursue_u > 0 then
			return res > pursue_u
		else
			return res <= 0
		end
	end
}

property "act[enum.power.warp].ranged: attempt, boolean result" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10), bool() },
	check = function(seed, pos, warp_factor, force_line)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, force_line)
		local possible = act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		local res = act[enum.power.warp].ranged(enum.actmode.attempt, w, src, targ.pos)
		return res == possible
	end
}

property "act[enum.power.warp].ranged: attempt, health result" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10), bool() },
	check = function(seed, pos, warp_factor, force_line)
		local w, src, targ = ranged_setup(seed, pos, warp_factor, force_line)
		local old_health = targ.health.now
		if act[enum.power.warp].ranged(enum.actmode.attempt, w, src, targ.pos) then
			return targ.health.now == (old_health - 2)
		else
			return targ.health.now == old_health
		end
	end
}