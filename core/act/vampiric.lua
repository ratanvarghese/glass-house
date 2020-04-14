--- Actions for `enum.power.vampiric`
-- @module core.act.vampiric

local mundane = require("core.act.mundane")
local say = require("core.system.say")

local msg = require("data.msg")

local vampiric = {
	--- Melee action for vampiric power
	-- @see act.action
	melee = {}
}

vampiric.melee.possible = mundane.melee.possible

function vampiric.melee.utility(world, source, target_i)
	return mundane.melee.utility(world, source, target_i) * 2
end

function vampiric.melee.attempt(world, source, target_i)
	local target = vampiric.melee.possible(world, source, target_i)
	if target then
		target.health.now = target.health.now - 2
		source.health.now = source.health.now + 1
		say.prepare(msg.vampiric, {source.pos})
		return true
	else
		return false
	end
end

return vampiric