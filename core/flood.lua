--- Flood fills
-- @module core.flood

local base = require("core.base")
local grid = require("core.grid")
local deque = require("core.deque")

local flood = {}

--- Return true if position `i` is not an edge
-- @tparam pos i see `core.grid`
-- @treturn bool
local not_edge = function(i) return not grid.is_edge(grid.get_xy(i)) end

--- Assign increasing values to eligible points as they get further from `i`.
-- `eligible` takes an integer position (see `core.grid`) as a parameter, and returns a
-- truthy value if it is an eligible position to be flooded by this gradient.
-- The result table will have eligible integer positions as keys and values greater than
-- or equal to `v`.
-- @tparam pos i see `core.grid`
-- @tparam[opt] func eligible defaults to `not_edge`
-- @tparam[opt=0] int v the value at the start point
-- @treturn table
function flood.gradient(i, eligible, v)
	local v = v or 0
	local eligible = eligible or not_edge

	local res = {[i] = v}
	local Q = deque.new()
	deque.push_back(Q, {i, v})
	while deque.len(Q) > 0 do
		local old = deque.pop_front(Q)
		for _, new_i in grid.destinations(old[1]) do
			if not res[new_i] and eligible(new_i) then
				local new_v = old[2] + 1
				res[new_i] = new_v
				deque.push_back(Q, {new_i, new_v})
			end
		end
	end
	if not eligible(i) then
		res[i] = nil
	end
	return res
end

--- Search eligible positions reachable from `i` for position satisfying `f`.
-- `eligible` takes an integer position (see `core.grid`) as a parameter, and returns a
-- truthy value if it is an eligible position to be flooded by this gradient.
-- `f` takes an integer position as a parameter, and returns a truthy value if it is
-- satisfied.
-- @tparam pos i see `core.grid`
-- @tparam[opt] func eligible defaults to `not_edge`
-- @tparam func f
-- @treturn bool `f` was satisfied by an eligible position reachable from `i`.
-- @treturn[opt] pos if `f` was satisfied, position that satisfied `f`
function flood.search(i, eligible, f)
	local eligible = eligible or not_edge
	if f(i) then
		return true, i
	end

	local finished = {[i] = true}
	local Q = deque.new()
	deque.push_back(Q, i)
	while deque.len(Q) > 0 do
		local old_i = deque.pop_front(Q)
		for _, new_i in grid.destinations(old_i) do
			if not finished[new_i] then
				if eligible(new_i) and f(new_i) then
					return true, new_i
				end
				finished[new_i] = true
				deque.push_back(Q, new_i)
			end
		end
	end
	return false
end

return flood
