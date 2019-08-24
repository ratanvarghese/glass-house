local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")
local health = require("core.system.health")

local mock = require("test.mock")

local function check_L_shape(src_pos, dest_pos)
		local src_x, src_y = grid.get_xy(src_pos)
		local dest_x, dest_y = grid.get_xy(dest_pos)
		local long_x = math.abs(src_x - dest_x) == 2 and math.abs(src_y - dest_y) == 1
		local long_y = math.abs(src_y - dest_y) == 2 and math.abs(src_x - dest_x) == 1
		return long_x or long_y
end

local function set_jump_unwalkable(w, src, pos, targ_pos)
	for _,v in grid.destinations(pos, act.jump_dlist) do
		w.state.terrain[v] = {kind = enum.tile.tough_wall, pos=v}
	end
	w._setup_walk_paths(w, src.pos, targ_pos)
end

local function attempt_if_impossible(f)
	return function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		set_jump_unwalkable(w, src, pos, targ_pos)
		local success = f(enum.actmode.attempt, w, src, targ_pos)
		return not success and src.pos == src.destination and src.pos == pos
	end
end


local function attempt_if_possible(f)
	return function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		local res = f(enum.actmode.attempt, w, src, targ_pos)
		return res and check_L_shape(src.pos, src.destination) and src.pos == pos
	end
end

local function simple_possible(f)
	return function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local res = f(enum.actmode.possible, w, src, targ_pos)
		for _,v in grid.destinations(pos, act.jump_dlist) do
			if w.walk_paths[targ_pos][v] then
				return res
			end
		end
		return not res
	end
end

local function ranged_setup(seed, pos)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	local targ_max = math.random(1, 10)
	local targ_now = math.random(1, targ_max) - 1  --Sometimes dead
	local targ = {pos = targ_pos, health=health.clip({now=targ_now, max=targ_max})}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.jump].wander: ignore target" {
	generators = {
		int(1, enum.actmode.MAX-1),
		any(),
		any(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(m, targ_1, targ_2, seed, pos)
		local f = act[enum.power.jump].wander
		local w_1, src_1 = mock.mini_world(seed, pos)
		local w_2, src_2 = mock.mini_world(seed, pos)
		math.randomseed(seed)
		local res_1 = f(m, w_1, src_1, targ_1)
		math.randomseed(seed)
		local res_2 = f(m, w_2, src_2, targ_2)
		return res_1 == res_2 and base.equals(w_1.state, w_2.state)
	end
}

property "act[enum.power.jump].wander: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(check_utility, seed, pos)
		local m = check_utility and enum.actmode.utility or enum.actmode.possible
		local w, src = mock.mini_world(seed, pos, true)
		local res = act[enum.power.jump].wander(m, w, src)
		if check_utility then
			return res > act.MAX_MUNDANE_MOVE
		else
			return res
		end
	end
}

property "act[enum.power.jump].wander: attempt if obviously possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src = mock.mini_world(seed, pos, true)
		local success = act[enum.power.jump].wander(enum.actmode.attempt, w, src)
		return success and check_L_shape(src.pos, src.destination) and src.pos == pos
	end
}

property "act[enum.power.jump].wander: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS ) },
	check = attempt_if_impossible(act[enum.power.jump].wander)
}

property "act[enum.power.jump].pursue: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = simple_possible(act[enum.power.jump].pursue)
}

property "act[enum.power.jump].pursue: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		local res = act[enum.power.jump].pursue(enum.actmode.utility, w, src, targ_pos)
		if w.state.light[targ_pos] then
			return res > act.MAX_MUNDANE_MOVE
		else
			return res <= 0
		end
	end
}

property "act[enum.power.jump].pursue: attempt if obviously possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_possible(act[enum.power.jump].pursue)
}

property "act[enum.power.jump].pursue: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_impossible(act[enum.power.jump].pursue)
}

property "act[enum.power.jump].flee: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS)},
	check = simple_possible(act[enum.power.jump].flee)
}

property "act[enum.power.jump].flee: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		local res = act[enum.power.jump].flee(enum.actmode.utility, w, src, targ_pos)
		return res > act.MAX_MUNDANE_MOVE
	end
}

property "act[enum.power.jump].flee: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2) },
	check = attempt_if_possible(act[enum.power.jump].flee)
}

property "act[enum.power.jump].flee: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_impossible(act[enum.power.jump].flee)
}

property "act[enum.power.jump].ranged: possible, only if target is alive" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		if health.is_alive(targ.health) then
			return true
		else
			return not act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.jump].ranged: possible, only if pursue possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		if act[enum.power.jump].pursue(enum.actmode.possible, w, src, targ.pos) then
			return true
		else
			return not act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.jump].ranged: possible, only if target in range" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		local distance = grid.distance(src.pos, targ.pos)
		if distance == 1 or distance == 2 then
			return true
		else
			return not act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ.pos)
		end
	end
}

property "act[enum.power.jump].ranged: obviously possible" {
	generators = { int(), bool(), bool() },
	check = function(seed, far_x, far_x)
		local x = far_x and grid.MAX_X or 1
		local y = far_y and grid.MAX_Y or 1
		local pos = grid.get_pos(x, y)
		local w, src = mock.mini_world(seed, pos, true)
		local targ_x = far_x and (grid.MAX_X - 2) or 2
		local targ_y = far_y and (grid.MAX_Y - 2) or 2
		local targ_pos = grid.get_pos(targ_x, targ_y)
		w.state.denizens[targ_pos] = {pos = targ_pos, health=health.clip({now=2, max=2})}
		return act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ_pos)
	end
}

property "act[enum.power.jump].ranged: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		local possible = act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ.pos)
		local pursue_u = act[enum.power.jump].pursue(enum.actmode.utility, w, src, targ.pos)
		local res = act[enum.power.jump].ranged(enum.actmode.utility, w, src, targ.pos)
		if possible and pursue_u > 0 then
			return res > pursue_u
		else
			return res <= 0
		end
	end
}

property "act[enum.power.jump].ranged: attempt, boolean result" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		local possible = act[enum.power.jump].ranged(enum.actmode.possible, w, src, targ.pos)
		local res = act[enum.power.jump].ranged(enum.actmode.attempt, w, src, targ.pos)
		return res == possible
	end
}

property "act[enum.power.jump].ranged: attempt, health result" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		local old_health = targ.health.now
		if act[enum.power.jump].ranged(enum.actmode.attempt, w, src, targ.pos) then
			return targ.health.now == (old_health - 2)
		else
			return targ.health.now == old_health
		end
	end
}

property "act[enum.power.jump].ranged: attempt, distance result" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = ranged_setup(seed, pos)
		if act[enum.power.jump].ranged(enum.actmode.attempt, w, src, targ.pos) then
			local distance = grid.distance(src.destination, targ.pos)
			return distance == 2 and check_L_shape(src.pos, src.destination)
		else
			return src.pos == src.destination
		end
	end
}