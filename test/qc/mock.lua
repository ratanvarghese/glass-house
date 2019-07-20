local base = require("core.base")
local grid = require("core.grid")
local mock = require("test.mock")

property "mock.world: read terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, 20) },
	check = function(x, y, reads)
		local w = mock.world()
		local i = grid.get_idx(x, y)
		local fake_t
		for r=1,reads do
			fake_t = w.terrain[i]
		end
		local real_t = w._terrain[i]
		local act_t = w._active_terrain[i]
		if fake_t ~= act_t then
			return false
		elseif fake_t == real_t or not base.equals(fake_t, real_t) then --MUST be a copy
			return false
		end
		return w._terrain_reads == reads
	end
}

property "mock.world: write terrain" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, 20) },
	check = function(x, y, writes)
		local w = mock.world()
		t = {definitely_a_fake_field = true}
		local i = grid.get_idx(x, y)
		for r=1,writes do
			w.terrain[i] = t
		end
		local real_t = w._terrain[i]
		local act_t = w._active_terrain[i]
		if t == real_t or base.equals(t, real_t) then
			return false
		elseif t ~= act_t then
			return false
		end
		return w._terrain_writes == writes
	end
}

property "mock.world: read denizens" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, 20) },
	check = function(x, y, reads)
		local w = mock.world()
		local i = grid.get_idx(x, y)
		w._denizens[i] = {also_a_fake_field = true}
		local fake_t
		for r=1,reads do
			fake_t = w.denizens[i]
		end
		local real_t = w._denizens[i]
		local act_t = w._active_denizens[i]
		if fake_t ~= act_t then
			return false
		elseif fake_t == real_t or not base.equals(fake_t, real_t) then --MUST be a copy
			return false
		end
		return w._denizen_reads == reads
	end
}

property "mock.world: write denizens" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, 20) },
	check = function(x, y, writes)
		local w = mock.world()
		t = {definitely_a_fake_field = true}
		local i = grid.get_idx(x, y)
		for r=1,writes do
			w.denizens[i] = t
		end
		local real_t = w._denizens[i]
		local act_t = w._active_denizens[i]
		if t == real_t or base.equals(t, real_t) then
			return false
		elseif t ~= act_t then
			return false
		end
		return w._denizen_writes == writes
	end
}

property "mock.world: add entities" {
	generators = { tbl(), int(1, 20) },
	check = function(t, adds)
		local w = mock.world()
		for a=1,adds do
			w.addEntity(w, t)
		end
		return w._entities[t] and w._entity_adds == adds
	end
}

property "mock.world: _start_i" {
	generators = {},
	check = function()
		local x, y = grid.get_xy(mock.world()._start_i)
		local cx, cy = grid.clip(x, y)
		return x == cx and y == cy
	end
}
