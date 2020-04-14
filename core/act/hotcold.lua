--- Actions for `enum.power.hot` and `enum.power.cold`
-- @module core.act.hotcold
local enum = require("core.enum")
local grid = require("core.grid")
local say = require("core.system.say")

local msg = require("data.msg")

local function possible(world, source, targ_pos, p)
	if not p then
		return false
	end
	local s_x, s_y = grid.get_xy(source.pos)
	local t_x, t_y = grid.get_xy(targ_pos)
	if s_x == t_x then
		return math.abs(s_y - t_y) <= p
	elseif s_y == t_y then
		return math.abs(s_x - t_x) <= p
	else
		return false
	end
end

local function utility(world, source, targ_pos, p)
	local p = p or 0
	local s_x, s_y = grid.get_xy(source.pos)
	local t_x, t_y = grid.get_xy(targ_pos)
	local in_line = ((s_x == t_x or s_y == t_y) and 1 or 0)
	local lit = (world.state.light[targ_pos] and 1 or 0)
	return lit*(p-math.abs(s_x-t_x))*(p-math.abs(s_y-t_y))*p*in_line
end

local function attempt(world, source, targ_pos, p_enum, alt_p_enum)
	if (source.pos == targ_pos) or (not source.power) or (not source.power[p_enum]) then
		return false
	end
	local direction = grid.line_direction(source.pos, targ_pos)
	local dest = grid.travel(source.pos, source.power[p_enum], direction)
	for i,cur_pos in ipairs(grid.line(source.pos, dest)) do
		local dz = world.state.denizens[cur_pos]
		if dz and i > 1 then
			local dmg = (source.power[p_enum]-i+1)
			if dz.power then
				if dz.power[p_enum] then
					dmg = 0
				elseif dz.power[alt_p_enum] then
					dmg = dmg * 2
				end
			end
			dz.health.now = dz.health.now - dmg
			if cur_pos == targ_pos then
				hit_target = true
				if dz.decide == enum.decidemode.player and dmg > 0 then
					if p_enum == enum.power.hot then
						say.prepare(msg.hot, {cur_pos})
					else
						say.prepare(msg.cold, {cur_pos})
					end
				end
			end
		end
	end
	return hit_target
end

local p_hot = enum.power.hot
local p_cold = enum.power.cold

local hotcold = { hot = {}, cold = {} }

--- Ranged action for hot power
-- @see act.action
hotcold.hot.ranged = {
	possible = function(w,s,t) return possible(w, s, t, s.power[p_hot]) end,
	utility = function(w,s,t) return utility(w, s, t, s.power[p_hot]) end,
	attempt = function(w,s,t) return attempt(w, s, t, p_hot, p_cold) end
}

--- Ranged action for cold power
-- @see act.action
hotcold.cold.ranged = {
	possible = function(w,s,t) return possible(w, s, t, s.power[p_cold]) end,
	utility = function(w,s,t) return utility(w, s, t, s.power[p_cold]) end,
	attempt = function(w,s,t) return attempt(w, s, t, p_cold, p_hot) end
}

return hotcold