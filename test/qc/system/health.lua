local mock = require("test.mock")

local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")

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
		local t = {now = now, max = max}
		return health.is_alive(t) == (t.now > 0)
	end
}

property "health.kill: drop inventory only if entity is monster" {
	generators = {
		int(),
		int(),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		bool(),
		int(1, enum.decidemode.MAX-1),
		tbl()
	},
	check = function(now, max, x, y, make_cave, decidemode, inventory)
		local pos = grid.get_pos(x, y)
		local w = mock.world(make_cave)
		w.state.terrain[pos].inventory = {}
		w.state.denizens[pos] = {
			pos = pos,
			health = {
				now = now,
				max = max
			},
			decide = decidemode,
			inventory = inventory
		}
		health.kill({world=w}, w.state.denizens[pos])
		local new_inventory = w.state.terrain[pos].inventory
		if decidemode == enum.decidemode.monster then
			local res1 = #inventory > 0 and base.equals(new_inventory, inventory)
			local res2 = #inventory <= 0 and base.is_empty(new_inventory)
			local res3 = #inventory <= 0 and new_inventory == nil
			return res1 or res2 or res3
		else
			return base.is_empty(new_inventory)
		end
	end 
}

property "health.kill: remove entity if entity is monster" {
		generators = {
		int(),
		int(),
		int(1, enum.decidemode.MAX-1),
		bool()
	},
	check = function(now, max, decidemode, make_cave)
		local world = mock.world(make_cave)
		local e = {
			decide = decidemode,
			health = {
				now = now,
				max = max
			},
			pos = world._start_i
		}
		world.state.denizens[e.pos] = e
		world.addEntity(world, e)
		local old_exit = health.exit
		health.init(function() end)
		health.kill({world = world}, e)
		health.init(old_exit)
		if decidemode == enum.decidemode.player then
			return world.state.denizens[e.pos] == e and world._entities[e]
		else
			return not world.state.denizens[e.pos] and not world._entities[e]
		end
	end
}

property "health.kill, health.init: call exit_f only if entity is player" {
	generators = {
		int(),
		int(),
		int(1, enum.decidemode.MAX-1),
		bool()
	},
	check = function(now, max, decidemode, make_cave)
		local world = mock.world(make_cave)
		local e = {
			decide = decidemode,
			health = {
				now = now,
				max = max
			},
			pos = world._start_i
		}
		world.state.denizens[e.pos] = e
		local old_exit = health.exit
		local args = {}
		local exit_f = function(...) table.insert(args, {...}) end
		health.init(exit_f)
		health.kill({world = world}, e)
		health.init(old_exit)
		if decidemode == enum.decidemode.player then
			return base.equals(args, {{world, true}})
		else
			return base.equals(args, {})
		end
	end
}
