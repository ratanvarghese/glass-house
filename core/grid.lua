local base = require("core.base")
local enum = require("core.enum")

local grid = {}

function grid.get_pos(x, y)
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

function grid.clip(x, y, n)
	local n = n or 0
	local cx = base.clip(x, n+1, grid.MAX_X-n)
	local cy = base.clip(y, n+1, grid.MAX_Y-n)
	return cx, cy
end

function grid.is_edge(x, y)
	return x == 1 or x == grid.MAX_X or y == 1 or y == grid.MAX_Y
end

local function points_iter(invariant, i)
	local x, y = grid.get_xy(i)
	local nx, ny, ni = x+1, y, i+1
	if nx > invariant.x2 then
		nx = invariant.x1
		ny = ny + 1
		ni = grid.get_pos(nx, ny)
	end
	if ni > invariant.max then
		return nil, nil, nil, nil
	else
		return ni, nx, ny, invariant.t[ni]
	end
end

function grid.points(t, i1, i2)
	local t = t or {}
	local i1 = i1 or grid.get_pos(1, 1)
	local i2 = i2 or grid.get_pos(grid.MAX_X, grid.MAX_Y)
	local x1, y1 = grid.get_xy(i1)
	local x2, y2 = grid.get_xy(i2)

	local f = points_iter
	local invariant = {t=t, max=i2, x1=x1, x2=x2}
	local initial = (i1-1) --Because f will be called before any values generated

	return f, invariant, initial
end

function grid.travel(start_i, distance, direction, clipn)
	local distance = distance or 1
	local direction = direction or grid.direction_list[math.random(1, #grid.direction_list)]

	local d = grid.directions[direction]
	local start_x, start_y = grid.get_xy(start_i)
	local end_x, end_y
	local end_x = start_x + (d.x*distance)
	local end_y = start_y + (d.y*distance)
	return grid.get_pos(grid.clip(end_x, end_y, clipn))
end

local function bresenham(x1, y1, x2, y2, dx, dy, is_steep)
	--Bresenham's line algo, modified to avoid diagonal movement
	--See http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
	local ix = dx > 0 and 1 or -1
	local iy = dy > 0 and 1 or -1
	local abs_2dx = 2 * math.abs(dx)
	local abs_2dy = 2 * math.abs(dy)
	local function pt()
		return is_steep and grid.get_pos(y1, x1) or grid.get_pos(x1, y1)
	end
	
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

function grid.line(i1, i2)
	--Bresenham's line algo, modified to avoid diagonal movement
	--See http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
	local x1, y1 = grid.get_xy(i1)
	local x2, y2 = grid.get_xy(i2)
	local dx = x2 - x1
	local dy = y2 - y1
	if math.abs(dx) < math.abs(dy) then
		return bresenham(y1, x1, y2, x2, dy, dx, true)
	else
		return bresenham(x1, y1, x2, y2, dx, dy, false)
	end
end

function grid.adjacent_extreme(i, t, domax)
	local current = domax and -math.huge or math.huge
	local current_i = nil

	for d in pairs(grid.directions) do
		local new_i = grid.travel(i, 1, d)
		local new_v = t[new_i]
		if new_v then
			if (domax and new_v > current) or (not domax and new_v < current) then
				current = new_v
				current_i = new_i
			end
		end
	end
	return current, current_i
end

function grid.distance(i1, i2)
	local x1, y1 = grid.get_xy(i1)
	local x2, y2 = grid.get_xy(i2)
	return math.abs(y2 - y1) + math.abs(x2 - x1)
end

function grid.destinations_iter(_s, _var)
	local dk = next(_s.directions_table, _var)
	if dk == nil then
		return nil
	end
	local dv = _s.directions_table[dk]
	local x = _s.x + dv.x
	local y = _s.y + dv.y
	if x < 1 or x > grid.MAX_X or y < 1 or y > grid.MAX_Y then
		return grid.destinations_iter(_s, dk)
	else
		return dk, grid.get_pos(grid.clip(x, y))
	end
end

function grid.destinations(start, directions_table)
	local directions_table = directions_table or grid.directions
	local x, y = grid.get_xy(start)
	return grid.destinations_iter, {x=x, y=y, directions_table=directions_table}, nil
end

function grid.init(max_x, max_y)
	assert(type(max_x) == "number", "No max_x")
	assert(type(max_y) == "number", "No max_y")
	grid.MAX_X = max_x
	grid.MAX_Y = max_y
	grid.directions = {
		[enum.cmd.north] = {x=0, y=-1},
		[enum.cmd.south] = {x=0, y=1},
		[enum.cmd.east] = {x=1, y=0},
		[enum.cmd.west] = {x=-1, y=0},
	}
	grid.direction_list = {
		enum.cmd.north,
		enum.cmd.south,
		enum.cmd.east,
		enum.cmd.west
	}
	return grid
end

return grid.init(70, 20)
