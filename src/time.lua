local time = {}

time.scale = {}

time.scale.MAX = 8
time.scale.PLAYER = time.scale.MAX / 2
time.scale.MOVE_COST = time.scale.MAX

function time.make_actor(n)
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
