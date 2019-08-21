local base = require("core.base")
local grid = require("core.grid")
local deque = require("core.deque")

local flood = {}

local not_edge = function(i) return not grid.is_edge(grid.get_xy(i)) end

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
