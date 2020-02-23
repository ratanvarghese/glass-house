local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local act = require("core.act")

local mock = require("test.mock")

local function possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
	local pos = grid.get_pos(x, y)
	local w, src = mock.mini_world(seed, pos)
	local s_x, s_y = grid.get_xy(src.pos)
	local targ_pos = grid.get_pos(s_x + dx, s_y + dy)
	local targ = {
		pos = targ_pos,
		health={
			now=base.clip(targ_now_hp,1,targ_max_hp),
			max=targ_max_hp
		}
	}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.heal].area.possible: true if source has healing power" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(1, 100),
		int(-2, 2),
		int(-2, 2),
		int(2, 5),
		bool()
	},
	check = function(seed, x, y, targ_now_hp, targ_max_hp, dx, dy, h_factor, assign_h)
		local w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
		if assign_h then
			src.power = {[enum.power.heal] = h_factor}
		end
		local res = act[enum.power.heal].area.possible(w, src, targ.pos)
		if assign_h then
			return res
		else
			return not res
		end
	end
}

property "act[enum.power.heal].area.utility: scale inversely with health" {
		generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(1, 100),
		int(-2, 2),
		int(-2, 2),
		int(2, 5)
	},
	check = function(seed, x, y, targ_now_hp, targ_max_hp, dx, dy, h_factor)
		local w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
		src.power = {[enum.power.heal] = h_factor}
		local res_1 = act[enum.power.heal].area.utility(w, src, targ.pos)
		src.health.now  = src.health.now - 1
		local res_2 = act[enum.power.heal].area.utility(w, src, targ.pos)
		return res_1 < res_2
	end
}

property "act[enum.power.heal].area.utility: scale with h_factor" {
		generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(1, 100),
		int(-2, 2),
		int(-2, 2),
		int(2, 5)
	},
	check = function(seed, x, y, targ_now_hp, targ_max_hp, dx, dy, h_factor)
		local w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
		src.power = {[enum.power.heal] = h_factor}
		local res_1 = act[enum.power.heal].area.utility(w, src, targ.pos)
		src.power = {[enum.power.heal] = h_factor-1}
		local res_2 = act[enum.power.heal].area.utility(w, src, targ.pos)
		return res_1 > res_2
	end
}

property "act[enum.power.heal].area.attempt: heal self by h_factor" {
		generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(1, 100),
		int(-2, 2),
		int(-2, 2),
		int(2, 5)
	},
	check = function(seed, x, y, targ_now_hp, targ_max_hp, dx, dy, h_factor)
		local w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
		src.power = {[enum.power.heal] = h_factor}
		local old_health = src.health.now
		act[enum.power.heal].area.attempt(w, src, targ.pos)
		return (src.health.now - old_health) == h_factor
	end
}

property "act[enum.power.heal].area.attempt: heal target inverse to distance" {
		generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(1, 100),
		int(-1, 1),
		int(-1, 1),
		int(2, 5)
	},
	check = function(seed, x, y, targ_now_hp, targ_max_hp, dx, dy, h_factor)
		local w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx, dy)
		local old_health_1 = targ.health.now
		src.power = {[enum.power.heal] = h_factor}
		act[enum.power.heal].area.attempt(w, src, targ.pos)
		local res_1 = targ.health.now - old_health_1

		w, src, targ = possible_setup(seed, x, y, targ_now_hp, targ_max_hp, dx*2, dy*2)
		local old_health_2 = targ.health.now
		src.power = {[enum.power.heal] = h_factor}
		act[enum.power.heal].area.attempt(w, src, targ.pos)
		local res_2 = targ.health.now - old_health_2
		return res_2 >= 0 and res_1 > res_2
	end
}