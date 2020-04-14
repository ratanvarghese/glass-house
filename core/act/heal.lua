--- Actions for `enum.power.heal`
-- @module core.act.heal

local enum = require("core.enum")
local grid = require("core.grid")
local say = require("core.system.say")

local msg = require("data.msg")

local heal = {
	--- Area action for heal power
	-- @see act.action
	area = {}
}

function heal.area.possible(world, source, targ_pos)
	return source.power[enum.power.heal]
end

function heal.area.utility(world, source, targ_pos)
	local h_factor = source.power[enum.power.heal] or 0
	return (1 - source.health.now/source.health.max) * h_factor * 2
end

function heal.area.attempt(world, source, targ_pos)
	local h_factor = source.power[enum.power.heal]
	if not h_factor then
		return false
	end
	local s_x, s_y = grid.get_xy(source.pos)
	for pos, x, y, dz in grid.surround(source.pos, h_factor, world.state.denizens) do
		if dz then
			local hx = h_factor - math.max(math.abs(s_x - x),math.abs(s_y - y))
			dz.health.now = dz.health.now + hx
			say.prepare(msg.heal, {dz.pos})
		end	
	end
	return true
end

return heal