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
	
function base.getIdx(x, y)
	assert(type(x)=="number", "invalid x:\n"..debug.traceback())
	assert(type(y)=="number", "invalid y:\n"..debug.traceback())
	return (y*base.MAX_X) + x
end

return base
