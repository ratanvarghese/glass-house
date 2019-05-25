local grid = require("src.grid")
local base = require("src.base")

local path = {}

function path.iter(old)
	return grid.make_full(function(x, y, i)
		local old_v = old[i]
		if old_v then
			local new_v = grid.adjacent_min(old, x, y) + 1
			return math.min(new_v, old_v)
		end
	end)
end

function path.init_array(targ_x, targ_y, eligible_f)
	local min = 0
	local max = grid.MAX_X * grid.MAX_Y
	return grid.make_full(function(x, y, i)
		if x == targ_x and y == targ_y then
			return min
		elseif eligible_f(x, y, i) then
			return max
		end
	end)
end

function path.to(targ_x, targ_y, eligible_f)
	local res = path.init_array(targ_x, targ_y, eligible_f)
	while true do
		local old = base.copy(res)
		res = path.iter(old)
		if base.equals(old, res) then
			break
		end
	end
	return res
end

return path
