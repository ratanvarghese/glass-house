local clock = {}

clock.scale = {}

function clock.make(n)
	clock.scale.MAX_ID = clock.scale.MAX_ID + 1
	return {speed = n, credit = 0, id = clock.scale.MAX_ID}
end

function clock.earn_credit(clk, cred)
	local cred = cred or clk.speed
	clk.credit = clk.credit + cred
end

function clock.has_credit(clk)
	return clk.credit > 0
end

function clock.spend_credit(clk, cost)
	local cost = cost or clock.scale.PLAYER
	clk.credit = clk.credit - cost
end

function clock.init(max, max_id)
	clock.scale.MAX = max
	clock.scale.PLAYER = clock.scale.MAX / 2
	clock.scale.MOVE_COST = clock.scale.MAX
	clock.scale.MAX_ID = max_id
	return clock
end

return clock.init(16, 0)
