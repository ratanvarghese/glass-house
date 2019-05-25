local grid = require("src.grid")
local base = require("src.base")

local path = {}

function path.iter(old)
	local res = {}
	grid.for_all_points(function(x, y, i)
		local old_v = old[i]
		if old_v then
			local new_v = grid.adjacent_min(old, x, y) + 1
			res[i] = math.min(new_v, old_v)
		end
	end)
	return res
end

function path.init_array(targ_x, targ_y, eligible_f)
	local res = {}
	local max = grid.MAX_X * grid.MAX_Y
	local min = 0

	grid.for_all_points(function(x, y, i)
		if x == targ_x and y == targ_y then
			res[i] = min
		elseif eligible_f(x, y, i) then
			res[i] = max
		end
	end)
	return res
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
