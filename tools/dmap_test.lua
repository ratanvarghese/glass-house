local base = require("src.base")
local level = require("src.level")
local ui = require("ui.std")

math.randomseed(os.time())
level.current = level.make(1)

for y=1,base.MAX_Y do
	for x=1,base.MAX_X do
		local i = base.getIdx(x, y)
		level.current.light[i] = true
	end
end

ui.init()

function huh()
	print(base.getIdx(5, nil))
end

local ok, err = xpcall(function()
	ui.drawlevel()
	ui.drawpaths()

	huh()
end, base.error_handler)
ui.shutdown()

if not ok then
	print(err)
end
