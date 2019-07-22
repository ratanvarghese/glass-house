local clock = {}

clock.scale = {}

function clock.make(n)
	return {speed = n, credit = 0}
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

function clock.init(max, slow_factor)
	clock.scale.MAX = max
	clock.scale.PLAYER = clock.scale.MAX / 2
	clock.scale.MOVE_COST = clock.scale.MAX
	clock.scale.SLOW_FACTOR = slow_factor
	return clock
end

return clock.init(16, 2)
