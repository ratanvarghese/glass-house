local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")

local mock = require("test.mock")

local function kill_setup(seed, pos, decidemode, inventory)
	local w, src = mock.mini_world(seed, pos)
	src.decide, src.inventory = decidemode, (inventory or {})
	w.addEntity(w, src)
	local old_exit = health.exit
	local args = {}
	local exit_f = function(...) table.insert(args, {...}) end
	health.init(exit_f)
	health.kill({world = w}, src)
	w.refresh(w)
	health.init(old_exit)
	return w, src, args
end

property "health.clip: results in range" {
	generators = { int(), int(1, 1000) },
	check = function(now, max)
		local t = {now = now, max = max}
		health.clip(t)
		if now < 0 then
			return t.now == 0
		elseif now > max then
			return t.now == max
		else
			return t.now == now
		end
	end
}

property "health.is_alive: alive if t.now > 0" {
	generators = { int(), int(1, 1000) },
	check = function(now, max)
		return health.is_alive({now = now, max = max}) == (now > 0)
	end
}

property "health.kill: drop inventory only if entity is monster" {
	generators = {int(),int(grid.MIN_POS,grid.MAX_POS),int(1,enum.decidemode.MAX-1),tbl()},
	check = function(seed, pos, decidemode, inventory)
		local w, src = kill_setup(seed, pos, decidemode, inventory)
		local t_inventory = w.state.terrain[src.pos].inventory
		if #inventory > 0 and decidemode == enum.decidemode.monster then
			return base.equals(t_inventory, inventory)
		else
			return (not t_inventory) or base.is_empty(t_inventory)
		end
	end
}

property "health.kill: remove entity if entity is monster" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(1, enum.decidemode.MAX-1) },
	check = function(seed, pos, decidemode)
		local w, src = kill_setup(seed, pos, decidemode)
		if decidemode == enum.decidemode.player then
			return w.state.denizens[src.pos] == src and w.getEntityCount(w) == 1
		else
			return not w.state.denizens[src.pos] and w.getEntityCount(w) == 0
		end
	end
}

property "health.kill, health.init: call exit_f only if entity is player" {
	generators = { int(), int(grid.MIN_POS, grid.MAX_POS), int(1, enum.decidemode.MAX-1) },
	check = function(seed, pos, decidemode)
		local w, _, args = kill_setup(seed, pos, decidemode)
		return base.equals(args, (decidemode == enum.decidemode.player) and {{w, true}} or {})
	end
}
