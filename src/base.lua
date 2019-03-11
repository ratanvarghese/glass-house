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

return base
