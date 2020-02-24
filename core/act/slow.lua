local enum = require("core.enum")
local grid = require("core.grid")
local clock = require("core.clock")

local slow = { area = {} }

function slow.area.possible(world, source, targ_pos)
	return source.power[enum.power.slow]
end

function slow.area.utility(world, source, targ_pos)
	local s_factor = source.power[enum.power.slow] or 0
	local clk = source.clock or {credit=0, speed=1}
	return (2 - clk.credit/clk.speed) * s_factor
end

function slow.area.attempt(world, source, targ_pos)
	local s_factor = source.power[enum.power.slow]
	local s_clk = source.clock
	if not s_factor or not s_clk then
		return false
	end
	local s_x, s_y = grid.get_xy(source.pos)
	local p_start = grid.get_pos(grid.clip(s_x-s_factor, s_y-s_factor))
	local p_end = grid.get_pos(grid.clip(s_x+s_factor, s_y+s_factor))
	for pos, x, y, dz in grid.points(world.state.denizens, p_start, p_end) do
		if dz and pos ~= source.pos and dz.clock then
			local slow_x = s_factor - math.max(math.abs(s_x - x),math.abs(s_y - y))
			clock.spend_credit(dz.clock, slow_x)
			clock.earn_credit(s_clk, 2)
		end
	end
	return true
end

return slow