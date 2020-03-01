--- Track whether entity is ready to act.
-- @module core.clock

local clock = {}

clock.scale = {}

--- Table containing entity speed and movement information.
-- Anything in the game that changes with time should have an associated clock.
-- If a clock has credit, that means the associated entity is ready to act.
-- After an action, the entity should spend some credit.
-- @typedef clock.clock


--- Make a clock of speed `n`
-- @tparam int n
-- @treturn clock.clock
function clock.make(n)
	clock.scale.MAX_ID = clock.scale.MAX_ID + 1
	return {speed = n, credit = 0, id = clock.scale.MAX_ID}
end

--- Earn credit for a clock
-- @tparam clock.clock clk
-- @tparam[opt] int cred credit to earn, default to `clk`'s speed
function clock.earn_credit(clk, cred)
	local cred = cred or clk.speed
	clk.credit = clk.credit + cred
end

--- Check if clock has credit (and associated entity can act)
-- @tparam clock.clock clk
-- @treturn bool
function clock.has_credit(clk)
	return clk.credit > 0
end

--- Spend credit for a clock
-- @tparam clock.clock clk
-- @tparam[opt] int cost default to cost player takes to move.
function clock.spend_credit(clk, cost)
	local cost = cost or clock.scale.PLAYER
	clk.credit = clk.credit - cost
end

--- Initialize the `core.clock` module.
-- @tparam int max new maximum speed
-- @tparam int max_id the initial clock id
function clock.init(max, max_id)

	--- The maximum speed
	clock.scale.MAX = max

	--- The speed of the player
	clock.scale.PLAYER = clock.scale.MAX / 2

	--- The cost for the player to move 1 step
	clock.scale.MOVE_COST = clock.scale.MAX

	clock.scale.MAX_ID = max_id
	return clock
end

return clock.init(16, 0)
