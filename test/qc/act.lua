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

local function mini_world(cave, swap, x, y)
	local x = x or math.floor(grid.MAX_X/2)
	local y = y or math.floor(grid.MAX_Y/2)
	local w = mock.world(cave)
	local targ_i = grid.get_idx(x, y)
	local source_i = w._start_i
	if swap then
		targ_i, source_i = source_i, targ_i
	end
	local source = {pos=source_i}
	w._denizens[source_i] = source
	return w, source, targ_i
end

local function when_fail_general(power, act_i, cave, trap, x, y)
	local f, act_i = get_f(power, act_i)
	local w, source, targ_i = mini_world(cave, trap, x, y)
	print("")
	print("power:", power, "("..enum.inverted.power[power]..")")
	print("act_i:", f and act_i or "N/A")
	print("cave:", cave, "trap:", trap)
	print("x:", x, "y:", y)
	io.write("\n")
	for i,x,y,t in grid.points(w.terrain) do
		if w.denizens[i] then
			io.write(i == source.pos and "@" or "A")
		else
			io.write(t.kind == enum.terrain.floor and " " or ".")
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
		int(1, grid.MAX_Y)
	},
	check = function(use_utility, power, act_i, cave, trap, x, y)
		local f = get_f(power, act_i)
		if not f then return true end
		local m = use_utility and enum.actmode.utility or enum.actmode.possible
		local w, source, targ_i = mini_world(cave, trap, x, y)
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
		int(1, grid.MAX_Y)
	},
	check = function(power, act_i, cave, trap, x, y)
		local f = get_f(power, act_i)
		if not f then return true end
		local w, source, targ_i = mini_world(cave, trap, x, y)
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
		local w, source, targ_i = mini_world(cave, trap, x, y)
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
		local w, source, targ_i = mini_world(cave, trap, x, y)
		return not pcall(function() f(m, w, source, targ_i) end)
	end,
	when_fail = function(m, ...)
		io.write("\nmode:\t", tostring(m)) --general func will add newline after
		when_fail_general(...)
	end
}

property "act[enum.power.mundane] wander: ignore target" {
	generators = {
		int(1, enum.actmode.MAX-1),
		any(),
		any(),
		bool(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int()
	},
	check = function(m, targ_1, targ_2, cave, x, y, seed)
		local f = act[enum.power.mundane].wander
		local w_1, source_1 = mini_world(cave, true, x, y)
		local w_2, source_2 = mini_world(cave, true, x, y)
		math.randomseed(seed)
		local res_1 = f(m, w_1, source_1, targ_1)
		math.randomseed(seed)
		local res_2 = f(m, w_2, source_2, targ_2)
		local eq_terrain = base.equals(w_1._active_terrain, w_2._active_terrain)
		local eq_denizens = base.equals(w_1._active_denizens, w_2._active_denizens)
		local eq_entities = base.equals(w_1._entities, w_2._entities)
		return res_1 == res_2 and eq_terrain and eq_denizens and eq_entities
	end
}

property "act[enum.power.mundane] wander: correct possible/utility if obviously possible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool()
	},
	check = function(x, y, check_utility)
		local f = act[enum.power.mundane].wander
		local w, source = mini_world(false, true, x, y)
		if check_utility then
			return f(enum.actmode.utility, w, source) == 1
		else
			return f(enum.actmode.possible, w, source)
		end
	end
}

property "act[enum.power.mundane] wander: attempt if obviously possible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
	},
	check = function(x, y)
		local f = act[enum.power.mundane].wander
		local w, source = mini_world(false, true, x, y)
		local old_pos = source.pos
		local success = f(enum.actmode.attempt, w, source)
		return success and grid.distance(old_pos, source.pos) == 1
	end
}

property "act[enum.power.mundane] wander: correct possible/utility if obviously impossible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool()
	},
	check = function(x, y, check_utility)
		local f = act[enum.power.mundane].wander
		local w, source = mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			w._terrain[v].kind = enum.terrain.tough_wall 
		end

		if check_utility then
			return f(enum.actmode.utility, w, source) < 1
		else
			return not f(enum.actmode.possible, w, source)
		end
	end
}

property "act[enum.power.mundane] wander: attempt if obviously impossible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
	},
	check = function(x, y)
		local f = act[enum.power.mundane].wander
		local w, source = mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			w._terrain[v].kind = enum.terrain.tough_wall 
		end
		local old_pos = source.pos
		local success = f(enum.actmode.attempt, w, source)
		return not success and grid.distance(old_pos, source.pos) == 0
	end
}
