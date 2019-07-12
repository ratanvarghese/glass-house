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
	return (y*grid.MAX_X) + x
end

local function get_x(i)
	local x = i % grid.MAX_X
	if x == 0 then
		return grid.MAX_X
	else
		return x
	end
end

function grid.get_xy(i)
	local x = get_x(i)
	local y = (i - x) / grid.MAX_X
	return x, y
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

local function iter(invariant, i)
	local x, y = grid.get_xy(i)
	local nx, ny, ni = x+1, y, i+1
	if nx > invariant.x2 then
		nx = invariant.x1
		ny = ny + 1
		ni = grid.get_idx(nx, ny)
	end
	if ni > invariant.max then
		return nil, nil, nil, nil
	else
		return ni, nx, ny, invariant.t[ni]
	end
end

function grid.points(t, x1, y1, x2, y2)
	local t = t or {}
	local x1 = math.max(x1 or 1, 1)
	local y1 = math.max(y1 or 1, 1)
	local x2 = math.min(x2 or grid.MAX_X, grid.MAX_X)
	local y2 = math.min(y2 or grid.MAX_Y, grid.MAX_Y)
	local min = grid.get_idx(x1, y1)
	local max = grid.get_idx(x2, y2)

	local f = iter
	local invariant = {t=t, max=max, x1=x1, y1=y1, x2=x2, y2=y2}
	local initial = (min-1)

	return f, invariant, initial
end

function grid.edit_rect(x1, y1, x2, y2, t, f)
	for i,x,y in grid.points(nil, x1, y1, x2, y2) do
		t[i] = f(x, y, i)
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

function grid.are_adjacent(x1, y1, x2, y2)
	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)
end

local function bresenham(x1, y1, x2, y2, dx, dy, is_steep)
	--Bresenham's line algo, modified to avoid diagonal movement
	--See http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
	local ix = dx > 0 and 1 or -1
	local iy = dy > 0 and 1 or -1
	local abs_2dx = 2 * math.abs(dx)
	local abs_2dy = 2 * math.abs(dy)
	local function pt() return is_steep and {x = y1, y = x1} or {x = x1, y = y1} end
	
	local res = {}
	table.insert(res, pt())
	local err = abs_2dy - abs_2dx / 2
	while x1 ~= x2 do
		if err > 0 or (err == 0 and ix > 0) then
			err = err - abs_2dx
			y1 = y1 + iy
			table.insert(res, pt())
		end
		err = err + abs_2dy
		x1 = x1 + ix
		table.insert(res, pt())
	end
	return res
end

function grid.line(x1, y1, x2, y2)
	--Bresenham's line algo, modified to avoid diagonal movement
	--See http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
	local dx = x2 - x1
	local dy = y2 - y1
	if math.abs(dx) < math.abs(dy) then
		return bresenham(y1, x1, y2, x2, dy, dx, true)
	else
		return bresenham(x1, y1, x2, y2, dx, dy, false)
	end
end

local prev_jumps = false
function grid.knight_jumps(refresh)
	local d_list = {
		{x=2, y=1, middle={x=1}},
		{x=1, y=2, middle={y=1}},
		{x=-2, y=1, middle={x=-1}},
		{x=-1, y=2, middle={y=1}},
		{x=2, y=-1, middle={x=1}},
		{x=-1, y=-2, middle={y=-1}},
		{x=-2, y=-1, middle={x=-1}},
		{x=1, y=-2, middle={y=-1}},
	}
	if not refresh and prev_jumps then
		return prev_jumps
	end
	prev_jumps = grid.make_full(function(x, y, i)
		local res = {}
		for _,d in pairs(d_list) do
			local nx = x + d.x
			local ny = y + d.y
			if nx >= 1 and nx <= grid.MAX_X and ny >= 1 and ny <= grid.MAX_Y then
				local ni = grid.get_idx(nx, ny)
				local covered = {
					[grid.get_idx(x, ny)] = true,
					[grid.get_idx(nx, y)] = true
				}
				if d.middle.x then
					local mid_x = x + d.middle.x
					covered[grid.get_idx(mid_x, y)] = true
					covered[grid.get_idx(mid_x, ny)] = true
				elseif d.middle.y then
					local mid_y = y + d.middle.y
					covered[grid.get_idx(x, mid_y)] = true
					covered[grid.get_idx(nx, mid_y)] = true
				end
				table.insert(res, {x=nx, y=ny, i=ni, covered=covered})
			end
		end
		return res
	end)
	return prev_jumps
end


grid.not_edge_t = grid.make_full(function(x, y, i) return not grid.is_edge(x, y) end)

return grid
