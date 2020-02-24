clock = require("core.clock")

property "clock.init: respects new values" {
	generators = { int(), int() },
	check = function(max, max_id)
		local max = math.abs(max)
		local old_max = clock.scale.MAX
		local old_slow = clock.scale.SLOW_FACTOR
		local old_max_id = clock.scale.MAX_ID
		clock.init(max, max_id)
		local basic = (clock.scale.MAX == max)
		local derived = (clock.scale.PLAYER <= max and clock.scale.MOVE_COST <= max)
		local id = (clock.scale.MAX_ID == max_id)
		clock.init(old_max, old_max_id)
		return basic and derived and id
	end
}

property "clock: expected move speed" {
	generators = {
		int(0, clock.scale.MAX),
		int(1, clock.scale.MAX),
		bool(),
		int(1, clock.scale.MAX),
		bool()
	},
	check = function(speed, cost, ignore_cost, cred, ignore_cred)
		local c = clock.make(speed)
		local cost = cost
		if ignore_cost then
			cost = nil
		end
		if ignore_cred then
			cred = nil
		end
		clock.earn_credit(c, cred)
		local i = 0
		while clock.has_credit(c) do
			i = i + 1
			clock.spend_credit(c, cost)
		end
		if ignore_cost then
			cost = clock.scale.PLAYER
		end

		if ignore_cred or cred == speed then
			return i == math.ceil(speed/cost)
		elseif cred > speed then
			return i >= math.ceil(speed/cost)
		elseif cred < speed then
			return i <= math.ceil(speed/cost)
		else
			error("what's this?")
		end
	end
}

property "clock: unlimited zero-cost actions if speed > 0" {
	generators = {
		int(0, clock.scale.MAX),
		int(0, 100)
	},
	check = function(speed, iters)
		local c = clock.make(speed)
		clock.earn_credit(c)
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

property "clock.init, clock.make: increasing id" {
	generators = {
		int(0, 100),
		int()
	},
	check = function(count, max_id)
		local old_max_id = clock.scale.MAX_ID
		clock.init(clock.scale.MAX, max_id)
		local prev = max_id - 1
		for n = 1,count do
			local c = clock.make()
			if c.id <= prev then
				clock.init(clock.scale.MAX, old_max_id)
				return false
			end
			prev = c.id
		end
		local new_max_id = clock.scale.MAX_ID
		clock.init(clock.scale.MAX, old_max_id)
		return new_max_id == (max_id + count)
	end
}
