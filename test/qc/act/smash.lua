local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")

local mock = require("test.mock")
local mundane = require("core.act.mundane")


local function set_adjacent_smashable(w, src, pos, targ_pos)
	for _,v in grid.destinations(pos) do
		w.state.terrain[v] = {kind = enum.tile.wall, pos=v}
	end
	w._setup_walk_paths(w, src.pos, targ_pos)
end

local function possible_utility_if_impossible(f)
	return function(check_utility, seed, x, y)
		local m = check_utility and enum.actmode.utility or enum.actmode.possible
		local pos = grid.get_pos(x, y)
		local res = f(m, mock.mini_world(seed, pos, true))
		if check_utility then
			return res == 0
		else
			return not res
		end
	end
end

local function possible_utility_if_possible(f, seek_target)
	return function(check_utility, seed, x, y)
		local m = check_utility and enum.actmode.utility or enum.actmode.possible
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		set_adjacent_smashable(w, src, pos, targ_pos)
		local res = act[enum.power.smash].wander(m, w, src, targ_pos)
		if seek_target then
			local line = grid.line(pos, targ_pos)
			if line[2] then
				if check_utility then
					return res > 0 and res <= mundane.MAX_MOVE
				else
					return res
				end
			else
				return true --Seeking target not possible
			end
		else
			if check_utility then
				return res == 2
			else
				return res
			end
		end
	end
end

local function attempt_if_impossible(f)
	return function(seed, x, y)
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos, true)
		local w_copy = base.copy(w)
		local res = f(enum.actmode.attempt, w, src, targ_pos)
		return not res and base.equals(w.state, w_copy.state)
	end
end

local function attempt_if_possible(f, seek_target)
	return function(seed, x, y)
		local pos = grid.get_pos(x, y)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		set_adjacent_smashable(w, src, pos, targ_pos)
		local res = f(enum.actmode.attempt, w, src, targ_pos)
		for _,v in grid.destinations(pos) do
			if w.state.terrain[v].new_kind == enum.tile.floor then
				if seek_target then
					local line = grid.line(pos, targ_pos)
					if line[2] then
						return line[2] == v and res
					end
				end
				return res
			end
		end
		return false
	end
end


property "act[enum.power.smash].wander: ignore target" {
	generators = {
		int(1, enum.actmode.MAX-1),
		any(),
		any(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(m, targ_1, targ_2, seed, pos)
		local f = act[enum.power.smash].wander
		local w_1, src_1 = mock.mini_world(seed, pos)
		local w_2, src_2 = mock.mini_world(seed, pos)
		math.randomseed(seed)
		local res_1 = f(m, w_1, src_1, targ_1)
		math.randomseed(seed)
		local res_2 = f(m, w_2, src_2, targ_2)
		return res_1 == res_2 and base.equals(w_1.state, w_2.state)
	end
}

property "act[enum.power.smash].wander: correct possible/utility if obviously impossible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = possible_utility_if_impossible(act[enum.power.smash].wander)
}

property "act[enum.power.smash].wander: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = possible_utility_if_possible(act[enum.power.smash].wander, false)
}

property "act[enum.power.smash].wander: attempt if obviously impossible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = attempt_if_impossible(act[enum.power.smash].wander)
}

property "act[enum.power.smash].wander: attempt if obviously possible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = attempt_if_possible(act[enum.power.smash].wander, false)
}

property "act[enum.power.smash].pursue: correct possible/utility if obviously impossible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = possible_utility_if_impossible(act[enum.power.smash].pursue)
}

property "act[enum.power.smash].pursue: correct possible/utility if obviously possible" {
	generators = { bool(), int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = possible_utility_if_possible(act[enum.power.smash].pursue, true)
}

property "act[enum.power.smash].pursue: attempt if obviously impossible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = attempt_if_impossible(act[enum.power.smash].pursue)
}

property "act[enum.power.smash].pursue: attempt if obviously possible" {
	generators = { int(), int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = attempt_if_possible(act[enum.power.smash].pursue, true)
}