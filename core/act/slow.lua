--- Actions for `enum.power.slow`
-- @module core.act.slow

local enum = require("core.enum")
local grid = require("core.grid")
local clock = require("core.clock")
local say = require("core.system.say")

local msg = require("data.msg")

local slow = {
	--- Area action for slow power
	-- @see act.action
	area = {}
}

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
	local do_speed = false
	for pos, x, y, dz in grid.surround(source.pos,s_factor,world.state.denizens) do
		if dz and pos ~= source.pos and dz.clock then
			local slow_x = s_factor - math.max(math.abs(s_x - x),math.abs(s_y - y))
			clock.spend_credit(dz.clock, slow_x)
			say.prepare(msg.slowed, {dz.pos})
			do_speed = true
		end
	end
	if do_speed then
		clock.earn_credit(s_clk, 2)
	end
	return true
end

return slow