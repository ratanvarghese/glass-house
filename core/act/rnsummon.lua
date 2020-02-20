local enum = require("core.enum")
local summon = require("core.summon")

local move = require("core.system.move")

local rnsummon = {
	ranged = {}
}

function rnsummon.ranged.possible(world, source, target_pos)
	return source.health.now > 1 and #(move.options(world, source.pos)) > 0
end

function rnsummon.ranged.utility(world, source, target_pos)
	local n_options = #(move.options(world, source.pos))
	local lit = (world.state.light[target_pos] and 1 or 0)
	local h_ratio = ((source.health.now - 10)/source.health.now)
	return n_options * lit * h_ratio * 4
end

function rnsummon.ranged.attempt(world, source, target_pos, kind, n)
	local n = math.random(1, (source.power[enum.power.summon] or n) or 1)
	local kind = kind or math.random(enum.monster.MAX_STATIC+1, enum.monster.MAX-1)
	if rnsummon.ranged.possible(world, source, target_pos) then
		local h_ratio = 0.5
		for i = 1,n do
			summon.summon(world, kind, source.pos, true, h_ratio)
			source.health.now = math.floor(source.health.now*h_ratio)
		end
		return true
	else
		return false
	end
end

return rnsummon