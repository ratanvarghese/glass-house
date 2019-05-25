local grid = require("src.grid")

local unique_idx_set = {}
property "grid.get_idx: unique idx" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local i = grid.get_idx(x, y)
		local alreadyFound = unique_idx_set[i]
		unique_idx_set[i] = {x=x, y=y}
		if alreadyFound then
			return alreadyFound.x == x and alreadyFound.y == y
		else
			return true
		end
	end
}

property "grid.get_idx: error on string" {
	generators = { str(), int(1, grid.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() grid.get_idx(s,i) end)
		local ok_2 = pcall(function() grid.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "grid.get_idx: error on table" {
	generators = { tbl(), int(1, grid.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() grid.get_idx(s,i) end)
		local ok_2 = pcall(function() grid.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "grid.get_idx: error on bool" {
	generators = { bool(), int(1, grid.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() grid.get_idx(s,i) end)
		local ok_2 = pcall(function() grid.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}

property "grid.is_edge: across y" {
	generators = { int(1, grid.MAX_Y) },
	check = function(y)
		return grid.is_edge(1, y) and grid.is_edge(grid.MAX_X, y)
	end
}

property "grid.is_edge: across y" {
	generators = { int(1, grid.MAX_X) },
	check = function(x)
		return grid.is_edge(x, 1) and grid.is_edge(x, grid.MAX_Y)
	end
}

property "grid.is_edge: restricted to edge" {
	generators = { int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1) },
	check = function(x, y)
		return not grid.is_edge(x, y)
	end
}

property "grid.make_full: handles all points" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(test_x, test_y)
		local t = grid.make_full(function(x, y, i)
			return true
		end)
		return t[grid.get_idx(test_x, test_y)]
	end
}

property "grid.make_full: no extra points" {
	generators = { int(1, grid.MAX_X), int(grid.MAX_Y+1, grid.MAX_Y*2) },
	check = function(test_x, test_y)
		local t = grid.make_full(function(x, y, i)
			return true
		end)
		return not t[grid.get_idx(test_x, test_y)]
	end
}

property "grid.make_full: correct order" {
	generators = {},
	check = function()
		local res = true
		local last_x = 0
		grid.make_full(function(x, y, i)
			if x == last_x then
				res = false
			end
			last_x = x
		end)
		return res
	end
}

property "grid.rn_xy: x in range" {
	generators = {},
	check = function()
		local x = grid.rn_xy()
		return (x > 1) and (x < grid.MAX_X) and (x == math.floor(x))
	end
}

property "grid.rn_xy: y in range" {
	generators = {},
	check = function()
		local _, y = grid.rn_xy()
		return (y > 1) and (y < grid.MAX_Y) and (y == math.floor(y))
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
property "grid.adjacent_min: pick minimum value" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local res_v = grid.adjacent_min(my_grid, x, y)
		return res_v == math.min(v1, v2, v3, v4)
	end
}
property "grid.adjacent_min: pick minimum coordinates" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local _, res_x, res_y = grid.adjacent_min(my_grid, x, y)
		return my_grid[grid.get_idx(res_x, res_y)] == math.min(v1, v2, v3, v4)
	end
}
property "grid.adjacent_min: return number as default result" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local my_grid = {} --Empty, so must use default value
		return type(grid.adjacent_min(my_grid, x, y)) == "number"
	end
}
