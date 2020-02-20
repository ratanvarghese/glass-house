local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local act = require("core.act")

local bestiary = require("core.bestiary")

local mock = require("test.mock")

local serpent = require("lib.serpent")

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
		local t = get_f(power, act_i)
		if not t then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		if use_utility then
			t.utility(w, src, targ_pos)
		else
			t.possible(w, src, targ_pos)
		end
		for _,v in pairs(w.ctrl) do
			if v.writes > 0 then
				return false
			end
		end
		return true
	end,
	when_fail = function(use_utility, ...)
		print("use_utility:", use_utility)
		when_fail_general(...)
	end
}

property "act: if 'possible' mode returns false, 'utility' mode returns <= 0" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(1, enum.power.MAX-1),
		int(),
		int(),
		int(grid.MIN_POS, grid.MAX_POS)
	},
	check = function(power, act_i, seed, pos)
		local t = get_f(power, act_i)
		if not t then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local possibility = t.possible(w, src, targ_pos)
		local utility = t.utility(w, src, targ_pos)
		return possibility or (utility <= 0)
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
		local t = get_f(power, act_i)
		if not t then return true end
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local possibility = t.possible(w, src, targ_pos)
		local old_make = bestiary.make
		bestiary.make = function() end
		local attempt = t.attempt(w, src, targ_pos)
		bestiary.make = old_make
		return possibility or (not attempt)
	end,
	when_fail = when_fail_general
}