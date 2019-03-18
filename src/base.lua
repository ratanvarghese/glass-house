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
	dark = " "
}

base.conf = {}

base.conf.keys = {
	quit = "q",
	north = "w",
	south = "s",
	west = "a",
	east = "d"
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

function base.getIdx(x, y)
	assert(type(x)=="number", "invalid x:\n"..debug.traceback())
	assert(type(y)=="number", "invalid y:\n"..debug.traceback())
	return (y*base.MAX_X) + x
end

function base.rn_direction()
	return base.direction_list[math.random(1, #base.direction_list)]
end

function base.adjacent_min(t, x, y)
	local res = base.MAX_X * base.MAX_Y
	for _,d in pairs(base.direction) do
		local di = base.getIdx(x + d.x, y + d.y)
		local new_res = t[di]
		if new_res and res > new_res then
			res = new_res
		end
	end
	return res
end

function base.shallow_equals(t1, t2)
	for k,v in pairs(t1) do
		if t2[k] ~= v then
			return false
		end
	end
	for k,v in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end
	return true
end

function base.shallow_copy(t1)
	local res = {}
	for k,v in pairs(t1) do
		res[k] = v
	end
	return res
end

return base
