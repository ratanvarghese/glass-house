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

local function when_fail_general(power, act_i, cave, trap, x, y)
	local f, act_i = get_f(power, act_i)
	local w, source, targ_i = mock.mini_world(cave, trap, x, y)
	print("")
	print("power:", power, "("..enum.inverted.power[power]..")")
	print("act_i:", f and act_i or "N/A")
	print("cave:", cave, "trap:", trap)
	print("x:", x, "y:", y)
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
	generators = {
		int(1, enum.power.MAX-1)
	},
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

		for v in pairs(v_from_str) do
			if v_from_num[v] then
				v_from_num[v] = nil
			else
				return false
			end
		end
		return base.is_empty(v_from_num)
	end
}

property "act: 'possible' and 'utility' modes do not alter state" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		bool(),
		int(1, enum.power.MAX-1),
		int(),
		bool(),
		bool(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 1000),
		int(1, 1000)
	},
	check = function(use_utility, power, act_i, cave, trap, x, y, h1, h2)
		local f = get_f(power, act_i)
		if not f then return true end
		local m = use_utility and enum.actmode.utility or enum.actmode.possible
		local w, source, targ_i = mock.mini_world(cave, trap, x, y)
		local health_max = math.max(h1, h2)
		local health_now = math.min(h1, h2)
		source.health = {max = health_max, now = health_now}
		f(m, w, source, targ_i)
		local no_terrain_writes = (w._terrain_ctrl.writes == 0)
		local no_denizens_writes = (w._denizens_ctrl.writes == 0)
		return no_terrain_writes and no_denizens_writes and w._entity_adds == 0
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
		bool(),
		bool(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 1000),
		int(1, 1000)
	},
	check = function(power, act_i, cave, trap, x, y, h1, h2)
		local f = get_f(power, act_i)
		if not f then return true end
		local w, source, targ_i = mock.mini_world(cave, trap, x, y)
		local health_max = math.max(h1, h2)
		local health_now = math.min(h1, h2)
		source.health = {max = health_max, now = health_now}
		local possibility = f(enum.actmode.possible, w, source, targ_i)
		local utility = f(enum.actmode.utility, w, source, targ_i)
		if possibility then
			return true
		else
			return utility < 1
		end
	end,
	when_fail = when_fail_general
}

property "act: if 'possible' mode returns false, so does 'attempt' mode" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(1, enum.power.MAX-1),
		int(),
		bool(),
		bool(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(power, act_i, cave, trap, x, y)
		local f = get_f(power, act_i)
		if not f then return true end
		local w, source, targ_i = mock.mini_world(cave, trap, x, y)
		local possibility = f(enum.actmode.possible, w, source, targ_i)
		local success = f(enum.actmode.attempt, w, source, targ_i)
		return possibility or not success
	end,
	when_fail = when_fail_general

}

property "act: error on bad mode" {
	numtests = 750, --Testing many functions, so need many runs to catch errors
	generators = {
		int(),
		int(1, enum.power.MAX-1),
		int(),
		bool(),
		bool(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(m, power, act_i, cave, trap, x, y)
		local f = get_f(power, act_i)
		if not f then return true end
		local m = (m == base.clip(m, 1, enum.actmode.MAX)) and enum.actmode.MAX or m
		local w, source, targ_i = mock.mini_world(cave, trap, x, y)
		return not pcall(function() f(m, w, source, targ_i) end)
	end,
	when_fail = function(m, ...)
		io.write("\nmode:\t", tostring(m)) --general func will add newline after
		when_fail_general(...)
	end
}