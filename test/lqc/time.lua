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
		local clock = time.make_clock(s1)
		local moves = 0
		for i=1,iters do
			if time.earn_credit(clock) then
				time.spend_move(clock)
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
		local clock = time.make_clock(s1)
		local moves = 0
		for i=1,iters do
			io.write("i = ", i, ":\t")
			io.write("credit = ", clock.move_credit, "\t")
			if time.earn_credit(clock) then
				io.write("\tm\t")
				time.spend_move(clock)
				moves = moves + 1
			else
				io.write("\t\t")
			end
			io.write("credit = ", clock.move_credit, "\n")
		end
		time.scale.MOVE_COST = old_cost
		print("speed:", s1)
		print("iters:", iters)
		print("cost:", cost)
		print("actual moves:", moves)
		print("predicted moves:", math.min(iters, math.ceil((s1/cost)*iters)))
	end
}

property "time.*: expected move speed when slow" {
	generators = {
		int(0, time.scale.MAX),
		int(1, time.scale.MAX*4),
		int(1, time.scale.MAX),
		int(1, time.scale.MAX)
	},
	check = function(s1, iters, cost, slow_factor)
		local old_slow = time.scale.SLOW_FACTOR
		time.scale.SLOW_FACTOR = slow_factor
		local old_cost = time.scale.MOVE_COST
		time.scale.MOVE_COST = cost
		local clock = time.make_clock(s1)
		local moves = 0
		for i=1,iters do
			if time.earn_credit(clock, true) then
				time.spend_move(clock)
				moves = moves + 1
			end
		end
		time.scale.MOVE_COST = old_cost
		time.scale.SLOW_FACTOR = old_slow
		local n_speed = math.ceil(s1/slow_factor)
		return moves == math.min(iters, math.ceil((n_speed/cost)*iters))
	end,
	when_fail = function(s1, iters, cost, slow_factor)
		print("---------------")
		local old_slow = time.scale.SLOW_FACTOR
		time.scale.SLOW_FACTOR = slow_factor
		local old_cost = time.scale.MOVE_COST
		time.scale.MOVE_COST = cost
		local clock = time.make_clock(s1)
		local moves = 0
		for i=1,iters do
			io.write("i = ", i, ":\t")
			io.write("credit = ", clock.move_credit, "\t")
			if time.earn_credit(clock, true) then
				io.write("\tm\t")
				time.spend_move(clock)
				moves = moves + 1
			else
				io.write("\t\t")
			end
			io.write("credit = ", clock.move_credit, "\n")
		end
		time.scale.MOVE_COST = old_cost
		time.scale.SLOW_FACTOR = old_slow
		print("speed:", s1)
		print("iters:", iters)
		print("cost:", cost)
		print("slow:", slow_factor)
		print("actual moves:", moves)
		local n_speed = math.ceil(s1/slow_factor)
		print("predicted moves:", math.min(iters, math.ceil((n_speed/cost)*iters)))
	end
}

local function make_freq(count)
	local freq = {}
	for i=0,time.scale.MAX do
		freq[i] = 0
	end
	for i=1,count do
		local s = time.make_clock().speed
		freq[s] = freq[s] + 1
	end
	return freq
end

--[[
	It's okay if these distribution tests sometimes fail.
	However it should be a minority of cases.
--]]
property "time.make_clock (distribution): immobiles exist" {
	generators = {},
	check = function()
		return make_freq(100)[0] > 0
	end
}

property "time.make_clock (distribution): max speeds exist" {
	generators = {},
	check = function()
		return make_freq(100)[time.scale.MAX] > 0
	end
}

property "time.make_clock (distribution): player speeds exist" {
	generators = {},
	check = function()
		return make_freq(100)[time.scale.PLAYER] > 0
	end
}

property "time.make_clock (distribution): middling speeds dominate" {
	generators = {},
	check = function()
		local freq = make_freq(100)
		local tMax = time.scale.MAX
		local edge_freq = freq[0] + freq[1] + freq[tMax - 1] + freq[tMax]
		return edge_freq < 50
	end
}
