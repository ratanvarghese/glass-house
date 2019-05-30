local grid = {}

grid.MAX_X = 70
grid.MAX_Y = 20

grid.direction = {
	north = {y = -1, x = 0},
	south = {y = 1, x = 0},
	west = {y = 0, x = -1},
	east = {y = 0, x = 1}
}

grid.direction_list = {}
for _,v in pairs(grid.direction) do
	table.insert(grid.direction_list, v)
end

function grid.get_idx(x, y)
	assert(type(x)=="number", "invalid x: "..tostring(x))
	assert(type(y)=="number", "invalid y: "..tostring(y))
	return (y*grid.MAX_X) + x
end

function grid.is_edge(x, y)
	return x == 1 or x == grid.MAX_X or y == 1 or y == grid.MAX_Y
end

function grid.make_rect(x1, y1, x2, y2, f)
	local res = {}
	grid.edit_rect(x1, y1, x2, y2, res, f)
	return res
end

function grid.make_full(f)
	local res = {}
	grid.edit_full(res, f)
	return res
end

function grid.edit_rect(x1, y1, x2, y2, t, f)
	local min_x = math.max(x1, 1)
	local max_x = math.min(x2, grid.MAX_X)
	local min_y = math.max(y1, 1)
	local max_y = math.min(y2, grid.MAX_Y)
	for y = min_y,max_y do
		for x = min_x,max_x do
			local i = grid.get_idx(x, y)
			t[i] = f(x, y, i)
		end
	end
end

function grid.edit_full(t, f)
	grid.edit_rect(1, 1, grid.MAX_X, grid.MAX_Y, t, f)
end

function grid.rn_direction()
	return grid.direction_list[math.random(1, #grid.direction_list)]
end

function grid.rn_xy()
	local x = math.random(2, grid.MAX_X - 1)
	local y = math.random(2, grid.MAX_Y - 1)
	return x, y
end

grid.not_edge_t = grid.make_full(function(x, y, i) return not grid.is_edge(x, y) end)

return grid
