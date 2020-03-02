--- Actions for `enum.power.clone`
-- @module core.act.clone

local enum = require("core.enum")
local rnsummon = require("core.act.rnsummon")

local clone = {
	--- Ranged action for clone power
	-- @see act.action
	ranged = {}
}

clone.ranged.possible = rnsummon.ranged.possible
clone.ranged.utility = rnsummon.ranged.utility

function clone.ranged.attempt(world, source, targ_pos)
	return rnsummon.ranged.attempt(
		world,
		source,
		targ_pos,
		source.kind,
		source.power[enum.power.clone]
	)
end

return clone