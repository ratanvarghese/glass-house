local base = require("core.base")
local grid = require("core.grid")
local say = require("core.system.say")

local mock = require("test.mock")

property "say.prepare, say.init, say.update work together" {
	generators = { any(), int(), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(msg, seed, p)
		local w = mock.mini_world(seed, p)
		local system = {world = w}
		local say_args = {}
		local say_f = function(...) table.insert(say_args, {...}) end
		say.init(say_f)
		local p_list = {p}
		say.prepare(msg, p_list)
		say.update(system)
		return base.equals(say_args, {{msg, w, {p}}})
	end
}