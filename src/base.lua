local base = {}

base.MAX_X = 70
base.MAX_Y = 20
base.savefile = ".save.glass"
base.symbols = {
	player = "@",
	angel = "A",
	dragon = "D",
	floor = ".",
	wall = "#",
	stair = "<",
	dark = " ",
	tool = "("
}

base.conf = {}

base.conf.keys = {
	quit = "q",
	north = "w",
	south = "s",
	west = "a",
	east = "d",
	drop = "f"
}

base.direction = {
	north = {y = -1, x = 0},
	south = {y = 1, x = 0},
	west = {y = 0, x = -1},
	east = {y = 0, x = 1}
}

base.direction_list = {}
for _,v in pairs(base.direction) do
	table.insert(base.direction_list, v)
end

function base.get_idx(x, y)
	assert(type(x)=="number", "invalid x: "..tostring(x))
	assert(type(y)=="number", "invalid y: "..tostring(y))
	return (y*base.MAX_X) + x
end

function base.is_edge(x, y)
	return x == 1 or x == base.MAX_X or y == 1 or y == base.MAX_Y
end

function base.for_all_points(f)
	base.for_rect(1, 1, base.MAX_X, base.MAX_Y, f)
end

function base.for_rect(x1, y1, x2, y2, f)
	local min_x = math.max(x1, 1)
	local max_x = math.min(x2, base.MAX_X)
	local min_y = math.max(y1, 1)
	local max_y = math.min(y2, base.MAX_Y)
	for y = min_y,max_y do
		for x = min_x,max_x do
			f(x, y, base.get_idx(x, y))
		end
	end
end

function base.error_handler(msg)
	return msg.."\n"..debug.traceback()
end

function base.rn_direction()
	return base.direction_list[math.random(1, #base.direction_list)]
end

function base.rn_xy()
	local x = math.random(2, base.MAX_X - 1)
	local y = math.random(2, base.MAX_Y - 1)
	return x, y
end

function base.adjacent_min(t, x, y)
	local res = math.huge
	local res_x, res_y = x, y
	for _,d in pairs(base.direction) do
		local nx = x + d.x
		local ny = y + d.y
		local di = base.get_idx(nx, ny)
		local new_res = t[di]
		if (new_res and res > new_res) then
			res = new_res
			res_x = nx
			res_y = ny
		end
	end
	return res, res_x, res_y
end

function base.equals(a, b)
	local type1, type2 = type(a), type(b)
	if type1 ~= type2 then
		return false
	elseif type1 ~= "table" and type2 ~= "table" then
		return a == b
	elseif #a ~= #b then
		return false
	end

	for k,v in pairs(a) do
		if not base.equals(v, b[k]) then
			return false
		end
	end

	for k,v in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

--Based on http://stackoverflow.com/questions/640642
function base.copy(a, seen)
	if type(a) ~= "table" then
		return a
	end
	if seen and seen[a] then
		return seen[a]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(a))
	s[a] = res
	for k,v in pairs(a) do
		res[base.copy(k, s)] = base.copy(v, s)
	end
	return res
end

return base
