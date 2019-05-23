local base = require("src.base")
local level = require("src.level")
local ui = require("ui.std")

math.randomseed(os.time())
level.current = level.make(1)
level.current:set_light(true)

ui.init()

function huh()
	print(base.get_idx(5, nil))
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
