local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")

local mock = require("test.mock")

local function get_f(power, act_i)
	local flist = act[power]
	if not flist or #flist < 0 then return nil end
	local act_i = base.clip(act_i, 1, #flist)
	return flist[act_i], act_i
end

local function when_fail_general(power, act_i, seed, pos)
	local f, act_i = get_f(power, act_i)
	local w, source = mock.mini_world(seed, pos)
	print("")
	print("power:", power, "("..enum.inverted.power[power]..")")
	print("act_i:", f and act_i or "N/A")
	io.write("\n")
	for i,x,y,t in grid.points(w.state.terrain) do
		if w.state.denizens[i] then
			io.write(i == source.pos and "@" or "A")
		else
			io.write(t.kind == enum.tile.floor and "." or "#")
		end
		if x == grid.MAX_X then
			io.write("\n")
		end
	end
end

property "act: functions have 1 string key and 1 numeric key" {
	generators = { int(1, enum.power.MAX-1) },
	check = function(power)
		local flist = act[power]
		if not flist then return true end

		local v_from_str = {}
		local v_from_num = {}
		for k,v in pairs(flist) do
			if type(k) == "number" then
				v_from_num[v] = true
			elseif type(k) == "string" then
				v_from_str[v] = true
			else
				return false
			end
		end
		return base.equals(v_from_num, v_from_str)
	end
}

property "act: 'possible' and 'utility' do not write to state" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		bool(),
		int(1, enum.power.MAX-1),
		int(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(use_utility, power, act_i, seed, pos)
		local m = use_utility and enum.actmode.utility or enum.actmode.possible
		local f = get_f(power, act_i)
		if not f then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		f(m, w, src, targ_pos)
		for _,v in pairs(w.ctrl) do
			if v.writes > 0 then
				return false
			end
		end
		return true
	end,
	when_fail = function(use_utility, ...)
		local m = use_utility and enum.actmode.utility or enum.actmode.possible
		io.write("\nmode:\t", enum.inverted.actmode[m]) --general func will add newline
		when_fail_general(...)
	end
}

property "act: if 'possible' mode returns false, 'utility' mode returns < 1" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(1, enum.power.MAX-1),
		int(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(power, act_i, seed, pos)
		local f = get_f(power, act_i)
		if not f then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local possibility = f(enum.actmode.possible, w, src, targ_pos)
		local utility = f(enum.actmode.utility, w, src, targ_pos)
		return possibility or (utility < 1)
	end,
	when_fail = when_fail_general
}

property "act: if 'possible' mode returns false, so does 'attempt' mode" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(1, enum.power.MAX-1),
		int(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(power, act_i, seed, pos)
		local f = get_f(power, act_i)
		if not f then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local possibility = f(enum.actmode.possible, w, src, targ_pos)
		local attempt = f(enum.actmode.attempt, w, src, targ_pos)
		return possibility or (not attempt)
	end,
	when_fail = when_fail_general
}

property "act: error on bad mode" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(),
		int(1, enum.power.MAX-1),
		int(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(m, power, act_i, seed, pos)
		if m >= 1 and m < enum.actmode.MAX then return true end
		local f = get_f(power, act_i)
		return (not f) or (not pcall(f, m, mock.mini_world(seed, pos)))
	end,
	when_fail = function(m, ...)
		io.write("\nmode:\t", tostring(m)) --general func will add newline after
		when_fail_general(...)
	end
}