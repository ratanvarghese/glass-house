local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")
local health = require("core.system.health")

local mock = require("test.mock")

local function make_dlist(warp_factor)
	return {
		{x = 0, y = -warp_factor},
		{x = 0, y = warp_factor},
		{x = -warp_factor, y = 0},
		{x = warp_factor, y = 0}
	}
end

local function set_warp_unwalkable(w, src, pos, targ_pos, warp_factor)
	local dlist = make_dlist(warp_factor)
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
		local dlist = make_dlist(warp_factor)
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

local function ranged_setup(seed, pos, warp_factor)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	src.power = {[enum.power.warp] = warp_factor}
	local targ_now = math.random(1, 1000)
	local targ_max = math.random(1, 1000)
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

property "act[enum.power.warp].wander: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = function(check_utility, seed, x, y)
		local m = check_utility and enum.actmode.utility or enum.actmode.possible
		local pos = grid.get_pos(x, y)
		local res = act[enum.power.warp].wander(m, mock.mini_world(seed, pos, true))
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
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.warp] = warp_factor}
		local res = act[enum.power.warp].pursue(enum.actmode.utility, w, src, targ_pos)
		if w.state.light[targ_pos] then
			return res <= 0
		else
			return res > act.MAX_MUNDANE_MOVE
		end
	end
}

property "act[enum.power.mundane].pursue: attempt if obviously possible" {
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
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.warp] = warp_factor}
		local res = act[enum.power.warp].flee(enum.actmode.utility, w, src, targ_pos)
		return res > act.MAX_MUNDANE_MOVE
	end
}

property "act[enum.power.mundane].flee: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2), int(2, 10) },
	check = attempt_if_possible(act[enum.power.warp].flee)
}

property "act[enum.power.warp].flee: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = attempt_if_impossible(act[enum.power.warp].flee)
}

property "act[enum.power.warp].ranged: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor)
		local res = act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos)
		if act[enum.power.warp].pursue(enum.actmode.possible, w, src, targ.pos) then
			return res == (grid.distance(src.pos, targ.pos) < warp_factor)
		else
			return not res
		end
	end
}

property "act[enum.power.warp].ranged: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor)
		local res = act[enum.power.warp].ranged(enum.actmode.utility, w, src, targ.pos)
		if act[enum.power.warp].ranged(enum.actmode.possible, w, src, targ.pos) then
			return res > act[enum.power.warp].pursue(enum.actmode.utility, w, src, targ.pos)
		else
			return res <= 0
		end
	end
}

property "act[enum.power.warp].ranged: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(2, 10) },
	check = function(seed, pos, warp_factor)
		local w, src, targ = ranged_setup(seed, pos, warp_factor)
		local old_health = targ.health.now
		if act[enum.power.warp].ranged(enum.actmode.attempt, w, src, targ.pos) then
			return targ.health.now == (old_health - 2)
		else
			return targ.health.now == old_health
		end
	end
}