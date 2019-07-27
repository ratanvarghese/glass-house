local clock = {}

clock.scale = {}

function clock.make(n)
	clock.scale.MAX_ID = clock.scale.MAX_ID + 1
	return {speed = n, credit = 0, id = clock.scale.MAX_ID}
end

function clock.earn_credit(clk, slow)
	local credit = slow and math.ceil(clk.speed/clock.scale.SLOW_FACTOR) or clk.speed
	clk.credit = clk.credit + credit
end

function clock.has_credit(clk)
	return clk.credit > 0
end

function clock.spend_credit(clk, cost)
	local cost = cost or clock.scale.PLAYER
	clk.credit = clk.credit - cost
end

function clock.init(max, slow_factor, max_id)
	clock.scale.MAX = max
	clock.scale.PLAYER = clock.scale.MAX / 2
	clock.scale.MOVE_COST = clock.scale.MAX
	clock.scale.SLOW_FACTOR = slow_factor
	clock.scale.MAX_ID = max_id
	return clock
end

return clock.init(16, 2, 0)
