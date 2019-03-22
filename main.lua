local base = require("src.base")
local file = require("src.file")
local level = require("src.level")
local loop = require("src.loop")

local ui
if arg[1] == "--stdio" or arg[1] == "-s" then
	ui = require("ui.std")
else
	ui = require("ui.rogue")
end

math.randomseed(os.time())

local state = file.load()
if state then
	level.current = state.current
	level.register(level.current)
else	
	level.current = level.make(1)
end

ui.init()
local ok, err = xpcall(function()
	while loop.iter(ui) do
	end

	if level.current.game_over then
		file.remove_save()
		ui.game_over(level.current.game_over)
	else
		local state = {
			current = level.current
		}
		file.save(state)
	end
end, base.error_handler)
ui.shutdown()

if not ok then
	print(err)
end
