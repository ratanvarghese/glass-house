local base = require("src.base")
local grid = require("src.grid")
local flood = require("src.flood")

property "flood.gradient: same result multiple times" {
	numtests = 1, --This is a slow test
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
	},
	check = function(targ_x, targ_y)
		local eligible = grid.make_full(function() return true end)
		local t1 = flood.gradient(targ_x, targ_y, eligible)
		local t2 = flood.gradient(targ_x, targ_y, eligible)
		return base.equals(t1, t2)
	end
}

property "flood.gradient: correct number of steps" {
	numtests = 10, --This is a slow test
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1)
	},
	check = function(targ_x, targ_y, start_x, start_y)
		local eligible = grid.make_full(function(x, y)
			--flood.gradient relies on eligible_f for bounds checking
			return not grid.is_edge(x, y)
		end)
		local t = flood.gradient(targ_x, targ_y, eligible)
		local start_i = grid.get_idx(start_x, start_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local expected = math.abs(targ_x - start_x) + math.abs(targ_y - start_y)
		local actual = t[start_i] - t[targ_i]
		return expected == actual
	end,
	when_fail = function(targ_x, targ_y, start_x, start_y)
		local eligible = grid.make_full(function(x, y)
			--flood.gradient relies on eligible_f for bounds checking
			return not grid.is_edge(x, y)
		end)
		local t = flood.gradient(targ_x, targ_y, eligible)
		local out = grid.make_full(function(x, y, i)
			if t[i] == 0 then
				return "@@@"
			elseif x == start_x and y == start_y then
				return "AAA"
			else
				return string.format("%02d,", t[i] % 100)
			end
		end)
		local start_i = grid.get_idx(start_x, start_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local expected = math.abs(targ_x - start_x) + math.abs(targ_y - start_y)
		local actual = t[start_i] - t[targ_i]
		print("")
		print("Expected: ", expected, "Actual: ", actual)
		print(cmdutil.full_string(out))
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
		local t = {[targ_i] = 0, [dummy_i] = math.huge}
		local eligible = grid.make_full(function(x, y, i)
			return not grid.is_edge(x, y)
		end)
		local f = function(x, y, i)
			return t[i] == 0
		end
		local res, res_x, res_y = flood.search(targ_x, targ_y, eligible, f)
		return res and res_x == targ_x and res_y == targ_y
	end
}

local function smallGrid(x, y, v1, v2, v3, v4)
	return {
		[grid.get_idx(x,y+1)] = v1,
		[grid.get_idx(x,y-1)] = v2,
		[grid.get_idx(x+1,y)] = v3,
		[grid.get_idx(x-1,y)] = v4
	}
end
property "flood.local_min: pick minimum value" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local res_v = flood.local_min(x, y, my_grid)
		return res_v == math.min(v1, v2, v3, v4)
	end,
	when_fail = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local expected = math.min(v1, v2, v3, v4) 
		local actual = flood.local_min(x, y, my_grid)
		print("Expected: ", expected)
		print("Actual: ", actual)
	end
}
property "flood.local_min: pick minimum coordinates" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local _, res_x, res_y = flood.local_min(x, y, my_grid)
		return my_grid[grid.get_idx(res_x, res_y)] == math.min(v1, v2, v3, v4)
	end,
	when_fail = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local expected = math.min(v1, v2, v3, v4) 
		local res, res_x, res_y = flood.local_min(x, y, my_grid)
		print("res: ", res)
		print("res_x: ", res_x)
		print("res_y: ", res_y)
	end
}
property "flood.local_min: return number as default result" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local my_grid = {} --Empty, so must use default value
		return type(flood.local_min(x, y, my_grid)) == "number"
	end
}
