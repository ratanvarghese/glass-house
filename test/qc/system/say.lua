local base = require("core.base")
local say = require("core.system.say")

property "say.prepare, say.init, say.update work together" {
	generators = { any(), any() },
	check = function(msg, w)
		local system = {world = w}
		local say_args = {}
		local say_f = function(...) table.insert(say_args, {...}) end
		say.init(say_f)
		say.prepare(msg)
		say.update(system)
		return base.equals(say_args, {{msg, w}})
	end
}