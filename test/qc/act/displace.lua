local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")
local move = require("core.system.move")

local mock = require("test.mock")

local function melee_setup(seed, pos, keep_close, dx, dy, hp)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	if keep_close then
		local s_x, s_y = grid.get_xy(src.pos)
		targ_pos = grid.get_pos(s_x + dx, s_y + dy)
	end

	local targ = {pos = targ_pos, health={now=hp, max=hp}}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.displace].melee: likely possible" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1),
		int(1, 100)
	},
	check = function(seed, x, y, dx, dy, hp)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy, hp)
		local res_1 = act[enum.power.mundane].melee.possible(w, src, targ.pos)
		local res_2 = act[enum.power.displace].melee.possible(w, src, targ.pos)
		return res_1 == res_2
	end
}

property "act[enum.power.displace].melee: higher utility than melee" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1),
		int(1, 100)
	},
	check = function(seed, x, y, dx, dy, hp)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy, hp)
		local res_1 = act[enum.power.mundane].melee.utility(w, src, targ.pos)
		local res_2 = act[enum.power.displace].melee.utility(w, src, targ.pos)
		if res_1 == 0 then
			return res_2 == 0
		else
			return res_1 < res_2
		end
	end
}

property "act[enum.power.displace].melee: attempt" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1),
		int(1, 100)
	},
	check = function(seed, x, y, dx, dy, hp)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy, hp)
		local old_src_pos, old_targ_pos = src.pos, targ.pos
		local old_hp = targ.health.now
		local old_prep = move.prepare
		local prep_args = {}
		move.prepare = function(...) table.insert(prep_args, {...}) end
		local res = act[enum.power.displace].melee.attempt(w, src, targ.pos)
		move.prepare = old_prep
		if res then
			if targ.health.now >= old_hp then
				return false
			elseif #(prep_args) == 0 then
				return false
			end
			for _,v in pairs(prep_args) do
				if #(v) < 3 then
					return false
				elseif v[1] ~= w then
					return false
				elseif v[2] == src and v[3] ~= old_targ_pos then
					return false
				elseif v[2] == targ and v[3] ~= old_src_pos then
					return false
				elseif v[2] ~= src and v[2] ~= targ then
					return false
				end
			end
			return true
		else
			return true
		end
	end
}