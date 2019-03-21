local base = require("src.base")

local unique_idx_set = {}
property "base.getIdx: unique idx" {
	generators = { int(1, base.MAX_X), int(1, base.MAX_Y) },
	check = function(x, y)
		local i = base.getIdx(x, y)
		local alreadyFound = unique_idx_set[i]
		unique_idx_set[i] = {x=x, y=y}
		if alreadyFound then
			return alreadyFound.x == x and alreadyFound.y == y
		else
			return true
		end
	end
}

property "base.getIdx: error on string" {
	generators = { str(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.getIdx(s,i) end)
		local ok_2 = pcall(function() base.getIdx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "base.getIdx: error on table" {
	generators = { tbl(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.getIdx(s,i) end)
		local ok_2 = pcall(function() base.getIdx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}
property "base.getIdx: error on bool" {
	generators = { bool(), int(1, base.MAX_X) },
	check = function(s, i)
		local ok_1 = pcall(function() base.getIdx(s,i) end)
		local ok_2 = pcall(function() base.getIdx(i,s) end)
		return (not ok_1) and (not ok_2)
	end
}

local function smallGrid(x, y, v1, v2, v3, v4)
	return {
		[base.getIdx(x,y+1)] = v1,
		[base.getIdx(x,y-1)] = v2,
		[base.getIdx(x+1,y)] = v3,
		[base.getIdx(x-1,y)] = v4
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
		return grid[base.getIdx(res_x, res_y)] == math.min(v1, v2, v3, v4)
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
