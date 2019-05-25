local base = require("src.base")
local grid = require("src.grid")
local level = require("src.level")
local ui = require("ui.std")

math.randomseed(os.time())
level.current = level.make(1)
level.current:set_light(true)

ui.init()

function huh()
	print(grid.get_idx(5, nil))
end

local ok, err = xpcall(function()
	ui.draw_level(level.current)
	ui.draw_paths(level.current)

	huh()
end, base.error_handler)
ui.shutdown()

if not ok then
	print(err)
end
