local base = require("src.base")
local level = require("src.level")
local ui = require("ui.std")

local debug_mode = false

if arg[1] == "--debug" or arg[1] == "-d" then
	debug_mode = true
end

if not debug_mode then
	debug = {
		traceback = function() return "" end
	}
end

math.randomseed(os.time())
level.current = level.make(1)

for y=1,base.MAX_Y do
	for x=1,base.MAX_X do
		local i = base.getIdx(x, y)
		level.current.light[i] = true
	end
end

ui.init()
ui.drawlevel()
ui.drawpaths()
ui.shutdown()
