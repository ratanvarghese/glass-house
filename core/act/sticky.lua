local enum = require("core.enum")
local move = require("core.system.move")
local mundane = require("core.act.mundane")

local sticky = { melee = {} }

sticky.melee.possible = mundane.melee.possible

function sticky.melee.utility(world, source, targ_pos)
	local target = world.state.denizens[targ_pos] or {}
	local relations = target.relations or {}
	local not_stuck_yet = (relations[enum.relations.stuck_to] and 0 or 1)
	local adj = (sticky.melee.possible(world, source, targ_pos) and 1 or 0)
	return (mundane.MAX_MELEE + 1) * adj * not_stuck_yet
end

function sticky.melee.attempt(world, source, targ_pos)
	local target = sticky.melee.possible(world, source, targ_pos)
	if target then
		move.stick(source, target)
	end
	return target
end

return sticky