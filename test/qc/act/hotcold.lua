local grid = require("core.grid")
local enum = require("core.enum")
local act = require("core.act")
local mock = require("test.mock")

function ranged_attempt_setup(seed, x, y, targ_along_x, distance, hot_factor, hp, p)
	local pos = grid.get_pos(x, y)
	local w, src = mock.mini_world(seed, pos, true)
	src.power = {[p] = hot_factor}
	local targ_dz = {health = {now=hp}}
	local spos_x, spos_y = grid.get_xy(src.pos)
	local targ_pos
	if targ_along_x then
		targ_pos = grid.get_pos(spos_x+distance, spos_y)
	else
		targ_pos = grid.get_pos(spos_x, spos_y+distance)
	end
	w.state.denizens[targ_pos] = targ_dz
	return w, src, targ_pos
end

property "act[enum.power.hot].ranged: impossible without power" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos, hot_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		return not act[enum.power.hot].ranged.possible(w, src, targ_pos)
	end
}

property "act[enum.power.hot].ranged: possible if in line" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(3, 5) },
	check = function(seed, pos, hot_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.hot] = hot_factor}
		local in_range = grid.distance(src.pos, targ_pos) <= hot_factor
		local s_x, s_y = grid.get_xy(src.pos)
		local t_x, t_y = grid.get_xy(targ_pos)
		local in_line = (s_x == t_x) or (s_y == t_y)
		local res = act[enum.power.hot].ranged.possible(w, src, targ_pos)
		return res == (in_line and in_range)
	end
}

property "act[enum.power.hot].ranged: utility scales with heat" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(3, 5) },
	check = function(seed, pos, hot_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.hot] = hot_factor}
		local res_1 = act[enum.power.hot].ranged.utility(w, src, targ_pos)
		if res_1 <= 0 then
			return true
		end
		src.power[enum.power.hot] = hot_factor + 1
		local res_2 = act[enum.power.hot].ranged.utility(w, src, targ_pos)
		return res_2 > res_1
	end
}

property "act[enum.power.hot].ranged: attempt really obvious case" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(-2, 2),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, distance, hot_factor, hp)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.hot
		)
		local res = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		return res and w.state.denizens[targ_pos].health.now < hp
	end
}

property "act[enum.power.hot].ranged: fail if distance zero" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, hot_factor, hp)
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, 0, hot_factor, hp, enum.power.hot
		)
		local res = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		return not res and w.state.denizens[targ_pos].health.now == hp
	end
}

property "act[enum.power.hot].ranged: attempt damage scales with heat" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(-2, 2),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, distance, hot_factor, hp)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.hot
		)
		local res_1 = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		local hp_1 = w.state.denizens[targ_pos].health.now
		src.power[enum.power.hot] = hot_factor + 1
		w.state.denizens[targ_pos].health.now = hp
		local res_2 = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		local hp_2 = w.state.denizens[targ_pos].health.now
		return res_1 and res_2 and hp_1 > hp_2
	end
}

property "act[enum.power.hot].ranged: attempt damage scales inverse with distance" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(-1, 1),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, distance, hot_factor, hp)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ_pos_1 = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.hot
		)
		local res_1 = act[enum.power.hot].ranged.attempt(w, src, targ_pos_1)
		local hp_1 = w.state.denizens[targ_pos_1].health.now
		local targ_dz = w.state.denizens[targ_pos_1]
		targ_dz.health.now = hp
		w.state.denizens[targ_pos_1] = nil
		local t1_x, t1_y = grid.get_xy(targ_pos_1)
		local targ_pos_2
		if t1_x == x then
			targ_pos_2 = grid.get_pos(t1_x, t1_y+distance)
		else
			targ_pos_2 = grid.get_pos(t1_x+distance, t1_y)
		end
		w.state.denizens[targ_pos_2] = targ_dz
		local res_2 = act[enum.power.hot].ranged.attempt(w, src, targ_pos_2)
		local hp_2 = w.state.denizens[targ_pos_2].health.now
		return res_1 and res_2 and hp_1 < hp_2
	end
}

property "act[enum.power.cold].ranged: possible/utility same as hot" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(3, 5), bool() },
	check = function(seed, pos, cold_factor)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.cold] = cold_factor}
		local r1_u = act[enum.power.cold].ranged.utility(w, src, targ_pos)
		local r1_p = act[enum.power.cold].ranged.possible(w, src, targ_pos)
		src.power = {[enum.power.hot] = cold_factor}
		local r2_u = act[enum.power.hot].ranged.utility(w, src, targ_pos)
		local r2_p = act[enum.power.hot].ranged.possible(w, src, targ_pos)
		return r1_u == r2_u and r1_p == r2_p
	end
}

property "act[enum.power.cold].ranged: attempt same as hot" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(-1, 1),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, distance, hot_factor, hp)
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.cold
		)
		local res_1 = act[enum.power.cold].ranged.attempt(w, src, targ_pos)
		local hp_1 = w.state.denizens[targ_pos].health.now
		w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.hot
		)
		local res_2 = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		local hp_2 = w.state.denizens[targ_pos].health.now
		return res_1 == res_2 and hp_1 == hp_2
	end
}

property "act[enum.power.cold/hot].ranged: element cancels itself" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		int(-1, 1),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, distance, hot_factor, hp)
		if distance == 0 then
			distance = 1
		end
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.hot
		)
		w.state.denizens[targ_pos].power = {[enum.power.hot]=hot_factor}
		local res_1 = act[enum.power.hot].ranged.attempt(w, src, targ_pos)
		local hp_1 = w.state.denizens[targ_pos].health.now
		w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, enum.power.cold
		)
		w.state.denizens[targ_pos].power = {[enum.power.cold]=hot_factor}
		local res_2 = act[enum.power.cold].ranged.attempt(w, src, targ_pos)
		local hp_2 = w.state.denizens[targ_pos].health.now
		return res_1 == true and res_2 == true and hp_1 == hp and hp_2 == hp
	end
}

property "act[enum.power.cold/hot].ranged: element has bonus against other" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		bool(),
		int(-1, 1),
		int(3, 5),
		int(1, 100)
	},
	check = function(seed, x, y, targ_along_x, use_hot, distance, hot_factor, hp)
		if distance == 0 then
			distance = 1
		end
		local pow_1, pow_2
		if use_hot then
			pow_1, pow_2 = enum.power.hot, enum.power.cold
		else
			pow_1, pow_2 = enum.power.cold, enum.power.hot
		end
		local w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, pow_1
		)
		local res_1 = act[pow_1].ranged.attempt(w, src, targ_pos)
		local hp_1 = w.state.denizens[targ_pos].health.now
		w, src, targ_pos = ranged_attempt_setup(
			seed, x, y, targ_along_x, distance, hot_factor, hp, pow_1
		)
		w.state.denizens[targ_pos].power = {[pow_2]=hot_factor}
		local res_2 = act[pow_1].ranged.attempt(w, src, targ_pos)
		local hp_2 = w.state.denizens[targ_pos].health.now
		return res_1 == true and res_2 == true and hp_1 > hp_2
	end
}