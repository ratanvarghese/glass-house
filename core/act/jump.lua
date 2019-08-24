local jump = {
	wander = {},
	pursue = {},
	flee = {},
	ranged = {},
	dlist = {
		{x = 1, y = -2},
		{x = 1, y = 2},
		{x = -1, y = -2},
		{x = -1, y = 2},
		{x = 2, y = -1},
		{x = 2, y = 1},
		{x = -2, y = -1},
		{x = -2, y = 1},
	}
}

function jump.wander.possible(world, source, dummy_pos)
	return math.random(1, 2) == 1
end

function jump.wander.utility(world, source, dummy_pos)
	return math.random(1, 2)
end

function jump.wander.attempt(world, source, dummy_pos)
	return math.random(1, 2) == 1
end

function jump.pursue.possible(world, source, target_pos)
	return math.random(1, 2) == 1
end

function jump.pursue.utility(world, source, target_pos)
	return math.random(1, 2)
end

function jump.pursue.attempt(world, source, target_pos)
	return math.random(1, 2) == 1
end

function jump.flee.possible(world, source, target_pos)
	return math.random(1, 2) == 1
end

function jump.flee.utility(world, source, target_pos)
	return math.random(1, 2)
end

function jump.flee.attempt(world, source, target_pos)
	return math.random(1, 2) == 1
end

function jump.ranged.possible(world, source, target_pos)
	return math.random(1, 2) == 1
end

function jump.ranged.utility(world, source, target_pos)
	return math.random(1, 2)
end

function jump.ranged.attempt(world, source, target_pos)
	return math.random(1, 2) == 1
end

return jump