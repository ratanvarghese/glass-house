local time = require("src.time")

property "time: expected move speed" {
	generators = {
		int(0, time.scale.MAX),
		int(1, time.scale.MAX*4),
		int(1, time.scale.MAX)
	},
	check = function(s1, iters, cost)
		local old_cost = time.scale.MOVE_COST
		time.scale.MOVE_COST = cost
		local actor = time.make_actor(s1)
		local moves = 0
		for i=1,iters do
			if time.earn_credit(actor) then
				time.spend_move(actor)
				moves = moves + 1
			end
		end
		time.scale.MOVE_COST = old_cost
		return moves == math.min(iters, math.ceil((s1/cost)*iters))
	end,
	when_fail = function(s1, iters, cost)
		print("---------------")
		local old_cost = time.scale.MOVE_COST
		time.scale.MOVE_COST = cost
		local actor = time.make_actor(s1)
		local moves = 0
		for i=1,iters do
			io.write("i = ", i, ":\t")
			io.write("credit = ", actor.move_credit, "\t")
			if time.earn_credit(actor) then
				io.write("\tm\t")
				time.spend_move(actor)
				moves = moves + 1
			else
				io.write("\t\t")
			end
			io.write("credit = ", actor.move_credit, "\n")
		end
		time.scale.MOVE_COST = old_cost
		print("speed:", s1)
		print("iters:", iters)
		print("cost:", cost)
		print("actual moves:", moves)
		print("predicted moves:", math.min(iters, math.ceil((s1/cost)*iters)))
	end
}
