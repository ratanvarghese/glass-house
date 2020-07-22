--- Manage positions on a cartesian plane.
--
-- Note that there is no z-index, z-dimension, or elevation. To handle entities on top of
-- each other, each "layer" can be treated as seperate cartesian planes.
-- @module core.grid

local base = require("core.base")
local enum = require("core.enum")

local grid = {}

--- Integer representing a cartesian point.
--
-- In this application, there are two ways to represent a position:
--
-- 1. as x,y coordinates, where both x & y are integers
-- 2. as an integer (referred to in this documentation as a `grid.pos`)
--
-- For coordinates, the minimum value for both x and y are 1. The maximum
-- values are `core.grid.MAX_X` and `core.grid.MAX_Y` respectively.
-- For `grid.pos`, the minimum and maximum are `core.grid.MIN_POS` and
-- `core.grid.MAX_POS`.
--
-- Usually `grid.pos` is used, especially in cases where a collection
-- must be indexed by position.
-- @typedef grid.pos

--- Command enum representing cardinal direction.
-- The cardinal directions are represented using elements of `enum.cmd`:
--
-- + enum.cmd.north
-- + enum.cmd.south
-- + enum.cmd.west
-- + enum.cmd.east
-- @typedef grid.cardinal

--- Table representing vector.
-- Vectors can be represented using a table of the form `{x = a, y = b}`, where `a` and
-- `b` are integers.
-- @typedef grid.vector


--- Convert x,y coordinates to `grid.pos`
-- @tparam int x
-- @tparam int y
-- @treturn grid.pos
function grid.get_pos(x, y)
	return ((y-1)*grid.MAX_X) + x
end

local function get_x(i)
	local x = i % grid.MAX_X
	if x == 0 then
		return grid.MAX_X
	else
		return x
	end
end

--- Convert `grid.pos` to x,y coordinates
-- @tparam grid.pos i
-- @treturn int x
-- @treturn int y
function grid.get_xy(i)
	local x = get_x(i)
	local y = ((i - x) / grid.MAX_X) + 1
	return x, y
end

--- Clip x,y so that they are both within the grid limits.
-- @tparam int x
-- @tparam int y
-- @tparam[opt=0] int n the minimum distance from the edge
-- @treturn int clipped x
-- @treturn int clipped y
function grid.clip(x, y, n)
	local n = n or 0
	local cx = base.clip(x, n+1, grid.MAX_X-n)
	local cy = base.clip(y, n+1, grid.MAX_Y-n)
	return cx, cy
end

--- Return true if x,y coordinate is on the edge of grid limits.
-- @tparam int x
-- @tparam int y
-- @treturn bool
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

--- Iterate over area of a rectangle in a `for` loop.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam[opt={}] table t table with grid.pos keys
-- @tparam[opt] grid.pos i1 the northwest rectangle corner, defaults to northwest grid limit
-- @tparam[opt] grid.pos i2 the southeast rectangle corner, defaults to southeast grid limit
-- @usage t = {[grid.get_pos(2,2)] = "Hi"}
-- for pos,x,y,v in grid.points(t, grid.get_pos(1,1), grid.get_pos(3,3)) do
--     print(x, y, v) -- When x == 2 and y == 2, v will be "Hi"
-- end
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

--- Travel from a start point along a cardinal directions.
-- @tparam grid.pos start_i
-- @tparam[opt=1] int distance
-- @tparam[opt] grid.cardinal direction defaults to random direction
-- @tparam[opt] int clipn minimum distance from grid edges for the destination
-- @treturn grid.pos destination point of travel
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

--- Calculate all points along a straight line
-- @tparam grid.pos i1 start of line
-- @tparam grid.pos i2 end of line
-- @treturn {grid.pos,...} list of grid.pos, from start to end of line
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


--- Find minima or maxima of `t` near a start position.
-- A point is "near" `start_pos` if it can be reached from `start_pos` using one of the
-- vectors in `directions_table`.
-- @tparam grid.pos start_pos
-- @tparam {[grid.pos]=number,...} t
-- @tparam[opt] bool domax if truthy find maxima, if falsy find minima
-- @tparam[opt] {grid.vector,...} directions_table defaults to `core.grid.directions`
-- @treturn int nearby maxima or mimima
-- @treturn grid.pos position of nearby maxima or minima
function grid.extreme_destination(start_pos, t, domax, directions_table)
	local current_v = domax and -math.huge or math.huge
	local current_pos = nil
	for _,pos in grid.destinations(start_pos, directions_table) do
		local v = t[pos]
		if v and ((domax and v > current_v) or (not domax and v < current_v)) then
			current_v = v
			current_pos = pos
		end
	end
	return current_v, current_pos
end

--- Calculate distance between two points.
-- It is assumed that each step is vertical or horizontal.
-- Diagonal movement takes 2 steps.
-- @tparam grid.pos i1
-- @tparam grid.pos i2
-- @treturn int distance
function grid.distance(i1, i2)
	local x1, y1 = grid.get_xy(i1)
	local x2, y2 = grid.get_xy(i2)
	return math.abs(y2 - y1) + math.abs(x2 - x1)
end

local function destinations_iter(_s, _var)
	local dk = next(_s.directions_table, _var)
	if dk == nil then
		return nil
	end
	local dv = _s.directions_table[dk]
	local x = _s.x + dv.x
	local y = _s.y + dv.y
	if x < 1 or x > grid.MAX_X or y < 1 or y > grid.MAX_Y then
		return destinations_iter(_s, dk)
	else
		return dk, grid.get_pos(grid.clip(x, y))
	end
end

--- Iterate over points near a start point in a `for` loop.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam grid.pos start
-- @tparam[opt] {[any]=grid.vector,...} directions_table defaults to `grid.directions`
-- @usage for _, near_pos in grid.destinations(start) do
--    -- do something
-- end
function grid.destinations(start, directions_table)
	local directions_table = directions_table or grid.directions
	local x, y = grid.get_xy(start)
	return destinations_iter, {x=x, y=y, directions_table=directions_table}, nil
end

--- Iterate over area of a square, centered around a given point.
-- @tparam grid.pos center
-- @tparam int radius minimum distance from center to any edge
-- @tparam[opt={}] {[grid.pos]=any,..} t
-- @usage t = {[grid.get_pos(2,2)] = "Hi"}
-- for pos,x,y,v in grid.surround(grid.get_pos(2,2),1,t) do
--     print(x, y, v) -- When x == 2 and y == 2, v will be "Hi"
-- end
function grid.surround(center, radius, t)
	local c_x, c_y = grid.get_xy(center)
	local p_start = grid.get_pos(grid.clip(c_x-radius, c_y-radius))
	local p_end = grid.get_pos(grid.clip(c_x+radius, c_y+radius))
	return grid.points(t, p_start, p_end)
end

--- Given two points, determine the cardinal direction leading from one to the other.
-- If no cardinal direction can lead from one point to the other, returns nil.
-- @tparam grid.pos source_pos the start point
-- @tparam grid.pos targ_pos the destination point
-- @treturn[opt] grid.cardinal
function grid.line_direction(source_pos, targ_pos)
	local s_x, s_y = grid.get_xy(source_pos)
	local t_x, t_y = grid.get_xy(targ_pos)
	if s_x == t_x then
		if s_y < t_y then
			return enum.cmd.south
		elseif s_y > t_y then
			return enum.cmd.north
		end
	elseif s_y == t_y then
		if s_x < t_x then
			return enum.cmd.east
		elseif s_x > t_x then
			return enum.cmd.west
		end
	end
end

--- Initialize `core.grid` module
-- @tparam int max_x the new maximum x
-- @tparam int max_y the new maximum y
-- @treturn table the grid module
function grid.init(max_x, max_y)
	assert(type(max_x) == "number", "No max_x")
	assert(type(max_y) == "number", "No max_y")

	--- The maximum X (initialized by `grid.init`)
	grid.MAX_X = max_x

	--- The maximum Y (initialized by `grid.init`)
	grid.MAX_Y = max_y

	--- The minimum grid.pos (initialized by `grid.init`)
	grid.MAX_POS = grid.get_pos(grid.MAX_X, grid.MAX_Y)

	--- The maximum grid.pos (initialized by `grid.init`)
	grid.MIN_POS = grid.get_pos(1, 1)

	--- Vectors for cardinal directions (initialized by `grid.init`).
	-- Keys are `grid.cardinal`. Values are `grid.vector`
	grid.directions = {
		[enum.cmd.north] = {x=0, y=-1},
		[enum.cmd.south] = {x=0, y=1},
		[enum.cmd.east] = {x=1, y=0},
		[enum.cmd.west] = {x=-1, y=0},
	}

	--- List of `grid.cardinal` (initialized by `grid.init`).
	grid.direction_list = {
		enum.cmd.north,
		enum.cmd.south,
		enum.cmd.east,
		enum.cmd.west
	}
	return grid
end

return grid.init(70, 20)