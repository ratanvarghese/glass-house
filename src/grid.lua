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

function grid.for_all_points(f)
	grid.for_rect(1, 1, grid.MAX_X, grid.MAX_Y, f)
end

function grid.for_rect(x1, y1, x2, y2, f)
	local min_x = math.max(x1, 1)
	local max_x = math.min(x2, grid.MAX_X)
	local min_y = math.max(y1, 1)
	local max_y = math.min(y2, grid.MAX_Y)
	for y = min_y,max_y do
		for x = min_x,max_x do
			f(x, y, grid.get_idx(x, y))
		end
	end
end

function grid.rn_direction()
	return grid.direction_list[math.random(1, #grid.direction_list)]
end

function grid.rn_xy()
	local x = math.random(2, grid.MAX_X - 1)
	local y = math.random(2, grid.MAX_Y - 1)
	return x, y
end

function grid.adjacent_min(t, x, y)
	local res = math.huge
	local res_x, res_y = x, y
	for _,d in pairs(grid.direction) do
		local nx = x + d.x
		local ny = y + d.y
		local di = grid.get_idx(nx, ny)
		local new_res = t[di]
		if (new_res and res > new_res) then
			res = new_res
			res_x = nx
			res_y = ny
		end
	end
	return res, res_x, res_y
end

return grid
