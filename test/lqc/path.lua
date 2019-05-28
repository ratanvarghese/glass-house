local grid = require("src.grid")
local path = require("src.path")
local cmdutil = require("ui.cmdutil")

property "path.init_array: uniform maximum value greater than value at target" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(targ_x, targ_y)
		local t = path.init_array(targ_x, targ_y, function() return true end)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local min = t[targ_i]
		local uniform = true
		local max = nil
		grid.make_full(function(x, y, i)
			if i == targ_i then return end
			if not max then
				max = t[i]
			elseif t[i] ~= max then
				uniform = false
			end
		end)
		return uniform and max > min
	end
}

property "path.init_array: if no space eligible, include target only" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(targ_x, targ_y)
		local t = path.init_array(targ_x, targ_y, function() return false end)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local target_only = true
		grid.make_full(function(x, y, i)
			if i ~= targ_i and t[i] then
				target_only = false
			end
		end)
		return t[targ_i] and target_only
	end
}

property "path.init_array: respect eligible_f" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(1, grid.MAX_X*grid.MAX_Y) },
	check = function(targ_x, targ_y, dice_sides)
		local eligible_t = grid.make_full(function()
			return math.random(1, dice_sides) == 1
		end)
		local t = path.init_array(targ_x, targ_y, function(x, y, i)
			return eligible_t[i]
		end)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local matched_eligible = true
		grid.make_full(function(x, y, i)
			if i == targ_i then return end
			if (t[i] and not eligible_t[i]) then
				matched_eligible = false
			elseif (not t[i] and eligible_t[i]) then
				matched_eligible = false
			end
		end)
		return matched_eligible
	end
}

property "path.iter: output is adjacent_min + 1 of input everywhere" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_X*grid.MAX_Y)
	},
	check = function(x, y, dice_sides)
		local old = grid.make_full(function()
			return math.random(0, dice_sides)
		end)
		local new = path.iter(old)
		local i = grid.get_idx(x, y)
		if old[i] then
			local adjmin = grid.adjacent_min(old, x, y) + 1
			return new[i] == math.min(old[i], adjmin)
		else
			return true
		end
	end
}

property "path.to: correct number of steps" {
	numtests = 10, --This is a slow test
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1)
	},
	check = function(targ_x, targ_y, start_x, start_y)
		local t = path.to(targ_x, targ_y, function(x, y)
			--path.to relies on eligible_f for bounds checking
			return not grid.is_edge(x, y)
		end)
		local start_i = grid.get_idx(start_x, start_y)
		local targ_i = grid.get_idx(targ_x, targ_y)
		local expected = math.abs(targ_x - start_x) + math.abs(targ_y - start_y)
		local actual = t[start_i] - t[targ_i]
		return expected == actual
	end,
	when_fail = function(targ_x, targ_y, start_x, start_y)
		local t = path.to(targ_x, targ_y, function() return true end)
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
