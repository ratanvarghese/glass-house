local base = require("core.base")
local grid = require("core.grid")
local flood = require("core.flood")

property "flood.gradient: correct number of steps" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1)
	},
	check = function(targ_x, targ_y, start_x, start_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local start_i = grid.get_idx(start_x, start_y)
		local t = flood.gradient(targ_i)
		local expected = math.abs(targ_x - start_x) + math.abs(targ_y - start_y)
		local actual = t[start_i] - t[targ_i]
		return expected == actual
	end,
	when_fail = function(targ_x, targ_y, start_x, start_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local start_i = grid.get_idx(start_x, start_y)
		local t = flood.gradient(targ_i)
		local expected = math.abs(targ_x - start_x) + math.abs(targ_y - start_y)
		local actual = t[start_i] - t[targ_i]
		print("")
		print("Expected: ", expected, "Actual: ", actual)
		local prev_y
		for i,x,y,v in grid.points(t) do
			if y ~= prev_y then
				io.write("\n")
			end
			if v == 0 then
				io.write("@@@")
			elseif x == start_x and y == start_y then
				io.write("AAA")
			elseif v then
				io.write(string.format("%02d", v % 100))
			else
				io.write("   ")
			end
			prev_y = y
		end
	end
}

property "flood.search: finds target" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1)
	},
	check = function(targ_x, targ_y, dummy_x, dummy_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local dummy_i = grid.get_idx(dummy_x, dummy_y)
		local t = {[dummy_i] = math.huge, [targ_i] = 0} --Order matters if dummy_i == targ_i
		local f = function(i)
			return t[i] == 0
		end
		local res, res_i = flood.search(dummy_i, nil, f)
		return res and res_i == targ_i
	end
}

property "flood.search: return false if no target" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
	},
	check = function(dummy_x, dummy_y)
		local dummy_i = grid.get_idx(dummy_x, dummy_y)
		local t = {[dummy_i] = math.huge} 
		local f = function(i)
			return t[i] == 0
		end
		local res = flood.search(dummy_i, nil, f)
		return not res
	end

}
