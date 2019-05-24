local base = require("src.base")

local unique_idx_set = {}
property "base.get_idx: unique idx" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(x, y)
		local i = base.get_idx(x, y)
		local alreadyFound = unique_idx_set[i]
		unique_idx_set[i] = {x=x, y=y}
		if alreadyFound then
			return alreadyFound.x == x and alreadyFound.y == y
		else
			return true
		end
	end
}

property "base.get_idx: error on string" {
	generators = { str(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.get_idx(s,i) end)
		local ok_2 = pcall(function() base.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "base.get_idx: error on table" {
	generators = { tbl(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.get_idx(s,i) end)
		local ok_2 = pcall(function() base.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "base.get_idx: error on bool" {
	generators = { bool(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.get_idx(s,i) end)
		local ok_2 = pcall(function() base.get_idx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}

property "base.is_edge: across y" {
	generators = { int(1, base.MAX_Y) },
	check = function(y)
		return base.is_edge(1, y) and base.is_edge(base.MAX_X, y)
	end
}

property "base.is_edge: across y" {
	generators = { int(1, base.MAX_X) },
	check = function(x)
		return base.is_edge(x, 1) and base.is_edge(x, base.MAX_Y)
	end
}

property "base.is_edge: restricted to edge" {
	generators = { int(2, base.MAX_X-1), int(2, base.MAX_Y-1) },
	check = function(x, y)
		return not base.is_edge(x, y)
	end
}

property "base.for_all_points: handles all points" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(test_x, test_y)
		local t = {}
		base.for_all_points(function(x, y, i)
			t[i] = true
		end)
		return t[base.get_idx(test_x, test_y)]
	end
}

property "base.for_all_points: no extra points" {
	generators = { int(1, base.MAX_X), int(base.MAX_Y+1, base.MAX_Y*2) },
	check = function(test_x, test_y)
		local t = {}
		base.for_all_points(function(x, y, i)
			t[i] = true
		end)
		return not t[base.get_idx(test_x, test_y)]
	end
}

property "base.for_all_points: correct order" {
	generators = {},
	check = function()
		local res = true
		local last_x = 0
		base.for_all_points(function(x, y, i)
			if x == last_x then
				res = false
			end
			last_x = x
		end)
		return res
	end
}

property "base.rn_xy: x in range" {
	generators = {},
	check = function()
		local x = base.rn_xy()
		return (x > 1) and (x < base.MAX_X) and (x == math.floor(x))
	end
}

property "base.rn_xy: y in range" {
	generators = {},
	check = function()
		local _, y = base.rn_xy()
		return (y > 1) and (y < base.MAX_Y) and (y == math.floor(y))
	end
}


local function smallGrid(x, y, v1, v2, v3, v4)
	return {
		[base.get_idx(x,y+1)] = v1,
		[base.get_idx(x,y-1)] = v2,
		[base.get_idx(x+1,y)] = v3,
		[base.get_idx(x-1,y)] = v4
	}
end
property "base.adjacent_min: pick minimum value" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local grid = smallGrid(x, y, v1, v2, v3, v4)
		local res_v = base.adjacent_min(grid, x, y)
		return res_v == math.min(v1, v2, v3, v4)
	end
}
property "base.adjacent_min: pick minimum coordinates" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y), int(), int(), int(), int() },
	check = function(x, y, v1, v2, v3, v4)
		local grid = smallGrid(x, y, v1, v2, v3, v4)
		local _, res_x, res_y = base.adjacent_min(grid, x, y)
		return grid[base.get_idx(res_x, res_y)] == math.min(v1, v2, v3, v4)
	end
}
property "base.adjacent_min: return number as default result" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(x, y)
		local grid = {} --Empty, so must use default value
		return type(base.adjacent_min(grid, x, y)) == "number"
	end
}

property "base.equals: obviously equal values" {
	generators = { any() },
	check = function(a)
		if type(a) ~= "table" then
			local b = a
			return base.equals(a, b)
		end

		local b = {}
		for k,v in pairs(a) do
			b[k] = v
		end
		return base.equals(a, b)
	end
}

property "base.equals: obviously unequal values" {
	generators = { any(), any() },
	check = function(a, b)
		if a == b and type(a) ~= "table" then
			a = true
			b = false
		elseif type(a) == "table" and type(b) == "table" and a[1] == b[1] then
			a[1] = true
			b[1] = false
		end
		return not base.equals(a, b)
	end
}

property "base.copy: base.equals(original, copy)" {
	generators = { any() },
	check = function(a)
		return base.equals(a, base.copy(a))
	end
}

