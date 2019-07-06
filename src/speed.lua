local speed = {}

speed.scale = {}

speed.scale.MAX = 8
speed.scale.PLAYER = speed.scale.MAX / 2
speed.scale.MOVE_COST = speed.scale.MAX

function speed.make_actor(n)
	return {speed = n, move_credit = 0}
end

function speed.earn_credit(actor)
	actor.move_credit = actor.move_credit + actor.speed
	return actor.move_credit > 0
end

function speed.spend_move(actor)
	actor.move_credit = actor.move_credit - speed.scale.MOVE_COST
end

return speed
