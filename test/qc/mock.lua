local base = require("core.base")
local grid = require("core.grid")
local mock = require("test.mock")

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
