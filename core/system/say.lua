--- System to display messages to the player
-- @module core.system.say

local tiny = require("lib.tiny")

local deque = require("core.deque")

local say = {}

--- Message queue
say.msg_q = deque.new()

--- Prepare message `s` to be displayed when `say` system updates
-- @param s message
function say.prepare(s)
	deque.push_back(say.msg_q, s)
end

--- Update system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function say.update(system, dt)
	for _,v in deque.backwards(say.msg_q) do
		say.ui_say_f(v, system.world)
	end

	say.msg_q = deque.new()
end

--- Make system
-- @treturn tiny.system see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function say.make_system()
	local system = tiny.system()
	system.update = say.update
	return system
end

--- Initialize callbacks for `core.system.say` module
-- @tparam func ui_say_f ui message handler
-- @treturn table `core.system.say` module
function say.init(ui_say_f)
	say.ui_say_f = ui_say_f
	return say
end

return say.init(function() end)