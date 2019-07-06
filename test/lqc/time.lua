local time = require("src.time")

property "time.*: expected move speed" {
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

local function make_freq(count)
	local freq = {}
	for i=0,time.scale.MAX do
		freq[i] = 0
	end
	for i=1,count do
		local s = time.make_actor().speed
		freq[s] = freq[s] + 1
	end
	return freq
end

--[[
	It's okay if these distribution tests sometimes fail.
	However it should be a minority of cases.
--]]
property "time.make_actor (distribution): immobiles exist" {
	generators = {},
	check = function()
		return make_freq(100)[0] > 0
	end
}

property "time.make_actor (distribution): max speeds exist" {
	generators = {},
	check = function()
		return make_freq(100)[time.scale.MAX] > 0
	end
}

property "time.make_actor (distribution): player speeds exist" {
	generators = {},
	check = function()
		return make_freq(100)[time.scale.PLAYER] > 0
	end
}

property "time.make_actor (distribution): middling speeds dominate" {
	generators = {},
	check = function()
		local freq = make_freq(100)
		local tMax = time.scale.MAX
		local edge_freq = freq[0] + freq[1] + freq[tMax - 1] + freq[tMax]
		return edge_freq < 50
	end
}
