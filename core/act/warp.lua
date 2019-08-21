local mundane = require("core.act.mundane")

local warp = {
	wander = {},
	pursue = {},
	flee = {},
	ranged = {}
}

function warp.wander.possible(world, source, dummy_i)
	return math.random(0, 2) == 1
end

function warp.wander.utility(world, source, dummy_i)
	return math.random(0, 2)
end

function warp.wander.attempt(world, source, dummy_i)
	return math.random(0, 2) == 1
end

function warp.pursue.possible(world, source, target_pos)
	return math.random(0, 2) == 1
end

function warp.pursue.utility(world, source, target_pos)
	return math.random(0, 2)
end

function warp.pursue.attempt(world, source, target_pos)
	return math.random(0, 2) == 1
end

function warp.flee.possible(world, source, target_pos)
	return math.random(0, 2) == 1
end

function warp.flee.utility(world, source, target_pos)
	return math.random(0, 2)
end

function warp.flee.attempt(world, source, target_pos)
	return math.random(0, 2) == 1
end

function warp.ranged.possible(world, source, target_pos)
	return math.random(0, 2) == 1
end

function warp.ranged.utility(world, source, target_pos)
	return math.random(0, 2)
end

function warp.ranged.attempt(world, source, target_pos)
	return math.random(0, 2) == 1
end

return warp