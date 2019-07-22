clock = require("core.clock")

property "clock.init: respects new values" {
	generators = { int(), int() },
	check = function(max, slow_factor)
		local max = math.abs(max)
		local slow_factor = math.abs(slow_factor)
		local old_max = clock.scale.MAX
		local old_slow = clock.scale.SLOW_FACTOR
		clock.init(max, slow_factor)
		local basic = (clock.scale.MAX == max and clock.scale.SLOW_FACTOR == slow_factor)
		local derived = (clock.scale.PLAYER <= max and clock.scale.MOVE_COST <= max)
		clock.init(old_max, old_slow)
		return basic and derived
	end
}

property "clock: expected move speed" {
	generators = {
		int(0, clock.scale.MAX),
		int(1, clock.scale.MAX),
		bool(),
		bool()
	},
	check = function(speed, cost, slow, ignore_cost)
		local c = clock.make(speed)
		local cost = cost
		if ignore_cost then
			cost = nil
		end
		clock.earn_credit(c, slow)
		local i = 0
		while clock.has_credit(c) do
			i = i + 1
			clock.spend_credit(c, cost)
		end
		if ignore_cost then
			cost = clock.scale.PLAYER
		end
		if slow then
			return i == math.ceil(math.ceil(speed/clock.scale.SLOW_FACTOR)/cost)
		else
			return i == math.ceil(speed/cost)
		end
	end
}

property "clock: unlimited zero-cost actions if speed > 0" {
	generators = {
		int(0, clock.scale.MAX),
		bool(),
		int(0, 100)
	},
	check = function(speed, slow, iters)
		local c = clock.make(speed)
		clock.earn_credit(c, slow)
		local i = 0
		while clock.has_credit(c) and i < iters do
			i = i + 1
			clock.spend_credit(c, 0)
		end
		if speed > 0 then
			return i == iters
		else
			return i == 0
		end
	end
}

property "clock: default speed == time.scale.PLAYER" {
	generators = {
		int(1, clock.scale.MAX),
	},
	check = function(cost)
		local clist = {
			clock.make(),
			clock.make(clock.scale.PLAYER)
		}
		local turn_count = {0, 0}
		for ci,c in ipairs(clist) do
			while clock.has_credit(c) do
				turn_count[ci] = turn_count[ci] + 1
				clock.spend_credit(c, cost)
			end
		end
		return turn_count[1] == turn_count[2]
	end
}
