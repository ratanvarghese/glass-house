local mundane = require("core.act.mundane")
local move = require("core.system.move")

local displace = { melee = {} }

displace.melee.possible = mundane.melee.possible

function displace.melee.utility(world, source, targ_pos)
	return mundane.melee.utility(world, source, targ_pos)*2
end

function displace.melee.attempt(world, source, targ_pos)
	local target = displace.melee.possible(world, source, targ_pos)
	if target then
		target.health.now = target.health.now - 1
		move.prepare(world, source, targ_pos)
		return true
	else
		return false
	end
end

return displace