local base = require("src.base")
local file = require("src.file")
local level = require("src.level")
local loop = require("src.loop")
local bestiary = require("src.bestiary")
local enum = require("src.enum")

local ui
if arg[1] == "--stdio" or arg[1] == "-s" then
	ui = require("ui.std")
else
	ui = require("ui.rogue")
end

local BIG = false
if arg[1] == "--big" or arg[1] == "-b" then
	BIG = true
end

math.randomseed(os.time())

local state = file.load()
if state then
	enum.init(state.enum_inverted)
	bestiary.set = state.bestiary_set
	level.current = state.current
	level.register(level.current)
else
	bestiary.make_set()
	level.current = level.make(1, BIG)
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
			current = level.current,
			enum_inverted = enum.inverted,
			bestiary_set = bestiary.set
		}
		file.save(state)
	end
end, base.error_handler)
ui.shutdown()

if not ok then
	print(err)
end
