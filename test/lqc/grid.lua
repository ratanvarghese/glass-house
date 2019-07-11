local base = require("src.base")
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
		if tonumber(s) then return true end
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

property "grid.get_xy: reverse of grid.get_idx" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local nx, ny = grid.get_xy(grid.get_idx(x, y))
		return x == nx and y == ny
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

property "grid.make_rect: handles all points" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, x3, y1, y2, y3)
		local x_asc = {x1, x2, x3}
		table.sort(x_asc)
		local y_asc = {y1, y2, y3}
		table.sort(y_asc)
		local t = grid.make_rect(x_asc[1], y_asc[1], x_asc[3], y_asc[3], base.true_f)
		return t[grid.get_idx(x_asc[2], y_asc[2])]
	end
}

property "grid.make_rect: no extra points" {
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
		local t = grid.make_rect(x_asc[1], y_asc[1], x_asc[2], y_asc[2], base.true_f)
		local id_2 = grid.get_idx(x_asc[2], y_asc[2])
		local id_3 = grid.get_idx(x_asc[3], y_asc[3])
		if id_2 ~= id_3 then
			return not t[id_3]
		else
			return true
		end
	end
}

property "grid.make_rect: correct order" {
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
		if y_asc[1] == y_asc[3] then
			return true
		end
		local res = true
		grid.make_full(function(x, y, i)
			if x == last_x then
				res = false
			end
			last_x = x
		end)
		return res
	end
}

property "grid.make_full: handles all points" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(test_x, test_y)
		local t = grid.make_full(base.true_f)
		return t[grid.get_idx(test_x, test_y)]
	end
}

property "grid.make_full: no extra points" {
	generators = { int(1, grid.MAX_X), int(grid.MAX_Y+1, grid.MAX_Y*2) },
	check = function(test_x, test_y)
		local t = grid.make_full(base.true_f)
		return not t[grid.get_idx(test_x, test_y)]
	end
}

property "grid.make_full: correct order" {
	generators = {},
	numtests = 1,
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

property "grid.edit_full: overwrite targets" {
	generators = { int(1, grid.MAX_X), int(1, grid.MAX_Y) },
	check = function(x, y)
		local t = {}
		local i = grid.get_idx(x, y)
		t[i] = false
		grid.edit_full(t, base.true_f)
		return t[i]
	end
}

property "grid.edit_full: do not overwrite non-targets" {
	generators = { int(1, grid.MAX_X), int(grid.MAX_Y+1, grid.MAX_Y*2) },
	check = function(x, y)
		local t = {}
		local i = grid.get_idx(x, y)
		t[i] = false
		grid.edit_full(t, base.true_f)
		return t[i] == false --make sure it's not nil!
	end
}

property "grid.edit_rect: overwrite targets" {
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
		local t = {}
		local i = grid.get_idx(x_asc[2], y_asc[2])
		t[i] = false
		grid.edit_rect(x_asc[1], y_asc[1], x_asc[3], y_asc[3], t, base.true_f)
		return t[i]
	end
}

property "grid.edit_rect: do not overwrite non-targets" {
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
		local t = {}
		local i = grid.get_idx(x_asc[3], y_asc[3])
		t[i] = false
		grid.edit_rect(x_asc[1], y_asc[1], x_asc[2], y_asc[2], t, base.true_f)
		if i == grid.get_idx(x_asc[2], y_asc[2]) then
			return true
		else
			return t[i] == false --make sure it's not nil!
		end
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

property "grid.are_adjacent: inclusive" {
	generators = {
		int(2, grid.MAX_X - 1),
		int(2, grid.MAX_Y - 1),
	},
	check = function(x, y)
		local res_1 = grid.are_adjacent(x, y, x+1, y)
		local res_2 = grid.are_adjacent(x, y, x-1, y)
		local res_3 = grid.are_adjacent(x, y, x, y+1)
		local res_4 = grid.are_adjacent(x, y, x, y-1)
		return res_1 and res_2 and res_3 and res_4
	end
}

property "grid.are_adjacent: exclude repeated point" {
	generators = {
		int(2, grid.MAX_X - 1),
		int(2, grid.MAX_Y - 1),
	},
	check = function(x, y)
		return not grid.are_adjacent(x, y, x, y)
	end
}

property "grid.are_adjacent: exclusive" {
	generators = {
		int(2, grid.MAX_X - 1),
		int(2, grid.MAX_X - 1),
		int(2, grid.MAX_Y - 1),
		int(2, grid.MAX_Y - 1),
	},
	check = function(x1, x2, y1, y2)
		if x1 == x2 and math.abs(y1 - y2) == 1 then
			x2 = x2 + 1
		elseif y1 == y2 and math.abs(x1 - x2) == 1 then
			y2 = y2 + 1
		end
		return not grid.are_adjacent(x1, y1, x2, y2)
	end
}

property "grid.line: start at x1, y1" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		return res[1].x == x1 and res[1].y == y1
	end
}

property "grid.line: end at x2, y2" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		return res[#res].x == x2 and res[#res].y == y2
	end
}

property "grid.line: adjacent list elements are adjacent coordinates" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		for i,v in ipairs(res) do
			if i > 1 and not grid.are_adjacent(res[i-1].x, res[i-1].y, v.x, v.y) then
				return false
			end
		end
		return true
	end,
	when_fail = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		print("")
		for i,v in ipairs(res) do
			print("i:", i, "x:", v.x, "y:", v.y)
		end
	end
}

property "grid.line: correct length" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, grid.MAX_Y),
	},
	check = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		local dx = math.abs(x2 - x1)
		local dy = math.abs(y2 - y1)
		return #res == (dx + dy + 1)
	end,
	when_fail = function(x1, x2, y1, y2)
		local res = grid.line(x1, y1, x2, y2)
		print("")
		for i,v in ipairs(res) do
			print("i:", i, "x:", v.x, "y:", v.y)
		end
	end
}

property "grid.knight_jumps: correct length" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y)
	},
	check = function(x, y)
		local jumps = grid.knight_jumps()[grid.get_idx(x, y)]
		local x_from_edge = math.min(x, grid.MAX_X - x + 1)
		local y_from_edge = math.min(y, grid.MAX_Y - y + 1)
		if x_from_edge == 1 and y_from_edge == 1 then
			return #jumps == 2
		elseif x_from_edge == 1 and y_from_edge == 2 then
			return #jumps == 3
		elseif x_from_edge == 2 and y_from_edge == 1 then
			return #jumps == 3
		elseif x_from_edge == 1 or y_from_edge == 1 then
			return #jumps == 4
		elseif x_from_edge == 2 and y_from_edge == 2 then
			return #jumps == 4
		elseif x_from_edge == 2 or y_from_edge == 2 then
			return #jumps == 6
		else
			return #jumps == 8
		end
	end,
	when_fail = function(x, y)
		local jumps = grid.knight_jumps()[grid.get_idx(x, y)]
		print("\nx:", x, "y:", y)
		for _,v in ipairs(jumps) do
			print("jx:", v.x, "jy:", v.y)
		end
	end
}

property "grid.knight_jumps: elements have valid x,y" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 8)
	},
	check = function(x, y, ji)
		local jumps = grid.knight_jumps()[grid.get_idx(x, y)]
		if ji > #jumps then ji = #jumps end
		local j = jumps[ji]
		local abs_dx, abs_dy = math.abs(j.x - x), math.abs(j.y - y)
		if abs_dx == 2 then
			return abs_dy == 1
		elseif abs_dx == 1 then
			return abs_dy == 2
		else
			return false
		end
	end
}

property "grid.knight_jumps: elements have valid i" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 8)
	},
	check = function(x, y, ji)
		local jumps = grid.knight_jumps()[grid.get_idx(x, y)]
		if ji > #jumps then ji = #jumps end
		local j = jumps[ji]
		return j.i == grid.get_idx(j.x, j.y)
	end
}

property "grid.knight_jumps: elements distinct" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 8),
		int(1, 8)
	},
	check = function(x, y, ji_1, ji_2)
		local jumps = grid.knight_jumps()[grid.get_idx(x, y)]
		if ji_1 > #jumps then ji_1 = 1 end
		if ji_2 > #jumps then ji_2 = #jumps end
		return (ji_1 == ji_2) == base.equals(jumps[ji_1], jumps[ji_2])
	end
}

property "grid.knight_jumps: consistent content" {
	generators = { bool(), bool() },
	numtests = 8, --This is a slow test
	check = function(refresh1, refresh2)
		local t1 = grid.knight_jumps(refresh1)
		local t2 = grid.knight_jumps(refresh2)
		return base.equals(t1, t2)
	end
}

property "grid.knight_jumps: refresh" {
	generators = { bool() },
	numtests = 8, --This is a slow test
	check = function(refresh)
		local t1 = grid.knight_jumps(true)
		local t2 = grid.knight_jumps(refresh)
		return (not refresh) == (t1 == t2)
	end
}

property "grid.knight: covered" {
	generators = {
		int(1, grid.MAX_X),
		int(1, grid.MAX_Y),
		int(1, 8)
	},
	check = function(x, y, ji)
		local origin_i = grid.get_idx(x, y)
		local jumps = grid.knight_jumps()[origin_i]
		if ji > #jumps then ji = #jumps end
		local j = jumps[ji]
		local lines = {
			grid.line(x, y, j.x, y),
			grid.line(x, y, x, j.y),
			grid.line(j.x, j.y, j.x, y),
			grid.line(j.x, j.y, x, j.y)
		}
		local predicted = {}
		for _,line in ipairs(lines) do
			for _,p in ipairs(line) do
				predicted[grid.get_idx(p.x, p.y)] = true
			end
		end
		predicted[origin_i] = nil
		predicted[j.i] = nil
		return base.equals(j.covered, predicted)
	end
}
