local enum = require("core.enum")
local base = require("core.base")
local grid = require("core.grid")

property "grid.init: respect new values" {
	generators = { int(1, 100), int(1, 100) },
	check = function(x, y)
		local old_x, old_y = grid.MAX_X, grid.MAX_Y
		grid.init(x, y)
		local res_max_xy = (grid.MAX_X == x and grid.MAX_Y == y)
		local res_max_pos = (grid.MAX_POS == grid.get_pos(grid.MAX_X, grid.MAX_Y))
		local res_min_pos = (grid.MIN_POS == grid.get_pos(1, 1))
		grid.init(old_x, old_y)
		return res_max_xy and res_max_pos and res_min_pos
	end
}

property "grid.init: error on bad input" {
	generators = { any(), any() },
	check = function(x, y)
		local old_x, old_y = grid.MAX_X, grid.MAX_Y
		local ok = pcall(function() grid.init(x, y) end)
		grid.init(old_x, old_y)
		return not ok or (type(x) == "number" and type(y) == "number")
	end
}

property "grid.get_pos: unique pos for each x, y combination" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y)
	},
	check = function(x1, x2, y1, y2)
		local xy_eq = (x1 == x2) and (y1 == y2)
		local pos_eq = grid.get_pos(x1, y1) == grid.get_pos(x2, y2)
		return xy_eq == pos_eq
	end
}

property "grid.get_pos: in range" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local p = grid.get_pos(x, y)
		return p <= grid.MAX_POS and p >= grid.MIN_POS
	end
}

property "grid.get_xy: reverse of grid.get_pos" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local nx, ny = grid.get_xy(grid.get_pos(x, y))
		return nx == x and ny == y
	end
}

property "grid.get_xy: in range" {
	generators = { int(grid.MIN_POS, grid.MAX_POS) },
	check = function (p)
		local x, y = grid.get_xy(p)
		return x <= grid.MAX_X and x >= 1 and y <= grid.MAX_Y and y >= 1
	end
}

property "grid.clip: clips x" {
	generators = { int(), int(), int(1, math.min(grid.MAX_X, grid.MAX_Y)/4) },
	check = function(x, y, n)
		local cx = grid.clip(x, y, n)
		if x < (1+n) then
			return cx == (1+n)
		elseif x > (grid.MAX_X-n) then
			return cx == (grid.MAX_X-n)
		else
			return cx == x
		end
	end
}

property "grid.clip: clips y" {
	generators = { int(), int(), int(1, math.min(grid.MAX_X, grid.MAX_Y)/4)},
	check = function(x, y, n)
		local _, cy = grid.clip(x, y, n)
		if y < (1+n) then
			return cy == (1+n)
		elseif y > (grid.MAX_Y-n) then
			return cy == (grid.MAX_Y-n)
		else
			return cy == y
		end
	end
}

property "grid.clip: default n = 0" {
	generators = { int(), int() },
	check = function(x, y)
		return grid.clip(x, y) == grid.clip(x, y, 0)
	end
}

property "grid.is_edge: across y" {
	generators = { int(1, grid.MAX_Y) },
	check = function(y)
		return grid.is_edge(1, y) and grid.is_edge(grid.MAX_X, y)
	end
}

property "grid.is_edge: across x" {
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

property "grid.points: handle all points with default arguments" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
	},
	check = function(x1, y1)
		local t = {}
		for i in grid.points() do
			t[i] = true
		end
		return t[grid.get_pos(x1, y1)]
	end

}

property "grid.points: handle all points if given arguments" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, x3, y1, y2, y3)
		local x_asc, y_asc = {x1, x2, x3}, {y1, y2, y3}
		table.sort(x_asc)
		table.sort(y_asc)
		local i_asc = {
			grid.get_pos(x_asc[1], y_asc[1]),
			grid.get_pos(x_asc[2], y_asc[2]),
			grid.get_pos(x_asc[3], y_asc[3])
		}
		local t = {}
		for i in grid.points(nil, i_asc[1], i_asc[3]) do
			t[i] = true
		end
		return t[i_asc[2]]
	end

}

property "grid.points: no extra points" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y)
	},
	check = function(x1, x2, x3, y1, y2, y3)
		local x_asc, y_asc = {x1, x2, x3}, {y1, y2, y3}
		table.sort(x_asc)
		table.sort(y_asc)
		local i_asc = {
			grid.get_pos(x_asc[1], y_asc[1]),
			grid.get_pos(x_asc[2], y_asc[2]),
			grid.get_pos(x_asc[3], y_asc[3])
		}
		local t = {}
		for i in grid.points(nil, i_asc[1], i_asc[2]) do
			t[i] = true
		end
		if i_asc[2] ~= i_asc[3] then
			return not t[i_asc[3]]
		else
			return true
		end
	end
}

property "grid.points: correct order" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, y1, y2)
		local x_asc, y_asc = {x1, x2}, {y1, y2}
		table.sort(x_asc)
		table.sort(y_asc)
		local got_small_pt = false
		for _,x,y in grid.points() do
			if x == x_asc[1] and y == y_asc[1] then
				got_small_pt = true
			end
			if x == x_asc[2] and y == y_asc[2] and not got_small_pt then
				return false
			end
		end
		return true
	end
}

property "grid.points: get v" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
		any(),
		any()
	},
	check = function(x1, x2, y1, y2, v1, v2)
		if x1 == x1 and y1 == y2 then
			return true
		end
		local t = {
			[grid.get_pos(x1, y1)] = v1,
			[grid.get_pos(x2, y2)] = v2
		}
		for _,x,y,v in grid.points(t) do
			if x == x1 and y == y1 and v ~= v1 then
				return false
			elseif x == x2 and y == y2 and v ~= v2 then
				return false
			end
		end
		return true
	end
}

property "grid.travel: correct destination" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(-10, 10),
		bool(),
		int(1, math.min(grid.MAX_X, grid.MAX_Y)/4),
		bool(),
		int(1, #grid.direction_list)
	},
	check = function(x, y, distance, omit_distance, clipn, omit_clipn, direction_i)
		local direction = grid.direction_list[direction_i]
		local start_i = grid.get_pos(x, y)
		if omit_distance then
			distance = nil
		end
		if omit_clipn then
			clipn = nil
		end
		local res_x, res_y = grid.get_xy(grid.travel(start_i, distance, direction, clipn))
		if omit_distance then
			distance = 1
		end
		if direction == enum.cmd.north then
			local expect_x, expect_y = grid.clip(x, y - distance, clipn)
			return res_x == expect_x and res_y == expect_y
		elseif direction == enum.cmd.south then
			local expect_x, expect_y = grid.clip(x, y + distance, clipn)
			return res_x == expect_x and res_y == expect_y
		elseif direction == enum.cmd.east then
			local expect_x, expect_y = grid.clip(x + distance, y, clipn)
			return res_x == expect_x and res_y == expect_y
		elseif direction == enum.cmd.west then
			local expect_x, expect_y = grid.clip(x - distance, y, clipn)
			return res_x == expect_x and res_y == expect_y
		else
			error("Bad direction")
		end
	end
}

property "grid.travel: omit direction" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(-10, 10),
		bool(),
	},
	check = function(x, y, distance, omit_distance)
		if omit_distance then
			distance = nil
		end
		local start_i = grid.get_pos(x, y)
		local res_i = grid.travel(start_i, distance)
		local expected = {
			[grid.travel(start_i, distance, enum.cmd.north)] = true,
			[grid.travel(start_i, distance, enum.cmd.south)] = true,
			[grid.travel(start_i, distance, enum.cmd.east)] = true,
			[grid.travel(start_i, distance, enum.cmd.west)] = true,
		}
		return expected[res_i]
	end
}

property "grid.line: start at i1" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(i1, i2)
		return grid.line(i1, i2)[1] == i1
	end
}

property "grid.line: end at i2" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(i1, i2)
		local res = grid.line(i1, i2)
		return res[#res] == i2
	end
}

property "grid.line: adjacent list elements are adjacent coordinates" {
	generators = {
 		int(grid.MIN_POS, grid.MAX_POS),
 		int(grid.MIN_POS, grid.MAX_POS),
		int(2, grid.MAX_X + grid.MAX_Y)
	},
	check = function(i1, i2, list_i)
		local res = grid.line(i1, i2)
		if #res < 2 then
			return true
		end

		local list_i = base.clip(list_i, 2, #res)
		return grid.distance(res[list_i - 1], res[list_i]) == 1
	end,
	when_fail = function(i1, i2)
		local res = grid.line(i1, i2)
		print("")
		for i,v in ipairs(res) do
			local x, y = grid.get_xy(v)
			print("i:", i, "x:", x, "y:", y)
		end
	end
}

property "grid.line: correct length" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(i1, i2)
		return #(grid.line(i1, i2)) == (grid.distance(i1, i2) + 1)
	end,
	when_fail = function(i1, i2)
		local res = grid.line(i1, i2)
		print("")
		for i,v in ipairs(res) do
			print("i:", i, "x:", v.x, "y:", v.y)
		end
	end
}

local function smallGrid(x, y, v1, v2, v3, v4)
	return {
		[grid.get_pos(x,y+1)] = v1,
		[grid.get_pos(x,y-1)] = v2,
		[grid.get_pos(x+1,y)] = v3,
		[grid.get_pos(x-1,y)] = v4
	}
end
property "grid.adjacent_extreme: pick correct value" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(),
		int(),
		int(),
		int(),
		bool()
	 },
	check = function(x, y, v1, v2, v3, v4, domax)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local i = grid.get_pos(x, y)
		local cmp = domax and math.max or math.min
		return grid.adjacent_extreme(i, my_grid, domax) == cmp(v1, v2, v3, v4)
	end,
	when_fail = function(x, y, v1, v2, v3, v4, domax)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local cmp = domax and math.max or math.min
		local expected = cmp(v1, v2, v3, v4)
		local i = grid.get_pos(x, y) 
		local actual = grid.adjacent_extreme(i, my_grid, domax)
		print("Expected: ", expected)
		print("Actual: ", actual)
	end
}
property "grid.adjacent_extreme: pick correct coordinates" {
	generators = {
		int(2, grid.MAX_X-1),
		int(2, grid.MAX_Y-1),
		int(),
		int(),
		int(),
		int(),
		bool()
	 },
	check = function(x, y, v1, v2, v3, v4, domax)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local i = grid.get_pos(x, y)
		local cmp = domax and math.max or math.min
		local _, res_i = grid.adjacent_extreme(i, my_grid, domax)
		return my_grid[res_i] == cmp(v1, v2, v3, v4)
	end,
	when_fail = function(x, y, v1, v2, v3, v4)
		local my_grid = smallGrid(x, y, v1, v2, v3, v4)
		local cmp = domax and math.max or math.min
		local expected = cmp(v1, v2, v3, v4)
		local i = grid.get_pos(x, y)
		local res, res_i = grid.adjacent_extreme(i, my_grid, domax)
		print("res: ", res)
		print("res_i: ", res_i)
	end
}
property "grid.adjacent_extreme: return number as default result" {
	generators = { int(2, grid.MAX_X-1), int(2, grid.MAX_Y-1), bool() },
	check = function(x, y, domax)
		local my_grid = {} --Empty, so must use default value
		local i = grid.get_pos(x, y)
		return type(grid.adjacent_extreme(i, my_grid, domax)) == "number"
	end
}

property "grid.distance: expected distance" {
	generators = {
		int(1, grid.MAX_X),
		int(0, grid.MAX_X - 1),
		int(1, grid.MAX_Y),
		int(0, grid.MAX_Y - 1)
	},
	check = function(x, dx, y, dy)
		local dx = base.clip(dx, 0, grid.MAX_X - x)
		local dy = base.clip(dy, 0, grid.MAX_Y - y)
		local i1 = grid.get_pos(x, y)
		local i2 = grid.get_pos(x + dx, y + dy)
		local res = grid.distance(i1, i2)
		return res == (dx + dy)
	end
}

property "grid.distance: same result with arguments reversed" {
	generators = { int(grid.MIN_POS, grid.MAX_POS), int(grid.MIN_POS, grid.MAX_POS) },
	check = function(i1, i2)
		return grid.distance(i1, i2) == grid.distance(i2, i1)
	end
}

property "grid.destinations: correct distance for default direction list" {
	generators = { int(grid.MIN_POS, grid.MAX_POS) },
	check = function(start)
		local count = 0
		for _,pos in grid.destinations(start) do
			if grid.distance(start, pos) ~= 1 then
				return false
			end
			count = count + 1
		end
		return count <= 4 and count >= 2
	end
}

property "grid.destinations: skip out-of-bounds results" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(x, y)
		local x = (x < grid.MAX_X) and 1 or grid.MAX_X
		local y = (y < grid.MAX_Y) and 1 or grid.MAX_Y
		local start = grid.get_pos(x, y)
		local count = 0
		for _,pos in grid.destinations(start) do
			local dest_x, dest_y = grid.get_xy(pos)
			if dest_x < 1 or dest_x > grid.MAX_X or dest_y < 1 or dest_y > grid.MAX_Y then
				return false
			elseif grid.distance(start, pos) ~= 1 then
				return false
			end
			count = count + 1
		end
		return count == 2
	end
}

property "grid.destinations: custom direction table" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(0, 3)
	},
	check = function(dx, dy, dlen)
		local dlist = {
			{x = dx, y = 0},
			{x = 0, y = dy},
			{x = dx, y = dy}
		}
		local old_dlen = #dlist
		for i=old_dlen,dlen+1,-1 do
			dlist[i] = nil
		end
		local start = grid.get_pos(1, 1)
		local count = 0
		for _,pos in grid.destinations(start, dlist) do
			local dest_x, dest_y = grid.get_xy(pos)
			if dest_x ~= (dx + 1) and dest_x ~= 1 then
				return false
			elseif dest_y ~= (dy + 1) and dest_y ~= 1 then
				return false
			end
			count = count + 1
		end
		if dx == grid.MAX_X and dy == grid.MAX_Y then
			return count == 0
		elseif dx == grid.MAX_X then
			return (dlen > 1) and 1 or 0
		elseif dy == grid.MAX_Y then
			return (dlen > 0) and 1 or 0
		else
			return count == dlen
		end
	end
}