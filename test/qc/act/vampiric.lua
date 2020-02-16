local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")
local act = require("core.act")

local mock = require("test.mock")

local function melee_setup(seed, pos)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	local targ_now = math.random(1, 1000)
	local targ_max = math.random(1, 1000)
	local targ = {pos = targ_pos, health=health.clip({now=targ_now, max=targ_max})}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.vampiric].melee: possible" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local m_res = act[enum.power.mundane].melee(enum.actmode.possible, w, src, targ.pos)
		local v_res = act[enum.power.vampiric].melee(enum.actmode.possible, w, src, targ.pos)
		return v_res == m_res
	end
}

property "act[enum.power.vampiric].melee: utility" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local m_res = act[enum.power.mundane].melee(enum.actmode.utility, w, src, targ.pos)
		local v_res = act[enum.power.vampiric].melee(enum.actmode.utility, w, src, targ.pos)
		if m_res == 0 then
			return v_res == 0
		else
			return v_res > m_res
		end
	end
}

property "act[enum.power.vampiric].melee: attempt" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(seed, pos)
		local w, src, targ = melee_setup(seed, pos)
		local targ_old_health = targ.health.now
		local src_old_health = src.health.now
		if act[enum.power.vampiric].melee(enum.actmode.attempt, w, src, targ.pos) then
			local t_res = targ.health.now < (targ_old_health - 1)
			local s_res = src.health.now > src_old_health
			return t_res and s_res
		else
			local t_res = (targ.health.now == targ_old_health)
			local s_res = (src.health.now == src_old_health)
			return t_res and s_res
		end
	end
}