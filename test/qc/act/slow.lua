local enum = require("core.enum")
local grid = require("core.grid")
local clock = require("core.clock")
local act = require("core.act")

local mock = require("test.mock")

local function possible_setup(seed, x, y, src_speed, targ_speed, dx, dy)
	local pos = grid.get_pos(x, y)
	local w, src = mock.mini_world(seed, pos)
	src.clock = clock.make(src_speed)
	local s_x, s_y = grid.get_xy(src.pos)
	local targ_pos = grid.get_pos(s_x + dx, s_y + dy)
	local targ = {
		pos = targ_pos,
		clock = clock.make(targ_speed)
	}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.slow].area.possible: true if source has slowing power" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, clock.scale.MAX),
		int(1, clock.scale.MAX),
		int(-2, 2),
		int(-2, 2),
		int(2, 5),
		bool()
	},
	check = function(seed, x, y, src_speed, targ_speed, dx, dy, s_factor, assign_s)
		local w, src, targ = possible_setup(seed, x, y, src_speed, targ_speed, dx, dy)
		if assign_s then
			src.power = {[enum.power.slow] = s_factor}
		end
		local res = act[enum.power.slow].area.possible(w, src, targ.pos)
		if assign_s then
			return res
		else
			return not res
		end
	end
}

property "act[enum.power.slow].area.utility: scale with s_factor" {
		generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, clock.scale.MAX),
		int(1, clock.scale.MAX),
		int(-2, 2),
		int(-2, 2),
		int(2, 5)
	},
	check = function(seed, x, y, src_speed, targ_speed, dx, dy, s_factor)
		local w, src, targ = possible_setup(seed, x, y, src_speed, targ_speed, dx, dy)
		src.power = {[enum.power.slow] = s_factor}
		local res_1 = act[enum.power.slow].area.utility(w, src, targ.pos)
		src.power = {[enum.power.slow] = s_factor-1}
		local res_2 = act[enum.power.slow].area.utility(w, src, targ.pos)
		return res_1 > res_2
	end
}

property "act[enum.power.slow].area.attempt: do not slow self" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, clock.scale.MAX),
		int(1, clock.scale.MAX),
		int(-2, 2),
		int(-2, 2),
		int(2, 5)
	},
	check = function(seed, x, y, src_speed, src_speed, dx, dy, s_factor)
		local w, src, targ = possible_setup(seed, x, y, src_speed, targ_speed, dx, dy)
		src.power = {[enum.power.slow] = s_factor}
		local old_cred = src.clock.credit
		act[enum.power.slow].area.attempt(w, src, targ.pos)
		return src.clock.credit == old_cred
	end
}

property "act[enum.power.slow].area.attempt: slow target inverse to distance" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, clock.scale.MAX),
		int(1, clock.scale.MAX),
		int(-1, 1),
		int(-1, 1),
		int(2, 5)
	},
	check = function(seed, x, y, src_speed, src_speed, dx, dy, s_factor)
		local w, src, targ = possible_setup(seed, x, y, src_speed, targ_speed, dx, dy)
		local old_cred_1 = targ.clock.credit
		src.power = {[enum.power.slow] = s_factor}
		act[enum.power.slow].area.attempt(w, src, targ.pos)
		local res_1 = old_cred_1 - targ.clock.credit

		w, src, targ = possible_setup(seed, x, y, src_speed, targ_speed, dx*2, dy*2)
		local old_cred_2 = targ.clock.credit
		src.power = {[enum.power.slow] = s_factor}
		act[enum.power.slow].area.attempt(w, src, targ.pos)
		local res_2 =  old_cred_2 - targ.clock.credit
		return res_2 >= 0 and res_1 > res_2
	end
}