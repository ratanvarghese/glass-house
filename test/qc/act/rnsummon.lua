local base = require("core.base")
local grid = require("core.grid")
local enum = require("core.enum")
local act = require("core.act")
local summon = require("core.summon")

local mock = require("test.mock")

property "act[enum.power.summon].ranged.possible: obviously possible" {
	generators = { int(), int(grid.MIN_POS+1, grid.MAX_POS-1) },
	check = function(seed, pos)
		return act[enum.power.summon].ranged.possible(mock.mini_world(seed, pos, true))
	end
}

property "act[enum.power.summon].ranged.possible: low health" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.health.now = 1
		return not act[enum.power.summon].ranged.possible(w, src, targ_pos)
	end
}

property "act[enum.power.summon].ranged.utility: scale with health" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		local res_1 = act[enum.power.summon].ranged.utility(w, src, targ_pos)
		if res_1 <= 0 then
			return true
		end
		src.health.now = 1
		local res_2 = act[enum.power.summon].ranged.utility(w, src, targ_pos)
		return res_1 > res_2
	end
}

property "act[enum.power.summon].ranged.attempt: call summon.summon" {
	generators = { int(), int(grid.MIN_POS+1, grid.MAX_POS-1), int(1, 4), int(1, 4) },
	check = function(seed, pos, summon_i, power)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.summon] = power}
		local oldsummon = summon.summon
		local summon_args = {}
		summon.summon = function(...)
			table.insert(summon_args, {...})
			return true
		end
		local res = act[enum.power.summon].ranged.attempt(w, src, targ_pos)
		summon.summon = oldsummon
		if res then
			if #(summon_args) > 4 or #(summon_args) < 1 then
				return false
			end

			local summon_i = base.clip(summon_i, 1, #(summon_args))
			if summon_args[summon_i][1] ~= w then
				return false
			elseif summon_args[summon_i][2] < enum.monster.MAX_STATIC then
				return false
			elseif summon_args[summon_i][2] > enum.monster.MAX then
				return false
			elseif summon_args[summon_i][3] ~= src.pos then
				return false
			elseif not summon_args[summon_i][4] then
				return false
			elseif summon_args[summon_i][5] ~= 0.5 then
				return false
			else
				return src.health.now < src.health.max
			end
		else
			return #(summon_args) == 0
		end
	end
}

property "act[enum.power.summon].ranged.attempt: respect extra kind argument" {
	generators = { int(), int(grid.MIN_POS+1, grid.MAX_POS-1), int(), int(1, 4) },
	check = function(seed, pos, kind, power)
		local w, src, targ_pos = mock.mini_world(seed, pos)
		src.power = {[enum.power.summon] = power}
		local oldsummon = summon.summon
		local summon_args = {}
		summon.summon = function(...)
			table.insert(summon_args, {...})
			return true
		end
		local res = act[enum.power.summon].ranged.attempt(w, src, targ_pos, kind)
		summon.summon = oldsummon
		if res then
			return summon_args[1][2] == kind
		else
			return #(summon_args) == 0
		end
	end
}