local time = {}

time.scale = {}

time.scale.MAX = 8
time.scale.PLAYER = time.scale.MAX / 2
time.scale.MOVE_COST = time.scale.MAX

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

function time.make_actor(n)
	local n = n or get_speed()
	return {speed = n, move_credit = 0}
end

function time.earn_credit(actor)
	actor.move_credit = actor.move_credit + actor.speed
	return actor.move_credit > 0
end

function time.spend_move(actor)
	actor.move_credit = actor.move_credit - time.scale.MOVE_COST
end

return time
