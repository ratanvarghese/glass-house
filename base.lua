local base = {}

base.MAX_X = 70
base.MAX_Y = 20
base.savefile = ".save.glass"
base.symbols = {
	floor = ".",
	wall = "#",
	player = "@",
	stair = "<",
	dark = " "
}
	
function base.getIdx(x, y)
	return (y*base.MAX_X) + x
end

return base
