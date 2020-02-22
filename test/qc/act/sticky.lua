local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")
local move = require("core.system.move")

local mock = require("test.mock")

local function possible_setup(seed, x, y, hp, dx, dy)
	local pos = grid.get_pos(x, y)
	local w, src = mock.mini_world(seed, pos)
	local s_x, s_y = grid.get_xy(src.pos)
	local targ_pos = grid.get_pos(s_x + dx, s_y + dy)
	local targ = {pos = targ_pos, health={now=hp, max=hp}}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.sticky].melee: likely impossible if melee is likely impossible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(1, 100) },
	check = function(seed, pos, hp)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		w.state.denizens[targ_pos] = {pos = targ_pos, health={now=hp, max=hp}}
		local res_1 = act[enum.power.sticky].melee.possible(w, src, targ_pos)
		local res_2 = act[enum.power.mundane].melee.possible(w, src, targ_pos)
		return res_1 == res_2
	end
}

property "act[enum.power.sticky].melee: likely possible if melee is likely possible" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(-1, 1),
		int(-1, 1)
	},
	check = function(seed, x, y, hp, dx, dy)
		local w, src, targ = possible_setup(seed, x, y, hp, dx, dy)
		local res_1 = act[enum.power.sticky].melee.possible(w, src, targ.pos)
		local res_2 = act[enum.power.mundane].melee.possible(w, src, targ.pos)
		return res_1 == res_2
	end
}

property "act[enum.power.sticky].melee: utility if not already stuck" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(-1, 1),
		int(-1, 1)
	},
	check = function(seed, x, y, hp, dx, dy)
		local w, src, targ = possible_setup(seed, x, y, hp, dx, dy)
		local res_1 = act[enum.power.sticky].melee.utility(w, src, targ.pos)
		local res_2 = act[enum.power.mundane].melee.utility(w, src, targ.pos)
		if res_1 == 0 then
			return res_2 == 0
		else
			return res_1 > res_2
		end
	end
}

property "act[enum.power.sticky].melee: utility if already stuck" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(-1, 1),
		int(-1, 1)
	},
	check = function(seed, x, y, hp, dx, dy)
		local w, src, targ = possible_setup(seed, x, y, hp, dx, dy)
		move.stick(src, targ)
		return act[enum.power.sticky].melee.utility(w, src, targ.pos) == 0
	end
}

property "act[enum.power.sticky].attempt: likely possible" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 100),
		int(-1, 1),
		int(-1, 1)
	},
	check = function(seed, x, y, hp, dx, dy)
		local w, src, targ = possible_setup(seed, x, y, hp, dx, dy)
		local old_stick = move.stick
		local stick_args = {}
		move.stick = function(...)
			table.insert(stick_args, {...})
		end
		local res = act[enum.power.sticky].melee.attempt(w, src, targ.pos)
		move.stick = old_stick
		if res then
			return base.equals(stick_args, {{src, targ}})
		else
			return #stick_args == 0
		end
	end
}