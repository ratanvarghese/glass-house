local time = {}

time.scale = {}

time.scale.MAX = 8
time.scale.PLAYER = time.scale.MAX / 2
time.scale.MOVE_COST = time.scale.MAX
time.scale.SLOW_FACTOR = 2

local function get_speed()
	--Mostly middling speeds, with some outliers
	local x = math.random(0, time.scale.MAX)
	local a = time.scale.PLAYER / 2
	local b = time.scale.MAX
	if x <= time.scale.PLAYER then
		return math.floor(a * math.sqrt(x))
	else
		return math.ceil(b - a * math.sqrt(-x + b))
	end
end

function time.make_clock(n)
	local n = n or get_speed()
	return {speed = n, move_credit = 0}
end

local function slow_credit(clock)
	return math.ceil(clock.speed/time.scale.SLOW_FACTOR)
end

function time.earn_credit(clock, slow)
	local new_credit = slow and slow_credit(clock) or clock.speed
	clock.move_credit = clock.move_credit + new_credit
	return clock.move_credit > 0
end

function time.spend_move(clock)
	clock.move_credit = clock.move_credit - time.scale.MOVE_COST
end

return time
