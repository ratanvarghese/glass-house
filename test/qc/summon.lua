local grid = require("core.grid")
local summon = require("core.summon")
local bestiary = require("core.bestiary")
local enum = require("core.enum")
local clock = require("core.clock")


local mock = require("test.mock")

property "summon.summon: on walkable" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(),
		bool(),
		bool()
	},
	check = function(seed, player_pos, kind, add, use_targ_pos)
		local w, src, targ_pos = mock.mini_world(seed, player_pos)
		w.addEntity = function() end
		make_args = {}

		local old_make = bestiary.make
		local make_args = {}
		bestiary.make = function (...)
			local a = {...}
			table.insert(make_args, a)
			return {pos=a[2], health={now=3, max=3}, clock=clock.make(clock.scale.MAX)}
		end
		local res = summon.summon(w, kind, use_targ_pos and targ_pos or nil, add)
		bestiary.make = old_make
		if res then
			if #(make_args) ~= 1 then
				return false
			elseif make_args[1][1] ~= kind then
				return false
			end
			local t_kind = w.state.terrain[make_args[1][2]].kind
			return t_kind ~= enum.tile.wall and t_kind ~= enum.tile.tough_wall
		else
			return #(make_args) == 0
		end
	end
}

property "summon.summon: adjacent to target" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(),
		bool(),
		bool()
	},
	check = function(seed, player_pos, kind, add)
		local w, src, targ_pos = mock.mini_world(seed, player_pos)
		w.addEntity = function() end
		make_args = {}

		local old_make = bestiary.make
		local make_args = {}
		bestiary.make = function (...)
			local a = {...}
			table.insert(make_args, a)
			return {pos=a[2], health={now=3, max=3}, clock=clock.make(clock.scale.MAX)}
		end
		local res = summon.summon(w, kind, targ_pos, add)
		bestiary.make = old_make
		if res then
			return grid.distance(make_args[1][2], targ_pos) == 1
		else
			return true
		end
	end
}

property "summon.summon: respect add" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(),
		bool(),
		bool(),
		tbl()
	},
	check = function(seed, player_pos, kind, add, use_targ_pos, e)
		local w, src, targ_pos = mock.mini_world(seed, player_pos)
		local addArgs = {}
		w.addEntity = function(...) table.insert(addArgs, {...}) end

		local old_make = bestiary.make
		local make_args = {}
		bestiary.make = function (...)
			local a = {...}
			table.insert(make_args, a)
			e.pos = a[2]
			e.health={now=3, max=3}
			e.clock=clock.make(clock.scale.MAX)
			return e
		end
		local res = summon.summon(w, kind, use_targ_pos and targ_pos or nil, add)
		bestiary.make = old_make
		if res and add then
			if #(addArgs) ~= 1 then
				return false
			else
				return addArgs[1][1] == w and addArgs[1][2] == e
			end
		else
			return #(addArgs) == 0
		end
	end
}


property "summon.summon: respect max_h" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(),
		int(2, 100),
		int(2, 100)
	},
	check = function(seed, player_pos, kind, max_h, h_initial)
		local w, src, targ_pos = mock.mini_world(seed, player_pos)
		local addArgs = {}
		w.addEntity = function(...) table.insert(addArgs, {...}) end
		local old_make = bestiary.make
		bestiary.make = function(...)
			local a = {...}
			return {
				pos=a[2],
				health={now=h_initial, max=h_initial},
				clock=clock.make(clock.scale.MAX)
			}
		end
		summon.summon(w, kind, targ_pos, true, max_h)
		bestiary.make = old_make
		local m = addArgs[1][2]
		return m.health.now <= math.min(h_initial, h_initial)
	end
}

property "summon.summon: spend clock" {
	generators = {
		int(),
		int(grid.MIN_POS, grid.MAX_POS),
		int(),
		float(),
		int(2, 100)
	},
	check = function(seed, player_pos, kind, h_ratio, h_initial)
		local w, src, targ_pos = mock.mini_world(seed, player_pos)
		local addArgs = {}
		w.addEntity = function(...) table.insert(addArgs, {...}) end
		local old_make = bestiary.make
		bestiary.make = function(...)
			local a = {...}
			local e = {
				pos=a[2],
				health={now=h_initial, max=h_initial},
				clock=clock.make(clock.scale.PLAYER)
			}
			clock.earn_credit(e.clock)
			return e
		end
		summon.summon(w, kind, targ_pos, true, h_ratio)
		bestiary.make = old_make
		local m = addArgs[1][2]
		return not clock.has_credit(m.clock)
	end
}