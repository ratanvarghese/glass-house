local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")
local act = require("core.act")

local mock = require("test.mock")

local function set_adjacent_unwalkable(w, src, pos, targ_pos)
	for _,v in grid.destinations(pos) do
		w.state.terrain[v] = {kind = enum.tile.tough_wall, pos=v}
	end
	w._setup_walk_paths(w, src.pos, targ_pos)
end

local function attempt_if_impossible(t)
	return function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		set_adjacent_unwalkable(w, src, pos, targ_pos)
		local success = t.attempt(w, src, targ_pos)
		return not success and grid.distance(src.pos, src.destination) == 0 and src.pos == pos
	end
end

local function attempt_if_possible(t, seek_target)
	return function(seed, x, y)
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		local res = t.attempt(w, src, targ_pos)
		local old_distance = grid.distance(src.pos, targ_pos)
		local new_distance = grid.distance(src.destination, targ_pos)
		if seek_target then
			return res and new_distance <= old_distance and src.pos == pos
		else
			return res and new_distance >= old_distance and src.pos == pos
		end
	end
end

local function simple_possible(t)
	return function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local res = t.possible(w, src, targ_pos)
		for _,v in grid.destinations(pos) do
			if w.walk_paths[targ_pos][v] then
				return res
			end
		end
		return not res
	end
end

local function melee_setup(seed, pos)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	local targ_now = math.random(1, 1000)
	local targ_max = math.random(1, 1000)
	local targ = {pos = targ_pos, health=health.clip({now=targ_now, max=targ_max})}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.mundane].wander: ignore target" {
	generators = {
		int(1, 3),
		any(),
		any(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(m, targ_1, targ_2, seed, pos)
		local f
		if m == 1 then
			f = act[enum.power.mundane].wander.possible
		elseif m == 2 then
			f = act[enum.power.mundane].wander.utility
		else
			f = act[enum.power.mundane].wander.attempt
		end
		local w_1, src_1 = mock.mini_world(seed, pos)
		local w_2, src_2 = mock.mini_world(seed, pos)
		math.randomseed(seed)
		local res_1 = f(w_1, src_1, targ_1)
		math.randomseed(seed)
		local res_2 = f(w_2, src_2, targ_2)
		return res_1 == res_2 and base.equals(w_1.state, w_2.state)
	end
}

property "act[enum.power.mundane].wander: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = function(check_utility, seed, x, y)
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		if check_utility then
			local res = act[enum.power.mundane].wander.utility(w, src, targ_pos)
			return res <= act.MAX_MUNDANE_MOVE and res >= 1
		else
			return act[enum.power.mundane].wander.possible(w, src, targ_pos)
		end
	end
}

property "act[enum.power.mundane].wander: attempt if obviously possible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = function(seed, x, y)
		local pos = grid.get_pos(x, y)
		local w, src = mock.mini_world(seed, pos, true)
		local success = act[enum.power.mundane].wander.attempt(w, src)
		return success and grid.distance(src.destination, src.pos) == 1 and src.pos == pos
	end
}

property "act[enum.power.mundane].wander: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_impossible(act[enum.power.mundane].wander)
}

property "act[enum.power.mundane].pursue: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = simple_possible(act[enum.power.mundane].pursue)
}

property "act[enum.power.mundane].pursue: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local res = act[enum.power.mundane].pursue.utility(w, src, targ_pos)
		return res <= (w.state.light[targ_pos] and act.MAX_MUNDANE_MOVE or 0)
	end
}

property "act[enum.power.mundane].pursue: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2) },
	check = attempt_if_possible(act[enum.power.mundane].pursue, true)
}

property "act[enum.power.mundane].pursue: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_impossible(act[enum.power.mundane].pursue)
}

property "act[enum.power.mundane].flee: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = simple_possible(act[enum.power.mundane].flee)
}

property "act[enum.power.mundane].flee: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local res = act[enum.power.mundane].flee.utility(w, src, targ_pos)
		return res <= act.MAX_MUNDANE_MOVE
	end
}

property "act[enum.power.mundane].flee: attempt if obviously possible" {
	generators = { int(), int(3, grid.MAX_X-2), int(3, grid.MAX_Y-2) },
	check = attempt_if_possible(act[enum.power.mundane].flee, false)
}

property "act[enum.power.mundane].flee: attempt if obviously impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = attempt_if_impossible(act[enum.power.mundane].flee)
}

property "act[enum.power.mundane].melee: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local alive = health.is_alive(targ.health)
		local adjacent = grid.distance(src.pos, targ.pos) == 1
		local res = act[enum.power.mundane].melee.possible(w, src, targ.pos)
		if alive and adjacent then
			return res
		else
			return not res
		end
	end
}

property "act[enum.power.mundane].melee: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local res = act[enum.power.mundane].melee.utility(w, src, targ.pos)
		return res <= act.MAX_MUNDANE_MELEE
	end
}

property "act[enum.power.mundane].melee: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local old_health = targ.health.now
		if act[enum.power.mundane].melee.attempt(w, src, targ.pos) then
			return targ.health.now == (old_health - 1)
		else
			return targ.health.now == old_health
		end
	end
}