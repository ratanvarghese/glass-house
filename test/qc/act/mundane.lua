local base = require("core.base")
local enum = require("core.enum")
local grid = require("core.grid")
local health = require("core.system.health")
local act = require("core.act")

local mock = require("test.mock")

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
		local w_1, source_1 = mock.mini_world(cave, true, x, y)
		local w_2, source_2 = mock.mini_world(cave, true, x, y)
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
		local w, source = mock.mini_world(false, true, x, y)
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
		local w, source = mock.mini_world(false, true, x, y)
		local success = f(enum.actmode.attempt, w, source)
		return success and grid.distance(source.destination, source.pos) == 1
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
		local w, source = mock.mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			w.terrain[v] = {kind = enum.terrain.tough_wall, pos=v}
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
		local w, source = mock.mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			w.terrain[v] = {kind = enum.terrain.tough_wall, pos=v}
		end
		local success = f(enum.actmode.attempt, w, source)
		return not success and grid.distance(source.pos, source.destination) == 0
	end
}

property "act[enum.power.mundane] pursue: possible" {
	generators = {
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		bool()
	},
	check = function(x, y, cave)
		local f = act[enum.power.mundane].pursue
		local w, source, targ_i = mock.mini_world(cave, true, x, y)
		local can_progress = false
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			if w.walk_paths[targ_i][v] then
				can_progress = true
				break
			end
		end
		local res = f(enum.actmode.possible, w, source, targ_i)
		return res == can_progress
	end
}

property "act[enum.power.mundane] pursue: utility" {
	generators = {
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		bool()
	},
	check = function(x, y, cave)
		local f = act[enum.power.mundane].pursue
		local w, source, targ_i = mock.mini_world(cave, true, x, y)
		local old_pos = source.pos
		local res = f(enum.actmode.utility, w, source, targ_i)
		local expected_max = grid.distance(old_pos, targ_i)
		if not w.light[targ_i] then
			expected_max = 0
		end
		return res <= expected_max
	end
}

property "act[enum.power.mundane] pursue: attempt with obvious result" {
	generators = {
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		int(1, enum.decidemode.MAX-1)
	},
	check = function(x, y, decidemode)
		local f = act[enum.power.mundane].pursue
		local w, source, targ_i = mock.mini_world(false, true, x, y)
		source.decide = decidemode
		if decidemode == enum.decidemode.player then
			w.player_pos = source.pos
		end
		w.terrain[targ_i] = {kind = enum.terrain.stair, pos=targ_i}
		local res = f(enum.actmode.attempt, w, source, targ_i)
		local old_distance = grid.distance(source.pos, targ_i)
		local new_distance = grid.distance(source.destination, targ_i)
		local correct_player_pos = true
		if decidemode == enum.decidemode.player then
			correct_player_pos = w.player_pos == source.pos
		end
		return res and new_distance <= old_distance and correct_player_pos
	end,
	when_fail = function(x, y, decidemode)
		local f = act[enum.power.mundane].pursue
		local w, source, targ_i = mock.mini_world(false, true, x, y)
		source.decide = decidemode
		if decidemode == enum.decidemode.player then
			w.player_pos = source.pos
		end
		w.terrain[targ_i] = {kind = enum.terrain.floor, pos=targ_i}
		local old_distance = grid.distance(source.pos, targ_i)
		local res = f(enum.actmode.attempt, w, source, targ_i)
		local new_distance = grid.distance(source.pos, targ_i)
		local correct_player_pos = true
		if decidemode == enum.decidemode.player then
			correct_player_pos = w.player_pos == source.pos
		end
		if x < grid.MAX_X and x > 1 and y < grid.MAX_Y and y > 1 then
			print("")
			print("x:", x, "y:", y)
			print("targ_i:", targ_i)
			local tx, ty = grid.get_xy(targ_i)
			print("tx:", tx, "ty:", ty)
			print("player?", decidemode == enum.decidemode.player)
			print("player_pos:", w.player_pos)
			print("target lit?", w.light[targ_i])
			print("old_distance:", old_distance)
			print("new_distance:", new_distance)
			print("res:", res)
			print("pass cond:", new_distance <= old_distance and correct_player_pos)
			io.write("\n")
			for i,x,y,t in grid.points(w._terrain) do
				if w.denizens[i] then
					io.write(i == source.pos and "@" or "A")
				else
					io.write(t.kind == enum.terrain.floor and "." or "#")
				end
				if x == grid.MAX_X then
					io.write("\n")
				end
			end
		end
	end
}

property "act[enum.power.mundane] pursue: attempt if obviously impossible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 4)
	},
	check = function(x, y, opt_i)
		local f = act[enum.power.mundane].pursue
		local w, source = mock.mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		local targ_pos = options[opt_i]
		w.terrain[targ_pos] = {kind = enum.terrain.tough_wall, pos=targ_pos}
		w._setup_walk_paths(w, source.pos, targ_pos)
		local success = f(enum.actmode.attempt, w, source, options[opt_i])
		return not success and grid.distance(source.pos, source.destination) == 0
	end
}

property "act[enum.power.mundane] flee: possible" {
	generators = {
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
		bool()
	},
	check = function(x, y, cave)
		local f = act[enum.power.mundane].flee
		local w, source, targ_i = mock.mini_world(cave, true, x, y)
		local can_progress = false
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		for _,v in ipairs(options) do
			if w.walk_paths[targ_i][v] then
				can_progress = true
				break
			end
		end
		local res = f(enum.actmode.possible, w, source, targ_i)
		return res == can_progress
	end
}

property "act[enum.power.mundane] flee: utility" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool()
	},
	check = function(x, y, cave)
		local f = act[enum.power.mundane].flee
		local w, source, targ_i = mock.mini_world(cave, true, x, y)
		local old_pos = source.pos
		local res = f(enum.actmode.utility, w, source, targ_i)
		return res <= grid.MAX_X + grid.MAX_Y - grid.distance(old_pos, targ_i)
	end
}

property "act[enum.power.mundane] flee: attempt with obvious result" {
	generators = {
		int(3, grid.MAX_X-2),
		int(3, grid.MAX_Y-2),
	},
	check = function(x, y)
		local f = act[enum.power.mundane].flee
		local w, source, targ_i = mock.mini_world(false, true, x, y)
		local res = f(enum.actmode.attempt, w, source, targ_i)
		local old_distance = grid.distance(source.pos, targ_i)
		local new_distance = grid.distance(source.destination, targ_i)
		return res and new_distance == (old_distance + 1)
	end,
	when_fail = function(x, y)
		local f = act[enum.power.mundane].flee
		local w, source, targ_i = mock.mini_world(false, true, x, y)
		local old_distance = grid.distance(source.pos, targ_i)
		local res = f(enum.actmode.attempt, w, source, targ_i)
		local new_distance = grid.distance(source.pos, targ_i)
		if x < grid.MAX_X and x > 1 and y < grid.MAX_Y and y > 1 then
			print("")
			print("x:", x, "y:", y)
			print("targ_i:", targ_i)
			local tx, ty = grid.get_xy(targ_i)
			print("tx:", tx, "ty:", ty)
			print("target lit?", w.light[targ_i])
			print("old_distance:", old_distance)
			print("new_distance:", new_distance)
			print("res:", res)
			print("pass cond:", old_distance > 1 and w.light[targ_i])
			io.write("\n")
			for i,x,y,t in grid.points(w._terrain) do
				if w.denizens[i] then
					io.write(i == source.pos and "@" or "A")
				else
					io.write(t.kind == enum.terrain.floor and "." or "#")
				end
				if x == grid.MAX_X then
					io.write("\n")
				end
			end
		end
	end
}

property "act[enum.power.mundane] flee: attempt if obviously impossible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(1, 4)
	},
	check = function(x, y, opt_i)
		local f = act[enum.power.mundane].flee
		local w, source = mock.mini_world(false, true, x, y)
		local options = {
			grid.travel(source.pos, 1, enum.cmd.north),
			grid.travel(source.pos, 1, enum.cmd.south),
			grid.travel(source.pos, 1, enum.cmd.east),
			grid.travel(source.pos, 1, enum.cmd.west)
		}
		local targ_pos = options[opt_i]
		for _,v in ipairs(options) do
			w.terrain[v] = {kind = enum.terrain.tough_wall, pos=v}
		end
		w._setup_walk_paths(w, source.pos, targ_pos)
		local success = f(enum.actmode.attempt, w, source, options[opt_i])
		return not success and grid.distance(source.destination, source.pos) == 0
	end
}

property "act[enum.power.mundane] melee: possible" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		bool(),
		int(0, 1000),
		int(0, 1000),
		int(0, 1000),
		int(0, 1000)
	},
	check = function(x, y, cave, swap, targ_now, targ_max, source_now, source_max)
		local w, source, targ_i = mock.mini_world(cave, swap, x, y)
		local target = {pos=targ_i, health=health.clip({now=targ_now, max=targ_max})}
		w.denizens[targ_i] = target
		source.health = health.clip({now=source_now, max=source_max})

		local alive = health.is_alive(target.health)
		local adjacent = grid.distance(source.pos, targ_i) == 1
		local f = act[enum.power.mundane].melee
		local res = f(enum.actmode.possible, w, source, targ_i)
		if alive and adjacent then
			return res
		else
			return not res
		end
	end
}

property "act[enum.power.mundane] melee: attempt" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		bool(),
		bool(),
		int(0, 1000),
		int(0, 1000),
		int(0, 1000),
		int(0, 1000)
	},
	check = function(x, y, cave, swap, targ_now, targ_max, source_now, source_max)
		local w, source, targ_i = mock.mini_world(cave, swap, x, y)
		local target = {pos=targ_i, health=health.clip({now=targ_now, max=targ_max})}
		w.denizens[targ_i] = target
		source.health = health.clip({now=source_now, max=source_max})
		local old_health = target.health.now

		local alive = health.is_alive(target.health)
		local adjacent = grid.distance(source.pos, targ_i) == 1
		local f = act[enum.power.mundane].melee
		local res = f(enum.actmode.attempt, w, source, targ_i)
		if alive and adjacent then
			return res and target.health.now == (old_health - 1)
		else
			return not res and target.health.now == old_health
		end
	end
}