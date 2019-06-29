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
