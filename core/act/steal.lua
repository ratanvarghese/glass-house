--- Actions for `enum.power.steal`
-- @module core.act.steal

local mundane = require("core.act.mundane")

local steal = {
	--- Melee action for steal power
	-- @see act.action
	melee = {}
}

function steal.melee.possible(world, source, targ_pos)
	local targ = mundane.melee.possible(world, source, targ_pos)
	return targ and targ.inventory or false
end

function steal.melee.utility(world, source, targ_pos)
	local inv = steal.melee.possible(world, source, targ_pos) or {}
	return #(inv)*5
end

function steal.melee.attempt(world, source, targ_pos)
	local inv = steal.melee.possible(world, source, targ_pos)
	if inv and #(inv) > 0 then
		table.insert(source.inventory, table.remove(inv))
		return true
	else
		return false
	end
end

return steal