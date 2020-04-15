--- System to display messages to the player
-- @module core.system.say

local tiny = require("lib.tiny")

local deque = require("core.deque")
local visible = require("core.visible")

local say = {}

--- Message queue
say.msg_q = deque.new()

--- Prepare message `s` to be displayed when `say` system updates
-- @param s message
function say.prepare(s, p_list)
	deque.push_back(say.msg_q, {s=s,p_list=p_list})
end

--- Update system, see [tiny-ecs](http://bakpakin.github.io/tiny-ecs/doc/)
function say.update(system, dt)
	for _,v in deque.backwards(say.msg_q) do
		local _, __, lit = visible.at(system.world, v.p_list[1])
		if lit then
			say.ui_say_f(v.s, system.world, v.p_list)
		end
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