local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")
local act = require("core.act")


local mock = require("test.mock")

local function melee_setup(seed, pos, keep_close, dx, dy)
	local w, src, targ_pos = mock.mini_world(seed, pos)
	local targ_now = math.random(1, 1000)
	local targ_max = math.random(1, 1000)
	if keep_close then
		local s_x, s_y = grid.get_xy(src.pos)
		targ_pos = grid.get_pos(s_x + dx, s_y + dy)
	end

	local targ = {pos = targ_pos, health=health.clip({now=targ_now, max=targ_max})}
	w.state.denizens[targ_pos] = targ
	return w, src, targ
end

property "act[enum.power.steal].melee: possible if melee possible and inventory" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1),
		bool()
	},
	check = function(seed, x, y, dx, dy, has_inventory)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy)
		if has_inventory then
			targ.inventory = {{}}
		end
		src.inventory = {}
		local res = act[enum.power.steal].melee.possible(w, src, targ.pos)
		if not act[enum.power.mundane].melee.possible(w, src, targ.pos) then
			return not res
		elseif has_inventory then
			return res
		else
			return not res
		end
	end
}

property "act[enum.power.steal].melee: utility scales with target inventory size" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1)
	},
	check = function(seed, x, y, dx, dy)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy)
		targ.inventory = {{}}
		src.inventory = {}
		local res_1 = act[enum.power.steal].melee.utility(w, src, targ.pos)
		table.insert(targ.inventory, {})
		local res_2 = act[enum.power.steal].melee.utility(w, src, targ.pos)
		if res_1 > 0 then
			return res_1 < res_2
		else
			return res_2 <= 0
		end
	end	
}

property "act[enum.power.steal].melee: attempt" {
	generators = {
		int(),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(-1, 1),
		int(-1, 1),
		tbl()
	},
	check = function(seed, x, y, dx, dy, inv)
		local pos = grid.get_pos(x, y)
		local w, src, targ = melee_setup(seed, pos, true, dx, dy)
		local old_n = #(inv)
		local targ_item = inv[old_n]
		targ.inventory = inv
		src.inventory = {}
		local res = act[enum.power.steal].melee.attempt(w, src, targ.pos)
		if res then
			return src.inventory[1] == targ_item
		else
			return base.is_empty(src.inventory) and inv[old_n] == targ_item
		end
	end	
}